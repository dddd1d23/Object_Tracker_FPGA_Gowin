module  histogram_equalized(
        input                   clk                             ,
        input                   rst_n                           ,
        input                   cap_vsync                       ,
        input                   cap_vld                         ,
        input         [ 7: 0]   cap_data                        ,
        input                   out_req                         ,
        output  wire  [31: 0]   dout                            ,
        output  reg             dout_vld                        ,
        output  wire            flag_finish                     ,
        //equalized
        output  reg             hist_equalized_dout_vld         ,
        output  wire  [ 7: 0]   hist_equalized_dout 
);
//======================================================================\
//************** Define Parameter and Internal Signals *****************
//======================================================================/
parameter   IH          =       600                             ;
parameter   IW          =       800                             ;
reg                             cap_vsync_r                     ;
reg     [ 1: 0]                 cap_vld_r                       ;
reg     [ 7: 0]                 cap_data_r1                     ;
reg     [ 7: 0]                 cap_data_r2                     ;
wire                            cap_vld_pos                     ;
wire                            cap_vld_neg                     ;
wire                            cap_vsync_pos                   ;
wire                            cap_vsync_neg                   ;
reg     [31: 0]                 hist_cnt                        ;
//hsync_cnt
reg     [ 9: 0]                 hsync_cnt                       ;
wire                            add_hsync_cnt                   ;
wire                            end_hsync_cnt                   ;
reg                             cnt_en                          ;
//cnt
reg     [31: 0]                 cnt                             ;
wire                            rst_cnt                         ;
wire                            inc_en                          ;
wire    [31: 0]                 cnt_value                       ;
reg     [ 8: 0]                 out_pixel                       ;
wire    [ 7: 0]                 rd_clr_addr                     ;
reg                             dout_vld_tmp                    ;

reg     [47: 0]                 mul_tmp0                        ;
reg     [47: 0]                 mul_tmp1                        ;
reg     [47: 0]                 mul_tmp2                        ;
reg     [ 7: 0]                 address_b_r1                    ;
reg     [ 7: 0]                 address_b_r2                    ;
reg     [ 7: 0]                 address_b_r3                    ;
reg     [ 1: 0]                 frame_cnt                       ;
reg                             hist_equalized_vld              ;
//dpram
wire    [ 7: 0]                 address_a                       ;
wire    [31: 0]                 data_a                          ;
wire                            wren_a                          ;
wire                            rden_a                          ;
wire    [31: 0]                 q_a                             ;
wire    [ 7: 0]                 address_b                       ;
wire    [31: 0]                 data_b                          ;
wire                            wren_b                          ;
reg                             rden_b                          ;
wire    [31: 0]                 q_b                             ;
//hist_equalized_inst
wire     [ 7: 0]                 hist_data_a                     ;
wire     [ 7: 0]                 hist_address_a                  ;
wire                            hist_wren_a                     ;
wire                            hist_rden_a                     ;
wire    [ 7: 0]                 hist_q_a                        ;
wire    [ 7: 0]                 hist_address_b                  ;
wire    [ 7: 0]                 hist_data_b                     ;
wire                            hist_wren_b                     ;
wire                            hist_rden_b                     ;
//======================================================================\
//**************************** Main Code *******************************
//======================================================================/
//打拍
always  @(posedge clk)begin
    cap_vld_r   <=  {cap_vld_r[0],cap_vld};
    cap_vsync_r <=  cap_vsync;
    cap_data_r1 <=  cap_data;
    cap_data_r2 <=  cap_data_r1;
end

assign  cap_vsync_pos   =   cap_vsync && (~cap_vsync_r);
assign  cap_vsync_neg   =   (~cap_vsync) && cap_vsync_r;
assign  cap_vld_pos     =   cap_vld_r[0] && (~cap_vld_r[1]);
assign  cap_vld_neg     =   (~cap_vld_r[0]) && cap_vld_r[1];

//hsync_cnt
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        hsync_cnt <= 0;
    end
    else if(add_hsync_cnt)begin
        if(end_hsync_cnt)
            hsync_cnt <= 0;
        else
            hsync_cnt <= hsync_cnt + 1;
    end
end

assign  add_hsync_cnt     =       cap_vld_neg;       
assign  end_hsync_cnt     =       add_hsync_cnt && hsync_cnt == IH-1;   

//cnt_en
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        cnt_en  <=  1'b0;
    end
    else if(end_hsync_cnt)begin
        cnt_en  <=  1'b0;
    end
    else if(cap_vld && (~cap_vld_r[0]))begin
        cnt_en  <=  1'b1;
    end
end

//flag_finish
assign  flag_finish     =   ~cnt_en;

//cnt
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        cnt <=  32'd0;
    end
    else if(rst_cnt)begin
        cnt <=  32'd1;
    end
    else if(inc_en)begin
        cnt <=  cnt + 1'b1;
    end
end

