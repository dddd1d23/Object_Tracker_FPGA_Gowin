module box_calculator(
	input clk,rst_n,
	input pre_vs,pre_hs,pre_imgbit,pre_clken,
	input [15:0] pre_imgdata,
	output post_vs,post_hs,post_imgbit,post_clken,
	output [15:0] post_imgdata,
	output [10:0] px,py,
	output [10:0] a
);
reg vs_n_t;
wire vs_nedge,vs_pedge,vs_n;
assign vs_n=pre_vs;
reg [10:0] pre_x,pre_y;
parameter row_cnt=800;
parameter col_cnt=600;
//--------------------------------------------------------------
assign post_hs=pre_hs;
assign post_vs=pre_vs;
assign post_clken=pre_clken;
assign post_imgdata=pre_imgdata;
assign post_imgbit=pre_imgbit;
//generate pre_x,pre_y
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        pre_x<=0;
    end
    else if (pre_clken && pre_x==row_cnt-1)
        pre_x<=0;
    else if (pre_clken) begin
        pre_x<=pre_x+1'b1;
    end
    else pre_x<=pre_x;
end
assign row_flag=(pre_clken && pre_x==row_cnt-1'b1)?1'b1:1'b0;
always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        pre_y<=0;
    end
    else if (row_flag && pre_y==col_cnt-1'b1)
        pre_y<=0;
    else if (row_flag) begin
        pre_y<=pre_y + 1'b1;
    end
    else pre_y<=pre_y;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) vs_n_t<=0;
	else vs_n_t<=vs_n;
end
assign vs_nedge=vs_n_t && (!vs_n);
assign vs_pedge=(!vs_n_t) && vs_n;
reg [31:0] sum_x,sum_y;
reg [31:0] t_sum_x,t_sum_y;
reg [21:0] sum,t_sum;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin sum_x<=0;sum_y<=0;sum<=0;end
	else if (vs_pedge) begin sum_x<=0;sum_y<=0;sum<=0;end
	else if (pre_clken && pre_imgbit) begin
		sum_x<=sum_x+pre_x;sum_y<=sum_y+pre_y;
		sum<=sum+1'b1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin t_sum_x<=32'b0;t_sum_y<=32'b0;t_sum<=0;end
	else if (vs_nedge) begin
		t_sum_x<=sum_x;t_sum_y<=sum_y;t_sum<=sum;
	end
end
div223 div223_u0(.clk(clk),.rst_n(rst_n),.a(t_sum_x),.b({10'b0,t_sum}),.q(px),.r(),.en(1'b1),.done());
div223 div223_u1(.clk(clk),.rst_n(rst_n),.a(t_sum_y),.b({10'b0,t_sum}),.q(py),.r(),.en(1'b1),.done());
sqrt_1 sqrt_1_u0(.clk(clk),.rst_n(rst_n),.i_vaild(1'b1),.o_vaild(),.data_i({1'b0,t_sum}),.data_r(),.data_o(a));
endmodule