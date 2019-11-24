//=======================================================================================================================  
// File     : video2bmp.v                                                                                              
// Author   :                                                                                                    
//                                                                                                     //                  
// Abstract : Extract the data in one flame from the input 24-bit-rgb video,                                               
//            and then write them in a bmp file                                                                            
//                                                                                                                         
//            Pixels arranged in accordance with the order of each row and column,The number of bytes in each row must be  
//            integer multiples of 4, the insufficient part must be filled with 0. In the case of '1366x768', each line    
//            of the original number of bytes is 4098, which is not integer multiples of 4. So we need to fill 2 words of  
//            '0' to make the number of bytes in each row up to 4100.                                                      
//                                                                                                                         
//                                                                                                                         
// Modification History                                                                                                    
//=======================================================================================================================              
//  Date          | Version|  Author    | Change Description                                                                           
//=======================================================================================================================
//=======================================================================================================================              

`timescale 1ns / 1ps

module video2bmp
(
  input       link_i   , //0,单像素；1，双像素
  input       en_i     ,
  input       pclk_i   ,
  input       vs_i     ,
  input       hs_i     ,
  input       de_i     ,
  input [7:0] data0_r_i,
  input [7:0] data0_g_i,
  input [7:0] data0_b_i,
  input [7:0] data1_r_i,
  input [7:0] data1_g_i,
  input [7:0] data1_b_i
);

//================================================================================
parameter BMP_OUTPUTED_WIDTH  = 1920;
parameter BMP_OUTPUTED_HEIGHT = 1080;
parameter BMP_OUTPUTED_NAME   = "pic_out/flame000.bmp"; //character string, the name (except the postfix ".bmp") can not longer than 36 characters //40 Bytes
parameter BMP_OUTPUTED_NUMBER = 16'd3;

//=============================================================
integer i;
integer j;

reg vs_i_d0;
reg de_i_d0;
reg [319:0] bmp_name_o;
reg [15:0] bmp_outputed_number;

wire vs_i_fall;
wire de_i_rise;
wire de_i_fall;
wire [319:0] bmp_name;

reg [7:0] bmp_hdr[53:0];
reg [65:0] bitmap_data_size;
reg [65:0] file_size;
integer img_resp_ptr;

reg bmp_wr_en;

//==================================================
assign vs_i_fall = vs_i_d0 && !vs_i;
assign de_i_rise = !de_i_d0 && de_i;
assign de_i_fall = de_i_d0 && !de_i;
assign bmp_name=BMP_OUTPUTED_NAME;

//==================================================
////////////////////////////////////////////////
//'vs_i' delay, st.
always @ (posedge pclk_i or negedge en_i)
    begin
    if (en_i==1'b0)
        vs_i_d0<=1'b0;
    else
        vs_i_d0<=vs_i;
    end
//'vs_i' delay, end.

////////////////////////////////////////////////
//'de_i' delay, st.
always @ (posedge pclk_i or negedge en_i)
    begin
    if (en_i==1'b0)
        de_i_d0<=1'b0;
    else
        de_i_d0<=de_i;
    end
//'vs_i' delay, end.

////////////////////////////////////////////////
//'bmp_name_o' crtl, st.
always @ (posedge pclk_i or negedge en_i)
        begin
    if (en_i==1'b0)
        bmp_outputed_number<=16'd0;
    else if (vs_i_fall==1'b1)
        bmp_outputed_number<=bmp_outputed_number+1'b1;
    else
        bmp_outputed_number<=bmp_outputed_number;
    end

always @ (posedge pclk_i or negedge en_i)
    begin
    if (en_i==1'b0)
        bmp_wr_en<=1'b0;
    else if (vs_i_fall & bmp_outputed_number!=0)
        bmp_wr_en<=1'b1;
    else
        bmp_wr_en<=1'b0;
    end

always @ (posedge pclk_i or negedge en_i)
    begin
    if (en_i==1'b0)
        begin
        bmp_name_o<= bmp_name;
        end
    else if (bmp_name_o[35:32]>=(bmp_name[35:32]+4'ha))
        begin
        bmp_name_o[35:32]<=4'h0;
        bmp_name_o[43:40]<=bmp_name_o[43:40]+4'h1;
        end
    else if (bmp_name_o[43:40]>=(bmp_name[43:40]+4'ha))
        begin
        bmp_name_o[43:40]<=4'h0;
        bmp_name_o[51:48]<=bmp_name_o[51:48]+4'h1;
        end
    else if (bmp_wr_en)
        begin
        bmp_name_o[35:32]<=bmp_name_o[35:32]+4'h1;
        end
    else
        begin
        bmp_name_o<=bmp_name_o;
        end
    end
//'bmp_name_o' crtl, end.

//=============================================================================
////////////////////////////////////////////////
//write bmp ctrl, st.
reg [7:0] data_r_i_mem [BMP_OUTPUTED_WIDTH*BMP_OUTPUTED_HEIGHT-1:0];
reg [7:0] data_g_i_mem [BMP_OUTPUTED_WIDTH*BMP_OUTPUTED_HEIGHT-1:0];
reg [7:0] data_b_i_mem [BMP_OUTPUTED_WIDTH*BMP_OUTPUTED_HEIGHT-1:0];
reg [7:0] data_i_mem [(BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT-1:0];
reg [7:0] data_bmp_mem [(BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT-1:0];

reg [23:0] data_mem_addr;

always @ (posedge pclk_i or negedge en_i)
begin
  if (en_i==1'b0)
      data_mem_addr=24'd0;
  else if (vs_i_fall==1'b1)
      data_mem_addr=24'd0;
  else if (de_i==1'b1)
    begin
      if(link_i)
        begin
          data_r_i_mem[data_mem_addr]      = data0_r_i;
          data_g_i_mem[data_mem_addr]      = data0_g_i;
          data_b_i_mem[data_mem_addr]      = data0_b_i;
          data_r_i_mem[data_mem_addr+1'b1] = data1_r_i;
          data_g_i_mem[data_mem_addr+1'b1] = data1_g_i;
          data_b_i_mem[data_mem_addr+1'b1] = data1_b_i;
          data_mem_addr = data_mem_addr +2'd2;   //双像素模式，每次加2
        end
      else
        begin
          data_r_i_mem[data_mem_addr]      =data0_r_i;
          data_g_i_mem[data_mem_addr]      =data0_g_i;
          data_b_i_mem[data_mem_addr]      =data0_b_i;
          data_mem_addr = data_mem_addr +1'b1;   //单像素模式，每次加1
        end
    end
end

always @ (posedge pclk_i)
    begin
    if (bmp_wr_en)
        begin
        write_bmp_pre_rgb_24b(BMP_OUTPUTED_WIDTH,BMP_OUTPUTED_HEIGHT,bmp_name_o);

        if (BMP_OUTPUTED_WIDTH*3%4==0)
            for (i=0;i<((BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT)/3;i=i+1)
                begin
                data_i_mem[3*i+0]=data_b_i_mem[i];
                data_i_mem[3*i+1]=data_g_i_mem[i];
                data_i_mem[3*i+2]=data_r_i_mem[i];
                end
        else if (BMP_OUTPUTED_WIDTH*3%4==1)
            for (i=0;i<((BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT)/3;i=i+1)
                begin
                data_i_mem[3*i+0+i/BMP_OUTPUTED_WIDTH*3]=data_b_i_mem[i];
                data_i_mem[3*i+1+i/BMP_OUTPUTED_WIDTH*3]=data_g_i_mem[i];
                data_i_mem[3*i+2+i/BMP_OUTPUTED_WIDTH*3]=data_r_i_mem[i];
                end
        else if (BMP_OUTPUTED_WIDTH*3%4==2)
            for (i=0;i<((BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT)/3;i=i+1)
                begin
                data_i_mem[3*i+0+i/BMP_OUTPUTED_WIDTH*2]=data_b_i_mem[i];
                data_i_mem[3*i+1+i/BMP_OUTPUTED_WIDTH*2]=data_g_i_mem[i];
                data_i_mem[3*i+2+i/BMP_OUTPUTED_WIDTH*2]=data_r_i_mem[i];
                end
        else if (BMP_OUTPUTED_WIDTH*3%4==3)
            for (i=0;i<((BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT)/3;i=i+1)
                begin
                data_i_mem[3*i+0+i/BMP_OUTPUTED_WIDTH*1]=data_b_i_mem[i];
                data_i_mem[3*i+1+i/BMP_OUTPUTED_WIDTH*1]=data_g_i_mem[i];
                data_i_mem[3*i+2+i/BMP_OUTPUTED_WIDTH*1]=data_r_i_mem[i];
                end
        
        //bmp是倒序存储，先存储最后一行，但每行内部是按顺序的
        //以下将图像顺序倒转
        for(i=0;i<BMP_OUTPUTED_HEIGHT;i=i+1)
            for(j=0;j<BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4;j=j+1)
                data_bmp_mem[i*(BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)+j]=data_i_mem[(BMP_OUTPUTED_HEIGHT-i-1)*(BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)+j];

        for (i=0;i<(BMP_OUTPUTED_WIDTH*3+BMP_OUTPUTED_WIDTH*3%4)*BMP_OUTPUTED_HEIGHT;i=i+1)
            $fwrite(img_resp_ptr, "%c", data_bmp_mem[i]);

        $fclose(img_resp_ptr); 
        $display("** %m: Write bmp file completely, at time %0t",$time);
        $display(" ");
        end
    end
//write bmp ctrl, end.


////////////////////////////////////////////////
//sim stop ctrl, st.
always @ (posedge pclk_i or negedge en_i)
    begin
    if (bmp_outputed_number==BMP_OUTPUTED_NUMBER+1)
        begin
        #30;
        $stop;
        end
    end
//sim stop ctrl, end.


/*******************************************task: write_bmp_pre********************************************/
task write_bmp_pre_rgb_24b;
  input[31:0] width;
  input[31:0] height;      
  input[319:0] filename; //character string, the name (except the postfix ".bmp") can not longer than 36 characters //40 Bytes
  
  integer i;
  
  begin
  bitmap_data_size = (width*2'b11+(width*2'b11)%4) * height;
  file_size = bitmap_data_size+8'd54;
  
  img_resp_ptr = 0;  
  
  /////14bytes   bitmapfileheader
  //bftype
  bmp_hdr[0]=8'h42;                                       
  bmp_hdr[1]=8'h4D;                                       
  //bfsize
  bmp_hdr[2]=file_size[7:0];
  bmp_hdr[3]=file_size[15:8];
  bmp_hdr[4]=file_size[23:16];
  bmp_hdr[5]=file_size[31:24];
  //bfreserved
  bmp_hdr[6]=8'h00;                                       
  bmp_hdr[7]=8'h00;                                       
  bmp_hdr[8]=8'h00;                                       
  bmp_hdr[9]=8'h00;                                       
  //bf offset size
  bmp_hdr[10]=8'h36;  //offset of imgage width, 8'd54
  bmp_hdr[11]=8'h00;                                      
  bmp_hdr[12]=8'h00;                                      
  bmp_hdr[13]=8'h00;                                      
  /////40bytes bitmapinfoheader
  //bytesize of bitmapinfoheader
  bmp_hdr[14]=8'h28;   //unique bytes
  bmp_hdr[15]=8'h00;                                      
  bmp_hdr[16]=8'h00;                                      
  bmp_hdr[17]=8'h00;                                      
  //width                                                   
  bmp_hdr[18]=width[7:0];    //image width low8
  bmp_hdr[19]=width[15:8];   //image width high8
  bmp_hdr[20]=width[23:16];                                  
  bmp_hdr[21]=width[31:24];                                  
  //height                                                  
  bmp_hdr[22]=height[7:0];   //image height low8
  bmp_hdr[23]=height[15:8];  //image height high8
  bmp_hdr[24]=height[23:16];                                 
  bmp_hdr[25]=height[31:24];                                 
  //biplanes                                                  
  bmp_hdr[26]=8'h01;                                        
  bmp_hdr[27]=8'h00;                                        
  //bitcount,value = 1,4,8,24,32
  bmp_hdr[28]=8'h18;                                        
  bmp_hdr[29]=8'h00;                                        
  //compression stratege, value=0,1,2,3.0,is non-conpressed
  bmp_hdr[30]=8'h00;   //compressed specification
  bmp_hdr[31]=8'h00;                                        
  bmp_hdr[32]=8'h00;                                        
  bmp_hdr[33]=8'h00;                                        
  //size of image = width'*height, width = 4* num
  bmp_hdr[34]=bitmap_data_size[7:0];    //size of image      
  bmp_hdr[35]=bitmap_data_size[15:8];                                
  bmp_hdr[36]=bitmap_data_size[23:16];                               
  bmp_hdr[37]=bitmap_data_size[31:24];                               
  //xpelpermeter of monitor
  bmp_hdr[38]=8'h00;                                        
  bmp_hdr[39]=8'h00;                                        
  bmp_hdr[40]=8'h00;                                        
  bmp_hdr[41]=8'h00;                                        
  //ypelpermeter of monitor
  bmp_hdr[42]=8'h00;                                        
  bmp_hdr[43]=8'h00;                                        
  bmp_hdr[44]=8'h00;                                        
  bmp_hdr[45]=8'h00;                                        
  //biclrused
  bmp_hdr[46]=8'h00;                                        
  bmp_hdr[47]=8'h00;                                        
  bmp_hdr[48]=8'h00;                                        
  bmp_hdr[49]=8'h00;                                        
  //biclrimportant
  bmp_hdr[50]=8'h00;                                        
  bmp_hdr[51]=8'h00;                                        
  bmp_hdr[52]=8'h00;                                        
  bmp_hdr[53]=8'h00;
  
  img_resp_ptr = $fopen(filename, "wb");   
       
  if (img_resp_ptr == 0)   
      begin
      $display("** %m: ERROR: Can't find the bmp file");                      
      $stop;                     
      end   
  else
      begin               
      for(i=0; i<54; i=i+1)   
          begin                       
          $fwrite(img_resp_ptr, "%c", bmp_hdr[i]);  
          end          
      end
  end
endtask

endmodule