assign  rst_cnt     =   cap_vld_pos || (cap_data_r1 != cap_data_r2);
assign  inc_en      =   cap_vld_r[1] && (cap_data_r1 == cap_data_r2);
assign  cnt_value   =   (cnt_en == 1'b1) ? (cnt + q_b) : 32'd0;
assign  address_a   =   wren_b?address_b:cap_data_r2;
assign  data_a      =   wren_b?32'd0:cnt_value;
assign  wren_a      =   cap_vld_neg || (cap_vld_r[1] && (cap_data_r1 != cap_data_r2)) || wren_b;
assign  rden_a      =   1'b0;

//out_pixel
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        out_pixel   <=  32'd0;
    end
    else if(cnt_en)begin //在统计时不能输出
        out_pixel   <=  32'd0;
    end
    else if(out_req)begin //反相清零法，先读后清零,所以out_req得保持256*2个时钟周期
        out_pixel   <=  out_pixel + 1'b1;
    end
end

assign  rd_clr_addr =   out_pixel[8:1];
assign  address_b   =   (cnt_en == 1'b1) ? cap_data_r1 : rd_clr_addr;
assign  data_b      =   32'd0;

//rden_b
always  @(*) begin
    //cap_vld上升沿和cap_data与cap_data_r1不相等时读取
    if(cnt_en && ((cap_vld_r[0] && (~cap_vld_r[1])) || (cap_data_r1 != cap_data_r2)))begin
        rden_b  <=  1'b1;
    end
    else if(out_req && out_pixel[0] == 1'b0)begin
        rden_b  <=  1'b1;
    end
    else begin
        rden_b  <=  1'b0;
    end
end

assign  wren_b      =   (out_req == 1'b1 && out_pixel[0] == 1'b1) ? 1'b1 : 1'b0;
//dout_vld_tmp out_req有效期间，先读后清零
always  @(*) begin
    if(out_req && out_pixel[0] == 1'b0)begin
        dout_vld_tmp    <=  1'b1;
    end
    else begin
        dout_vld_tmp    <=  1'b0;
    end
end
//dout_vld 打一拍，因为输出有一拍延时（一拍延时还是两拍延时是可以选择的，这里
//两拍延时会出现问题）
always  @(posedge clk)begin
    dout_vld        <=  dout_vld_tmp;
end

//dout
assign  dout    =   q_b;

//-----------------------直方图均衡化---------------------
//hist_cnt
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        hist_cnt    <=  32'd0;
    end
    else if(cap_vsync_pos)begin
        hist_cnt    <=  32'd0;
    end
    else if(dout_vld)begin
        hist_cnt    <=  hist_cnt + dout;
    end
end

//frame_cnt //用cap_vsync的上升沿和下降沿是一样的，看一下书上的时序图就知道了
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        frame_cnt   <=  2'd0;
    end
    else if(cap_vsync_pos)begin
        frame_cnt   <=  frame_cnt + 1'b1;
    end
end

//hist_equalized_vld
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        hist_equalized_vld  <=  1'b0;
    end
    else if(frame_cnt >= 2'd2)begin
        hist_equalized_vld  <=  1'b1;
    end
end

reg [32:0] dout_vld_r;
reg [7:0] address_b_r[0:32];
//dout_vld , address_b lag 30 clocks
integer i;
always  @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        dout_vld_r<=0;
        for (i=0;i<=32;i=i+1) address_b_r[i]<=0;
    end else begin
        dout_vld_r[0]<=dout_vld;
        for (i=1;i<=32;i=i+1) dout_vld_r[i]<=dout_vld_r[i-1];
        address_b_r[0]<=address_b;
        for (i=1;i<=32;i=i+1) address_b_r[i]<=address_b_r[i-1];
    end
end
//自定义除法器div227
reg [29:0] hist_cnt1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) hist_cnt1<=0;else begin
        hist_cnt1<=hist_cnt*6'd51;
    end
end
wire [29:0] out_tmp;
div227 div227_u0(.clk(clk),.a(hist_cnt1),.b(30'd96000),.q(out_tmp),.r());
assign hist_data_a=out_tmp[7:0];
assign hist_address_a=address_b_r[31];
assign  hist_wren_a     =   dout_vld_r[31];
assign  hist_rden_a     =   1'b0;

assign  hist_address_b  =   cap_data;
assign  hist_wren_b     =   1'b0;
assign  hist_data_b     =   8'd0;
assign  hist_rden_b     =   hist_equalized_vld && cap_vld;

//hist_equalized_dout_vld
always  @(posedge clk)begin
    hist_equalized_dout_vld <=  hist_rden_b;
end

sdp00 dpram_inst(
        .dout(q_b), //output [31:0] dout
        .clka(clk), //input clka
        .cea(1'b1), //input cea
        .reseta(1'b0), //input reseta
        .wrea(wren_a), //input wrea
        .clkb(clk), //input clkb
        .ceb(1'b1), //input ceb
        .resetb(1'b0), //input resetb
        .wreb(~rden_b), //input wreb
        .oce(1'b1), //input oce
        .ada(address_a), //input [7:0] ada
        .din(data_a), //input [31:0] din
        .adb(address_b) //input [7:0] adb
    );
//直方图均衡化
sdp_256_8 sdp_256_8_u0(
        .dout(hist_equalized_dout), //output [7:0] dout
        .clka(clk), //input clka
        .cea(1'b1), //input cea
        .reseta(1'b0), //input reseta
        .wrea(hist_wren_a), //input wrea
        .clkb(clk), //input clkb
        .ceb(1'b1), //input ceb
        .resetb(1'b0), //input resetb
        .wreb(~hist_rden_b), //input wreb
        .oce(1'b1), //input oce
        .ada(hist_address_a), //input [7:0] ada
        .din(hist_data_a), //input [7:0] din
        .adb(hist_address_b) //input [7:0] adb
    );

endmodule
