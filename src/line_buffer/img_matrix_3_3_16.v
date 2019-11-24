//Author:dhy0077
//Email:851856050@qq.com
`timescale 1ns/1ns
module img_matrix_3_3_16
#(
	parameter [10:0]	IMG_H=10'd1280,	//1280*720
	parameter [10:0]	IMG_V=10'd720
)
(
	input clk,
	input rst_n,
	input [15:0] pre_img_data,
	input pre_vs,
	input pre_hs,
	input pre_clken,
	//input pre_imgbit,
	output matrix_vs,
	output matrix_hs,
	output matrix_clken,	
	output reg [15:0] matrix_p11, matrix_p12, matrix_p13,
	output reg [15:0] matrix_p21, matrix_p22, matrix_p23,
	output reg [15:0] matrix_p31, matrix_p32, matrix_p33,
	output [15:0] matrix_img_data
);
//Generate 3*3 matrix 
//sync row3_data with pre_clken & row1_data & raw2_data
wire [15:0] row1_data;	//1th row
wire [15:0] row2_data;	//2nd row
reg	 [15:0] row3_data;	//3rd row
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		row3_data<=0;
	else 
	begin
		if(pre_clken) row3_data<=pre_img_data;
		else row3_data<=row3_data;
	end	
end
//module of shift ram for raw data
wire shift_clk_en = pre_clken;
Shift_RAM_16Bit_1280_L3 u0(
	.clk(clk),
	.clken(shift_clk_en),	//pixel enable clock
//	.aclr(1'b0),
	.rst(1'b0),
	.shiftin(row3_data),	//Current data input
	.taps0x(row2_data),	//Last row data
	.taps1x(row1_data),	//Up a row data
	.shiftout()
);
//------------------------------------------
//sync:lag 2 clocks
reg	[1:0] pre_vs_r;
reg	[1:0] pre_hs_r;	
reg	[1:0] pre_clken_r;
reg [15:0] pre_img_data_r[0:1];
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		pre_vs_r<=0;
		pre_hs_r<=0;
		pre_clken_r<=0;
		pre_img_data_r[1]<=16'b0;
		pre_img_data_r[0]<=16'b0;
	end
	else begin
		pre_vs_r<={pre_vs_r[0],pre_vs};
		pre_hs_r<={pre_hs_r[0],pre_hs};
		pre_clken_r<={pre_clken_r[0],pre_clken};
		pre_img_data_r[1]<=pre_img_data_r[0];
		pre_img_data_r[0]<=pre_img_data;
	end
end
//Give up the 1th and 2th row edge data caculate for simple process
//Give up the 1th and 2th point of 1 line for simple process
wire read_frame_href=pre_hs_r[0];	//RAM read href sync signal
wire read_frame_clken=pre_clken_r[0];	//RAM read enable
assign matrix_vs=pre_vs_r[1];
assign matrix_hs=pre_hs_r[1];
assign matrix_clken=pre_clken_r[1];
assign matrix_img_data=pre_img_data_r[1];
//wire [2:0] matrix_row1={matrix_p11,matrix_p12,matrix_p13};
//wire [2:0] matrix_row2={matrix_p21,matrix_p22,matrix_p23};
//wire [2:0] matrix_row3={matrix_p31,matrix_p32,matrix_p33};
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		{matrix_p11,matrix_p12,matrix_p13}<=0;
		{matrix_p21,matrix_p22,matrix_p23}<=0;
		{matrix_p31,matrix_p32,matrix_p33}<=0;
	end
	else if(read_frame_href)
	begin
		if(read_frame_clken)	//shift ram data read clock enable
		begin
			{matrix_p11,matrix_p12,matrix_p13}<={matrix_p12,matrix_p13,row1_data};	//1th shift input
			{matrix_p21,matrix_p22,matrix_p23}<={matrix_p22,matrix_p23,row2_data};	//2nd shift input
			{matrix_p31,matrix_p32,matrix_p33}<={matrix_p32,matrix_p33,row3_data};	//3rd shift input
		end else
		begin
			{matrix_p11,matrix_p12,matrix_p13}<={matrix_p11,matrix_p12,matrix_p13};
			{matrix_p21,matrix_p22,matrix_p23}<={matrix_p21,matrix_p22,matrix_p23};
			{matrix_p31,matrix_p32,matrix_p33}<={matrix_p31,matrix_p32,matrix_p33};
		end	
	end else
	begin
		{matrix_p11,matrix_p12,matrix_p13}<=0;
		{matrix_p21,matrix_p22,matrix_p23}<=0;
		{matrix_p31,matrix_p32,matrix_p33}<=0;
	end
end

endmodule
