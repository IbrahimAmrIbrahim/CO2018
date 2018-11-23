`timescale 1ns / 1ps

module ReadWriteControlLogic(A , RDbar , WRbar , Reset,CSbar);
input A[1:0];
input RDbar ;
input WRbar ;   
input Reset ;
input CSbar;

endmodule


module Acontroler(order,out_to_A_port,out_to_C_upper_port);
input order;
output out_to_A_port;
output out_to_C_upper_port;
endmodule



module Bcontroler(order,out_to_B_port,out_to_C_lower_port);
input order;
output out_to_B_port;
output out_to_C_lower_port;
endmodule


module


module PPI(D , PA , PB , PC , A , RDbar , WRbar , CSbar , Reset);
inout [7:0] D , PA , PB , PC;
input [1:0] A;
input RDbar , WRbar , CSbar , Reset;

assign PA = (~CSbar && Reset)? 8'b zzzz_zzzz : 8'b 1111_1111;


endmodule
