`timescale 1ns / 1ps

module FetchStageWithoutHazard(IF_ID,clk,PCSrc,BranchAddress,RST,load,Data,IF_ID_WRITE);
input clk,PCSrc,load,RST;
input [31:0] BranchAddress,Data;
reg [31:0] PC;
output reg [63:0] IF_ID;
wire [31:0] Instruction;
input IF_ID_WRITE;

assign IF_ID [63:32] = PC;

always @(posedge RST)
begin
	PC <= 32'h0000_0000;
end

always @(posedge clk)
begin
	if (~(RST && IF_ID_WRITE))
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

InstructionMemory InstructionMemory1(Instruction,PC,clk,RST,load,Data);
endmodule

module DecodeStageWithoutHazard(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data,IF_ID_WRITE,ID_EX_MEMORY_CONTROL,ID_EX_RT);
output reg [151:0] ID_EX;
wire RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch;
wire [1:0] ALUOp;
wire [31:0] SignExtend_wires;
wire [31:0] READ_DATA1,READ_DATA2;
input [4:0] WRITE_REGISTER;
input [31:0] WRITE_DATA,Data;
input [63:0] IF_ID;
input REG_WRITE,clk,RST,load;
input [4:0]ID_EX_RT;
input ID_EX_MEMORY_CONTROL;
wire MUX_0_CONTROL;
output IF_ID_WRITE;
always @(negedge clk)
begin
	ID_EX [4:0] <= IF_ID[15:11];// rd
	ID_EX [9:5] <= IF_ID[20:16];//rt
	ID_EX [14:10] <= IF_ID[25:21];//rs
	ID_EX [46:15] <= SignExtend_wires;// 15:0 from instruction
	ID_EX [78:47] <= READ_DATA2;
	ID_EX [110:79] <= READ_DATA1;
	ID_EX [142:111] <= IF_ID[63:32];// pc + 4
		if(MUX_0_CONTROL==0)
		begin
		ID_EX [143] <= ALUSrc;
		ID_EX [145:144] <= ALUOp;
		ID_EX [146] <= RegDst;
		ID_EX [147] <= MemWrite;
		ID_EX [148] <= MemRead;
		ID_EX [149] <= Branch;
		ID_EX [150] <= MemtoReg;
		ID_EX [151] <= RegWrite;
		end
		else 
		begin
		ID_EX [151:143] <= 0;
		end
		
		
		
end
hazard_detction_unit(ID_EX_MEMORY_CONTROL,IF_ID[25:21],IF_ID[20:16],ID_EX_RT,IF_ID_WRITE,MUX_0_CONTROL);
SignExtend SignExtend1(IF_ID[15:0],SignExtend_wires);
RegisterFile RegisterFile1 (READ_DATA2,READ_DATA1,IF_ID[25:21],IF_ID[20:16],WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,RST,load,Data);
ControlUnit ControlUnit1(RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp,IF_ID[31:26]);
endmodule


module ExecutionStageWithoutHazard(EX_MEM,clk,ID_EX,WB_EX,WB_MEM,RD_EX,RD_MEM,ALU_OUT,WRITE_BACK_DATA);
output reg [106:0] EX_MEM;
input WB_EX,WB_MEM; 
input [4:0]RD_EX,RD_MEM;
input [31:0]ALU_OUT,WRITE_BACK_DATA;
wire [1:0]MUX_RS,MUX_RT;
wire[31:0]mux1_out;
wire[31:0]mux2_out;

//reg write 
input clk;
input [151:0] ID_EX;
wire [3:0]ALUCtrl;
wire Zero_wire;
wire [31:0] ALUOut;
wire [31:0] Shifted_wire;

always@(negedge clk)
begin
	EX_MEM [4:0] <= (ID_EX[146)? ID_EX[4:0]:ID_EX[9:5];
	EX_MEM [36:5] <= ID_EX[78:47];
	EX_MEM [68:37] <= ALUOut;
	EX_MEM [69] <= Zero_wire;
	EX_MEM [101:70] <= Shifted_wire + ID_EX [142:111];
	EX_MEM [106:102] <= ID_EX [151:147];
end
mux4x1_32bit mux_1(ID_EX [110:79],WRITE_BACK_DATA,ALU_OUT,0,MUX_RS,mux1_out);
mux4x1_32bit mux_2(ID_EX [78:47],WRITE_BACK_DATA,ALU_OUT,0,MUX_RT,mux2_out);
forwarding_unit(ID_EX [14:10],ID_EX [9:5],RD_EX,RD_MEM,WB_EX,WB_MEM,MUX_RS,MUX_RT);
ALUControl ALUControl1(ID_EX [145:144],ID_EX [20:15],ALUCtrl);
ALU ALU1(mux1_out,((ID_EX [143])? ID_EX [46:15]:mux2_out),ALUCtrl,ALUOut,Zero_wire);
ShiftLeft2 ShiftLeft2_1 (ID_EX [46:15],Shifted_wire);
endmodule


module MemoryStageWithoutHazard(MEM_WB,PCSrc,BranchAddress,clk,EX_MEM,load,Data);
output reg [70:0] MEM_WB;
output reg PCSrc;
output reg [31:0] BranchAddress;
input clk,load;
input [7:0] Data;
input [106:0] EX_MEM;
wire [31:0] READ_DATA;

always@(posedge clk)
begin
	PCSrc <= EX_MEM [69] & EX_MEM [104];
	BranchAddress <= EX_MEM [101:70];
end

always@(negedge clk)
begin
	MEM_WB [4:0] <= EX_MEM[4:0];
	MEM_WB [36:5] <= EX_MEM [68:37];
	MEM_WB [68:37] <= READ_DATA;
	MEM_WB [70:69] <= EX_MEM [106:105];
end

DataMemory DataMemory1(READ_DATA,EX_MEM [68:37],EX_MEM [36:5],EX_MEM [102],EX_MEM [103],clk,load,Data);
endmodule


module WBStageWithoutHazard(WriteRegister,WRITE_DATA,RegWrite,clk,MEM_WB);
input [70:0] MEM_WB;
input clk;
output reg [4:0] WriteRegister;
output reg [31:0] WRITE_DATA;
output reg RegWrite;

always@(posedge clk)
begin
	WriteRegister <= MEM_WB [4:0];
	WRITE_DATA <= (MEM_WB [69])? MEM_WB [68:37]:MEM_WB [36:5];
	RegWrite <= MEM_WB [70];
end
endmodule


module PipelineMIPSWithoutHazard(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
input clk,RST,loadRegFile,loadInstructionMem,loadDataMem;
input [31:0] RegFileData ,InstructionMemData;
input [7:0] DataMemData;

wire PCSrc,REG_WRITE;
wire [63:0]IF_ID;
wire [151:0]ID_EX;
wire [4:0] WRITE_REGISTER;
wire [31:0] WRITE_DATA,BranchAddress;
wire [106:0]EX_MEM;
wire [70:0]MEM_WB;


ExecutionStageWithoutHazard(EX_MEM,clk,ID_EX,EX_MEM[106],MEM_WB[70],EX_MEM[4:0],MEM_WB[4:0],EX_MEM[68:37],WRITE_DATA);
FetchStageWithoutHazard FetchStage1(IF_ID,clk,PCSrc,BranchAddress,RST,loadInstructionMem,InstructionMemData);
DecodeStageWithoutHazard DecodeStage1(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,loadRegFile,RegFileData);
//ExecutionStageWithoutHazard ExecutionStage1(EX_MEM,clk,ID_EX);
MemoryStageWithoutHazard MemoryStage1(MEM_WB,PCSrc,BranchAddress,clk,EX_MEM,loadDataMem,DataMemData);
WBStageWithoutHazard WBStage1(WRITE_REGISTER,WRITE_DATA,REG_WRITE,clk,MEM_WB);

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
$readmemb("F:/RegFileData.txt" , RegFileDataFile);
$readmemb("F:/InstructionFileData.txt" , InstructionFileDataFile);
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
PipelineMIPSWithoutHazard PipelineMIPS1(clk,RST,loadRegFile,loadInstructionMem,loadDataMem,RegFileData,InstructionMemData,DataMemData);
endmodule




module tb_DECStageWithoutHazard();
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

DecodeStageWithoutHazard DEC(ID_EX,IF_ID,clk,WRITE_REGISTER,WRITE_DATA,REG_WRITE,RST,load,Data);
endmodule


module tb_registerfileWithoutHazard(); 
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


