
#Begin clock constraint
define_clock -name {fifo_dma_write_32_256|WrClk} {p:fifo_dma_write_32_256|WrClk} -period 4.912 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 2.456 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {fifo_dma_write_32_256|RdClk} {p:fifo_dma_write_32_256|RdClk} -period 5.236 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 2.618 -route 0.000 
#End clock constraint
