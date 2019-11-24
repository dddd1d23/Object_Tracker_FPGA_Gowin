module RGB565_YCbCr_gray(
	input clk,rst_n,
	input [15:0] pre_imgdata,
	input pre_vs,pre_clken,pre_hs,
	output post_imgbit,
	output post_clken,post_vs,post_hs,
	output [15:0] post_imgdata
);
wire [4:0] cR;
wire [5:0] cG;
wire [4:0] cB;
assign cR=pre_imgdata[15:11],cG=pre_imgdata[10:5],cB=pre_imgdata[4:0];
wire [7:0] cR0;
wire [7:0] cG0;
wire [7:0] cB0;
assign cR0={cR,cR[4:2]};
assign cG0={cG,cG[5:4]};
assign cB0={cB,cB[4:2]};
reg [15:0] cR1,cR2,cR3;
reg [15:0] cG1,cG2,cG3;
reg [15:0] cB1,cB2,cB3;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		cR1<=16'd0;
        cG1<=16'd0;
        cB1<=16'd0;
		cR2<=16'd0;
        cG2<=16'd0;
        cB2<=16'd0;
		cR3<=16'd0;
        cG3<=16'd0;
        cB3<=16'd0;
	end
	else begin
		cR1<=cR0*8'd77;
		cG1<=cG0*8'd150;
		cB1<=cB0*8'd29; 
		cR2<=cR0*8'd43; 
		cG2<=cG0*8'd85; 
		cB2<=cB0*8'd128; 
        cR3<=cR0*8'd128;
        cG3<=cG0*8'd107;
        cB3<=cB0*8'd21;
	end
end
reg	[15:0] img_Y0;
reg [15:0] img_Cb0;
reg [15:0] img_Cr0;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		img_Y0<=16'd0;
		img_Cb0<=16'd0;
		img_Cr0<=16'd0;
	end
	else begin
		img_Y0<=cR1+cG1+cB1;
		img_Cb0<=cB2-cR2-cG2+16'd32768;
		img_Cr0<=cR3-cG3-cB3+16'd32768;
	end
end
reg	[7:0] img_Y1;
reg [7:0] img_Cb1;
reg [7:0] img_Cr1;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		img_Y1<=8'd0;
		img_Cb1<=8'd0;
		img_Cr1<=8'd0;
	end
	else begin
		img_Y1<=img_Y0[15:8];
		img_Cb1<=img_Cb0[15:8];
		img_Cr1<=img_Cr0[15:8];
	end
end
reg [0:0] gray_data_r;
always @(posedge clk or negedge rst_n)begin
	if (!rst_n)
		gray_data_r<='b0;
	else if(img_Cb1>73 && img_Cb1<130 && img_Cr1>130 && img_Cr1<176)
		gray_data_r<=1;
	else 
		gray_data_r<=0;
end
reg [4:0] pre_clken_r;
reg [4:0] pre_hs_r;
reg [4:0] pre_vs_r;
reg [15:0] pre_imgdata_r[0:3];
integer i;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		pre_clken_r<=4'b0;
		pre_hs_r<=4'b0;
		pre_vs_r<=4'b0;
		for (i=0;i<=3;i=i+1) pre_imgdata_r[i]<=16'b0;
	end	
	else begin
		pre_clken_r<={pre_clken_r[3:0],pre_clken};
		pre_hs_r<={pre_hs_r[3:0],pre_hs};
		pre_vs_r<={pre_vs_r[3:0],pre_vs};
		for (i=0;i<=2;i=i+1) pre_imgdata_r[i+1]<=pre_imgdata_r[i];
		pre_imgdata_r[0]<=pre_imgdata;
	end
end
assign post_clken=pre_clken_r[4];
assign post_hs=pre_hs_r[4];
assign post_vs=pre_vs_r[4];
assign post_imgbit=post_hs?gray_data_r:1'b0;
endmodule


