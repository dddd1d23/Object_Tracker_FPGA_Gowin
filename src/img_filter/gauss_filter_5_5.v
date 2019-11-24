module gauss_filter_5_5
#(
	parameter [9:0]	IMG_H=10'd800,	//800*600
	parameter [9:0]	IMG_V=10'd600
)
(
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
)/* synthesis syn_dspstyle = "logic" */;
parameter g11=5'd6,g12=5'd9,g13=5'd10,g14=5'd9,g15=5'd6;
parameter g21=5'd9,g22=5'd12,g23=5'd14,g24=5'd12,g25=5'd9;
parameter g31=5'd10,g32=5'd14,g33=5'd16,g34=5'd14,g35=5'd10;
parameter g41=5'd9,g42=5'd12,g43=5'd14,g44=5'd12,g45=5'd9;
parameter g51=5'd6,g52=5'd9,g53=5'd10,g54=5'd9,g55=5'd6;
//div 4096
wire [15:0] matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15;
wire [15:0] matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25;
wire [15:0] matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35;
wire [15:0] matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45;
wire [15:0] matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55;
img_matrix_5_5_16 ut01(
	.clk(clk),
	.rst_n(rst_n),
	.pre_img_data(pre_img_data),
	.pre_vs(pre_vs),
	.pre_hs(pre_hs),
	.pre_clken(pre_clken),
	//input pre_imgbit,
	.matrix_vs(post_vs),
	.matrix_hs(post_hs),
	.matrix_clken(post_clken),	
	.matrix_p11(matrix_p11),.matrix_p12(matrix_p12),.matrix_p13(matrix_p13),.matrix_p14(matrix_p14),.matrix_p15(matrix_p15),  
	.matrix_p21(matrix_p21),.matrix_p22(matrix_p22),.matrix_p23(matrix_p23),.matrix_p24(matrix_p24),.matrix_p25(matrix_p25),  
	.matrix_p31(matrix_p31),.matrix_p32(matrix_p32),.matrix_p33(matrix_p33),.matrix_p34(matrix_p34),.matrix_p35(matrix_p35),  
	.matrix_p41(matrix_p41),.matrix_p42(matrix_p42),.matrix_p43(matrix_p43),.matrix_p44(matrix_p44),.matrix_p45(matrix_p45),  
	.matrix_p51(matrix_p51),.matrix_p52(matrix_p52),.matrix_p53(matrix_p53),.matrix_p54(matrix_p54),.matrix_p55(matrix_p55),  
	.matrix_img_data()
);
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p11_r,matrix_p11_g,matrix_p11_b;
wire [7:0] matrix_p12_r,matrix_p12_g,matrix_p12_b;
wire [7:0] matrix_p13_r,matrix_p13_g,matrix_p13_b;
wire [7:0] matrix_p14_r,matrix_p14_g,matrix_p14_b;
wire [7:0] matrix_p15_r,matrix_p15_g,matrix_p15_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p21_r,matrix_p21_g,matrix_p21_b;
wire [7:0] matrix_p22_r,matrix_p22_g,matrix_p22_b;
wire [7:0] matrix_p23_r,matrix_p23_g,matrix_p23_b;
wire [7:0] matrix_p24_r,matrix_p24_g,matrix_p24_b;
wire [7:0] matrix_p25_r,matrix_p25_g,matrix_p25_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p31_r,matrix_p31_g,matrix_p31_b;
wire [7:0] matrix_p32_r,matrix_p32_g,matrix_p32_b;
wire [7:0] matrix_p33_r,matrix_p33_g,matrix_p33_b;
wire [7:0] matrix_p34_r,matrix_p34_g,matrix_p34_b;
wire [7:0] matrix_p35_r,matrix_p35_g,matrix_p35_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p41_r,matrix_p41_g,matrix_p41_b;
wire [7:0] matrix_p42_r,matrix_p42_g,matrix_p42_b;
wire [7:0] matrix_p43_r,matrix_p43_g,matrix_p43_b;
wire [7:0] matrix_p44_r,matrix_p44_g,matrix_p44_b;
wire [7:0] matrix_p45_r,matrix_p45_g,matrix_p45_b;
//-----------------------------------------------------------------------------------
wire [7:0] matrix_p51_r,matrix_p51_g,matrix_p51_b;
wire [7:0] matrix_p52_r,matrix_p52_g,matrix_p52_b;
wire [7:0] matrix_p53_r,matrix_p53_g,matrix_p53_b;
wire [7:0] matrix_p54_r,matrix_p54_g,matrix_p54_b;
wire [7:0] matrix_p55_r,matrix_p55_g,matrix_p55_b;
//-----------------------------------------------------------------------------------
rgb565_888 u011(.d(matrix_p11), .r(matrix_p11_r), .g(matrix_p11_g), .b(matrix_p11_b) );
rgb565_888 u012(.d(matrix_p12), .r(matrix_p12_r), .g(matrix_p12_g), .b(matrix_p12_b) );
rgb565_888 u013(.d(matrix_p13), .r(matrix_p13_r), .g(matrix_p13_g), .b(matrix_p13_b) );
rgb565_888 u014(.d(matrix_p14), .r(matrix_p14_r), .g(matrix_p14_g), .b(matrix_p14_b) );
rgb565_888 u015(.d(matrix_p15), .r(matrix_p15_r), .g(matrix_p15_g), .b(matrix_p15_b) );
//-----------------------------------------------------------------------------------
rgb565_888 u021(.d(matrix_p21), .r(matrix_p21_r), .g(matrix_p21_g), .b(matrix_p21_b) );
rgb565_888 u022(.d(matrix_p22), .r(matrix_p22_r), .g(matrix_p22_g), .b(matrix_p22_b) );
rgb565_888 u023(.d(matrix_p23), .r(matrix_p23_r), .g(matrix_p23_g), .b(matrix_p23_b) );
rgb565_888 u024(.d(matrix_p24), .r(matrix_p24_r), .g(matrix_p24_g), .b(matrix_p24_b) );
rgb565_888 u025(.d(matrix_p25), .r(matrix_p25_r), .g(matrix_p25_g), .b(matrix_p25_b) );
//-----------------------------------------------------------------------------------
rgb565_888 u031(.d(matrix_p31), .r(matrix_p31_r), .g(matrix_p31_g), .b(matrix_p31_b) );
rgb565_888 u032(.d(matrix_p32), .r(matrix_p32_r), .g(matrix_p32_g), .b(matrix_p32_b) );
rgb565_888 u033(.d(matrix_p33), .r(matrix_p33_r), .g(matrix_p33_g), .b(matrix_p33_b) );
rgb565_888 u034(.d(matrix_p34), .r(matrix_p34_r), .g(matrix_p34_g), .b(matrix_p34_b) );
rgb565_888 u035(.d(matrix_p35), .r(matrix_p35_r), .g(matrix_p35_g), .b(matrix_p35_b) );
//-----------------------------------------------------------------------------------
rgb565_888 u041(.d(matrix_p41), .r(matrix_p41_r), .g(matrix_p41_g), .b(matrix_p41_b) );
rgb565_888 u042(.d(matrix_p42), .r(matrix_p42_r), .g(matrix_p42_g), .b(matrix_p42_b) );
rgb565_888 u043(.d(matrix_p43), .r(matrix_p43_r), .g(matrix_p43_g), .b(matrix_p43_b) );
rgb565_888 u044(.d(matrix_p44), .r(matrix_p44_r), .g(matrix_p44_g), .b(matrix_p44_b) );
rgb565_888 u045(.d(matrix_p45), .r(matrix_p45_r), .g(matrix_p45_g), .b(matrix_p45_b) );
//-----------------------------------------------------------------------------------
rgb565_888 u051(.d(matrix_p51), .r(matrix_p51_r), .g(matrix_p51_g), .b(matrix_p51_b) );
rgb565_888 u052(.d(matrix_p52), .r(matrix_p52_r), .g(matrix_p52_g), .b(matrix_p52_b) );
rgb565_888 u053(.d(matrix_p53), .r(matrix_p53_r), .g(matrix_p53_g), .b(matrix_p53_b) );
rgb565_888 u054(.d(matrix_p54), .r(matrix_p54_r), .g(matrix_p54_g), .b(matrix_p54_b) );
rgb565_888 u055(.d(matrix_p55), .r(matrix_p55_r), .g(matrix_p55_g), .b(matrix_p55_b) );
//-----------------------------------------------------------------------------------
wire [15:0] matrix_w11_r,matrix_w11_g,matrix_w11_b;
assign matrix_w11_r=matrix_p11_r*g11,matrix_w11_g=matrix_p11_g*g11,matrix_w11_b=matrix_p11_b*g11;
wire [15:0] matrix_w12_r,matrix_w12_g,matrix_w12_b;
assign matrix_w12_r=matrix_p12_r*g12,matrix_w12_g=matrix_p12_g*g12,matrix_w12_b=matrix_p12_b*g12;
wire [15:0] matrix_w13_r,matrix_w13_g,matrix_w13_b;
assign matrix_w13_r=matrix_p13_r*g13,matrix_w13_g=matrix_p13_g*g13,matrix_w13_b=matrix_p13_b*g13;
wire [15:0] matrix_w14_r,matrix_w14_g,matrix_w14_b;
assign matrix_w14_r=matrix_p14_r*g14,matrix_w14_g=matrix_p14_g*g14,matrix_w14_b=matrix_p14_b*g14;
wire [15:0] matrix_w15_r,matrix_w15_g,matrix_w15_b;
assign matrix_w15_r=matrix_p15_r*g15,matrix_w15_g=matrix_p15_g*g15,matrix_w15_b=matrix_p15_b*g15;
//-----------------------------------------------------------------------------------
wire [15:0] matrix_w21_r,matrix_w21_g,matrix_w21_b;
assign matrix_w21_r=matrix_p21_r*g21,matrix_w21_g=matrix_p21_g*g21,matrix_w21_b=matrix_p21_b*g21;
wire [15:0] matrix_w22_r,matrix_w22_g,matrix_w22_b;
assign matrix_w22_r=matrix_p22_r*g22,matrix_w22_g=matrix_p22_g*g12,matrix_w22_b=matrix_p22_b*g22;
wire [15:0] matrix_w23_r,matrix_w23_g,matrix_w23_b;
assign matrix_w23_r=matrix_p23_r*g23,matrix_w23_g=matrix_p23_g*g23,matrix_w23_b=matrix_p23_b*g23;
wire [15:0] matrix_w24_r,matrix_w24_g,matrix_w24_b;
assign matrix_w24_r=matrix_p24_r*g24,matrix_w24_g=matrix_p24_g*g24,matrix_w24_b=matrix_p24_b*g24;
wire [15:0] matrix_w25_r,matrix_w25_g,matrix_w25_b;
assign matrix_w25_r=matrix_p25_r*g25,matrix_w25_g=matrix_p25_g*g25,matrix_w25_b=matrix_p25_b*g25;
//-----------------------------------------------------------------------------------
wire [15:0] matrix_w31_r,matrix_w31_g,matrix_w31_b;
assign matrix_w31_r=matrix_p31_r*g31,matrix_w31_g=matrix_p31_g*g31,matrix_w31_b=matrix_p31_b*g31;
wire [15:0] matrix_w32_r,matrix_w32_g,matrix_w32_b;
assign matrix_w32_r=matrix_p32_r*g32,matrix_w32_g=matrix_p32_g*g32,matrix_w32_b=matrix_p32_b*g32;
wire [15:0] matrix_w33_r,matrix_w33_g,matrix_w33_b;
assign matrix_w33_r=matrix_p33_r*g33,matrix_w33_g=matrix_p33_g*g33,matrix_w33_b=matrix_p33_b*g33;
wire [15:0] matrix_w34_r,matrix_w34_g,matrix_w34_b;
assign matrix_w34_r=matrix_p34_r*g34,matrix_w34_g=matrix_p34_g*g34,matrix_w34_b=matrix_p34_b*g34;
wire [15:0] matrix_w35_r,matrix_w35_g,matrix_w35_b;
assign matrix_w35_r=matrix_p35_r*g35,matrix_w35_g=matrix_p35_g*g35,matrix_w35_b=matrix_p35_b*g35;
//-----------------------------------------------------------------------------------
wire [15:0] matrix_w41_r,matrix_w41_g,matrix_w41_b;
assign matrix_w41_r=matrix_p41_r*g41,matrix_w41_g=matrix_p41_g*g41,matrix_w41_b=matrix_p41_b*g41;
wire [15:0] matrix_w42_r,matrix_w42_g,matrix_w42_b;
assign matrix_w42_r=matrix_p42_r*g42,matrix_w42_g=matrix_p42_g*g42,matrix_w42_b=matrix_p42_b*g42;
wire [15:0] matrix_w43_r,matrix_w43_g,matrix_w43_b;
assign matrix_w43_r=matrix_p43_r*g43,matrix_w43_g=matrix_p43_g*g43,matrix_w43_b=matrix_p43_b*g43;
wire [15:0] matrix_w44_r,matrix_w44_g,matrix_w44_b;
assign matrix_w44_r=matrix_p44_r*g44,matrix_w44_g=matrix_p44_g*g44,matrix_w44_b=matrix_p44_b*g44;
wire [15:0] matrix_w45_r,matrix_w45_g,matrix_w45_b;
assign matrix_w45_r=matrix_p45_r*g45,matrix_w45_g=matrix_p45_g*g45,matrix_w45_b=matrix_p45_b*g45;
//-----------------------------------------------------------------------------------
wire [15:0] matrix_w51_r,matrix_w51_g,matrix_w51_b;
assign matrix_w51_r=matrix_p51_r*g51,matrix_w51_g=matrix_p51_g*g51,matrix_w51_b=matrix_p51_b*g51;
wire [15:0] matrix_w52_r,matrix_w52_g,matrix_w52_b;
assign matrix_w52_r=matrix_p52_r*g52,matrix_w52_g=matrix_p52_g*g52,matrix_w52_b=matrix_p52_b*g52;
wire [15:0] matrix_w53_r,matrix_w53_g,matrix_w53_b;
assign matrix_w53_r=matrix_p53_r*g53,matrix_w53_g=matrix_p53_g*g53,matrix_w53_b=matrix_p53_b*g53;
wire [15:0] matrix_w54_r,matrix_w54_g,matrix_w54_b;
assign matrix_w54_r=matrix_p54_r*g54,matrix_w54_g=matrix_p54_g*g54,matrix_w54_b=matrix_p54_b*g54;
wire [15:0] matrix_w55_r,matrix_w55_g,matrix_w55_b;
assign matrix_w55_r=matrix_p55_r*g55,matrix_w55_g=matrix_p55_g*g55,matrix_w55_b=matrix_p55_b*g55;
//-----------------------------------------------------------------------------------
reg [19:0] l1_r,l2_r,l3_r,l4_r,l5_r;
reg [19:0] l1_g,l2_g,l3_g,l4_g,l5_g;
reg [19:0] l1_b,l2_b,l3_b,l4_b,l5_b;
reg [21:0] r_s,g_s,b_s;
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		l1_r<=0;l2_r<=0;l3_r<=0;l4_r<=0;l5_r<=0;
		l1_g<=0;l2_g<=0;l3_g<=0;l4_g<=0;l5_g<=0;
		l1_b<=0;l2_b<=0;l3_b<=0;l4_b<=0;l5_b<=0;
	end else 
	begin
		l1_r<=matrix_w11_r+matrix_w12_r+matrix_w13_r+matrix_w14_r+matrix_w15_r;
		l2_r<=matrix_w21_r+matrix_w22_r+matrix_w23_r+matrix_w24_r+matrix_w25_r;
		l3_r<=matrix_w31_r+matrix_w32_r+matrix_w33_r+matrix_w34_r+matrix_w35_r;
		l4_r<=matrix_w41_r+matrix_w42_r+matrix_w43_r+matrix_w44_r+matrix_w45_r;
		l5_r<=matrix_w51_r+matrix_w52_r+matrix_w53_r+matrix_w54_r+matrix_w55_r;
		//--------------------------------------------------------------------------------
		l1_g<=matrix_w11_g+matrix_w12_g+matrix_w13_g+matrix_w14_g+matrix_w15_g;
		l2_g<=matrix_w21_g+matrix_w22_g+matrix_w23_g+matrix_w24_g+matrix_w25_g;
		l3_g<=matrix_w31_g+matrix_w32_g+matrix_w33_g+matrix_w34_g+matrix_w35_g;
		l4_g<=matrix_w41_g+matrix_w42_g+matrix_w43_g+matrix_w44_g+matrix_w45_g;
		l5_g<=matrix_w51_g+matrix_w52_g+matrix_w53_g+matrix_w54_g+matrix_w55_g;
		//--------------------------------------------------------------------------------
		l1_b<=matrix_w11_b+matrix_w12_b+matrix_w13_b+matrix_w14_b+matrix_w15_b;
		l2_b<=matrix_w21_b+matrix_w22_b+matrix_w23_b+matrix_w24_b+matrix_w25_b;
		l3_b<=matrix_w31_b+matrix_w32_b+matrix_w33_b+matrix_w34_b+matrix_w35_b;
		l4_b<=matrix_w41_b+matrix_w42_b+matrix_w43_b+matrix_w44_b+matrix_w45_b;
		l5_b<=matrix_w51_b+matrix_w52_b+matrix_w53_b+matrix_w54_b+matrix_w55_b;
	end
end
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		r_s<=0;g_s<=0;b_s<=0;
	end else 
	begin
		r_s<=l1_r+l2_r+l3_r+l4_r+l5_r;
		g_s<=l1_g+l2_g+l3_g+l4_g+l5_g;
		b_s<=l1_b+l2_b+l3_b+l4_b+l5_b;
	end
end
//div 4096
wire [7:0] o_r,o_g,o_b;
assign o_r=r_s[15:8];
assign o_g=g_s[15:8];
assign o_b=b_s[15:8];
rgb888_565 uw01(.r(o_r),.g(o_g),.b(o_b),.d(post_img_data));
endmodule
