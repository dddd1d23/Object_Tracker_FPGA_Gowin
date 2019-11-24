

`include "vfb_defines.v"

module led_test2
(
	input            	I_clk_50m 	   ,
	input            	I_rst_n   	   ,
	input      [1:0]    I_sw           ,
	output     [3:0] 	O_led     	   ,
    //output reg [20:0] wwcnt,frame_cnt,
    output [7:0] cmos_fps_rate,
    output cmos_frame_vsync,
	//
    input [7:0] cmos_d,
	output cmos_sclk,
	inout cmos_sdat,
    output cmos_rst_n,cmos_xclk,
    input cmos_vsync,cmos_href,cmos_pclk,
    //
    output        vga_r5,vga_r6,vga_r7,vga_r8,vga_r9,
    output vga_g4,vga_g5,vga_g6,vga_g7,vga_g8,vga_g9,
    output        vga_b5,vga_b6,vga_b7,vga_b8,vga_b9,
    output vga_hs,vga_vs,vga_clk,vga_blank,
    //
    output uart_tx,
    //
	//output     [7:0]	O_data_r       ,//O_f_gpio 
	//output     [7:0]	O_data_g       ,//O_f_gpio
	//output     [7:0]	O_data_b       ,//O_f_gpio
	//output              O_vs           ,//O_h_gpio
	//output              O_hs           ,//O_h_gpio
	//output              O_clk          ,//O_h_gpio
	//output              O_sync_n       ,//O_h_gpio
	//output              O_blank_n      ,//O_h_gpio  //O_de
	output     [1:0]    O_psram_ck     ,
	output     [1:0]    O_psram_ck_n   ,
	inout      [1:0]    IO_psram_rwds  ,
	inout      [15:0]   IO_psram_dq    ,
	output     [1:0]    O_psram_reset_n,
	output     [1:0]    O_psram_cs_n   
);
wire [7:0] O_data_r,O_data_g,O_data_b;
wire [7:0] vga_r,vga_g,vga_b;
wire        clk_24M;
//=========================================================
//SRAM parameters
parameter IMAGE_SIZE          = 24'h10_0000;//--2^19*32=16Mbit  //frame base address
parameter BURST_WRITE_LENGTH  = 256;  //bytes //对应最大burst number 256*8/64=32(突发长度128)
parameter BURST_READ_LENGTH   = 256;  //bytes
parameter ADDR_WIDTH          = 21;    //总容量=2^21*32bit = 64Mbit ??
parameter DATA_WIDTH          = 64;   //与生成PSRAM IP有关，此psram 64Mbit, x16， 则用户数据位宽固定64bit
parameter VIDEO_WIDTH	      = `DEF_VIDEO_WIDTH;  
//-------------------------------------------------

//-------------------------------------------------
//ddr
wire        dma_clk  ;  

wire        memory_clk;
wire        pll_lock  ;

//-------------------------------------------------
//memory interface
wire        cmd           ;
wire        cmd_en        ;
wire [20:0] addr          ;//[ADDR_WIDTH-1:0]
wire [63:0] wr_data       ;//[DATA_WIDTH-1:0]
wire [7:0]  data_mask     ;
wire        rd_data_valid ;
wire [63:0] rd_data       ;//[DATA_WIDTH-1:0]
wire        init_done     ;


//===========================================
//-----------------------------------
wire        pixel_clk; //65MHz
wire        clk_100m;
wire        pll_locked;
wire        pll0_locked;
wire        pll1_locked;

wire        ddr_rstn;

wire        ch0_vs_in ;
wire        ch0_hs_in ;
wire        ch0_de_in ;
wire [ 7:0] ch0_data_r;
wire [ 7:0] ch0_data_g;
wire [ 7:0] ch0_data_b;

//-------------------------
//frame buffer in
wire                   ch0_vfb_clk_in ;
wire                   ch0_vfb_vs_in  ;
wire                   ch0_vfb_de_in  ;
wire [VIDEO_WIDTH-1:0] ch0_vfb_data_in;

//-------------------
//syn_code
wire                   syn_off0_re;  // ofifo read enable signal
wire                   syn_off0_vs;
wire                   syn_off0_hs;
                       
wire                   off0_syn_de  ;
wire [VIDEO_WIDTH-1:0] off0_syn_data;

