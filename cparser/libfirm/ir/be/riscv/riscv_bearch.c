/*
 * This file is part of libFirm.
 * Copyright (C) 2018 Christoph Mallon.
 */

#include "riscv_bearch_t.h"

#include "be2addr.h"
#include "be_t.h"
#include "beirg.h"
#include "bemodule.h"
#include "benode.h"
#include "bera.h"
#include "besched.h"
#include "bespillslots.h"
#include "bestack.h"
#include "betranshlp.h"
#include "bevarargs.h"
#include "gen_riscv_new_nodes.h"
#include "gen_riscv_regalloc_if.h"
#include "irarch.h"
#include "iredges.h"
#include "irgwalk.h"
#include "irprog_t.h"
#include "platform_t.h"
#include "lower_builtins.h"
#include "lower_calls.h" 
#include "lowering.h"
#include "riscv_emitter.h"
#include "riscv_lower64.h"
#include "lower_softfloat.h"
#include "riscv_transform.h"
#include "target_t.h"
#include "util.h"
#include "irtools.h"
#include "lc_opts_enum.h"

bool use_softfloat = true;

static ir_settings_arch_dep_t const riscv_arch_dep = {
	.replace_muls         = true,
	.replace_divs         = true,
	.replace_mods         = true,
	.allow_mulhs          = true,
	.allow_mulhu          = true,
	.also_use_subs        = true,
	.maximum_shifts       = 4,
	.highest_shift_amount = 63,
	.evaluate             = NULL,
	.max_bits_for_mulh    = RISCV_MACHINE_SIZE,
};

/**
 * Splits a 32 bit immediate value into a 20 bit hi and a 12 bit lo part, which can be realised by lui and addi
 * instructions.
 */
riscv_hi_lo_imm calc_hi_lo(int32_t val) {
	int32_t hi = ((uint32_t) val >> 12) + ((uint32_t) val >> 11 & 1);
	if (hi >= 1048576) { //2^20
		hi = 0;
	}
	int32_t const lo = (uint32_t) val - ((uint32_t) hi << 12);
	return (riscv_hi_lo_imm) {hi, lo};
}

static void riscv_init_asm_constraints(void)
{
	be_set_constraint_support(ASM_CONSTRAINT_FLAG_SUPPORTS_MEMOP,     "m");
	be_set_constraint_support(ASM_CONSTRAINT_FLAG_SUPPORTS_REGISTER,  "r");
	be_set_constraint_support(ASM_CONSTRAINT_FLAG_SUPPORTS_ANY,       "g");
	be_set_constraint_support(ASM_CONSTRAINT_FLAG_SUPPORTS_IMMEDIATE, "IJKin");
}

static int riscv_ifconv(ir_node const *const sel, ir_node const *const mux_false, ir_node const *mux_true)
{
	(void)sel;
	(void)mux_false;
	(void)mux_true;
	return false;
}

static void riscv_init(void)
{
	riscv_init_asm_constraints();
	riscv_create_opcodes();
	riscv_register_init();

	ir_target.experimental = "the RISC-V backend is highly experimental and unfinished";

	ir_target.allow_ifconv       = riscv_ifconv;
	ir_target.float_int_overflow = ir_overflow_min_max;
    ir_platform_set_va_list_type_pointer();
    if(!use_softfloat) ir_platform.map_double_float  = true;
}

static void riscv_finish(void)
{
	riscv_free_opcodes();
}

static void riscv_select_instructions(ir_graph *const irg)
{
	be_timer_push(T_CODEGEN);
	riscv_transform_graph(irg);
	be_timer_pop(T_CODEGEN);
	be_dump(DUMP_BE, irg, "code-selection");

	place_code(irg);
	be_dump(DUMP_BE, irg, "place");
}

static ir_node *riscv_new_spill(ir_node *const value, ir_node *const after)
{
	ir_mode *const mode = get_irn_mode(value);
    ir_node  *const block = get_block(after);
    ir_graph *const irg   = get_irn_irg(after);
	ir_node  *const nomem = get_irg_no_mem(irg);
	ir_node  *const frame = get_irg_frame(irg);
	if (be_mode_needs_gp_reg(mode)) {		
		ir_node  *const store = new_bd_riscv_sw(NULL, block, nomem, frame, value, NULL, 0);
		sched_add_after(after, store);
		return store;
	}
    if (mode_is_float(mode)) {
        ir_node  *const store = new_bd_riscv_fsw(NULL, block, nomem, frame, value, NULL, 0);
		sched_add_after(after, store);
		return store;
    }
	TODO(value);
}

