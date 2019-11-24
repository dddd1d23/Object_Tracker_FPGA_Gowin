module div227(clk,a,b,q,r);
parameter DIV_W=30;
input clk;
input [DIV_W-1:0] a; 
input [DIV_W-1:0] b;
output wire [DIV_W-1:0] q;
output wire [DIV_W-1:0] r;
//reg [15:0] tempb[0:16];
reg [(DIV_W+DIV_W-1):0] temp_a[0:DIV_W];
reg [(DIV_W+DIV_W-1):0] temp_b[0:DIV_W];
wire [(DIV_W-1):0] v0;
integer i;
assign v0=0;
always @(posedge clk)
begin
    temp_a[0]={ v0 , a };
    temp_b[0]={ b , v0 }; 
    //tempb[0]=b;
end
always @(posedge clk)
begin
    for(i = 1;i <= DIV_W;i = i + 1)
        begin
            if(temp_a[i-1][(DIV_W+DIV_W-2):(DIV_W-1)] >= temp_b[i-1][(DIV_W+DIV_W-1):DIV_W])
                temp_a[i] <= {temp_a[i-1][(DIV_W+DIV_W-2):0],1'b0} - temp_b[i-1] + 1'b1;
            else temp_a[i] <= {temp_a[i-1][(DIV_W+DIV_W-2):0],1'b0};
            temp_b[i]<=temp_b[i-1];
            //tempb[i]<=tempb[i-1];
        end
    
end
assign q = temp_a[DIV_W][(DIV_W-1):0],r = temp_a[DIV_W][(DIV_W+DIV_W-1):DIV_W];
endmodule