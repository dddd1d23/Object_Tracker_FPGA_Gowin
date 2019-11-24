module rgb16_24(
	input [15:0] i,
	output [23:0] o
);
assign o[23:16]={i[15:11],i[13:11]};
assign o[15:8]={i[10:5],i[6:5]};
assign o[7:0]={i[4:0],i[2:0]};
endmodule