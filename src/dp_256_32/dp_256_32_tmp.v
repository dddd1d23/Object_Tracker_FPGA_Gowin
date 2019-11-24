//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: v1.9.2Beta
//Part Number: GW2AR-LV18EQ144PC8/I7
//Created Time: Thu Nov 14 22:05:17 2019

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    dp_256_32 your_instance_name(
        .douta(douta_o), //output [31:0] douta
        .doutb(doutb_o), //output [31:0] doutb
        .clka(clka_i), //input clka
        .ocea(ocea_i), //input ocea
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .wrea(wrea_i), //input wrea
        .clkb(clkb_i), //input clkb
        .oceb(oceb_i), //input oceb
        .ceb(ceb_i), //input ceb
        .resetb(resetb_i), //input resetb
        .wreb(wreb_i), //input wreb
        .ada(ada_i), //input [7:0] ada
        .dina(dina_i), //input [31:0] dina
        .adb(adb_i), //input [7:0] adb
        .dinb(dinb_i) //input [31:0] dinb
    );

//--------Copy end-------------------
