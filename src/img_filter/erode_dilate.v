module erode_dilate(
	input clk,rst_n,
	input pre_vs,pre_hs,pre_imgbit,pre_clken,
	input [15:0] pre_imgdata,
	output post_vs,post_hs,post_imgbit,post_clken,
	output [15:0] post_imgdata
);
wire post_hs0,post_vs0,post_clken0,post_imgbit0;
wire [15:0] post_imgdata0;
img_erosion img_erosion_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(pre_vs),.pre_hs(pre_hs),.pre_clken(pre_clken),.pre_imgbit(pre_imgbit),
	.pre_img_data(pre_imgdata),
	.post_hs(post_hs0),.post_vs(post_vs0),.post_clken(post_clken0),
	.post_imgbit(post_imgbit0),
	.post_img_data(post_imgdata0)
);
wire post_hs1,post_vs1,post_clken1,post_imgbit1;
wire post_hs2,post_vs2,post_clken2,post_imgbit2;
wire post_hs3,post_vs3,post_clken3,post_imgbit3;
wire [15:0] post_imgdata1,post_imgdata2;
img_dilation img_dilation_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(post_vs0),.pre_hs(post_hs0),.pre_clken(post_clken0),.pre_imgbit(post_imgbit0),
	.pre_img_data(post_imgdata0),
	.post_hs(post_hs),.post_vs(post_vs),.post_clken(post_clken),
	.post_imgbit(post_imgbit),
	.post_img_data(post_imgdata) 
);
/*img_dilation img_dilation_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(pre_vs),.pre_hs(pre_hs),.pre_clken(pre_clken),.pre_imgbit(pre_imgbit),
	.pre_img_data(pre_imgdata),
	.post_hs(post_hs1),.post_vs(post_vs1),.post_clken(post_clken1),
	.post_imgbit(post_imgbit1),
	.post_img_data(post_imgdata1) 
);
img_dilation img_dilation_u1(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(post_hs1),.pre_hs(post_vs1),.pre_clken(post_clken1),.pre_imgbit(post_imgbit1),
	.pre_img_data(post_imgdata1),
	.post_hs(post_hs2),.post_vs(post_vs2),.post_clken(post_clken2),
	.post_imgbit(post_imgbit2),
	.post_img_data(post_imgdata2) 
);
img_dilation img_dilation_u2(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(post_hs2),.pre_hs(post_vs2),.pre_clken(post_clken2),.pre_imgbit(post_imgbit2),
	.pre_img_data(post_imgdata2),
	.post_hs(post_hs),.post_vs(post_vs),.post_clken(post_clken),
	.post_imgbit(post_imgbit),
	.post_img_data(post_imgdata) 
);*/
endmodule