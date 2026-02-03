`timescale 1ns / 1ps

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b; // 1 & 0 -> 0, 1 | 0 -> 1 meaning like it would be 0 with a carry, lets say these are in order4 bit
   // essentially we have to take g and p, lets take the cases - at worst 1 = a, b -> then g = 1, p = 1, c_out = 1
   // a = 1, b = 0 -> g = 0, p = 1, c_out = 1
   // a = 0, b = 1 -> ...

   // a = 0, b = 0 -> g = 0, p = 0, c_out = 0
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

   // TODO: your code here
   // intuition - we need to essentially loop through and go:
   // okay we have gin[i], pin[i]
   // if gin[i] or (pin[i] & cin) -> cout = 1
   wire p_carry_stmt;
   wire g_or_pc;
   logic cout_0, cout_1, cout_2;
   
   assign p_carry_stmt = (pin[0] & cin);
   assign g_or_pc = (gin[0] | p_carry_stmt);

   always_comb begin
      if (g_or_pc) begin
         cout_0 = 1'b1;
      end else begin 
         cout_0 = 1'b0;
      end   
   end

   wire p_carry_stmt_1;
   wire g_or_pc_1;
   assign p_carry_stmt_1 = (pin[1] & cout_0);
   assign g_or_pc_1 = (gin[1] | p_carry_stmt_1);

   always_comb begin
      if (g_or_pc_1) begin
         cout_1 = 1'b1;
      end else begin 
         cout_1 = 1'b0;
      end   
   end

   wire p_carry_stmt_2;
   wire g_or_pc_2;
   assign p_carry_stmt_2 = (pin[2] & cout_1);
   assign g_or_pc_2 = (gin[2] | p_carry_stmt_2);

   always_comb begin
      if (g_or_pc_2) begin
         cout_2 = 1'b1;
      end else begin 
         cout_2 = 1'b0;
      end   
   end
   
   assign cout[0] = cout_0;
   assign cout[1] = cout_1;
   assign cout[2] = cout_2;

   assign gout = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]);

   assign pout = pin[0] & pin[1] & pin[2] & pin[3];


   

endmodule

/** Same as gp4 but for an 8-bit window instead */
module gp8(input wire [7:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [6:0] cout);
   wire p_carry_stmt;
   wire g_or_pc;
   logic cout_0, cout_1, cout_2, cout_3, cout_4, cout_5, cout_6;
   
   assign p_carry_stmt = (pin[0] & cin);
   assign g_or_pc = (gin[0] | p_carry_stmt);

   always_comb begin
      if (g_or_pc) begin
         cout_0 = 1'b1;
      end else begin 
         cout_0 = 1'b0;
      end   
   end

   wire p_carry_stmt_1;
   wire g_or_pc_1;
   assign p_carry_stmt_1 = (pin[1] & cout_0);
   assign g_or_pc_1 = (gin[1] | p_carry_stmt_1);

   always_comb begin
      if (g_or_pc_1) begin
         cout_1 = 1'b1;
      end else begin 
         cout_1 = 1'b0;
      end   
   end

   wire p_carry_stmt_2;
   wire g_or_pc_2;
   assign p_carry_stmt_2 = (pin[2] & cout_1);
   assign g_or_pc_2 = (gin[2] | p_carry_stmt_2);

   always_comb begin
      if (g_or_pc_2) begin
         cout_2 = 1'b1;
      end else begin 
         cout_2 = 1'b0;
      end   
   end

   wire p_carry_stmt_3;
   wire g_or_pc_3;
   assign p_carry_stmt_3 = (pin[3] & cout_2);
   assign g_or_pc_3 = (gin[3] | p_carry_stmt_3);

   always_comb begin
      if (g_or_pc_3) begin
         cout_3 = 1'b1;
      end else begin 
         cout_3 = 1'b0;
      end   
   end

   wire p_carry_stmt_4;
   wire g_or_pc_4;
   assign p_carry_stmt_4 = (pin[4] & cout_3);
   assign g_or_pc_4 = (gin[4] | p_carry_stmt_4);

   always_comb begin
      if (g_or_pc_4) begin
         cout_4 = 1'b1;
      end else begin 
         cout_4 = 1'b0;
      end   
   end

   wire p_carry_stmt_5;
   wire g_or_pc_5;
   assign p_carry_stmt_5 = (pin[5] & cout_4);
   assign g_or_pc_5 = (gin[5] | p_carry_stmt_5);

   always_comb begin
      if (g_or_pc_5) begin
         cout_5 = 1'b1;
      end else begin 
         cout_5 = 1'b0;
      end   
   end

   wire p_carry_stmt_6;
   wire g_or_pc_6;
   assign p_carry_stmt_6 = (pin[6] & cout_5);
   assign g_or_pc_6 = (gin[6] | p_carry_stmt_6);

   always_comb begin
      if (g_or_pc_6) begin
         cout_6 = 1'b1;
      end else begin 
         cout_6 = 1'b0;
      end   
   end
   
   assign cout[0] = cout_0;
   assign cout[1] = cout_1;
   assign cout[2] = cout_2;
   assign cout[3] = cout_3;
   assign cout[4] = cout_4;
   assign cout[5] = cout_5;
   assign cout[6] = cout_6;

   assign gout = gin[7] | (pin[7] & gin[6]) | (pin[7] & pin[6] & gin[5]) | (pin[7] & pin[6] & pin[5] & gin[4]) | (pin[7] & pin[6] & pin[5] & pin[4] & gin[3]) | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & gin[2]) | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & pin[2] & gin[1]) | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & pin[2] & pin[1] & gin[0]);

   assign pout = &pin;

endmodule

module CarryLookaheadAdder
  (input wire [31:0]  a, b,
   input wire         cin,
   output wire [31:0] sum);

   // TODO: your code here

   logic [31:0] g;
   logic [31:0] p;

   genvar i;
   for (i = 0; i < 32; i = i + 1) begin : gp1_inst
      gp1 gp1_inst (
         .a(a[i]),
         .b(b[i]),
         .g(g[i]),
         .p(p[i])
      );
   end

   wire [6:0] cout_0, cout_1, cout_2, cout_3;
   wire gout_0, pout_0, gout_1, pout_1, gout_2, pout_2, gout_3, pout_3;
   wire carry_8, carry_16, carry_24;

   gp8 gp8_inst_0 (
      .gin(g[7:0]),
      .pin(p[7:0]),
      .cin(cin),
      .gout(gout_0),
      .pout(pout_0),
      .cout(cout_0)
   );

   assign carry_8 = gout_0 | (pout_0 & cin);
   
   gp8 gp8_inst_1 (
      .gin(g[15:8]),
      .pin(p[15:8]),
      .cin(carry_8),
      .gout(gout_1),
      .pout(pout_1),
      .cout(cout_1)
   );

   assign carry_16 = gout_1 | (pout_1 & carry_8);
   
   gp8 gp8_inst_2 (
      .gin(g[23:16]),
      .pin(p[23:16]),
      .cin(carry_16),
      .gout(gout_2),
      .pout(pout_2),
      .cout(cout_2)
   );

   assign carry_24 = gout_2 | (pout_2 & carry_16);
   
   gp8 gp8_inst_3 (
      .gin(g[31:24]),
      .pin(p[31:24]),
      .cin(carry_24),
      .gout(gout_3),
      .pout(pout_3),
      .cout(cout_3)
   );

   wire [31:0] carry_in;

   // compiling correct carry_in for the final sum, need to essentially make the full array from individual parts due to impl details.
   // these are done individually due to circular dependency compilation issues
   assign carry_in = {cout_3, carry_24, cout_2, carry_16, cout_1, carry_8, cout_0, cin};

   assign sum = a ^ b ^ carry_in;

endmodule
