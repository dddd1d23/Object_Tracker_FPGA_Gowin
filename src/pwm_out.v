module pwm_out(
	input clk,//50MHz
	input rst_n
	input [11:0] px,py,
	output [18:0] pwm_cnt; //18000-130000
);
parameter ox=400,oy=300;

endmodule