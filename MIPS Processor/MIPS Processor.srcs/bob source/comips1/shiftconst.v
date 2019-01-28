`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:45:21 01/28/2019 
// Design Name: 
// Module Name:    shiftconst 
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
module shiftconst(in1,out);
input [31:0] in1;
output [31:0] out;
assign out = in1*4;

endmodule

module tb_shift();
reg [31:0]in1;
wire [31:0]out;
shiftconst shiff(in1,out);
initial 
begin
$monitor("%d // %d",in1,out);
#5
in1= 32'd25;
#5
in1=32'd100;
end
endmodule
