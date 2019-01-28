`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:33:22 01/28/2019 
// Design Name: 
// Module Name:    mux2x1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux2x1(in1, in2, sel, out);
input [31:0] in1;
input [31:0] in2;
input sel;
output [31:0] out;
assign out = (sel == 0)? in1:in2;

endmodule

module tb_mux();
reg [31:0]in1;
reg [31:0]in2;
reg sel;
wire [31:0]out;
mux2x1 tmux(in1, in2 , sel, out);
initial
begin
$monitor("%h // %h // %b // %h", in1,in2,sel,out);
#5
in1=32'h11111111;
#5
in1=32'h00000000;
in2=32'hffffffff;
sel=0;
#5
in1=32'h00000000;
in2=32'hffffffff;
sel=1;

end

endmodule 


