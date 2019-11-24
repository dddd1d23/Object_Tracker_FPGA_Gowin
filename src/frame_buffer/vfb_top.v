// ==============0ooo===================================================0ooo===========
// =  Copyright (C) 2014-2019 Gowin Semiconductor Technology Co.,Ltd.
// =					 All rights reserved.
// ====================================================================================
// 
//  __	    __	    __
//  \ \	   /  \	   / /   [File name   ] scaler_top.v
//   \ \  / /\ \  / /	 [Description ] Video scaler
//	  \ \/ /  \ \/ /	 [Timestamp   ] Friday May 26 14:00:30 2019
//	   \  /	   \  /	     [version	  ] 1.0.0
//	    \/	    \/
//
// ==============0ooo===================================================0ooo===========
// Code Revision History :
// ----------------------------------------------------------------------------------
// Ver:	|  Author	| Mod. Date	| Changes Made:
// ----------------------------------------------------------------------------------
// V1.0	| Caojie	 | 05/26/19	 | Initial version 
// ----------------------------------------------------------------------------------
// ==============0ooo===================================================0ooo===========

`timescale 1ns / 1ps

`include "vfb_defines.v"
	
module vfb_top#
(   
	parameter IMAGE_SIZE		  = 32'h0080_0000   ,//--8MB,byte address  //frame base address
	parameter BURST_WRITE_LENGTH  = 1024            ,  //bytes
	parameter BURST_READ_LENGTH   = 1024            ,  //bytes		
	parameter ADDR_WIDTH		  = 26              ,
	parameter DATA_WIDTH		  = `DEF_DATA_WIDTH ,
	parameter VIDEO_WIDTH		  = `DEF_VIDEO_WIDTH
)
( 
	input                     I_rst_n       ,
	input                     I_dma_clk     ,
	input  [3:0]              I_wr_halt     , //1:halt,  0:no halt
	input  [3:0]              I_rd_halt     , //1:halt,  0:no halt
	// video data input                        
	input                     I_vin0_clk    ,
	input                     I_vin0_vs_n   ,
	input                     I_vin0_de     ,
	input  [VIDEO_WIDTH-1:0]  I_vin0_data   ,                                
	// video data output                    
	input                     I_vout0_clk   ,
	input                     I_vout0_vs_n  ,
	input                     I_vout0_de    ,
	output                    O_vout0_den   ,
	output [VIDEO_WIDTH-1:0]  O_vout0_data  ,
	// ddr write request
	output                    cmd           ,
	output                    cmd_en        ,
	output [20:0]             addr          ,//[ADDR_WIDTH-1:0]
	output [63:0]             wr_data       ,//[DATA_WIDTH-1:0]
	output [7:0]              data_mask     ,
	input                     rd_data_valid ,
	input  [63:0]             rd_data       ,//[DATA_WIDTH-1:0]
	input                     init_done     
);
  
//----------------------------------------------- 
//ch0
wire                         dma0_wr_req      ;
wire                         dma0_wr_end      ;
wire                         dma0_wr_grant    ;
wire                         dma0_wr_cmd      ;
wire                         dma0_wr_cmd_en   ;
wire      [ADDR_WIDTH-1:0]   dma0_wr_addr     ;//[ADDR_WIDTH-1:0]
wire      [DATA_WIDTH-1:0]   dma0_wr_data     ;//[DATA_WIDTH-1:0]
wire      [7:0]              dma0_wr_data_mask;

wire                         dma0_rd_req      ;
wire                         dma0_rd_end      ;
wire                         dma0_rd_grant    ;
wire                         dma0_rd_cmd      ;
wire                         dma0_rd_cmd_en   ;
wire      [ADDR_WIDTH-1:0]   dma0_rd_addr     ;//[ADDR_WIDTH-1:0]
wire                         dma0_rd_valid    ;
wire      [DATA_WIDTH-1:0]   dma0_rd_data     ;//[DATA_WIDTH-1:0]


