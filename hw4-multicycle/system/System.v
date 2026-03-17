module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	clk_mem,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire clk_mem;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "10" *) (* FREQUENCY_PIN_CLKOS = "10" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
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
		.CLKOP_DIV(60),
		.CLKOP_CPHASE(30),
		.CLKOP_FPHASE(0),
		.CLKOS_ENABLE("ENABLED"),
		.CLKOS_DIV(60),
		.CLKOS_CPHASE(45),
		.CLKOS_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(2)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
		.CLKOS(clk_mem),
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
module DatapathMultiCycle (
	clk,
	rst,
	halt,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg halt;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output reg [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output reg [31:0] store_data_to_dmem;
	output reg [3:0] store_we_to_dmem;
	output wire [31:0] trace_completed_pc;
	output wire [31:0] trace_completed_insn;
	output reg [31:0] trace_completed_cycle_status;
	wire [6:0] insn_funct7;
	wire [4:0] insn_rs2;
	wire [4:0] insn_rs1;
	wire [2:0] insn_funct3;
	wire [4:0] insn_rd;
	wire [6:0] insn_opcode;
	assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = insn_from_imem;
	wire [11:0] imm_i;
	assign imm_i = insn_from_imem[31:20];
	wire [4:0] imm_shamt = insn_from_imem[24:20];
	wire [11:0] imm_s;
	assign imm_s[11:5] = insn_funct7;
	assign imm_s[4:0] = insn_rd;
	wire [12:0] imm_b;
	assign {imm_b[12], imm_b[10:5]} = insn_funct7;
	assign {imm_b[4:1], imm_b[11]} = insn_rd;
	assign imm_b[0] = 1'b0;
	wire [20:0] imm_j;
	assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {insn_from_imem[31:12], 1'b0};
	wire [31:0] imm_i_sext = {{20 {imm_i[11]}}, imm_i[11:0]};
	wire [31:0] imm_s_sext = {{20 {imm_s[11]}}, imm_s[11:0]};
	wire [31:0] imm_b_sext = {{19 {imm_b[12]}}, imm_b[12:0]};
	wire [31:0] imm_j_sext = {{11 {imm_j[20]}}, imm_j[20:0]};
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
	wire insn_lui = insn_opcode == OpLui;
	wire insn_auipc = insn_opcode == OpAuipc;
	wire insn_jal = insn_opcode == OpJal;
	wire insn_jalr = insn_opcode == OpJalr;
	wire insn_beq = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b000);
	wire insn_bne = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b001);
	wire insn_blt = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b100);
	wire insn_bge = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b101);
	wire insn_bltu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b110);
	wire insn_bgeu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b111);
	wire insn_lb = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b000);
	wire insn_lh = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b001);
	wire insn_lw = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b010);
	wire insn_lbu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b100);
	wire insn_lhu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b101);
	wire insn_sb = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b000);
	wire insn_sh = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b001);
	wire insn_sw = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b010);
	wire insn_addi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b000);
	wire insn_slti = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b010);
	wire insn_sltiu = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b011);
	wire insn_xori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b100);
	wire insn_ori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b110);
	wire insn_andi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b111);
	wire insn_slli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srai = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_add = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sub = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_sll = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_slt = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b010)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sltu = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b011)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_xor = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b100)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srl = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sra = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_or = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b110)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_and = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b111)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_mul = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b000);
	wire insn_mulh = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b001);
	wire insn_mulhsu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b010);
	wire insn_mulhu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b011);
	wire insn_div = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b100);
	wire insn_divu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b101);
	wire insn_rem = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b110);
	wire insn_remu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b111);
	wire insn_ecall = (insn_opcode == OpEnviron) && (insn_from_imem[31:7] == 25'd0);
	wire insn_fence = insn_opcode == OpMiscMem;
	reg [31:0] pcNext;
	reg [31:0] pcCurrent;
	always @(posedge clk)
		if (rst)
			pcCurrent <= 32'd0;
		else
			pcCurrent <= pcNext;
	assign pc_to_imem = pcCurrent;
	assign trace_completed_pc = pcCurrent;
	assign trace_completed_insn = insn_from_imem;
	reg [31:0] cycles_current;
	reg [31:0] num_insns_current;
	always @(posedge clk)
		if (rst) begin
			cycles_current <= 0;
			num_insns_current <= 0;
		end
		else begin
			cycles_current <= cycles_current + 1;
			if (trace_completed_cycle_status == 32'd1)
				num_insns_current <= num_insns_current + 1;
		end
	reg [31:0] rd_data;
	reg we;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	RegFile rf(
		.clk(clk),
		.rst(rst),
		.we(we),
		.rd(insn_rd),
		.rd_data(rd_data),
		.rs1(insn_rs1),
		.rs2(insn_rs2),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);
	wire [31:0] load_addr = rs1_data + imm_i_sext;
	wire [31:0] store_addr = rs1_data + imm_s_sext;
	reg illegal_insn;
	wire div_rem_signed = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && ((insn_from_imem[14:12] == 3'b100) || (insn_from_imem[14:12] == 3'b110));
	wire [31:0] dividend = (div_rem_signed && rs1_data[31] ? ~rs1_data + 32'd1 : rs1_data);
	wire [31:0] divisor = (div_rem_signed && rs2_data[31] ? ~rs2_data + 32'd1 : rs2_data);
	wire [31:0] quotient;
	wire [31:0] remainder;
	DividerUnsignedPipelined div_inst(
		.clk(clk),
		.rst(rst),
		.stall(1'b0),
		.i_dividend(dividend),
		.i_divisor(divisor),
		.o_quotient(quotient),
		.o_remainder(remainder)
	);
	wire is_div_insn = ((insn_div | insn_divu) | insn_rem) | insn_remu;
	reg [3:0] div_counter;
	reg [3:0] div_counter_next;
	always @(posedge clk)
		if (rst)
			div_counter <= 4'd0;
		else
			div_counter <= div_counter_next;
	always @(*) begin
		if (_sv2v_0)
			;
		illegal_insn = 1'b0;
		rd_data = 32'b00000000000000000000000000000000;
		we = 1'b0;
		pcNext = pcCurrent + 32'd4;
		halt = 1'b0;
		addr_to_dmem = 32'b00000000000000000000000000000000;
		store_data_to_dmem = 32'b00000000000000000000000000000000;
		store_we_to_dmem = 4'b0000;
		case (insn_opcode)
			OpLui: begin
				rd_data = {insn_from_imem[31:12], 12'b000000000000};
				we = 1'b1;
			end
			OpAuipc: begin
				rd_data = pcCurrent + {insn_from_imem[31:12], 12'b000000000000};
				we = 1'b1;
			end
			OpJal: begin
				rd_data = pcCurrent + 32'd4;
				we = 1'b1;
				pcNext = pcCurrent + imm_j_sext;
			end
			OpJalr: begin
				rd_data = pcCurrent + 32'd4;
				we = 1'b1;
				pcNext = (rs1_data + imm_i_sext) & ~32'd1;
			end
			OpEnviron:
				if (insn_ecall)
					halt = 1'b1;
			OpRegImm:
				case (insn_from_imem[14:12])
					3'b000: begin
						rd_data = rs1_data + imm_i_sext;
						we = 1'b1;
					end
					3'b010: begin
						rd_data = ($signed(rs1_data) < $signed(imm_i_sext) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						we = 1'b1;
					end
					3'b011: begin
						rd_data = (rs1_data < imm_i_sext ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
						we = 1'b1;
					end
					3'b100: begin
						rd_data = rs1_data ^ imm_i_sext;
						we = 1'b1;
					end
					3'b110: begin
						rd_data = rs1_data | imm_i_sext;
						we = 1'b1;
					end
					3'b111: begin
						rd_data = rs1_data & imm_i_sext;
						we = 1'b1;
					end
					3'b001: begin
						rd_data = rs1_data << imm_i[4:0];
						we = 1'b1;
					end
					3'b101: begin
						if (insn_from_imem[30])
							rd_data = $signed(rs1_data) >>> imm_i[4:0];
						else
							rd_data = rs1_data >> imm_i[4:0];
						we = 1'b1;
					end
					default: illegal_insn = 1'b1;
				endcase
			OpRegReg:
				case (insn_from_imem[14:12])
					3'b000:
						case (insn_from_imem[31:25])
							7'd0: begin
								rd_data = rs1_data + rs2_data;
								we = 1'b1;
							end
							7'b0100000: begin
								rd_data = rs1_data + (~rs2_data + 32'd1);
								we = 1'b1;
							end
							7'b0000001: begin
								rd_data = rs1_data * rs2_data;
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b001:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = rs1_data << rs2_data[4:0];
								we = 1'b1;
							end
							7'b0000001: begin : sv2v_autoblock_1
								reg signed [63:0] mulh_prod;
								mulh_prod = $signed({{32 {rs1_data[31]}}, rs1_data}) * $signed({{32 {rs2_data[31]}}, rs2_data});
								rd_data = mulh_prod[63:32];
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b010:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = ($signed(rs1_data) < $signed(rs2_data) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
								we = 1'b1;
							end
							7'b0000001: begin : sv2v_autoblock_2
								reg signed [63:0] mulhsu_prod;
								mulhsu_prod = $signed({{32 {rs1_data[31]}}, rs1_data}) * {32'b00000000000000000000000000000000, rs2_data};
								rd_data = mulhsu_prod[63:32];
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b011:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = (rs1_data < rs2_data ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000);
								we = 1'b1;
							end
							7'b0000001: begin : sv2v_autoblock_3
								reg [63:0] mulhu_prod;
								mulhu_prod = {32'b00000000000000000000000000000000, rs1_data} * {32'b00000000000000000000000000000000, rs2_data};
								rd_data = mulhu_prod[63:32];
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b100:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = rs1_data ^ rs2_data;
								we = 1'b1;
							end
							7'b0000001: begin
								if (rs2_data == 32'b00000000000000000000000000000000)
									rd_data = 32'hffffffff;
								else
									rd_data = (rs1_data[31] ^ rs2_data[31] ? ~quotient + 32'd1 : quotient);
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b110:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = rs1_data | rs2_data;
								we = 1'b1;
							end
							7'b0000001: begin
								if (rs2_data == 32'b00000000000000000000000000000000)
									rd_data = rs1_data;
								else if ((rs1_data == 32'h80000000) && (rs2_data == 32'hffffffff))
									rd_data = 32'b00000000000000000000000000000000;
								else
									rd_data = (rs1_data[31] ? ~remainder + 32'd1 : remainder);
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b101:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = rs1_data >> rs2_data[4:0];
								we = 1'b1;
							end
							7'b0100000: begin
								rd_data = $signed(rs1_data) >>> rs2_data[4:0];
								we = 1'b1;
							end
							7'b0000001: begin
								rd_data = (rs2_data == 32'b00000000000000000000000000000000 ? 32'hffffffff : quotient);
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					3'b111:
						case (insn_from_imem[31:25])
							7'b0000000: begin
								rd_data = rs1_data & rs2_data;
								we = 1'b1;
							end
							7'b0000001: begin
								rd_data = (rs2_data == 32'b00000000000000000000000000000000 ? rs1_data : remainder);
								we = 1'b1;
							end
							default: illegal_insn = 1'b1;
						endcase
					default: illegal_insn = 1'b1;
				endcase
			OpBranch:
				case (insn_from_imem[14:12])
					3'b000:
						if (rs1_data == rs2_data)
							pcNext = pcCurrent + imm_b_sext;
					3'b001:
						if (rs1_data != rs2_data)
							pcNext = pcCurrent + imm_b_sext;
					3'b100:
						if ($signed(rs1_data) < $signed(rs2_data))
							pcNext = pcCurrent + imm_b_sext;
					3'b101:
						if ($signed(rs1_data) >= $signed(rs2_data))
							pcNext = pcCurrent + imm_b_sext;
					3'b110:
						if (rs1_data < rs2_data)
							pcNext = pcCurrent + imm_b_sext;
					3'b111:
						if (rs1_data >= rs2_data)
							pcNext = pcCurrent + imm_b_sext;
					default: illegal_insn = 1'b1;
				endcase
			OpLoad: begin
				we = 1'b1;
				addr_to_dmem = load_addr & ~32'h00000003;
				case (insn_from_imem[14:12])
					3'b000:
						case (load_addr[1:0])
							2'b00: rd_data = {{24 {load_data_from_dmem[7]}}, load_data_from_dmem[7:0]};
							2'b01: rd_data = {{24 {load_data_from_dmem[15]}}, load_data_from_dmem[15:8]};
							2'b10: rd_data = {{24 {load_data_from_dmem[23]}}, load_data_from_dmem[23:16]};
							2'b11: rd_data = {{24 {load_data_from_dmem[31]}}, load_data_from_dmem[31:24]};
						endcase
					3'b001:
						case (load_addr[1])
							1'b0: rd_data = {{16 {load_data_from_dmem[15]}}, load_data_from_dmem[15:0]};
							1'b1: rd_data = {{16 {load_data_from_dmem[31]}}, load_data_from_dmem[31:16]};
						endcase
					3'b010: rd_data = load_data_from_dmem[31:0];
					3'b100:
						case (load_addr[1:0])
							2'b00: rd_data = {24'b000000000000000000000000, load_data_from_dmem[7:0]};
							2'b01: rd_data = {24'b000000000000000000000000, load_data_from_dmem[15:8]};
							2'b10: rd_data = {24'b000000000000000000000000, load_data_from_dmem[23:16]};
							2'b11: rd_data = {24'b000000000000000000000000, load_data_from_dmem[31:24]};
						endcase
					3'b101:
						case (load_addr[1])
							1'b0: rd_data = {16'b0000000000000000, load_data_from_dmem[15:0]};
							1'b1: rd_data = {16'b0000000000000000, load_data_from_dmem[31:16]};
						endcase
					default: illegal_insn = 1'b1;
				endcase
			end
			OpStore: begin
				addr_to_dmem = store_addr & ~32'h00000003;
				case (insn_from_imem[14:12])
					3'b000: begin
						store_data_to_dmem = {24'b000000000000000000000000, rs2_data[7:0]} << (8 * store_addr[1:0]);
						store_we_to_dmem = 4'b0001 << store_addr[1:0];
					end
					3'b001: begin
						store_data_to_dmem = (store_addr[1] ? {rs2_data[15:0], 16'b0000000000000000} : {16'b0000000000000000, rs2_data[15:0]});
						store_we_to_dmem = (store_addr[1] ? 4'b1100 : 4'b0011);
					end
					3'b010: begin
						store_data_to_dmem = rs2_data;
						store_we_to_dmem = 4'b1111;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			default: illegal_insn = 1'b1;
		endcase
		div_counter_next = 4'd0;
		trace_completed_cycle_status = 32'd1;
		if ((div_counter == 4'd0) && is_div_insn) begin
			div_counter_next = 4'd1;
			pcNext = pcCurrent;
			we = 1'b0;
			trace_completed_cycle_status = 32'd2;
		end
		else if ((div_counter > 4'd0) && (div_counter < 4'd8)) begin
			div_counter_next = div_counter + 4'd1;
			pcNext = pcCurrent;
			we = 1'b0;
			trace_completed_cycle_status = 32'd2;
			addr_to_dmem = 32'b00000000000000000000000000000000;
			store_data_to_dmem = 32'b00000000000000000000000000000000;
			store_we_to_dmem = 4'b0000;
		end
		else if (div_counter == 4'd8) begin
			div_counter_next = 4'd0;
			trace_completed_cycle_status = 32'd1;
		end
	end
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clock_mem,
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
	input wire clock_mem;
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
	always @(posedge clock_mem)
		if (rst)
			;
		else
			insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
	always @(negedge clock_mem)
		if (rst)
			;
		else begin
			if (store_we_to_dmem[0])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
			if (store_we_to_dmem[1])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
			if (store_we_to_dmem[2])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
			if (store_we_to_dmem[3])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
			load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
		end
	initial _sv2v_0 = 0;
endmodule
module SystemResourceCheck (
	external_clk_25MHz,
	btn,
	led
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	wire clk_proc;
	wire clk_mem;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.clk_mem(clk_mem),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	MemorySingleCycle #(.NUM_WORDS(128)) memory(
		.rst(!clk_locked),
		.clock_mem(clk_mem),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we)
	);
	DatapathMultiCycle datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(led[0])
	);
endmodule