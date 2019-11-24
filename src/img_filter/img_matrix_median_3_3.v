module img_matrix_median_3_3(
	input clk,rst_n,
	input data_in_en,
	input [7:0] matrix_p11, matrix_p12, matrix_p13,
	input [7:0] matrix_p21, matrix_p22, matrix_p23,
	input [7:0] matrix_p31, matrix_p32, matrix_p33,
	output [7:0] median
);
//assign data_in_en=1'b1;
//--------------------------------------
//define line max mid min
//--------------------------------------
reg [7:0] line0_max;
reg [7:0] line0_mid;
reg [7:0] line0_min;
reg [7:0] line1_max;
reg [7:0] line1_mid;
reg [7:0] line1_min;
reg [7:0] line2_max;
reg [7:0] line2_mid;
reg [7:0] line2_min;

//----------------------------------------------
// define //max of min //mid of mid// min of max
//----------------------------------------------

reg [7:0] max_max;
reg [7:0] max_mid;
reg [7:0] max_min;
reg [7:0] mid_max;
reg [7:0] mid_mid;
reg [7:0] mid_min;
reg [7:0] min_max;
reg [7:0] min_mid;
reg [7:0] min_min;
reg [7:0] mid;
//-----------------------------------------------------------------------------------
//(line0 line1 line2) of (max mid min)
//-----------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    line0_max <= 8'b0;
    line0_mid <= 8'b0;
    line0_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((matrix_p11 >= matrix_p12) && (matrix_p11 >= matrix_p13)) begin
	   line0_max <= matrix_p11;
		if(matrix_p12 >= matrix_p13) begin
		  line0_mid <= matrix_p12;
		  line0_min <= matrix_p13;
		end 
		else begin
		  line0_mid <= matrix_p13;
		  line0_min <= matrix_p12;
		end
	 end
	 else if((matrix_p12 > matrix_p11) && (matrix_p12 >= matrix_p13)) begin
	   line0_max <= matrix_p12;
		if(matrix_p11 >= matrix_p13) begin
		  line0_mid <= matrix_p11;
		  line0_min <= matrix_p13;
		end 
		else begin
		  line0_mid <= matrix_p13;
		  line0_min <= matrix_p11;
		end
	 end
	 else if((matrix_p13 > matrix_p11) && (matrix_p13 > matrix_p12)) begin
	   line0_max <= matrix_p13;
		if(matrix_p11 >= matrix_p12) begin
		  line0_mid <= matrix_p11;
		  line0_min <= matrix_p12;
		end 
		else begin
		  line0_mid <= matrix_p12;
		  line0_min <= matrix_p11;
		end
	 end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
	 line1_max <= 8'b0;
     line1_mid <= 8'b0;
     line1_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((matrix_p21 >= matrix_p22) && (matrix_p21 >= matrix_p23)) begin
	   line1_max <= matrix_p21;
		if(matrix_p22 >= matrix_p23) begin
		  line1_mid <= matrix_p22;
		  line1_min <= matrix_p23;
		end 
		else begin
		  line1_mid <= matrix_p23;
		  line1_min <= matrix_p22;
		end
	 end
	 else if((matrix_p22 > matrix_p21) && (matrix_p22 >= matrix_p23)) begin
	   line1_max <= matrix_p22;
		if(matrix_p21 >= matrix_p23) begin
		  line1_mid <= matrix_p21;
		  line1_min <= matrix_p23;
		end 
		else begin
		  line1_mid <= matrix_p23;
		  line1_min <= matrix_p21;
		end	 
	 end
	 else if((matrix_p23 > matrix_p21) && (matrix_p23 > matrix_p22)) begin
	   line1_max <= matrix_p23;
		if(matrix_p21 >= matrix_p22) begin
		  line1_mid <= matrix_p21;
		  line1_min <= matrix_p22;
		end 
		else begin
		  line1_mid <= matrix_p22;
		  line1_min <= matrix_p21;
		end	 
	 end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
	 line2_max <= 8'b0;
     line2_mid <= 8'b0;
     line2_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((matrix_p31 >= matrix_p32) && (matrix_p31 >= matrix_p33)) begin
	   line2_max <= matrix_p31;
		if(matrix_p32 > matrix_p33) begin
		  line2_mid <= matrix_p32;
		  line2_min <= matrix_p33;
		end 
		else begin
		  line2_mid <= matrix_p33;
		  line2_min <= matrix_p32;
		end
	 end
	 else if((matrix_p32 > matrix_p31) && (matrix_p32 >= matrix_p33)) begin
	   line2_max <= matrix_p32;
		if(matrix_p31 >= matrix_p33) begin
		  line2_mid <= matrix_p31;
		  line2_min <= matrix_p33;
		end 
		else begin
		  line2_mid <= matrix_p33;
		  line2_min <= matrix_p31;
		end	 
	 end
	 else if((matrix_p33 > matrix_p31) && (matrix_p33 > matrix_p32)) begin
	   line2_max <= matrix_p33;
		if(matrix_p31 >= matrix_p32) begin
		  line2_mid <= matrix_p31;
		  line2_min <= matrix_p32;
		end 
		else begin
		  line2_mid <= matrix_p32;
		  line2_min <= matrix_p31;
		end	 
	 end
  end