static ir_node *riscv_new_reload(ir_node *const value, ir_node *const spill, ir_node *const before)
{
	ir_mode *const mode = get_irn_mode(value);
    ir_node  *const block = get_block(before);
	ir_graph *const irg   = get_irn_irg(before);
	ir_node  *const frame = get_irg_frame(irg);
	if (be_mode_needs_gp_reg(mode)) {
		ir_node  *const load  = new_bd_riscv_lw(NULL, block, spill, frame, NULL, 0);
		sched_add_before(before, load);
		return be_new_Proj(load, pn_riscv_lw_res);
	}
    if (mode_is_float(mode)) {
        ir_node  *const load  = new_bd_riscv_flw(NULL, block, spill, frame, NULL, 0);
		sched_add_before(before, load);
		return be_new_Proj(load, pn_riscv_lw_res);
    }
	TODO(value);
}

static regalloc_if_t const riscv_regalloc_if = {
	.spill_cost  = 7,
	.reload_cost = 5,
	.new_spill   = riscv_new_spill,
	.new_reload  = riscv_new_reload,
};

static void riscv_collect_frame_entity_nodes(ir_node *const node, void *const data)
{
	be_fec_env_t *const env = (be_fec_env_t*)data;

	if (is_riscv_lw(node)) {
		ir_node  *const base  = get_irn_n(node, n_riscv_lw_base);
		ir_graph *const irg   = get_irn_irg(node);
		ir_node  *const frame = get_irg_frame(irg);
		if (base == frame) {
			riscv_immediate_attr_t const *const attr = get_riscv_immediate_attr_const(node);
			if (!attr->ent) {
				unsigned const size     = RISCV_MACHINE_SIZE / 8; // TODO
				unsigned const po2align = log2_floor(size);
				be_load_needs_frame_entity(env, node, size, po2align);
			}
		}
	}
}

static void riscv_set_frame_entity(ir_node *const node, ir_entity *const entity, unsigned const size, unsigned const po2align)
{
	(void)size, (void)po2align;

	riscv_immediate_attr_t *const imm = get_riscv_immediate_attr(node);
	imm->ent = entity;
}

static void riscv_assign_spill_slots(ir_graph *const irg)
{
	be_fec_env_t *const fec_env = be_new_frame_entity_coalescer(irg);
	irg_walk_graph(irg, NULL, riscv_collect_frame_entity_nodes, fec_env);
	be_assign_entities(fec_env, riscv_set_frame_entity, true);
	be_free_frame_entity_coalescer(fec_env);
}

static ir_node *riscv_new_IncSP(ir_node *const block, ir_node *const sp, int const offset, unsigned const align)
{
	return be_new_IncSP(block, sp, offset, align);
}

static void riscv_introduce_prologue(ir_graph *const irg, unsigned const size)
{
	ir_node *const start    = get_irg_start(irg);
	ir_node *const block    = get_nodes_block(start);
	ir_node *const start_sp = be_get_Start_proj(irg, &riscv_registers[REG_X2]);
	ir_node *const inc_sp   = riscv_new_IncSP(block, start_sp, size, 0);
	sched_add_after(start, inc_sp);
	edges_reroute_except(start_sp, inc_sp, inc_sp);
}

static void riscv_introduce_epilogue(ir_node *const ret, unsigned const size)
{
	ir_node *const block  = get_nodes_block(ret);
	ir_node *const ret_sp = get_irn_n(ret, n_riscv_ret_stack);
	ir_node *const inc_sp = riscv_new_IncSP(block, ret_sp, -(int)size, 0);
	sched_add_before(ret, inc_sp);
	set_irn_n(ret, n_riscv_ret_stack, inc_sp);
}

static void riscv_introduce_prologue_epilogue(ir_graph *const irg)
{
	ir_type *const frame = get_irg_frame_type(irg);
	unsigned const size  = get_type_size(frame);
	if (size == 0)
		return;

	foreach_irn_in(get_irg_end_block(irg), i, ret) {
		assert(is_riscv_ret(ret));
		riscv_introduce_epilogue(ret, size);
	}

	riscv_introduce_prologue(irg, size);
}

static void riscv_sp_sim(ir_node *const node, stack_pointer_state_t *const state)
{
	if (be_is_MemPerm(node)) {		
			be_set_MemPerm_offset(node, state->offset);
		return;
	}
    if (is_riscv_irn(node)) {
		switch ((riscv_opcodes)get_riscv_irn_opcode(node)) {
		case iro_riscv_addi:
		case iro_riscv_FrameAddr:
		case iro_riscv_lb:
		case iro_riscv_lbu:
		case iro_riscv_lh:
		case iro_riscv_lhu:
		case iro_riscv_lw:
		case iro_riscv_sb:
		case iro_riscv_sh:
		case iro_riscv_sw:
		case iro_riscv_fsw:
		case iro_riscv_flw:
		{
			riscv_immediate_attr_t *const imm = get_riscv_immediate_attr(node);
			ir_entity              *const ent = imm->ent;
			if (ent && is_frame_type(get_entity_owner(ent))) {
				imm->ent  = NULL;
				imm->val += state->offset + get_entity_offset(ent);
			}
			break;
		}

		default:
			break;
		}
	}
}

