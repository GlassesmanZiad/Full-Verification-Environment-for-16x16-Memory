package pack1;

	/* UVM package Importation and Macros */
	import uvm_pkg::*;
  	`include "uvm_macros.svh"

  	/* Sequence Item Class */
  	class my_sequence_item extends uvm_sequence_item;
  		`uvm_object_utils( my_sequence_item)
  		parameter Depth = 4;
		parameter Data_width = 32;
		
		rand  bit rst;
		rand  bit EN;
		rand  bit wr_en;
		rand  bit rd_en;
		randc bit [   Depth   - 1 : 0] add;
		randc bit [Data_width - 1 : 0] Data_in;
		bit valid_out;
		bit [Data_width - 1 : 0] Data_out;
		
		constraint C1 {wr_en dist {0:=50,1:=30};}
		constraint C2 {{rd_en != wr_en};}
		constraint C3 {EN    dist {1:=10,1:=90};}
		constraint C4 {{rst == 1};}
		constraint C5 {{wr_en == 0};}
		constraint C6 {{rd_en == 0};}
		constraint C7 {{Data_in == 0};}

		function void Disp (string str ="");
			if (str == "Driver Writing") begin
				$display("T=[%0t] [%s] add = %d , Data_in = %h , wr_en = %d , rd_en = %d " , $time , str,add,Data_in,wr_en,rd_en);
				$display("---------------------------------------------------------------------------------------------------");
			end else if (str == "Driver Reading") begin
				$display("T=[%0t] [%s] EN = %d , add = %d " , $time , str,EN,add);
				$display("---------------------------------------------------------------------------------------------------");
			end else if (str == "Monitor") begin
				$display("T=[%0t] [%s] EN = %d , add = %d , Data_out = %h , valid_out = %d" , $time , str,EN,add,Data_out,valid_out);
				$display("---------------------------------------------------------------------------------------------------");
			end else if (str == "ScoreBoard")begin 
				$display("[%s] The value in add = %d is [0x%h]",str,add,Data_in);	
			end
		endfunction

  		function new (string name = "my_sequence_item");
			super.new(name);
		endfunction

  	endclass
	
  	/* Sequence1 Class */
	class my_sequence_wr extends uvm_sequence ;
		`uvm_object_utils(my_sequence_wr)
		my_sequence_item seq_item;

		function new (string name = "my_sequence");
			super.new(name);
		endfunction
		virtual task pre_body();
			seq_item = my_sequence_item ::type_id::create("seq_item");
		endtask : pre_body

		virtual task body();
			repeat(16) begin
				start_item(seq_item);
				seq_item.C6.constraint_mode(0);
				seq_item.C7.constraint_mode(0);
				void'(seq_item.randomize());
				finish_item(seq_item);
			end
		$display("Data Sent at time [%0t] !",$time);
		endtask : body
  	endclass


  	/* Sequence2 Class */
	class my_sequence_rd extends uvm_sequence ;
		`uvm_object_utils(my_sequence_rd)
		my_sequence_item seq_item;

		function new (string name = "my_sequence");
			super.new(name);
		endfunction
		virtual task pre_body();
			seq_item = my_sequence_item ::type_id::create("seq_item");
		endtask : pre_body

		virtual task body();
			repeat(16) begin
				start_item(seq_item);
				seq_item.C5.constraint_mode(0);
				void'(seq_item.randomize());
				finish_item(seq_item);
			end
		$display("Data Received at time [%0t] !",$time);
		endtask : body
  	endclass  	

  	/* Sequencer Class */
  	class my_sequencer  extends uvm_sequencer #(my_sequence_item) ;
  		`uvm_component_utils( my_sequencer)
  		function new (string name = "my_sequencer", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 		endtask 
  	endclass

  	/* Driver Class */
	class my_driver  extends uvm_driver #(my_sequence_item) ;
		`uvm_component_utils( my_driver)
		virtual interface intf driver_vif;
		my_sequence_item seq_item;
		function new (string name = "my_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			seq_item  = my_sequence_item ::type_id::create("seq_item");
 			if (!uvm_config_db #(virtual intf) :: get(this,"","driver_vif" , driver_vif))
  				`uvm_fatal(get_full_name(),"Error!") 
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase);
 			$display("Hi Im driver sneding data and Im starting at time [%0t] ",$time);
			$display("*******************************************************");
			forever begin
				my_sequence_item seq_item;
				seq_item_port.get_next_item(seq_item);
				@(negedge driver_vif.clk);
				$display("Drivr is waiting sending data for transaction at time [%0t]",$time);	
				if(seq_item.rd_en == 0 ) seq_item.Disp("Driver Reading");
				else seq_item.Disp("Driver Writing");
				driver_vif.intf_rst         <= seq_item.rst;
				driver_vif.intf_EN  	    <= seq_item.EN;
				driver_vif.intf_wr_en    	<= seq_item.wr_en;
				driver_vif.intf_rd_en    	<= seq_item.rd_en;
				driver_vif.intf_add      	<= seq_item.add; 
				driver_vif.intf_Data_in  	<= seq_item.Data_in;
				//$display("%h  [%0t]",driver_vif.intf_Data_out,$time); 
				#1 seq_item_port.item_done();		
			end
 		endtask
  	endclass

  	/* Monitor Class */
	class my_monitor extends uvm_monitor;
		`uvm_component_utils( my_monitor)
		virtual interface intf monitor_vif;
		my_sequence_item seq_item_mon;
		uvm_analysis_port#(my_sequence_item)  analysis_port;
		function new (string name = "my_monitor", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			if (!uvm_config_db #(virtual intf) :: get(this,"","monitor_vif" , monitor_vif))
  				`uvm_fatal(get_full_name(),"Error!")
  			seq_item_mon  = my_sequence_item ::type_id::create("seq_item_mon");
  			analysis_port = new("analysis_port",this);
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 			forever begin
 				@(negedge monitor_vif.clk);
				seq_item_mon.rst         =  monitor_vif.intf_rst;
				seq_item_mon.EN          =  monitor_vif.intf_EN;
				seq_item_mon.wr_en       =  monitor_vif.intf_wr_en;
				seq_item_mon.rd_en       =  monitor_vif.intf_rd_en;
				seq_item_mon.add         =  monitor_vif.intf_add;
				seq_item_mon.Data_in     =  monitor_vif.intf_Data_in;
				seq_item_mon.Data_out    =  monitor_vif.intf_Data_out;
				seq_item_mon.valid_out   =  monitor_vif.intf_valid_out;
				analysis_port.write(seq_item_mon);
			end
 		endtask
  	endclass

  	/* ScoreBoard Class */
	class my_scoreboard extends uvm_scoreboard ;
		`uvm_component_utils( my_scoreboard)
		my_sequence_item seq_item_SB_EXPECTED;
		my_sequence_item seq_item_SB_ACTUAL;
		uvm_analysis_imp#(my_sequence_item,my_scoreboard) analysis_export;
		logic [31:0] acc [0:15];

		function new (string name = "my_scoreboard", uvm_component parent = null);
			super.new(name, parent);
		endfunction
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			seq_item_SB_EXPECTED  = my_sequence_item ::type_id::create("seq_item_SB_EXPECTED");
 			seq_item_SB_ACTUAL    = my_sequence_item ::type_id::create("seq_item_SB_ACTUAL");
 			analysis_export       = new("analysis_export",this);
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 		endtask

		function void write ( my_sequence_item t ) ;
			if (t.wr_en == 0) begin
				acc[t.add] = t.Data_in;
				//$display("[%0t]add = %d , data = %h , acc[%0d] = %h ",$time,t.add,t.Data_in,t.add,acc[t.add]);
			end else begin
				//$displayh("%p",acc);
				$display("Data Recived !");
				//$display("data recived is %h from add %d and data should be %h in add %d" , t.Data_out ,t.add,acc[t.add],t.add);
				if (t.Data_out == acc[t.add]) begin
					$display("[Comparasion] The value in memory in add = %d is [0x%h] and Expected Value in add = [%d] is [0x%h]",t.add,acc[t.add],t.add,t.Data_out);
					$display("*********************************** Test Passed ***********************************");
				end else begin 
					$display("*********************************** Test Failed ***********************************");
					$display("The value in memory in add = %d is [0x%h] and Expected Value in add = [%d] is [0x%h]",t.add,t.Data_out,t.add,acc[t.add]);
				end
			end
 		endfunction

  	endclass

  	/* Subscriber Class */
  	class my_subscriber extends uvm_subscriber #(my_sequence_item);
  		`uvm_component_utils( my_subscriber)
  		function new (string name = "my_subscriber", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void write ( my_sequence_item t ) ; 
 		endfunction
	
 		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;

 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ; 
 		endtask
  	endclass

  	/* Agent Class */
	class my_agent extends uvm_agent ;
		`uvm_component_utils( my_agent)
		my_sequencer my_sequencer1 ;
		my_driver    my_driver1  ; 
		my_monitor   my_monitor1  ;
		uvm_analysis_port#(my_sequence_item) analysis_port;

		virtual interface intf agent_vif;

		function new (string name = "my_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			my_sequencer1  = my_sequencer :: type_id :: create ("my_sequencer1",this ) ;
  			my_driver1 	   = my_driver    :: type_id :: create ("my_driver1",this ) ;
  			my_monitor1    = my_monitor   :: type_id :: create ("my_monitor1",this ) ;
  			analysis_port = new("analysis_port",this);
 			if (!uvm_config_db #(virtual intf) :: get(this,"","agent_vif" , agent_vif))
  			`uvm_fatal(get_full_name(),"Error!")

  			uvm_config_db #(virtual intf) :: set(this,"my_driver1","driver_vif" , agent_vif) ;
  			uvm_config_db #(virtual intf) :: set(this,"my_monitor1","monitor_vif", agent_vif) ;  
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 			my_driver1.seq_item_port.connect(my_sequencer1.seq_item_export);
 			my_monitor1.analysis_port.connect(analysis_port);
 		endfunction
 		                        
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 		endtask
  	endclass

  	/* Environment Class */
	class my_env extends uvm_env ;
		`uvm_component_utils( my_env)
 		my_agent      my_agent1 ; 
 		my_scoreboard my_scoreboard1 ; 
 		my_subscriber my_subscriber1 ;
 		virtual intf env_vif;

		function new (string name = "my_env", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			my_agent1      = my_agent      :: type_id :: create ("my_agent1",this ) ;
 			my_scoreboard1 = my_scoreboard :: type_id :: create ("my_scoreboard1",this ) ;
 			my_subscriber1 = my_subscriber :: type_id :: create ("my_subscriber1",this ) ;
 			if (!uvm_config_db #(virtual intf)::get(this,"","env_vif",env_vif))
  			`uvm_fatal(get_full_name(),"Error!")

  			uvm_config_db #(virtual intf) :: set(this,"my_agent1","agent_vif",env_vif) ; 
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 			my_agent1.analysis_port.connect(my_scoreboard1.analysis_export);
 		endfunction
 		
 		task run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 		endtask
 	endclass  

  	/* Test Class */
	class my_test extends uvm_test ;
		`uvm_component_utils(my_test)
		my_sequence_wr my_sequence1 ;
		my_sequence_rd my_sequence2 ;
 		my_env my_env1 ;
 		virtual intf test_vif;
		function new (string name = "my_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction
	
		function void build_phase(uvm_phase phase ) ; 
 			super.build_phase(phase) ;
 			my_env1      = my_env      :: type_id :: create ("my_env1",this ) ;
  			my_sequence1 = my_sequence_wr :: type_id :: create ("my_sequence1" ) ;
  			my_sequence2 = my_sequence_rd :: type_id :: create ("my_sequence2" ) ; 
  			if (!uvm_config_db #(virtual intf)::get(this,"","test_vif",test_vif))
  			`uvm_fatal(get_full_name(),"Error!")

 		    uvm_config_db #(virtual intf)::set(this ,"my_env1","env_vif",test_vif) ;
 		endfunction
 		
 		function void connect_phase(uvm_phase phase ) ; 
 			super.connect_phase(phase) ;
 		endfunction
 		
 		task  run_phase(uvm_phase phase ) ; 
 			super.run_phase(phase) ;
 			phase.raise_objection(this,"Sequence Start");
 			my_sequence1.start(my_env1.my_agent1.my_sequencer1);
 			my_sequence2.start(my_env1.my_agent1.my_sequencer1);
 			phase.drop_objection(this,"Sequence Finished");	
 		endtask 
  	endclass  		  	

endpackage