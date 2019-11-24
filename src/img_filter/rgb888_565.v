module rgb888_565(
	input [7:0] r,g,b,
	output [15:0] d
);
assign d[15:11]=r[7:3];
assign d[10:5]=g[7:2];
assign d[4:0]=b[7:3];
endmodule