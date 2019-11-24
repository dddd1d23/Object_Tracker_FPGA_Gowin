module datatest(
	input clk,rst_n,
	output reg [7:0] d1,d2,d3,d4
);
reg [27:0] cnt;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt<=28'b0;
	else begin
		if (cnt==28'd80000000) cnt<=28'b0;
		else cnt<=cnt+1'b1;
	end
end
reg [15:0] x0,y0;
always @(*) begin
	if (cnt<=28'd20000000) begin x0=16'd150;y0=16'd300;end
	else if (cnt<=28'd40000000) begin x0=16'd400;y0=16'd500;end
	else if (cnt<=28'd60000000) begin x0=16'd500;y0=16'd600;end
	else begin x0=16'd700;y0=16'd350;end
end
assign d1=x0[15:8],d2=x0[7:0];
assign d3=y0[15:8],d4=y0[7:0];
//assign d3=8'h02,d4=8'h58;
endmodule