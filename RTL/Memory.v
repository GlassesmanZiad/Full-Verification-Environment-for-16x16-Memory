/******************************************************
 * Project Name: Memory.v
 * By: Ziad Ahmed Mamdouh
 * Date: 1 / 7 / 2024
 /****************************************************/ 

module Memory #(parameter Depth = 4,
			  parameter Data_width = 32)
			 
			 ( input  wire clk,
			   input  wire rst,
			   input  wire EN,
			   input  wire wr_en,
			   input  wire rd_en,
			   input  wire [  Depth    - 1 : 0] add,
			   input  wire [Data_width - 1 : 0] Data_in,
			   output reg  valid_out,
			   output reg  [Data_width - 1 : 0] Data_out
			 );

/******* Initializing The Memory Layers which consist of 16 Places of width 32-bits *******/
reg [Data_width-1:0] mem [0:15];
reg [15:0] arr_add [0:15];

/******* Internal Signals *******/								 
integer i = 0; 													
integer counter = 0;

/******* Triggiering *******/
always @(posedge clk or negedge rst) begin
/******* Reset The Memory *******/
	if (~rst) begin
		for (i = 0; i < 16; i = i + 1)
	      begin
	        mem[i]  <= 32'hXXXXXXXX;
	        arr_add[i] <= 16'h0000;
	      end
/* This counter is used to determine if we already wrote a valid data in the memory before reading from it
   If the counter is zero this means that there are no valid data written to the memory so reading operation isnt valid */	      
	      counter <= 0; 
	end else if (EN)begin
		if (~wr_en && rd_en)begin
			mem[add]     <= Data_in;
			arr_add[add] <= add;
			/******* Check that the counter reaches 15 so that it means its full but we need to reset the counter 
			 * to avoid the infinity counting or reaching the edge of the int boundaries *******/
			if (counter == 15) begin 
				counter <= 1;
			end else begin
			counter <= counter + 1;
			end
		end else if (~rd_en && wr_en)begin

			/******* Before reading from the memory we check if the data is valid or not by checking 
			 * the state of the data and the counter *******/
			if (counter == 0 || arr_add[add] != add) begin
			valid_out <= 0;
			Data_out <= 32'hXXXXXXXX;	
			end else begin
			Data_out  <= mem[add];
			valid_out <= 1;	
			end 
			end else begin 
			/******* if the user want to read and write in the same time the data valid output will be zero and data out = 8'hZZ *******/	
			valid_out <= 0;
			Data_out <= 32'hXXXXXXXX;
			end
           /******* if the EN port is zero so that the memory is off and the data valid output will be zero and data out = 8'hZZ *******/
	end else begin 
		Data_out <= 32'hXXXXXXXX;
		valid_out <= 0;
	end
end
endmodule