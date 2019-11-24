//Author:dhy0077
//latency=17
module rgb2hsv_top(
	input clk,
	input rst_n,
	input [23:0] pre_img,
	input pre_vs,
	input pre_hs,
	input pre_clken,
    input [7:0] c0,c1,c2,c3,c4,c5,
	output reg [7:0] h0,
	output reg [7:0] s0,
	output reg [7:0] v0,
	output [23:0] post_img,

	output post_hs,
	output post_clken,
	output post_vs,
    output post_imgbit
);
reg [18:0] pre_vs_r,pre_hs_r,pre_clken_r;
reg [23:0] pre_img_r[0:18];
//reg [7:0] h0,s0,v0;
wire [23:0] post_img_t;
integer i;
//hs,vs,clken:lag 17 clocks
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        pre_vs_r<=0;pre_hs_r<=0;pre_clken_r<=0;
        for (i=2;i<=18;i=i+1) pre_img_r[i]<=0;
    end else begin
        pre_vs_r[1]<=pre_vs;
        pre_hs_r[1]<=pre_hs;
        pre_clken_r[1]<=pre_clken;
        pre_img_r[1]<=pre_img;
        for (i=2;i<=18;i=i+1) pre_vs_r[i]<=pre_vs_r[i-1];
        for (i=2;i<=18;i=i+1) pre_hs_r[i]<=pre_hs_r[i-1];
        for (i=2;i<=18;i=i+1) pre_clken_r[i]<=pre_clken_r[i-1];
        for (i=2;i<=18;i=i+1) pre_img_r[i]<=pre_img_r[i-1];
    end
end
assign post_img_t=pre_img_r[18];
assign post_clken=pre_clken_r[18];
assign post_vs=pre_vs_r[18];
assign post_hs=pre_hs_r[18];
//---------------------------------------------------------------------------
wire [7:0] r0,g0,b0;
assign r0=pre_img[23:16],g0=pre_img[15:8],b0=pre_img[7:0];
reg [7:0] max,min; // lag 1 clock
//Step 1
//find max
always @(*) begin
	if (r0>=g0)
	  begin
	  	if (r0>=b0) max=r0;
	  	else max=b0;
	  end else 
	begin //r0<g0
		if (g0>=b0) max=g0;
		else max=b0;
	end
end
//find min
always @(*) begin
	if (r0<=g0)
	  begin
	  	if (r0<=b0) min=r0;
	  	else min=b0;
	  end else 
	begin //r0>g0
		if (g0<=b0) min=g0;
		else min=b0;
	end
end
reg [15:0] h_dividend,s_dividend;
reg [7:0] h_divisor,s_divisor;
wire [15:0] h_quotient;
wire [15:0] s_quotient;
reg [8:0] h_add[0:18];
reg [7:0] v[0:18];
reg [18:0] sign_f;
//Step 2 prepare for division
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    	sign_f[0]<=0;
		h_dividend<=0;
		h_divisor<=1;
		h_add[0]<=0;
		s_dividend<=0;
		s_divisor<=1;
		v[0]<=0;
    end else 
	if (max==min) begin
		sign_f[0]<=0;
		h_dividend<=0;
		h_divisor<=1;
		h_add[0]<=0;
		s_dividend<=0;
		s_divisor<=1;
		v[0]<=max;
	end else if (max==r0 && g0>=b0) begin
		sign_f[0]<=0;
		h_dividend<=60*(g0-b0);
		h_divisor<=max-min;
		h_add[0]<=0;
		s_dividend<=255*(max-min);
		s_divisor<=max;
		v[0]<=max;
	end else if (max==r0 && g0<b0) begin
		sign_f[0]<=1;
		h_dividend<=60*(b0-g0);
		h_divisor<=max-min;
		h_add[0]<=360;
		s_dividend<=255*(max-min);
		s_divisor<=max;
		v[0]<=max;
	end else if (max==g0) begin
		if (b0>=r0) begin
			sign_f[0]<=0;
			h_dividend<=60*(b0-r0);
		end else begin
			sign_f[0]<=1;
			h_dividend<=60*(r0-b0);
		end
		h_divisor<=max-min;
		h_add[0]<=120;
		s_dividend<=255*(max-min);
		s_divisor<=max;
		v[0]<=max;
	end else if (max==b0) begin
		if (r0>=g0) begin
			sign_f[0]<=0;
			h_dividend<=60*(r0-g0);
		end else 
		begin
			sign_f[0]<=1;
			h_dividend<=60*(g0-r0);
		end
		h_divisor<=max-min;
		h_add[0]<=240;
		s_dividend<=255*(max-min);
		s_divisor<=max;
		v[0]<=max;
	end
end
wire [15:0] h_quotient_0,s_quotient_0;
//Step 3 divide
//latency of div222=15
div222 udivh(
	.clk(clk),
	.a(h_dividend),
	.b({8'b0,h_divisor}),
	.q(h_quotient_0),
	.r()
);
div222 udivs(
	.clk(clk),
	.a(s_dividend),
	.b({8'b0,s_divisor}),
	.q(s_quotient_0),
	.r()
);
//v,sign_f,h_add:lag 16 clocks
integer j;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j=1;j<=17;j=j+1) v[j]<=0;
        for (j=1;j<=17;j=j+1) sign_f[j]<=0;
        for (j=1;j<=17;j=j+1) h_add[j]<=0;
    end else 
    begin
        for (j=1;j<=17;j=j+1) h_add[j]<=h_add[j-1];
        for (j=1;j<=17;j=j+1) v[j]<=v[j-1];
        for (j=1;j<=17;j=j+1) sign_f[j]<=sign_f[j-1];
    end
end
assign h_quotient=h_quotient_0;
assign s_quotient=s_quotient_0;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin h0<=0;s0<=0;v0<=0;end
	else begin
		if (sign_f[16]==0) h0<=(h_quotient+h_add[16])/2;
		else h0<=(h_add[16]-h_quotient)/2;
		s0<=s_quotient;
		v0<=v[16];
	end
end
//pick out
//assign pick=( (h0>=50) &&(h0<=70) && (s0>=40) && (s0<=110) && (v0>=0) && (v0<=255) );
//assign pick=0;{8'd255,8'd0,8'd255}
//assign pick=0;
assign pick=( (h0>=50) &&(h0<=70) && (s0>=40) && (s0<=110) && (v0>=0) && (v0<=255) );
assign post_img=post_img_t;
assign post_imgbit=pick;
//assign post_img=pick?{8'd255,8'd255,8'd0}:post_img_t;
//assign post_img={h0,s0,v0};
//assign post_img=post_img_t?post_img_t:24'b0;
//assign post_img=post_img_t;
/*always @(posedge clk) begin999999999999999999999999999999i
	if (post_img[23:16]==8'd43 && post_img[15:8]==8'd140 && post_img[7:0]== 8'd213) 
	begin
		$display ("%d %d %d",h0,s0,v0);
		//if (h0==8'd137) $stop;
	end
end*/
endmodule
