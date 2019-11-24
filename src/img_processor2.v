//Author:dhy0077
//e-mail:851856050@qq.com
module img_processor2(
	input clk,rst_n,
	input pre_hs,pre_vs,pre_clken,
	input [15:0] pre_imgdata,
    input [7:0] c0,c1,c2,c3,c4,c5,
    input hist_process_en,
    input mark_out_en,
    input bit_display_en,
    input gauss_en,
	output post_hs,post_vs,post_clken,
	output [15:0] post_imgdata,
    output [11:0] px,py,a
);
wire [15:0] post_imgdata1,post_imgdata1_tmp,post_imgdata0_t;
reg [15:0] post_imgdata0;
wire post_hs1,post_vs1,post_clken1;
reg post_hs0,post_vs0,post_clken0;
wire post_hs2,post_vs2,post_clken2;
wire post_hs0_t,post_vs0_t,post_clken0_t;
gauss_filter_5_5 gauss_filter_5_5_u0(
	.clk(clk),
	.rst_n(rst_n),
	.pre_hs(pre_hs), .pre_vs(pre_vs), .pre_clken(pre_clken),
	.pre_img_data(pre_imgdata), .post_img_data(post_imgdata0_t),
	.post_hs(post_hs0_t), .post_vs(post_vs0_t), .post_clken(post_clken0_t)
);
always @(*) begin
    if (gauss_en) begin
        post_hs0<=post_hs0_t;post_vs0<=post_vs0_t;
        post_clken0<=post_clken0_t;post_imgdata0<=post_imgdata0_t;
    end else begin
        post_hs0<=pre_hs;post_vs0<=pre_vs;
        post_clken0<=pre_clken;post_imgdata0<=pre_imgdata;
    end
end
/*median_filter_3_3 median_filter_3_3_u1(
	.clk(clk),
	.rst_n(rst_n),
	.pre_hs(post_hs1), .pre_vs(post_vs1), .pre_clken(post_clken1),
	.pre_img_data(post_imgdata1), .post_img_data(post_imgdata),
	.post_hs(post_hs), .post_vs(post_vs), .post_clken(post_clken)
);*/
//{8'd225,8'd130,8'd55}
wire [23:0] tmp0,tmp1,tmp2,pre_imgdata_24,post_imgdata_24,post_imgdata0_24;
wire [7:0] h0,s0,v0;
wire bit1;
rgb16_24 rgb16_24_u0(.i(post_imgdata0),.o(post_imgdata0_24));
/*rgb2hsv_top rgb2hsv_top_u0(
	.clk(clk),
	.rst_n(rst_n),
	.pre_hs(pre_hs), .pre_vs(pre_vs), .pre_clken(pre_clken),
	.pre_img(tmp0), .post_img(tmp1),
	.post_hs(post_hs1), .post_vs(post_vs1), .post_clken(post_clken1), .post_imgbit(bit1),
    .c0(c0),.c1(c1),.c2(c2),.c3(c3),.c4(c4),.c5(c5)
);*/
hist_v hist_v_u0(
    .clk(clk), .rst_n(rst_n), .pre_hs(post_hs0), .pre_vs(post_vs0),
    .pre_clken(post_clken0), .rgb(post_imgdata0_24),
    .post_hs(post_hs1), .post_vs(post_vs1), .post_clken(post_clken1),
    .post_rgb(post_imgdata_24), .post_hsv({h0,s0,v0}) , .process_en(hist_process_en)
);
rgb24_16 rgb24_16_u0(.i(post_imgdata_24),.o(post_imgdata1_tmp));
assign bit1=( (h0>=90) &&(h0<=115) && (s0>=100) && (s0<=200) && (v0>=0) && (v0<=255) ); 
assign post_imgdata1=bit_display_en?(bit1?16'b11111_111111_11111:post_imgdata1_tmp):(post_imgdata1_tmp);
//rgb565_888 tr00(.d(post_imgdata1),.r(tmp0[23:16]),.g(tmp0[15:8]),.b(tmp0[7:0]));
/*vga_mark_out vga_mark_out_u0(
    .clk(clk),
	.rst_n(rst_n),
	.pre_hs(post_hs0), .pre_vs(post_vs0), .pre_clken(post_clken0),
	.pre_img(tmp1), .post_img(tmp2),
    .px(200),.py(300),.a(32),
	.post_hs(post_hs1), .post_vs(post_vs1), .post_clken(post_clken1)
);*/
//rgb888_565 tr01(.r(tmp1[23:16]),.g(tmp1[15:8]),.b(tmp1[7:0]),.d(post_imgdata));
/*RGB565_YCbCr_gray RGB565_YCbCr_gray_u0(
    .clk(clk),.rst_n(rst_n),
    .pre_imgdata(pre_imgdata),.post_imgdata(),
    .post_imgbit(bit1),
    .pre_hs(pre_hs),.pre_vs(pre_vs),
    .pre_clken(pre_clken),
    .post_hs(post_hs1),.post_vs(post_vs1),
    .post_clken(post_clken1)
);*/
//assign post_imgdata1=bit1?16'b11111_111111_11111:tmp2;
//assign post_imgdata1=tmp2;
//assign post_clken=pre_clken,post_hs=pre_hs,post_vs=pre_vs;
//assign post_imgdata=pre_imgdata;
vga_mark_out_top vga_mark_out_top_u0(
    .clk(clk),.rst_n(rst_n),
    .pre_imgbit(bit1),.pre_hs(post_hs1),.pre_vs(post_vs1),
    .pre_clken(post_clken1),.pre_imgdata(post_imgdata1),
    .post_hs(post_hs),.post_vs(post_vs),.post_clken(post_clken),
    .post_imgdata(post_imgdata),
    .px(px),.py(py),.a(a),
    .mark_out_en(mark_out_en)
);
endmodule 

