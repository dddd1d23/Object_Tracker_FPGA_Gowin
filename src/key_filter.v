module key_filter(key_in,clk,rst_n,key_state,key_flag,key_pressed);
input key_in,clk,rst_n;
output reg key_state,key_flag;
output key_pressed;
reg key_in_a,key_in_b,key_tmp_a,key_tmp_b;
reg [1:0]state;
reg [19:0]cnt;
reg cnt_en,cnt_full;
localparam IDLE=2'b00;
localparam FILTER0=2'b01;
localparam DOWN=2'b10;
localparam FILTER1=2'b11;
wire pedge,nedge;
always@(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin
  key_in_a<=1'b0;
  key_in_b<=1'b0;
 end else
 begin
  key_in_a<=key_in;
  key_in_b<=key_in_a;
 end
end 
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin
  key_tmp_a<=1'b0;
  key_tmp_b<=1'b0;
 end else
 begin
  key_tmp_a<=key_in_b;
  key_tmp_b<=key_tmp_a;
 end
end
assign pedge=key_tmp_a && (!key_tmp_b);
assign nedge=(!key_tmp_a) && key_tmp_b;
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n)
  cnt<=20'd0;
 else if (cnt_en)
  cnt<=cnt+1'b1;
 else cnt<=20'd0;
end
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n)
  cnt_full<=1'b0;
 else if (cnt==20'd999999)
  cnt_full<=1'b1;
 else cnt_full<=1'b0;
end
always @(posedge clk or negedge rst_n)
begin
 if (!rst_n) begin
  state<=IDLE;
  key_flag<=1'b0;
  key_state<=1'b1;
 end else
 begin
  case (state)
   default:
	 begin
	  state<=IDLE;
	  key_flag<=1'b0;
     key_state<=1'b1;
	  cnt_en<=1'b0;
	 end
   IDLE:
	 begin
	  key_flag<=1'b0;
	  if (nedge) begin
	   state<=FILTER0;
		cnt_en<=1'b1;
	  end else 
	  state<=IDLE;
	 end
	FILTER0:
	 begin
	  if (cnt_full) 
	   begin
		 key_flag<=1'b1;
		 key_state<=1'b0;
		 state<=DOWN;
		 cnt_en<=1'b0;
		end else if (pedge)
		begin
		 state<=IDLE;
		 cnt_en<=1'b0;
		end
	 end
	DOWN:
	 begin
	  key_flag<=1'b0;
	  if (pedge) 
	   begin
		 state<=FILTER1;
		 cnt_en<=1'b1;
		end else 
		 state<=DOWN;
	 end
	FILTER1:
	 begin
	  if (cnt_full) 
	   begin
		 key_flag<=1'b1;
		 key_state<=1'b1;
		 state<=IDLE;
		 cnt_en<=1'b0;
		end else if (nedge)
		begin
		 state<=DOWN;
		 cnt_en<=1'b0;
		end
	 end
  endcase
 end
end
assign key_pressed=key_flag && (!key_state);
endmodule
