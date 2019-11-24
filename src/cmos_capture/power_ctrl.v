module power_ctrl(
	input clk,rst_n,
	output reg cmos_pwdn,cmos_rst_n,
	output reg power_done
);
localparam DELAY_6ms=30_0000;
localparam DELAY_2ms=10_0000;
localparam DELAY_21ms=105_0000;
reg [20:0] cnt_6ms,cnt_2ms,cnt_21ms;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt_6ms<=0;
	else if (cmos_pwdn && (cnt_6ms<DELAY_6ms) ) cnt_6ms<=cnt_6ms+1'b1;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt_2ms<=0;
	else if ( (cmos_rst_n==1'b0) && (cmos_pwdn==1'b0) && (cnt_2ms<DELAY_2ms) ) cnt_2ms<=cnt_2ms+1'b1;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt_21ms<=0;
	else if ( (cmos_rst_n==1'b1) && (cnt_21ms<DELAY_21ms) ) cnt_21ms<=cnt_21ms+1'b1;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin cmos_pwdn<=1;cmos_rst_n<=0;power_done<=0;end
    else begin
        cmos_pwdn<=(cnt_6ms>=DELAY_6ms)?1'b0:1'b1;
        cmos_rst_n<=(cnt_2ms>=DELAY_2ms)?1'b1:1'b0;
        power_done<=(cnt_21ms>=DELAY_21ms)?1'b1:1'b0;
    end
end
endmodule