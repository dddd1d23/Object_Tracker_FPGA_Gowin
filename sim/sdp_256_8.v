//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: v1.9.2Beta
//Part Number: GW2AR-LV18EQ144PC8/I7
//Created Time: Thu Nov 14 17:10:02 2019

module sdp_256_8 (dout, clka, cea, reseta, wrea, clkb, ceb, resetb, wreb, oce, ada, din, adb);

output [7:0] dout;
input clka;
input cea;
input reseta;
input wrea;
input clkb;
input ceb;
input resetb;
input wreb;
input oce;
input [7:0] ada;
input [7:0] din;
input [7:0] adb;

wire gw_gnd;

assign gw_gnd = 1'b0;

SDP sdp_inst_0 (
    .DO(dout[7:0]),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .OCE(oce),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,gw_gnd,gw_gnd,ada[7:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI(din[7:0]),
    .ADB({gw_gnd,gw_gnd,gw_gnd,adb[7:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam sdp_inst_0.READ_MODE = 1'b0;
defparam sdp_inst_0.BIT_WIDTH_0 = 8;
defparam sdp_inst_0.BIT_WIDTH_1 = 8;
defparam sdp_inst_0.BLK_SEL = 3'b000;
defparam sdp_inst_0.RESET_MODE = "SYNC";

endmodule //sdp_256_8
