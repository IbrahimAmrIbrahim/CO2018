`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:33 01/28/2019 
// Design Name: 
// Module Name:    shiftvar 
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
module shiftvar(in1,out);
input [25:0] in1;
output [27:0] out ;
assign out = in1*4;
endmodule

module tb_shiftv();
reg [25:0] in1;
wire [27:0] out;
shiftvar shift(in1,out);
initial 
begin
$monitor("%d // %d", in1,out);
#5
in1 = 26'd25;
#5
in1 = 26'd50;
end
endmodule




