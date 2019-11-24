module uart_byte_tx(
	Clk,       //50M时钟输入
	Rst_n,     //模块复位
	data_byte, //待传输8bit数据
	send_en,   //发送使能
	baud_set,  //波特率设置
	
	Rs232_Tx,  //Rs232输出信号
	Tx_Done,   //一次发送数据完成标志
	uart_state //发送数据状态
);

	input Clk;
	input Rst_n;
	input [7:0]data_byte;
	input send_en;
	input [2:0]baud_set;
	
	output reg Rs232_Tx;
	output reg Tx_Done;
	output reg uart_state;
	
	reg bps_clk;	//波特率时钟
	
	reg [15:0]div_cnt;//分频计数器
	
	reg [15:0]bps_DR;//分频计数最大值
	
	reg [3:0]bps_cnt;//波特率时钟计数器
	
	reg [7:0]r_data_byte;
	
	localparam START_BIT = 1'b0;
	localparam STOP_BIT = 1'b1;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		uart_state <= 1'b0;
	else if(send_en)
		uart_state <= 1'b1;
	else if(bps_cnt == 4'd11)
		uart_state <= 1'b0;
	else
		uart_state <= uart_state;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		r_data_byte <= 8'd0;
	else if(send_en)
		r_data_byte <= data_byte;
	else
		r_data_byte <= r_data_byte;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		bps_DR <= 16'd5207;
	else begin
		case(baud_set)
			0:bps_DR <= 16'd5207;
			1:bps_DR <= 16'd2603;
			2:bps_DR <= 16'd1301;
			3:bps_DR <= 16'd867;
			4:bps_DR <= 16'd433;
			default:bps_DR <= 16'd5207;			
		endcase
	end	
	
	//counter
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		div_cnt <= 16'd0;
	else if(uart_state)begin
		if(div_cnt == bps_DR)
			div_cnt <= 16'd0;
		else
			div_cnt <= div_cnt + 1'b1;
	end
	else
		div_cnt <= 16'd0;
	
	// bps_clk gen
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		bps_clk <= 1'b0;
	else if(div_cnt == 16'd1)
		bps_clk <= 1'b1;
	else
		bps_clk <= 1'b0;
	
	//bps counter
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)	
		bps_cnt <= 4'd0;
	else if(bps_cnt == 4'd11)
		bps_cnt <= 4'd0;
	else if(bps_clk)
		bps_cnt <= bps_cnt + 1'b1;
	else
		bps_cnt <= bps_cnt;
		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Tx_Done <= 1'b0;
	else if(bps_cnt == 4'd11)
		Tx_Done <= 1'b1;
	else
		Tx_Done <= 1'b0;
		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Rs232_Tx <= 1'b1;
	else begin
		case(bps_cnt)
			0:Rs232_Tx <= 1'b1;
			1:Rs232_Tx <= START_BIT;
			2:Rs232_Tx <= r_data_byte[0];
			3:Rs232_Tx <= r_data_byte[1];
			4:Rs232_Tx <= r_data_byte[2];
			5:Rs232_Tx <= r_data_byte[3];
			6:Rs232_Tx <= r_data_byte[4];
			7:Rs232_Tx <= r_data_byte[5];
			8:Rs232_Tx <= r_data_byte[6];
			9:Rs232_Tx <= r_data_byte[7];
			10:Rs232_Tx <= STOP_BIT;
			default:Rs232_Tx <= 1'b1;
		endcase
	end	

endmodule
