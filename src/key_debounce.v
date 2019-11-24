
`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/16 12:26:43
// Design Name: 
// Module Name: key_debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define DEBCNT 32'd50000000


module key_debounce(clk, rst_n, key1_n, key_1
);
    input clk;
    input rst_n;
    input key1_n;
    output key_1;
    
    reg key_rst;

    always @(posedge clk or negedge rst_n)
    begin
    if(~rst_n)
        key_rst <= 1'b1;
    else
        key_rst <= key1_n; 
    end

    reg key_rst_r;
    always @(posedge clk or negedge rst_n)
    begin
    if(~rst_n)
        key_rst_r <= 1'b1;
        else
    key_rst_r <= key_rst; 
    end

    wire key_an = key_rst_r ^ key_rst;
    reg [31:0] cnt; 
    
    always @(posedge clk or negedge rst_n)
    begin
    if(~rst_n)
        cnt <= 32'd0;
    else if(key_an)
        cnt <= 32'd0;
    else
        cnt <= cnt + 1'd1;
    end

    reg key_1;
    always @(posedge clk or negedge rst_n)
    begin
    if(~rst_n)
        key_1 <= 1'b0;
    else if(cnt == `DEBCNT) // DEBCNT*1/(50MHZ)  , 32'd50000000->1s
        key_1 <= key1_n; 
    else
        key_1 <= key_1; 
    end
    endmodule
