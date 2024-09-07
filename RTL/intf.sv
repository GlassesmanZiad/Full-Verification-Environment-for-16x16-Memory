interface intf(input logic clk);

    parameter Depth = 4;
	parameter Data_width = 32;

	logic intf_rst;
	logic intf_EN;
	logic intf_wr_en;
	logic intf_rd_en;
	logic [  Depth    - 1 : 0] intf_add;
	logic [Data_width - 1 : 0] intf_Data_in;
	logic intf_valid_out;
	logic [Data_width - 1 : 0] intf_Data_out;


	/*clocking cb @(negedge clk);
		//default input #1 output #2;
		input intf_valid_out;
		input intf_Data_out;

		output intf_EN,intf_wr_en,intf_rd_en;
		output intf_add;
		output intf_Data_in;
	endclocking*/

endinterface
