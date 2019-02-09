`timescale 1ns / 1ps

module FetchStageWithoutHazard(IF_ID,clk,PCSrc,BranchAddress,RST,load,Data,PC_WRITE);
input clk,PCSrc,load,RST,PC_WRITE;
input [31:0] BranchAddress,Data;
reg [31:0] PC;
output [63:0] IF_ID;
wire [31:0] Instruction;

assign IF_ID [63:32] = PC;

always @(posedge RST)
begin
	PC <= 32'h0000_0000;
end

always @(posedge clk)
begin
	if (~(RST || PC_WRITE))
	begin
		if (PCSrc)
		begin
			PC <= BranchAddress;
		end
		else
		begin
			PC <= PC + 4;
		end
    end 
end

InstructionMemory InstructionMemory1(IF_ID [31:0],PC,clk,RST,load,Data);
endmodule

module DecodeStageWithoutHazard(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data,IF_ID_WRITE,PCWrite,ID_EX_MEMRead,ID_EX_RT);
output [151:0] ID_EX;
output IF_ID_WRITE , PCWrite;

input [4:0] WRITE_REGISTER;
input [31:0] WRITE_DATA,Data;
input [63:0] IF_ID;
input REG_WRITE,clk,RST,load;
input [4:0]ID_EX_RT;
input ID_EX_MEMRead;

wire RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch;
wire [8:0] Control;
wire [1:0] ALUOp;
wire [31:0] SignExtend_wires;
wire [31:0] READ_DATA1,READ_DATA2;
wire MUX_0_CONTROL;

assign ID_EX [4:0] = IF_ID[15:11]; // rd
assign ID_EX [9:5] = IF_ID[20:16]; //rt
assign ID_EX [14:10] = IF_ID[25:21]; //rs
assign ID_EX [46:15] = SignExtend_wires; // 15:0 from instruction
assign ID_EX [78:47] = READ_DATA2;
assign ID_EX [110:79] = READ_DATA1;
assign ID_EX [142:111] = IF_ID[63:32]; // pc + 4
assign ID_EX [151:143] = (MUX_0_CONTROL)? 9'b000000000 : Control;
assign PCWrite = IF_ID_WRITE;
/*
ID_EX [143] <= ALUSrc;
ID_EX [145:144] <= ALUOp;
ID_EX [146] <= RegDst;
ID_EX [147] <= MemWrite;
ID_EX [148] <= MemRead;
ID_EX [149] <= Branch;
ID_EX [150] <= MemtoReg;
ID_EX [151] <= RegWrite;
*/
		
/*
module hazard_detction_unit(ID_EX_MEMORY_CONTROL,RS,RT,ID_EX_RT,IF_ID_WRITE,MUX_0_CONTROL);
*/
hazard_detction_unit hazard_detction_unit_1(ID_EX_MEMRead,IF_ID[25:21],IF_ID[20:16],ID_EX_RT,IF_ID_WRITE,MUX_0_CONTROL,RST);
SignExtend SignExtend1(IF_ID[15:0],SignExtend_wires);
RegisterFile RegisterFile1 (READ_DATA1,READ_DATA2,IF_ID[25:21],IF_ID[20:16],WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,RST,load,Data);
/*
module ControlUnit(RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp,OpCode);
*/
ControlUnit ControlUnit1(Control[3],Control[0],Control[7],Control[8],Control[5],Control[4],Control[6],Control[2:1],IF_ID[31:26]);

endmodule


module ExecutionStageWithoutHazard(EX_MEM,ID_EX,EX_MEM_WB,MEM_WB_WB,EX_MEM_rd,MEM_WB_rd,ALU_OUT,WRITE_BACK_DATA,ID_EX_MEMRead,RST);
output [106:0] EX_MEM;
output ID_EX_MEMRead;

input [151:0] ID_EX;
input EX_MEM_WB,MEM_WB_WB,RST; 
input [4:0] EX_MEM_rd,MEM_WB_rd;
input [31:0] ALU_OUT,WRITE_BACK_DATA;

wire [1:0] MUX_RS,MUX_RT;
wire [31:0] mux1_out;
wire [31:0] mux2_out;
wire [3:0] ALUCtrl;
wire Zero_wire;
wire [31:0] ALUOut;
wire [31:0] Shifted_wire;

assign EX_MEM [4:0] = (ID_EX[146])? ID_EX[4:0]:ID_EX[9:5];
assign EX_MEM [36:5] = ID_EX[78:47];
assign EX_MEM [68:37] = ALUOut;
assign EX_MEM [69] = Zero_wire;
assign EX_MEM [101:70] = Shifted_wire + ID_EX [142:111];
assign EX_MEM [106:102] = ID_EX [151:147];
assign ID_EX_MEMRead = ID_EX[148];

mux4x1_32bit mux_1(ID_EX [110:79],WRITE_BACK_DATA,ALU_OUT,0,MUX_RS,mux1_out);
mux4x1_32bit mux_2(ID_EX [78:47],WRITE_BACK_DATA,ALU_OUT,0,MUX_RT,mux2_out);
forwarding_unit forwarding_unit_1(ID_EX [14:10],ID_EX [9:5],EX_MEM_rd,MEM_WB_rd,EX_MEM_WB,MEM_WB_WB,MUX_RS,MUX_RT,RST);
ALUControl ALUControl1(ID_EX [145:144],ID_EX [20:15],ALUCtrl);
ALU ALU1(mux1_out,((ID_EX [143])? ID_EX [46:15]:mux2_out),ALUCtrl,ALUOut,Zero_wire);
ShiftLeft2 ShiftLeft2_1 (ID_EX [46:15],Shifted_wire);
endmodule


module MemoryStageWithoutHazard(MEM_WB,PCSrc,BranchAddress,clk,EX_MEM,RST,load,Data,ALUOut,EX_MEM_rd,EX_MEM_WB);
output [70:0] MEM_WB;
output PCSrc,EX_MEM_WB;
output [31:0] BranchAddress , ALUOut;
output [4:0] EX_MEM_rd;

input clk,load,RST;
input [7:0] Data;
input [106:0] EX_MEM;

wire [31:0] READ_DATA;

assign PCSrc = EX_MEM [69] & EX_MEM [104];
assign BranchAddress = EX_MEM [101:70];
assign MEM_WB [4:0] = EX_MEM[4:0];
assign MEM_WB [36:5] = EX_MEM [68:37];
assign MEM_WB [68:37] = READ_DATA;
assign MEM_WB [70:69] = EX_MEM [106:105];
assign ALUOut = EX_MEM [68:37];
assign EX_MEM_WB = EX_MEM [106];


DataMemory DataMemory1(READ_DATA,EX_MEM [68:37],EX_MEM [36:5],EX_MEM [102],EX_MEM [103],clk,RST,load,Data);
endmodule


module WBStageWithoutHazard(WriteRegister,WRITE_DATA,RegWrite,MEM_WB);
input [70:0] MEM_WB;

output [4:0] WriteRegister;
output [31:0] WRITE_DATA;
output RegWrite;

assign WriteRegister = MEM_WB [4:0];
assign WRITE_DATA = (MEM_WB [69])? MEM_WB [68:37]:MEM_WB [36:5];
assign RegWrite = MEM_WB [70];

endmodule


module PipelineMIPSWithoutHazard(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
input clk,RST,loadRegFile,loadInstructionMem,loadDataMem;
input [31:0] RegFileData ,InstructionMemData;
input [7:0] DataMemData;

wire PCSrc,REG_WRITE,PC_WRITE,IF_ID_WRITE,ID_EX_MEMRead,EX_MEM_WB;

wire [63:0] IF_ID_in;
wire [63:0] IF_ID_out;
wire [151:0]ID_EX_in;
wire [151:0]ID_EX_out;
wire [106:0]EX_MEM_in;
wire [106:0]EX_MEM_out;
wire [70:0]MEM_WB_in;
wire [70:0]MEM_WB_out;

wire [4:0] WRITE_REGISTER,ID_EX_RT,EX_MEM_rd;
wire [31:0] WRITE_DATA,BranchAddress,ALUOut;


/*
module FetchStageWithoutHazard(IF_ID,clk,PCSrc,BranchAddress,RST,load,Data,PC_WRITE);
module DecodeStageWithoutHazard(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data,IF_ID_WRITE,PCWrite,ID_EX_MEMRead,ID_EX_RT);
module ExecutionStageWithoutHazard(EX_MEM,ID_EX,EX_MEM_WB,MEM_WB_WB,EX_MEM_rd,MEM_WB_rd,ALU_OUT,WRITE_BACK_DATA,ID_EX_MEMRead);
module MemoryStageWithoutHazard(MEM_WB,PCSrc,BranchAddress,clk,EX_MEM,RST,load,Data,ALUOut,EX_MEM_rd,EX_MEM_WB);
module WBStageWithoutHazard(WriteRegister,WRITE_DATA,RegWrite,MEM_WB);
*/

FetchStageWithoutHazard FetchStageWithoutHazard1(IF_ID_in,clk,PCSrc,BranchAddress,RST,loadInstructionMem,InstructionMemData,PC_WRITE);
IF_ID__MEM IF_ID__MEM_1(clk,IF_ID_in,IF_ID_out,IF_ID_WRITE);
DecodeStageWithoutHazard DecodeStageWithoutHazard1(ID_EX_in,IF_ID_out,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,loadRegFile,RegFileData,IF_ID_WRITE,PC_WRITE,ID_EX_MEMRead,ID_EX_RT);
ID_EX__MEM ID_EX__MEM_1(clk,ID_EX_in,ID_EX_out);
ExecutionStageWithoutHazard ExecutionStageWithoutHazard1(EX_MEM_in,ID_EX_out,EX_MEM_WB,REG_WRITE,EX_MEM_rd,WRITE_REGISTER,ALUOut,WRITE_DATA,ID_EX_MEMRead,RST);
EX_MEM__MEM EX_MEM__MEM_1(clk,EX_MEM_in,EX_MEM_out);
MemoryStageWithoutHazard MemoryStageWithoutHazard1(MEM_WB_in,PCSrc,BranchAddress,clk,EX_MEM_out,RST,loadDataMem,DataMemData,ALUOut,EX_MEM_rd,EX_MEM_WB);
MEM_WB__MEM MEM_WB__MEM_1(clk,MEM_WB_in,MEM_WB_out);
WBStageWithoutHazard WBStageWithoutHazard1(WRITE_REGISTER,WRITE_DATA,REG_WRITE,MEM_WB_out);

endmodule


//=======================tb==============//
module tb_PipelineMIPSWithoutHazard();
reg clk ,RST,loadRegFile,loadInstructionMem,loadDataMem;
reg [31:0] RegFileData,InstructionMemData;
reg [7:0] DataMemData;
reg [31:0] RegFileDataFile [0:31];
reg [31:0] InstructionFileDataFile [0:131071];
integer i,j;

initial
begin
clk = 1'b0;
loadRegFile <= 0;
loadInstructionMem <= 0;
RST <= 1;
$readmemb("E:/Faculty of Engineering Ain Shams University/3rd CSE 2018 - 2019/1st Term/Lectures/Computer Organization/Project/CO2018/MIPS Processor/MIPS Processor.srcs/sources_1/new/RegFileData.txt" , RegFileDataFile);
$readmemb("E:/Faculty of Engineering Ain Shams University/3rd CSE 2018 - 2019/1st Term/Lectures/Computer Organization/Project/CO2018/MIPS Processor/MIPS Processor.srcs/sources_1/new/InstructionFileData.txt" , InstructionFileDataFile);
#15
fork
begin
	for (i = 0 ; i < 32; i = i + 1)
	begin
	#10
	loadRegFile <= 1;
	RegFileData <= RegFileDataFile[i];
	end
	#10
	loadRegFile <= 0;
end
begin
	for (j = 0 ; j < 200; j = j + 1)
	begin
	#10
	loadInstructionMem <= 1;
	InstructionMemData <= InstructionFileDataFile[j];
	$display("%b \n",InstructionFileDataFile[j - 1]);
	end
	#10
	loadInstructionMem <= 0;
end
join
#5
RST <= 0;

end


always
begin
#5
clk = ~clk;
end
PipelineMIPSWithoutHazard PipelineMIPSWithoutHazard1(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
endmodule