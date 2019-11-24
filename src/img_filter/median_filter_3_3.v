module median_filter_3_3(
	input clk,  				
	input rst_n,				
	input pre_vs,	
	input pre_hs,		
	input pre_clken,	
	//input pre_imgbit,		
	input [15:0] pre_img_data,
	output post_vs,	
	output post_hs,	
	output post_clken,	
	//output post_imgbit,		
	output [15:0] post_img_data
);
wire [15:0] matrix_p11, matrix_p12, matrix_p13;
wire [15:0] matrix_p21, matrix_p22, matrix_p23;
wire [15:0] matrix_p31, matrix_p32, matrix_p33;
wire post_vs_t,post_hs_t,post_clken_t;
reg [2:0] post_vs_r,post_hs_r,post_clken_r;
img_matrix_3_3_16 img_matrix_3_3_16_u0(
	.clk(clk),
	.rst_n(rst_n),
	.pre_img_data(pre_img_data),
	.pre_vs(pre_vs),
	.pre_hs(pre_hs),
	.pre_clken(pre_clken),
	//input pre_imgbit,
	.matrix_vs(post_vs_t),
	.matrix_hs(post_hs_t),
	.matrix_clken(post_clken_t),	
	.matrix_p11(matrix_p11),.matrix_p12(matrix_p12),.matrix_p13(matrix_p13),
	.matrix_p21(matrix_p21),.matrix_p22(matrix_p22),.matrix_p23(matrix_p23),  
	.matrix_p31(matrix_p31),.matrix_p32(matrix_p32),.matrix_p33(matrix_p33),  
	.matrix_img_data()
);
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p11_r,matrix_p11_g,matrix_p11_b;
wire [7:0] matrix_p12_r,matrix_p12_g,matrix_p12_b;
wire [7:0] matrix_p13_r,matrix_p13_g,matrix_p13_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p21_r,matrix_p21_g,matrix_p21_b;
wire [7:0] matrix_p22_r,matrix_p22_g,matrix_p22_b;
wire [7:0] matrix_p23_r,matrix_p23_g,matrix_p23_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p31_r,matrix_p31_g,matrix_p31_b;
wire [7:0] matrix_p32_r,matrix_p32_g,matrix_p32_b;
wire [7:0] matrix_p33_r,matrix_p33_g,matrix_p33_b;
//-----------------------------------------------------------------------------------
wire [7:0] out_r,out_g,out_b;
//-----------------------------------------------------------------------------------
rgb565_888 rgb565_888_u011(.d(matrix_p11), .r(matrix_p11_r), .g(matrix_p11_g), .b(matrix_p11_b) );
rgb565_888 rgb565_888_u012(.d(matrix_p12), .r(matrix_p12_r), .g(matrix_p12_g), .b(matrix_p12_b) );
rgb565_888 rgb565_888_u013(.d(matrix_p13), .r(matrix_p13_r), .g(matrix_p13_g), .b(matrix_p13_b) );
//-----------------------------------------------------------------------------------
rgb565_888 rgb565_888_u021(.d(matrix_p21), .r(matrix_p21_r), .g(matrix_p21_g), .b(matrix_p21_b) );
rgb565_888 rgb565_888_u022(.d(matrix_p22), .r(matrix_p22_r), .g(matrix_p22_g), .b(matrix_p22_b) );
rgb565_888 rgb565_888_u023(.d(matrix_p23), .r(matrix_p23_r), .g(matrix_p23_g), .b(matrix_p23_b) );
//-----------------------------------------------------------------------------------
rgb565_888 rgb565_888_u031(.d(matrix_p31), .r(matrix_p31_r), .g(matrix_p31_g), .b(matrix_p31_b) );
rgb565_888 rgb565_888_u032(.d(matrix_p32), .r(matrix_p32_r), .g(matrix_p32_g), .b(matrix_p32_b) );
rgb565_888 rgb565_888_u033(.d(matrix_p33), .r(matrix_p33_r), .g(matrix_p33_g), .b(matrix_p33_b) );
//-----------------------------------------------------------------------------------
img_matrix_median_3_3 img_matrix_median_3_3_R( 
	.clk(clk),.rst_n(rst_n),
	.data_in_en(1'b1),
	.matrix_p11(matrix_p11_r),.matrix_p12(matrix_p12_r),.matrix_p13(matrix_p13_r),
	.matrix_p21(matrix_p21_r),.matrix_p22(matrix_p22_r),.matrix_p23(matrix_p23_r),
	.matrix_p31(matrix_p31_r),.matrix_p32(matrix_p32_r),.matrix_p33(matrix_p33_r),
	.median(out_r)
);
img_matrix_median_3_3 img_matrix_median_3_3_G( 
	.clk(clk),.rst_n(rst_n),
	.data_in_en(1'b1),
	.matrix_p11(matrix_p11_g),.matrix_p12(matrix_p12_g),.matrix_p13(matrix_p13_g),
	.matrix_p21(matrix_p21_g),.matrix_p22(matrix_p22_g),.matrix_p23(matrix_p23_g),
	.matrix_p31(matrix_p31_g),.matrix_p32(matrix_p32_g),.matrix_p33(matrix_p33_g),
	.median(out_g)
);
img_matrix_median_3_3 img_matrix_median_3_3_B( 
	.clk(clk),.rst_n(rst_n),
	.data_in_en(1'b1),
	.matrix_p11(matrix_p11_b),.matrix_p12(matrix_p12_b),.matrix_p13(matrix_p13_b),
	.matrix_p21(matrix_p21_b),.matrix_p22(matrix_p22_b),.matrix_p23(matrix_p23_b),
	.matrix_p31(matrix_p31_b),.matrix_p32(matrix_p32_b),.matrix_p33(matrix_p33_b),
	.median(out_b)
);
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		post_vs_r<=0;
		post_hs_r<=0;
		post_clken_r<=0;
	end
	else begin
		post_vs_r<={post_vs_r[0],post_vs_t};
		post_hs_r<={post_hs_r[0],post_hs_t};
		post_clken_r<={post_clken_r[0],post_clken_t};
	end
end
assign post_vs=post_vs_r[1];
assign post_hs=post_hs_r[1];
assign post_clken=post_clken_r[1];
rgb888_565 rgb888_565_u0(.r(out_r),.g(out_g),.b(out_b), .d(post_img_data));
endmodule