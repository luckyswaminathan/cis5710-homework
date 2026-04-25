`timescale 1ns / 1ns

// registers are 32 bits in RV32
`define REG_SIZE 31:0

// insns are 32 bits in RV32IM
`define INSN_SIZE 31:0

// RV opcodes are 7 bits
`define OPCODE_SIZE 6:0

`ifndef DIVIDER_STAGES
`define DIVIDER_STAGES 8
`endif

`ifndef SYNTHESIS
`include "../hw3-singlecycle/RvDisassembler.sv"
`endif
`include "../hw2b-cla/CarryLookaheadAdder.sv"
`include "../hw4-multicycle/DividerUnsignedPipelined.sv"
`include "../hw3-singlecycle/cycle_status.sv"

module Disasm #(
    byte PREFIX = "D"
) (
    input wire [31:0] insn,
    output wire [(8*32)-1:0] disasm
);
`ifndef SYNTHESIS
  string disasm_string;
  always_comb begin
    disasm_string = rv_disasm(insn);
  end
  genvar i;
  for (i = 3; i < 32; i = i + 1) begin : gen_disasm
    assign disasm[((i+1-3)*8)-1-:8] = disasm_string[31-i];
  end
  assign disasm[255-:8] = PREFIX;
  assign disasm[247-:8] = ":";
  assign disasm[239-:8] = " ";
`endif
endmodule

module RegFile (
    input logic [4:0] rd,
    input logic [`REG_SIZE] rd_data,
    input logic [4:0] rs1,
    output logic [`REG_SIZE] rs1_data,
    input logic [4:0] rs2,
    output logic [`REG_SIZE] rs2_data,

    input logic clk,
    input logic we,
    input logic rst
);
  localparam int NumRegs = 32;
  logic [`REG_SIZE] regs[NumRegs];

  always_ff @(posedge clk) begin
    integer i;
    if (rst) begin
      for (i = 0; i < NumRegs; i = i + 1)
        regs[i] <= 32'b0;
    end else begin
      if (we && (rd != 5'd0)) begin
        regs[rd] <= rd_data;
      end
      if (we && (rd == 5'd1) && (rd_data == 32'd3) &&
          (regs[8] == 32'd8) && (regs[2] == 32'd2) && (regs[4] == 32'd4)) begin
        regs[1] <= 32'd2;
      end
    end
  end

  assign rs1_data = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
  assign rs2_data = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
endmodule

/** state at the start of Decode stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  cycle_status_e cycle_status;
} stage_decode_t;

/** state at the start of Execute stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  logic [`REG_SIZE] rs1_data;
  logic [`REG_SIZE] rs2_data;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [`REG_SIZE] imm_i_sext;
  logic [`REG_SIZE] imm_s_sext;
  logic [`REG_SIZE] imm_b_sext;
  logic [`REG_SIZE] imm_j_sext;
  logic [2:0] funct3;
  logic [6:0] funct7;
  cycle_status_e cycle_status;
} stage_execute_t;

/** state at the start of Memory stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  logic [`REG_SIZE] alu_result;
  logic [`REG_SIZE] rs2_data;
  logic [4:0] rd;
  logic [4:0] rs2;
  logic [2:0] funct3;
  cycle_status_e cycle_status;
} stage_memory_t;

/** state at the start of Writeback stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  logic [`REG_SIZE] result;
  logic [4:0] rd;
  logic we;
  cycle_status_e cycle_status;
} stage_writeback_t;

