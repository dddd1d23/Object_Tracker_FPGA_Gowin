module Shift_RAM_16Bit_1280_L5(
	input clk,
	input rst,
	input clken,
	input [15:0] shiftin,
	output [15:0] shiftout,
	output [15:0] taps0x,
	output [15:0] taps1x,
	output [15:0] taps2x,
	output [15:0] taps3x
);
wire clkw;
assign clkw=clken?clk:1'b0;
SR_1280_16 line0(
	.clk(clkw),
	.Reset(rst),
	.Din(shiftin),
	.Q(taps0x)
);
SR_1280_16 line1(
	.clk(clkw),
	.Reset(rst),
	.Din(taps0x),
	.Q(taps1x)
);
SR_1280_16 line2(
	.clk(clkw),
	.Reset(rst),
	.Din(taps1x),
	.Q(taps2x)
);
SR_1280_16 line3(
	.clk(clkw),
	.Reset(rst),
	.Din(taps2x),
	.Q(taps3x)
);
SR_1280_16 line4(
	.clk(clkw),
	.Reset(rst),
	.Din(taps3x),
	.Q(shiftout)
);
endmodule
