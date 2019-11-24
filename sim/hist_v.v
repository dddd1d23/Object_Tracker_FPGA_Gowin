module hist_v(
	input clk,rst_n,pre_vs,pre_hs,pre_clken,
    input [23:0] rgb,
    output post_vs,post_hs,post_clken,
    output [23:0] post_hsv,post_rgb,
    input process_en
);
wire post_vs1,post_hs1,post_clken1;
wire post_vs2,post_hs2,post_clken2;
wire [7:0] h0,s0,v0,v1,v_processed;
reg [7:0] h1,s1,v_delay;
rgb2hsv_top rgb2hsv_top_u0(
	.clk(clk),.rst_n(rst_n),
	.pre_vs(pre_vs),.pre_hs(pre_hs),.pre_clken(pre_clken),
	.pre_img(rgb),
	.post_vs(post_vs1),.post_hs(post_hs1),.post_clken(post_clken1),
	.post_img(),
	.h0(h0),.s0(s0),.v0(v0)
);
histogram_equalized_top histogram_equalized_top_u0(
    .clk(clk),.rst_n(rst_n),
    .pre_vs(post_vs1),.pre_hs(post_hs1),.pre_clken(post_clken1),
    .pre_imgdata(v0),
    .post_vs(post_vs2),.post_hs(post_hs2),.post_clken(post_clken2),
    .post_imgdata(v_processed)
);
//h0,s0 延迟一个时钟周期
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin h1<=0;s1<=0;v_delay<=0;end 
	else begin
		h1<=h0;s1<=s0;v_delay<=v0;
	end
end
assign v1=process_en?v_processed:v_delay;
hsv2rgb hsv2rgb_u0(
	.clk(clk),.rst_n(rst_n),
	.hsv({h1,s1,v1}),
	.pre_vs(post_vs2),.pre_hs(post_hs2),.pre_clken(post_clken2),
	.post_vs(post_vs),.post_hs(post_hs),.post_clken(post_clken),
	.post_rgb(post_rgb),
	.post_hsv(post_hsv)
);
endmodule