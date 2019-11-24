module SR_1280_16(
	input clk,Reset,
	input [15:0] Din,
	output [15:0] Q
);
wire [15:0] d00;
SR_640_16 SR_640_16_u0(
	.clk(clk),
	.Reset(Reset),
	.Din(Din),
	.Q(d00)
);
SR_640_16 SR_640_16_u1(
	.clk(clk),
	.Reset(Reset),
	.Din(d00),
	.Q(Q)
);
endmodule
