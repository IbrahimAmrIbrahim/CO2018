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


module ALU();

endmodule


module ALUControl();

endmodule


module ControlUnit();

endmodule
