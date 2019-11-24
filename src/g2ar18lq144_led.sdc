//Copyright (C)2014-2019 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.1 Beta
//Created Time: 2019-07-08 17:15:17
create_clock -name I_clk_50m -period 20 -waveform {0 10} [get_ports {I_clk_50m}] -add
//create_clock -name cmos_pclk -period 16.000 -waveform { 0.000 8.000 } [get_ports {cmos_pclk}] -add
