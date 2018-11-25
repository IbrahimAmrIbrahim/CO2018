`timescale 1ns / 1ps

module PortA(DataBus,A,RW,Sel);
inout [7:0] A;
inout [7:0] DataBus;
input RW;
input Sel;

assign DataBus = (Sel)? ((RW)? 8'b zzzz_zzzz : A) : 8'b zzzz_zzzz;
assign A = (Sel)? ((RW)? DataBus : 8'b zzzz_zzzz) : A;

endmodule

module PortB(DataBus,B,RW,Sel);
inout [7:0] B;
inout [7:0] DataBus;
input RW;
input Sel;

assign DataBus = (Sel)? ((RW)? 8'b zzzz_zzzz : B) : 8'b zzzz_zzzz;
assign B = (Sel)? ((RW)? DataBus : 8'b zzzz_zzzz) : B;

endmodule

module PortUpperC(DataBus,CU,RW,Sel);
inout [3:0] CU;
inout [3:0] DataBus;
input RW;
input Sel;

assign DataBus = (Sel)? ((RW)? 4'b zzzz : CU) : 4'b zzzz;
assign CU = (Sel)? ((RW)? DataBus : 4'b zzzz) : CU;

endmodule

module PortLowerC(DataBus,LU,RW,Sel);
inout [3:0] LU;
inout [3:0] DataBus;
input RW;
input Sel;

assign DataBus = (Sel)? ((RW)? 4'b zzzz : LU) : 4'b zzzz;
assign LU = (Sel)? ((RW)? DataBus : 4'b zzzz) : LU;

endmodule

module DataBusBuffer(DataBus,D);
inout [7:0] D;
inout [7:0] DataBus;
endmodule

/*module ReadWriteControlLogic(A , RDbar , WRbar ,CSbar , Reset);
input [1:0] A;
input RDbar , WRbar ,CSbar, Reset;

always @(A , RDbar , WRbar ,CSbar , Reset)
begin
if(~CSbar)
begin
case(A)
00: Acontroler();
01: Acontroler();
10: Acontroler();
11: Acontroler();
end
end
endmodule


module Acontroler(Order,out_to_A_port,out_to_C_upper_port);
input order;
output out_to_A_port;
output out_to_C_upper_port;
endmodule



module Bcontroler(order,out_to_B_port,out_to_C_lower_port);
input order;
output out_to_B_port;
output out_to_C_lower_port;
endmodule


module PPI(D , PA , PB , PC , A , RDbar , WRbar , CSbar , Reset);
inout [7:0] D , PA , PB , PC;
input [1:0] A;
input RDbar , WRbar , CSbar , Reset;

assign PA = (~CSbar && Reset)? 8'b zzzz_zzzz : 8'b 1111_1111;


endmodule*/


module tb_PortA();
reg RW , Sel;
wire [7 : 0] A , DataBus;

assign A = (Sel)? ((RW)? 8'b zzzz_zzzz : 8'b 1111_1111): 8'b zzzz_zzzz  ;
assign DataBus = (RW)? 8'b 0101_0101 :  8'b zzzz_zzzz;

initial
begin
$monitor($time , "%b %b %b %b", Sel , RW , A , DataBus);
RW <= 0;
Sel <= 0;
#5
RW <= 0;
Sel <= 1;
#5
RW <= 1;
Sel <= 0;
#5
RW <= 1;
Sel <= 1;
#5
RW <= 1;
Sel <= 0;
#5
RW <= 0;
Sel <= 0;
end
PortA A1(DataBus,A,RW,Sel);

endmodule