`ifndef Transaction
`define Transaction

class Transaction;

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
	$display("[%s]  add = %d , Data_in = %h",str,add,Data_in);	
	end
endfunction
endclass

`endif



