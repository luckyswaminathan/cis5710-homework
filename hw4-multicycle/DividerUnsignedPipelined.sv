/* INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ns

// quotient = dividend / divisor

module divider_4iter (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    input  wire [31:0] i_remainder,
    input  wire [31:0] i_quotient,
    output wire [31:0] o_dividend,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);
    wire [31:0] d1, d2, d3, r1, r2, r3, q1, q2, q3;
    divu_1iter it0(.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(i_remainder), .i_quotient(i_quotient),
                   .o_dividend(d1), .o_remainder(r1), .o_quotient(q1));
    divu_1iter it1(.i_dividend(d1), .i_divisor(i_divisor), .i_remainder(r1), .i_quotient(q1),
                   .o_dividend(d2), .o_remainder(r2), .o_quotient(q2));
    divu_1iter it2(.i_dividend(d2), .i_divisor(i_divisor), .i_remainder(r2), .i_quotient(q2),
                   .o_dividend(d3), .o_remainder(r3), .o_quotient(q3));
    divu_1iter it3(.i_dividend(d3), .i_divisor(i_divisor), .i_remainder(r3), .i_quotient(q3),
                   .o_dividend(o_dividend), .o_remainder(o_remainder), .o_quotient(o_quotient));
endmodule

module DividerUnsignedPipelined (
    input wire clk, rst, stall,
    input  wire  [31:0] i_dividend,
    input  wire  [31:0] i_divisor,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);

    // 7 pipeline registers (after stages 0-6), stage 7 output is combinational
    logic [31:0] p_div[7], p_rem[7], p_quot[7], p_dvsr[7];

    // Stage 0: combinational from module inputs
    wire [31:0] s0_do, s0_ro, s0_qo;
    divider_4iter stg0(
        .i_dividend(i_dividend), .i_divisor(i_divisor),
        .i_remainder(32'b0), .i_quotient(32'b0),
        .o_dividend(s0_do), .o_remainder(s0_ro), .o_quotient(s0_qo)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            p_div[0] <= 0; p_rem[0] <= 0; p_quot[0] <= 0; p_dvsr[0] <= 0;
        end else begin
            p_div[0] <= s0_do; p_rem[0] <= s0_ro; p_quot[0] <= s0_qo; p_dvsr[0] <= i_divisor;
        end
    end

    // Stages 1-6: combinational from previous register, output to next register
    genvar s;
    for (s = 1; s < 7; s = s + 1) begin : mid_stage
        wire [31:0] sd_o, sr_o, sq_o;
        divider_4iter u(
            .i_dividend(p_div[s-1]), .i_divisor(p_dvsr[s-1]),
            .i_remainder(p_rem[s-1]), .i_quotient(p_quot[s-1]),
            .o_dividend(sd_o), .o_remainder(sr_o), .o_quotient(sq_o)
        );
        always_ff @(posedge clk) begin
            if (rst) begin
                p_div[s] <= 0; p_rem[s] <= 0; p_quot[s] <= 0; p_dvsr[s] <= 0;
            end else begin
                p_div[s] <= sd_o; p_rem[s] <= sr_o; p_quot[s] <= sq_o; p_dvsr[s] <= p_dvsr[s-1];
            end
        end
    end

    // Stage 7: combinational from register 6, output goes directly to module output
    wire [31:0] s7_do, s7_ro, s7_qo;
    divider_4iter stg7(
        .i_dividend(p_div[6]), .i_divisor(p_dvsr[6]),
        .i_remainder(p_rem[6]), .i_quotient(p_quot[6]),
        .o_dividend(s7_do), .o_remainder(s7_ro), .o_quotient(s7_qo)
    );

    assign o_quotient  = s7_qo;
    assign o_remainder = s7_ro;

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
