module vga_mark_out_top(
	input clk,rst_n,
	input pre_imgbit,pre_hs,pre_vs,pre_clken,
    input mark_out_en,
	input [15:0] pre_imgdata,
	output reg post_hs,post_vs,post_clken,
	output [15:0] post_imgdata,
    output [11:0] px,py,a
);
wire post_clken0,post_clken1,post_hs0,post_hs1,post_vs0,post_vs1,post_hs2,post_vs2,post_clken2;
wire [15:0] post_imgdata0,post_imgdata1;
wire [23:0] post_img2,post_img1;
reg [23:0] post_img_out;
erode_dilate erode_dilate_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(pre_vs),.pre_hs(pre_hs),.pre_clken(pre_clken),.pre_imgbit(pre_imgbit),
	.pre_imgdata(pre_imgdata),
	.post_hs(post_hs0),.post_vs(post_vs0),.post_clken(post_clken0),
	.post_imgbit(post_imgbit0),
	.post_imgdata(post_imgdata0)
);
box_calculator box_calculator_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(post_vs0),.pre_hs(post_hs0),.pre_clken(post_clken0),.pre_imgbit(post_imgbit0),
	.pre_imgdata(post_imgdata0),
	.post_vs(post_vs1),.post_hs(post_hs1),.post_clken(post_clken1),
	.post_imgbit(post_imgbit1),
	.post_imgdata(post_imgdata1),
	.px(px),.py(py),.a(a)
);
rgb16_24 rgb16_24_u0(.i(post_imgdata1),.o(post_img1));
vga_mark_out vga_mark_out_u0(
	.clk(clk),.rst_n(rst_n),
	.px(px),.py(py),.a(a),
	.pre_vs(post_vs1),.pre_hs(post_hs1),.pre_clken(post_clken1),
	.pre_img(post_img1),
	.post_vs(post_vs2),.post_hs(post_hs2),.post_clken(post_clken2),
	.post_img(post_img2)
);
always @(*) begin
    if (mark_out_en) begin
        post_vs=post_vs2;post_hs=post_hs2;post_clken=post_clken2;
        post_img_out=post_img2;
    end else begin
        post_vs=post_vs1;post_hs=post_hs1;post_clken=post_clken1;
        post_img_out=post_img1;
    end
end
//assign post_vs=post_vs1,post_hs=post_hs1,post_clken=post_clken1;
//assign post_img2=post_img1;
rgb24_16 rgb24_16_u0(.i(post_img_out),.o(post_imgdata));
endmodule



