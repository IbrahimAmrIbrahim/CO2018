`timescale 1ns / 1ps

module InstructionMemory();

endmodule


module DataMemory(READ_DATA,ADDRESS,WRITE_DATA,MEM_WRITE,MEM_READ);
input [31:0]ADDRESS,WRITE_DATA;
input MEM_READ,MEM_WRITE;
output reg [31:0]READ_DATA;
reg [7:0]memory[0:4294967295];

always@(*)
begin
if(MEM_READ)
    begin
     READ_DATA[7:0]<= memory[ADDRESS];
     READ_DATA[15:8]<= memory[ADDRESS+1];
     READ_DATA[23:16]<= memory[ADDRESS+2];
     READ_DATA[32:24]<= memory[ADDRESS+3];
        
    end
    
 if(MEM_WRITE)
    begin
    memory[ADDRESS]<=WRITE_DATA[7:0];
    memory[ADDRESS+1]<=WRITE_DATA[15:8];
    memory[ADDRESS+2]<=WRITE_DATA[23:16];
    memory[ADDRESS+3]<=WRITE_DATA[32:24];
    
    end
end
endmodule


module RegisterFile(READ_DATA2,READ_DATA1,READ_REGISTER1,READ_REGISTER2,WRITE_REGISTER,WRITE_DATA,REG_WRITE);
input [4:0]READ_REGISTER2,READ_REGISTER1,WRITE_REGISTER;
input REG_WRITE;
input[31:0] WRITE_DATA;
output   [31:0] READ_DATA2,READ_DATA1;
reg [31:0]memory[31:0];
assign READ_DATA2 = memory[READ_REGISTER2];
assign READ_DATA1 = memory[READ_REGISTER1];
always@(*)
begin

if(REG_WRITE)
    begin
    memory[WRITE_REGISTER]<=WRITE_DATA;
    end
end


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


module ShiftLeft2(IN,OUT);
input [31:0]IN;
output reg [31:0]OUT;
always@(*)
begin
OUT[1:0]<=2'b 00;
OUT[31:2]=IN[29:0];
end 

endmodule
