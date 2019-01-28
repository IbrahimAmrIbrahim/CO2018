`timescale 1ns / 1ps

module InstructionMemory();

endmodule


module DataMemory();

endmodule


module RegisterFile();

endmodule


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



module ALUControl();

endmodule


module ControlUnit();

endmodule
