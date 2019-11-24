//=======================================================================================================================  
// File     : video_gen_data.v                                                                                         
// Author   :                                                                                                   
//                                                                                                        //               
// Abstract : Extract a bmp file's pixel data, restore them in a memory.                                                   
//            And then transfer the pixel data outside as 24-bit-rgb video's pixel data.                                   
//                                                                                                                         
//            Pixels arranged in accordance with the order of each row and column,The number of bytes in each row must be  
//            integer multiples of 4, the insufficient part must be filled with 0. In the case of '1366x768', each line    
//            of the original number of bytes is 4098, which is not integer multiples of 4. So we need to fill 2 words of  
//            '0' to make the number of bytes in each row up to 4100.                                                      
//                                                                                                                         
// Modification History                                                                                                    
//=======================================================================================================================  
//  Date          | Version|  Author    |  Change Description                                                                           
//=======================================================================================================================
//=======================================================================================================================
`timescale 1ns / 1ps 

module video_gen_data
(
  input            link_i    ,  //0,单像素；1，双像素
  input            repeat_en ,  //0:bmp increase  , 1:bmp repeat
  input            en_i      ,  //module enable, 0:disable 1:enbale
  input            pclk_i    ,  //pixel clock                      
  input            vs_i      ,  //vertical synchronization         
  input            de_i      ,  //data valid   
  output reg [7:0] data0_r_o ,  //addressable video data, red      
  output reg [7:0] data0_g_o ,  //addressable video data, green    
  output reg [7:0] data0_b_o ,  //addressable video data, blue                    
  output reg [7:0] data1_r_o ,  //addressable video data, red      
  output reg [7:0] data1_g_o ,  //addressable video data, green    
  output reg [7:0] data1_b_o    //addressable video data, blue     
);

//=============================================================
parameter HOR_RESOLUTION  = 16'd1920;
parameter VER_RESOLUTION  = 16'd1080;
parameter SOURCE_BMP_NAME = "pic_source/game.bmp";
parameter DATA_SEL        = "BMP2MEM"; //video data sel
                                       //"BMP2MEM"
                                
//===============================================================
/*********************internal signals********************/
reg [7:0] bmp2mem_24b_r [HOR_RESOLUTION*VER_RESOLUTION-1:0];  
reg [7:0] bmp2mem_24b_g [HOR_RESOLUTION*VER_RESOLUTION-1:0]; 
reg [7:0] bmp2mem_24b_b [HOR_RESOLUTION*VER_RESOLUTION-1:0]; 

reg [31:0] address_cnt;

reg vs_i_delay;
wire vs_i_r;
wire vs_i_f;

wire [319:0] bmp_name;//character string, the name (except the postfix ".bmp") can not longer than 36 characters //40 Bytes
reg  [319:0] bmp_name_o;

//===============================================================
assign bmp_name = SOURCE_BMP_NAME;

always @ (posedge pclk_i or negedge en_i)
begin
  if (en_i==1'b0)
    begin
      bmp_name_o<= bmp_name;
    end
  else if(repeat_en)
    begin
      bmp_name_o<= bmp_name;
    end
  else if (vs_i_r)
    begin
      bmp_name_o[35:32]<=bmp_name_o[35:32]+4'h1;
    end
  else
    begin
      bmp_name_o<=bmp_name_o;
    end
end

//===============================================================
always @(posedge pclk_i)
begin
    if(vs_i_r & en_i)
      begin
        if (DATA_SEL=="BMP2MEM") 
          bmp2mem_24b(bmp_name_o);
      end
end

//===============================================================
/*********************logic implementation***************/
////ascertain the rising edge and falling edge of the vs_i
always@(posedge pclk_i or negedge en_i)
begin
  if(en_i==1'b0)
    vs_i_delay<=1'b0;
  else 
    vs_i_delay<=vs_i;     
end

assign vs_i_r=!vs_i_delay && vs_i; //vs_i rising edge
assign vs_i_f=vs_i_delay && !vs_i; //vs_i falling edge

////data memory address generator
always@(posedge pclk_i or negedge en_i)
begin
  if(en_i==1'b0)
    address_cnt<=32'd0;
  else if (address_cnt==HOR_RESOLUTION*VER_RESOLUTION-1'b1)  
    address_cnt<=32'd0;
  else if (vs_i_r==1'b1)
    address_cnt<=32'd0;
  else if (de_i==1'b1)
    begin
      if(link_i) 
        address_cnt<=address_cnt+2'd2;   //双像素模式，每次加2 
      else
        address_cnt<=address_cnt+1'b1;   //单像素模式，每次加1 
    end
end
  
////data_*_o ctrl
always @*
begin
  if (de_i==1'b1)
    begin
      if (DATA_SEL=="BMP2MEM")
        begin
          if(link_i)
            begin
              data0_r_o = bmp2mem_24b_r[address_cnt];
              data0_g_o = bmp2mem_24b_g[address_cnt];
              data0_b_o = bmp2mem_24b_b[address_cnt];
              data1_r_o = bmp2mem_24b_r[address_cnt+1'b1];
              data1_g_o = bmp2mem_24b_g[address_cnt+1'b1];
              data1_b_o = bmp2mem_24b_b[address_cnt+1'b1];
            end
          else
            begin
              data0_r_o = bmp2mem_24b_r[address_cnt];
              data0_g_o = bmp2mem_24b_g[address_cnt];
              data0_b_o = bmp2mem_24b_b[address_cnt];
              data1_r_o = 8'd0;
              data1_g_o = 8'd0;
              data1_b_o = 8'd0;
            end
        end
    end
  else
    begin
      data0_r_o = 8'd0;
      data0_g_o = 8'd0;
      data0_b_o = 8'd0;
      data1_r_o = 8'd0;
      data1_g_o = 8'd0;
      data1_b_o = 8'd0;
    end
end

//===============================================================
/*******************************************task definition*******************************************/
////NOTICE: before instantiate this task, you must do two things follow
////       a. define the depth of the reg "bmp_data"  appropriately
////       b. define the reg "bmp2mem_24b_r" "bmp2mem_24b_g" and "bmp2mem_24b_b" as a global variables
///        c. define the $fopen file name appropriately
task bmp2mem_24b;
    input[319:0] filename; //character string, the name (except the postfix ".bmp") can not longer than 36 characters //40 Bytes
    
    reg [7:0] inbmp_htr[53:0];
    reg [7:0] bmp_data[(HOR_RESOLUTION*3+HOR_RESOLUTION*3%4)*VER_RESOLUTION-1:0]; //modify 1.0.4
    reg [7:0] bmp_data_reg [(HOR_RESOLUTION*3+HOR_RESOLUTION*3%4)*VER_RESOLUTION-1:0]; //add 1.0.6

    integer infile_ptr;
    integer i;
    integer j;
    integer fread_ptr;
    integer fscanf_ptr;
    integer fseek_ptr;
    integer disc;

    reg [15:0] file_identity;      //bitmap type
    reg [31:0] file_size;          //the total file size in bytes
    reg [31:0] reserved0;          //reserved, must be seted to 32'h00000000
    reg [31:0] bitmap_data_offset; //Bitmap data offset from the beginning of the file
    reg [31:0] bitmap_header_size; //Length of 'bitmap info header'
    reg [31:0] width;              //bitmap width
    reg [31:0] height;             //bitmap height
    reg [15:0] planes;             //must be seted to 16'h0001
    reg [15:0] bits_per_pixel;     //1: 1-bit color bitmap
                                   //4: 4-bit color bitmap
                                   //8: 8-bit color bitmap
                                   //16: 16-bit color bitmap
                                   //24: 24-bit color bitmap
                                   //32: 32-bit color bitmap
    reg [31:0] compression;        //0: uncompressed(BI_RGB)
                                   //1: BI_RLE8
                                   //2: BI_RLE4
                                   //3: BI_BITFIELDS
    reg [31:0] bitmap_data_size;   //bitmap data size in words, it must be a multiple of 4
    reg [31:0] hresolution;        //horizontal resolution, pixels per meter
    reg [31:0] vresolution;        //vertical resolution, pixels per meter
    reg [31:0] colors;             //number of color the bitmap use
    reg [31:0] important;          //specify the number of important color
                                   //when it is equal to 32'd0 or 'colors', means that all colors are important

    begin
    disc=HOR_RESOLUTION*3%4;
    infile_ptr=$fopen(filename, "rb");
    
    if (infile_ptr==0)
        begin
        $display ("** %m: ERROR: Can't open the bmp file");
        $stop;
        end
    else
        begin
        for (i=0;i<54;i=i+1)
            begin
            fscanf_ptr=$fscanf (infile_ptr,"%c",inbmp_htr[i]);//获取bmp位图文件头
            end
        
        file_identity={inbmp_htr[1],inbmp_htr[0]};
        file_size={inbmp_htr[5],inbmp_htr[4],inbmp_htr[3],inbmp_htr[2]};
        reserved0={inbmp_htr[9],inbmp_htr[8],inbmp_htr[7],inbmp_htr[6]};
        bitmap_data_offset={inbmp_htr[13],inbmp_htr[12],inbmp_htr[11],inbmp_htr[10]};
        bitmap_header_size={inbmp_htr[17],inbmp_htr[16],inbmp_htr[15],inbmp_htr[14]};
        width={inbmp_htr[21],inbmp_htr[20],inbmp_htr[19],inbmp_htr[18]};                       
        height={inbmp_htr[25],inbmp_htr[24],inbmp_htr[23],inbmp_htr[22]};   
        planes={inbmp_htr[27],inbmp_htr[26]};
        bits_per_pixel={inbmp_htr[29],inbmp_htr[28]};
        compression={inbmp_htr[33],inbmp_htr[32],inbmp_htr[31],inbmp_htr[30]};                                                      
        bitmap_data_size={inbmp_htr[37],inbmp_htr[36],inbmp_htr[35],inbmp_htr[34]}; 
        hresolution={inbmp_htr[41],inbmp_htr[40],inbmp_htr[39],inbmp_htr[38]}; 
        vresolution={inbmp_htr[45],inbmp_htr[44],inbmp_htr[43],inbmp_htr[42]}; 
        colors={inbmp_htr[49],inbmp_htr[48],inbmp_htr[47],inbmp_htr[46]}; 
        important={inbmp_htr[53],inbmp_htr[52],inbmp_htr[51],inbmp_htr[50]}; 
      
        fseek_ptr=$fseek(infile_ptr,bitmap_data_offset,0);//设置文件指针偏移 
        fread_ptr=$fread(bmp_data_reg,infile_ptr);//从偏移地址开始读取位图数据    

        //bmp是倒序存储，先存储最后一行，但每行内部是按顺序的
        //以下将图像顺序倒转
        for (i=0;i<VER_RESOLUTION;i=i+1)
            for (j=0;j<(HOR_RESOLUTION*3+HOR_RESOLUTION*3%4);j=j+1)
            bmp_data[i*(HOR_RESOLUTION*3+HOR_RESOLUTION*3%4)+j]=bmp_data_reg[(VER_RESOLUTION-i-1)*(HOR_RESOLUTION*3+HOR_RESOLUTION*3%4)+j];
      
        if (disc==0)
            begin
            for (j=0;j<HOR_RESOLUTION*VER_RESOLUTION;j=j+1)
                begin
                bmp2mem_24b_r[j]=bmp_data[j*3+2];
                bmp2mem_24b_g[j]=bmp_data[j*3+1];
                bmp2mem_24b_b[j]=bmp_data[j*3];
                end
            end 
        else if (disc==1)
            begin
            for (j=0;j<HOR_RESOLUTION*VER_RESOLUTION;j=j+1)
                begin
                bmp2mem_24b_r[j]=bmp_data[j*3+2+j/HOR_RESOLUTION*3];
                bmp2mem_24b_g[j]=bmp_data[j*3+1+j/HOR_RESOLUTION*3];
                bmp2mem_24b_b[j]=bmp_data[j*3+j/HOR_RESOLUTION*3];
                end
            end
       else if (disc==2)
            begin
            for (j=0;j<HOR_RESOLUTION*VER_RESOLUTION;j=j+1)
                begin
                bmp2mem_24b_r[j]=bmp_data[j*3+2+j/HOR_RESOLUTION*2];
                bmp2mem_24b_g[j]=bmp_data[j*3+1+j/HOR_RESOLUTION*2];
                bmp2mem_24b_b[j]=bmp_data[j*3+j/HOR_RESOLUTION*2];
                end
            end
       else if (disc==3)
            begin
            for (j=0;j<HOR_RESOLUTION*VER_RESOLUTION;j=j+1)
                begin
                bmp2mem_24b_r[j]=bmp_data[j*3+2+j/HOR_RESOLUTION];
                bmp2mem_24b_g[j]=bmp_data[j*3+1+j/HOR_RESOLUTION];
                bmp2mem_24b_b[j]=bmp_data[j*3+j/HOR_RESOLUTION];
                end
            end
  
        $display("** %m: Extract bmp pixel data to memory completely");
        $display("file_identity     : %8h(hexadecimal) %12d(decimal)",file_identity     ,file_identity     );
        $display("file_size         : %8h(hexadecimal) %12d(decimal)",file_size         ,file_size         );
        $display("reserved0         : %8h(hexadecimal) %12d(decimal)",reserved0         ,reserved0         );
        $display("bitmap_data_offset: %8h(hexadecimal) %12d(decimal)",bitmap_data_offset,bitmap_data_offset);
        $display("bitmap_header_size: %8h(hexadecimal) %12d(decimal)",bitmap_header_size,bitmap_header_size);
        $display("width             : %8h(hexadecimal) %12d(decimal)",width             ,width             );
        $display("height            : %8h(hexadecimal) %12d(decimal)",height            ,height            );
        $display("planes            : %8h(hexadecimal) %12d(decimal)",planes            ,planes            );
        $display("bits_per_pixel    : %8h(hexadecimal) %12d(decimal)",bits_per_pixel    ,bits_per_pixel    );
        $display("compression       : %8h(hexadecimal) %12d(decimal)",compression       ,compression       );
        $display("bitmap_data_size  : %8h(hexadecimal) %12d(decimal)",bitmap_data_size  ,bitmap_data_size  );
        $display("hresolution       : %8h(hexadecimal) %12d(decimal)",hresolution       ,hresolution       );
        $display("vresolution       : %8h(hexadecimal) %12d(decimal)",vresolution       ,vresolution       );
        $display("colors            : %8h(hexadecimal) %12d(decimal)",colors            ,colors            );
        $display("important         : %8h(hexadecimal) %12d(decimal)",important         ,important         );
        
        $fclose(infile_ptr);

        end
    end
endtask

endmodule
