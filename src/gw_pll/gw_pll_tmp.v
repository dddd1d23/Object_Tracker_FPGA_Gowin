//Copyright (C)2014-2019 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.1.01Beta
//Part Number: GW2AR-LV18EQ144PC8/I7
//Created Time: Tue Sep 10 15:24:32 2019

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    gw_pll your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .reset(reset_i), //input reset
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
