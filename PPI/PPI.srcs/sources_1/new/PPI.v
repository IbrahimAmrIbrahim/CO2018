`timescale 1ns / 1ps
module PortA(DataBus,A,Sel,RD,RW,Reset,CS);
inout [7:0] A;
inout [7:0] DataBus;
input [1:0] Sel;
input RD,RW,Reset,CS ;

/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

/*assign DataBus = (Sel == 2'b00)? ((InOut[0])? 8'bzzzz_zzzz : A) : 8'bzzzz_zzzz;
assign A = (InOut[0])? ((Sel == 2'b00)? DataBus : A) : 8'bzzzz_zzzz;*/

endmodule

module PortB(DataBus,B,InOut,Sel);
inout [7:0] B;
inout [7:0] DataBus;
input [1:0] InOut;
input [1:0] Sel;

/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

assign DataBus = (Sel == 2'b01)? ((InOut[1])? 8'bzzzz_zzzz : B) : 8'bzzzz_zzzz;
assign B = (InOut[1])? ((Sel == 2'b01)? DataBus : B) : 8'bzzzz_zzzz;

endmodule

module PortC(DataBus,C,InOut,Sel);
inout [7:0] C;
inout [7:0] DataBus;
input [1:0] InOut;
input [1:0] Sel;

/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

assign DataBus = (Sel == 2'b01)? ((InOut[1])? 8'bzzzz_zzzz : C) : 8'bzzzz_zzzz;
assign C = (InOut[1])? ((Sel == 2'b01)? DataBus : C) : 8'bzzzz_zzzz;

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