static void riscv_generate_code(FILE *const output, char const *const cup_name)
{
	be_begin(output, cup_name);

	unsigned *const sp_is_non_ssa = rbitset_alloca(N_RISCV_REGISTERS);
	rbitset_set(sp_is_non_ssa, REG_X2);

	foreach_irp_irg(i, irg) {
		if (!be_step_first(irg))
			continue;

		be_irg_t *const birg = be_birg_from_irg(irg);
		birg->non_ssa_regs = sp_is_non_ssa;

		riscv_select_instructions(irg);
		be_step_schedule(irg);
		be_step_regalloc(irg, &riscv_regalloc_if);

		riscv_assign_spill_slots(irg);

		ir_type *const frame = get_irg_frame_type(irg);
		be_sort_frame_entities(frame, true);
		be_layout_frame_type(frame, 0, 0);

		riscv_introduce_prologue_epilogue(irg);
		be_fix_stack_nodes(irg, &riscv_registers[REG_X2]);
		birg->non_ssa_regs = NULL;
		be_sim_stack_pointer(irg, 0, 3, &riscv_sp_sim);

		riscv_finish_graph(irg);
		be_handle_2addr(irg, NULL);

		riscv_emit_function(irg);
		be_step_last(irg);
	}

	be_finish();
}

static void riscv32_lower_va_arg(ir_node *node)
{
	be_default_lower_va_arg(node, false, 4);
}

static void riscv_lower_for_target(void)
{
	ir_arch_lower(&riscv_arch_dep);
	be_after_irp_transform("lower-arch-dep");
    
    /* lower compound param handling */
	lower_calls_with_compounds(LF_RETURN_HIDDEN,
				   lower_aggregates_as_pointers, NULL,
				   lower_aggregates_as_pointers, NULL,
				   reset_stateless_abi);
	be_after_irp_transform("lower-calls");
    
	foreach_irp_irg(i, irg) {
		lower_CopyB(irg, 16, 17, false);
		be_after_transform(irg, "lower-copyb");
	}
    
    if (use_softfloat) {
        lower_floating_point();
        be_after_irp_transform("lower-fp"); 
    }
    
    size_t s = 0; 
	ir_builtin_kind  supported[8];
    
		supported[s++] = ir_bk_saturating_increment;
        supported[s++] = ir_bk_va_start;
	
	lower_builtins(s, supported, riscv32_lower_va_arg);

	ir_mode *const mode_gp = riscv_reg_classes[CLASS_riscv_gp].mode;
	foreach_irp_irg(i, irg) {
		lower_switch(irg, 4, 256, mode_gp);
		be_after_transform(irg, "lower-switch");
	}

	riscv_lower64();
	be_after_irp_transform("lower-64");
}

static unsigned riscv_get_op_estimated_cost(ir_node const *const node)
{
	(void)node; // TODO
	return 1;
}

arch_isa_if_t const riscv32_isa_if = {
	.name                  = "riscv32",
	.pointer_size          = 4,
	.modulo_shift          = 32,
	.big_endian            = false,
	.po2_biggest_alignment = 4,
	.pic_supported         = false,
	.n_registers           = N_RISCV_REGISTERS,
	.registers             = riscv_registers,
	.n_register_classes    = N_RISCV_CLASSES,
	.register_classes      = riscv_reg_classes,
	.init                  = riscv_init,
	.finish                = riscv_finish,
	.generate_code         = riscv_generate_code,
	.lower_for_target      = riscv_lower_for_target,
	.get_op_estimated_cost = riscv_get_op_estimated_cost,
};


static const lc_opt_table_entry_t riscv_options[] = {	
	LC_OPT_ENT_BOOL    ("soft-float", "use softwarefloating point emulation", &use_softfloat),
	LC_OPT_LAST
}; 

BE_REGISTER_MODULE_CONSTRUCTOR(be_init_arch_riscv32)
void be_init_arch_riscv32(void)
{ 
    lc_opt_entry_t *be_grp = lc_opt_get_grp(firm_opt_get_root(), "be");
	lc_opt_entry_t *riscv_grp = lc_opt_get_grp(be_grp, "riscv32");

	lc_opt_add_table(riscv_grp, riscv_options); 
}
