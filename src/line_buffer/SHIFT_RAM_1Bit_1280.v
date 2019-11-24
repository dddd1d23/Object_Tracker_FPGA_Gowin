module Shift_RAM_1Bit_800(
	input clk,
	input rst,
	input clken,
	input shiftin,
	output shiftout,
	output taps0x,
	output taps1x
);
assign clkw=clken?clk:1'b0;
SR_800_1 line0(
	.clk(clkw),
	.Reset(rst),
	.Din(shiftin),
	.Q(taps0x)
);
SR_800_1 line1(
	.clk(clkw),
	.Reset(rst),
	.Din(taps0x),
	.Q(taps1x)
);
SR_800_1 line2(
	.clk(clkw),
	.Reset(rst),
	.Din(taps1x),
	.Q(shiftout)
);
endmodule