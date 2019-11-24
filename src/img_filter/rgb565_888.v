module rgb565_888(
	input [15:0] d,
	output [7:0] r,g,b
);
assign r[7:3]=d[15:11];
assign r[2:0]=d[13:11];
assign g[7:2]=d[10:5];
assign g[1:0]=d[6:5];
assign b[7:3]=d[4:0];
assign b[2:0]=d[2:0];
endmodule