//======================================================================================================================
// File     : video_gen.v                                                                                           
// Author   :                                                                                                        
// Abstract : Generate 24-bit-rgb video according the VESA standard.                                                    
//            Take 1024x768 at 60Hz for example.                                                                        
//            hor_total_time_w = 16'd1344 //Hor Total Time(1344)                                                        
//            ver_total_time_w = 16'd806  //Ver Total Time(806)                                                         
//            hor_sync_time_w  = 16'd136  //Hor Sync Time(136)                                                          
//            ver_sync_time_w  = 16'd6    //Ver Sync Time(6)                                                            
//            data_valid_xst_w = 16'd297  //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+1                     
//            data_valid_xed_w = 16'd1320 //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+Hor Addr Time(1024)   
//            data_valid_yst_w = 16'd36   //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+1                         
//            data_valid_yed_w = 16'd803  //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+Ver Addr Time(768)        
//                                                                                                                      
//            VIDEO_FORMAT should be:                                                                                   
//            "640x480_60Hz"                                                                                            
//            "800x600_60Hz"                                                                                            
//            "1024x768_60Hz"                                                                                           
//            "1366x768_60Hz"                                                                                       
//            "1400x1050_60Hz"                                                                                          
//            "1600x1200_60Hz"                                                                                          
//            "1920x1080_60Hz"                                                                                          
//            "1920x1200_60Hz(RB)"                                                                                
//                                                                                                                      
// Modification History                                                                                                 
//==================================================================================================================================
//  Date          | Version|  Author    |  Change Description                                                                        
//==================================================================================================================================
//==================================================================================================================================

`timescale 1ns / 1ps 

module video_gen
(
  input        link_i        , //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
  input        repeat_en     , //0:bmp increase  , 1:bmp repeat
  input        video_gen_en_i, //module enable, 0:disable 1:enbale
  input        pixel_clock_i , //pixel clock 
  output       vsync_o       , //vertical synchronization
  output       hsync_o       , //horizontal synchronization
  output       data_valid_o  , //addressable video data valid 
  output [7:0] data0_r_o     , //addressable video data, red
  output [7:0] data0_g_o     , //addressable video data, green
  output [7:0] data0_b_o     ,  //addressable video data, blue
  output [7:0] data1_r_o     , //addressable video data, red
  output [7:0] data1_g_o     , //addressable video data, green
  output [7:0] data1_b_o       //addressable video data, blue
);

//===============================================================================
parameter VIDEO_FORMAT    = "1920x1080_xHz";  //video format
parameter PIXEL_CLK_FREQ  = 100.0 ;//pixel clock frequency, unit: MHz
parameter HOR_RESOLUTION  = 1920;  // horizontal resolution
parameter VER_RESOLUTION  = 1080;  // vertical resolution
parameter SOURCE_BMP_NAME = "pic_source/game.bmp";

parameter HSYNC_POL       = "NEGATIVE"; //horizontal synchronization polarity. //"NEGATIVE" //"POSITIVE"
parameter VSYNC_POL       = "NEGATIVE"; //vertical synchronization polarity.   //"NEGATIVE" //"POSITIVE"
parameter DATA_SEL        = "BMP2MEM";  //video data sel
                                        //"BMP2MEM"

//===================================================================================
wire [15:0] hor_total_time_w; 
wire [15:0] ver_total_time_w;  
wire [15:0] hor_sync_time_w; 
wire [15:0] ver_sync_time_w; 
wire [15:0] data_valid_xst_w; 
wire [15:0] data_valid_xed_w; 
wire [15:0] data_valid_yst_w; 
wire [15:0] data_valid_yed_w; 

//===================================================================================
video_syntime_config #
(
    .VIDEO_FORMAT   (VIDEO_FORMAT  ),
    .PIXEL_CLK_FREQ (PIXEL_CLK_FREQ),
    .HOR_RESOLUTION (HOR_RESOLUTION),
    .VER_RESOLUTION (VER_RESOLUTION)
)
u_video_syntime_config
(
    .link_i           (link_i          ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .hor_total_time_o (hor_total_time_w), //horizontal total pixels
    .ver_total_time_o (ver_total_time_w), //vertical total lines
    .hor_sync_time_o  (hor_sync_time_w ), //horizontal synchronization time (unit:pixel) 
    .ver_sync_time_o  (ver_sync_time_w ), //vertical synchronization time (unit:line)
    .data_valid_xst_o (data_valid_xst_w), //addressable video horizontal start coorodinate   
    .data_valid_xed_o (data_valid_xed_w), //addressable video horizontal end coorodinate     
    .data_valid_yst_o (data_valid_yst_w), //addressable video vertical start coorodinate     
    .data_valid_yed_o (data_valid_yed_w)  //addressable video vertical end coorodinate
);
  
//===================================================================================
video_gen_syn #
(
    .HSYNC_POL (HSYNC_POL),//horizontal synchronization polarity. 0:negative; 1:positive
    .VSYNC_POL (VSYNC_POL) //vertical synchronization polarity. 0:negative; 1:positive 
)
u_video_gen_syn
(
    .En_i                 (video_gen_en_i  ),  //module enable, 0:disable 1:enbale            
    .Pixel_Clock_i        (pixel_clock_i   ),  //pixel clock   
    .Hor_Total_Time_i     (hor_total_time_w),  //horizontal total pixels                   
    .Ver_Total_Time_i     (ver_total_time_w),  //vertical total lines
    .Hor_Sync_Time_i      (hor_sync_time_w ),  //horizontal synchronization time (unit:pixel)                  
    .Ver_Sync_Time_i      (ver_sync_time_w ),  //vertical synchronization time (unit:line)
    .Data_Valid_Out_Xst_i (data_valid_xst_w),  //addressable video horizontal start coorodinate 
    .Data_Valid_Out_Xed_i (data_valid_xed_w),  //addressable video horizontal end coorodinate
    .Data_Valid_Out_Yst_i (data_valid_yst_w),  //addressable video vertical start coorodinate
    .Data_Valid_Out_Yed_i (data_valid_yed_w),  //addressable video vertical end coorodinate
    .VSync_o              (vsync_o         ),  //vertical synchronization	       
    .HSync_o              (hsync_o         ),  //horizontal synchronization           
    .Data_Valid_o         (data_valid_o    )   //addressable video data valid                          
);
   
//===================================================================================
video_gen_data #
(
    .HOR_RESOLUTION  (HOR_RESOLUTION ),
    .VER_RESOLUTION  (VER_RESOLUTION ),
    .SOURCE_BMP_NAME (SOURCE_BMP_NAME),
    .DATA_SEL        (DATA_SEL       )
)
u_video_gen_data
(
    .link_i       (link_i        ), //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
    .repeat_en    (repeat_en     ), //0:bmp increase  , 1:bmp repeat
    .en_i         (video_gen_en_i), //module enable, 0:disable 1:enbale  
    .pclk_i       (pixel_clock_i ), //pixel clock 
    .vs_i         (vsync_o       ), //vertical synchronization
    .de_i         (data_valid_o  ), //data valid 
    .data0_r_o    (data0_r_o     ), //addressable video data, red
    .data0_g_o    (data0_g_o     ), //addressable video data, green
    .data0_b_o    (data0_b_o     ), //addressable video data, blue
    .data1_r_o    (data1_r_o     ), //addressable video data, red
    .data1_g_o    (data1_g_o     ), //addressable video data, green
    .data1_b_o    (data1_b_o     )  //addressable video data, blue
);
           
endmodule