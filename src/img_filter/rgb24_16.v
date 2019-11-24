module rgb24_16(
	input [23:0] i,
	output [15:0] o
);
assign o[15:11]=i[23:19];
assign o[10:5]=i[15:10];
assign o[4:0]=i[7:3];
endmodule