//==================================================================  
dma_frame_buffer#
(
	.IMAGE_SIZE        (IMAGE_SIZE        ),     
	.BURST_WRITE_LENGTH(BURST_WRITE_LENGTH),
	.BURST_READ_LENGTH (BURST_READ_LENGTH ),
	.ADDR_WIDTH        (ADDR_WIDTH        ),
	.DATA_WIDTH        (DATA_WIDTH        ),
	.VIDEO_WIDTH       (VIDEO_WIDTH       )
)
u0_dma_frame_buffer
( 
	.dma_clk           (I_dma_clk       ),
	.rst_n             (I_rst_n         ),
	.wr_halt           (I_wr_halt[0]    ),
	.rd_halt           (I_rd_halt[0]    ),
	// video data input
	.vin_clk_i         (I_vin0_clk		),
	.vin_vs_n_i        (I_vin0_vs_n		),    
	.vin_de_i          (I_vin0_de		),
	.vin_data_i        (I_vin0_data		),    
	// video data output
	.vout_clk_i        (I_vout0_clk		),    
	.vout_vs_n_i       (I_vout0_vs_n	),
	.vout_de_i         (I_vout0_de		),
	.vout_den_o        (O_vout0_den		),    
	.vout_data_o       (O_vout0_data	),
	// ddr write request
	.dma_wr_req_o      (dma0_wr_req      ),
    .dma_wr_end_o      (dma0_wr_end      ),
    .dma_wr_grant_i    (dma0_wr_grant    ),
    .dma_wr_cmd        (dma0_wr_cmd      ),
	.dma_wr_cmd_en     (dma0_wr_cmd_en   ),
	.dma_wr_addr_o     (dma0_wr_addr     ),//[ADDR_WIDTH-1:0]
	.dma_wr_data       (dma0_wr_data     ),//[DATA_WIDTH-1:0]
	.dma_wr_data_mask  (dma0_wr_data_mask),
	// ddr read request
	.dma_rd_req_o      (dma0_rd_req      ),
    .dma_rd_end_o      (dma0_rd_end      ),
    .dma_rd_grant_i    (dma0_rd_grant    ),
    .dma_rd_cmd        (dma0_rd_cmd      ),
	.dma_rd_cmd_en     (dma0_rd_cmd_en   ),
	.dma_rd_addr_o     (dma0_rd_addr     ),//[ADDR_WIDTH-1:0]
	.dma_rd_valid      (dma0_rd_valid    ),
	.dma_rd_data       (dma0_rd_data     ),//[DATA_WIDTH-1:0]
	// video base address
	.dma_base_addr_i   (IMAGE_SIZE*3*0)
);
  
//==========================================================================
//**** ARBITER ****
dma_bus_arbiter#
(
	.ADDR_WIDTH        (ADDR_WIDTH ),
	.DATA_WIDTH        (DATA_WIDTH )
)
u_dma_bus_arbiter
( 
	.clk              (I_dma_clk     ),
	.rst_n            (I_rst_n       ),
	// ddr write request
	.dma0_wr_req      (dma0_wr_req      ),
    .dma0_wr_end      (dma0_wr_end      ),
    .dma0_wr_grant    (dma0_wr_grant    ),
	.dma0_wr_cmd      (dma0_wr_cmd      ),
	.dma0_wr_cmd_en   (dma0_wr_cmd_en   ),
	.dma0_wr_addr     (dma0_wr_addr     ),//[ADDR_WIDTH-1:0]
	.dma0_wr_data     (dma0_wr_data     ),//[DATA_WIDTH-1:0]
	.dma0_wr_data_mask(dma0_wr_data_mask),
	
	// ddr read request
	.dma0_rd_req      (dma0_rd_req      ),
    .dma0_rd_end      (dma0_rd_end      ),
    .dma0_rd_grant    (dma0_rd_grant    ),
    .dma0_rd_cmd      (dma0_rd_cmd      ),
	.dma0_rd_cmd_en   (dma0_rd_cmd_en   ),
	.dma0_rd_addr     (dma0_rd_addr     ),//[ADDR_WIDTH-1:0]
	.dma0_rd_valid    (dma0_rd_valid    ),
	.dma0_rd_data     (dma0_rd_data     ),//[DATA_WIDTH-1:0]
	
	// common output
	.cmd              (cmd              ),
	.cmd_en           (cmd_en           ),
	.addr             (addr             ),//[ADDR_WIDTH-1:0]
	.wr_data          (wr_data          ),//[DATA_WIDTH-1:0]
	.data_mask        (data_mask        ),
	.rd_data_valid    (rd_data_valid    ),
	.rd_data          (rd_data          ),//[DATA_WIDTH-1:0]
	.init_done        (init_done        )  
);

endmodule   
  