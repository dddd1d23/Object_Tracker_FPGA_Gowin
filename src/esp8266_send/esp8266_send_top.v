module esp8266_send_top(
	input clk,rst_n,
	input [7:0] d1,d2,d3,d4,
	output uart_tx
	//output reg init_done,
);
parameter s0=4'd0,s1=4'd1,s2=4'd2,s3=4'd3,s4=4'd4,s5=4'd5,s6=4'd6,s7=4'd7,s8=4'd8,s9=4'd9;
reg [3:0] state;
reg [7:0] s_data,s_d1,s_d2,s_d3,s_d4,s_xor;
reg s_en;
wire Tx_Done;	
uart_byte_tx u0(
	.Clk(clk),
	.Rst_n(rst_n),
	.send_en(s_en),
	.baud_set(3'd4),
	.Rs232_Tx(uart_tx),
	.data_byte(s_data),
	.Tx_Done(Tx_Done),
	.uart_state()
);
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state<=s0;
	end else 
	begin
		case (state)
		s0:begin 
            s_en<=1'b0;state<=s1;
            s_d1<=d1;s_d2<=d2;s_d3<=d3;s_d4<=d4;s_en<=1'b0;
            s_xor=s_d1^s_d2^s_d3^s_d4;
        end
		s1:begin
			s_data<=8'hFF;
			if (Tx_Done) begin s_en<=1'b0;state<=s2;end else begin state<=s1;s_en<=1'b1;end
		end
		s2:begin
			s_data<=8'hFE;
			if (Tx_Done) begin s_en<=1'b0;state<=s3;end 
			else begin state<=s2;s_en<=1'b1;end
		end
		s3:begin
			s_data<=8'hFD;
			if (Tx_Done) begin s_en<=1'b0;state<=s4;end 
			else begin state<=s3;s_en<=1'b1;end
		end
		s4:begin
			s_data<=8'hFC;
			if (Tx_Done) begin s_en<=1'b0;state<=s5;end 
			else begin state<=s4;s_en<=1'b1;end
		end
		s5:begin
			s_data<=s_d1;
			if (Tx_Done) begin s_en<=1'b0;state<=s6;end 
			else begin state<=s5;s_en<=1'b1;end
		end
		s6:begin
			s_data<=s_d2;
			if (Tx_Done) begin s_en<=1'b0;state<=s7;end 
			else begin state<=s6;s_en<=1'b1;end
		end
		s7:begin
			s_data<=s_d3;
			if (Tx_Done) begin s_en<=1'b0;state<=s8;end 
			else begin state<=s7;s_en<=1'b1;end
		end
		s8:begin
			s_data<=s_d4;
			if (Tx_Done) begin s_en<=1'b0;state<=s9;end 
			else begin state<=s8;s_en<=1'b1;end
		end
        s9:begin
            s_data<=s_xor;
            if (Tx_Done) begin s_en<=1'b0;state<=s0;end 
			else begin state<=s9;s_en<=1'b1;end
        end
        endcase
	end
end
endmodule 