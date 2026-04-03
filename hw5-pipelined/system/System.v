module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "20" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
		.PLLRST_ENA("DISABLED"),
		.INTFB_WAKE("DISABLED"),
		.STDBY_ENABLE("DISABLED"),
		.DPHASE_SOURCE("DISABLED"),
		.OUTDIVIDER_MUXA("DIVA"),
		.OUTDIVIDER_MUXB("DIVB"),
		.OUTDIVIDER_MUXC("DIVC"),
		.OUTDIVIDER_MUXD("DIVD"),
		.CLKI_DIV(5),
		.CLKOP_ENABLE("ENABLED"),
		.CLKOP_DIV(30),
		.CLKOP_CPHASE(15),
		.CLKOP_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(4)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
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
module divider_4iter (
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
	wire [31:0] d1;
	wire [31:0] d2;
	wire [31:0] d3;
	wire [31:0] r1;
	wire [31:0] r2;
	wire [31:0] r3;
	wire [31:0] q1;
	wire [31:0] q2;
	wire [31:0] q3;
	divu_1iter it0(
		.i_dividend(i_dividend),
		.i_divisor(i_divisor),
		.i_remainder(i_remainder),
		.i_quotient(i_quotient),
		.o_dividend(d1),
		.o_remainder(r1),
		.o_quotient(q1)
	);
	divu_1iter it1(
		.i_dividend(d1),
		.i_divisor(i_divisor),
		.i_remainder(r1),
		.i_quotient(q1),
		.o_dividend(d2),
		.o_remainder(r2),
		.o_quotient(q2)
	);
	divu_1iter it2(
		.i_dividend(d2),
		.i_divisor(i_divisor),
		.i_remainder(r2),
		.i_quotient(q2),
		.o_dividend(d3),
		.o_remainder(r3),
		.o_quotient(q3)
	);
	divu_1iter it3(
		.i_dividend(d3),
		.i_divisor(i_divisor),
		.i_remainder(r3),
		.i_quotient(q3),
		.o_dividend(o_dividend),
		.o_remainder(o_remainder),
		.o_quotient(o_quotient)
	);
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
	reg [31:0] p_div [0:6];
	reg [31:0] p_rem [0:6];
	reg [31:0] p_quot [0:6];
	reg [31:0] p_dvsr [0:6];
	wire [31:0] s0_do;
	wire [31:0] s0_ro;
	wire [31:0] s0_qo;
	divider_4iter stg0(
		.i_dividend(i_dividend),
		.i_divisor(i_divisor),
		.i_remainder(32'b00000000000000000000000000000000),
		.i_quotient(32'b00000000000000000000000000000000),
		.o_dividend(s0_do),
		.o_remainder(s0_ro),
		.o_quotient(s0_qo)
	);
	always @(posedge clk)
		if (rst) begin
			p_div[0] <= 0;
			p_rem[0] <= 0;
			p_quot[0] <= 0;
			p_dvsr[0] <= 0;
		end
		else begin
			p_div[0] <= s0_do;
			p_rem[0] <= s0_ro;
			p_quot[0] <= s0_qo;
			p_dvsr[0] <= i_divisor;
		end
	genvar _gv_s_1;
	generate
		for (_gv_s_1 = 1; _gv_s_1 < 7; _gv_s_1 = _gv_s_1 + 1) begin : mid_stage
			localparam s = _gv_s_1;
			wire [31:0] sd_o;
			wire [31:0] sr_o;
			wire [31:0] sq_o;
			divider_4iter u(
				.i_dividend(p_div[s - 1]),
				.i_divisor(p_dvsr[s - 1]),
				.i_remainder(p_rem[s - 1]),
				.i_quotient(p_quot[s - 1]),
				.o_dividend(sd_o),
				.o_remainder(sr_o),
				.o_quotient(sq_o)
			);
			always @(posedge clk)
				if (rst) begin
					p_div[s] <= 0;
					p_rem[s] <= 0;
					p_quot[s] <= 0;
					p_dvsr[s] <= 0;
				end
				else begin
					p_div[s] <= sd_o;
					p_rem[s] <= sr_o;
					p_quot[s] <= sq_o;
					p_dvsr[s] <= p_dvsr[s - 1];
				end
		end
	endgenerate
	wire [31:0] s7_do;
	wire [31:0] s7_ro;
	wire [31:0] s7_qo;
	divider_4iter stg7(
		.i_dividend(p_div[6]),
		.i_divisor(p_dvsr[6]),
		.i_remainder(p_rem[6]),
		.i_quotient(p_quot[6]),
		.o_dividend(s7_do),
		.o_remainder(s7_ro),
		.o_quotient(s7_qo)
	);
	assign o_quotient = s7_qo;
	assign o_remainder = s7_ro;
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
	reg _sv2v_0;
	input wire [31:0] i_dividend;
	input wire [31:0] i_divisor;
	input wire [31:0] i_remainder;
	input wire [31:0] i_quotient;
	output wire [31:0] o_dividend;
	output reg [31:0] o_remainder;
	output reg [31:0] o_quotient;
	wire [31:0] r_cmp;
	wire [31:0] r_sub;
	wire lt;
	assign r_cmp = (i_remainder << 1) | {{31 {1'b0}}, i_dividend[31]};
	assign o_dividend = i_dividend << 1;
	assign r_sub = r_cmp - i_divisor;
	assign lt = r_cmp < i_divisor;
	always @(*) begin
		if (_sv2v_0)
			;
		if (lt) begin
			o_remainder = r_cmp;
			o_quotient = i_quotient << 1;
		end
		else begin
			o_remainder = r_sub;
			o_quotient = (i_quotient << 1) | 32'b00000000000000000000000000000001;
		end
	end
	initial _sv2v_0 = 0;
endmodule
module Disasm (
	insn,
	disasm
);
	parameter signed [7:0] PREFIX = "D";
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
	always @(posedge clk) begin : sv2v_autoblock_1
		integer i;
		if (rst)
			for (i = 0; i < NumRegs; i = i + 1)
				regs[i] <= 32'b00000000000000000000000000000000;
		else if (we && (rd != 5'd0))
			regs[rd] <= rd_data;
	end
	assign rs1_data = (rs1 == 5'd0 ? 32'b00000000000000000000000000000000 : regs[rs1]);
	assign rs2_data = (rs2 == 5'd0 ? 32'b00000000000000000000000000000000 : regs[rs2]);
endmodule
module DatapathPipelined (
	clk,
	rst,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	halt,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output wire [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output reg [31:0] store_data_to_dmem;
	output reg [3:0] store_we_to_dmem;
	output wire halt;
	output wire [31:0] trace_completed_pc;
	output wire [31:0] trace_completed_insn;
	output wire [31:0] trace_completed_cycle_status;
	function automatic [31:0] arshift_right32;
		input [31:0] val;
		input [4:0] shamt;
		if (shamt == 5'd0)
			arshift_right32 = val;
		else
			arshift_right32 = (val >> shamt) | ({32 {val[31]}} << (32 - shamt));
	endfunction
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
	reg [31:0] f_pc;
	wire [31:0] f_insn = insn_from_imem;
	reg [31:0] f_cycle_status;
	wire load_use_stall;
	wire div_stall;
	wire branch_taken;
	wire [31:0] branch_target;
	always @(posedge clk)
		if (rst) begin
			f_pc <= 32'd0;
			f_cycle_status <= 32'd1;
		end
		else begin
			f_cycle_status <= 32'd1;
			if (branch_taken)
				f_pc <= branch_target;
			else if (load_use_stall || div_stall)
				f_pc <= f_pc;
			else
				f_pc <= f_pc + 4;
		end
	assign pc_to_imem = f_pc;
	wire [255:0] f_disasm;
	Disasm #(.PREFIX("F")) disasm_f(
		.insn(f_insn),
		.disasm(f_disasm)
	);
	reg [95:0] d_state;
	wire load_use_stall_next = load_use_stall;
	always @(posedge clk)
		if (rst)
			d_state <= 96'h000000000000000000000004;
		else if (branch_taken)
			d_state <= 96'h000000000000000000000008;
		else if (load_use_stall || div_stall)
			d_state <= (div_stall ? 96'h000000000000000000000002 : d_state);
		else
			d_state <= {f_pc, f_insn, f_cycle_status};
	wire [6:0] d_funct7;
	wire [4:0] d_rs2;
	wire [4:0] d_rs1;
	wire [2:0] d_funct3;
	wire [4:0] d_rd;
	wire [6:0] d_opcode;
	assign {d_funct7, d_rs2, d_rs1, d_funct3, d_rd, d_opcode} = d_state[63-:32];
	wire [11:0] d_imm_i = d_state[63:52];
	wire [11:0] d_imm_s;
	assign d_imm_s[11:5] = d_funct7;
	assign d_imm_s[4:0] = d_rd;
	wire [12:0] d_imm_b;
	assign {d_imm_b[12], d_imm_b[10:5]} = d_funct7;
	assign {d_imm_b[4:1], d_imm_b[11]} = d_rd;
	assign d_imm_b[0] = 1'b0;
	wire [20:0] d_imm_j;
	assign {d_imm_j[20], d_imm_j[10:1], d_imm_j[11], d_imm_j[19:12], d_imm_j[0]} = {d_state[63:44], 1'b0};
	wire [31:0] d_imm_i_sext = {{20 {d_imm_i[11]}}, d_imm_i};
	wire [31:0] d_imm_s_sext = {{20 {d_imm_s[11]}}, d_imm_s};
	wire [31:0] d_imm_b_sext = {{19 {d_imm_b[12]}}, d_imm_b};
	wire [31:0] d_imm_j_sext = {{11 {d_imm_j[20]}}, d_imm_j};
	wire d_is_load = d_opcode == OpLoad;
	wire d_is_store = d_opcode == OpStore;
	wire d_uses_rs1 = (d_opcode != OpLui) && (d_opcode != OpJal);
	wire d_uses_rs2 = ((d_opcode == OpStore) || (d_opcode == OpBranch)) || (d_opcode == OpRegReg);
	wire [31:0] w_rd_data;
	wire w_we;
	wire [4:0] w_rd;
	wire [31:0] x_alu_result;
	wire x_we;
	wire [4:0] x_rd;
	wire x_is_load;
	wire [31:0] m_result_bypass;
	wire m_we_bypass;
	wire [4:0] m_rd_bypass;
	wire [31:0] rf_rs1_data;
	wire [31:0] rf_rs2_data;
	RegFile rf(
		.clk(clk),
		.rst(rst),
		.we(w_we),
		.rd(w_rd),
		.rd_data(w_rd_data),
		.rs1(d_rs1),
		.rs2(d_rs2),
		.rs1_data(rf_rs1_data),
		.rs2_data(rf_rs2_data)
	);
	wire wd_rs1 = ((d_rs1 != 5'd0) && (d_rs1 == w_rd)) && w_we;
	wire wd_rs2 = ((d_rs2 != 5'd0) && (d_rs2 == w_rd)) && w_we;
	wire m_rs1 = ((d_rs1 != 5'd0) && (d_rs1 == m_rd_bypass)) && m_we_bypass;
	wire m_rs2 = ((d_rs2 != 5'd0) && (d_rs2 == m_rd_bypass)) && m_we_bypass;
	wire x_rs1 = ((d_rs1 != 5'd0) && (d_rs1 == x_rd)) && x_we;
	wire x_rs2 = ((d_rs2 != 5'd0) && (d_rs2 == x_rd)) && x_we;
	reg [31:0] d_rs1_data;
	reg [31:0] d_rs2_data;
	always @(*) begin
		if (_sv2v_0)
			;
		if (x_rs1)
			d_rs1_data = x_alu_result;
		else if (m_rs1)
			d_rs1_data = m_result_bypass;
		else if (wd_rs1)
			d_rs1_data = w_rd_data;
		else
			d_rs1_data = rf_rs1_data;
		if (x_rs2)
			d_rs2_data = x_alu_result;
		else if (m_rs2)
			d_rs2_data = m_result_bypass;
		else if (wd_rs2)
			d_rs2_data = w_rd_data;
		else
			d_rs2_data = rf_rs2_data;
	end
	reg [312:0] x_state;
	wire x_is_load_val = (x_state[255:249] == OpLoad) && (x_state[280-:32] != 32'd0);
	wire load_use_rs1 = (d_uses_rs1 && (d_rs1 != 5'd0)) && (d_rs1 == x_rd);
	wire load_use_rs2 = (d_uses_rs2 && (d_rs2 != 5'd0)) && (d_rs2 == x_rd);
	assign load_use_stall = x_is_load_val && (load_use_rs1 || load_use_rs2);
	wire [255:0] d_disasm;
	Disasm #(.PREFIX("D")) disasm_d(
		.insn(d_state[63-:32]),
		.disasm(d_disasm)
	);
	wire x_bubble = load_use_stall || branch_taken;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(posedge clk)
		if (rst)
			x_state <= 313'h4;
		else if (branch_taken)
			x_state <= 313'h8;
		else if (load_use_stall)
			x_state <= 313'h10;
		else if (div_stall)
			x_state <= x_state;
		else
			x_state <= {sv2v_cast_32(d_state[95-:32]), sv2v_cast_32(d_state[63-:32]), d_rs1_data, d_rs2_data, d_rd, d_rs1, d_rs2, d_imm_i_sext, d_imm_s_sext, d_imm_b_sext, d_imm_j_sext, d_funct3, d_funct7, sv2v_cast_32(d_state[31-:32])};
	wire [6:0] x_opcode = x_state[255:249];
	wire x_insn_lui = x_opcode == OpLui;
	wire x_insn_auipc = x_opcode == OpAuipc;
	wire x_insn_jal = x_opcode == OpJal;
	wire x_insn_jalr = x_opcode == OpJalr;
	wire x_insn_beq = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b000);
	wire x_insn_bne = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b001);
	wire x_insn_blt = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b100);
	wire x_insn_bge = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b101);
	wire x_insn_bltu = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b110);
	wire x_insn_bgeu = (x_opcode == OpBranch) && (x_state[41-:3] == 3'b111);
	reg [31:0] x_alu_result_inner;
	reg branch_taken_inner;
	reg [31:0] branch_target_inner;
	always @(*) begin
		if (_sv2v_0)
			;
		x_alu_result_inner = 32'b00000000000000000000000000000000;
		branch_taken_inner = 1'b0;
		branch_target_inner = x_state[312-:32] + x_state[105-:32];
		if (x_state[280-:32] == 32'd0)
			branch_taken_inner = 1'b0;
		else
			case (x_opcode)
				OpLui: x_alu_result_inner = {x_state[280:261], 12'b000000000000};
				OpAuipc: x_alu_result_inner = x_state[312-:32] + {x_state[280:261], 12'b000000000000};
				OpJal: begin
					x_alu_result_inner = x_state[312-:32] + 4;
					branch_taken_inner = 1'b1;
					branch_target_inner = x_state[312-:32] + x_state[73-:32];
				end
				OpJalr: begin
					x_alu_result_inner = x_state[312-:32] + 4;
					branch_taken_inner = 1'b1;
					branch_target_inner = (x_state[248-:32] + x_state[169-:32]) & ~32'd1;
				end
				OpRegImm:
					case (x_state[41-:3])
						3'b000: x_alu_result_inner = x_state[248-:32] + x_state[169-:32];
						3'b010: x_alu_result_inner = ($signed(x_state[248-:32]) < $signed(x_state[169-:32]) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						3'b011: x_alu_result_inner = (x_state[248-:32] < x_state[169-:32] ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						3'b100: x_alu_result_inner = x_state[248-:32] ^ x_state[169-:32];
						3'b110: x_alu_result_inner = x_state[248-:32] | x_state[169-:32];
						3'b111: x_alu_result_inner = x_state[248-:32] & x_state[169-:32];
						3'b001: x_alu_result_inner = x_state[248-:32] << x_state[142:138];
						3'b101: x_alu_result_inner = (x_state[38-:7] == 7'b0100000 ? arshift_right32(x_state[248-:32], x_state[142:138]) : x_state[248-:32] >> x_state[142:138]);
						default: x_alu_result_inner = 32'b00000000000000000000000000000000;
					endcase
				OpRegReg:
					case (x_state[41-:3])
						3'b000: x_alu_result_inner = (x_state[37] ? x_state[248-:32] + (~x_state[216-:32] + 32'd1) : x_state[248-:32] + x_state[216-:32]);
						3'b001: x_alu_result_inner = x_state[248-:32] << x_state[189:185];
						3'b010: x_alu_result_inner = ($signed(x_state[248-:32]) < $signed(x_state[216-:32]) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						3'b011: x_alu_result_inner = (x_state[248-:32] < x_state[216-:32] ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						3'b100: x_alu_result_inner = x_state[248-:32] ^ x_state[216-:32];
						3'b101: x_alu_result_inner = (x_state[38-:7] == 7'b0100000 ? arshift_right32(x_state[248-:32], x_state[189:185]) : x_state[248-:32] >> x_state[189:185]);
						3'b110: x_alu_result_inner = x_state[248-:32] | x_state[216-:32];
						3'b111: x_alu_result_inner = x_state[248-:32] & x_state[216-:32];
						default: x_alu_result_inner = 32'b00000000000000000000000000000000;
					endcase
				OpBranch:
					case (x_state[41-:3])
						3'b000: branch_taken_inner = x_state[248-:32] == x_state[216-:32];
						3'b001: branch_taken_inner = x_state[248-:32] != x_state[216-:32];
						3'b100: branch_taken_inner = $signed(x_state[248-:32]) < $signed(x_state[216-:32]);
						3'b101: branch_taken_inner = $signed(x_state[248-:32]) >= $signed(x_state[216-:32]);
						3'b110: branch_taken_inner = x_state[248-:32] < x_state[216-:32];
						3'b111: branch_taken_inner = x_state[248-:32] >= x_state[216-:32];
						default: branch_taken_inner = 1'b0;
					endcase
				OpLoad: x_alu_result_inner = x_state[248-:32] + x_state[169-:32];
				OpStore: x_alu_result_inner = x_state[248-:32] + x_state[137-:32];
				default: x_alu_result_inner = 32'b00000000000000000000000000000000;
			endcase
	end
	wire x_is_mul = (x_opcode == OpRegReg) && (x_state[38-:7] == 7'd1);
	reg signed [63:0] mul_prod;
	reg [31:0] x_mul_result;
	always @(*) begin
		if (_sv2v_0)
			;
		mul_prod = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		x_mul_result = 32'b00000000000000000000000000000000;
		if (x_is_mul)
			case (x_state[41-:3])
				3'b000: x_mul_result = x_state[248-:32] * x_state[216-:32];
				3'b001: begin
					mul_prod = $signed({{32 {x_state[248]}}, x_state[248-:32]}) * $signed({{32 {x_state[216]}}, x_state[216-:32]});
					x_mul_result = mul_prod[63:32];
				end
				3'b010: begin
					mul_prod = $signed({{32 {x_state[248]}}, x_state[248-:32]}) * {32'b00000000000000000000000000000000, x_state[216-:32]};
					x_mul_result = mul_prod[63:32];
				end
				3'b011: begin
					mul_prod = {32'b00000000000000000000000000000000, x_state[248-:32]} * {32'b00000000000000000000000000000000, x_state[216-:32]};
					x_mul_result = mul_prod[63:32];
				end
				default: x_mul_result = 32'b00000000000000000000000000000000;
			endcase
	end
	wire x_is_div_insn = ((x_opcode == OpRegReg) && (x_state[38-:7] == 7'd1)) && ((((x_state[41-:3] == 3'b100) || (x_state[41-:3] == 3'b101)) || (x_state[41-:3] == 3'b110)) || (x_state[41-:3] == 3'b111));
	wire div_rem_signed = x_is_div_insn && ((x_state[41-:3] == 3'b100) || (x_state[41-:3] == 3'b110));
	wire [31:0] div_dividend = (div_rem_signed && x_state[248] ? ~x_state[248-:32] + 32'd1 : x_state[248-:32]);
	wire [31:0] div_divisor = (div_rem_signed && x_state[216] ? ~x_state[216-:32] + 32'd1 : x_state[216-:32]);
	wire [31:0] div_quotient;
	wire [31:0] div_remainder;
	DividerUnsignedPipelined div_inst(
		.clk(clk),
		.rst(rst),
		.stall(1'b0),
		.i_dividend(div_dividend),
		.i_divisor(div_divisor),
		.o_quotient(div_quotient),
		.o_remainder(div_remainder)
	);
	reg [31:0] x_div_result;
	always @(*) begin
		if (_sv2v_0)
			;
		x_div_result = 32'b00000000000000000000000000000000;
		if (x_is_div_insn)
			case (x_state[41-:3])
				3'b100: x_div_result = (x_state[216-:32] == 32'b00000000000000000000000000000000 ? 32'hffffffff : (x_state[248] ^ x_state[216] ? ~div_quotient + 32'd1 : div_quotient));
				3'b101: x_div_result = (x_state[216-:32] == 32'b00000000000000000000000000000000 ? 32'hffffffff : div_quotient);
				3'b110: x_div_result = (x_state[216-:32] == 32'b00000000000000000000000000000000 ? x_state[248-:32] : (x_state[248] ? ~div_remainder + 32'd1 : div_remainder));
				3'b111: x_div_result = (x_state[216-:32] == 32'b00000000000000000000000000000000 ? x_state[248-:32] : div_remainder);
				default: x_div_result = 32'b00000000000000000000000000000000;
			endcase
	end
	wire x_we_inner = (((((((x_opcode == OpLui) || (x_opcode == OpAuipc)) || (x_opcode == OpJal)) || (x_opcode == OpJalr)) || (x_opcode == OpRegImm)) || (x_opcode == OpRegReg)) || (x_opcode == OpLoad)) && (x_state[184-:5] != 5'd0);
	wire x_result_from_mul = x_is_mul;
	wire x_result_from_div = x_is_div_insn;
	assign x_alu_result = (x_result_from_mul ? x_mul_result : (x_result_from_div ? x_div_result : x_alu_result_inner));
	assign branch_taken = branch_taken_inner && (x_state[280-:32] != 32'd0);
	assign branch_target = branch_target_inner;
	assign x_we = x_we_inner && !x_is_div_insn;
	assign x_rd = x_state[184-:5];
	assign x_is_load = x_opcode == OpLoad;
	wire [255:0] x_disasm;
	Disasm #(.PREFIX("X")) disasm_x(
		.insn(x_state[280-:32]),
		.disasm(x_disasm)
	);
	reg [3:0] div_stage_count;
	wire div_complete;
	wire div_entering = (x_is_div_insn && (x_state[280-:32] != 32'd0)) && (div_stage_count == 4'd0);
	always @(posedge clk)
		if (rst)
			div_stage_count <= 4'd0;
		else if (div_entering)
			div_stage_count <= 4'd1;
		else if ((div_stage_count > 4'd0) && (div_stage_count < 8))
			div_stage_count <= div_stage_count + 4'd1;
		else if (div_stage_count == 8)
			div_stage_count <= 4'd0;
	wire div_in_progress = div_stage_count > 4'd0;
	assign div_complete = div_stage_count == 8;
	assign div_stall = div_entering || (div_in_progress && !div_complete);
	reg [172:0] m_state;
	reg m_from_div;
	reg [31:0] m_div_result;
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			m_state <= 173'h00000000000000000000000000000000000000000004;
			m_from_div <= 1'b0;
			m_div_result <= 32'b00000000000000000000000000000000;
		end
		else if (div_complete) begin
			m_state <= {sv2v_cast_32(x_state[312-:32]), sv2v_cast_32(x_state[280-:32]), x_div_result, sv2v_cast_32(x_state[216-:32]), sv2v_cast_5(x_state[184-:5]), sv2v_cast_5(x_state[174-:5]), sv2v_cast_3(x_state[41-:3]), 32'd1};
			m_from_div <= 1'b1;
			m_div_result <= x_div_result;
		end
		else if (div_in_progress) begin
			m_state <= 173'h00000000000000000000000000000000000000000002;
			m_from_div <= 1'b0;
		end
		else begin
			m_state <= {sv2v_cast_32(x_state[312-:32]), sv2v_cast_32(x_state[280-:32]), x_alu_result, sv2v_cast_32(x_state[216-:32]), sv2v_cast_5(x_state[184-:5]), sv2v_cast_5(x_state[174-:5]), sv2v_cast_3(x_state[41-:3]), sv2v_cast_32(x_state[31-:32])};
			m_from_div <= 1'b0;
		end
	wire [6:0] m_opcode = m_state[115:109];
	wire m_is_load = m_opcode == OpLoad;
	wire m_is_store = m_opcode == OpStore;
	assign m_rd_bypass = m_state[44-:5];
	assign m_we_bypass = ((((((m_is_load || (m_opcode == OpLui)) || (m_opcode == OpAuipc)) || (m_opcode == OpJal)) || (m_opcode == OpJalr)) || (m_opcode == OpRegImm)) || (m_opcode == OpRegReg)) && (m_state[44-:5] != 5'd0);
	reg [31:0] m_load_result;
	assign m_result_bypass = (m_is_load ? m_load_result : (m_from_div ? m_div_result : m_state[108-:32]));
	wire [31:0] m_load_addr = m_state[108-:32];
	always @(*) begin
		if (_sv2v_0)
			;
		m_load_result = 32'b00000000000000000000000000000000;
		case (m_state[34-:3])
			3'b000:
				case (m_load_addr[1:0])
					2'b00: m_load_result = {{24 {load_data_from_dmem[7]}}, load_data_from_dmem[7:0]};
					2'b01: m_load_result = {{24 {load_data_from_dmem[15]}}, load_data_from_dmem[15:8]};
					2'b10: m_load_result = {{24 {load_data_from_dmem[23]}}, load_data_from_dmem[23:16]};
					2'b11: m_load_result = {{24 {load_data_from_dmem[31]}}, load_data_from_dmem[31:24]};
				endcase
			3'b001:
				case (m_load_addr[1])
					1'b0: m_load_result = {{16 {load_data_from_dmem[15]}}, load_data_from_dmem[15:0]};
					1'b1: m_load_result = {{16 {load_data_from_dmem[31]}}, load_data_from_dmem[31:16]};
				endcase
			3'b010: m_load_result = load_data_from_dmem;
			3'b100:
				case (m_load_addr[1:0])
					2'b00: m_load_result = {24'b000000000000000000000000, load_data_from_dmem[7:0]};
					2'b01: m_load_result = {24'b000000000000000000000000, load_data_from_dmem[15:8]};
					2'b10: m_load_result = {24'b000000000000000000000000, load_data_from_dmem[23:16]};
					2'b11: m_load_result = {24'b000000000000000000000000, load_data_from_dmem[31:24]};
				endcase
			3'b101:
				case (m_load_addr[1])
					1'b0: m_load_result = {16'b0000000000000000, load_data_from_dmem[15:0]};
					1'b1: m_load_result = {16'b0000000000000000, load_data_from_dmem[31:16]};
				endcase
			default: m_load_result = 32'b00000000000000000000000000000000;
		endcase
	end
	wire [31:0] w_result;
	wire wm_bypass = ((m_is_store && (m_state[39-:5] != 5'd0)) && (m_state[39-:5] == w_rd)) && w_we;
	reg [31:0] m_store_data_val;
	always @(*) begin
		if (_sv2v_0)
			;
		if (wm_bypass)
			m_store_data_val = w_result;
		else
			m_store_data_val = m_state[76-:32];
	end
	assign addr_to_dmem = m_state[108-:32] & ~32'h00000003;
	always @(*) begin
		if (_sv2v_0)
			;
		store_data_to_dmem = 32'b00000000000000000000000000000000;
		store_we_to_dmem = 4'b0000;
		if (m_is_store)
			case (m_state[34-:3])
				3'b000: begin
					store_data_to_dmem = {24'b000000000000000000000000, m_store_data_val[7:0]} << (8 * m_load_addr[1:0]);
					store_we_to_dmem = 4'b0001 << m_load_addr[1:0];
				end
				3'b001: begin
					store_data_to_dmem = (m_load_addr[1] ? {m_store_data_val[15:0], 16'b0000000000000000} : {16'b0000000000000000, m_store_data_val[15:0]});
					store_we_to_dmem = (m_load_addr[1] ? 4'b1100 : 4'b0011);
				end
				3'b010: begin
					store_data_to_dmem = m_store_data_val;
					store_we_to_dmem = 4'b1111;
				end
				default:
					;
			endcase
	end
	wire [255:0] m_disasm;
	Disasm #(.PREFIX("M")) disasm_m(
		.insn(m_state[140-:32]),
		.disasm(m_disasm)
	);
	reg [133:0] w_state;
	reg [31:0] m_result;
	always @(*) begin
		if (_sv2v_0)
			;
		m_result = m_state[108-:32];
		if (m_is_load)
			m_result = m_load_result;
		else if (m_from_div)
			m_result = m_div_result;
	end
	wire m_writes_reg = (((((m_is_load || (m_opcode == OpLui)) || (m_opcode == OpAuipc)) || (m_opcode == OpJal)) || (m_opcode == OpJalr)) || (m_opcode == OpRegImm)) || (m_opcode == OpRegReg);
	always @(posedge clk)
		if (rst)
			w_state <= 134'h0000000000000000000000000000000004;
		else
			w_state <= {sv2v_cast_32(m_state[172-:32]), sv2v_cast_32(m_state[140-:32]), m_result, sv2v_cast_5(m_state[44-:5]), m_writes_reg, sv2v_cast_32(m_state[31-:32])};
	assign w_rd_data = w_state[69-:32];
	assign w_we = w_state[32] && (w_state[37-:5] != 5'd0);
	assign w_rd = w_state[37-:5];
	assign w_result = w_state[69-:32];
	assign halt = (w_state[76:70] == OpEnviron) && (w_state[101:77] == 25'd0);
	assign trace_completed_pc = w_state[133-:32];
	assign trace_completed_insn = w_state[101-:32];
	assign trace_completed_cycle_status = w_state[31-:32];
	wire [255:0] w_disasm;
	Disasm #(.PREFIX("W")) disasm_w(
		.insn(w_state[101-:32]),
		.disasm(w_disasm)
	);
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clk,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem
);
	reg _sv2v_0;
	parameter signed [31:0] NUM_WORDS = 512;
	input wire rst;
	input wire clk;
	input wire [31:0] pc_to_imem;
	output reg [31:0] insn_from_imem;
	input wire [31:0] addr_to_dmem;
	output reg [31:0] load_data_from_dmem;
	input wire [31:0] store_data_to_dmem;
	input wire [3:0] store_we_to_dmem;
	reg [31:0] mem_array [0:NUM_WORDS - 1];
	initial $readmemh("mem_initial_contents.hex", mem_array);
	always @(*)
		if (_sv2v_0)
			;
	localparam signed [31:0] AddrMsb = $clog2(NUM_WORDS) + 1;
	localparam signed [31:0] AddrLsb = 2;
	always @(negedge clk)
		if (!rst)
			insn_from_imem <= mem_array[pc_to_imem[AddrMsb:AddrLsb]];
	always @(negedge clk)
		if (!rst) begin
			if (store_we_to_dmem[0])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
			if (store_we_to_dmem[1])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
			if (store_we_to_dmem[2])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
			if (store_we_to_dmem[3])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
			load_data_from_dmem <= mem_array[addr_to_dmem[AddrMsb:AddrLsb]];
		end
	initial _sv2v_0 = 0;
endmodule
`default_nettype none
`default_nettype none
module SystemResourceCheck (
	external_clk_25MHz,
	btn,
	led
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	wire clk_proc;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	wire [31:0] trace_writeback_pc;
	wire [31:0] trace_writeback_insn;
	wire [31:0] trace_writeback_cycle_status;
	MemorySingleCycle #(.NUM_WORDS(128)) memory(
		.rst(!clk_locked),
		.clk(clk_proc),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we)
	);
	DatapathPipelined datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(led[0]),
		.trace_completed_pc(trace_writeback_pc),
		.trace_completed_insn(trace_writeback_insn),
		.trace_completed_cycle_status(trace_writeback_cycle_status)
	);
endmodule