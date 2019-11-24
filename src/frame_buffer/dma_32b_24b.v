//---------------------------------------------------------------------
// File name         : dma_32b_24b.v
// Module name       : dma_32b_24b
// Module Description: 
// Created by        : 
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR   |    DESCRIPTION
// ---------------------------------------------------------------------
//   1.0   |  2-Jan-2014 |          |      initial
// ---------------------------------------------------------------------

`timescale 1ns / 1ps
    
module dma_32b_24b
( 
  input  wire          sys_clk,
  input  wire          rst_n,
  // video data input
  input  wire          dma_rst_i,
  input  wire          dma_de_24b_i,
  output wire          dma_den_24b_o,
  output wire[23:0]    dma_d_24b_o,

  output wire          dma_de_32b_o,
  input  wire[31:0]    dma_d_32b_i
);

  /*************************************************************************/  
  reg                  dma_de_24b;
  reg                  dma_de_24b_d0;
  reg                  dma_de_24b_ni;
  
  reg[2:0]             allian_cnt;
  
  reg                  dma_de_32b;
  reg[31:0]            dma_d_32b;
  
  reg                  dma_den_24b;
  reg[23:0]            dma_d_24b;
  
  /*************************************************************************/  
  assign    dma_de_32b_o   = dma_de_32b;
  assign    dma_den_24b_o  = dma_den_24b;
  assign    dma_d_24b_o    = dma_d_24b;
  
  /*************************************************************************/
  always@(negedge rst_n or posedge sys_clk)
  begin
    if (rst_n == 1'b0) 
      begin
        dma_de_24b       <=  1'b0;
        dma_de_24b_d0    <=  1'b0;
        dma_de_24b_ni    <=  1'b0;
        allian_cnt[2:0]  <=  3'b000;
      end 
    else 
      begin
        dma_de_24b       <=  dma_de_24b_i;
        dma_de_24b_d0    <=  dma_de_24b;
        dma_de_24b_ni    <=  dma_de_24b_d0;
        allian_cnt[2:0]  <=  (dma_de_24b_i == 1'b1 && dma_de_24b == 1'b0) ? 3'b000 : (allian_cnt[2:0] + 1'b1);
      end
  end
  
  always@(negedge rst_n or posedge sys_clk)
  begin
    if (rst_n == 1'b0) 
      begin
        dma_de_32b    <=  1'b0;
        dma_d_32b[31:0]  <=  32'h0000_0000;
      end 
    else 
      begin
        dma_d_32b  <=  dma_d_32b_i;
        case (allian_cnt[1:0])
          2'b00  :  dma_de_32b  <=  dma_de_24b;
          2'b01  :  dma_de_32b  <=  dma_de_32b;
          2'b10  :  dma_de_32b  <=  dma_de_32b;
          2'b11  :  dma_de_32b  <=  1'b0;
          default:  dma_de_32b  <=  1'b0;
        endcase
      end
  end
  
  //-----------------------------------------------------
  always@(negedge rst_n or posedge sys_clk)
  begin
    if (rst_n == 1'b0) 
      begin
        dma_den_24b      <=  1'b0;
        dma_d_24b[23:0]  <=  24'h00_0000;
      end 
    else 
      begin
        dma_den_24b  <=  dma_de_24b_ni;
        if (dma_de_24b_ni == 1'b1) 
          begin
          case (allian_cnt[1:0])
            2'b10  :  dma_d_24b  <=  {dma_d_32b_i[23:0]           };  //---- recive data allian_cnt[1:0] == 2'b00;
            2'b11  :  dma_d_24b  <=  {dma_d_32b_i[15:0],dma_d_32b[31:24]};
            2'b00  :  dma_d_24b  <=  {dma_d_32b_i[7: 0],dma_d_32b[31:16]};
            2'b01  :  dma_d_24b  <=  {                  dma_d_32b[31: 8]};
            default:  dma_d_24b  <=  1'b0;
          endcase
          end 
        else 
          begin
            dma_d_24b[23:0]  <=  24'h00_0000;
          end
      end
  end
  
endmodule   
  