# This file is part of libFirm.
# Copyright (C) 2018 Christoph Mallon.

$arch = "riscv";

my $mode_gp = "mode_Iu";
my $mode_fp = "mode_F";

%reg_classes = (
	gp => {
		mode => $mode_gp,
		registers => [
			{ name => "x0", encoding =>  0 },
			{ name => "x1",   encoding =>  1 },
			{ name => "x2",   encoding =>  2 },
			{ name => "x3",   encoding =>  3 },
			{ name => "x4",   encoding =>  4 },
			{ name => "x5",   encoding =>  5 },
			{ name => "x6",   encoding =>  6 },
			{ name => "x7",   encoding =>  7 },
			{ name => "x8",   encoding =>  8 },
			{ name => "x9",   encoding =>  9 },
			{ name => "x10",   encoding => 10 },
			{ name => "x11",   encoding => 11 },
			{ name => "x12",   encoding => 12 },
			{ name => "x13",   encoding => 13 },
			{ name => "x14",   encoding => 14 },
			{ name => "x15",   encoding => 15 },
			{ name => "x16",   encoding => 16 },
			{ name => "x17",   encoding => 17 },
			{ name => "x18",   encoding => 18 },
			{ name => "x19",   encoding => 19 },
			{ name => "x20",   encoding => 20 },
			{ name => "x21",   encoding => 21 },
			{ name => "x22",   encoding => 22 },
			{ name => "x23",   encoding => 23 },
			{ name => "x24",   encoding => 24 },
			{ name => "x25",   encoding => 25 },
			{ name => "x26",  encoding => 26 },
			{ name => "x27",  encoding => 27 },
			{ name => "x28",   encoding => 28 },
			{ name => "x29",   encoding => 29 },
			{ name => "x30",   encoding => 30 },
			{ name => "x31",   encoding => 31 },
		]
	},
     fp => {
		mode => $mode_fp,
		registers => [
			{ name => "f0",  encoding =>  0, dwarf => 32 },
			{ name => "f1",  encoding =>  1, dwarf => 33 },
			{ name => "f2",  encoding =>  2, dwarf => 34 },
			{ name => "f3",  encoding =>  3, dwarf => 35 },
			{ name => "f4",  encoding =>  4, dwarf => 36 },
			{ name => "f5",  encoding =>  5, dwarf => 37 },
			{ name => "f6",  encoding =>  6, dwarf => 38 },
			{ name => "f7",  encoding =>  7, dwarf => 39 },
			{ name => "f8",  encoding =>  8, dwarf => 40 },
			{ name => "f9",  encoding =>  9, dwarf => 41 },
			{ name => "f10", encoding => 10, dwarf => 42 },
			{ name => "f11", encoding => 11, dwarf => 43 },
			{ name => "f12", encoding => 12, dwarf => 44 },
			{ name => "f13", encoding => 13, dwarf => 45 },
			{ name => "f14", encoding => 14, dwarf => 46 },
			{ name => "f15", encoding => 15, dwarf => 47 },
			{ name => "f16", encoding => 16, dwarf => 48 },
			{ name => "f17", encoding => 17, dwarf => 49 },
			{ name => "f18", encoding => 18, dwarf => 50 },
			{ name => "f19", encoding => 19, dwarf => 51 },
			{ name => "f20", encoding => 20, dwarf => 52 },
			{ name => "f21", encoding => 21, dwarf => 53 },
			{ name => "f22", encoding => 22, dwarf => 54 },
			{ name => "f23", encoding => 23, dwarf => 55 },
			{ name => "f24", encoding => 24, dwarf => 56 },
			{ name => "f25", encoding => 25, dwarf => 57 },
			{ name => "f26", encoding => 26, dwarf => 58 },
			{ name => "f27", encoding => 27, dwarf => 59 },
			{ name => "f28", encoding => 28, dwarf => 60 },
			{ name => "f29", encoding => 29, dwarf => 61 },
			{ name => "f30", encoding => 30, dwarf => 62 },
			{ name => "f31", encoding => 31, dwarf => 63 },
		]
	}  
);

