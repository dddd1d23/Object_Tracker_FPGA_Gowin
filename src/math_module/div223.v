module div223
(
	input clk,
	input rst_n,
	input en,
	input [31:0] a, 
	input [31:0] b,
	output reg [31:0] q,
	output reg [31:0] r,
	output reg done
);
reg [31:0] tempa;
reg [31:0] tempb;
reg [63:0] temp_a;
reg [63:0] temp_b;
reg [5:0] status;
parameter s_idle=6'b000000;
parameter s_init=6'b000001;
parameter s_calc1=6'b000010;
parameter s_calc2=6'b000100;
parameter s_done=6'b001000;
reg [31:0] i;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			i<=32'h0;
			tempa<=32'h1;
			tempb<=32'h1;
			q<=32'h1;
			r<=32'h1;
			done<=1'b0;
			status<=s_idle;
		end
	else
		begin
			case (status)
			s_idle:
				begin
					if (en)
						begin
							i<=32'h0;
							tempa<=a;
							tempb<=b;
							status<=s_init;
							done<=1'b0;
						end
					else
						begin
							i<=32'h0;
							tempa<=32'h1;
							tempb<=32'h1;
							q<=32'h1;
							r<=32'h1;
							done<=1'b0;
							status<=s_idle;
						end
				end
			s_init:
				begin
					temp_a={32'h00000000,tempa};
					temp_b={tempb,32'h00000000};
					status<=s_calc1;
				end
			s_calc1:
				begin
					if(i<32)
						begin
							temp_a={temp_a[62:0],1'b0};
							status<=s_calc2;
						end
					else
						begin
							status<=s_done;
						end
				end				
			s_calc2:
				begin
					if(temp_a[63:32]>=tempb)
						begin
							temp_a=temp_a-temp_b+1'b1;
						end
					else
						begin
							temp_a=temp_a;
						end
					i<=i+1'b1;	
					status<=s_calc1;
				end
			s_done:
				begin
					q<=temp_a[31:0];
					r<=temp_a[63:32];
					done<=1'b1;
					status<=s_idle;
				end
			default:
				begin
					status<=s_idle;
				end
			endcase
		end
end
endmodule