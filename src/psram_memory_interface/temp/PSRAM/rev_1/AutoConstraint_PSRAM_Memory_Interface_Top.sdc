
#Begin clock constraint
define_clock -name {_~psram_top.PSRAM_Memory_Interface_Top_|clk_out_inferred_clock} {n:_~psram_top.PSRAM_Memory_Interface_Top_|clk_out_inferred_clock} -period 5.177 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.588 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {PSRAM_Memory_Interface_Top|clk} {p:PSRAM_Memory_Interface_Top|clk} -period 3.305 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 1.652 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_top.PSRAM_Memory_Interface_Top_|clk_x2p_inferred_clock} {n:_~psram_top.PSRAM_Memory_Interface_Top_|clk_x2p_inferred_clock} -period 66667.000 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 33333.500 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_wd.PSRAM_Memory_Interface_Top_|step_derived_clock[0]} {n:_~psram_wd.PSRAM_Memory_Interface_Top_|step_derived_clock[0]} -period 193526.729 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 96763.365 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init.PSRAM_Memory_Interface_Top_|read_calibration[0].VALUE_derived_clock[0]} {n:_~psram_init.PSRAM_Memory_Interface_Top_|read_calibration[0].VALUE_derived_clock[0]} -period 193526.729 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 96763.365 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {_~psram_init.PSRAM_Memory_Interface_Top_|read_calibration[1].VALUE_derived_clock[1]} {n:_~psram_init.PSRAM_Memory_Interface_Top_|read_calibration[1].VALUE_derived_clock[1]} -period 193526.729 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 96763.365 -route 0.000 
#End clock constraint
