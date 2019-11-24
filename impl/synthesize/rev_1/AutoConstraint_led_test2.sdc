
#Begin clock constraint
define_clock -name {led_test2|cmos_pclk} {p:led_test2|cmos_pclk} -period 4.214 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.107 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {led_test2|I_clk_50m} {p:led_test2|I_clk_50m} -period 7.114 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 3.557 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {pll_75m|clkout_inferred_clock} {n:pll_75m|clkout_inferred_clock} -period 5.140 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 2.570 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_top_PSRAM_Memory_Interface_Top__|clk_out_inferred_clock} {n:_~psram_top_PSRAM_Memory_Interface_Top__|clk_out_inferred_clock} -period 7.179 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 3.589 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_top_PSRAM_Memory_Interface_Top__|clk_x2p_inferred_clock} {n:_~psram_top_PSRAM_Memory_Interface_Top__|clk_x2p_inferred_clock} -period 66667.000 -clockgroup Autoconstr_clkgroup_4 -rise 0.000 -fall 33333.500 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {led_test2|cmos_pclk2_derived_clock} {n:led_test2|cmos_pclk2_derived_clock} -period 157543.925 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 78771.963 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_wd_PSRAM_Memory_Interface_Top__|step_derived_clock[0]} {n:_~psram_wd_PSRAM_Memory_Interface_Top__|step_derived_clock[0]} -period 200000000.000 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 100000000.000 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[0]} {n:_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[0]} -period 200000000.000 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 100000000.000 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[1]} {n:_~psram_init_PSRAM_Memory_Interface_Top__|VALUE_1_derived_clock[1]} -period 200000000.000 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 100000000.000 -route 0.000 
#End clock constraint
