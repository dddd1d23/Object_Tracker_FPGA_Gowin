module pwm_out(
	input clk,//50MHz
	input rst_n,
	input [11:0] px,py,
    input [1:0] I_sw,
	output reg [18:0] pwm_cnt //18000-130000
);
parameter ox=400,oy=300;
parameter init_val=19'd74250;
parameter gm=7;
reg [25:0] driver_cnt;
reg driver_en;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        driver_cnt<=0;driver_en<=0;
    end else begin
        if (driver_cnt==26'd4000000-1) begin driver_cnt<=0;driver_en<=1;end
        else begin driver_cnt<=driver_cnt+1'b1;driver_en<=0;end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || I_sw[1]==1'b1) begin
        pwm_cnt<=init_val;
    end else if (driver_en)
    begin
        if (px<ox) begin
            pwm_cnt<=pwm_cnt+(ox-px)*gm;
        end else pwm_cnt<=pwm_cnt-(px-ox)*gm;
    end else pwm_cnt<=pwm_cnt;
end
endmodule