module  histogram_equalized_top(
    input clk,rst_n,pre_vs,pre_hs,pre_clken,
    input [7:0] pre_imgdata,
    output post_vs,post_hs,post_clken,
    output [7:0] post_imgdata
);
//======================================================================\
//************** Define Parameter and Internal Signals *****************
//======================================================================/
reg                             flag_finish_r                   ;
wire                            flag_finish_pos                 ;
//cnt
reg     [ 9: 0]                 cnt                             ;
wire                            add_cnt                         ;
wire                            end_cnt                         ;
//histogram_equalized_inst
reg                             out_req                         ;
wire    [ 7: 0]                 dout                            ;
wire                            dout_vld                        ;
wire                            flag_finish                     ;
wire                            hist_equalized_dout_vld         ;
wire    [31: 0]                 hist_equalized_dout             ;
//======================================================================\
//**************************** Main Code *******************************
//======================================================================/
//flag_finish_r
always  @(posedge clk or negedge rst_n) begin
    if (!rst_n) flag_finish_r<=0;
    else flag_finish_r   <=  flag_finish;
end

assign  flag_finish_pos =   flag_finish && (~flag_finish_r);

//cnt
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

assign  add_cnt     =       out_req;       
assign  end_cnt     =       add_cnt && cnt == 512-1;   

//out_req
always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        out_req <=  1'b0;
    end
    else if(flag_finish_pos)begin
        out_req <=  1'b1;
    end
    else if(end_cnt)begin
        out_req <=  1'b0;
    end
end
//直方图统计模块
histogram_equalized histogram_equalized_inst(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                          ),
        .cap_vsync              (pre_vs                      ),
        .cap_vld                (pre_clken                        ),
        .cap_data               (pre_imgdata                       ),
        .out_req                (out_req                        ),
        .dout                   (dout                           ),
        .dout_vld               (dout_vld                       ),
        .flag_finish            (flag_finish                    ),
        //equalized
        .hist_equalized_dout_vld(        ),
        .hist_equalized_dout    (post_imgdata            )
);
always @(posedge clk)
begin
    if (flag_finish_pos) $display($time);
end
assign post_vs=pre_vs,post_hs=pre_hs,post_clken=pre_clken;
endmodule
