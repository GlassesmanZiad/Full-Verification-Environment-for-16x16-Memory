`include"Env.sv"
`include"intf.sv"

module top ();

	parameter Depth = 4;
	parameter Data_width = 32;
	logic clk;

	Env MyFirstEnv;

	intf intf1(clk);
	virtual intf vif;

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


always begin 
	#5 clk = ~clk;
end

initial begin 
	vif = intf1;
	clk = 0;
	MyFirstEnv = new(vif);

	  MyFirstEnv.reset_sys();

	 #5 MyFirstEnv.initialize_sys();

end

endmodule