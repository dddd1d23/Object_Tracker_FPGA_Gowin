//---------------------------------------------------------------------
// File name  : driver.v
// Module name: driver
// Created by : 
// ---------------------------------------------------------------------
// Release history
// VERSION |  Date       | AUTHOR     |    DESCRIPTION
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------

`timescale 1ns / 1ps

module driver
(
  input        link_i      , //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
  input        repeat_en   , //0:bmp increase  , 1:bmp repeat
  input        video_gen_en,
  input        pixel_clock ,
  output       vsync       , 
  output       hsync       , 
  output       data_valid  ,
  output [7:0] data0_r     , 
  output [7:0] data0_g     ,
  output [7:0] data0_b     , 
  output [7:0] data1_r     , 
  output [7:0] data1_g     ,
  output [7:0] data1_b       
);

//========================================================================
parameter BMP_VIDEO_FORMAT    = "1366x768_xHz";   //video format
parameter BMP_PIXEL_CLK_FREQ  = 74.250;//pixel clock frequency, unit: MHz
parameter BMP_WIDTH           = 1366;
parameter BMP_HEIGHT          = 768;
parameter BMP_OPENED_NAME     = "../pic_lib/1366x768/round_24b.bmp";
                              
parameter HSYNC_POL           = "NEGATIVE"; //horizontal synchronization polarity. //"NEGATIVE" //"POSITIVE"
parameter VSYNC_POL           = "NEGATIVE"; //vertical synchronization polarity.   //"NEGATIVE" //"POSITIVE"

//===========================================
video_gen #
(
    .VIDEO_FORMAT    (BMP_VIDEO_FORMAT   ),
    .PIXEL_CLK_FREQ  (BMP_PIXEL_CLK_FREQ ),
    .HOR_RESOLUTION  (BMP_WIDTH          ),
    .VER_RESOLUTION  (BMP_HEIGHT         ),
    .SOURCE_BMP_NAME (BMP_OPENED_NAME    ),
    .HSYNC_POL       (HSYNC_POL          ),
    .VSYNC_POL       (VSYNC_POL          )
)
u_video_gen
(
    .link_i          (link_i      ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .repeat_en       (repeat_en   ), //0:bmp increase  , 1:bmp repeat
    .video_gen_en_i  (video_gen_en),
    .pixel_clock_i   (pixel_clock ),
    .vsync_o         (vsync       ),
    .hsync_o         (hsync       ),
    .data_valid_o    (data_valid  ),
    .data0_r_o       (data0_r     ),
    .data0_g_o       (data0_g     ),
    .data0_b_o       (data0_b     ),
    .data1_r_o       (data1_r     ),
    .data1_g_o       (data1_g     ),
    .data1_b_o       (data1_b     )
);


endmodule
