//---------------------------------------------------------------------
// File name  : monitor.v
// Module name: monitor
// Created by : 
// ---------------------------------------------------------------------
// Release history
// VERSION |  Date       | AUTHOR     |    DESCRIPTION
// ---------------------------------------------------------------------  
// ---------------------------------------------------------------------

`timescale 1ns / 1ps

module monitor
(
  input       link_i      , //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
  input       video2bmp_en,
  input       pixel_clock , 
  input       vsync       ,       
  input       hsync       ,       
  input       data_valid  ,  
  input [7:0] data0_r     , 
  input [7:0] data0_g     , 
  input [7:0] data0_b     ,
  input [7:0] data1_r     , 
  input [7:0] data1_g     , 
  input [7:0] data1_b     
);

//===============================================
parameter BMP_OUTPUTED_WIDTH  = 1536;
parameter BMP_OUTPUTED_HEIGHT = 768;
parameter BMP_OUTPUTED_NAME   = "pic_out/flame000.bmp";
parameter BMP_OUTPUTED_NUMBER = 16'd2;

//==================================================
video2bmp #
(
    .BMP_OUTPUTED_WIDTH  (BMP_OUTPUTED_WIDTH ),
    .BMP_OUTPUTED_HEIGHT (BMP_OUTPUTED_HEIGHT),
    .BMP_OUTPUTED_NAME   (BMP_OUTPUTED_NAME  ),
    .BMP_OUTPUTED_NUMBER (BMP_OUTPUTED_NUMBER)
)
u_video2bmp
(
    .link_i        (link_i      ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .en_i          (video2bmp_en),
    .pclk_i        (pixel_clock ),
    .vs_i          (vsync       ),
    .hs_i          (hsync       ),
    .de_i          (data_valid  ),
    .data0_r_i     (data0_r     ),
    .data0_g_i     (data0_g     ),
    .data0_b_i     (data0_b     ),
    .data1_r_i     (data1_r     ),
    .data1_g_i     (data1_g     ),
    .data1_b_i     (data1_b     )
);


endmodule
