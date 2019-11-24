//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: v1.9.1Beta
//Part Number: GW2AR-LV18LQ144C8/I7
//Created Time: Mon Jul 08 16:46:13 2019

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    pix_pll your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .reset(reset_i), //input reset
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
