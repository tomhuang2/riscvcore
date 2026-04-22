module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "20" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
		.PLLRST_ENA("DISABLED"),
		.INTFB_WAKE("DISABLED"),
		.STDBY_ENABLE("DISABLED"),
		.DPHASE_SOURCE("DISABLED"),
		.OUTDIVIDER_MUXA("DIVA"),
		.OUTDIVIDER_MUXB("DIVB"),
		.OUTDIVIDER_MUXC("DIVC"),
		.OUTDIVIDER_MUXD("DIVD"),
		.CLKI_DIV(5),
		.CLKOP_ENABLE("ENABLED"),
		.CLKOP_DIV(30),
		.CLKOP_CPHASE(15),
		.CLKOP_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(4)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
		.CLKFB(clkfb),
		.CLKINTFB(clkfb),
		.PHASESEL0(1'b0),
		.PHASESEL1(1'b0),
		.PHASEDIR(1'b1),
		.PHASESTEP(1'b1),
		.PHASELOADREG(1'b1),
		.PLLWAKESYNC(1'b0),
		.ENCLKOP(1'b0),
		.LOCK(locked)
	);
endmodule
module gp1 (
	a,
	b,
	g,
	p
);
	input wire a;
	input wire b;
	output wire g;
	output wire p;
	assign g = a & b;
	assign p = a | b;
endmodule
module gp4 (
	gin,
	pin,
	cin,
	gout,
	pout,
	cout
);
	input wire [3:0] gin;
	input wire [3:0] pin;
	input wire cin;
	output wire gout;
	output wire pout;
	output wire [2:0] cout;
	assign pout = &pin;
	assign gout = ((gin[3] | (pin[3] & gin[2])) | ((pin[3] & pin[2]) & gin[1])) | (&pin[3:1] & gin[0]);
	assign cout[0] = gin[0] | (pin[0] & cin);
	assign cout[1] = (gin[1] | (pin[1] & gin[0])) | ((pin[1] & pin[0]) & cin);
	assign cout[2] = (gin[2] | (pin[2] & gin[1])) | (((pin[2] & pin[1]) & gin[0]) | (&pin[2:0] & cin));
endmodule
module gp8 (
	gin,
	pin,
	cin,
	gout,
	pout,
	cout
);
	input wire [7:0] gin;
	input wire [7:0] pin;
	input wire cin;
	output wire gout;
	output wire pout;
	output wire [6:0] cout;
	assign pout = &pin;
	assign gout = ((((((gin[7] | (pin[7] & gin[6])) | (&pin[7:6] & gin[5])) | (&pin[7:5] & gin[4])) | (&pin[7:4] & gin[3])) | (&pin[7:3] & gin[2])) | (&pin[7:2] & gin[1])) | (&pin[7:1] & gin[0]);
	assign cout[0] = gin[0] | (pin[0] & cin);
	assign cout[1] = (gin[1] | (pin[1] & gin[0])) | ((pin[1] & pin[0]) & cin);
	assign cout[2] = (gin[2] | (pin[2] & gin[1])) | (((pin[2] & pin[1]) & gin[0]) | (&pin[2:0] & cin));
	assign cout[3] = (((gin[3] | (pin[3] & gin[2])) | ((pin[3] & pin[2]) & gin[1])) | (&pin[3:1] & gin[0])) | (&pin[3:0] & cin);
	assign cout[4] = ((((gin[4] | (pin[4] & gin[3])) | (&pin[4:3] & gin[2])) | (&pin[4:2] & gin[1])) | (&pin[4:1] & gin[0])) | (&pin[4:0] & cin);
	assign cout[5] = (((((gin[5] | (pin[5] & gin[4])) | (&pin[5:4] & gin[3])) | (&pin[5:3] & gin[2])) | (&pin[5:2] & gin[1])) | (&pin[5:1] & gin[0])) | (&pin[5:0] & cin);
	assign cout[6] = ((((((gin[6] | (pin[6] & gin[5])) | (&pin[6:5] & gin[4])) | (&pin[6:4] & gin[3])) | (&pin[6:3] & gin[2])) | (&pin[6:2] & gin[1])) | (&pin[6:1] & gin[0])) | (&pin[6:0] & cin);
endmodule
module CarryLookaheadAdder (
	a,
	b,
	cin,
	sum
);
	input wire [31:0] a;
	input wire [31:0] b;
	input wire cin;
	output wire [31:0] sum;
	wire [31:0] g_gp1;
	wire [31:0] p_gp1;
	wire [31:0] carries;
	wire [7:0] g_gp4;
	wire [7:0] p_gp4;
	wire g_gp8;
	wire p_gp8;
	wire [6:0] carries_gp8;
	wire [7:0] cin4;
	assign cin4[0] = cin;
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 1; _gv_i_1 < 8; _gv_i_1 = _gv_i_1 + 1) begin : genblk1
			localparam i = _gv_i_1;
			assign cin4[i] = carries_gp8[i - 1];
		end
		for (_gv_i_1 = 0; _gv_i_1 < 32; _gv_i_1 = _gv_i_1 + 1) begin : genblk2
			localparam i = _gv_i_1;
			gp1 gp_one(
				.a(a[i]),
				.b(b[i]),
				.g(g_gp1[i]),
				.p(p_gp1[i])
			);
		end
		for (_gv_i_1 = 0; _gv_i_1 < 8; _gv_i_1 = _gv_i_1 + 1) begin : genblk3
			localparam i = _gv_i_1;
			gp4 gp_four(
				.gin(g_gp1[(4 * i) + 3:4 * i]),
				.pin(p_gp1[(4 * i) + 3:4 * i]),
				.cin(cin4[i]),
				.gout(g_gp4[i]),
				.pout(p_gp4[i]),
				.cout(carries[(4 * i) + 3:(4 * i) + 1])
			);
		end
	endgenerate
	gp8 gp_eight(
		.gin(g_gp4),
		.pin(p_gp4),
		.cin(cin),
		.gout(g_gp8),
		.pout(p_gp8),
		.cout(carries_gp8)
	);
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 8; _gv_i_1 = _gv_i_1 + 1) begin : genblk4
			localparam i = _gv_i_1;
			assign carries[4 * i] = cin4[i];
		end
	endgenerate
	assign sum = (a ^ b) ^ carries;
endmodule
module DividerUnsignedPipelined (
	clk,
	rst,
	stall,
	i_dividend,
	i_divisor,
	o_remainder,
	o_quotient
);
	input wire clk;
	input wire rst;
	input wire stall;
	input wire [31:0] i_dividend;
	input wire [31:0] i_divisor;
	output wire [31:0] o_remainder;
	output wire [31:0] o_quotient;
	wire [31:0] quotient_bus [0:32];
	wire [31:0] dividend_bus [0:32];
	wire [31:0] remainder_bus [0:32];
	reg [31:0] quotient_reg [0:6];
	reg [31:0] dividend_reg [0:6];
	reg [31:0] remainder_reg [0:6];
	reg [31:0] divisor_reg [0:6];
	assign remainder_bus[0] = 32'd0;
	assign quotient_bus[0] = 32'd0;
	assign dividend_bus[0] = i_dividend;
	genvar _gv_i_2;
	generate
		for (_gv_i_2 = 0; _gv_i_2 < 32; _gv_i_2 = _gv_i_2 + 1) begin : genblk1
			localparam i = _gv_i_2;
			divu_1iter d(
				.i_dividend((((i & 3) == 0) && (i != 0) ? dividend_reg[(i / 4) - 1] : dividend_bus[i])),
				.i_divisor((i >= 4 ? divisor_reg[(i / 4) - 1] : i_divisor)),
				.i_remainder((((i & 3) == 0) && (i != 0) ? remainder_reg[(i / 4) - 1] : remainder_bus[i])),
				.i_quotient((((i & 3) == 0) && (i != 0) ? quotient_reg[(i / 4) - 1] : quotient_bus[i])),
				.o_dividend(dividend_bus[i + 1]),
				.o_remainder(remainder_bus[i + 1]),
				.o_quotient(quotient_bus[i + 1])
			);
		end
	endgenerate
	always @(posedge clk)
		if (rst) begin : sv2v_autoblock_1
			reg signed [31:0] r;
			for (r = 0; r < 7; r = r + 1)
				begin
					quotient_reg[r] <= 0;
					dividend_reg[r] <= 0;
					divisor_reg[r] <= 0;
					remainder_reg[r] <= 0;
				end
		end
		else begin : sv2v_autoblock_2
			reg signed [31:0] r;
			for (r = 0; r < 7; r = r + 1)
				begin
					dividend_reg[r] <= dividend_bus[(r + 1) * 4];
					remainder_reg[r] <= remainder_bus[(r + 1) * 4];
					quotient_reg[r] <= quotient_bus[(r + 1) * 4];
					divisor_reg[r] <= (r == 0 ? i_divisor : divisor_reg[r - 1]);
				end
		end
	assign o_remainder = remainder_bus[32];
	assign o_quotient = quotient_bus[32];
endmodule
module divu_1iter (
	i_dividend,
	i_divisor,
	i_remainder,
	i_quotient,
	o_dividend,
	o_remainder,
	o_quotient
);
	input wire [31:0] i_dividend;
	input wire [31:0] i_divisor;
	input wire [31:0] i_remainder;
	input wire [31:0] i_quotient;
	output wire [31:0] o_dividend;
	output wire [31:0] o_remainder;
	output wire [31:0] o_quotient;
	wire [31:0] remainder;
	assign remainder = {i_remainder[30:0], i_dividend[31]};
	wire [32:0] status = {1'b0, remainder} - {1'b0, i_divisor};
	assign o_quotient = (status[32] ? i_quotient << 1 : (i_quotient << 1) | 32'b00000000000000000000000000000001);
	assign o_remainder = (status[32] ? remainder : status[31:0]);
	assign o_dividend = i_dividend << 1;
endmodule
module Disasm (
	insn,
	disasm
);
	parameter signed [7:0] PREFIX = "D";
	input wire [31:0] insn;
	output wire [255:0] disasm;
endmodule
module RegFile (
	rd,
	rd_data,
	rs1,
	rs1_data,
	rs2,
	rs2_data,
	clk,
	we,
	rst
);
	input wire [4:0] rd;
	input wire [31:0] rd_data;
	input wire [4:0] rs1;
	output wire [31:0] rs1_data;
	input wire [4:0] rs2;
	output wire [31:0] rs2_data;
	input wire clk;
	input wire we;
	input wire rst;
	localparam signed [31:0] NumRegs = 32;
	reg [31:0] regs [0:31];
	always @(posedge clk)
		if (rst) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				regs[i] <= 32'b00000000000000000000000000000000;
		end
		else if (we) begin
			if (rd != 0)
				regs[rd] <= rd_data;
		end
	assign rs1_data = regs[rs1];
	assign rs2_data = regs[rs2];
endmodule
module DatapathPipelined (
	clk,
	rst,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	halt,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output reg [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output reg [31:0] store_data_to_dmem;
	output reg [3:0] store_we_to_dmem;
	output wire halt;
	output wire [31:0] trace_completed_pc;
	output wire [31:0] trace_completed_insn;
	output wire [31:0] trace_completed_cycle_status;
	localparam [6:0] OpLoad = 7'b0000011;
	localparam [6:0] OpStore = 7'b0100011;
	localparam [6:0] OpBranch = 7'b1100011;
	localparam [6:0] OpJalr = 7'b1100111;
	localparam [6:0] OpMiscMem = 7'b0001111;
	localparam [6:0] OpJal = 7'b1101111;
	localparam [6:0] OpRegImm = 7'b0010011;
	localparam [6:0] OpRegReg = 7'b0110011;
	localparam [6:0] OpEnviron = 7'b1110011;
	localparam [6:0] OpAuipc = 7'b0010111;
	localparam [6:0] OpLui = 7'b0110111;
	reg [31:0] cycles_current;
	always @(posedge clk)
		if (rst)
			cycles_current <= 0;
		else
			cycles_current <= cycles_current + 1;
	reg [31:0] f_pc_current;
	wire [31:0] f_insn;
	reg [31:0] f_cycle_status;
	reg branch_taken;
	reg [31:0] branch_target;
	reg div_stall;
	reg [302:0] execute_state;
	wire [6:0] insn_opcode;
	wire [4:0] insn_rs1;
	wire [4:0] insn_rs2;
	wire insn_uses_rs2 = ((insn_opcode == OpRegReg) || (insn_opcode == OpStore)) || (insn_opcode == OpBranch);
	wire load_use_stall = ((execute_state[245:239] == OpLoad) && (execute_state[46-:5] != 0)) && ((insn_rs1 == execute_state[46-:5]) || (((insn_opcode != OpStore) && insn_uses_rs2) && (insn_rs2 == execute_state[46-:5])));
	always @(posedge clk)
		if (rst) begin
			f_pc_current <= 32'd0;
			f_cycle_status <= 32'd1;
		end
		else if (load_use_stall || div_stall)
			;
		else begin
			f_cycle_status <= 32'd1;
			f_pc_current <= (branch_taken ? branch_target : f_pc_current + 4);
		end
	assign pc_to_imem = f_pc_current;
	assign f_insn = insn_from_imem;
	wire [255:0] f_disasm;
	Disasm #(.PREFIX("F")) disasm_0fetch(
		.insn(f_insn),
		.disasm(f_disasm)
	);
	reg [95:0] decode_state;
	always @(posedge clk)
		if (rst)
			decode_state <= 96'h000000000000000000000004;
		else if (branch_taken)
			decode_state <= 96'h000000000000000000000008;
		else if (load_use_stall || div_stall)
			;
		else
			decode_state <= {f_pc_current, f_insn, f_cycle_status};
	wire [255:0] d_disasm;
	Disasm #(.PREFIX("D")) disasm_1decode(
		.insn(decode_state[63-:32]),
		.disasm(d_disasm)
	);
	wire [6:0] insn_funct7;
	wire [2:0] insn_funct3;
	wire [4:0] insn_rd;
	assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = decode_state[63-:32];
	wire [11:0] imm_i;
	assign imm_i = decode_state[63:52];
	wire [4:0] imm_shamt = decode_state[56:52];
	wire [11:0] imm_s;
	assign imm_s[11:5] = insn_funct7;
	assign imm_s[4:0] = insn_rd;
	wire [12:0] imm_b;
	assign {imm_b[12], imm_b[10:5]} = insn_funct7;
	assign {imm_b[4:1], imm_b[11]} = insn_rd;
	assign imm_b[0] = 1'b0;
	wire [20:0] imm_j;
	assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {decode_state[63:44], 1'b0};
	wire [31:0] imm_i_sext = {{20 {imm_i[11]}}, imm_i[11:0]};
	wire [31:0] imm_s_sext = {{20 {imm_s[11]}}, imm_s[11:0]};
	wire [31:0] imm_b_sext = {{19 {imm_b[12]}}, imm_b[12:0]};
	wire [31:0] imm_j_sext = {{11 {imm_j[20]}}, imm_j[20:0]};
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	reg [133:0] writeback_state;
	RegFile rf(
		.clk(clk),
		.rst(rst),
		.we(writeback_state[32]),
		.rd(writeback_state[37-:5]),
		.rd_data(writeback_state[69-:32]),
		.rs1(insn_rs1),
		.rs2(insn_rs2),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);
	wire [31:0] rs1_data_wd = ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == insn_rs1) ? writeback_state[69-:32] : rs1_data);
	wire [31:0] rs2_data_wd = ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == insn_rs2) ? writeback_state[69-:32] : rs2_data);
	wire d_insn_div = ((insn_opcode == OpRegReg) && (decode_state[63:57] == 7'd1)) && (decode_state[46:44] == 3'b100);
	wire d_insn_divu = ((insn_opcode == OpRegReg) && (decode_state[63:57] == 7'd1)) && (decode_state[46:44] == 3'b101);
	wire d_insn_rem = ((insn_opcode == OpRegReg) && (decode_state[63:57] == 7'd1)) && (decode_state[46:44] == 3'b110);
	wire d_insn_remu = ((insn_opcode == OpRegReg) && (decode_state[63:57] == 7'd1)) && (decode_state[46:44] == 3'b111);
	reg div_in_progress;
	reg [138:0] div_pipe [0:6];
	always @(*) begin
		if (_sv2v_0)
			;
		div_stall = (((d_insn_div || d_insn_divu) || d_insn_rem) || d_insn_remu ? 0 : div_in_progress);
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 6; i = i + 1)
				if (div_pipe[i][138] && ((div_pipe[i][102-:5] == insn_rs1) || (div_pipe[i][102-:5] == insn_rs2)))
					div_stall = div_stall | 1'b1;
		end
		if (div_in_progress && ((execute_state[46-:5] == insn_rs1) || (execute_state[46-:5] == insn_rs2)))
			div_stall = div_stall | 1'b1;
	end
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(posedge clk)
		if (rst)
			execute_state <= 303'h4;
		else if (branch_taken)
			execute_state <= 303'h8;
		else if (load_use_stall)
			execute_state <= 303'h10;
		else if (div_stall)
			execute_state <= 303'h2;
		else
			execute_state <= {sv2v_cast_32(decode_state[95-:32]), sv2v_cast_32(decode_state[63-:32]), rs1_data_wd, rs2_data_wd, imm_i_sext, imm_s_sext, imm_b_sext, imm_j_sext, insn_rd, insn_rs1, insn_rs2, sv2v_cast_32(decode_state[31-:32])};
	wire [255:0] x_disasm;
	Disasm #(.PREFIX("X")) disasm_2execute(
		.insn(execute_state[270-:32]),
		.disasm(x_disasm)
	);
	wire [6:0] x_insn_funct7;
	wire [4:0] x_insn_rs2;
	wire [4:0] x_insn_rs1;
	wire [2:0] x_insn_funct3;
	wire [4:0] x_insn_rd;
	wire [6:0] x_insn_opcode;
	assign {x_insn_funct7, x_insn_rs2, x_insn_rs1, x_insn_funct3, x_insn_rd, x_insn_opcode} = execute_state[270-:32];
	wire x_insn_lui = x_insn_opcode == OpLui;
	wire x_insn_auipc = x_insn_opcode == OpAuipc;
	wire x_insn_jal = x_insn_opcode == OpJal;
	wire x_insn_jalr = x_insn_opcode == OpJalr;
	wire x_insn_beq = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b000);
	wire x_insn_bne = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b001);
	wire x_insn_blt = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b100);
	wire x_insn_bge = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b101);
	wire x_insn_bltu = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b110);
	wire x_insn_bgeu = (x_insn_opcode == OpBranch) && (execute_state[253:251] == 3'b111);
	wire x_insn_lb = (x_insn_opcode == OpLoad) && (execute_state[253:251] == 3'b000);
	wire x_insn_lh = (x_insn_opcode == OpLoad) && (execute_state[253:251] == 3'b001);
	wire x_insn_lw = (x_insn_opcode == OpLoad) && (execute_state[253:251] == 3'b010);
	wire x_insn_lbu = (x_insn_opcode == OpLoad) && (execute_state[253:251] == 3'b100);
	wire x_insn_lhu = (x_insn_opcode == OpLoad) && (execute_state[253:251] == 3'b101);
	wire x_insn_sb = (x_insn_opcode == OpStore) && (execute_state[253:251] == 3'b000);
	wire x_insn_sh = (x_insn_opcode == OpStore) && (execute_state[253:251] == 3'b001);
	wire x_insn_sw = (x_insn_opcode == OpStore) && (execute_state[253:251] == 3'b010);
	wire x_insn_addi = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b000);
	wire x_insn_slti = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b010);
	wire x_insn_sltiu = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b011);
	wire x_insn_xori = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b100);
	wire x_insn_ori = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b110);
	wire x_insn_andi = (x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b111);
	wire x_insn_slli = ((x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b001)) && (execute_state[270:264] == 7'd0);
	wire x_insn_srli = ((x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b101)) && (execute_state[270:264] == 7'd0);
	wire x_insn_srai = ((x_insn_opcode == OpRegImm) && (execute_state[253:251] == 3'b101)) && (execute_state[270:264] == 7'b0100000);
	wire x_insn_add = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b000)) && (execute_state[270:264] == 7'd0);
	wire x_insn_sub = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b000)) && (execute_state[270:264] == 7'b0100000);
	wire x_insn_sll = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b001)) && (execute_state[270:264] == 7'd0);
	wire x_insn_slt = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b010)) && (execute_state[270:264] == 7'd0);
	wire x_insn_sltu = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b011)) && (execute_state[270:264] == 7'd0);
	wire x_insn_xor = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b100)) && (execute_state[270:264] == 7'd0);
	wire x_insn_srl = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b101)) && (execute_state[270:264] == 7'd0);
	wire x_insn_sra = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b101)) && (execute_state[270:264] == 7'b0100000);
	wire x_insn_or = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b110)) && (execute_state[270:264] == 7'd0);
	wire x_insn_and = ((x_insn_opcode == OpRegReg) && (execute_state[253:251] == 3'b111)) && (execute_state[270:264] == 7'd0);
	wire x_insn_mul = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b000);
	wire x_insn_mulh = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b001);
	wire x_insn_mulhsu = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b010);
	wire x_insn_mulhu = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b011);
	wire x_insn_div = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b100);
	wire x_insn_divu = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b101);
	wire x_insn_rem = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b110);
	wire x_insn_remu = ((x_insn_opcode == OpRegReg) && (execute_state[270:264] == 7'd1)) && (execute_state[253:251] == 3'b111);
	wire x_insn_ecall = (x_insn_opcode == OpEnviron) && (execute_state[270:246] == 25'd0);
	wire x_insn_fence = x_insn_opcode == OpMiscMem;
	reg illegal_insn;
	wire [31:0] cla_result;
	reg [31:0] cla_operand_a;
	reg [31:0] cla_operand_b;
	reg cla_carry_in;
	reg [7:0] b;
	reg [15:0] h;
	reg [63:0] prod;
	reg [31:0] div_a;
	reg [31:0] div_b;
	reg [31:0] div_dividend;
	reg [31:0] div_divisor;
	wire [31:0] div_remainder;
	wire [31:0] div_quotient;
	wire [3:0] div_counter;
	reg [31:0] alu_result;
	wire [31:0] x_rs1_data;
	wire [31:0] x_rs2_data;
	reg insn_writes_rd;
	CarryLookaheadAdder cla(
		.a(cla_operand_a),
		.b(cla_operand_b),
		.cin(cla_carry_in),
		.sum(cla_result)
	);
	DividerUnsignedPipelined div(
		.clk(clk),
		.rst(rst),
		.stall(1'b0),
		.i_dividend(div_dividend),
		.i_divisor(div_divisor),
		.o_remainder(div_remainder),
		.o_quotient(div_quotient)
	);
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 7; i = i + 1)
				div_pipe[i] <= 139'h00000000000000000000000000000000002;
		end
		else begin
			begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 6; i > 0; i = i - 1)
					div_pipe[i] <= div_pipe[i - 1];
			end
			div_pipe[0] <= {((x_insn_div || x_insn_divu) || x_insn_rem) || x_insn_remu, x_rs1_data, (x_insn_div || x_insn_rem ? x_rs2_data[31] : 1'b0), (((x_insn_div || x_insn_rem) && (x_rs1_data == 32'h80000000)) && (x_rs2_data == 32'hffffffff) ? 1'b1 : 1'b0), (x_rs2_data == 32'b00000000000000000000000000000000 ? 1'b1 : 1'b0), sv2v_cast_5(execute_state[46-:5]), sv2v_cast_32(execute_state[302-:32]), sv2v_cast_32(execute_state[270-:32]), (x_insn_divu ? 2'd1 : (x_insn_rem ? 2'd2 : (x_insn_remu ? 2'd3 : 2'd0))), sv2v_cast_32(execute_state[31-:32])};
		end
	always @(*) begin
		if (_sv2v_0)
			;
		div_in_progress = ((x_insn_div || x_insn_divu) || x_insn_rem) || x_insn_remu;
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < 6; i = i + 1)
				div_in_progress = div_in_progress | div_pipe[i][138];
		end
	end
	reg [199:0] memory_state;
	assign x_rs1_data = ((memory_state[32] && (memory_state[39-:5] != 0)) && (memory_state[39-:5] == execute_state[41-:5]) ? memory_state[135-:32] : ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == execute_state[41-:5]) ? writeback_state[69-:32] : execute_state[238-:32]));
	assign x_rs2_data = ((memory_state[32] && (memory_state[39-:5] != 0)) && (memory_state[39-:5] == execute_state[36-:5]) ? memory_state[135-:32] : ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == execute_state[36-:5]) ? writeback_state[69-:32] : execute_state[206-:32]));
	always @(*) begin
		if (_sv2v_0)
			;
		illegal_insn = 1'b0;
		insn_writes_rd = 0;
		alu_result = 32'b00000000000000000000000000000000;
		branch_taken = 1'b0;
		branch_target = 32'b00000000000000000000000000000000;
		prod = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		cla_operand_a = x_rs1_data;
		cla_operand_b = execute_state[174-:32];
		cla_carry_in = 1'b0;
		div_dividend = 32'b00000000000000000000000000000000;
		div_divisor = 32'b00000000000000000000000000000000;
		div_a = 32'b00000000000000000000000000000000;
		div_b = 32'b00000000000000000000000000000000;
		case (x_insn_opcode)
			OpLui: begin
				insn_writes_rd = 1'b1;
				alu_result = {execute_state[270:251], 12'b000000000000};
			end
			OpRegImm: begin
				insn_writes_rd = 1'b1;
				if (x_insn_addi)
					alu_result = cla_result;
				else if (x_insn_slti)
					alu_result = {31'b0000000000000000000000000000000, $signed(x_rs1_data) < $signed(execute_state[174-:32])};
				else if (x_insn_sltiu)
					alu_result = {31'b0000000000000000000000000000000, x_rs1_data < execute_state[174-:32]};
				else if (x_insn_xori)
					alu_result = x_rs1_data ^ execute_state[174-:32];
				else if (x_insn_ori)
					alu_result = x_rs1_data | execute_state[174-:32];
				else if (x_insn_andi)
					alu_result = x_rs1_data & execute_state[174-:32];
				else if (x_insn_slli)
					alu_result = x_rs1_data << execute_state[263:259];
				else if (x_insn_srli)
					alu_result = x_rs1_data >> execute_state[263:259];
				else if (x_insn_srai)
					alu_result = $signed(x_rs1_data) >>> execute_state[263:259];
			end
			OpRegReg: begin
				insn_writes_rd = 1'b1;
				if (x_insn_add) begin
					cla_operand_b = x_rs2_data;
					alu_result = cla_result;
				end
				else if (x_insn_sub) begin
					cla_operand_b = ~x_rs2_data;
					cla_carry_in = 1'b1;
					alu_result = cla_result;
				end
				else if (x_insn_sll)
					alu_result = x_rs1_data << x_rs2_data[4:0];
				else if (x_insn_slt)
					alu_result = {31'b0000000000000000000000000000000, $signed(x_rs1_data) < $signed(x_rs2_data)};
				else if (x_insn_sltu)
					alu_result = {31'b0000000000000000000000000000000, x_rs1_data < x_rs2_data};
				else if (x_insn_xor)
					alu_result = x_rs1_data ^ x_rs2_data;
				else if (x_insn_srl)
					alu_result = x_rs1_data >> x_rs2_data[4:0];
				else if (x_insn_sra)
					alu_result = $signed(x_rs1_data) >>> x_rs2_data[4:0];
				else if (x_insn_or)
					alu_result = x_rs1_data | x_rs2_data;
				else if (x_insn_and)
					alu_result = x_rs1_data & x_rs2_data;
				else if (x_insn_mul) begin
					prod = x_rs1_data * x_rs2_data;
					alu_result = prod[31:0];
				end
				else if (x_insn_mulh) begin
					prod = $signed(x_rs1_data) * $signed(x_rs2_data);
					alu_result = prod[63:32];
				end
				else if (x_insn_mulhsu) begin
					prod = $signed({{32 {x_rs1_data[31]}}, x_rs1_data}) * $signed({32'b00000000000000000000000000000000, x_rs2_data});
					alu_result = prod[63:32];
				end
				else if (x_insn_mulhu) begin
					prod = $unsigned(x_rs1_data) * $unsigned(x_rs2_data);
					alu_result = prod[63:32];
				end
				else if (x_insn_div) begin
					if (x_rs2_data == 32'b00000000000000000000000000000000)
						;
					else if ((x_rs1_data == 32'h80000000) && (x_rs2_data == 32'hffffffff))
						;
					else begin
						div_a = (x_rs1_data[31] ? ~x_rs1_data + 1 : x_rs1_data);
						div_b = (x_rs2_data[31] ? ~x_rs2_data + 1 : x_rs2_data);
						div_dividend = div_a;
						div_divisor = div_b;
					end
				end
				else if (x_insn_divu) begin
					div_dividend = x_rs1_data;
					div_divisor = $unsigned(x_rs2_data);
				end
				else if (x_insn_rem) begin
					if (x_rs2_data == 32'b00000000000000000000000000000000)
						;
					else if ((x_rs1_data == 32'h80000000) && (x_rs2_data == 32'hffffffff))
						;
					else begin
						div_a = (x_rs1_data[31] ? ~x_rs1_data + 1 : x_rs1_data);
						div_b = (x_rs2_data[31] ? ~x_rs2_data + 1 : x_rs2_data);
						div_dividend = div_a;
						div_divisor = div_b;
					end
				end
				else if (x_insn_remu) begin
					div_dividend = x_rs1_data;
					div_divisor = $unsigned(x_rs2_data);
				end
			end
			OpBranch:
				if (x_insn_beq) begin
					if (x_rs1_data == x_rs2_data) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
				else if (x_insn_bne) begin
					if (x_rs1_data != x_rs2_data) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
				else if (x_insn_blt) begin
					if ($signed(x_rs1_data) < $signed(x_rs2_data)) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
				else if (x_insn_bge) begin
					if ($signed(x_rs1_data) >= $signed(x_rs2_data)) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
				else if (x_insn_bltu) begin
					if (x_rs1_data < x_rs2_data) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
				else if (x_insn_bgeu) begin
					if (x_rs1_data >= x_rs2_data) begin
						branch_taken = 1'b1;
						branch_target = execute_state[302-:32] + execute_state[110-:32];
					end
				end
			OpEnviron:
				;
			OpAuipc: begin
				insn_writes_rd = 1'b1;
				alu_result = execute_state[302-:32] + {execute_state[270:251], 12'b000000000000};
			end
			OpLoad: begin
				insn_writes_rd = 1'b1;
				cla_operand_a = x_rs1_data;
				cla_operand_b = execute_state[174-:32];
				alu_result = cla_result;
			end
			OpStore: begin
				cla_operand_a = x_rs1_data;
				cla_operand_b = execute_state[142-:32];
				alu_result = cla_result;
			end
			OpJal: begin
				insn_writes_rd = 1;
				alu_result = execute_state[302-:32] + 4;
				branch_taken = 1'b1;
				branch_target = execute_state[302-:32] + execute_state[78-:32];
			end
			OpJalr: begin
				insn_writes_rd = 1;
				alu_result = execute_state[302-:32] + 4;
				branch_taken = 1'b1;
				branch_target = (x_rs1_data + execute_state[174-:32]) & {{31 {1'b1}}, 1'b0};
			end
			default: illegal_insn = 1'b1;
		endcase
		if (div_pipe[6][138])
			case (div_pipe[6][33-:2])
				2'd0:
					if (div_pipe[6][103])
						alu_result = 32'hffffffff;
					else if (div_pipe[6][104])
						alu_result = 32'h80000000;
					else
						alu_result = (div_pipe[6][105] ^ div_pipe[6][137] ? ~div_quotient + 1 : div_quotient);
				2'd1:
					if (div_pipe[6][103])
						alu_result = 32'hffffffff;
					else
						alu_result = div_quotient;
				2'd2:
					if (div_pipe[6][103])
						alu_result = div_pipe[6][137-:32];
					else if (div_pipe[6][104])
						alu_result = 32'h00000000;
					else
						alu_result = (div_pipe[6][137] ? ~div_remainder + 1 : div_remainder);
				2'd3:
					if (div_pipe[6][103])
						alu_result = div_pipe[6][137-:32];
					else
						alu_result = div_remainder;
			endcase
	end
	always @(posedge clk)
		if (rst)
			memory_state <= 200'h00000000000000000000000000000000000000000000000004;
		else if (div_pipe[6][138])
			memory_state <= {sv2v_cast_32(div_pipe[6][97-:32]), sv2v_cast_32(div_pipe[6][65-:32]), alu_result, 64'h0000000000000000, sv2v_cast_5(div_pipe[6][102-:5]), 3'h1, sv2v_cast_32(div_pipe[6][31-:32])};
		else if (div_in_progress)
			memory_state <= 200'h00000000000000000000000000000000000000000000000002;
		else
			memory_state <= {sv2v_cast_32(execute_state[302-:32]), sv2v_cast_32(execute_state[270-:32]), alu_result, x_rs2_data, sv2v_cast_32({alu_result[31:2], 2'b00}), sv2v_cast_5(execute_state[46-:5]), alu_result[1:0], insn_writes_rd, sv2v_cast_32(execute_state[31-:32])};
	wire [255:0] m_disasm;
	Disasm #(.PREFIX("M")) disasm_3memory(
		.insn(memory_state[167-:32]),
		.disasm(m_disasm)
	);
	wire [6:0] m_insn_funct7;
	wire [4:0] m_insn_rs2;
	wire [4:0] m_insn_rs1;
	wire [2:0] m_insn_funct3;
	wire [4:0] m_insn_rd;
	wire [6:0] m_insn_opcode;
	assign {m_insn_funct7, m_insn_rs2, m_insn_rs1, m_insn_funct3, m_insn_rd, m_insn_opcode} = memory_state[167-:32];
	wire m_insn_lb = (m_insn_opcode == OpLoad) && (memory_state[150:148] == 3'b000);
	wire m_insn_lh = (m_insn_opcode == OpLoad) && (memory_state[150:148] == 3'b001);
	wire m_insn_lw = (m_insn_opcode == OpLoad) && (memory_state[150:148] == 3'b010);
	wire m_insn_lbu = (m_insn_opcode == OpLoad) && (memory_state[150:148] == 3'b100);
	wire m_insn_lhu = (m_insn_opcode == OpLoad) && (memory_state[150:148] == 3'b101);
	wire m_insn_sb = (m_insn_opcode == OpStore) && (memory_state[150:148] == 3'b000);
	wire m_insn_sh = (m_insn_opcode == OpStore) && (memory_state[150:148] == 3'b001);
	wire m_insn_sw = (m_insn_opcode == OpStore) && (memory_state[150:148] == 3'b010);
	wire is_writeback_load = writeback_state[76:70] == OpLoad;
	wire [31:0] m_store_data = ((is_writeback_load && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == m_insn_rs2) ? writeback_state[69-:32] : memory_state[103-:32]);
	reg [31:0] m_load_data;
	always @(*) begin
		if (_sv2v_0)
			;
		addr_to_dmem = memory_state[71-:32];
		b = 8'b00000000;
		h = 16'b0000000000000000;
		store_data_to_dmem = 32'b00000000000000000000000000000000;
		store_we_to_dmem = 4'b0000;
		m_load_data = 32'b00000000000000000000000000000000;
		case (m_insn_opcode)
			OpLoad:
				if (m_insn_lb) begin
					case (memory_state[34:33])
						2'b00: b = load_data_from_dmem[7:0];
						2'b01: b = load_data_from_dmem[15:8];
						2'b10: b = load_data_from_dmem[23:16];
						2'b11: b = load_data_from_dmem[31:24];
					endcase
					m_load_data = {{24 {b[7]}}, b};
				end
				else if (m_insn_lbu) begin
					case (memory_state[34:33])
						2'b00: b = load_data_from_dmem[7:0];
						2'b01: b = load_data_from_dmem[15:8];
						2'b10: b = load_data_from_dmem[23:16];
						2'b11: b = load_data_from_dmem[31:24];
					endcase
					m_load_data = {{24 {1'b0}}, b};
				end
				else if (m_insn_lh) begin
					case (memory_state[34])
						1'b0: h = load_data_from_dmem[15:0];
						1'b1: h = load_data_from_dmem[31:16];
					endcase
					m_load_data = {{16 {h[15]}}, h};
				end
				else if (m_insn_lhu) begin
					case (memory_state[34])
						1'b0: h = load_data_from_dmem[15:0];
						1'b1: h = load_data_from_dmem[31:16];
					endcase
					m_load_data = {{16 {1'b0}}, h};
				end
				else if (m_insn_lw)
					m_load_data = load_data_from_dmem;
			OpStore:
				if (m_insn_sb)
					case (memory_state[34:33])
						2'b00: begin
							store_data_to_dmem[7:0] = m_store_data[7:0];
							store_we_to_dmem = 4'b0001;
						end
						2'b01: begin
							store_data_to_dmem[15:8] = m_store_data[7:0];
							store_we_to_dmem = 4'b0010;
						end
						2'b10: begin
							store_data_to_dmem[23:16] = m_store_data[7:0];
							store_we_to_dmem = 4'b0100;
						end
						2'b11: begin
							store_data_to_dmem[31:24] = m_store_data[7:0];
							store_we_to_dmem = 4'b1000;
						end
					endcase
				else if (m_insn_sh)
					case (memory_state[34])
						1'b0: begin
							store_data_to_dmem[15:0] = m_store_data[15:0];
							store_we_to_dmem = 4'b0011;
						end
						1'b1: begin
							store_data_to_dmem[31:16] = m_store_data[15:0];
							store_we_to_dmem = 4'b1100;
						end
					endcase
				else if (m_insn_sw) begin
					store_data_to_dmem[31:0] = m_store_data[31:0];
					store_we_to_dmem = 4'b1111;
				end
			default:
				;
		endcase
	end
	always @(posedge clk)
		if (rst)
			writeback_state <= 134'h0000000000000000000000000000000004;
		else
			writeback_state <= {sv2v_cast_32(memory_state[199-:32]), sv2v_cast_32(memory_state[167-:32]), sv2v_cast_32((memory_state[142:136] == OpLoad ? m_load_data : memory_state[135-:32])), sv2v_cast_5(memory_state[39-:5]), memory_state[32], sv2v_cast_32(memory_state[31-:32])};
	wire [255:0] w_disasm;
	Disasm #(.PREFIX("W")) disasm_4writeback(
		.insn(writeback_state[101-:32]),
		.disasm(w_disasm)
	);
	assign halt = ((writeback_state[76:70] == OpEnviron) && (writeback_state[101:77] == 25'd0)) && (writeback_state[31-:32] == 32'd1);
	assign trace_completed_pc = (writeback_state[31-:32] == 32'd1 ? writeback_state[133-:32] : 32'b00000000000000000000000000000000);
	assign trace_completed_insn = (writeback_state[31-:32] == 32'd1 ? writeback_state[101-:32] : 32'b00000000000000000000000000000000);
	assign trace_completed_cycle_status = writeback_state[31-:32];
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clk,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem
);
	reg _sv2v_0;
	parameter signed [31:0] NUM_WORDS = 512;
	input wire rst;
	input wire clk;
	input wire [31:0] pc_to_imem;
	output reg [31:0] insn_from_imem;
	input wire [31:0] addr_to_dmem;
	output reg [31:0] load_data_from_dmem;
	input wire [31:0] store_data_to_dmem;
	input wire [3:0] store_we_to_dmem;
	reg [31:0] mem_array [0:NUM_WORDS - 1];
	initial $readmemh("mem_initial_contents.hex", mem_array);
	always @(*)
		if (_sv2v_0)
			;
	localparam signed [31:0] AddrMsb = $clog2(NUM_WORDS) + 1;
	localparam signed [31:0] AddrLsb = 2;
	always @(negedge clk)
		if (rst)
			;
		else
			insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
	always @(negedge clk)
		if (rst)
			;
		else begin
			if (store_we_to_dmem[0])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
			if (store_we_to_dmem[1])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
			if (store_we_to_dmem[2])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
			if (store_we_to_dmem[3])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
			load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
		end
	initial _sv2v_0 = 0;
endmodule
module SystemDemo (
	external_clk_25MHz,
	btn,
	led,
	gp
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	output wire [27:0] gp;
	localparam signed [31:0] MmapGpioStart = 32'hff001000;
	localparam signed [31:0] LastGpioIndex = 27;
	localparam signed [31:0] MmapGpioEnd = MmapGpioStart + LastGpioIndex;
	localparam signed [31:0] MmapLeds = 32'hff002000;
	localparam signed [31:0] MmapButtons = 32'hff003000;
	wire clk_proc;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	wire [31:0] trace_writeback_pc;
	wire [31:0] trace_writeback_insn;
	wire [31:0] trace_writeback_cycle_status;
	wire is_gpio_write = (mem_data_we != 0) && ((MmapGpioStart <= mem_data_addr) && (mem_data_addr <= MmapGpioEnd));
	wire is_led_write = (mem_data_we != 0) && (mem_data_addr == MmapLeds);
	wire is_button_read = mem_data_addr == MmapButtons;
	reg [7:0] led_reg;
	reg [27:0] gpio_reg;
	always @(posedge clk_proc)
		if (!clk_locked) begin
			led_reg <= 0;
			gpio_reg <= 0;
		end
		else if (is_gpio_write)
			gpio_reg[mem_data_addr - MmapGpioStart] <= mem_data_to_write[0];
		else if (is_led_write)
			led_reg <= mem_data_to_write[7:0];
	assign gp = gpio_reg;
	assign led = led_reg;
	MemorySingleCycle #(.NUM_WORDS(1024)) memory(
		.rst(!clk_locked),
		.clk(clk_proc),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem((is_gpio_write ? 4'd0 : mem_data_we))
	);
	DatapathPipelined datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(),
		.trace_completed_pc(trace_writeback_pc),
		.trace_completed_insn(trace_writeback_insn),
		.trace_completed_cycle_status(trace_writeback_cycle_status)
	);
endmodule