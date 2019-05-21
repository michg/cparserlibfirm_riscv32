# This file is part of libFirm.
# Copyright (C) 2018 Christoph Mallon.

$arch = "riscv";

my $mode_gp = "mode_Iu";

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
);

%init_attr = (
	riscv_attr_t => "",
	riscv_cond_attr_t =>
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

%nodes = (

add => { template => $binOp },

addi => { template => $immediateOp },

and => { template => $binOp },

andi => { template => $immediateOp },


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

);
