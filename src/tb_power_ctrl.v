`timescale 1ns/1ns
`define clk_period 20
module tb_power_ctrl(
);
reg clk,rst_n;
wire cmos_pwdn,cmos_rst_n,power_done;
initial clk=1;
always #(`clk_period/2) clk=~clk;
power_ctrl power_ctrl_u0(
	.clk(clk),
	.rst_n(rst_n),
	.cmos_pwdn(cmos_pwdn),
	.cmos_rst_n(cmos_rst_n),
	.power_done(power_done)
);
initial begin
	clk=1;rst_n=0;
	#100;
	rst_n=1;
end
endmodule