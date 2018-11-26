`timescale 1ns / 1ps
module PortA(DataBus,A,Sel,RD_bar,RW_bar,Reset,CS_bar);
inout [7:0] A;
inout [7:0] DataBus;
input [1:0] Sel;
input RD_bar,RW_bar,Reset,CS_bar ;

/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

/*assign DataBus = (Sel == 2'b00)? ((InOut[0])? 8'bzzzz_zzzz : A) : 8'bzzzz_zzzz;
assign A = (InOut[0])? ((Sel == 2'b00)? DataBus : A) : 8'bzzzz_zzzz;*/

endmodule

module PortB(DataBus,B,Sel,RD_bar,RW_bar,Reset,CS_bar);
inout [7:0] B;
inout [7:0] DataBus;
input [1:0] Sel;
input RD_bar,RW_bar,Reset,CS_bar ;

/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

/*assign DataBus = (Sel == 2'b01)? ((InOut[1])? 8'bzzzz_zzzz : B) : 8'bzzzz_zzzz;
assign B = (InOut[1])? ((Sel == 2'b01)? DataBus : B) : 8'bzzzz_zzzz;*/

endmodule

module PortC(DataBus,C,Sel,RD_bar,RW_bar,Reset,CS_bar);
inout [7:0] C;
inout [7:0] DataBus;
input [1:0] Sel;
input RD_bar,RW_bar,Reset,CS_bar ;
/*
InOut = 0 --> Input
InOut = 1 --> Output
*/

/*assign DataBus = (Sel == 2'b01)? ((InOut[1])? 8'bzzzz_zzzz : C) : 8'bzzzz_zzzz;
assign C = (InOut[1])? ((Sel == 2'b01)? DataBus : C) : 8'bzzzz_zzzz;*/

endmodule

module DataBusBuffer(DataBus,D,RD_bar,RW_bar,Reset,CS_bar);
inout [7:0] D;
inout [7:0] DataBus;
input RD_bar,RW_bar,Reset,CS_bar ;
reg [1:0] ctrl;
/*
Read  :ctrl = 0 , Input
Write :ctrl = 1 , Output
*/

assign DataBus = (ctrl[0])? D : 8'bzzzz_zzzz;
assign D = (ctrl[1])? DataBus : 8'bzzzz_zzzz;

always @(RD_bar,RW_bar,Reset,CS_bar)
begin
    if(~Reset && ~CS_bar)
    begin
        if(~RD_bar)
        begin
            ctrl[0] <= 0;
            ctrl[1] <= 1;
        end
        else if(~RW_bar)
        begin
            ctrl[0] <= 1; 
            ctrl[1] <= 0;
        end
        else
        begin
            ctrl[0] <= 0;
            ctrl[1] <= 0;
        end
    end
    else
    begin 
        ctrl[0] <= 0;
        ctrl[1] <= 0;
    end
end
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

module DataBusBuffer_tb();
reg RD , RW , CS , Reset;
wire [7 : 0] D , DataBus;

assign D = (~RD)? 8'b zzzz_zzzz : 8'b 1111_1111;
assign DataBus = (~RD)? 8'b 0101_0101 :  8'b zzzz_zzzz;

initial
begin
$monitor($time , "CS=%b RD=%b WR=%b Reset=%b D=%b DataBus=%b", CS , RD , RW , Reset , D , DataBus);
$display("Reset");
RW <= 1;
RD <= 1;
Reset <= 1;
CS <= 1;
#5
$display("Nothing");
RW <= 1;
RD <= 1;
Reset <= 0;
CS <= 1;
#5
$display("chip select");
RW <= 1;
RD <= 1;
Reset <= 0;
CS <= 0;
#5
$display("write");
RW <= 0;
RD <= 1;
Reset <= 0;
CS <= 0;
#5
$display("Read");
RW <= 1;
RD <= 0;
Reset <= 0;
CS <= 0;
#5
$display("nothing");
RW <= 1;
RD <= 1;
Reset <= 0;
CS <= 1;
#5
$display("chip unselect");
RW <= 1;
RD <= 1;
Reset <= 0;
CS <= 0;
end

DataBusBuffer DBB(DataBus,D,RD,RW,Reset,CS);

endmodule