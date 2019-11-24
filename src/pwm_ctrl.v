module pwm_ctrl(
	input clk,rst_n,
	input [18:0] pwm_cnt,
	output reg pwm,
);
parameter servo_period=26'd1000000;
reg [25:0] d_cnt;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		d_cnt<=26'd0;
		pwm<=1'b0;
	end else
	begin
	    pwm<=(d_cnt<=pwm_cnt)?1'b1:1'b0;
	    if (d_cnt==servo_period) begin
		     d_cnt<=26'd0;
	    end else d_cnt<=d_cnt+1'b1;
	end
end
endmodule