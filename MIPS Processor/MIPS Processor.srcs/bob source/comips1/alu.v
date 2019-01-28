`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:06 01/28/2019 
// Design Name: 
// Module Name:    alu 
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
module alu(in1,in2,aluctr,out,zero);
input [31:0] in1;
input [31:0] in2;
input [3:0] aluctr;
output [31:0] out;
reg [31:0]tout;
output zero;
assign out = tout;  

assign zero = (out==32'h00000000)?1:0;
always@(*)
begin
case(aluctr)
	4'b0000:tout<=in1&in2;
	4'b0001:tout<=in1|in2;
	4'b0010:tout<=in1+in2;
	4'b0110:tout<=in1-in2;
	4'b0111:tout<=(in1<in2)?32'hffffffff:32'h00000000;
endcase
end
endmodule

module tb_alu();
reg [31:0] in1,in2;
reg [3:0]aluctr;
wire [31:0] out;
wire zero;
alu alutest(in1,in2,aluctr,out,zero);
initial 
begin
$monitor(" %d // %d // %b // %b // %b",in1,in2,aluctr,out,zero);
#5
in1=32'd25;
in2=32'd50;
aluctr=4'b0000;
#5
in1=32'd25;
in2=32'd50;
aluctr=4'b0001;
#5
in1=32'd25;
in2=32'd50;
aluctr=4'b0010;
#5
in1=32'd50;
in2=32'd25;
aluctr=4'b0111;
#5
in1=32'd25;
in2=32'd50;
aluctr=4'b0111;

#5
in1=32'd25;
in2=32'd50;
aluctr=4'b0110;
#5
in1=32'd75;
in2=32'd50;
aluctr=4'b0110;

end
endmodule
