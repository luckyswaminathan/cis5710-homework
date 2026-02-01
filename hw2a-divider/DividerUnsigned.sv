/* INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ns

// quotient = dividend / divisor

module DividerUnsigned (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);

    logic [31:0] dividend_temp[33];
    logic [31:0] remainder_temp[33];
    logic [31:0] quotient_temp[33];
    assign dividend_temp[0] = i_dividend;
    assign remainder_temp[0] = 32'b0;
    assign quotient_temp[0] = 32'b0;

    genvar i;
    for (i = 0; i < 32; i = i + 1) begin : divider_one_iter
        DividerOneIter divider_one_iter_inst (
            .i_dividend(dividend_temp[i]),
            .i_divisor(i_divisor),
            .i_remainder(remainder_temp[i]),
            .i_quotient(quotient_temp[i]),
            .o_dividend(dividend_temp[i+1]),
            .o_remainder(remainder_temp[i+1]),
            .o_quotient(quotient_temp[i+1])
        );
    end

    assign o_remainder = remainder_temp[32];
    assign o_quotient = quotient_temp[32];


endmodule


module DividerOneIter (
    input  logic [31:0] i_dividend,
    input  logic [31:0] i_divisor,
    input  logic [31:0] i_remainder,
    input  logic [31:0] i_quotient,
    output logic [31:0] o_dividend,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);
  /*
    for (int i = 0; i < 32; i++) {
        remainder = (remainder << 1) | ((dividend >> 31) & 0x1);
        if (remainder < divisor) {
            quotient = (quotient << 1);
        } else {
            quotient = (quotient << 1) | 0x1;
            remainder = remainder - divisor;
        }
        dividend = dividend << 1;
    }
  */

    logic [31:0] r_cmp;
    logic [31:0] r_sub;
    logic        lt;

    assign r_cmp      = (i_remainder << 1) | {{31{1'b0}}, i_dividend[31]};
    assign o_dividend = i_dividend << 1;         
    assign r_sub      = r_cmp - i_divisor;
    assign lt         = (r_cmp < i_divisor);     

    always_comb begin
        if (lt) begin

            o_remainder = r_cmp;
            o_quotient  = (i_quotient << 1);
        end else begin

            o_remainder = r_sub;
            o_quotient  = (i_quotient << 1) | 32'b1;
        end
    end

endmodule
