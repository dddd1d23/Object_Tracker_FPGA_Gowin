//---------------------------------------------------------------------
// File name         : dma_16b_32b.v
// Module name       : dma_16b_32b
// Module Description: 
// Created by        :   
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR   |    DESCRIPTION
// ---------------------------------------------------------------------
//   1.0   |  2-Jan-2014 |          |      initial
// ---------------------------------------------------------------------

`timescale 1ns / 1ps
    
module dma_16b_32b
( 
  input  wire          sys_clk,
  input  wire          rst_n,
  // video data input
  input  wire          dma_rst_i,
  input  wire          dma_de_16b_i,
  input  wire[15:0]    dma_d_16b_i,

  output wire          dma_de_32b_o,
  output wire          dma_we_32b_o,
  output wire[31:0]    dma_d_32b_o
);

  /*************************************************************************/  
  reg                  dma_de_16b;
  reg[15:0]            dma_d_16b;
  
  reg[2:0]             allian_cnt;
  
  reg                  dma_de_32b;
  reg                  dma_we_32b;
  reg[31:0]            dma_d_32b;
  
  /*************************************************************************/  
  assign    dma_de_32b_o  = dma_de_32b;
  assign    dma_we_32b_o  = dma_we_32b;
  assign    dma_d_32b_o    = dma_d_32b;
  
  /*************************************************************************/
  always@(negedge rst_n or posedge sys_clk)
  begin
    if (rst_n == 1'b0) 
      begin
        dma_de_16b       <=  1'b0;
        dma_d_16b[15:0]  <=  16'h0000;
        allian_cnt[2:0]  <=  3'b000;
      end 
    else 
      begin
        dma_de_16b       <=  dma_de_16b_i;
        dma_d_16b[15:0]  <=  dma_d_16b_i[15:0];
        allian_cnt[2:0]  <=  (dma_de_16b_i == 1'b1 && dma_de_16b == 1'b0) ? 3'b000 : (allian_cnt[2:0] + 1'b1);
      end
  end
  
  always@(negedge rst_n or posedge sys_clk)
  begin
    if (rst_n == 1'b0) 
      begin
        dma_de_32b  <=  1'b0;
        dma_we_32b  <=  1'b0;
        dma_d_32b[31:0]  <=  32'h0000_0000;
      end 
    else 
      begin
        dma_de_32b  <=  dma_de_16b;
        case (allian_cnt[1:0])
          2'b00  :  
              begin
                dma_we_32b  <=  dma_de_16b;
                dma_d_32b[31:0]  <=  {dma_d_16b_i[15:0],dma_d_16b[15:0]};
              end
          2'b01  :  
              begin
                dma_we_32b  <=  1'b0;    //---- pad for line allian 
                dma_d_32b[31:0]  <=  {dma_d_16b_i[15:0],dma_d_16b[15:0]};
              end
          2'b10  :  
              begin
                dma_we_32b  <=  dma_de_16b;
                dma_d_32b[31:0]  <=  {dma_d_16b_i[15:0],dma_d_16b[15:0]};
              end
          2'b11  :  
              begin
                dma_we_32b  <=  1'b0;
                dma_d_32b[31:0]  <=  32'h0000_0000;
              end
          default  :  
              begin
                dma_we_32b  <=  1'b0;
                dma_d_32b[31:0]  <=  32'h0000_0000;
              end
        endcase
      end
  end
endmodule   
  