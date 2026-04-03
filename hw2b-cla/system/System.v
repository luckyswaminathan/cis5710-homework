module gp1 (
	a,
	b,
	g,
	p
);
	input wire a;
	input wire b;
	output wire g;
	output wire p;
	assign g = a & b;
	assign p = a | b;
endmodule
module gp8 (
	gin,
	pin,
	cin,
	gout,
	pout,
	cout
);
	reg _sv2v_0;
	input wire [7:0] gin;
	input wire [7:0] pin;
	input wire cin;
	output wire gout;
	output wire pout;
	output wire [6:0] cout;
	wire p_carry_stmt;
	wire g_or_pc;
	reg cout_0;
	reg cout_1;
	reg cout_2;
	reg cout_3;
	reg cout_4;
	reg cout_5;
	reg cout_6;
	assign p_carry_stmt = pin[0] & cin;
	assign g_or_pc = gin[0] | p_carry_stmt;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc)
			cout_0 = 1'b1;
		else
			cout_0 = 1'b0;
	end
	wire p_carry_stmt_1;
	wire g_or_pc_1;
	assign p_carry_stmt_1 = pin[1] & cout_0;
	assign g_or_pc_1 = gin[1] | p_carry_stmt_1;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_1)
			cout_1 = 1'b1;
		else
			cout_1 = 1'b0;
	end
	wire p_carry_stmt_2;
	wire g_or_pc_2;
	assign p_carry_stmt_2 = pin[2] & cout_1;
	assign g_or_pc_2 = gin[2] | p_carry_stmt_2;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_2)
			cout_2 = 1'b1;
		else
			cout_2 = 1'b0;
	end
	wire p_carry_stmt_3;
	wire g_or_pc_3;
	assign p_carry_stmt_3 = pin[3] & cout_2;
	assign g_or_pc_3 = gin[3] | p_carry_stmt_3;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_3)
			cout_3 = 1'b1;
		else
			cout_3 = 1'b0;
	end
	wire p_carry_stmt_4;
	wire g_or_pc_4;
	assign p_carry_stmt_4 = pin[4] & cout_3;
	assign g_or_pc_4 = gin[4] | p_carry_stmt_4;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_4)
			cout_4 = 1'b1;
		else
			cout_4 = 1'b0;
	end
	wire p_carry_stmt_5;
	wire g_or_pc_5;
	assign p_carry_stmt_5 = pin[5] & cout_4;
	assign g_or_pc_5 = gin[5] | p_carry_stmt_5;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_5)
			cout_5 = 1'b1;
		else
			cout_5 = 1'b0;
	end
	wire p_carry_stmt_6;
	wire g_or_pc_6;
	assign p_carry_stmt_6 = pin[6] & cout_5;
	assign g_or_pc_6 = gin[6] | p_carry_stmt_6;
	always @(*) begin
		if (_sv2v_0)
			;
		if (g_or_pc_6)
			cout_6 = 1'b1;
		else
			cout_6 = 1'b0;
	end
	assign cout[0] = cout_0;
	assign cout[1] = cout_1;
	assign cout[2] = cout_2;
	assign cout[3] = cout_3;
	assign cout[4] = cout_4;
	assign cout[5] = cout_5;
	assign cout[6] = cout_6;
	assign gout = ((((((gin[7] | (pin[7] & gin[6])) | ((pin[7] & pin[6]) & gin[5])) | (((pin[7] & pin[6]) & pin[5]) & gin[4])) | ((((pin[7] & pin[6]) & pin[5]) & pin[4]) & gin[3])) | (((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & gin[2])) | ((((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & pin[2]) & gin[1])) | (((((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & pin[2]) & pin[1]) & gin[0]);
	assign pout = &pin;
	initial _sv2v_0 = 0;
endmodule
module CarryLookaheadAdder (
	a,
	b,
	cin,
	sum
);
	input wire [31:0] a;
	input wire [31:0] b;
	input wire cin;
	output wire [31:0] sum;
	wire [31:0] g;
	wire [31:0] p;
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 32; _gv_i_1 = _gv_i_1 + 1) begin : gp1_inst
			localparam i = _gv_i_1;
			gp1 gp1_inst(
				.a(a[i]),
				.b(b[i]),
				.g(g[i]),
				.p(p[i])
			);
		end
	endgenerate
	wire [6:0] cout_0;
	wire [6:0] cout_1;
	wire [6:0] cout_2;
	wire [6:0] cout_3;
	wire gout_0;
	wire pout_0;
	wire gout_1;
	wire pout_1;
	wire gout_2;
	wire pout_2;
	wire gout_3;
	wire pout_3;
	wire carry_8;
	wire carry_16;
	wire carry_24;
	gp8 gp8_inst_0(
		.gin(g[7:0]),
		.pin(p[7:0]),
		.cin(cin),
		.gout(gout_0),
		.pout(pout_0),
		.cout(cout_0)
	);
	assign carry_8 = gout_0 | (pout_0 & cin);
	gp8 gp8_inst_1(
		.gin(g[15:8]),
		.pin(p[15:8]),
		.cin(carry_8),
		.gout(gout_1),
		.pout(pout_1),
		.cout(cout_1)
	);
	assign carry_16 = gout_1 | (pout_1 & carry_8);
	gp8 gp8_inst_2(
		.gin(g[23:16]),
		.pin(p[23:16]),
		.cin(carry_16),
		.gout(gout_2),
		.pout(pout_2),
		.cout(cout_2)
	);
	assign carry_24 = gout_2 | (pout_2 & carry_16);
	gp8 gp8_inst_3(
		.gin(g[31:24]),
		.pin(p[31:24]),
		.cin(carry_24),
		.gout(gout_3),
		.pout(pout_3),
		.cout(cout_3)
	);
	wire [31:0] carry_in;
	assign carry_in = {cout_3, carry_24, cout_2, carry_16, cout_1, carry_8, cout_0, cin};
	assign sum = (a ^ b) ^ carry_in;
endmodule
module SystemDemo (
	external_clk_25MHz,
	btn,
	led
);
	reg _sv2v_0;
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output reg [7:0] led;
	reg [31:0] ab;
	wire [15:0] a;
	wire [15:0] b;
	wire [31:0] expected_sum;
	wire [31:0] actual_sum;
	wire rst = ~btn[0];
	reg error;
	wire [2:0] chunk = ab[31:29];
	reg [7:0] completed;
	CarryLookaheadAdder cla_inst(
		.a(a),
		.b(b),
		.cin(1'b0),
		.sum(actual_sum)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		a = ab[31:16];
		b = ab[15:0];
		expected_sum = a + b;
	end
	always @(posedge external_clk_25MHz)
		if (rst) begin
			ab <= 32'd0;
			error <= 1'b0;
			completed <= 8'd0;
		end
		else if (!error) begin
			if (actual_sum != expected_sum)
				error <= 1'b1;
			else begin
				ab <= ab + 1;
				if (ab[28:0] == 29'h1fffffff)
					completed[chunk] <= 1'b1;
			end
		end
	reg [23:0] blink;
	always @(posedge external_clk_25MHz)
		if (rst)
			blink <= 0;
		else
			blink <= blink + 1;
	always @(*) begin
		if (_sv2v_0)
			;
		if (error)
			led = completed;
		else
			led = completed | ({7'd0, blink[23]} << chunk);
	end
	initial _sv2v_0 = 0;
endmodule