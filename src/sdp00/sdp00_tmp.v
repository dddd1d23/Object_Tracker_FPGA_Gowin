//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: v1.9.2Beta
//Part Number: GW2AR-LV18EQ144PC8/I7
//Created Time: Wed Nov 13 16:22:33 2019

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    sdp00 your_instance_name(
        .dout(dout_o), //output [31:0] dout
        .clka(clka_i), //input clka
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .wrea(wrea_i), //input wrea
        .clkb(clkb_i), //input clkb
        .ceb(ceb_i), //input ceb
        .resetb(resetb_i), //input resetb
        .wreb(wreb_i), //input wreb
        .oce(oce_i), //input oce
        .ada(ada_i), //input [7:0] ada
        .din(din_i), //input [31:0] din
        .adb(adb_i) //input [7:0] adb
    );

//--------Copy end-------------------
