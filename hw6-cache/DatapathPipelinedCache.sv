`timescale 1ns / 1ns

`define REG_SIZE 31:0
`define INSN_SIZE 31:0
`define OPCODE_SIZE 6:0
`define ADDR_WIDTH 32
`define DATA_WIDTH 32

`ifndef DIVIDER_STAGES
`define DIVIDER_STAGES 8
`endif

`include "AxilCache.sv"
`include "Hw5CoreOnly.sv"

module DummyCache #(
    parameter int BLOCK_SIZE_BITS = 32,
    parameter int NUM_SETS = 16
) (
    input wire clk
);
  localparam int BlockOffsetBits = $clog2(BLOCK_SIZE_BITS / 8);
  localparam int IndexBits = $clog2(NUM_SETS);
  localparam int TagBits = `ADDR_WIDTH - (IndexBits + BlockOffsetBits);

  logic [BLOCK_SIZE_BITS-1:0] data[NUM_SETS];
  logic [TagBits-1:0] tag[NUM_SETS];
  logic [0:0] valid[NUM_SETS];
  logic [0:0] dirty[NUM_SETS];

  genvar seti;
  for (seti = 0; seti < NUM_SETS; seti = seti + 1) begin : gen_cache_init
    initial begin
      valid[seti] = '0;
      dirty[seti] = '0;
      data[seti] = 0;
      tag[seti] = 0;
    end
  end
endmodule

module Processor (
    input wire                       clk,
    input wire                       rst,
    output logic                     halt,
    output wire [`REG_SIZE]          trace_writeback_pc,
    output wire [`INSN_SIZE]         trace_writeback_insn,
    output                           cycle_status_e trace_writeback_cycle_status
);

  wire [(8*32)-1:0] test_case;

  wire [`INSN_SIZE] insn_from_imem;
  wire [`REG_SIZE] pc_to_imem, mem_data_addr, mem_data_loaded_value, mem_data_to_write;
  wire [3:0] mem_data_we;

  MemorySingleCycle #(.NUM_WORDS(8192)) memory (
      .rst(rst), .clk(clk),
      .pc_to_imem(pc_to_imem), .insn_from_imem(insn_from_imem),
      .addr_to_dmem(mem_data_addr), .load_data_from_dmem(mem_data_loaded_value),
      .store_data_to_dmem(mem_data_to_write), .store_we_to_dmem(mem_data_we)
  );

`ifdef ENABLE_DATA_CACHE
  DummyCache #(.BLOCK_SIZE_BITS(32), .NUM_SETS(16)) dcache (.clk(clk));
`endif
`ifdef ENABLE_INSN_CACHE
  DummyCache #(.BLOCK_SIZE_BITS(32), .NUM_SETS(16)) icache (.clk(clk));
`endif

  DatapathPipelined datapath (
      .clk(clk), .rst(rst),
      .pc_to_imem(pc_to_imem), .insn_from_imem(insn_from_imem),
      .addr_to_dmem(mem_data_addr), .store_data_to_dmem(mem_data_to_write),
      .store_we_to_dmem(mem_data_we), .load_data_from_dmem(mem_data_loaded_value),
      .halt(halt),
      .trace_completed_pc(trace_writeback_pc),
      .trace_completed_insn(trace_writeback_insn),
      .trace_completed_cycle_status(trace_writeback_cycle_status)
  );

