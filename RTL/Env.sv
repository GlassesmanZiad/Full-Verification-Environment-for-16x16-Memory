`ifndef Env
`define Env


`include "Sequencer.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "ScoreBoard.sv"
`include "intf.sv"

class Env;

Driver     D1;
Monitor    M1;
Sequencer  S1;
ScoreBoard SB1;
mailbox #(Transaction) ENV_mb,ENV2_mb,ENV_SBMmb,ENV_SBSmb;
event Gn_dn;
event Rd_dn;
event data_SBS;


function new(virtual intf vif);
	ENV_mb 	 = new();
	ENV2_mb  = new();
	ENV_SBMmb = new();
	ENV_SBSmb = new();
	D1 	     = new(vif,ENV_mb,ENV2_mb,Gn_dn,Rd_dn);
	M1 	     = new(vif,ENV_SBMmb,Rd_dn);
	S1 	     = new(ENV_mb,ENV2_mb,ENV_SBSmb,Gn_dn,Rd_dn,data_SBS);
	SB1      = new(ENV_SBSmb,ENV_SBMmb,Gn_dn,Rd_dn,data_SBS);
endfunction

task reset_sys();
	D1.mem_reset();
endtask

task initialize_sys(); 

	fork
	S1.generate_data();
	SB1.read_input();
	D1.send_data();
	join_any

	#100;

	fork
	S1.read_data();
	D1.get_data();

	M1.get_output();
	SB1.Checking ();
	join_any


endtask

endclass

`endif