//==============================================
wire cmos_frame_clken,cmos_frame_href,frame_sync_flag,cmos_vsync_begin;
wire [15:0] cmos_frame_data;
wire c_done;
//-------------------------------
assign O_led[0] = ~init_done;
assign O_led[1] = ~ddr_rstn;   
assign O_led[2] = c_done;    
assign O_led[3] = c_done;  
assign cmos_rst_n = 1'b1;
//==============================================
I2C_OV5640_Init_RGB565 inst0(
	.clk(I_clk_50m),
	.rst_n(I_rst_n),
    .strobe_on(I_sw[1]),
	.i2c_sclk(cmos_sclk),
	.i2c_sdat(cmos_sdat),
	.config_done(c_done)
);
//==============================================
key_debounce key_debounce_inst
(
	.clk   (I_clk_50m     ),
	.rst_n (1'b1          ),
	.key1_n(I_rst_n       ),
	.key_1 (ddr_rstn      )
	
);

//===========================================================================
//------------------------------------------------------------------
//generate pixel clock
/*pix_pll pix_pll_inst
(
	.clkout (pixel_clk ), //output clkout //65MHz
	.lock   (pll_locked), //output lock
	.reset  (!I_rst_n      ), //input reset
	.clkin  (I_clk_50m     ) //input clkin
 );*/
pll_75m pll_75m_u0(
        .clkout(pixel_clk), //output clkout
        .lock(pll_locked), //output lock
        .reset(!I_rst_n), //input reset
        .clkin(I_clk_50m) //input clkin
    );
//===========================================================================
/*pix3_pll pll3(
        .clkout(pixel_clk), //output clkout
        .lock(pll_locked), //output lock
        .reset(!I_rst_n), //input reset
        .clkin(I_clk_50m) //input clkin
    );*/
pll_100M pll5(
        .clkout(clk_100m), //output clkout
        .lock(pll1_locked), //output lock
        .reset(!I_rst_n), //input reset
        .clkin(I_clk_50m) //input clkin
    );
pll_24M pll4(
    .clkout(clk_24M),
    .lock(pll0_locked),
    .reset(!I_rst_n),
    .clkin(clk_100m)
);
/*pll_25m u343(
        .clkout(clk_24M), //output clkout
        .lock(pll0_locked), //output lock
        .reset(!I_rst_n), //input reset
        .clkin(I_clk_50m) //input clkin
    );*/
//------------------------------------------------------------------
CMOS_Capture_RGB565 
#(
		.CMOS_FRAME_WAITCNT		(4'd10)				//Wait n fps for steady(OmniVision need 10 Frame)
)
c0(
	//global clock
	.clk_cmos(clk_24M),			//24MHz CMOS Driver clock input
	.rst_n(I_rst_n && c_done && init_done),				//global reset

	//CMOS Sensor Interface
	.cmos_pclk(cmos_pclk),			//24MHz CMOS Pixel clock input
	.cmos_xclk(cmos_xclk),			//24MHz drive clock
	.cmos_vsync(cmos_vsync),			//H : Data Valid; L : Frame Sync(Set it by register)
	.cmos_href(cmos_href),			//H : Data vaild, L : Line Sync
	.cmos_din(cmos_d),			//8 bits cmos data input
	
	//CMOS SYNC Data output
	.cmos_frame_vsync(cmos_frame_vsync),	//cmos frame data vsync valid signal
	.cmos_frame_href(cmos_frame_href),	//cmos frame data href vaild  signal
	.cmos_frame_data(cmos_frame_data),	//cmos frame RGB output: {{R[4:0],G[5:3]}, {G2:0}, B[4:0]}	
	.cmos_frame_clken(cmos_frame_clken),	//cmos frame data output/capture enable clock, 12MHz
	
	.cmos_vsync_begin(cmos_vsync_begin),
	.frame_sync_flag(frame_sync_flag),
	//user interface
	.cmos_fps_rate(cmos_fps_rate)		//cmos frame output rate
);
//测试图
wire [15:0] hres;
wire [15:0] vres;
wire [15:0] rgb_out;
wire vs_n0,de0;
assign hres = 16'd1280;
assign vres = 16'd720;
wire clk2out;
//-----------------------------------------
vfb_test u0(
    .clk(clk_24M),
    .rst_n(I_rst_n),
    .rgb_out(rgb_out),
    .vs_n(vs_n0),
    .clken(de0),
    .clk2out(clk2out)
);
//-----------------------------------------
testpattern testpattern_inst
(
	.I_pxl_clk   (pixel_clk        ),//pixel clock
    .I_rst_n     (I_rst_n          ),//low active 
    .I_mode      ({2'b10,I_sw}     ),//data select
    .I_single_r  (8'd0             ),
    .I_single_g  (8'd0             ),
    .I_single_b  (8'd255           ),                  //800x600    //1024x768   //1280x720
    .I_h_total   (16'd1056         ),//hor total time  // 16'd1056  // 16'd1344  // 16'd1650
    .I_h_sync    (16'd128         ),//hor sync time   // 16'd128   // 16'd136   // 16'd40 
    .I_h_bporch  (16'd88          ),//hor back porch  // 16'd88    // 16'd160   // 16'd220 
    .I_h_res     (hres             ),//hor resolution  // 16'd800   // 16'd1024  // 16'd1280
    .I_v_total   (16'd628          ),//ver total time  // 16'd628   // 16'd806   // 16'd750
    .I_v_sync    (16'd4            ),//ver sync time   // 16'd4     // 16'd6     // 16'd5   
    .I_v_bporch  (16'd23           ),//ver back porch  // 16'd23    // 16'd29    // 16'd20  
    .I_v_res     (vres             ),//ver resolution  // 16'd600   // 16'd768   // 16'd720 
    .I_hs_pol    (1'b0             ),
    .I_vs_pol    (1'b0             ),
    .O_de        (ch0_de_in        ),   
    .O_hs        (ch0_hs_in        ),//负极性
    .O_vs        (ch0_vs_in        ),//负极性
    .O_data_r    (ch0_data_r       ),   
    .O_data_g    (ch0_data_g       ),
    .O_data_b    (ch0_data_b       )
); 
//==============================================
wire [7:0] d1,d2,d3,d4;
datatest dt0(
    .clk(I_clk_50m),
    .rst_n(I_rst_n),
    .d1(d1),.d2(d2),.d3(d3),.d4(d4)
);
esp8266_send_top u2(
    .clk(I_clk_50m),
    .rst_n(I_rst_n),
    .d1(d1), .d2(d2), .d3(d3), .d4(d4),
    .uart_tx(uart_tx)
);
//==============================================
/*`ifdef VIDEO_WIDTH_16     
	assign ch0_vfb_clk_in  = pixel_clk     ;   
	assign ch0_vfb_vs_in   = ch0_vs_in;
	assign ch0_vfb_de_in   = ch0_de_in;
	assign ch0_vfb_data_in = {ch0_data_b[7:3],ch0_data_g[7:2],ch0_data_r[7:3]};
`endif

`ifdef VIDEO_WIDTH_32
	assign ch0_vfb_clk_in  = pixel_clk  ;
	assign ch0_vfb_vs_in   = ch0_vs_in;
	assign ch0_vfb_de_in   = ch0_de_in;
	assign ch0_vfb_data_in = {8'd0,ch0_data_b,ch0_data_g,ch0_data_r};
`endif */
reg cmos_pclk2;
always @(posedge cmos_pclk or negedge I_rst_n)
begin
    if (!I_rst_n) cmos_pclk2<=0;
    else cmos_pclk2<=~cmos_pclk2;
end
reg cmos_frame_vsync_r,sw00;
//reg [20:0] frame_cnt;
wire cmos_vs_fall;
always @(posedge cmos_pclk or negedge I_rst_n)
begin
    if (!I_rst_n) begin
        cmos_frame_vsync_r<=1'b0;
    end else
    begin
        cmos_frame_vsync_r<=cmos_frame_vsync;
    end
end
assign cmos_vs_fall=(!cmos_frame_vsync) && (cmos_frame_vsync_r);
reg frame_cnt;
always @(posedge cmos_pclk or negedge I_rst_n)
begin
    if (!I_rst_n) frame_cnt<=0;
    else if (cmos_vs_fall) frame_cnt<=frame_cnt+1'b1;
    else frame_cnt<=frame_cnt;
end
always @(posedge cmos_pclk or negedge I_rst_n)
begin
    if (!I_rst_n) sw00=1'b0;
    else if (frame_cnt==21'd2100) sw00=1'b1;
    else sw00=1'b0;
end
//-------------------------------------------------------------------------
assign ch0_vfb_clk_in=cmos_pclk2;
assign ch0_vfb_vs_in=cmos_frame_vsync;
//assign ch0_vfb_de_in=cmos_frame_clken;
assign ch0_vfb_de_in=cmos_frame_clken;
//assign ch0_vfb_data_in=cmos_frame_data;
assign ch0_vfb_data_in={cmos_frame_data[4:0],cmos_frame_data[10:5],cmos_frame_data[15:11]};
//assign ch0_vfb_clk_in=de0;
//assign ch0_vfb_vs_in=vs_n0,ch0_vfb_de_in=de0,ch0_vfb_data_in=rgb_out;
//=====================================================
//SRAM 控制模块 
vfb_top#
(
	.IMAGE_SIZE        (IMAGE_SIZE        ),     
	.BURST_WRITE_LENGTH(BURST_WRITE_LENGTH),
	.BURST_READ_LENGTH (BURST_READ_LENGTH ),
	.ADDR_WIDTH        (ADDR_WIDTH        ),
	.DATA_WIDTH        (DATA_WIDTH        ),
	.VIDEO_WIDTH       (VIDEO_WIDTH       )
)
vfb_top_inst
( 
	.I_rst_n		    (I_rst_n),//rst_n            ),
	.I_dma_clk		    (dma_clk          ),   //sram_clk         ),
	.I_wr_halt		    (4'd0             ), //1:halt,  0:no halt
	.I_rd_halt		    (4'd0             ), //1:halt,  0:no halt
	// video data input           
	.I_vin0_clk		    (ch0_vfb_clk_in   ),
	.I_vin0_vs_n	    (ch0_vfb_vs_in    ),
	.I_vin0_de		    (ch0_vfb_de_in),
	.I_vin0_data	    (ch0_vfb_data_in  ),
	// video data output          
	.I_vout0_clk	    (pixel_clk ),
	.I_vout0_vs_n	    (syn_off0_vs      ),
	.I_vout0_de		    (syn_off0_re ),
	.O_vout0_den	    (off0_syn_de      ),
	.O_vout0_data	    (off0_syn_data    ),
	// ddr write request
	.cmd                (cmd              ),
	.cmd_en             (cmd_en           ),
	.addr               (addr             ),//[ADDR_WIDTH-1:0]
	.wr_data            (wr_data          ),//[DATA_WIDTH-1:0]
	.data_mask          (data_mask        ),
	.rd_data_valid      (rd_data_valid    ),
	.rd_data            (rd_data          ),//[DATA_WIDTH-1:0]
	.init_done          (init_done        )
);  
//-------------------------------------------
//debug
reg wwcnt;
always @(posedge cmos_pclk or negedge I_rst_n)
begin
    if ( (!I_rst_n) || (!cmos_frame_vsync) ) wwcnt<=0;
    else if (cmos_frame_clken ) wwcnt<=wwcnt+1'b1;
    else wwcnt<=wwcnt;
end

/*always @(posedge cmos_pclk) 
begin
    wwcnt2<=wwcnt;
end*/
//----------------------------------------------------- 
//psram ip
gw_pll gw_pll_inst
(
	.clkout (memory_clk    ), //output clkout //100MHz
	.lock   (pll_lock      ), //output lock
	.reset  (!I_rst_n      ), //input reset
	.clkin  (I_clk_50m     ) //input clkin
 );

PSRAM_Memory_Interface_Top PSRAM_Memory_Interface_Top_inst
(
	.clk            (I_clk_50m      ),
	.memory_clk     (memory_clk     ),
	.pll_lock       (pll_lock       ),
	.rst_n          (ddr_rstn       ),  //rst_n
	.O_psram_ck     (O_psram_ck     ),
	.O_psram_ck_n   (O_psram_ck_n   ),
	.IO_psram_rwds  (IO_psram_rwds  ),
	.IO_psram_dq    (IO_psram_dq    ),
	.O_psram_reset_n(O_psram_reset_n),
	.O_psram_cs_n   (O_psram_cs_n   ),
	.wr_data        (wr_data        ),
	.rd_data        (rd_data        ),
	.rd_data_valid  (rd_data_valid  ),
	.addr           (addr           ),
	.cmd            (cmd            ),
	.cmd_en         (cmd_en         ),
	.clk_out        (dma_clk        ),
	.data_mask      (data_mask      ),
	.init_calib     (init_done      )
);

//---------------------------------------------------
//输出同步时序模块
syn_gen syn_gen_inst
(                                   
    .I_pxl_clk   (pixel_clk       ),//40MHz      //65MHz      //74.25MHz    //30MHz
    .I_rst_n     (frame_sync_flag ),//800x600    //1024x768   //1280x720    //800x480  
    .I_h_total   (16'd1650        ),// 16'd1056  // 16'd1344  // 16'd1650   // 16'd992 
    .I_h_sync    (16'd40         ),// 16'd128   // 16'd136   // 16'd40     // 16'd72 
    .I_h_bporch  (16'd220          ),// 16'd88    // 16'd160   // 16'd220    // 16'd96  
    .I_h_res     (16'd1280         ),// 16'd800   // 16'd1024  // 16'd1280   // 16'd800 
    .I_v_total   (16'd750         ),// 16'd628   // 16'd806   // 16'd750    // 16'd500  
    .I_v_sync    (16'd5           ),// 16'd4     // 16'd6     // 16'd5      // 16'd7    
    .I_v_bporch  (16'd20          ),// 16'd23    // 16'd29    // 16'd20     // 16'd10    
    .I_v_res     (16'd720         ),// 16'd600   // 16'd768   // 16'd720    // 16'd480  
    .I_rd_hres   (hres            ),
    .I_rd_vres   (vres            ),
    .I_hs_pol    (1'b0            ),//HS polarity , 0:负极性，1：正极性
    .I_vs_pol    (1'b0            ),//VS polarity , 0:负极性，1：正极性
    .O_rden      (syn_off0_re     ),
    .O_de        (                ),   
    .O_hs        (syn_off0_hs     ),
    .O_vs        (syn_off0_vs     )
);


//=========================================================================
`ifdef VIDEO_WIDTH_16 
	assign O_data_r  = {off0_syn_data[15:11],3'd0};
	assign O_data_g  = {off0_syn_data[10: 5],2'd0};
	assign O_data_b  = {off0_syn_data[4:0],3'd0};
	assign vga_vs      = syn_off0_vs;               
	assign vga_hs      = syn_off0_hs;               
	assign vga_clk     = pixel_clk;                                         
	assign vga_blank = off0_syn_de;                
`endif

`ifdef VIDEO_WIDTH_32 
	assign O_data_r  = off0_syn_data[ 7: 0];
	assign O_data_g  = off0_syn_data[15: 8];
	assign O_data_b  = off0_syn_data[23:16];
	assign vga_vs      = syn_off0_vs;
	assign vga_hs      = syn_off0_hs;
	assign vga_clk     = pixel_clk;
	assign vga_blank = off0_syn_de;
`endif
/*genvar i;
generate for(i = 0; i < 8; i = i + 1) begin
assign vga_r[i] = o_data_r[7 - i];
assign vga_g[i] = o_data_g[7 - i];
assign vga_b[i] = o_data_b[7 - i];
end 
endgenerate*/
//assign vga_r[7:0]=O_data_r[0:7];
//assign vga_g[7:0]=O_data_g[0:7];
//assign vga_b[7:0]=O_dara_b[0:7];
//assign vga_r5=vga_r[3],vga_r6=vga_r[4],vga_r7=vga_r[5],vga_r8=vga_r[6],vga_r9=vga_r[7];
//assign vga_g4=vga_g[2],vga_g5=vga_g[3],vga_g6=vga_g[4],vga_g7=vga_g[5],vga_g8=vga_g[6],vga_g9=vga_g[7];
//assign vga_b5=vga_b[3],vga_b6=vga_b[4],vga_b7=vga_b[5],vga_b8=vga_b[6],vga_b9=vga_b[7];
//assign vga_r5=1,vga_r6=1,vga_r7=1,vga_r8=1,vga_r9=1;
//assign vga_g4=0,vga_g5=0,vga_g6=0,vga_g7=0,vga_g8=0,vga_g9=0;
//assign vga_r5=0,vga_r6=0,vga_r7=0,vga_r8=0,vga_r9=0;
//assign vga_g4=1,vga_g5=1,vga_g6=1,vga_g7=1,vga_g8=1,vga_g9=1;
//assign vga_g4=0,vga_g5=0,vga_g6=0,vga_g7=0,vga_g8=0,vga_g9=0;
//assign vga_b5=0,vga_b6=0,vga_b7=0,vga_b8=0,vga_b9=0;
//assign vga_b5=1,vga_b6=1,vga_b7=1,vga_b8=1,vga_b9=1;
assign vga_r5=O_data_r[3],vga_r6=O_data_r[4],vga_r7=O_data_r[5],vga_r8=O_data_r[6],vga_r9=O_data_r[7];
assign vga_g4=O_data_g[2],vga_g5=O_data_g[3],vga_g6=O_data_g[4],vga_g7=O_data_g[5],vga_g8=O_data_g[6],vga_g9=O_data_g[7];
assign vga_b5=O_data_b[3],vga_b6=O_data_b[4],vga_b7=O_data_b[5],vga_b8=O_data_b[6],vga_b9=O_data_b[7];
endmodule