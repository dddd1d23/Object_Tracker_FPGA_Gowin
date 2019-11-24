module threshold_set(
	input clk,rst_n,
	input uart_rx,
	output reg [7:0] c0,c1,c2,c3,c4,c5
);
wire [7:0] data_byte;
wire rx_done;
reg [3:0] state;
reg [7:0] c0_t,c1_t,c2_t,c3_t,c4_t,c5_t;
parameter s0=4'd0,s1=4'd1,s2=4'd2,s3=4'd3,s4=4'd4,s5=4'd5,s6=4'd6,s7=4'd7,
		  s8=4'd8,s9=4'd9,s10=4'd10,s11=4'd11;
uart_byte_rx uart_byte_rx_u0(
	.Clk(clk),        //模块时钟50M
	.Rst_n(rst_n),      //模块复位
	.baud_set(3'd0),   //波特率设置
	.Rs232_Rx(uart_rx),   //RS232数据输入
			 
	.data_byte(data_byte),  //并行数据输出
	.Rx_Done(rx_done)     //一次数据接收完成标志
);
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		c0<=8'd105;c1<=8'd117;
		c2<=8'd130;c3<=8'd235;
		c4<=8'd0;c5<=8'd255;
		state<=s0;
		c0_t<=0;c1_t<=0;c2_t<=0;c3_t<=0;c4_t<=0;c5_t<=0;
	end else 
	begin
		case (state)
		s0:begin
			if (rx_done) begin 
			 if (data_byte==8'hff) state<=s1;else state<=s0;
			end else state<=s0;
		end
		s1:begin
			if (rx_done) begin 
			 if (data_byte==8'hfe) state<=s2;else state<=s0;
			end else state<=s1;
		end
		s2:begin
			if (rx_done) begin 
			 if (data_byte==8'hfd) state<=s3;else state<=s0;
			end else state<=s2;
		end
		s3:begin
			if (rx_done) begin 
			 if (data_byte==8'hfc) state<=s4;else state<=s0;
			end else state<=s3;
		end
		s4:begin
			if (rx_done) begin
				c0_t<=data_byte;
				state<=s5;
			end else state<=s4;
		end
		s5:begin
			if (rx_done) begin
				c1_t<=data_byte;
				state<=s6;
			end else state<=s5;
		end
		s6:begin
			if (rx_done) begin
				c2_t<=data_byte;
				state<=s7;
			end else state<=s6;
		end
		s7:begin
			if (rx_done) begin
				c3_t<=data_byte;
				state<=s8;
			end else state<=s7;
		end
		s8:begin
			if (rx_done) begin
				c4_t<=data_byte;
				state<=s9;
			end else state<=s8;
		end
		s9:begin
			if (rx_done) begin
				c5_t<=data_byte;
				state<=s10;
			end else state<=s9;
		end
		s10:begin
			c0<=c0_t;c1<=c1_t;c2<=c2_t;c3<=c3_t;c4<=c4_t;c5<=c5_t;
			state<=s0;
		end
		endcase
	end
end
endmodule