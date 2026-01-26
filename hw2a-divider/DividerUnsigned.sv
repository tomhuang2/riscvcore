/* tomhuang 89284960*/
/* shahhali 88552608*/
`timescale 1ns / 1ns

// quotient = dividend / divisor

module DividerUnsigned (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);
    wire [31:0] quotient_bus [0:32];
    wire [31:0] dividend_bus [0:32];
    wire [31:0] remainder_bus [0:32];

    assign remainder_bus[0] = 32'd0;
    assign quotient_bus[0] = 32'd0;
    assign dividend_bus[0] = i_dividend;

    genvar i; 
    generate 
        for (i = 0; i < 32; i++) begin
            DividerOneIter d (
                .i_dividend(dividend_bus[i]),
                .i_divisor(i_divisor),
                .i_remainder(remainder_bus[i]),
                .i_quotient(quotient_bus[i]),
                .o_dividend(dividend_bus[i+1]),
                .o_remainder(remainder_bus[i+1]),
                .o_quotient(quotient_bus[i+1])
            );
        end
    endgenerate

    assign o_remainder = remainder_bus[32];
    assign o_quotient = quotient_bus[32];
endmodule


module DividerOneIter (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    input  wire [31:0] i_remainder,
    input  wire [31:0] i_quotient,
    output wire [31:0] o_dividend,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);
  /*
    for (int i = 0; i < 32; i++) {
       vscv;
        if (remainder < divisor) {
            quotient = (quotient << 1);
        } else {
            quotient = (quotient << 1) | 0x1;
            remainder = remainder - divisor;
        }
        dividend = dividend << 1;
    }
    */
    wire [31:0] remainder;
    wire status;

    assign remainder = {i_remainder[30:0],i_dividend[31]};

    assign status = (remainder < i_divisor);
    assign o_quotient = status ? (i_quotient << 1) : ((i_quotient << 1) | 32'b1);
    assign o_remainder = status ? remainder : (remainder - i_divisor);

    assign o_dividend = i_dividend << 1;
endmodule
