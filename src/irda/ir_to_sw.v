module ir_to_sw(
	input clk,
	input [31:0] ir_data,
	input rst_n,
	input get_en,
	output reg [3:0] sw,
	output reg sweep_en
);
//assign changed=(ir_data!=ir_data_t);
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin sw<=0;sweep_en<=1'b0;end 
	else if (get_en) begin
		if (ir_data==32'hBA45FF00) begin
			sw[0]<=~sw[0];sweep_en<=1'b0;
		end else if (ir_data==32'hB946FF00) begin
			sw[1]<=~sw[1];sweep_en<=1'b0;
		end else if (ir_data==32'hB847FF00) begin
			sw[2]<=~sw[2];sweep_en<=1'b0;
		end else if (ir_data==32'hBB44FF00) begin
			sw[3]<=~sw[3];sweep_en<=1'b0;
		end else if (ir_data==32'hBF40FF00) begin
			sweep_en<=1'b1;
		end else begin sw<=sw;sweep_en<=1'b0;end
	end else begin sw<=sw;sweep_en<=1'b0;end
end
endmodule