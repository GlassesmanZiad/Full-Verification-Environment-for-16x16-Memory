`ifndef Monitor
`define Monitor

`include"Transaction.sv"
`include"intf.sv"

class Monitor;

virtual intf vif_mo;
mailbox #(Transaction) Mr_mb;
event MrSc_dn;
Transaction T1 =  new();
event Read_dn;

function new(virtual intf vif,mailbox ENV_SBMmb,event Rd_dn);
	vif_mo = vif;
	Mr_mb = ENV_SBMmb;
	Read_dn = Rd_dn;
endfunction

task get_output ();
	//$display("Hi Im Monitor and Im starting at time [%0t] ",$time);
	forever begin
		@(Read_dn);
		T1.rst         =  vif_mo.intf_rst;
		T1.EN          =  vif_mo.intf_EN;
		T1.wr_en       =  vif_mo.intf_wr_en;
		T1.rd_en       =  vif_mo.intf_rd_en;
		T1.add         =  vif_mo.intf_add;
		T1.Data_in     =  vif_mo.intf_Data_in;
		T1.Data_out    =  vif_mo.intf_Data_out;
		T1.valid_out   =  vif_mo.intf_valid_out;
		//T1.Disp("Monitor");
		Mr_mb.put(T1);
	end
		//$display("Monitor has Endeed his Work at time [%0t]",$time);
endtask 


endclass

`endif