end
//----------------------------------------------------------------------------------
// (max_max max_mid max_min) of ((line0 line1 line2) of max)
//----------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
	 max_max <= 8'b0;
     max_mid <= 8'b0;
     max_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((line0_max >= line1_max) && (line0_max >= line2_max)) begin
	   max_max <= line0_max;
		if(line1_max >= line2_max) begin
		  max_mid <= line1_max;
		  max_min <= line2_max;
		end 
		else begin
		  max_mid <= line2_max;
		  max_min <= line1_max;
		end
	 end
	 else if((line1_max > line0_max) && (line1_max >= line2_max)) begin
	   max_max <= line1_max;
		if(line0_max >= line2_max) begin
		  max_mid <= line0_max;
		  max_min <= line2_max;
		end 
		else begin
		  max_mid <= line2_max;
		  max_min <= line0_max;
		end
	 end
	 else if((line2_max > line0_max) && (line2_max > line1_max)) begin
	   max_max <= line2_max;
		if(line0_max >= line1_max) begin
		  max_mid <= line0_max;
		  max_min <= line1_max;
		end 
		else begin
		  max_mid <= line1_max;
		  max_min <= line0_max;
		end
	 end
  end
end
//------------------------------------------------------------------------------
// (mid_max mid_mid mid_min) of ((line0 line1 line2)of mid)
//------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
	 mid_max <= 8'b0;
     mid_mid <= 8'b0;
     mid_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((line0_mid >= line1_mid) && (line0_mid >= line2_mid)) begin
	   mid_max <= line0_mid;
		if(line1_mid >= line2_mid) begin
		  mid_mid <= line1_mid;
		  mid_min <= line2_mid;
		end 
		else begin
		  mid_mid <= line2_mid;
		  mid_min <= line1_mid;
		end
	 end
	 else if((line1_mid > line0_mid) && (line1_mid >= line2_mid)) begin
	   mid_mid <= line1_mid;
		if(line0_mid >= line2_mid) begin
		  mid_mid <= line0_mid;
		  mid_min <= line2_mid;
		end 
		else begin
		  mid_mid <= line2_mid;
		  mid_min <= line0_mid;
		end
	 end
	 else if((line2_mid > line0_mid) && (line2_mid > line1_mid)) begin
	   mid_max <= line2_mid;
		if(line0_mid >= line1_mid) begin
		  mid_mid <= line0_mid;
		  mid_min <= line1_mid;
		end 
		else begin
		  mid_mid <= line1_mid;
		  mid_min <= line0_mid;
		end
	 end
  end
end
//------------------------------------------------------------------------------
// (min_max min_mid min_min) of ((line0 line1 line2)of min)
//------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
	 min_max <= 8'b0;
     min_mid <= 8'b0;
     min_min <= 8'b0;
  end
  else if(data_in_en) begin
    if((line0_min >= line1_min) && (line0_min >= line2_min)) begin
	   min_max <= line0_min;
		if(line1_min >= line2_min) begin
		  min_mid <= line1_min;
		  min_min <= line2_min;
		end 
		else begin
		  min_mid <= line2_min;
		  min_min <= line1_min;
		end
	 end
	 else if((line1_min > line0_min) && (line1_min >= line2_min)) begin
	   min_max <= line1_min;
		if(line0_min >= line2_min) begin
		  min_mid <= line0_min;
		  min_min <= line2_min;
		end 
		else begin
		  min_mid <= line2_min;
		  min_min <= line0_min;
		end
	 end
	 else if((line2_min > line0_min) && (line2_min > line1_min)) begin
	   min_max <= line2_min;
		if(line0_min >= line1_min) begin
		  min_mid <= line0_min;
		  min_min <= line1_min;
		end 
		else begin
		  min_mid <= line1_min;
		  min_min <= line0_min;
		end
	 end
  end
end
//------------------------------------------------------------------------------
// middle
//------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    mid <= 8'b0;
  else if(data_in_en) begin
    if(((max_mid >= mid_mid) && (max_mid <= min_mid)) || ((max_mid >= min_mid) && (max_mid <= mid_mid)))
	   mid <= max_mid;
	 else if(((mid_mid >= max_mid) && (mid_mid <= min_mid)) || ((min_mid >= min_mid) && (mid_mid <= max_mid)))
	   mid <= mid_mid;
	 else if(((min_mid >= max_mid) && (min_mid <= mid_mid)) || ((min_mid >= mid_mid) && (mid_min <= max_mid)))
	   mid <= min_mid;
  end
end
//------------------------------------------------------------------------------
assign median=mid;
endmodule