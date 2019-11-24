//=======================================================================================================================
// File     : video_syntime_config.v                                                                                 
// Author   :                                                                                                                                                                                                      
// Abstract : Config 24-bit-rgb video syntime parameters according the VESA standard.                                    
//            Take 1024x768 at 60Hz for example.                                                                         
//            hor_total_time_i = 16'd1344 //Hor Total Time(1344)                                                         
//            ver_total_time_i = 16'd806  //Ver Total Time(806)                                                          
//            hor_sync_time_i  = 16'd136  //Hor Sync Time(136)                                                           
//            ver_sync_time_i  = 16'd6    //Ver Sync Time(6)                                                             
//            data_valid_xst_i = 16'd297  //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+1                      
//            data_valid_xed_i = 16'd1320 //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+Hor Addr Time(1024)    
//            data_valid_yst_i = 16'd36   //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+1                          
//            data_valid_yed_i = 16'd803  //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+Ver Addr Time(768)         
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
//====================================================================================================================
//  Date          | Version|  Author    |   Change Description                                                        
//====================================================================================================================
//====================================================================================================================

`timescale 1ns / 1ps

module video_syntime_config
(
  input             link_i          , //0,µ¥ÏñËØ£»1£¬Ë«ÏñËØ
  output reg [15:0] hor_total_time_o, //horizontal total pixels
  output reg [15:0] ver_total_time_o, //vertical total lines
  output reg [15:0] hor_sync_time_o , //horizontal synchronization time (unit:pixel) 
  output reg [15:0] ver_sync_time_o , //vertical synchronization time (unit:line)
  output reg [15:0] data_valid_xst_o, //addressable video horizontal start coorodinate
  output reg [15:0] data_valid_xed_o, //addressable video horizontal end coorodinate 
  output reg [15:0] data_valid_yst_o, //addressable video vertical start coorodinate 
  output reg [15:0] data_valid_yed_o  //addressable video vertical end coorodinate   
);

//===========================================================================
parameter VIDEO_FORMAT = "1920x1080_xHz";  //video format
                                           //"WxH_xHz"
                                           //"80x60_xHz"
                                           //"160x120_xHz"
                                           //"320x240_xHz"
                                           //"640x480_xHz"
                                           //"800x600_xHz"
                                           //"1024x768_xHz"
                                           //"1366x768_xHz"
                                           //"1400x1050_xHz"
                                           //"1600x1200_xHz"
                                           //"1920x1080_xHz"
                                           //"1920x1200_xHz(RB)"
parameter PIXEL_CLK_FREQ = 100.0; //pixel clock frequency, unit: MHz
                                  //any --> "WxH_xHz"
                                  //any --> "80x60_xHz"
                                  //any --> "160x120_xHz"
                                  //any --> "320x240_xHz".
                                  //any --> "640x480_xHz"
                                  //any --> "640x480_xHz"
                                  //any --> "800x600_xHz"
                                  //any --> "1024x768_xHz"
                                  //any --> "1366x768_xHz"
                                  //any --> "1400x1050_xHz"
                                  //any --> "1600x1200_xHz"
                                  //any --> "1920x1080_xHz"
                                  //any --> "1920x1200_xHz(RB)"
parameter HOR_RESOLUTION=16'd1920;
parameter VER_RESOLUTION=16'd1080;

//===================================================================================
  always@(*)
  begin
    case (VIDEO_FORMAT)
    "WxH_xHz":
        begin
            hor_total_time_o= link_i ? (16'd80+HOR_RESOLUTION/2     ) : (16'd160+HOR_RESOLUTION     );
            ver_total_time_o= link_i ? (16'd50+VER_RESOLUTION       ) : (16'd50+VER_RESOLUTION      );
            hor_sync_time_o = link_i ? (16'd16                      ) : (16'd32                     );
            ver_sync_time_o = link_i ? (16'd6                       ) : (16'd6                      );
            data_valid_xst_o= link_i ? (16'd53                      ) : (16'd105                    );
            data_valid_xed_o= link_i ? (16'd53+HOR_RESOLUTION/2-1'b1) : (16'd105+HOR_RESOLUTION-1'b1);
            data_valid_yst_o= link_i ? (16'd36                      ) : (16'd36                     );
            data_valid_yed_o= link_i ? (16'd36+VER_RESOLUTION-1'b1  ) : (16'd36+VER_RESOLUTION-1'b1 );
            $display("** %m: GENERATED VIDEO FORMAT CONFIG COMPLETELY: WxH_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "80x60_xHz":
        begin
            hor_total_time_o= link_i ? 16'd120 : 16'd240 ; 
            ver_total_time_o= link_i ? 16'd150 : 16'd150 ; 
            hor_sync_time_o = link_i ? 16'd32  : 16'd66  ; 
            ver_sync_time_o = link_i ? 16'd6   : 16'd6   ; 
            data_valid_xst_o= link_i ? 16'd63  : 16'd125 ; 
            data_valid_xed_o= link_i ? 16'd102 : 16'd204 ; 
            data_valid_yst_o= link_i ? 16'd36  : 16'd36  ; 
            data_valid_yed_o= link_i ? 16'd95  : 16'd95  ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 80x60_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "160x120_xHz":
        begin
            hor_total_time_o= link_i ? 16'd140 : 16'd280 ; 
            ver_total_time_o= link_i ? 16'd200 : 16'd200 ; 
            hor_sync_time_o = link_i ? 16'd32  : 16'd66  ; 
            ver_sync_time_o = link_i ? 16'd6   : 16'd6   ; 
            data_valid_xst_o= link_i ? 16'd53  : 16'd105 ; 
            data_valid_xed_o= link_i ? 16'd132 : 16'd264 ; 
            data_valid_yst_o= link_i ? 16'd36  : 16'd36  ; 
            data_valid_yed_o= link_i ? 16'd155 : 16'd155 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 160x120_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "320x240_xHz":
        begin
            hor_total_time_o= link_i ? 16'd240 : 16'd480 ; 
            ver_total_time_o= link_i ? 16'd300 : 16'd300 ; 
            hor_sync_time_o = link_i ? 16'd48  : 16'd96  ; 
            ver_sync_time_o = link_i ? 16'd6   : 16'd6   ; 
            data_valid_xst_o= link_i ? 16'd73  : 16'd145 ; 
            data_valid_xed_o= link_i ? 16'd232 : 16'd464 ; 
            data_valid_yst_o= link_i ? 16'd36  : 16'd36  ; 
            data_valid_yed_o= link_i ? 16'd275 : 16'd275 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 320x240_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "640x480_xHz":
        begin
            hor_total_time_o= link_i ? 16'd400 : 16'd800 ; 
            ver_total_time_o= link_i ? 16'd525 : 16'd525 ; 
            hor_sync_time_o = link_i ? 16'd48  : 16'd96  ; 
            ver_sync_time_o = link_i ? 16'd6   : 16'd6   ; 
            data_valid_xst_o= link_i ? 16'd73  : 16'd145 ; 
            data_valid_xed_o= link_i ? 16'd392 : 16'd784 ; 
            data_valid_yst_o= link_i ? 16'd36  : 16'd36  ; 
            data_valid_yed_o= link_i ? 16'd515 : 16'd515 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 640x480_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "800x600_xHz":
        begin
            hor_total_time_o= link_i ? 16'd528 : 16'd1056 ; 
            ver_total_time_o= link_i ? 16'd628 : 16'd628  ; 
            hor_sync_time_o = link_i ? 16'd64  : 16'd128  ; 
            ver_sync_time_o = link_i ? 16'd4   : 16'd4    ; 
            data_valid_xst_o= link_i ? 16'd109 : 16'd217  ; 
            data_valid_xed_o= link_i ? 16'd508 : 16'd1016 ; 
            data_valid_yst_o= link_i ? 16'd28  : 16'd28   ; 
            data_valid_yed_o= link_i ? 16'd627 : 16'd627  ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 800x600_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "1024x768_xHz":
        begin
            hor_total_time_o= link_i ? 16'd672 : 16'd1344 ; 
            ver_total_time_o= link_i ? 16'd806 : 16'd806  ; 
            hor_sync_time_o = link_i ? 16'd68  : 16'd136  ; 
            ver_sync_time_o = link_i ? 16'd6   : 16'd6    ; 
            data_valid_xst_o= link_i ? 16'd149 : 16'd297  ; 
            data_valid_xed_o= link_i ? 16'd660 : 16'd1320 ; 
            data_valid_yst_o= link_i ? 16'd36  : 16'd36   ; 
            data_valid_yed_o= link_i ? 16'd803 : 16'd803  ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1024x768_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "1366x768_xHz":
        begin
            hor_total_time_o= link_i ? 16'd896 : 16'd1792 ;
            ver_total_time_o= link_i ? 16'd798 : 16'd798  ;
            hor_sync_time_o = link_i ? 16'd70  : 16'd142  ;
            ver_sync_time_o = link_i ? 16'd3   : 16'd3    ; 
            data_valid_xst_o= link_i ? 16'd179 : 16'd357  ;
            data_valid_xed_o= link_i ? 16'd861 : 16'd1722 ;
            data_valid_yst_o= link_i ? 16'd28  : 16'd28   ;
            data_valid_yed_o= link_i ? 16'd795 : 16'd795  ;
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1366x768_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "1400x1050_xHz":
        begin
            hor_total_time_o= link_i ? 16'd780  : 16'd1560 ; 
            ver_total_time_o= link_i ? 16'd1080 : 16'd1080 ;  
            hor_sync_time_o = link_i ? 16'd16   : 16'd32   ; 
            ver_sync_time_o = link_i ? 16'd4    : 16'd4    ; 
            data_valid_xst_o= link_i ? 16'd57   : 16'd113  ; 
            data_valid_xed_o= link_i ? 16'd756  : 16'd1512 ; 
            data_valid_yst_o= link_i ? 16'd28   : 16'd28   ; 
            data_valid_yed_o= link_i ? 16'd1077 : 16'd1077 ;  
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1400x1050_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "1600x1200_xHz":
        begin
            hor_total_time_o= link_i ? 16'd1080 : 16'd2160 ; 
            ver_total_time_o= link_i ? 16'd1250 : 16'd1250 ; 
            hor_sync_time_o = link_i ? 16'd96   : 16'd192  ; 
            ver_sync_time_o = link_i ? 16'd3    : 16'd3    ; 
            data_valid_xst_o= link_i ? 16'd249  : 16'd497  ; 
            data_valid_xed_o= link_i ? 16'd1048 : 16'd2096 ; 
            data_valid_yst_o= link_i ? 16'd50   : 16'd50   ; 
            data_valid_yed_o= link_i ? 16'd1249 : 16'd1249 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1600x1200_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
         end
     "1920x1080_xHz":
         begin
            hor_total_time_o= link_i ? 16'd1100 : 16'd2200 ; 
            ver_total_time_o= link_i ? 16'd1125 : 16'd1125 ; 
            hor_sync_time_o = link_i ? 16'd22   : 16'd44   ; 
            ver_sync_time_o = link_i ? 16'd5    : 16'd5    ; 
            data_valid_xst_o= link_i ? 16'd97   : 16'd193  ; 
            data_valid_xed_o= link_i ? 16'd1056 : 16'd2112 ; 
            data_valid_yst_o= link_i ? 16'd42   : 16'd42   ; 
            data_valid_yed_o= link_i ? 16'd1121 : 16'd1121 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1920x1080_xHz");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    "1920x1200_xHz(RB)":  //REDUCED BLANKING
        begin
            hor_total_time_o= link_i ? 16'd1040 : 16'd2080 ; 
            ver_total_time_o= link_i ? 16'd1235 : 16'd1235 ; 
            hor_sync_time_o = link_i ? 16'd16   : 16'd32   ; 
            ver_sync_time_o = link_i ? 16'd6    : 16'd6    ; 
            data_valid_xst_o= link_i ? 16'd57   : 16'd113  ; 
            data_valid_xed_o= link_i ? 16'd1016 : 16'd2032 ; 
            data_valid_yst_o= link_i ? 16'd33   : 16'd33   ; 
            data_valid_yed_o= link_i ? 16'd1232 : 16'd1232 ; 
            $display("** %m: GENERATED DUAL-LINK VIDEO FORMAT CONFIG COMPLETELY: 1920x1200_xHz(RB)");
            $display("** %m: PIXEL_CLK_FREQ  = %0d",PIXEL_CLK_FREQ);
            $display("** %m: Frame rate      = %0d",(PIXEL_CLK_FREQ*1000000/hor_total_time_o/ver_total_time_o));
            $display("***********************************************************************************************");
        end
    default:
        begin
            hor_total_time_o= 16'd0;  
            ver_total_time_o= 16'd0;  
            hor_sync_time_o = 16'd0; 
            ver_sync_time_o = 16'd0; 
            data_valid_xst_o= 16'd0; 
            data_valid_xed_o= 16'd0; 
            data_valid_yst_o= 16'd0; 
            data_valid_yed_o= 16'd0; 
            $display("** %m: ERROR: VIDEO FORMAT IS NOT SUPPORTED");
            $stop;
        end 
    endcase
            
    $display("** %m: hor_total_time  = %0d",hor_total_time_o);
    $display("** %m: ver_total_time  = %0d",ver_total_time_o);
    $display("** %m: hor_sync_time   = %0d",hor_sync_time_o);
    $display("** %m: ver_sync_time   = %0d",ver_sync_time_o);
    $display("** %m: data_valid_xst  = %0d",data_valid_xst_o);
    $display("** %m: data_valid_xed  = %0d",data_valid_xed_o);
    $display("** %m: data_valid_yst  = %0d",data_valid_yst_o);
    $display("** %m: data_valid_yed  = %0d",data_valid_yed_o);
    $display("***********************************************************************************************");
  end

endmodule
