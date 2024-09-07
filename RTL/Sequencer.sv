`ifndef Sequencer
`define Sequencer

`include"Transaction.sv"

class Sequencer ;

mailbox #(Transaction) sq_mb,sq2_mb,SBS_mb;
event Gen_dn;
event Read_dn;
event send_data;
Transaction write_T = new();
Transaction read_T = new();

function new(mailbox ENV_mb,mailbox ENV2_mb,mailbox ENV_SBSmb,event Gn_dn,event Rd_dn,event data_SBS);
	sq_mb   = ENV_mb;
	sq2_mb  = ENV2_mb;
	SBS_mb  = ENV_SBSmb;
	Gen_dn 	= Gn_dn;
	Read_dn = Rd_dn;
	send_data = data_SBS;
endfunction

task generate_data();
	repeat(16) begin
		write_T.C6.constraint_mode(0);
		void'(write_T.randomize());
		sq_mb.put(write_T);
		SBS_mb.put(write_T);
		@(Gen_dn);
	end
	//$display("Driver Won't have More Transactions");
	//$display("Sequencer has Endeed his Work at time [%0t]",$time);
	$display("Data Sent !");
endtask

task read_data();
	repeat(16) begin
		read_T.C5.constraint_mode(0);
		void'(read_T.randomize());
		sq2_mb.put(read_T);
		@(Read_dn);
	end
	//$display("Driver Won't have More Transactions");
	//$display("Sequencer has Endeed his Work at time [%0t]",$time);
endtask

endclass

`endif