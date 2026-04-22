`default_nettype none
module MyClockGen (
	input_clk_25MHz,
	clk_125MHz,
	clk_25MHz,
	clk_proc,
	locked
);
	input input_clk_25MHz;
	output wire clk_125MHz;
	output wire clk_25MHz;
	output wire clk_proc;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "125" *) (* FREQUENCY_PIN_CLKOS = "25" *) (* FREQUENCY_PIN_CLKOS2 = "20.1613" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
		.PLLRST_ENA("DISABLED"),
		.INTFB_WAKE("DISABLED"),
		.STDBY_ENABLE("DISABLED"),
		.DPHASE_SOURCE("DISABLED"),
		.OUTDIVIDER_MUXA("DIVA"),
		.OUTDIVIDER_MUXB("DIVB"),
		.OUTDIVIDER_MUXC("DIVC"),
		.OUTDIVIDER_MUXD("DIVD"),
		.CLKI_DIV(1),
		.CLKOP_ENABLE("ENABLED"),
		.CLKOP_DIV(5),
		.CLKOP_CPHASE(2),
		.CLKOP_FPHASE(0),
		.CLKOS_ENABLE("ENABLED"),
		.CLKOS_DIV(25),
		.CLKOS_CPHASE(2),
		.CLKOS_FPHASE(0),
		.CLKOS2_ENABLE("ENABLED"),
		.CLKOS2_DIV(31),
		.CLKOS2_CPHASE(2),
		.CLKOS2_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(5)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_125MHz),
		.CLKOS(clk_25MHz),
		.CLKOS2(clk_proc),
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
`default_nettype none
`default_nettype none
module skidbuffer (
	i_clk,
	i_reset,
	i_valid,
	o_ready,
	i_data,
	o_valid,
	i_ready,
	o_data
);
	parameter [0:0] OPT_LOWPOWER = 0;
	parameter [0:0] OPT_OUTREG = 1;
	parameter [0:0] OPT_PASSTHROUGH = 0;
	parameter DW = 8;
	parameter [0:0] OPT_INITIAL = 1'b1;
	input wire i_clk;
	input wire i_reset;
	input wire i_valid;
	output wire o_ready;
	input wire [DW - 1:0] i_data;
	output wire o_valid;
	input wire i_ready;
	output reg [DW - 1:0] o_data;
	wire [DW - 1:0] w_data;
	generate
		if (OPT_PASSTHROUGH) begin : PASSTHROUGH
			assign {o_valid, o_ready} = {i_valid, i_ready};
			always @(*)
				if (!i_valid && OPT_LOWPOWER)
					o_data = 0;
				else
					o_data = i_data;
			assign w_data = 0;
			wire unused_passthrough;
			assign unused_passthrough = &{1'b0, i_clk, i_reset};
		end
		else begin : LOGIC
			reg r_valid;
			reg [DW - 1:0] r_data;
			initial if (OPT_INITIAL)
				r_valid = 0;
			always @(posedge i_clk)
				if (i_reset)
					r_valid <= 0;
				else if ((i_valid && o_ready) && (o_valid && !i_ready))
					r_valid <= 1;
				else if (i_ready)
					r_valid <= 0;
			initial if (OPT_INITIAL)
				r_data = 0;
			always @(posedge i_clk)
				if (OPT_LOWPOWER && i_reset)
					r_data <= 0;
				else if (OPT_LOWPOWER && (!o_valid || i_ready))
					r_data <= 0;
				else if (((!OPT_LOWPOWER || !OPT_OUTREG) || i_valid) && o_ready)
					r_data <= i_data;
			assign w_data = r_data;
			assign o_ready = !r_valid;
			if (!OPT_OUTREG) begin : NET_OUTPUT
				assign o_valid = !i_reset && (i_valid || r_valid);
				always @(*)
					if (r_valid)
						o_data = r_data;
					else if (!OPT_LOWPOWER || i_valid)
						o_data = i_data;
					else
						o_data = 0;
			end
			else begin : REG_OUTPUT
				reg ro_valid;
				initial if (OPT_INITIAL)
					ro_valid = 0;
				always @(posedge i_clk)
					if (i_reset)
						ro_valid <= 0;
					else if (!o_valid || i_ready)
						ro_valid <= i_valid || r_valid;
				assign o_valid = ro_valid;
				initial if (OPT_INITIAL)
					o_data = 0;
				always @(posedge i_clk)
					if (OPT_LOWPOWER && i_reset)
						o_data <= 0;
					else if (!o_valid || i_ready) begin
						if (r_valid)
							o_data <= r_data;
						else if (!OPT_LOWPOWER || i_valid)
							o_data <= i_data;
						else
							o_data <= 0;
					end
			end
		end
	endgenerate
	wire unused;
	assign unused = &{1'b0, w_data};
endmodule
module Disasm (
	insn,
	disasm
);
	parameter PREFIX = "D";
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
`default_nettype none
module SystemResourceCheck (
	external_clk_25MHz,
	btn,
	led
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	wire clk;
	wire clk_locked;
	wire ignore0;
	wire ignore1;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_125MHz(ignore0),
		.clk_25MHz(ignore1),
		.clk_proc(clk),
		.locked(clk_locked)
	);
	wire rst = !clk_locked;
	generate
		if (1) begin : axil_mem_ro
			localparam signed [31:0] ADDR_WIDTH = 32;
			localparam signed [31:0] DATA_WIDTH = 32;
			wire ARREADY;
			wire ARVALID;
			wire [31:0] ARADDR;
			wire [2:0] ARPROT;
			wire RREADY;
			wire RVALID;
			wire [31:0] RDATA;
			wire [1:0] RRESP;
			wire AWREADY;
			wire AWVALID;
			wire [31:0] AWADDR;
			wire [2:0] AWPROT;
			wire WREADY;
			wire WVALID;
			wire [31:0] WDATA;
			wire [3:0] WSTRB;
			wire BREADY;
			wire BVALID;
			wire [1:0] BRESP;
		end
		if (1) begin : axil_mem_rw
			localparam signed [31:0] ADDR_WIDTH = 32;
			localparam signed [31:0] DATA_WIDTH = 32;
			wire ARREADY;
			wire ARVALID;
			wire [31:0] ARADDR;
			wire [2:0] ARPROT;
			wire RREADY;
			wire RVALID;
			wire [31:0] RDATA;
			wire [1:0] RRESP;
			wire AWREADY;
			wire AWVALID;
			wire [31:0] AWADDR;
			wire [2:0] AWPROT;
			wire WREADY;
			wire WVALID;
			wire [31:0] WDATA;
			wire [3:0] WSTRB;
			wire BREADY;
			wire BVALID;
			wire [1:0] BRESP;
		end
	endgenerate
	localparam _param_F80E1_OPT_SKIDBUFFER = 1;
	localparam _param_F80E1_OPT_LOWPOWER = 0;
	localparam _param_F80E1_NUM_WORDS = 128;
	generate
		if (1) begin : memory
			localparam [0:0] OPT_SKIDBUFFER = _param_F80E1_OPT_SKIDBUFFER;
			localparam [0:0] OPT_LOWPOWER = _param_F80E1_OPT_LOWPOWER;
			localparam NUM_WORDS = _param_F80E1_NUM_WORDS;
			wire ACLK;
			wire ARESETn;
			localparam ADDRLSB = 2;
			wire i_reset = !ARESETn;
			wire axil_write_ready;
			wire [29:0] awskd_addr;
			wire [31:0] wskd_data;
			wire [3:0] wskd_strb;
			reg axil_bvalid;
			wire axil_read_ready;
			wire [29:0] arskd_addr;
			reg [31:0] axil_read_data;
			reg axil_read_valid;
			wire t_axil_read_ready;
			wire [29:0] t_arskd_addr;
			reg [31:0] t_axil_read_data;
			reg t_axil_read_valid;
			localparam signed [31:0] AddrLsb = 2;
			localparam signed [31:0] AddrMsb = 8;
			reg [31:0] mem_array [0:127];
			if (OPT_SKIDBUFFER) begin : SKIDBUFFER_WRITE
				wire awskd_valid;
				wire wskd_valid;
				skidbuffer #(
					.OPT_OUTREG(0),
					.OPT_LOWPOWER(OPT_LOWPOWER),
					.DW(30)
				) axilawskid(
					.i_clk(ACLK),
					.i_reset(i_reset),
					.i_valid(SystemResourceCheck.axil_mem_rw.AWVALID),
					.o_ready(SystemResourceCheck.axil_mem_rw.AWREADY),
					.i_data(SystemResourceCheck.axil_mem_rw.AWADDR[31:ADDRLSB]),
					.o_valid(awskd_valid),
					.i_ready(axil_write_ready),
					.o_data(awskd_addr)
				);
				skidbuffer #(
					.OPT_OUTREG(0),
					.OPT_LOWPOWER(OPT_LOWPOWER),
					.DW(36)
				) axilwskid(
					.i_clk(ACLK),
					.i_reset(i_reset),
					.i_valid(SystemResourceCheck.axil_mem_rw.WVALID),
					.o_ready(SystemResourceCheck.axil_mem_rw.WREADY),
					.i_data({SystemResourceCheck.axil_mem_rw.WDATA, SystemResourceCheck.axil_mem_rw.WSTRB}),
					.o_valid(wskd_valid),
					.i_ready(axil_write_ready),
					.o_data({wskd_data, wskd_strb})
				);
				assign axil_write_ready = (awskd_valid && wskd_valid) && (!SystemResourceCheck.axil_mem_rw.BVALID || SystemResourceCheck.axil_mem_rw.BREADY);
			end
			else begin : SIMPLE_WRITES
				reg axil_awready;
				initial axil_awready = 1'b0;
				always @(posedge ACLK)
					if (!ARESETn)
						axil_awready <= 1'b0;
					else
						axil_awready <= (!axil_awready && (SystemResourceCheck.axil_mem_rw.AWVALID && SystemResourceCheck.axil_mem_rw.WVALID)) && (!SystemResourceCheck.axil_mem_rw.BVALID || SystemResourceCheck.axil_mem_rw.BREADY);
				assign SystemResourceCheck.axil_mem_rw.AWREADY = axil_awready;
				assign SystemResourceCheck.axil_mem_rw.WREADY = axil_awready;
				assign awskd_addr = SystemResourceCheck.axil_mem_rw.AWADDR[31:ADDRLSB];
				assign wskd_data = SystemResourceCheck.axil_mem_rw.WDATA;
				assign wskd_strb = SystemResourceCheck.axil_mem_rw.WSTRB;
				assign axil_write_ready = axil_awready;
			end
			initial axil_bvalid = 0;
			always @(posedge ACLK)
				if (i_reset)
					axil_bvalid <= 0;
				else if (axil_write_ready)
					axil_bvalid <= 1;
				else if (SystemResourceCheck.axil_mem_rw.BREADY)
					axil_bvalid <= 0;
			assign SystemResourceCheck.axil_mem_rw.BVALID = axil_bvalid;
			assign SystemResourceCheck.axil_mem_rw.BRESP = 2'b00;
			if (OPT_SKIDBUFFER) begin : SKIDBUFFER_READ
				wire arskd_valid;
				skidbuffer #(
					.OPT_OUTREG(0),
					.OPT_LOWPOWER(OPT_LOWPOWER),
					.DW(30)
				) axilarskid(
					.i_clk(ACLK),
					.i_reset(i_reset),
					.i_valid(SystemResourceCheck.axil_mem_rw.ARVALID),
					.o_ready(SystemResourceCheck.axil_mem_rw.ARREADY),
					.i_data(SystemResourceCheck.axil_mem_rw.ARADDR[31:ADDRLSB]),
					.o_valid(arskd_valid),
					.i_ready(axil_read_ready),
					.o_data(arskd_addr)
				);
				assign axil_read_ready = arskd_valid && (!axil_read_valid || SystemResourceCheck.axil_mem_rw.RREADY);
			end
			else begin : SIMPLE_READS
				reg axil_arready;
				always @(*) axil_arready = !SystemResourceCheck.axil_mem_rw.RVALID;
				assign arskd_addr = SystemResourceCheck.axil_mem_rw.ARADDR[31:ADDRLSB];
				assign SystemResourceCheck.axil_mem_rw.ARREADY = axil_arready;
				assign axil_read_ready = SystemResourceCheck.axil_mem_rw.ARVALID && SystemResourceCheck.axil_mem_rw.ARREADY;
			end
			initial axil_read_valid = 1'b0;
			always @(posedge ACLK)
				if (i_reset)
					axil_read_valid <= 1'b0;
				else if (axil_read_ready)
					axil_read_valid <= 1'b1;
				else if (SystemResourceCheck.axil_mem_rw.RREADY)
					axil_read_valid <= 1'b0;
			assign SystemResourceCheck.axil_mem_rw.RVALID = axil_read_valid;
			assign SystemResourceCheck.axil_mem_rw.RDATA = axil_read_data;
			assign SystemResourceCheck.axil_mem_rw.RRESP = 2'b00;
			if (OPT_SKIDBUFFER) begin : T_SKIDBUFFER_READ
				wire t_arskd_valid;
				skidbuffer #(
					.OPT_OUTREG(0),
					.OPT_LOWPOWER(OPT_LOWPOWER),
					.DW(30)
				) axilarskid(
					.i_clk(ACLK),
					.i_reset(i_reset),
					.i_valid(SystemResourceCheck.axil_mem_ro.ARVALID),
					.o_ready(SystemResourceCheck.axil_mem_ro.ARREADY),
					.i_data(SystemResourceCheck.axil_mem_ro.ARADDR[31:ADDRLSB]),
					.o_valid(t_arskd_valid),
					.i_ready(t_axil_read_ready),
					.o_data(t_arskd_addr)
				);
				assign t_axil_read_ready = t_arskd_valid && (!t_axil_read_valid || SystemResourceCheck.axil_mem_ro.RREADY);
			end
			else begin : T_SIMPLE_READS
				reg t_axil_arready;
				always @(*) t_axil_arready = !SystemResourceCheck.axil_mem_ro.RVALID;
				assign t_arskd_addr = SystemResourceCheck.axil_mem_ro.ARADDR[31:ADDRLSB];
				assign SystemResourceCheck.axil_mem_ro.ARREADY = t_axil_arready;
				assign t_axil_read_ready = SystemResourceCheck.axil_mem_ro.ARVALID && SystemResourceCheck.axil_mem_ro.ARREADY;
			end
			initial t_axil_read_valid = 1'b0;
			always @(posedge ACLK)
				if (i_reset)
					t_axil_read_valid <= 1'b0;
				else if (t_axil_read_ready)
					t_axil_read_valid <= 1'b1;
				else if (SystemResourceCheck.axil_mem_ro.RREADY)
					t_axil_read_valid <= 1'b0;
			assign SystemResourceCheck.axil_mem_ro.RVALID = t_axil_read_valid;
			assign SystemResourceCheck.axil_mem_ro.RDATA = t_axil_read_data;
			assign SystemResourceCheck.axil_mem_ro.RRESP = 2'b00;
			always @(posedge ACLK)
				if (i_reset)
					;
				else if (axil_write_ready) begin
					if (wskd_strb[0])
						mem_array[awskd_addr[6:0]][7:0] <= wskd_data[7:0];
					if (wskd_strb[1])
						mem_array[awskd_addr[6:0]][15:8] <= wskd_data[15:8];
					if (wskd_strb[2])
						mem_array[awskd_addr[6:0]][23:16] <= wskd_data[23:16];
					if (wskd_strb[3])
						mem_array[awskd_addr[6:0]][31:24] <= wskd_data[31:24];
				end
			initial begin
				axil_read_data = 0;
				t_axil_read_data = 0;
			end
			always @(posedge ACLK) begin
				if (!SystemResourceCheck.axil_mem_rw.RVALID || SystemResourceCheck.axil_mem_rw.RREADY)
					axil_read_data <= mem_array[arskd_addr[6:0]];
				if (!SystemResourceCheck.axil_mem_ro.RVALID || SystemResourceCheck.axil_mem_ro.RREADY)
					t_axil_read_data <= mem_array[t_arskd_addr[6:0]];
			end
		end
	endgenerate
	assign memory.ACLK = clk;
	assign memory.ARESETn = ~rst;
	wire [31:0] trace_completed_pc;
	wire [31:0] trace_completed_insn;
	wire [31:0] trace_completed_cycle_status;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	generate
		if (1) begin : datapath
			reg _sv2v_0;
			wire clk;
			wire rst;
			wire halt;
			wire [31:0] trace_completed_pc;
			wire [31:0] trace_completed_insn;
			wire [31:0] trace_completed_cycle_status;
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
			wire load_use_stall;
			reg div_stall;
			reg branch_taken;
			reg [31:0] branch_target;
			wire stall_pipeline;
			assign stall_pipeline = load_use_stall || div_stall;
			reg [31:0] f_pc_current;
			reg [31:0] f_cycle_status;
			always @(posedge clk)
				if (rst) begin
					f_pc_current <= 32'd0;
					f_cycle_status <= 32'd1;
				end
				else if (stall_pipeline)
					;
				else begin
					f_cycle_status <= 32'd1;
					f_pc_current <= (branch_taken ? branch_target : f_pc_current + 4);
				end
			assign SystemResourceCheck.axil_mem_ro.ARADDR = f_pc_current;
			assign SystemResourceCheck.axil_mem_ro.ARVALID = !rst && !stall_pipeline;
			assign SystemResourceCheck.axil_mem_ro.ARPROT = 3'b000;
			assign SystemResourceCheck.axil_mem_ro.RREADY = !stall_pipeline;
			assign SystemResourceCheck.axil_mem_ro.AWVALID = 1'b0;
			assign SystemResourceCheck.axil_mem_ro.AWADDR = 32'b00000000000000000000000000000000;
			assign SystemResourceCheck.axil_mem_ro.AWPROT = 3'b000;
			assign SystemResourceCheck.axil_mem_ro.WVALID = 1'b0;
			assign SystemResourceCheck.axil_mem_ro.WDATA = 32'b00000000000000000000000000000000;
			assign SystemResourceCheck.axil_mem_ro.WSTRB = 4'b0000;
			assign SystemResourceCheck.axil_mem_ro.BREADY = 1'b1;
			reg [63:0] g_state;
			always @(posedge clk)
				if (rst)
					g_state <= 64'h0000000000000004;
				else if (branch_taken)
					g_state <= 64'h0000000000000008;
				else if (stall_pipeline)
					;
				else
					g_state <= {f_pc_current, f_cycle_status};
			wire [255:0] g_disasm;
			Disasm #(.PREFIX("G")) disasm_0g(
				.insn(SystemResourceCheck.axil_mem_ro.RDATA),
				.disasm(g_disasm)
			);
			reg [95:0] decode_state;
			always @(posedge clk)
				if (rst)
					decode_state <= 96'h000000000000000000000004;
				else if (branch_taken)
					decode_state <= 96'h000000000000000000000008;
				else if (stall_pipeline)
					;
				else if (g_state[31-:32] != 32'd1)
					decode_state <= {64'h0000000000000000, sv2v_cast_32(g_state[31-:32])};
				else
					decode_state <= {sv2v_cast_32(g_state[63-:32]), sv2v_cast_32(SystemResourceCheck.axil_mem_ro.RDATA), sv2v_cast_32(g_state[31-:32])};
			wire [255:0] d_disasm;
			Disasm #(.PREFIX("D")) disasm_1decode(
				.insn(decode_state[63-:32]),
				.disasm(d_disasm)
			);
			wire [6:0] insn_funct7;
			wire [4:0] insn_rs2;
			wire [4:0] insn_rs1;
			wire [2:0] insn_funct3;
			wire [4:0] insn_rd;
			wire [6:0] insn_opcode;
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
			wire insn_uses_rs2 = ((insn_opcode == OpRegReg) || (insn_opcode == OpStore)) || (insn_opcode == OpBranch);
			reg [302:0] execute_state;
			assign load_use_stall = ((execute_state[245:239] == OpLoad) && (execute_state[46-:5] != 0)) && ((insn_rs1 == execute_state[46-:5]) || (insn_uses_rs2 && (insn_rs2 == execute_state[46-:5])));
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
			wire [7:0] b;
			wire [15:0] h;
			reg [63:0] prod;
			reg [31:0] div_a;
			reg [31:0] div_b;
			reg [31:0] div_dividend;
			reg [31:0] div_divisor;
			wire [31:0] div_remainder;
			wire [31:0] div_quotient;
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
			reg [135:0] memory_state;
			assign x_rs1_data = ((memory_state[32] && (memory_state[39-:5] != 0)) && (memory_state[39-:5] == execute_state[41-:5]) ? memory_state[71-:32] : ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == execute_state[41-:5]) ? writeback_state[69-:32] : execute_state[238-:32]));
			assign x_rs2_data = ((memory_state[32] && (memory_state[39-:5] != 0)) && (memory_state[39-:5] == execute_state[36-:5]) ? memory_state[71-:32] : ((writeback_state[32] && (writeback_state[37-:5] != 0)) && (writeback_state[37-:5] == execute_state[36-:5]) ? writeback_state[69-:32] : execute_state[206-:32]));
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
			reg [31:0] x_store_data;
			reg [3:0] x_store_strb;
			wire [1:0] x_byte_offset;
			assign x_byte_offset = alu_result[1:0];
			always @(*) begin
				if (_sv2v_0)
					;
				x_store_data = 32'b00000000000000000000000000000000;
				x_store_strb = 4'b0000;
				if (x_insn_sb)
					case (x_byte_offset)
						2'b00: begin
							x_store_data[7:0] = x_rs2_data[7:0];
							x_store_strb = 4'b0001;
						end
						2'b01: begin
							x_store_data[15:8] = x_rs2_data[7:0];
							x_store_strb = 4'b0010;
						end
						2'b10: begin
							x_store_data[23:16] = x_rs2_data[7:0];
							x_store_strb = 4'b0100;
						end
						2'b11: begin
							x_store_data[31:24] = x_rs2_data[7:0];
							x_store_strb = 4'b1000;
						end
					endcase
				else if (x_insn_sh)
					case (x_byte_offset[1])
						1'b0: begin
							x_store_data[15:0] = x_rs2_data[15:0];
							x_store_strb = 4'b0011;
						end
						1'b1: begin
							x_store_data[31:16] = x_rs2_data[15:0];
							x_store_strb = 4'b1100;
						end
					endcase
				else if (x_insn_sw) begin
					x_store_data = x_rs2_data;
					x_store_strb = 4'b1111;
				end
			end
			assign SystemResourceCheck.axil_mem_rw.ARADDR = {alu_result[31:2], 2'b00};
			assign SystemResourceCheck.axil_mem_rw.ARVALID = (x_insn_opcode == OpLoad) && (execute_state[31-:32] == 32'd1);
			assign SystemResourceCheck.axil_mem_rw.ARPROT = 3'b000;
			assign SystemResourceCheck.axil_mem_rw.RREADY = 1'b1;
			assign SystemResourceCheck.axil_mem_rw.AWADDR = {alu_result[31:2], 2'b00};
			assign SystemResourceCheck.axil_mem_rw.AWVALID = (x_insn_opcode == OpStore) && (execute_state[31-:32] == 32'd1);
			assign SystemResourceCheck.axil_mem_rw.AWPROT = 3'b000;
			assign SystemResourceCheck.axil_mem_rw.WVALID = SystemResourceCheck.axil_mem_rw.AWVALID;
			assign SystemResourceCheck.axil_mem_rw.WDATA = x_store_data;
			assign SystemResourceCheck.axil_mem_rw.WSTRB = x_store_strb;
			assign SystemResourceCheck.axil_mem_rw.BREADY = 1'b1;
			always @(posedge clk)
				if (rst)
					memory_state <= 136'h0000000000000000000000000000000004;
				else if (div_pipe[6][138])
					memory_state <= {sv2v_cast_32(div_pipe[6][97-:32]), sv2v_cast_32(div_pipe[6][65-:32]), alu_result, sv2v_cast_5(div_pipe[6][102-:5]), 3'h1, sv2v_cast_32(div_pipe[6][31-:32])};
				else if (div_in_progress)
					memory_state <= 136'h0000000000000000000000000000000002;
				else
					memory_state <= {sv2v_cast_32(execute_state[302-:32]), sv2v_cast_32(execute_state[270-:32]), alu_result, sv2v_cast_5(execute_state[46-:5]), alu_result[1:0], insn_writes_rd, sv2v_cast_32(execute_state[31-:32])};
			wire [255:0] m_disasm;
			Disasm #(.PREFIX("M")) disasm_3memory(
				.insn(memory_state[103-:32]),
				.disasm(m_disasm)
			);
			wire [6:0] m_insn_funct7;
			wire [4:0] m_insn_rs2;
			wire [4:0] m_insn_rs1;
			wire [2:0] m_insn_funct3;
			wire [4:0] m_insn_rd;
			wire [6:0] m_insn_opcode;
			assign {m_insn_funct7, m_insn_rs2, m_insn_rs1, m_insn_funct3, m_insn_rd, m_insn_opcode} = memory_state[103-:32];
			wire m_insn_lb = (m_insn_opcode == OpLoad) && (memory_state[86:84] == 3'b000);
			wire m_insn_lh = (m_insn_opcode == OpLoad) && (memory_state[86:84] == 3'b001);
			wire m_insn_lw = (m_insn_opcode == OpLoad) && (memory_state[86:84] == 3'b010);
			wire m_insn_lbu = (m_insn_opcode == OpLoad) && (memory_state[86:84] == 3'b100);
			wire m_insn_lhu = (m_insn_opcode == OpLoad) && (memory_state[86:84] == 3'b101);
			reg [31:0] m_load_data;
			reg [7:0] m_b;
			reg [15:0] m_h;
			always @(*) begin
				if (_sv2v_0)
					;
				m_load_data = 32'b00000000000000000000000000000000;
				m_b = 8'b00000000;
				m_h = 16'b0000000000000000;
				if (m_insn_lb) begin
					case (memory_state[34-:2])
						2'b00: m_b = SystemResourceCheck.axil_mem_rw.RDATA[7:0];
						2'b01: m_b = SystemResourceCheck.axil_mem_rw.RDATA[15:8];
						2'b10: m_b = SystemResourceCheck.axil_mem_rw.RDATA[23:16];
						2'b11: m_b = SystemResourceCheck.axil_mem_rw.RDATA[31:24];
					endcase
					m_load_data = {{24 {m_b[7]}}, m_b};
				end
				else if (m_insn_lbu) begin
					case (memory_state[34-:2])
						2'b00: m_b = SystemResourceCheck.axil_mem_rw.RDATA[7:0];
						2'b01: m_b = SystemResourceCheck.axil_mem_rw.RDATA[15:8];
						2'b10: m_b = SystemResourceCheck.axil_mem_rw.RDATA[23:16];
						2'b11: m_b = SystemResourceCheck.axil_mem_rw.RDATA[31:24];
					endcase
					m_load_data = {24'b000000000000000000000000, m_b};
				end
				else if (m_insn_lh) begin
					case (memory_state[34])
						1'b0: m_h = SystemResourceCheck.axil_mem_rw.RDATA[15:0];
						1'b1: m_h = SystemResourceCheck.axil_mem_rw.RDATA[31:16];
					endcase
					m_load_data = {{16 {m_h[15]}}, m_h};
				end
				else if (m_insn_lhu) begin
					case (memory_state[34])
						1'b0: m_h = SystemResourceCheck.axil_mem_rw.RDATA[15:0];
						1'b1: m_h = SystemResourceCheck.axil_mem_rw.RDATA[31:16];
					endcase
					m_load_data = {16'b0000000000000000, m_h};
				end
				else if (m_insn_lw)
					m_load_data = SystemResourceCheck.axil_mem_rw.RDATA;
			end
			always @(posedge clk)
				if (rst)
					writeback_state <= 134'h0000000000000000000000000000000004;
				else
					writeback_state <= {sv2v_cast_32(memory_state[135-:32]), sv2v_cast_32(memory_state[103-:32]), sv2v_cast_32((memory_state[78:72] == OpLoad ? m_load_data : memory_state[71-:32])), sv2v_cast_5(memory_state[39-:5]), memory_state[32], sv2v_cast_32(memory_state[31-:32])};
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
		end
	endgenerate
	assign datapath.clk = clk;
	assign datapath.rst = rst;
	assign led[0] = datapath.halt;
	assign trace_completed_pc = datapath.trace_completed_pc;
	assign trace_completed_insn = datapath.trace_completed_insn;
	assign trace_completed_cycle_status = datapath.trace_completed_cycle_status;
endmodule