//---------------------------------------------------------------------
// File name  : tb_top.v
// Module name: tb_top
// Created by : 
// ---------------------------------------------------------------------
// Release history
// VERSION |  Date       | AUTHOR     |    DESCRIPTION
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------


`timescale 1ns / 1ps

module tb_hist_v();

//========================================================
//parameters
parameter BMP_VIDEO_FORMAT        = "800x600_xHz"; //video format
parameter BMP_PIXEL_CLK_FREQ      = 100.000;            //pixel clock frequency, unit: MHz
parameter BMP_PIXEL_CLK_PERIOD    = 1000.0/BMP_PIXEL_CLK_FREQ; //unit: ns
parameter BMP_WIDTH               = 800;
parameter BMP_HEIGHT              = 600;
parameter BMP_OPENED_NAME         = "low_light.bmp";
parameter BMP_REPEAT              = 1'b1;  //0:bmp increase  , 1:bmp repeat
parameter BMP_LINK                = 1'b0;  //0:µ¥ÏñËØ£»1:Ë«ÏñËØ
                                  
parameter BMP_OUTPUTED_WIDTH      = 800;
parameter BMP_OUTPUTED_HEIGHT     = 600;
parameter BMP_OUTPUTED_NAME       = "hist_v_out_000.bmp";
parameter BMP_OUTPUTED_NUMBER     = 16'd4;
GSR GSR (1'b1) ; 
//=======================================================
reg  pixel_clock;

reg  rst_n;
reg  video_gen_en;

//------------
//dirver
wire       vsync; 
wire       hsync; 
wire       data_valid; 
wire [7:0] data0_r; 
wire [7:0] data0_g;
wire [7:0] data0_b;
wire [7:0] data1_r ; 
wire [7:0] data1_g ;
wire [7:0] data1_b ;

//-----------------
//monitor rgb input
wire        m_clk;
wire        m_vs_rgb;  
wire        m_hs_rgb;  
wire        m_de_rgb;  
wire [7:0]  m_data0_r;
wire [7:0]  m_data0_g;
wire [7:0]  m_data0_b;
wire [7:0]  m_data1_r;
wire [7:0]  m_data1_g;
wire [7:0]  m_data1_b;
wire [9:0] sobel_data;
wire [15:0] out_Data;
//=====================================================
//clk
initial
  begin
    pixel_clock = 1'b0;
  end

always  #(BMP_PIXEL_CLK_PERIOD/2.0) pixel_clock = ~pixel_clock;

//=====================================================
//rst_n
initial
  begin
    rst_n=1'b0;
    
    #2000;
    rst_n=1'b1;
end

initial
  begin
    video_gen_en=1'b0;
    
    #5000;
    video_gen_en=1'b1;
end

//==================================================
//video driver
driver #
(
    .BMP_VIDEO_FORMAT    (BMP_VIDEO_FORMAT     ),
    .BMP_PIXEL_CLK_FREQ  (BMP_PIXEL_CLK_FREQ   ),
    .BMP_WIDTH           (BMP_WIDTH            ),
    .BMP_HEIGHT          (BMP_HEIGHT           ),
    .BMP_OPENED_NAME     (BMP_OPENED_NAME      )
)
driver_inst
(
    .link_i      (BMP_LINK    ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .repeat_en   (BMP_REPEAT  ),
    .video_gen_en(video_gen_en),
    .pixel_clock (pixel_clock ),
    .vsync       (vsync       ), 
    .hsync       (hsync       ), 
    .data_valid  (data_valid  ),
    .data0_r     (data0_r     ), 
    .data0_g     (data0_g     ),
    .data0_b     (data0_b     ), 
    .data1_r     (data1_r     ), 
    .data1_g     (data1_g     ),
    .data1_b     (data1_b     )
);
//---------------------------------
/*sobel_t sobel0(
    .hsi(hsync),
    .vsi(vsync),
    .iCLK(pixel_clock),
    .iRST_N(rst_n),
    .iTHRESHOLD(8'd7),
    .iDVAL(data_valid),
    .iDATA({2'b0,data0_g}),
    .oDVAL(),
    .oDATA(sobel_data),
    .hso(m_hs_rgb),
    .vso(m_vs_rgb)
);*/
wire [7:0] gray_out;
/*histogram_equalized_top histogram_equalized_top_u0(
    //global clock
    .clk(pixel_clock),          
    .rst_n(rst_n),       

    //Image data prepred to be processd
    .pre_vs(vsync), 
    .pre_hs(hsync),  
    .pre_clken(data_valid), 
    .pre_imgdata(data0_r),

    //Image data has been processd
    .post_vs(m_vs_rgb), 
    .post_hs(m_hs_rgb), 
    .post_clken(m_de_rgb),
    .post_imgdata(gray_out)
);*/
wire [23:0] o_data;
hist_v hist_v_u0(
    .clk(pixel_clock),
    .rst_n(rst_n),
    .pre_vs(vsync),
    .pre_hs(hsync),
    .pre_clken(data_valid),
    .rgb({data0_r,data0_g,data0_b}),
    .post_hs(m_hs_rgb),
    .post_vs(m_vs_rgb),
    .post_clken(m_de_rgb),
    .post_rgb(o_data),
    .post_hsv(),
    .process_en(1'b1)
);
//==========================================================
//monitor
assign m_clk        = pixel_clock   ;
//assign m_vs_rgb     = vsync         ;
//assign m_hs_rgb     = hsync         ;
//assign m_de_rgb     = data_valid    ;
assign m_data0_r    = o_data[23:16];
assign m_data0_g    = o_data[15:8];
assign m_data0_b    = o_data[7:0];
//
assign m_data1_r    = data1_r       ;
assign m_data1_g    = data1_g       ;
assign m_data1_b    = data1_b       ;
monitor #
(
    .BMP_OUTPUTED_WIDTH  (BMP_OUTPUTED_WIDTH ),
    .BMP_OUTPUTED_HEIGHT (BMP_OUTPUTED_HEIGHT),
    .BMP_OUTPUTED_NAME   (BMP_OUTPUTED_NAME  ),
    .BMP_OUTPUTED_NUMBER (BMP_OUTPUTED_NUMBER)
)
monitor_inst
(
    .link_i       (BMP_LINK          ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .video2bmp_en (rst_n             ),
    .pixel_clock  (m_clk             ), 
    .vsync        (m_vs_rgb          ),        
    .hsync        (m_hs_rgb          ),        
    .data_valid   (m_de_rgb          ), 
    .data0_r      (m_data0_r         ),    
    .data0_g      (m_data0_g         ),
    .data0_b      (m_data0_b         ),
    .data1_r      (m_data1_r         ),    
    .data1_g      (m_data1_g         ),
    .data1_b      (m_data1_b         )
);
          
endmodule
