module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	clk_mem,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire clk_mem;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "10" *) (* FREQUENCY_PIN_CLKOS = "10" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
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
		.CLKOP_DIV(60),
		.CLKOP_CPHASE(30),
		.CLKOP_FPHASE(0),
		.CLKOS_ENABLE("ENABLED"),
		.CLKOS_DIV(60),
		.CLKOS_CPHASE(45),
		.CLKOS_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(2)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
		.CLKOS(clk_mem),
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
module DatapathMultiCycle (
	clk,
	rst,
	halt,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg halt;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output reg [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output reg [31:0] store_data_to_dmem;
	output reg [3:0] store_we_to_dmem;
	output wire [31:0] trace_completed_pc;
	output wire [31:0] trace_completed_insn;
	output wire [31:0] trace_completed_cycle_status;
	wire [6:0] insn_funct7;
	wire [4:0] insn_rs2;
	wire [4:0] insn_rs1;
	wire [2:0] insn_funct3;
	wire [4:0] insn_rd;
	wire [6:0] insn_opcode;
	assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = insn_from_imem;
	wire [11:0] imm_i;
	assign imm_i = insn_from_imem[31:20];
	wire [4:0] imm_shamt = insn_from_imem[24:20];
	wire [11:0] imm_s;
	assign imm_s[11:5] = insn_funct7;
	assign imm_s[4:0] = insn_rd;
	wire [12:0] imm_b;
	assign {imm_b[12], imm_b[10:5]} = insn_funct7;
	assign {imm_b[4:1], imm_b[11]} = insn_rd;
	assign imm_b[0] = 1'b0;
	wire [20:0] imm_j;
	assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {insn_from_imem[31:12], 1'b0};
	wire [31:0] imm_i_sext = {{20 {imm_i[11]}}, imm_i[11:0]};
	wire [31:0] imm_s_sext = {{20 {imm_s[11]}}, imm_s[11:0]};
	wire [31:0] imm_b_sext = {{19 {imm_b[12]}}, imm_b[12:0]};
	wire [31:0] imm_j_sext = {{11 {imm_j[20]}}, imm_j[20:0]};
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
	wire insn_lui = insn_opcode == OpLui;
	wire insn_auipc = insn_opcode == OpAuipc;
	wire insn_jal = insn_opcode == OpJal;
	wire insn_jalr = insn_opcode == OpJalr;
	wire insn_beq = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b000);
	wire insn_bne = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b001);
	wire insn_blt = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b100);
	wire insn_bge = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b101);
	wire insn_bltu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b110);
	wire insn_bgeu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b111);
	wire insn_lb = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b000);
	wire insn_lh = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b001);
	wire insn_lw = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b010);
	wire insn_lbu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b100);
	wire insn_lhu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b101);
	wire insn_sb = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b000);
	wire insn_sh = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b001);
	wire insn_sw = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b010);
	wire insn_addi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b000);
	wire insn_slti = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b010);
	wire insn_sltiu = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b011);
	wire insn_xori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b100);
	wire insn_ori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b110);
	wire insn_andi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b111);
	wire insn_slli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srai = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_add = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sub = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_sll = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_slt = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b010)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sltu = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b011)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_xor = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b100)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srl = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sra = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_or = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b110)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_and = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b111)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_mul = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b000);
	wire insn_mulh = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b001);
	wire insn_mulhsu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b010);
	wire insn_mulhu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b011);
	wire insn_div = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b100);
	wire insn_divu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b101);
	wire insn_rem = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b110);
	wire insn_remu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b111);
	wire insn_ecall = (insn_opcode == OpEnviron) && (insn_from_imem[31:7] == 25'd0);
	wire insn_fence = insn_opcode == OpMiscMem;
	reg [31:0] pcNext;
	reg [31:0] pcCurrent;
	always @(posedge clk)
		if (rst)
			pcCurrent <= 32'd0;
		else
			pcCurrent <= pcNext;
	assign pc_to_imem = pcCurrent;
	reg [31:0] cycles_current;
	reg [31:0] num_insns_current;
	always @(posedge clk)
		if (rst) begin
			cycles_current <= 0;
			num_insns_current <= 0;
		end
		else begin
			cycles_current <= cycles_current + 1;
			if (!rst)
				num_insns_current <= num_insns_current + 1;
		end
	wire is_div = ((insn_div || insn_divu) || insn_rem) || insn_remu;
	reg [3:0] div_counter;
	always @(posedge clk)
		if (rst)
			div_counter <= 0;
		else if (is_div)
			div_counter <= (div_counter == 4'd8 ? 4'd0 : div_counter + 1);
		else
			div_counter <= 0;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	reg rf_we;
	reg [31:0] rd_data;
	RegFile rf(
		.clk(clk),
		.rst(rst),
		.we(rf_we),
		.rd(insn_rd),
		.rd_data(rd_data),
		.rs1(insn_rs1),
		.rs2(insn_rs2),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);
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
	always @(*) begin
		if (_sv2v_0)
			;
		illegal_insn = 1'b0;
		rf_we = 0;
		pcNext = pcCurrent + 4;
		halt = 1'b0;
		rd_data = 32'b00000000000000000000000000000000;
		addr_to_dmem = 32'b00000000000000000000000000000000;
		b = 8'b00000000;
		h = 16'b0000000000000000;
		prod = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		store_data_to_dmem = 32'b00000000000000000000000000000000;
		store_we_to_dmem = 4'b0000;
		cla_operand_a = rs1_data;
		cla_operand_b = imm_i_sext;
		cla_carry_in = 1'b0;
		div_dividend = 32'b00000000000000000000000000000000;
		div_divisor = 32'b00000000000000000000000000000000;
		div_a = 32'b00000000000000000000000000000000;
		div_b = 32'b00000000000000000000000000000000;
		case (insn_opcode)
			OpLui: begin
				rf_we = 1'b1;
				rd_data = {insn_from_imem[31:12], 12'b000000000000};
			end
			OpRegImm: begin
				rf_we = 1'b1;
				if (insn_addi)
					rd_data = cla_result;
				else if (insn_slti)
					rd_data = {31'b0000000000000000000000000000000, $signed(rs1_data) < $signed(imm_i_sext)};
				else if (insn_sltiu)
					rd_data = {31'b0000000000000000000000000000000, rs1_data < imm_i_sext};
				else if (insn_xori)
					rd_data = rs1_data ^ imm_i_sext;
				else if (insn_ori)
					rd_data = rs1_data | imm_i_sext;
				else if (insn_andi)
					rd_data = rs1_data & imm_i_sext;
				else if (insn_slli)
					rd_data = rs1_data << imm_shamt;
				else if (insn_srli)
					rd_data = rs1_data >> imm_shamt;
				else if (insn_srai)
					rd_data = $signed(rs1_data) >>> imm_shamt;
			end
			OpRegReg: begin
				rf_we = 1'b1;
				if (insn_add) begin
					cla_operand_b = rs2_data;
					rd_data = cla_result;
				end
				else if (insn_sub) begin
					cla_operand_b = ~rs2_data;
					cla_carry_in = 1'b1;
					rd_data = cla_result;
				end
				else if (insn_sll)
					rd_data = rs1_data << rs2_data[4:0];
				else if (insn_slt)
					rd_data = {31'b0000000000000000000000000000000, $signed(rs1_data) < $signed(rs2_data)};
				else if (insn_sltu)
					rd_data = {31'b0000000000000000000000000000000, rs1_data < rs2_data};
				else if (insn_xor)
					rd_data = rs1_data ^ rs2_data;
				else if (insn_srl)
					rd_data = rs1_data >> rs2_data[4:0];
				else if (insn_sra)
					rd_data = $signed(rs1_data) >>> rs2_data[4:0];
				else if (insn_or)
					rd_data = rs1_data | rs2_data;
				else if (insn_and)
					rd_data = rs1_data & rs2_data;
				else if (insn_mul) begin
					prod = rs1_data * rs2_data;
					rd_data = prod[31:0];
				end
				else if (insn_mulh) begin
					prod = $signed(rs1_data) * $signed(rs2_data);
					rd_data = prod[63:32];
				end
				else if (insn_mulhsu) begin
					prod = $signed({{32 {rs1_data[31]}}, rs1_data}) * $signed({32'b00000000000000000000000000000000, rs2_data});
					rd_data = prod[63:32];
				end
				else if (insn_mulhu) begin
					prod = $unsigned(rs1_data) * $unsigned(rs2_data);
					rd_data = prod[63:32];
				end
				else if (insn_div) begin
					if (rs2_data == 32'b00000000000000000000000000000000)
						rd_data = 32'hffffffff;
					else if ((rs1_data == 32'h80000000) && (rs2_data == 32'hffffffff))
						rd_data = 32'h80000000;
					else begin
						div_a = (rs1_data[31] ? ~rs1_data + 1 : rs1_data);
						div_b = (rs2_data[31] ? ~rs2_data + 1 : rs2_data);
						div_dividend = div_a;
						div_divisor = div_b;
						if (rs1_data[31] != rs2_data[31])
							rd_data = ~div_quotient + 1;
						else
							rd_data = div_quotient;
					end
				end
				else if (insn_divu) begin
					div_dividend = rs1_data;
					div_divisor = $unsigned(rs2_data);
					rd_data = div_quotient;
				end
				else if (insn_rem) begin
					if (rs2_data == 32'b00000000000000000000000000000000)
						rd_data = rs1_data;
					else if ((rs1_data == 32'h80000000) && (rs2_data == 32'hffffffff))
						rd_data = 0;
					else begin
						div_a = (rs1_data[31] ? ~rs1_data + 1 : rs1_data);
						div_b = (rs2_data[31] ? ~rs2_data + 1 : rs2_data);
						div_dividend = div_a;
						div_divisor = div_b;
						if (rs1_data[31])
							rd_data = ~div_remainder + 1;
						else
							rd_data = div_remainder;
					end
				end
				else if (insn_remu) begin
					div_dividend = rs1_data;
					div_divisor = $unsigned(rs2_data);
					rd_data = div_remainder;
				end
			end
			OpBranch:
				if (insn_beq) begin
					if (rs1_data == rs2_data)
						pcNext = pcCurrent + imm_b_sext;
				end
				else if (insn_bne) begin
					if (rs1_data != rs2_data)
						pcNext = pcCurrent + imm_b_sext;
				end
				else if (insn_blt) begin
					if ($signed(rs1_data) < $signed(rs2_data))
						pcNext = pcCurrent + imm_b_sext;
				end
				else if (insn_bge) begin
					if ($signed(rs1_data) >= $signed(rs2_data))
						pcNext = pcCurrent + imm_b_sext;
				end
				else if (insn_bltu) begin
					if (rs1_data < rs2_data)
						pcNext = pcCurrent + imm_b_sext;
				end
				else if (insn_bgeu) begin
					if (rs1_data >= rs2_data)
						pcNext = pcCurrent + imm_b_sext;
				end
			OpEnviron:
				if (insn_ecall)
					halt = 1'b1;
			OpAuipc: begin
				rf_we = 1'b1;
				rd_data = pcCurrent + {insn_from_imem[31:12], 12'b000000000000};
			end
			OpLoad: begin
				rf_we = 1'b1;
				cla_operand_a = rs1_data;
				cla_operand_b = imm_i_sext;
				addr_to_dmem = {cla_result[31:2], 2'b00};
				if (insn_lb) begin
					case (cla_result[1:0])
						2'b00: b = load_data_from_dmem[7:0];
						2'b01: b = load_data_from_dmem[15:8];
						2'b10: b = load_data_from_dmem[23:16];
						2'b11: b = load_data_from_dmem[31:24];
					endcase
					rd_data = {{24 {b[7]}}, b};
				end
				else if (insn_lbu) begin
					case (cla_result[1:0])
						2'b00: b = load_data_from_dmem[7:0];
						2'b01: b = load_data_from_dmem[15:8];
						2'b10: b = load_data_from_dmem[23:16];
						2'b11: b = load_data_from_dmem[31:24];
					endcase
					rd_data = {{24 {1'b0}}, b};
				end
				else if (insn_lh) begin
					case (cla_result[1])
						1'b0: h = load_data_from_dmem[15:0];
						1'b1: h = load_data_from_dmem[31:16];
					endcase
					rd_data = {{16 {h[15]}}, h};
				end
				else if (insn_lhu) begin
					case (cla_result[1])
						1'b0: h = load_data_from_dmem[15:0];
						1'b1: h = load_data_from_dmem[31:16];
					endcase
					rd_data = {{16 {1'b0}}, h};
				end
				else if (insn_lw)
					rd_data = load_data_from_dmem;
			end
			OpStore: begin
				cla_operand_a = rs1_data;
				cla_operand_b = imm_s_sext;
				addr_to_dmem = {cla_result[31:2], 2'b00};
				if (insn_sb)
					case (cla_result[1:0])
						2'b00: begin
							store_data_to_dmem[7:0] = rs2_data[7:0];
							store_we_to_dmem = 4'b0001;
						end
						2'b01: begin
							store_data_to_dmem[15:8] = rs2_data[7:0];
							store_we_to_dmem = 4'b0010;
						end
						2'b10: begin
							store_data_to_dmem[23:16] = rs2_data[7:0];
							store_we_to_dmem = 4'b0100;
						end
						2'b11: begin
							store_data_to_dmem[31:24] = rs2_data[7:0];
							store_we_to_dmem = 4'b1000;
						end
					endcase
				else if (insn_sh)
					case (cla_result[1])
						1'b0: begin
							store_data_to_dmem[15:0] = rs2_data[15:0];
							store_we_to_dmem = 4'b0011;
						end
						1'b1: begin
							store_data_to_dmem[31:16] = rs2_data[15:0];
							store_we_to_dmem = 4'b1100;
						end
					endcase
				else if (insn_sw) begin
					store_data_to_dmem[31:0] = rs2_data[31:0];
					store_we_to_dmem = 4'b1111;
				end
			end
			OpJal: begin
				rf_we = 1;
				rd_data = pcCurrent + 4;
				pcNext = pcCurrent + imm_j_sext;
			end
			OpJalr: begin
				rf_we = 1;
				rd_data = pcCurrent + 4;
				pcNext = (rs1_data + imm_i_sext) & {{31 {1'b1}}, 1'b0};
			end
			default: illegal_insn = 1'b1;
		endcase
		if (is_div && (div_counter != 4'd8)) begin
			pcNext = pcCurrent;
			rf_we = 1'b0;
		end
	end
	assign trace_completed_pc = pcCurrent;
	assign trace_completed_insn = insn_from_imem;
	assign trace_completed_cycle_status = (is_div && (div_counter != 4'd8) ? 32'd2 : 32'd1);
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clock_mem,
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
	input wire clock_mem;
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
	always @(posedge clock_mem)
		if (rst)
			;
		else
			insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
	always @(negedge clock_mem)
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
module SystemResourceCheck (
	external_clk_25MHz,
	btn,
	led
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	wire clk_proc;
	wire clk_mem;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.clk_mem(clk_mem),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	MemorySingleCycle #(.NUM_WORDS(128)) memory(
		.rst(!clk_locked),
		.clock_mem(clk_mem),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we)
	);
	DatapathMultiCycle datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(led[0])
	);
endmodule