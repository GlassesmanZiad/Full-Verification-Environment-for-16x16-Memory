import uvm_pkg::*;
import pack1::*;
`include"intf.sv"

module Top();

logic clk;
intf intf1(clk);

always begin
	#5 clk = ~clk;
end

Memory Memory1 (
				.clk(clk),
				.rst(intf1.intf_rst),
				.EN(intf1.intf_EN),
				.wr_en(intf1.intf_wr_en),
				.rd_en(intf1.intf_rd_en),
				.add(intf1.intf_add),
				.Data_in(intf1.intf_Data_in),
				.valid_out(intf1.intf_valid_out),
				.Data_out(intf1.intf_Data_out)	
				);


initial begin
	clk = 0;
	uvm_config_db #(virtual intf) :: set(null,"uvm_test_top","test_vif",intf1);
	run_test("my_test");
end
endmodule