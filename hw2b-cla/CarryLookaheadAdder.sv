`timescale 1ns / 1ps

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits internally would generate a carry-out (independent of cin)
 * @param pout whether these 4 bits internally would propagate an incoming carry from cin
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
   
   assign pout = (& pin);
   assign gout = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | ((& pin[3:1]) & gin[0]);
   assign cout[0] = gin[0] | (pin[0] & cin);
   assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & cin);
   assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0] | ((& pin[2:0]) & cin));
endmodule

/** Same as gp4 but for an 8-bit window instead */
module gp8(input wire [7:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [6:0] cout);

   assign pout = (& pin);
   assign gout = gin[7] | (pin[7] & gin[6]) | ((& pin[7:6]) & gin[5]) | ((& pin[7:5]) & gin[4]) | ((& pin[7:4]) & gin[3]) | 
   ((& pin[7:3]) & gin[2]) | ((& pin[7:2]) & gin[1]) | ((& pin[7:1]) & gin[0]);

   assign cout[0] = gin[0] | (pin[0] & cin);
   assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & cin);
   assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0] | ((& pin[2:0]) & cin));
   assign cout[3] = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | ((& pin[3:1]) & gin[0]) | ((& pin[3:0]) & cin);
   assign cout[4] = gin[4] | (pin[4] & gin[3]) | ((& pin[4:3]) & gin[2]) | ((& pin[4:2]) & gin[1]) | ((& pin[4:1]) & gin[0]) | ((& pin[4:0]) & cin);
   assign cout[5] = gin[5] | (pin[5] & gin[4]) | ((& pin[5:4]) & gin[3]) | ((& pin[5:3]) & gin[2]) | ((& pin[5:2]) & gin[1]) | ((& pin[5:1]) & gin[0]) | ((& pin[5:0]) & cin);
   assign cout[6] = gin[6] | (pin[6] & gin[5]) | ((& pin[6:5]) & gin[4]) | ((& pin[6:4]) & gin[3]) | ((& pin[6:3]) & gin[2]) | ((& pin[6:2]) & gin[1]) | ((& pin[6:1]) & gin[0]) | ((& pin[6:0]) & cin);
endmodule

module CarryLookaheadAdder
  (input wire [31:0]  a, b,
   input wire         cin,
   output wire [31:0] sum);

   wire [31:0] g_gp1, p_gp1, carries;
   wire [7:0] g_gp4, p_gp4;
   wire g_gp8, p_gp8;
   wire [6:0] carries_gp8;
   wire [7:0] cin4;

   assign cin4[0] = cin;
   genvar i; 

   generate 
      for (i = 1; i < 8; i++) begin
         assign cin4[i] = carries_gp8[i-1];
      end
   endgenerate
   
   generate
      for (i = 0; i < 32; i++) begin
         gp1 gp_one (
            .a(a[i]),
            .b(b[i]),
            .g(g_gp1[i]),
            .p(p_gp1[i])
         );
      end
   endgenerate

   generate
      for (i = 0; i < 8; i++) begin
         gp4 gp_four (
            .gin(g_gp1[4*i+3:4*i]),
            .pin(p_gp1[4*i+3:4*i]),
            .cin(cin4[i]),
            .gout(g_gp4[i]),
            .pout(p_gp4[i]),
            .cout(carries[4*i+3:4*i+1])
         );
      end
   endgenerate

   gp8 gp_eight (
      .gin(g_gp4),
      .pin(p_gp4),
      .cin(cin),
      .gout(g_gp8),
      .pout(p_gp8),
      .cout(carries_gp8)
   );

   //map carries_gp8 to carries
   generate
      for (i = 0; i < 8; i++) begin
         assign carries[4*i] = cin4[i];
      end
   endgenerate

   assign sum = a ^ b ^ carries;
endmodule