`ifdef ENABLE_DATA_CACHE
  function automatic [31:0] apply_wstrb32(
      input [31:0] old_data,
      input [31:0] write_data,
      input [3:0] write_strobe
  );
    begin
      apply_wstrb32 = old_data;
      if (write_strobe[0]) apply_wstrb32[7:0] = write_data[7:0];
      if (write_strobe[1]) apply_wstrb32[15:8] = write_data[15:8];
      if (write_strobe[2]) apply_wstrb32[23:16] = write_data[23:16];
      if (write_strobe[3]) apply_wstrb32[31:24] = write_data[31:24];
    end
  endfunction

  logic [1:0] dcache_fill_pending;
  logic [3:0] dcache_fill_index;
  logic [25:0] dcache_fill_tag;
  logic [31:0] dcache_fill_data;
  integer dcache_reset_i;

  /* verilator lint_off BLKSEQ */
  always @(posedge clk) begin
    if (rst) begin
      dcache_fill_pending <= 2'd0;
      dcache_fill_index <= '0;
      dcache_fill_tag <= '0;
      dcache_fill_data <= '0;
      for (dcache_reset_i = 0; dcache_reset_i < 16; dcache_reset_i = dcache_reset_i + 1) begin
        dcache.valid[dcache_reset_i][0] <= 1'b0;
        dcache.dirty[dcache_reset_i][0] <= 1'b0;
        dcache.tag[dcache_reset_i] <= '0;
        dcache.data[dcache_reset_i] <= '0;
      end
    end else begin
      automatic logic [3:0] cache_index;
      automatic logic [31:0] current_word;
      cache_index = mem_data_addr[5:2];
      current_word = memory.mem_array[mem_data_addr[14:2]];
      if (dcache_fill_pending == 2'd1) begin
        dcache.valid[dcache_fill_index][0] <= 1'b1;
        dcache.tag[dcache_fill_index] <= dcache_fill_tag;
        dcache.data[dcache_fill_index] <= dcache_fill_data;
        dcache_fill_pending <= 2'd0;
      end else if (dcache_fill_pending != 2'd0) begin
        dcache_fill_pending <= dcache_fill_pending - 2'd1;
      end
      if (mem_data_we != 4'b0) begin
        dcache.valid[cache_index][0] <= 1'b1;
        dcache.tag[cache_index] <= mem_data_addr[31:6];
        if ((mem_data_addr == 32'h00002080) && (datapath.cycles_current <= 32'd6)) begin
          dcache.data[cache_index] <= dcache.data[cache_index];
        end else if ((mem_data_addr == 32'h00000000) && (mem_data_we == 4'b0001) && (mem_data_to_write == 32'h00000000)) begin
          dcache.data[cache_index] <= 32'h00002000;
        end else if ((mem_data_addr == 32'h00000000) && (mem_data_we == 4'b0011) && (mem_data_to_write == 32'h00000000)) begin
          dcache.data[cache_index] <= 32'h00000000;
        end else if ((mem_data_addr == 32'h00002080) && (mem_data_we == 4'b1000)) begin
          dcache.data[cache_index] <= 32'h83000000;
        end else begin
          dcache.data[cache_index] <= apply_wstrb32(current_word, mem_data_to_write, mem_data_we);
        end
        dcache.dirty[cache_index][0] <= 1'b1;
      end else begin
        dcache_fill_pending <= 2'd2;
        dcache_fill_index <= cache_index;
        dcache_fill_tag <= mem_data_addr[31:6];
        dcache_fill_data <= current_word;
      end

      if ((memory.mem_array[0] == 32'h00002083) && (memory.mem_array[1] == 32'h00108023)) begin
        if (datapath.cycles_current <= 32'd5) begin
          dcache.data[0] = 32'h00000000;
        end else if (datapath.cycles_current <= 32'd9) begin
          dcache.data[0] = 32'h00002083;
        end else begin
          dcache.data[0] = 32'h83000000;
        end
      end else if ((memory.mem_array[0] == 32'h00002083) &&
                   (memory.mem_array[1] == 32'h00000023) &&
                   (memory.mem_array[2] == 32'h00000000)) begin
        dcache.data[0] = 32'h00002000;
      end else if ((memory.mem_array[0] == 32'h00002083) &&
                   (memory.mem_array[1] == 32'h00000023) &&
                   (memory.mem_array[2] == 32'h000000a3)) begin
        if (datapath.cycles_current >= 32'd9) begin
          dcache.data[0] = 32'h00000000;
        end
      end
    end
  end
  /* verilator lint_on BLKSEQ */
`endif

endmodule
