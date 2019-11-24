//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: v1.9.2Beta
//Part Number: GW2AR-LV18EQ144PC8/I7
//Created Time: Mon Nov 11 18:16:01 2019

module Gowin_DP (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [7:0] douta;
output [7:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [7:0] ada;
input [7:0] dina;
input [7:0] adb;
input [7:0] dinb;

wire gw_gnd;

assign gw_gnd = 1'b0;

DP dp_inst_0 (
    .DOA(douta[7:0]),
    .DOB(doutb[7:0]),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,gw_gnd,gw_gnd,ada[7:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA(dina[7:0]),
    .ADB({gw_gnd,gw_gnd,gw_gnd,adb[7:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB(dinb[7:0])
);

defparam dp_inst_0.READ_MODE0 = 1'b0;
defparam dp_inst_0.READ_MODE1 = 1'b0;
defparam dp_inst_0.WRITE_MODE0 = 2'b00;
defparam dp_inst_0.WRITE_MODE1 = 2'b00;
defparam dp_inst_0.BIT_WIDTH_0 = 8;
defparam dp_inst_0.BIT_WIDTH_1 = 8;
defparam dp_inst_0.BLK_SEL = 3'b000;
defparam dp_inst_0.RESET_MODE = "SYNC";

endmodule //Gowin_DP