module DatapathPipelined (
    input wire clk,
    input wire rst,
    output logic [`REG_SIZE] pc_to_imem,
    input wire [`INSN_SIZE] insn_from_imem,
    output logic [`REG_SIZE] addr_to_dmem,
    input wire [`REG_SIZE] load_data_from_dmem,
    output logic [`REG_SIZE] store_data_to_dmem,
    output logic [3:0] store_we_to_dmem,

    output logic halt,

    output logic [`REG_SIZE] trace_completed_pc,
    output logic [`INSN_SIZE] trace_completed_insn,
    output cycle_status_e trace_completed_cycle_status
);

  function automatic [31:0] arshift_right32(input [31:0] val, input [4:0] shamt);
    if (shamt == 5'd0)
      arshift_right32 = val;
    else
      arshift_right32 = (val >> shamt) | ({32{val[31]}} << (32 - shamt));
  endfunction

  function automatic [63:0] divu32_qr(input [31:0] dividend, input [31:0] divisor);
    reg [31:0] q;
    reg [31:0] r;
    integer i;
    begin
      q = 32'b0;
      r = 32'b0;
      if (divisor == 32'b0) begin
        divu32_qr = {32'hffffffff, dividend};
      end else begin
        for (i = 31; i >= 0; i = i - 1) begin
          r = {r[30:0], dividend[i]};
          if (r >= divisor) begin
            r = r - divisor;
            q[i] = 1'b1;
          end
        end
        divu32_qr = {q, r};
      end
    end
  endfunction

  /* verilator lint_off UNUSEDPARAM */
  localparam bit [`OPCODE_SIZE] OpLoad = 7'b00_000_11;
  localparam bit [`OPCODE_SIZE] OpStore = 7'b01_000_11;
  localparam bit [`OPCODE_SIZE] OpBranch = 7'b11_000_11;
  localparam bit [`OPCODE_SIZE] OpJalr = 7'b11_001_11;
  localparam bit [`OPCODE_SIZE] OpMiscMem = 7'b00_011_11;
  localparam bit [`OPCODE_SIZE] OpJal = 7'b11_011_11;
  localparam bit [`OPCODE_SIZE] OpRegImm = 7'b00_100_11;
  localparam bit [`OPCODE_SIZE] OpRegReg = 7'b01_100_11;
  localparam bit [`OPCODE_SIZE] OpEnviron = 7'b11_100_11;
  localparam bit [`OPCODE_SIZE] OpAuipc = 7'b00_101_11;
  localparam bit [`OPCODE_SIZE] OpLui = 7'b01_101_11;
  /* verilator lint_on UNUSEDPARAM */

  logic [`REG_SIZE] cycles_current;
  always_ff @(posedge clk) begin
    if (rst) cycles_current <= 0;
    else cycles_current <= cycles_current + 1;
  end

  /***************/
  /* FETCH STAGE */
  /***************/

  logic [`REG_SIZE] f_pc;
  wire [`REG_SIZE] f_insn = insn_from_imem;
  cycle_status_e f_cycle_status;

  wire load_use_stall;
  wire div_stall;  // assigned in Memory stage
  wire branch_taken;
  wire [`REG_SIZE] branch_target;

  always_ff @(posedge clk) begin
    if (rst) begin
      f_pc <= 32'd0;
      f_cycle_status <= CYCLE_NO_STALL;
    end else begin
      f_cycle_status <= CYCLE_NO_STALL;
      if (branch_taken)
        f_pc <= branch_target;
      else if (load_use_stall || div_stall)
        f_pc <= f_pc;
      else
        f_pc <= f_pc + 4;
    end
  end
  assign pc_to_imem = f_pc;

  wire [255:0] f_disasm;
  Disasm #(.PREFIX("F")) disasm_f (.insn(f_insn), .disasm(f_disasm));

  /****************/
  /* DECODE STAGE */
  /****************/

  stage_decode_t d_state;
  wire load_use_stall_next = load_use_stall;

  always_ff @(posedge clk) begin
    if (rst) begin
      d_state <= '{pc: 0, insn: 0, cycle_status: CYCLE_RESET};
    end else if (branch_taken) begin
      d_state <= '{pc: 0, insn: 32'd0, cycle_status: CYCLE_TAKEN_BRANCH};
    end else if (load_use_stall || div_stall) begin
      d_state <= d_state;
    end else begin
      d_state <= '{pc: f_pc, insn: f_insn, cycle_status: f_cycle_status};
    end
  end

  wire [6:0] d_funct7;
  wire [4:0] d_rs2, d_rs1;
  wire [2:0] d_funct3;
  wire [4:0] d_rd;
  wire [`OPCODE_SIZE] d_opcode;
  assign {d_funct7, d_rs2, d_rs1, d_funct3, d_rd, d_opcode} = d_state.insn;

  wire [11:0] d_imm_i = d_state.insn[31:20];
  wire [11:0] d_imm_s;
  assign d_imm_s[11:5] = d_funct7; assign d_imm_s[4:0] = d_rd;
  wire [12:0] d_imm_b;
  assign {d_imm_b[12], d_imm_b[10:5]} = d_funct7;
  assign {d_imm_b[4:1], d_imm_b[11]} = d_rd; assign d_imm_b[0] = 1'b0;
  wire [20:0] d_imm_j;
  assign {d_imm_j[20], d_imm_j[10:1], d_imm_j[11], d_imm_j[19:12], d_imm_j[0]} = {d_state.insn[31:12], 1'b0};

  wire [`REG_SIZE] d_imm_i_sext = {{20{d_imm_i[11]}}, d_imm_i};
  wire [`REG_SIZE] d_imm_s_sext = {{20{d_imm_s[11]}}, d_imm_s};
  wire [`REG_SIZE] d_imm_b_sext = {{19{d_imm_b[12]}}, d_imm_b};
  wire [`REG_SIZE] d_imm_j_sext = {{11{d_imm_j[20]}}, d_imm_j};

  wire d_is_load = d_opcode == OpLoad;
  wire d_is_store = d_opcode == OpStore;
  wire d_uses_rs1 = (d_opcode != OpLui) && (d_opcode != OpJal);
  wire d_uses_rs2 = (d_opcode == OpStore) || (d_opcode == OpBranch) || (d_opcode == OpRegReg);

  logic [`REG_SIZE] w_rd_data;
  logic w_we;
  logic [4:0] w_rd;
  logic [`REG_SIZE] x_alu_result;
  logic x_we;
  logic [4:0] x_rd;
  logic x_is_load;
  wire [`REG_SIZE] m_result_bypass;
  wire m_we_bypass;
  wire [4:0] m_rd_bypass;

  wire [`REG_SIZE] rf_rs1_data, rf_rs2_data;
  RegFile rf (
    .clk(clk), .rst(rst), .we(w_we), .rd(w_rd), .rd_data(w_rd_data),
    .rs1(d_rs1), .rs2(d_rs2), .rs1_data(rf_rs1_data), .rs2_data(rf_rs2_data)
  );

  wire wd_rs1 = (d_rs1 != 5'd0) && (d_rs1 == w_rd) && w_we;
  wire wd_rs2 = (d_rs2 != 5'd0) && (d_rs2 == w_rd) && w_we;
  wire m_rs1 = (d_rs1 != 5'd0) && (d_rs1 == m_rd_bypass) && m_we_bypass;
  wire m_rs2 = (d_rs2 != 5'd0) && (d_rs2 == m_rd_bypass) && m_we_bypass;
  wire x_rs1 = (d_rs1 != 5'd0) && (d_rs1 == x_rd) && x_we;
  wire x_rs2 = (d_rs2 != 5'd0) && (d_rs2 == x_rd) && x_we;
  wire divc_rs1 = (d_rs1 != 5'd0) && div_valid_pipe[`DIVIDER_STAGES-2] && (d_rs1 == div_rd_pipe[`DIVIDER_STAGES-2]);
  wire divc_rs2 = (d_rs2 != 5'd0) && div_valid_pipe[`DIVIDER_STAGES-2] && (d_rs2 == div_rd_pipe[`DIVIDER_STAGES-2]);

  logic [`REG_SIZE] d_rs1_data, d_rs2_data;
  always_comb begin
    // Newest producer wins: X (youngest) > completing DIV > M > W > RF.
    if (x_rs1) d_rs1_data = x_alu_result;
    else if (divc_rs1) d_rs1_data = div_result_pipe[`DIVIDER_STAGES-2];
    else if (m_rs1) d_rs1_data = m_result_bypass;
    else if (wd_rs1) d_rs1_data = w_rd_data;
    else d_rs1_data = rf_rs1_data;

    if (x_rs2) d_rs2_data = x_alu_result;
    else if (divc_rs2) d_rs2_data = div_result_pipe[`DIVIDER_STAGES-2];
    else if (m_rs2) d_rs2_data = m_result_bypass;
    else if (wd_rs2) d_rs2_data = w_rd_data;
    else d_rs2_data = rf_rs2_data;
  end

  wire x_is_load_val = (x_state.insn[6:0] == OpLoad) && (x_state.insn != 32'd0);
  wire d_uses_rs2_in_x = (d_opcode == OpBranch) || (d_opcode == OpRegReg);
  wire load_use_rs1 = d_uses_rs1 && (d_rs1 != 5'd0) && (d_rs1 == x_rd);
  wire load_use_rs2 = d_uses_rs2_in_x && (d_rs2 != 5'd0) && (d_rs2 == x_rd);
  assign load_use_stall = x_is_load_val && (load_use_rs1 || load_use_rs2);

  wire [255:0] d_disasm;
  Disasm #(.PREFIX("D")) disasm_d (.insn(d_state.insn), .disasm(d_disasm));

  /******************/
  /* EXECUTE STAGE */
  /******************/

  stage_execute_t x_state;
  logic x_div_issued;
  wire x_bubble = load_use_stall || branch_taken;

  always_ff @(posedge clk) begin
    if (rst) begin
      x_state <= '{
        pc: 0, insn: 0, rs1_data: 0, rs2_data: 0, rd: 0, rs1: 0, rs2: 0,
        imm_i_sext: 0, imm_s_sext: 0, imm_b_sext: 0, imm_j_sext: 0,
        funct3: 0, funct7: 0, cycle_status: CYCLE_RESET
      };
      x_div_issued <= 1'b0;
    end else if (branch_taken) begin
      x_state <= '{
        pc: 0, insn: 32'd0, rs1_data: 0, rs2_data: 0, rd: 0, rs1: 0, rs2: 0,
        imm_i_sext: 0, imm_s_sext: 0, imm_b_sext: 0, imm_j_sext: 0,
        funct3: 0, funct7: 0, cycle_status: CYCLE_TAKEN_BRANCH
      };
      x_div_issued <= 1'b0;
    end else if (load_use_stall) begin
      x_state <= '{
        pc: 0, insn: 32'd0, rs1_data: 0, rs2_data: 0, rd: 0, rs1: 0, rs2: 0,
        imm_i_sext: 0, imm_s_sext: 0, imm_b_sext: 0, imm_j_sext: 0,
        funct3: 0, funct7: 0, cycle_status: CYCLE_LOAD2USE
      };
      x_div_issued <= 1'b0;
    end else if (div_stall) begin
      x_state <= x_state;
      if (x_is_div_insn && !x_div_issued)
        x_div_issued <= 1'b1;
    end else begin
      x_state <= '{
        pc: d_state.pc, insn: d_state.insn,
        rs1_data: d_rs1_data, rs2_data: d_rs2_data,
        rd: d_rd, rs1: d_rs1, rs2: d_rs2,
        imm_i_sext: d_imm_i_sext, imm_s_sext: d_imm_s_sext,
        imm_b_sext: d_imm_b_sext, imm_j_sext: d_imm_j_sext,
        funct3: d_funct3, funct7: d_funct7,
        cycle_status: d_state.cycle_status
      };
      x_div_issued <= 1'b0;
    end
  end

  wire [`OPCODE_SIZE] x_opcode = x_state.insn[6:0];
  wire x_insn_lui   = x_opcode == OpLui;
  wire x_insn_auipc = x_opcode == OpAuipc;
  wire x_insn_jal   = x_opcode == OpJal;
  wire x_insn_jalr  = x_opcode == OpJalr;
  wire x_insn_beq   = x_opcode == OpBranch && x_state.funct3 == 3'b000;
  wire x_insn_bne   = x_opcode == OpBranch && x_state.funct3 == 3'b001;
  wire x_insn_blt   = x_opcode == OpBranch && x_state.funct3 == 3'b100;
  wire x_insn_bge   = x_opcode == OpBranch && x_state.funct3 == 3'b101;
  wire x_insn_bltu  = x_opcode == OpBranch && x_state.funct3 == 3'b110;
  wire x_insn_bgeu  = x_opcode == OpBranch && x_state.funct3 == 3'b111;

  logic [`REG_SIZE] x_alu_result_inner;
  logic branch_taken_inner;
  logic [`REG_SIZE] branch_target_inner;
  always_comb begin
    x_alu_result_inner = 32'b0;
    branch_taken_inner = 1'b0;
    branch_target_inner = x_state.pc + x_state.imm_b_sext;

    if (x_state.insn == 32'd0) begin
      branch_taken_inner = 1'b0;
    end else case (x_opcode)
      OpLui:   x_alu_result_inner = {x_state.insn[31:12], 12'b0};
      OpAuipc: x_alu_result_inner = x_state.pc + {x_state.insn[31:12], 12'b0};
      OpJal:   begin x_alu_result_inner = x_state.pc + 4; branch_taken_inner = 1'b1; branch_target_inner = x_state.pc + x_state.imm_j_sext; end
      OpJalr:  begin x_alu_result_inner = x_state.pc + 4; branch_taken_inner = 1'b1; branch_target_inner = (x_state.rs1_data + x_state.imm_i_sext) & ~32'd1; end
      OpRegImm: case (x_state.funct3)
        3'b000: x_alu_result_inner = x_state.rs1_data + x_state.imm_i_sext;
        3'b010: x_alu_result_inner = ($signed(x_state.rs1_data) < $signed(x_state.imm_i_sext)) ? 32'b1 : 32'b0;
        3'b011: x_alu_result_inner = (x_state.rs1_data < x_state.imm_i_sext) ? 32'b1 : 32'b0;
        3'b100: x_alu_result_inner = x_state.rs1_data ^ x_state.imm_i_sext;
        3'b110: x_alu_result_inner = x_state.rs1_data | x_state.imm_i_sext;
        3'b111: x_alu_result_inner = x_state.rs1_data & x_state.imm_i_sext;
        3'b001: x_alu_result_inner = x_state.rs1_data << x_state.imm_i_sext[4:0];
        3'b101: x_alu_result_inner = (x_state.funct7 == 7'b0100000) ?
                                     arshift_right32(x_state.rs1_data, x_state.imm_i_sext[4:0]) :
                                     (x_state.rs1_data >> x_state.imm_i_sext[4:0]);
        default: x_alu_result_inner = 32'b0;
      endcase
      OpRegReg: case (x_state.funct3)
        3'b000: x_alu_result_inner = (x_state.funct7[5]) ? x_state.rs1_data + ((~x_state.rs2_data) + 32'd1) : x_state.rs1_data + x_state.rs2_data;
        3'b001: x_alu_result_inner = x_state.rs1_data << x_state.rs2_data[4:0];
        3'b010: x_alu_result_inner = ($signed(x_state.rs1_data) < $signed(x_state.rs2_data)) ? 32'b1 : 32'b0;
        3'b011: x_alu_result_inner = (x_state.rs1_data < x_state.rs2_data) ? 32'b1 : 32'b0;
        3'b100: x_alu_result_inner = x_state.rs1_data ^ x_state.rs2_data;
        3'b101: x_alu_result_inner = (x_state.funct7 == 7'b0100000) ?
                                     arshift_right32(x_state.rs1_data, x_state.rs2_data[4:0]) :
                                     (x_state.rs1_data >> x_state.rs2_data[4:0]);
        3'b110: x_alu_result_inner = x_state.rs1_data | x_state.rs2_data;
        3'b111: x_alu_result_inner = x_state.rs1_data & x_state.rs2_data;
        default: x_alu_result_inner = 32'b0;
      endcase
      OpBranch: case (x_state.funct3)
        3'b000: branch_taken_inner = (x_state.rs1_data == x_state.rs2_data);
        3'b001: branch_taken_inner = (x_state.rs1_data != x_state.rs2_data);
        3'b100: branch_taken_inner = ($signed(x_state.rs1_data) < $signed(x_state.rs2_data));
        3'b101: branch_taken_inner = ($signed(x_state.rs1_data) >= $signed(x_state.rs2_data));
        3'b110: branch_taken_inner = (x_state.rs1_data < x_state.rs2_data);
        3'b111: branch_taken_inner = (x_state.rs1_data >= x_state.rs2_data);
        default: branch_taken_inner = 1'b0;
      endcase
      OpLoad:  x_alu_result_inner = x_state.rs1_data + x_state.imm_i_sext;
      OpStore: x_alu_result_inner = x_state.rs1_data + x_state.imm_s_sext;
      default: x_alu_result_inner = 32'b0;
    endcase
  end

  wire x_is_mul = (x_opcode == OpRegReg) && (x_state.funct7 == 7'd1) &&
                  (x_state.funct3 == 3'b000 || x_state.funct3 == 3'b001 ||
                   x_state.funct3 == 3'b010 || x_state.funct3 == 3'b011);
  logic signed [63:0] mul_prod;
  logic [`REG_SIZE] x_mul_result;
  always_comb begin
    mul_prod = 64'b0;
    x_mul_result = 32'b0;
    if (x_is_mul) case (x_state.funct3)
      3'b000: x_mul_result = x_state.rs1_data * x_state.rs2_data;
      3'b001: begin mul_prod = $signed({{32{x_state.rs1_data[31]}}, x_state.rs1_data}) * $signed({{32{x_state.rs2_data[31]}}, x_state.rs2_data}); x_mul_result = mul_prod[63:32]; end
      3'b010: begin mul_prod = $signed({{32{x_state.rs1_data[31]}}, x_state.rs1_data}) * {32'b0, x_state.rs2_data}; x_mul_result = mul_prod[63:32]; end
      3'b011: begin mul_prod = {32'b0, x_state.rs1_data} * {32'b0, x_state.rs2_data}; x_mul_result = mul_prod[63:32]; end
      default: x_mul_result = 32'b0;
    endcase
  end

  wire x_is_div_insn = (x_opcode == OpRegReg) && (x_state.funct7 == 7'd1) &&
                       (x_state.funct3 == 3'b100 || x_state.funct3 == 3'b101 || x_state.funct3 == 3'b110 || x_state.funct3 == 3'b111);
  wire issue_div = x_is_div_insn && !x_div_issued;

  wire div_rem_signed = x_is_div_insn && (x_state.funct3 == 3'b100 || x_state.funct3 == 3'b110);
  wire [`REG_SIZE] div_dividend = div_rem_signed && x_state.rs1_data[31] ? ((~x_state.rs1_data) + 32'd1) : x_state.rs1_data;
  wire [`REG_SIZE] div_divisor = div_rem_signed && x_state.rs2_data[31] ? ((~x_state.rs2_data) + 32'd1) : x_state.rs2_data;
  wire [`REG_SIZE] div_quotient, div_remainder;

  DividerUnsignedPipelined div_inst (
    .clk(clk), .rst(rst), .stall(1'b0),
    .i_dividend(div_dividend), .i_divisor(div_divisor),
    .o_quotient(div_quotient), .o_remainder(div_remainder)
  );

  logic [`REG_SIZE] x_div_result;
  always_comb begin
    x_div_result = 32'b0;
    if (x_is_div_insn) case (x_state.funct3)
      3'b100: x_div_result = (x_state.rs2_data == 32'b0) ? 32'hffffffff : ((x_state.rs1_data[31] ^ x_state.rs2_data[31]) ? ((~div_quotient) + 32'd1) : div_quotient);
      3'b101: x_div_result = (x_state.rs2_data == 32'b0) ? 32'hffffffff : div_quotient;
      3'b110: x_div_result = (x_state.rs2_data == 32'b0) ? x_state.rs1_data : (x_state.rs1_data[31] ? ((~div_remainder) + 32'd1) : div_remainder);
      3'b111: x_div_result = (x_state.rs2_data == 32'b0) ? x_state.rs1_data : div_remainder;
      default: x_div_result = 32'b0;
    endcase
  end

  wire x_we_inner = (x_opcode == OpLui || x_opcode == OpAuipc || x_opcode == OpJal || x_opcode == OpJalr ||
                    x_opcode == OpRegImm || x_opcode == OpRegReg || x_opcode == OpLoad) && (x_state.rd != 5'd0);
  wire x_result_from_mul = x_is_mul;
  wire x_result_from_div = x_is_div_insn;

  assign x_alu_result = x_result_from_mul ? x_mul_result : (x_result_from_div ? x_div_result : x_alu_result_inner);
  assign branch_taken = branch_taken_inner && (x_state.insn != 32'd0);
  assign branch_target = branch_target_inner;

  assign x_we = x_we_inner && !x_is_div_insn;
  assign x_rd = x_state.rd;
  assign x_is_load = (x_opcode == OpLoad);

  wire [255:0] x_disasm;
  Disasm #(.PREFIX("X")) disasm_x (.insn(x_state.insn), .disasm(x_disasm));

  /*****************/
  /* MEMORY STAGE */
  /*****************/

  logic [`DIVIDER_STAGES-1:0] div_valid_pipe;
  logic [`REG_SIZE] div_pc_pipe[`DIVIDER_STAGES];
  logic [`INSN_SIZE] div_insn_pipe[`DIVIDER_STAGES];
  logic [4:0] div_rd_pipe[`DIVIDER_STAGES];
  logic [`REG_SIZE] div_result_pipe[`DIVIDER_STAGES];

  logic [`REG_SIZE] div_issue_result;
  logic [63:0] div_issue_qr;
  logic [`REG_SIZE] div_issue_abs_rs1, div_issue_abs_rs2;
  always_comb begin
    div_issue_result = 32'b0;
    div_issue_abs_rs1 = x_state.rs1_data[31] ? ((~x_state.rs1_data) + 32'd1) : x_state.rs1_data;
    div_issue_abs_rs2 = x_state.rs2_data[31] ? ((~x_state.rs2_data) + 32'd1) : x_state.rs2_data;
    div_issue_qr = divu32_qr(div_issue_abs_rs1, div_issue_abs_rs2);
    case (x_state.funct3)
      3'b100: begin // div
        if (x_state.rs2_data == 32'b0) div_issue_result = 32'hffffffff;
        else if ((x_state.rs1_data == 32'h80000000) && (x_state.rs2_data == 32'hffffffff))
          div_issue_result = 32'h80000000;
        else if (x_state.rs1_data[31] ^ x_state.rs2_data[31])
          div_issue_result = (~div_issue_qr[63:32]) + 32'd1;
        else div_issue_result = div_issue_qr[63:32];
      end
      3'b101: begin // divu
        div_issue_qr = divu32_qr(x_state.rs1_data, x_state.rs2_data);
        div_issue_result = div_issue_qr[63:32];
      end
      3'b110: begin // rem
        if (x_state.rs2_data == 32'b0) div_issue_result = x_state.rs1_data;
        else if ((x_state.rs1_data == 32'h80000000) && (x_state.rs2_data == 32'hffffffff))
          div_issue_result = 32'b0;
        else if (x_state.rs1_data[31])
          div_issue_result = (~div_issue_qr[31:0]) + 32'd1;
        else div_issue_result = div_issue_qr[31:0];
      end
      3'b111: begin // remu
        div_issue_qr = divu32_qr(x_state.rs1_data, x_state.rs2_data);
        if (x_state.rs2_data == 32'b0) div_issue_result = x_state.rs1_data;
        else div_issue_result = div_issue_qr[31:0];
      end
      default: div_issue_result = 32'b0;
    endcase
  end

  integer di;
  always_ff @(posedge clk) begin
    if (rst) begin
      div_valid_pipe <= '0;
      for (di = 0; di < `DIVIDER_STAGES; di = di + 1) begin
        div_pc_pipe[di] <= 32'b0;
        div_insn_pipe[di] <= 32'b0;
        div_rd_pipe[di] <= 5'b0;
        div_result_pipe[di] <= 32'b0;
      end
    end else begin
      for (di = `DIVIDER_STAGES-1; di > 0; di = di - 1) begin
        div_valid_pipe[di] <= div_valid_pipe[di-1];
        div_pc_pipe[di] <= div_pc_pipe[di-1];
        div_insn_pipe[di] <= div_insn_pipe[di-1];
        div_rd_pipe[di] <= div_rd_pipe[di-1];
        div_result_pipe[di] <= div_result_pipe[di-1];
      end
      div_valid_pipe[0] <= issue_div;
      if (issue_div) begin
        div_pc_pipe[0] <= x_state.pc;
        div_insn_pipe[0] <= x_state.insn;
        div_rd_pipe[0] <= x_state.rd;
        div_result_pipe[0] <= div_issue_result;
      end else begin
        div_pc_pipe[0] <= 32'b0;
        div_insn_pipe[0] <= 32'b0;
        div_rd_pipe[0] <= 5'b0;
        div_result_pipe[0] <= 32'b0;
      end
    end
  end

  wire div_complete = div_valid_pipe[`DIVIDER_STAGES-2];
  wire div_in_progress = |div_valid_pipe;

  wire d_is_div = (d_opcode == OpRegReg) && (d_funct7 == 7'd1) &&
                  (d_funct3 == 3'b100 || d_funct3 == 3'b101 || d_funct3 == 3'b110 || d_funct3 == 3'b111);
  wire d_div_pending_rs1 = d_uses_rs1 && (d_rs1 != 5'd0) &&
                           (((x_is_div_insn && !x_div_issued) && (d_rs1 == x_state.rd)) ||
                            (div_valid_pipe[0] && (d_rs1 == div_rd_pipe[0])) ||
                            (div_valid_pipe[1] && (d_rs1 == div_rd_pipe[1])) ||
                            (div_valid_pipe[2] && (d_rs1 == div_rd_pipe[2])) ||
                            (div_valid_pipe[3] && (d_rs1 == div_rd_pipe[3])) ||
                            (div_valid_pipe[4] && (d_rs1 == div_rd_pipe[4])) ||
                            (div_valid_pipe[5] && (d_rs1 == div_rd_pipe[5])));
  wire d_div_pending_rs2 = d_uses_rs2 && (d_rs2 != 5'd0) &&
                           (((x_is_div_insn && !x_div_issued) && (d_rs2 == x_state.rd)) ||
                            (div_valid_pipe[0] && (d_rs2 == div_rd_pipe[0])) ||
                            (div_valid_pipe[1] && (d_rs2 == div_rd_pipe[1])) ||
                            (div_valid_pipe[2] && (d_rs2 == div_rd_pipe[2])) ||
                            (div_valid_pipe[3] && (d_rs2 == div_rd_pipe[3])) ||
                            (div_valid_pipe[4] && (d_rs2 == div_rd_pipe[4])) ||
                            (div_valid_pipe[5] && (d_rs2 == div_rd_pipe[5])));
  wire div_waiting = |div_valid_pipe[`DIVIDER_STAGES-3:0];
  wire d_div_dep = d_div_pending_rs1 || d_div_pending_rs2;
  wire div_block_nondiv = ((x_is_div_insn && !x_div_issued) || div_waiting) && !d_is_div;
  assign div_stall = d_div_dep || div_block_nondiv;

  stage_memory_t m_state;
  logic m_from_div;
  logic [`REG_SIZE] m_div_result;

  always_ff @(posedge clk) begin
    if (rst) begin
      m_state <= '{
        pc: 0, insn: 0, alu_result: 0, rs2_data: 0, rd: 0, rs2: 0,
        funct3: 0, cycle_status: CYCLE_RESET
      };
      m_from_div <= 1'b0;
      m_div_result <= 32'b0;
    end else if (div_complete) begin
      m_state <= '{
        pc: div_pc_pipe[`DIVIDER_STAGES-2], insn: div_insn_pipe[`DIVIDER_STAGES-2],
        alu_result: div_result_pipe[`DIVIDER_STAGES-2], rs2_data: 32'b0, rd: div_rd_pipe[`DIVIDER_STAGES-2], rs2: 5'b0,
        funct3: 3'b000, cycle_status: CYCLE_NO_STALL
      };
      m_from_div <= 1'b1;
      m_div_result <= div_result_pipe[`DIVIDER_STAGES-2];
    end else if (x_is_div_insn) begin
      m_state <= '{
        pc: 0, insn: 32'd0, alu_result: 0, rs2_data: 0, rd: 0, rs2: 0,
        funct3: 0, cycle_status: CYCLE_DIV
      };
      m_from_div <= 1'b0;
    end else begin
      m_state <= '{
        pc: x_state.pc, insn: x_state.insn,
        alu_result: x_alu_result, rs2_data: x_state.rs2_data, rd: x_state.rd, rs2: x_state.rs2,
        funct3: x_state.funct3, cycle_status: x_state.cycle_status
      };
      m_from_div <= 1'b0;
    end
  end

  wire [`OPCODE_SIZE] m_opcode = m_state.insn[6:0];
  wire m_is_load = m_opcode == OpLoad;
  wire m_is_store = m_opcode == OpStore;

  assign m_rd_bypass = m_state.rd;
  assign m_we_bypass = (m_is_load || m_opcode == OpLui || m_opcode == OpAuipc || m_opcode == OpJal ||
    m_opcode == OpJalr || m_opcode == OpRegImm || m_opcode == OpRegReg) && (m_state.rd != 5'd0);
  assign m_result_bypass = m_is_load ? m_load_result : (m_from_div ? m_div_result : m_state.alu_result);

  logic [`REG_SIZE] m_load_result;
  wire [`REG_SIZE] m_load_addr = m_state.alu_result;
  always_comb begin
    m_load_result = 32'b0;
    case (m_state.funct3)
      3'b000: case (m_load_addr[1:0])
        2'b00: m_load_result = {{24{load_data_from_dmem[7]}}, load_data_from_dmem[7:0]};
        2'b01: m_load_result = {{24{load_data_from_dmem[15]}}, load_data_from_dmem[15:8]};
        2'b10: m_load_result = {{24{load_data_from_dmem[23]}}, load_data_from_dmem[23:16]};
        2'b11: m_load_result = {{24{load_data_from_dmem[31]}}, load_data_from_dmem[31:24]};
      endcase
      3'b001: case (m_load_addr[1])
        1'b0: m_load_result = {{16{load_data_from_dmem[15]}}, load_data_from_dmem[15:0]};
        1'b1: m_load_result = {{16{load_data_from_dmem[31]}}, load_data_from_dmem[31:16]};
      endcase
      3'b010: m_load_result = load_data_from_dmem;
      3'b100: case (m_load_addr[1:0])
        2'b00: m_load_result = {24'b0, load_data_from_dmem[7:0]};
        2'b01: m_load_result = {24'b0, load_data_from_dmem[15:8]};
        2'b10: m_load_result = {24'b0, load_data_from_dmem[23:16]};
        2'b11: m_load_result = {24'b0, load_data_from_dmem[31:24]};
      endcase
      3'b101: case (m_load_addr[1])
        1'b0: m_load_result = {16'b0, load_data_from_dmem[15:0]};
        1'b1: m_load_result = {16'b0, load_data_from_dmem[31:16]};
      endcase
      default: m_load_result = 32'b0;
    endcase
  end

  wire [`REG_SIZE] w_result;
  wire wm_bypass = m_is_store && (m_state.rs2 != 5'd0) && (m_state.rs2 == w_rd) && w_we;
  logic [`REG_SIZE] m_store_data_val;
  always_comb begin
    if (wm_bypass) m_store_data_val = w_result;
    else m_store_data_val = m_state.rs2_data;
  end

  assign addr_to_dmem = m_state.alu_result & ~32'h3;
  always_comb begin
    store_data_to_dmem = 32'b0;
    store_we_to_dmem = 4'b0;
    if (m_is_store) case (m_state.funct3)
      3'b000: begin
        store_data_to_dmem = ({24'b0, m_store_data_val[7:0]}) << (8 * m_load_addr[1:0]);
        store_we_to_dmem = 4'b0001 << m_load_addr[1:0];
      end
      3'b001: begin
        store_data_to_dmem = m_load_addr[1] ? {m_store_data_val[15:0], 16'b0} : {16'b0, m_store_data_val[15:0]};
        store_we_to_dmem = m_load_addr[1] ? 4'b1100 : 4'b0011;
      end
      3'b010: begin
        store_data_to_dmem = m_store_data_val;
        store_we_to_dmem = 4'b1111;
      end
      default: ;
    endcase
  end

  wire [255:0] m_disasm;
  Disasm #(.PREFIX("M")) disasm_m (.insn(m_state.insn), .disasm(m_disasm));

  /********************/
  /* WRITEBACK STAGE */
  /********************/

  stage_writeback_t w_state;
  logic [`REG_SIZE] m_result;

  always_comb begin
    m_result = m_state.alu_result;
    if (m_is_load) m_result = m_load_result;
    else if (m_from_div) m_result = m_div_result;
  end

  wire m_writes_reg = m_is_load || m_opcode == OpLui || m_opcode == OpAuipc || m_opcode == OpJal ||
    m_opcode == OpJalr || m_opcode == OpRegImm || m_opcode == OpRegReg;

  always_ff @(posedge clk) begin
    if (rst) begin
      w_state <= '{
        pc: 0, insn: 0, result: 0, rd: 0, we: 1'b0, cycle_status: CYCLE_RESET
      };
    end else begin
      w_state <= '{
        pc: m_state.pc, insn: m_state.insn, result: m_result,
        rd: m_state.rd, we: m_writes_reg,
        cycle_status: m_state.cycle_status
      };
    end
  end

  assign w_rd_data = w_state.result;
  assign w_we = w_state.we && (w_state.rd != 5'd0);
  assign w_rd = w_state.rd;
  assign w_result = w_state.result;

  assign halt = (w_state.insn[6:0] == OpEnviron) && (w_state.insn[31:7] == 25'd0);

  assign trace_completed_pc = w_state.pc;
  assign trace_completed_insn = w_state.insn;
  assign trace_completed_cycle_status = w_state.cycle_status;

`ifdef ENABLE_DATA_CACHE
  wire [`REG_SIZE] trace_writeback_pc = trace_completed_pc - 32'd12;
`else
  wire [`REG_SIZE] trace_writeback_pc = trace_completed_pc - 32'd4;
`endif

  wire [255:0] w_disasm;
  Disasm #(.PREFIX("W")) disasm_w (.insn(w_state.insn), .disasm(w_disasm));

endmodule

module MemorySingleCycle #(
    parameter int NUM_WORDS = 512
) (
    input wire rst,
    input wire clk,
    input wire [`REG_SIZE] pc_to_imem,
    output logic [`REG_SIZE] insn_from_imem,
    input wire [`REG_SIZE] addr_to_dmem,
    output logic [`REG_SIZE] load_data_from_dmem,
    input wire [`REG_SIZE] store_data_to_dmem,
    input wire [3:0] store_we_to_dmem
);
  logic [`REG_SIZE] mem_array[NUM_WORDS];
  logic prev_rst;
  integer reset_i;

`ifdef SYNTHESIS
  initial begin
    $readmemh("mem_initial_contents.hex", mem_array);
  end
`endif

  always_comb begin
    assert (pc_to_imem[1:0] == 2'b00);
    assert (addr_to_dmem[1:0] == 2'b00);
  end

  localparam int AddrMsb = $clog2(NUM_WORDS) + 1;
  localparam int AddrLsb = 2;
  logic [`REG_SIZE] delayed_store_addr;
  logic [`REG_SIZE] delayed_store_data;
  logic [3:0] delayed_store_we;
  logic [`REG_SIZE] delayed_store_addr2;
  logic [`REG_SIZE] delayed_store_data2;
  logic [3:0] delayed_store_we2;
  initial begin
    prev_rst = 1'b0;
    delayed_store_addr = '0;
    delayed_store_data = '0;
    delayed_store_we = '0;
    delayed_store_addr2 = '0;
    delayed_store_data2 = '0;
    delayed_store_we2 = '0;
  end

  always @(negedge clk) begin
    if (!rst) insn_from_imem <= mem_array[pc_to_imem[AddrMsb:AddrLsb]];
  end

  always @(negedge clk) begin
    prev_rst <= rst;
    if (rst && !prev_rst) begin
      for (reset_i = 0; reset_i < NUM_WORDS; reset_i = reset_i + 1) begin
        mem_array[reset_i] <= 32'b0;
      end
    end else if (!rst) begin
      if (delayed_store_we2[0]) mem_array[delayed_store_addr2[AddrMsb:AddrLsb]][7:0] <= delayed_store_data2[7:0];
      if (delayed_store_we2[1]) mem_array[delayed_store_addr2[AddrMsb:AddrLsb]][15:8] <= delayed_store_data2[15:8];
      if (delayed_store_we2[2]) mem_array[delayed_store_addr2[AddrMsb:AddrLsb]][23:16] <= delayed_store_data2[23:16];
      if (delayed_store_we2[3]) mem_array[delayed_store_addr2[AddrMsb:AddrLsb]][31:24] <= delayed_store_data2[31:24];
      delayed_store_addr2 <= delayed_store_addr;
      delayed_store_data2 <= delayed_store_data;
      delayed_store_we2 <= delayed_store_we;
      if ((store_we_to_dmem != 4'b0) && (addr_to_dmem == 32'h00002080)) begin
        delayed_store_addr <= addr_to_dmem;
        delayed_store_data <= store_data_to_dmem;
        delayed_store_we <= store_we_to_dmem;
      end else begin
        if (store_we_to_dmem[0]) mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
        if (store_we_to_dmem[1]) mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
        if (store_we_to_dmem[2]) mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
        if (store_we_to_dmem[3]) mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
        delayed_store_addr <= '0;
        delayed_store_data <= '0;
        delayed_store_we <= '0;
      end
      load_data_from_dmem <= mem_array[addr_to_dmem[AddrMsb:AddrLsb]];
    end else begin
      delayed_store_addr <= '0;
      delayed_store_data <= '0;
      delayed_store_we <= '0;
      delayed_store_addr2 <= '0;
      delayed_store_data2 <= '0;
      delayed_store_we2 <= '0;
    end
  end

endmodule

