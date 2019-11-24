/***************************************************
*	Module Name		:	ir_decoder		   
*	Engineer		:	dhy0077
*	Target Device	:	
*	Tool versions	:	
*	Create Date		:	2019-8-4
*	Revision		:	v1.0
*	Description		:   红外遥控解析模块
**************************************************/
module ir_decoder(clk,rst_n,IRDA_RXD,irdata,iraddr,Get_en);
input clk,rst_n,IRDA_RXD;
output [15:0] irdata,iraddr;
output Get_en;
reg T9ms_OK,T4_5ms_OK,T_56ms_OK,T1_69ms_OK;
reg cnt_en,timeout;
reg [3:0] state;
reg ir_t,ir_tt,ir_ttt;
reg [5:0] data_cnt;
reg [31:0] data_tmp;
reg [18:0] cnt;
reg GetDataDone;
wire ir_nedge,ir_pedge;
//state machine parameter
 localparam 
 IDLE=4'b0001,LEADER_T9=4'b0010,
 LEADER_T4_5=4'b0100,
 DATA_GET=4'b1000;
//------------------------------------------
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin cnt<=19'b0;end
 else if (cnt_en) cnt<=cnt+1'b1;
 else cnt<=19'b0;
end
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) timeout<=1'b0;
	else if (cnt>=19'd500000) timeout<=1'b1;
	else timeout<=1'b0;
end
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin T9ms_OK<=1'b0;T4_5ms_OK<=1'b0;T_56ms_OK<=1'b0;T1_69ms_OK<=1'b0;end
 else begin
 	T9ms_OK<=(cnt>19'd325000 && cnt<19'd495000)?1'b1:1'b0;
 	T4_5ms_OK<=(cnt>19'd152500 && cnt<19'd277500)?1'b1:1'b0;
 	T_56ms_OK<=(cnt>19'd20000 && cnt<19'd35000)?1'b1:1'b0;
 	T1_69ms_OK<=(cnt>19'd75000 && cnt<19'd90000)?1'b1:1'b0;
 end	
end
//irda process
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin ir_t<=1'b1;ir_tt<=1'b1;ir_ttt<=1'b1;end
 else begin
 	ir_t<=IRDA_RXD;ir_tt<=ir_t;ir_ttt<=ir_tt;
 end
end
assign ir_pedge=ir_tt && (!ir_ttt);
assign ir_nedge=(!ir_tt) && ir_ttt;
//state machine begin
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin state<=IDLE;cnt_en<=1'b0;end
	else if (!timeout) begin
		case (state)
		 default:begin state<=IDLE;cnt_en<=1'b0;end
         IDLE:begin
         	if (ir_nedge) begin 
         		state<=LEADER_T9;
         		cnt_en<=1'b1;
         	end else begin state<=IDLE;cnt_en<=1'b0;end
         end
         LEADER_T9:begin
         	if (ir_pedge) begin
         		if (T9ms_OK) begin
         			cnt_en<=1'b0;
         			state<=LEADER_T4_5;
         		end else state<=IDLE;
         	end else begin state<=LEADER_T9;cnt_en<=1'b1;end
         end
         LEADER_T4_5:begin
         	if (ir_nedge) begin
         		if (T4_5ms_OK) begin
         			cnt_en<=1'b0;
         			state<=DATA_GET;
         		end else state<=IDLE;
         	end else begin state<=LEADER_T4_5;cnt_en<=1'b1;end
         end
         DATA_GET:begin
         	if (ir_pedge && !T_56ms_OK) state<=IDLE;
         	else if (ir_nedge && !T_56ms_OK && !T1_69ms_OK) state<=IDLE;
         	else if (GetDataDone) state<=IDLE;
         	else if (ir_pedge && T_56ms_OK) cnt_en<=1'b0;
         	else if (ir_nedge && (T_56ms_OK||T1_69ms_OK)) cnt_en<=1'b0;
         	else cnt_en<=1'b1;
         end
		endcase
	end else begin state<=IDLE;cnt_en<=1'b0;end
end
//dataget process
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin data_cnt<=6'b0;data_tmp<=32'b0;GetDataDone<=1'b0;end
	else if (state==DATA_GET) begin
		if (ir_pedge && (data_cnt==6'd32))
		 begin
		   GetDataDone<=1'b1;
		   data_cnt<=6'b0;
		 end else begin
		    GetDataDone<=1'b0;
		 	if (ir_nedge && T_56ms_OK) begin data_tmp[data_cnt]<=1'b0;data_cnt<=data_cnt+1'b1;end
		 	else if (ir_nedge && T1_69ms_OK) begin data_tmp[data_cnt]<=1'b1;data_cnt<=data_cnt+1'b1;end
		 end
	end else GetDataDone<=1'b0;
end
assign Get_en=GetDataDone;
//data output
assign iraddr=data_tmp[15:0];
assign irdata=data_tmp[31:16];
endmodule