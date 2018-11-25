`timescale 1ns / 1ps

module PortA(DataBus,A,RW,Sel);
inout [7:0] A;
inout [7:0] DataBus;
input RW;
input Sel;

/*
Read  :RW = 0 , A Input , DataBus Output
Write :RW = 1 , A Output , DataBus Input
*/

assign DataBus = (Sel)? ((RW)? 8'b zzzz_zzzz : A) : 8'b zzzz_zzzz;
assign A = (Sel)? ((RW)? DataBus : 8'b zzzz_zzzz) : A;

endmodule

module PortB(DataBus,B,RW,Sel);
inout [7:0] B;
inout [7:0] DataBus;
input RW;
input Sel;

/*
Read  :RW = 0 , B Input , DataBus Output
Write :RW = 1 , B Output , DataBus Input
*/

assign DataBus = (Sel)? ((RW)? 8'b zzzz_zzzz :  B) : 8'b zzzz_zzzz;
assign B = (Sel)? ((RW)? DataBus : 8'b zzzz_zzzz) : B;

endmodule

module PortUpperC(DataBus,CU,RW,Sel);
inout [3:0] CU;
inout [3:0] DataBus;
input RW;
input Sel;

/*
Read  :RW = 0 , UC Input , DataBus Output
Write :RW = 1 , UC Output , DataBus Input
*/

assign DataBus = (Sel)? ((RW)? 4'b zzzz :  CU) : 4'b zzzz;
assign CU = (Sel)? ((RW)? DataBus :  4'b zzzz) : CU;

endmodule

module PortLowerC(DataBus,CL,RW,Sel);
inout [3:0] CL;
inout [3:0] DataBus;
input RW;
input Sel;

/*
Read  :RW = 0 , LC Input , DataBus Output
Write :RW = 1 , LC Output , DataBus Input
*/

assign DataBus = (Sel)? ((RW)? 4'b zzzz : CL) : 4'b zzzz;
assign CL = (Sel)? ((RW)? DataBus : 4'b zzzz) : CL;

endmodule

module DataBusBuffer(DataBus,D,RW);
inout [7:0] D;
inout [7:0] DataBus;
input RW;

/*
Read  :RW = 0 , D Output , DataBus Input
Write :RW = 1 , D Input , DataBus Output
*/

assign DataBus = (RW)? D : 8'b zzzz_ZZZZ;
assign D = (RW)? 8'b zzzz_zzzz : DataBus;

endmodule

module ReadWriteControlLogic();

endmodule


module GroupAcontroler(PortA_ctrl , PortUC_ctrl , ctrl , DataBus);
output PortA_ctrl , PortUC_ctrl;
input [7:0] DataBus;
input ctrl;


endmodule



module GroupBcontroler();

endmodule


module PPI();

endmodule


module tb_PortA();
reg RW , Sel;
wire [7 : 0] A , DataBus;

assign A = (Sel)? ((RW)? 8'b zzzz_zzzz : 8'b 1111_1111): 8'b zzzz_zzzz;
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
#5
RW <= 0;
Sel <= 1;
#5
RW <= 0;
Sel <= 0;
end
PortA A1(DataBus,A,RW,Sel);

endmodule