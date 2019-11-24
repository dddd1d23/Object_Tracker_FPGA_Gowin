module vga_mark_out(
    input clk,rst_n,
	input pre_vs,
	input pre_hs,
	input pre_clken,
	input [23:0] pre_img,
	input [10:0] px,py,
    input [10:0] a,
	output reg [23:0] post_img,
	output post_vs,
	output post_hs,
	output post_clken
);
reg [10:0] pre_x,pre_y;
parameter row_cnt=800;
parameter col_cnt=600;
//--------------------------------------------------------------
assign post_hs=pre_hs;
assign post_vs=pre_vs;
assign post_clken=pre_clken;
//generate pre_x,pre_y
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
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
    if (!rst_n) begin
        pre_y<=0;
    end
    else if (row_flag && pre_y==col_cnt-1'b1)
        pre_y<=0;
    else if (row_flag) begin
        pre_y<=pre_y + 1'b1;
    end
    else pre_y<=pre_y;
end
//--------------------------------------------------------------
wire [9:0] a1,a2,a3;
wire in_rect,in_line0,in_line1,in_line2,in_line3,in_line4,in_line5,in_line6,in_line7,in_line8;
assign a1={1'b0,a[9:1]},a2={2'b0,a[9:2]};
assign a3=a1+a2;
assign in_rect=(pre_x<=px+a1) && (pre_y<=py+a1) && (pre_x+a1>=px) && (pre_y+a1>=py);
assign in_line0=(pre_x==px) || (pre_y==py);
assign in_line1=(pre_x+a3==px) && (pre_y<=py+a3) && (pre_y>=py+a2);
assign in_line2=(pre_x+a3==px) && (pre_y+a2<=py) && (pre_y+a3>=py);
assign in_line3=(pre_x==px+a3) && (pre_y<=py+a3) && (pre_y>=py+a2);
assign in_line4=(pre_x==px+a3) && (pre_y+a2<=py) && (pre_y+a3>=py);
assign in_line5=(pre_y+a3==py) && (pre_x<=px+a3) && (pre_x>=px+a2);
assign in_line6=(pre_y+a3==py) && (pre_x+a2<=px) && (pre_x+a3>=px);
assign in_line7=(pre_y==py+a3) && (pre_x<=px+a3) && (pre_x>=px+a2);
assign in_line8=(pre_y==py+a3) && (pre_x+a2<=px) && (pre_x+a3>=px);
assign in_line=in_line0 
               || in_line1 || in_line2 || in_line3 || in_line4
					|| in_line5 || in_line6 || in_line7 || in_line8;
//---------------------------------------------------------------
always @(*) begin
	if (in_rect) begin
		post_img[23:0]={8'd255,8'd127,8'd0};
	end else if (in_line) begin
		post_img[23:0]={8'd255,8'd0,8'd0};
	end else begin
		post_img=pre_img;
	end
end
endmodule