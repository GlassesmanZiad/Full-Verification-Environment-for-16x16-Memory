`ifndef Driver
`define Driver

`include"Transaction.sv"
`include"intf.sv"

class Driver ;


mailbox #(Transaction) dr_mb,dr2_mb;
virtual intf vif_dr;
event Gen_dn;
event Read_dn;

function new(virtual intf vif,mailbox ENV_mb,mailbox ENV2_mb,event Gn_dn,event Rd_dn);
	vif_dr  = vif;
	dr_mb   = ENV_mb;
	dr2_mb  = ENV2_mb;
	Gen_dn  = Gn_dn; 
	Read_dn = Rd_dn;
endfunction

task mem_reset();
	vif_dr.intf_rst = 0'b0;
endtask



task send_data ();
		//$display("Hi Im driver sneding data and Im starting at time [%0t] ",$time);
		@(vif_dr.cb);
			forever begin
				Transaction T1;
				$display("Drivr is waiting sending data for transaction at time [%0t]",$time);	
				dr_mb.get(T1);
				T1.Disp("Driver Writing"); 
				vif_dr.intf_rst      <= T1.rst;
				vif_dr.intf_EN  	 <= T1.EN;
				vif_dr.intf_wr_en    <= T1.wr_en;
				vif_dr.intf_rd_en    <= T1.rd_en;
				vif_dr.intf_add      <= T1.add;
				vif_dr.intf_Data_in  <= T1.Data_in; 
				@(vif_dr.cb);
				->Gen_dn;
			end
endtask

task get_data ();
		//$display("Hi Im driver getting data and Im starting at time [%0t] ",$time);
		@(vif_dr.cb);
			forever begin
				Transaction T1;
				//$display("Drivr is waiting getting data for transaction at time [%0t]",$time);	
				dr2_mb.get(T1);
				//T1.Disp("Driver Reading");
				vif_dr.intf_rst      <= T1.rst;
				vif_dr.intf_EN  	 <= T1.EN;
				vif_dr.intf_wr_en    <= T1.wr_en;
				vif_dr.intf_rd_en    <= T1.rd_en;
				vif_dr.intf_add      <= T1.add;
				vif_dr.intf_Data_in  <= T1.Data_in; 
				@(vif_dr.cb);
				->Read_dn;
			end
endtask

endclass

`endif