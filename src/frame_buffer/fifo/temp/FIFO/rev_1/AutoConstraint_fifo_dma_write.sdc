
#Begin clock constraint
define_clock -name {fifo_dma_write|WrClk} {p:fifo_dma_write|WrClk} -period 5.196 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.598 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {fifo_dma_write|RdClk} {p:fifo_dma_write|RdClk} -period 5.184 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 2.592 -route 0.000 
#End clock constraint
