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
	assign carries[0] = cin;
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 32; _gv_i_1 = _gv_i_1 + 1) begin : genblk1
			localparam i = _gv_i_1;
			gp1 gp_one(
				.a(a[i]),
				.b(b[i]),
				.g(g_gp1[i]),
				.p(p_gp1[i])
			);
		end
		for (_gv_i_1 = 0; _gv_i_1 < 8; _gv_i_1 = _gv_i_1 + 1) begin : genblk2
			localparam i = _gv_i_1;
			gp4 gp_four(
				.gin(g_gp1[(4 * i) + 3:4 * i]),
				.pin(p_gp1[(4 * i) + 3:4 * i]),
				.cin(carries[4 * i]),
				.gout(g_gp4[i]),
				.pout(p_gp4[i]),
				.cout(carries[(4 * i) + 3:(4 * i) + 1])
			);
		end
	endgenerate
	gp8 gp_eight(
		.gin(g_gp4),
		.pin(p_gp4),
		.cin(carries[0]),
		.gout(g_gp8),
		.pout(p_gp8),
		.cout(carries_gp8)
	);
	generate
		for (_gv_i_1 = 1; _gv_i_1 < 8; _gv_i_1 = _gv_i_1 + 1) begin : genblk3
			localparam i = _gv_i_1;
			assign carries[4 * i] = carries_gp8[i - 1];
		end
	endgenerate
	assign sum = (a ^ b) ^ carries;
endmodule
module SystemDemo (
	external_clk_25MHz,
	btn,
	led
);
	reg _sv2v_0;
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output reg [7:0] led;
	reg [31:0] ab;
	wire [15:0] a;
	wire [15:0] b;
	wire [31:0] expected_sum;
	wire [31:0] actual_sum;
	wire rst = ~btn[0];
	reg error;
	wire [2:0] chunk = ab[31:29];
	reg [7:0] completed;
	CarryLookaheadAdder cla_inst(
		.a(a),
		.b(b),
		.cin(1'b0),
		.sum(actual_sum)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		a = ab[31:16];
		b = ab[15:0];
		expected_sum = a + b;
	end
	always @(posedge external_clk_25MHz)
		if (rst) begin
			ab <= 32'd0;
			error <= 1'b0;
			completed <= 8'd0;
		end
		else if (!error) begin
			if (actual_sum != expected_sum)
				error <= 1'b1;
			else begin
				ab <= ab + 1;
				if (ab[28:0] == 29'h1fffffff)
					completed[chunk] <= 1'b1;
			end
		end
	reg [23:0] blink;
	always @(posedge external_clk_25MHz)
		if (rst)
			blink <= 0;
		else
			blink <= blink + 1;
	always @(*) begin
		if (_sv2v_0)
			;
		if (error)
			led = completed;
		else
			led = completed | ({7'd0, blink[23]} << chunk);
	end
	initial _sv2v_0 = 0;
endmodule