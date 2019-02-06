`timescale 1ns / 1ps

module FetchStage(IF_ID,clk,PCSrc,BranchAddress,RST,load,Data);
input clk,PCSrc,load,RST;
input [31:0] BranchAddress,Data;
reg [31:0] PC;
output [63:0] IF_ID;
wire [31:0] Instruction;

assign IF_ID [63:32] = PC;
	
always @(RST)
begin
	if (RST)
	begin
		PC <= 32'hffff_fffc;
	end
end

always @(posedge clk)
begin
	if (~RST)
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


module DecodeStage(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data);
output[151:0] ID_EX;
input [4:0] WRITE_REGISTER;
input [31:0] WRITE_DATA,Data;
input [63:0] IF_ID;
input REG_WRITE,clk,RST,load;

assign ID_EX [4:0] = IF_ID[15:11];
assign ID_EX [9:5] = IF_ID[20:16];
assign ID_EX [137:106] = IF_ID[63:32];

/*	ID_EX [4:0] <= IF_ID[15:11];
	ID_EX [9:5] <= IF_ID[20:16];
	ID_EX [41:10] <= SignExtend_wires;
	ID_EX [73:42] <= READ_DATA2;
	ID_EX [105:74] <= READ_DATA1;
	ID_EX [137:106] <= IF_ID[63:32];
	ID_EX [138] <= ALUSrc;
	ID_EX [140:139] <= ALUOp;
	ID_EX [141] <= RegDst;
	ID_EX [142] <= MemWrite;
	ID_EX [143] <= MemRead;
	ID_EX [144] <= Branch;
	ID_EX [145] <= MemtoReg;
	ID_EX [146] <= RegWrite;
*/

SignExtend SignExtend1(IF_ID[15:0],ID_EX [41:10]);
RegisterFile RegisterFile1 (ID_EX [105:74],ID_EX [73:42],IF_ID[25:21],IF_ID[20:16],WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,RST,load,Data);
ControlUnit ControlUnit1(ID_EX [141],ID_EX [138],ID_EX [145],ID_EX [146],ID_EX [143] ,ID_EX [142],ID_EX [144],ID_EX [140:139],IF_ID[31:26]);
endmodule


module ExecutionStage(EX_MEM,clk,ID_EX);
output [106:0] EX_MEM;
input clk;
input [151:0] ID_EX;
wire [3:0]ALUCtrl;
wire Zero_wire;
wire [31:0] ALUOut;
wire [31:0] Shifted_wire;


assign EX_MEM [4:0] = (ID_EX[141])? ID_EX[4:0]:ID_EX[9:5];
assign EX_MEM [36:5] = ID_EX[73:42];
assign EX_MEM [68:37] = ALUOut;
assign EX_MEM [69] = Zero_wire;
assign EX_MEM [101:70] = Shifted_wire + ID_EX [137:106];
assign EX_MEM [106:102] = ID_EX [146:142];


ALUControl ALUControl1(ID_EX [140:139],ID_EX [15:10],ALUCtrl);
ALU ALU1(ID_EX [105:74],((ID_EX [138])? ID_EX [41:10]:ID_EX [73:42]),ALUCtrl,ALUOut,Zero_wire);
ShiftLeft2 ShiftLeft2_1 (ID_EX [41:10],Shifted_wire);
endmodule


module MemoryStage(MEM_WB,PCSrc,BranchAddress,clk,EX_MEM,RST,load,Data);
output [70:0] MEM_WB;
output PCSrc;
output [31:0] BranchAddress;
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

DataMemory DataMemory1(READ_DATA,EX_MEM [68:37],EX_MEM [36:5],EX_MEM [102],EX_MEM [103],clk,RST,load,Data);
endmodule


module WBStage(WriteRegister,WRITE_DATA,RegWrite,clk,MEM_WB);
input [70:0] MEM_WB;
input clk;
output [4:0] WriteRegister;
output [31:0] WRITE_DATA;
output RegWrite;


assign WriteRegister = MEM_WB [4:0];
assign WRITE_DATA = (MEM_WB [69])? MEM_WB [68:37]:MEM_WB [36:5];
assign RegWrite = MEM_WB [70];

endmodule


module PipelineMIPS(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
input clk,RST,loadRegFile,loadInstructionMem,loadDataMem;
input [31:0] RegFileData ,InstructionMemData;
input [7:0] DataMemData;

wire PCSrc,REG_WRITE;

wire [63:0] IF_ID_in;
wire [63:0] IF_ID_out;
wire [151:0]ID_EX_in;
wire [151:0]ID_EX_out;
wire [106:0]EX_MEM_in;
wire [106:0]EX_MEM_out;
wire [70:0]MEM_WB_in;
wire [70:0]MEM_WB_out;

wire [4:0] WRITE_REGISTER;
wire [31:0] WRITE_DATA,BranchAddress;

FetchStage FetchStage1(IF_ID_in,clk,PCSrc,BranchAddress,RST,loadInstructionMem,InstructionMemData);
IF_ID__MEM IF_ID__MEM_1(clk,IF_ID_in,IF_ID_out);
DecodeStage DecodeStage1(ID_EX_in,IF_ID_out,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,loadRegFile,RegFileData);
ID_EX__MEM ID_EX__MEM_1(clk,ID_EX_in,ID_EX_out);
ExecutionStage ExecutionStage1(EX_MEM_in,clk,ID_EX_out);
EX_MEM__MEM EX_MEM__MEM_1(clk,EX_MEM_in,EX_MEM_out);
MemoryStage MemoryStage1(MEM_WB_in,PCSrc,BranchAddress,clk,EX_MEM_out,RST,loadDataMem,DataMemData);
MEM_WB__MEM MEM_WB__MEM_1(clk,MEM_WB_in,MEM_WB_out);
WBStage WBStage1(WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,MEM_WB_out);

endmodule


//=======================tb==============//
module tb_PipelineMIPS();
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
PipelineMIPS PipelineMIPS1(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
endmodule




module tb_DECStage();
wire [146:0] ID_EX;
reg [4:0] WRITE_REGISTER;
reg [31:0] WRITE_DATA,Data;
reg [63:0] IF_ID;
reg REG_WRITE,clk,RST,load;
reg[31:0] i;
initial
begin
clk=1;
load=1;
RST=1;
REG_WRITE=0;
    for(i=0;i<10;i=i+1)
    begin
    #5
    Data=10;
    
    end
    
#5
RST=0;
load=0;
REG_WRITE=1;
WRITE_DATA=50;
WRITE_REGISTER=19;
IF_ID=32'h0000_0000;

    
end

always
begin
#5
clk = ~clk;
end

DecodeStage DEC(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data);
endmodule


module tb_registerfile(); 
reg [4:0] READ_REGISTER2,READ_REGISTER1,WRITE_REGISTER;
reg REG_WRITE,load,clk,RST;
reg [31:0] WRITE_DATA,Data;
wire [31:0] READ_DATA2,READ_DATA1;
reg [31:0]i;
initial
begin
clk=1;
load=1;
RST=1;
REG_WRITE=0;
   for(i=0;i<10;i=i+1)
    begin
    #5
    Data=i;
    
    end
    
#5
RST=0;
load=0;
READ_REGISTER1=0;
READ_REGISTER2=1;   
REG_WRITE=1;
WRITE_REGISTER=12;  
WRITE_DATA=40;  
end

always
begin
#5
clk = ~clk;
end


RegisterFile rf1(READ_DATA2,READ_DATA1,READ_REGISTER1,READ_REGISTER2,WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,RST,load,Data);
endmodule


