/* tomhuang 89284960*/
/* shahhali 88552608*/

`timescale 1ns / 1ns

// quotient = dividend / divisor

module DividerUnsignedPipelined (
    input wire clk, rst, stall,
    input  wire  [31:0] i_dividend,
    input  wire  [31:0] i_divisor,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);

    wire [31:0] quotient_bus [0:32];
    wire [31:0] dividend_bus [0:32];
    wire [31:0] remainder_bus [0:32];

    logic [31:0] quotient_reg [0:6];
    logic [31:0] dividend_reg [0:6];
    logic [31:0] remainder_reg [0:6];
    logic [31:0] divisor_reg [0:6];

    assign remainder_bus[0] = 32'd0;
    assign quotient_bus[0] = 32'd0;
    assign dividend_bus[0] = i_dividend;

    genvar i; 
    generate 
        for (i = 0; i < 32; i++) begin
            divu_1iter d (
                .i_dividend(((i & 3) == 0 && i != 0) ? dividend_reg[i/4-1] : dividend_bus[i]),
                .i_divisor((i >= 4) ? divisor_reg[i/4-1] : i_divisor),
                .i_remainder(((i & 3) == 0 && i != 0) ? remainder_reg[i/4-1] : remainder_bus[i]),
                .i_quotient(((i & 3) == 0 && i != 0) ? quotient_reg[i/4-1] : quotient_bus[i]),
                .o_dividend(dividend_bus[i+1]),
                .o_remainder(remainder_bus[i+1]),
                .o_quotient(quotient_bus[i+1])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int r = 0; r < 7; r++) begin
                quotient_reg[r] <= 0;
                dividend_reg[r] <= 0;
                divisor_reg[r] <= 0;
                remainder_reg[r] <= 0;
            end
        end else begin
            for (int r = 0; r < 7; r++) begin
                dividend_reg[r]  <= dividend_bus[(r+1)*4];
                remainder_reg[r] <= remainder_bus[(r+1)*4];
                quotient_reg[r]  <= quotient_bus[(r+1)*4];
                divisor_reg[r]   <= (r == 0) ? i_divisor : divisor_reg[r-1];
            end
        end
    end

    assign o_remainder = remainder_bus[32];
    assign o_quotient = quotient_bus[32];

endmodule


module divu_1iter (
    input  wire  [31:0] i_dividend,
    input  wire  [31:0] i_divisor,
    input  wire  [31:0] i_remainder,
    input  wire  [31:0] i_quotient,
    output logic [31:0] o_dividend,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);

    wire [31:0] remainder;
    wire status;

    assign remainder = {i_remainder[30:0],i_dividend[31]};

    assign status = (remainder < i_divisor);
    assign o_quotient = status ? (i_quotient << 1) : ((i_quotient << 1) | 32'b1);
    assign o_remainder = status ? remainder : (remainder - i_divisor);

    assign o_dividend = i_dividend << 1;

endmodule