%init_attr = (
	riscv_attr_t => "",
	riscv_cond_attr_t =>
		"attr->cond = cond;",
    riscv_condf_attr_t =>
		"attr->cond = cond;",
	riscv_immediate_attr_t =>
		"attr->ent = ent;\n".
		"\tattr->val = val;",
	riscv_switch_attr_t =>
		"be_switch_attr_init(res, &attr->swtch, table, table_entity);",
	riscv_farith_attr_t =>
		"attr->mode = op_mode;\n", 
);

my $binOp = {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-gp", "cls-gp" ],
	out_reqs  => [ "cls-gp" ],
	ins       => [ "left", "right" ],
	outs      => [ "res" ],
	emit      => "{name}\t%D0, %S0, %S1",
};

my $callOp = {
  state     => "exc_pinned",
  in_reqs   => "...",
  out_reqs  => "...",
  ins       => [ "mem", "stack", "first_argument" ],
  outs      => [ "M",   "stack", "first_result" ],
};

my $immediateOp = {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-gp" ],
	out_reqs  => [ "cls-gp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "{name}\t%D0, %S0, %I",
};

my $loadOp = {
	state     => "exc_pinned",
	in_reqs   => [ "mem", "cls-gp" ],
	out_reqs  => [ "mem", "cls-gp" ],
	ins       => [ "mem", "base" ],
	outs      => [ "M", "res" ],
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "{name}\t%D1, %A",
};

my $storeOp = {
	state     => "exc_pinned",
	in_reqs   => [ "mem", "cls-gp", "cls-gp" ],
	out_reqs  => [ "mem" ],
	ins       => [ "mem", "base", "value" ],
	outs      => [ "M" ],
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "{name}\t%S2, %A",
};

my $binopf = {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-fp", "cls-fp" ],
	out_reqs  => [ "cls-fp" ],
	ins       => [ "left", "right" ],
	outs      => [ "res" ],
	emit      => '{name}.s\t%D0, %S0, %S1',
};  

%nodes = (

add => { template => $binOp },

addi => { template => $immediateOp },

and => { template => $binOp },

andi => { template => $immediateOp },

fadd => { template => $binopf }, 
fsub => { template => $binopf }, 
fmul => { template => $binopf },
fdiv => { template => $binopf },  

sltu_t => {
	ins       => [ "left", "right" ],
	attr_type => "",
	dump_func => "NULL",
}, 
 

bcc => {
	state     => "pinned",
	op_flags  => [ "cfopcode", "forking" ],
	in_reqs   => [ "cls-gp", "cls-gp" ],
	ins       => [ "left", "right" ],
	out_reqs  => [ "exec", "exec" ],
	outs      => [ "false", "true" ],
	attr_type => "riscv_cond_attr_t",
	attr      => "riscv_cond_t const cond",
},

cmpf => {
	state     => "pinned",
	in_reqs   => [ "cls-fp", "cls-fp" ],
	ins       => [ "left", "right" ],
	out_reqs  => [ "cls-gp" ],
	outs      => [ "res" ],
    #out_reqs  => ["exec", "exec" ],
	#outs      => ["false", "true" ],
	attr_type => "riscv_condf_attr_t",
	attr      => "riscv_condf_t const cond",
},

div => { template => $binOp, },

divu => { template => $binOp, },

ijmp => {
	state    => "pinned",
	op_flags => [ "cfopcode", "unknown_jump" ],
	in_reqs  => [ "cls-gp" ],
	out_reqs => [ "exec" ],
	emit     => "jr\t%S0",
},

j => {
	state     => "pinned",
	irn_flags => [ "simple_jump", "fallthrough" ],
	op_flags  => [ "cfopcode" ],
	out_reqs  => [ "exec" ],
},

jal => {
	template  => $callOp,
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "jal\t%J",
},

jalr => {
	template => $callOp,
	emit     => "jalr\tx1, %S2, 0",
},

lb => { template => $loadOp },

lbu => { template => $loadOp },

lh => { template => $loadOp },

lhu => { template => $loadOp },

lui => {
	template  => $immediateOp,
	in_reqs   => [],
	ins       => [],
	emit      => "lui\t%D0, %H",
},

la => {
	template  => $immediateOp,
	in_reqs   => [],
	ins       => [],
	emit      => "la\t%D0, %J",
},

lw => { template => $loadOp },

mul => { template => $binOp, },

mulh => { template => $binOp, },

mulhu => { template => $binOp, },

or => { template => $binOp },

ori => { template => $immediateOp },

rem => { template => $binOp, },

remu => { template => $binOp, },

ret => {
	state    => "pinned",
	op_flags => [ "cfopcode" ],
	in_reqs  => "...",
	out_reqs => [ "exec" ],
	ins      => [ "mem", "stack", "addr", "first_result" ],
	emit     => "ret",
},

sb => { template => $storeOp },

sh => { template => $storeOp },

sll => { template => $binOp },

slli => { template => $immediateOp },

slt => { template => $binOp },

sltiu => { template => $immediateOp },

sltu => { template => $binOp },

sra => { template => $binOp },

srai => { template => $immediateOp },

srl => { template => $binOp },

srli => { template => $immediateOp },

sub => { template => $binOp },

sw => { template => $storeOp },

switch => {
	op_flags  => [ "cfopcode", "forking" ],
	state     => "pinned",
	in_reqs   => [ "cls-gp" ],
	out_reqs  => "...",
	attr_type => "riscv_switch_attr_t",
	attr      => "const ir_switch_table *table, ir_entity *table_entity",
},

xor => { template => $binOp },

xori => { template => $immediateOp },

FrameAddr => {
	op_flags  => [ "constlike" ],
	irn_flags => [ "rematerializable" ],
	attr      => "ir_entity *ent, int32_t val",
	in_reqs   => [ "cls-gp" ],
	out_reqs  => [ "cls-gp" ],
	ins       => [ "base" ],
	attr_type => "riscv_immediate_attr_t",
},

flw => {
	state     => "exc_pinned",
	in_reqs   => [ "mem", "cls-gp" ],
	out_reqs  => [ "mem", "cls-fp" ],
	ins       => [ "mem", "base" ],
	outs      => [ "M", "res" ],
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "flw\t%D1, %A",
},
fsw => {
	state     => "exc_pinned",
	in_reqs   => [ "mem", "cls-gp", "cls-fp" ],
	out_reqs  => [ "mem" ],
	ins       => [ "mem", "base", "value" ],
	outs      => [ "M" ],
	attr_type => "riscv_immediate_attr_t",
	attr      => "ir_entity *const ent, int32_t const val",
	emit      => "fsw\t%S2, %A",
},
fmvxs => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-fp" ],
	out_reqs  => [ "cls-gp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],	
	emit      => "fmv.x.s\t%D0, %S0",
},
fmvsx => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-gp" ],
	out_reqs  => [ "cls-fp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],	
	emit      => "fmv.s.x\t%D0, %S0",
},
fcvtws => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-fp" ],
	out_reqs  => [ "cls-gp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],	
	emit      => "fcvt.w.s\t%D0, %S0",
},
fcvtsw => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-gp" ],
	out_reqs  => [ "cls-fp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],	
	emit      => "fcvt.s.w\t%D0, %S0",
},
fneg => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "cls-fp" ],
	out_reqs  => [ "cls-fp" ],
	ins       => [ "left" ],
	outs      => [ "res" ],	
	emit      => "fneg.s\t%D0, %S0",
},
 
);
