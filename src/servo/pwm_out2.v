module pwm_out2(
	input clk,//50MHz
	input rst_n,
	input [11:0] px,py,
    input [11:0] a,
    input [1:0] I_sw,
    input sweep_en,
	output reg [18:0] pwm_cnt //18000-130000
);
parameter sweep_ready=3'b100;
parameter sweep_wait0=3'b011;
parameter sweep_wait1=3'b101;
parameter sweep_on=3'b010;
parameter sweep_finish=3'b001;
parameter normal=3'b000;
parameter ox=400,oy=300;
parameter init_val=19'd74250;
parameter gm=16;
reg sweep_en_t,sweep_en_2;
reg [2:0] state;
reg [25:0] driver_cnt;
reg driver_en;
reg [19:0] val_max;
wire [19:0] val_now;
wire [11:0] offset;
reg [18:0] pwm_find;
reg [5:0] wait0_cnt;
reg [5:0] wait1_cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        driver_cnt<=0;driver_en<=0;sweep_en_t<=0;sweep_en_2<=0;
    end else begin
        if (driver_cnt==26'd4000000-1) begin driver_cnt<=0;driver_en<=1;sweep_en_t<=sweep_en_2;end
        else if (driver_cnt==0) begin sweep_en_2<=0;driver_cnt<=driver_cnt+1'b1;driver_en<=0;end
        else begin 
            driver_cnt<=driver_cnt+1'b1;driver_en<=0;
            if (sweep_en) sweep_en_2<=1'b1;else sweep_en_2<=sweep_en_2;
        end
    end
end
assign offset=(ox>px)?ox-px:px-ox;
assign val_now=(400-offset)*a;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || I_sw[1]==1'b1) begin
        pwm_cnt<=init_val;
        state<=normal;
    end else if (driver_en) begin
        case (state)
        sweep_ready:begin
            val_max<=0;pwm_find<=0;
            pwm_cnt<=19'd19000;
            wait0_cnt<=0;
            state<=sweep_wait0;
        end
        sweep_wait0:begin
            val_max<=0;pwm_find<=0;
            pwm_cnt<=pwm_cnt;
            if (wait0_cnt==6'd13) begin
                wait0_cnt<=6'd0;
                state<=sweep_on;
            end else begin wait0_cnt<=wait0_cnt+1'b1;state<=sweep_wait0;end
        end
        sweep_on:begin
            if (val_now>val_max) begin
                val_max<=val_now;
                pwm_find<=pwm_cnt;
            end
            if (pwm_cnt+19'd1500<=19'd130000) begin 
                pwm_cnt<=pwm_cnt+19'd1500;
                state<=state;
            end
            else begin state<=sweep_finish;end
        end
        sweep_finish:begin
            pwm_cnt<=pwm_find;
            state<=sweep_wait1;
            wait1_cnt<=6'd0;
        end
        sweep_wait1:begin
            pwm_cnt<=pwm_cnt;
            if (wait1_cnt==6'd13) begin
                wait1_cnt<=6'd0;
                state<=normal;
            end else begin wait1_cnt<=wait1_cnt+1'b1;state<=sweep_wait1;end
        end
        normal:begin
            if (sweep_en_t) begin
                state<=sweep_ready;
            end else begin
                if (px<ox) begin
                    if (pwm_cnt+(ox-px)*gm<=19'd130000) 
                        pwm_cnt<=pwm_cnt+(ox-px)*gm;
                    else pwm_cnt<=pwm_cnt;
                end else begin
                     if (pwm_cnt>=19'd19000+(px-ox)*gm)  
                        pwm_cnt<=pwm_cnt-(px-ox)*gm;
                    else pwm_cnt<=pwm_cnt;
                end
            end
        end
        endcase
    end else pwm_cnt<=pwm_cnt;
    /*else if (driver_en)
    begin
        if (px<ox) begin
            pwm_cnt<=pwm_cnt+(ox-px)*gm;
        end else pwm_cnt<=pwm_cnt-(px-ox)*gm;
    end else pwm_cnt<=pwm_cnt;*/
end
endmodule