module vfb_test(
    input rst_n,clk,
	output reg [15:0] rgb_out,
	output reg vs_n,
	output reg clken,
    output reg clk2out
);
reg [9:0] pre_x,pre_y;
parameter row_cnt=800;
parameter col_cnt=600;
parameter s_vs=3'b100;
parameter s_out=3'b010;
reg [2:0] state;
wire pre_clken;
//--------------------------------------------------------------
assign pre_clken=1;
//generate pre_x,pre_y
reg clkt;
reg vs_n_2;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) clk2out<=1'b0;
    else clk2out<=~clk2out;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        vs_n_2<=1'b0;
    end else 
    begin
        if (vs_n==1'b0) vs_n_2<=~vs_n_2;
        else vs_n_2<=vs_n_2;
    end
end
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) clkt=0;
 else clkt=~clkt;
  //clkt<=1'b1;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n || state==s_vs ) begin
        pre_x<=0;
    end
    else if (pre_clken && pre_x==row_cnt-1)
        pre_x<=0;
    else if (pre_clken) begin
        pre_x<=pre_x+1'b1;
    end
    else pre_x<=pre_x;
end
assign row_flag=(pre_clken && pre_x==row_cnt-1'b1)?1'b1:1'b0;
always @(posedge clk or negedge rst_n)begin
    if (!rst_n || state==s_vs ) begin
        pre_y<=0;
    end
    else if (row_flag && pre_y==col_cnt-1'b1)
        pre_y<=0;
    else if (row_flag) begin
        pre_y<=pre_y + 1'b1;
    end
    else pre_y<=pre_y;
end
//----------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin state<=s_vs;vs_n<=1'b0;clken<=1'b0;end
	else begin
		case (state)
		s_vs:begin
			vs_n<=1'b0;clken<=1'b0;
			state<=s_out;
		end
		s_out:begin
			vs_n<=1'b1;clken<=clkt;
			if (row_flag && pre_y==col_cnt-1'b1) state<=s_vs;
			else state<=s_out;
		end
		default:begin
			vs_n<=1'b0;clken<=1'b0;
			state<=s_out;
		end
        endcase
	end
end
always @(*) begin
    //if (clkt) rgb_out<={5'b11111,6'b111111,5'b11111};
	if (pre_x>0 && pre_x<=300) rgb_out<={5'b11111,6'b0,5'b0};
    else if (pre_x>300 && pre_x<=500) rgb_out<={5'b0,6'b111111,5'b0};
	else rgb_out<={5'b0,6'b0,5'b11111};
    //rgb_out<={5'b11100,6'b111000,5'b11100};
end
endmodule