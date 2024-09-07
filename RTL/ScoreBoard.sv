`ifndef ScoreBoard
`define ScoreBoard

`include"Transaction.sv"
`include"intf.sv"

class ScoreBoard;

mailbox #(Transaction) SBS_mb,SBM_mb;
Transaction T1 =  new();
logic [31:0] memSB [0:15];
event Gen_dn;
event Read_dn;
event send_data;


function new(mailbox ENV_SBSmb,mailbox ENV_SBMmb,event Gn_dn,event Rd_dn,event data_SBS);
	SBS_mb  = ENV_SBSmb;
	SBM_mb  = ENV_SBMmb;
	Gen_dn  = Gn_dn;
	Read_dn = Rd_dn;
	send_data = data_SBS;
endfunction

task read_input();
	forever begin
		Transaction T1;
		//$display("Data is transmitting now from sequencer to scoreboard [%0t]",$time);	
		SBS_mb.get(T1);
		memSB[T1.add] = T1.Data_in;
		//$display("add = %d , Data_in = %h",T1.add,memSB[T1.add]); 
		end
		
endtask


task Checking ();
	$display("Hi Im ScoreBoard and Im starting at time [%0t] ",$time);
	$display("---------------------------------------------------------------------------------------------------");
	forever begin
		Transaction T2;
		SBM_mb.get(T2);
		//T2.Disp("ScoreBoard"); 
		if (T2.Data_out == memSB[T2.add]) begin
			$display("Expected Data is 0x%h and the Actual data is 0x%h",memSB[T2.add],T2.Data_out);
			$display("Success");
			$display("---------------------------------------------------------------------------------------------------");
		end else $display("Faild at time %0t",$time);
		$display("Data Recived !");
	end
		//$display("ScoreBoard has Endeed his Work at time [%0t]",$time);
endtask 


endclass

`endif