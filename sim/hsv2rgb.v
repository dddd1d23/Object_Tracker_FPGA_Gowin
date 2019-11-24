//Author:dhy0077
//latency=28
module hsv2rgb(
	input clk,rst_n,
	input [23:0] hsv,
	input pre_hs,pre_vs,pre_clken,
	output post_hs,post_vs,post_clken,
	//output [23:0] rgb
	//output [23:0] p_1,q_1,t_1
	output [23:0] post_rgb,
	output [23:0] post_hsv
);
wire [8:0] h;
wire [7:0] s,v;
wire [23:0] p_1,q_1,t_1;
reg [7:0] s0,v0,f0,s1,v1,f1,s2,v2,f2;
reg [15:0] v0s0,v0255,v0s0_1,v0255_1;
reg [23:0] v0s0f0,v025560,v0s060,p_0,q_0,t_0;
reg [3:0] I0,I1,I2,I3;
assign h={hsv[23:16],1'b0};
assign s=hsv[15:8];
assign v=hsv[7:0];
//step 1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		I0<=0;s0<=0;v0<=0;f0<=0;
	end else if (h<60) begin f0<=h;s0<=s;v0<=v;I0<=0;end
	else if (h<120) begin f0<=h-60;s0<=s;v0<=v;I0<=1;end
	else if (h<180) begin f0<=h-120;s0<=s;v0<=v;I0<=2;end
	else if (h<240) begin f0<=h-180;s0<=s;v0<=v;I0<=3;end
	else if (h<300) begin f0<=h-240;s0<=s;v0<=v;I0<=4;end
	else begin f0<=h-300;s0<=s;v0<=v;I0<=5;end
end
reg [23:0] hsv_r[0:32];
reg [3:0] I_r[0:32];
reg [32:0] clken_r,hs_r,vs_r;
wire [3:0] I_post;
wire [7:0] t_2,p_2,q_2;
integer i;
//signal delay
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i=0;i<=32;i=i+1) hsv_r[i]<=0;
		for (i=0;i<=32;i=i+1) I_r[i]<=0;
		clken_r<=0;hs_r<=0;vs_r<=0;
	end else begin
		hsv_r[0]<=hsv;I_r[0]<=I0;clken_r[0]<=pre_clken;hs_r[0]<=pre_hs;vs_r[0]<=pre_vs;
		for (i=1;i<=32;i=i+1) hsv_r[i]<=hsv_r[i-1];
		for (i=1;i<=32;i=i+1) I_r[i]<=I_r[i-1];
		for (i=1;i<=32;i=i+1) hs_r[i]<=hs_r[i-1];
		for (i=1;i<=32;i=i+1) vs_r[i]<=vs_r[i-1];
		for (i=1;i<=32;i=i+1) clken_r[i]<=clken_r[i-1];
	end
end
assign post_clken=clken_r[28],post_hs=hs_r[28],post_vs=vs_r[28];
//step 2
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		v0s0<=0;v0255<=0;
		v1<=0;s1<=0;f1<=0;I1<=0;
		v0s0_1<=0;v0255_1<=0;
	end else begin
		v1<=v0;s1<=s0;f1<=f0;I1<=I0; 
		v0s0<=v0*s0;v0255<=v0*255;
		v0s0_1<=v0s0;v0255_1<=v0255;
	end
end
//step 3
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		v0s060<=0;v0s0f0<=0;v025560<=0;
		v2<=0;s2<=0;f2<=0;I2<=0;
	end else begin
		v2<=v1;s2<=s1;f2<=f1;I2<=I1;
		v0s0f0<=v0s0*f1;v025560<=v0255*60;v0s060<=v0s0*60;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		p_0<=0;q_0<=0;t_0<=0;
	end else begin
		p_0<=v0255_1-v0s0_1;
		q_0<=v025560-v0s0f0;
		t_0<=v025560-v0s060+v0s0f0;
	end
end
reg [7:0] r,g,b;
wire [7:0] v_post;
assign I_post=I_r[26];
assign v_post=hsv_r[27][7:0];
assign post_rgb={r,g,b},post_hsv=hsv_r[28];
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r<=0;g<=0;b<=0;
	end else begin
		case (I_post)
		4'd0:{r,g,b}<={v_post,t_2,p_2};
		4'd1:{r,g,b}<={q_2,v_post,p_2};
		4'd2:{r,g,b}<={p_2,v_post,t_2};
		4'd3:{r,g,b}<={p_2,q_2,v_post};
		4'd4:{r,g,b}<={t_2,p_2,v_post};
		4'd5:{r,g,b}<={v_post,p_2,q_2};
		endcase
	end
end
div225 div225_hsv2rgb_u0(
	.clk(clk),.a(p_0),.b(24'd255),.q(p_1),.r()
);
div225 div225_hsv2rgb_u1(
	.clk(clk),.a(q_0),.b(24'd15300),.q(q_1),.r()
);
div225 div225_hsv2rgb_u2(
	.clk(clk),.a(t_0),.b(24'd15300),.q(t_1),.r()
);
assign p_2=p_1[7:0],q_2=q_1[7:0],t_2=t_1[7:0];
endmodule