//=======================================================================================================================              
// File     : video_gen_syn.v                                                                                                      
// Author   :                                                                                                                
// Version  : 1.0.0                                                                                                                    
// Abstract : Generate 24-bit-rgb video synchronous signals according the VESA standard.                                               
//            Take 1024x768 at 60Hz for example.                                                                                       
//            Hor_Total_Time_i     = 16'd1344 //Hor Total Time(1344)                                                                   
//            Ver_Total_Time_i     = 16'd806  //Ver Total Time(806)                                                                    
//            Hor_Sync_Time_i      = 16'd136  //Hor Sync Time(136)                                                                     
//            Ver_Sync_Time_i      = 16'd6    //Ver Sync Time(6)                                                                       
//            Data_Valid_Out_Xst_i = 16'd297  //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+1                                
//            Data_Valid_Out_Xed_i = 16'd1320 //Hor Sync Time(136)+H Back Porch(160)+H Left Border(0)+Hor Addr Time(1024)              
//            Data_Valid_Out_Yst_i = 16'd36   //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+1                                    
//            Data_Valid_Out_Yed_i = 16'd803  //Ver Sync Time(6)+V Back Porch(29)+V Top Border(0)+Ver Addr Time(768)                   
//                                                                                                                                     
//                                                                                                                                     
// Modification History                                                                                                                
//=======================================================================================================================              
//  Date          | Version|  Author    | Change Description                                                                           
//=======================================================================================================================                                                                                           
//=======================================================================================================================              

`timescale 1ns / 1ps 

module video_gen_syn
(
  input        En_i                ,  //module enable, 0:disable 1:enbale 
  input        Pixel_Clock_i       ,  //pixel clock 
  input [15:0] Hor_Total_Time_i    ,  //horizontal total pixels，beginning with 1
  input [15:0] Ver_Total_Time_i    ,  //vertical total lines，beginning with 1
  input [15:0] Hor_Sync_Time_i     ,  //horizontal synchronization time (unit:pixel)，beginning with 1
  input [15:0] Ver_Sync_Time_i     ,  //vertical synchronization time (unit:line) ，beginning with 1
  input [15:0] Data_Valid_Out_Xst_i,  //addressable video horizontal start coorodinate，beginning with 1 
  input [15:0] Data_Valid_Out_Xed_i,  //addressable video horizontal end coorodinate，beginning with 1   
  input [15:0] Data_Valid_Out_Yst_i,  //addressable video vertical start coorodinate，beginning with 1   
  input [15:0] Data_Valid_Out_Yed_i,  //addressable video vertical end coorodinate，beginning with 1                       
  output       VSync_o             ,  //vertical synchronization                
  output       HSync_o             ,  //horizontal synchronization
  output       Data_Valid_o           //addressable video data valid 
);

//=================================================================================                                   
  parameter HSYNC_POL = "NEGATIVE"; //horizontal synchronization polarity. //"NEGATIVE" //"POSITIVE"
  parameter VSYNC_POL = "NEGATIVE"; //vertical synchronization polarity.   //"NEGATIVE" //"POSITIVE"

//================================================================================= 
  wire Vs_cnt_Clean;
                                        
  reg [15:0] Vs_cnt;
  reg [15:0] Hs_cnt;

//================================================================================= 
//-----------------------------一帧开始信号 ------------------------------------
  assign Vs_cnt_Clean = (Vs_cnt == Ver_Total_Time_i-1'b1) & (Hs_cnt == Hor_Total_Time_i -1'b1 );

//--------------------------------行计数器--------------------------------------
  always @(posedge Pixel_Clock_i or negedge En_i)
  begin
    if(En_i==1'b0)
      Hs_cnt <=  16'd0;
    else if(Hs_cnt==Hor_Total_Time_i-1'b1)  
      Hs_cnt <=  16'd0 ; 
    else   
      Hs_cnt <=  Hs_cnt + 1'b1 ;           
  end

//--------------------------------场计数器--------------------------------------  
  always @(posedge Pixel_Clock_i or negedge En_i)
  begin
    if(En_i==1'b0)
      Vs_cnt <=  16'd0 ;  
    else if(Vs_cnt_Clean)                   
      Vs_cnt <=  16'd0 ;          
    else if(Hs_cnt==Hor_Total_Time_i-1'b1) 
      Vs_cnt <=  Vs_cnt + 1'b1 ;
    else
      Vs_cnt <=  Vs_cnt;     
  end

//------------------------------------------------------------------------------


  assign  Data_Valid_o = ((Hs_cnt>=(Data_Valid_Out_Xst_i-1'b1))&(Hs_cnt<=(Data_Valid_Out_Xed_i-1'b1))) & 
                         ((Vs_cnt>=(Data_Valid_Out_Yst_i-1'b1))&(Vs_cnt<=(Data_Valid_Out_Yed_i-1'b1))) ;
  assign  HSync_o      = (HSYNC_POL=="NEGATIVE") ? (~((Hs_cnt>=16'd0) & (Hs_cnt<=(Hor_Sync_Time_i-1'b1)))) 
                                                 : ((Hs_cnt>=16'd0) & (Hs_cnt<=(Hor_Sync_Time_i-1'b1)));
  assign  VSync_o      = (VSYNC_POL=="NEGATIVE") ? (~((Vs_cnt>=16'd0) & (Vs_cnt<=(Ver_Sync_Time_i-1'b1)))) 
                                                 : ((Vs_cnt>=16'd0) & (Vs_cnt<=(Ver_Sync_Time_i-1'b1)));     

//------------------------------------------------------------------------------
// diaplay frame number
  reg [9:0] gen_frm_cnt;
  always @(posedge Pixel_Clock_i or negedge En_i)
  begin
      if (En_i==1'b0)
        begin
          gen_frm_cnt<=10'd0;
        end
      else if (Vs_cnt_Clean==1'b1)
        begin
          gen_frm_cnt<=gen_frm_cnt+1'b1;
        end
      else
        begin
          gen_frm_cnt<=gen_frm_cnt;
        end
  end

    always@(gen_frm_cnt)
    begin
        if (gen_frm_cnt!=10'd0)
          begin
            $display ("** %m: Generate %0dth frame completely, at time %0t",gen_frm_cnt,$time);
          end
    end

endmodule       
