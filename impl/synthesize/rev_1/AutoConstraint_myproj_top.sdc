
#Begin clock constraint
define_clock -name {myproj_top|cmos_pclk0} {p:myproj_top|cmos_pclk0} -period 4.244 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.122 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {myproj_top|I_clk_50m} {p:myproj_top|I_clk_50m} -period 6.426 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 3.213 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {pll_36m|clkout_inferred_clock} {n:pll_36m|clkout_inferred_clock} -period 10.119 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 5.060 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_top_PSRAM_Memory_Interface_Top__|clk_out_inferred_clock} {n:_~psram_top_PSRAM_Memory_Interface_Top__|clk_out_inferred_clock} -period 7.284 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 3.642 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_top_PSRAM_Memory_Interface_Top__|clk_x2p_inferred_clock} {n:_~psram_top_PSRAM_Memory_Interface_Top__|clk_x2p_inferred_clock} -period 66667.000 -clockgroup Autoconstr_clkgroup_4 -rise 0.000 -fall 33333.500 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {myproj_top|cmos_pclk2_derived_clock} {n:myproj_top|cmos_pclk2_derived_clock} -period 9902.123 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 4951.062 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_wd_PSRAM_Memory_Interface_Top__|step_derived_clock[0]} {n:_~psram_wd_PSRAM_Memory_Interface_Top__|step_derived_clock[0]} -period 16993.857 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 8496.928 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[0]} {n:_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[0]} -period 16993.857 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 8496.928 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[1]} {n:_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[1]} -period 16993.857 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 8496.928 -route 0.000 
#End clock constraint
