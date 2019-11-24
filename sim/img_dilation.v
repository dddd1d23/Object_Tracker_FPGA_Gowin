//Author:dhy0077
//Email:851856050@qq.com
`timescale 1ns/1ns
module img_dilation
#(
	parameter [9:0]	IMG_H=10'd964,	//800*600
	parameter [9:0]	IMG_V=10'd1444
)
(
	input clk,  				
	input rst_n,				
	input [15:0] pre_img_data,
	input pre_vs,	
	input pre_hs,		
	input pre_clken,	
	input pre_imgbit,		
	output post_vs,	
	output post_hs,	
	output post_clken,	
	output post_imgbit,		
	output [15:0] post_img_data
);
//----------------------------------------------------
wire matrix_vs,matrix_hs,matrix_clken;
wire matrix_p11,matrix_p12,matrix_p13;	//3X3 Matrix output
wire matrix_p21,matrix_p22,matrix_p23;
wire matrix_p31,matrix_p32,matrix_p33;
wire [15:0] matrix_img_data;
img_matrix_3_3_1	
#(
	.IMG_H(IMG_H),	//800*600
	.IMG_V(IMG_V)
)
u0
(
	.clk(clk),  				
	.rst_n(rst_n),				
	.pre_vs(pre_vs),		
	.pre_hs(pre_hs),		
	.pre_clken(pre_clken),		
	.pre_imgbit(pre_imgbit),			
	.pre_img_data(pre_img_data),
	.matrix_vs(matrix_vs),	
	.matrix_hs(matrix_hs),	
	.matrix_clken(matrix_clken),	
	.matrix_p11(matrix_p11), .matrix_p12(matrix_p12), .matrix_p13(matrix_p13),	
	.matrix_p21(matrix_p21), .matrix_p22(matrix_p22), .matrix_p23(matrix_p23),
	.matrix_p31(matrix_p31), .matrix_p32(matrix_p32), .matrix_p33(matrix_p33),
	.matrix_img_data(matrix_img_data)
);
//Dilation Parameter
//   Original      Dilation			  Pixel
// [ 0  0  0 ]   [ 1  1  1 ]     [ P1  P2  P3 ]
// [ 0  1  0 ]   [ 1  1  1 ]     [ P4  P5  P6 ]
// [ 0  0  0 ]   [ 1  1  1 ]     [ P7  P8  P9 ]
//P = P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9;
//---------------------------------------
//Dilation with or operation,1 : White,  0 : Black
//Step 1
reg	post_imgbit1,post_imgbit2,post_imgbit3;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		post_imgbit1<=1'b0;
		post_imgbit2<=1'b0;
		post_imgbit3<=1'b0;
	end
	else
	begin
		post_imgbit1<=matrix_p11 | matrix_p12 | matrix_p13;
		post_imgbit2<=matrix_p21 | matrix_p22 | matrix_p23;
		post_imgbit3<=matrix_p21 | matrix_p32 | matrix_p33;
	end
end
//Step 2
reg	post_imgbit4;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) post_imgbit4<=1'b0;
	else post_imgbit4<=post_imgbit1 | post_imgbit2 | post_imgbit3;
end
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
	end
	else
	begin
		pre_vs_r<={pre_vs_r[0],matrix_vs};
		pre_hs_r<={pre_hs_r[0],matrix_hs};
		pre_clken_r<={pre_clken_r[0],matrix_clken};
		pre_img_data_r[1]<=pre_img_data_r[0];
		pre_img_data_r[0]<=matrix_img_data;
	end
end
assign post_vs=pre_vs_r[1];
assign post_hs=pre_hs_r[1];
assign post_clken=pre_clken_r[1];
assign post_imgbit=post_hs?post_imgbit4:1'b0;
assign post_img_data=pre_img_data_r[1];
endmodule
