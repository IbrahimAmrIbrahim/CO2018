`timescale 1ns / 1ps
`include "../../PCI/PCI.srcs/sources_1/new/PCI.v"
module PCI_tb_linux();

reg [7:0] FORCED_REQ_N;

reg [3:0] Forced_DataTfNo_A;
reg [3:0] Forced_DataTfNo_B;
reg [3:0] Forced_DataTfNo_C;
reg [3:0] Forced_DataTfNo_D;
reg [3:0] Forced_DataTfNo_E;
reg [3:0] Forced_DataTfNo_F;
reg [3:0] Forced_DataTfNo_G;
reg [3:0] Forced_DataTfNo_H;

reg [31:0] FORCED_ADDRESS_A;
reg [31:0] FORCED_ADDRESS_B;
reg [31:0] FORCED_ADDRESS_C;
reg [31:0] FORCED_ADDRESS_D;
reg [31:0] FORCED_ADDRESS_E;
reg [31:0] FORCED_ADDRESS_F;
reg [31:0] FORCED_ADDRESS_G;
reg [31:0] FORCED_ADDRESS_H;

reg [3:0] FORCED_CBE_N_A;
reg [3:0] FORCED_CBE_N_B;
reg [3:0] FORCED_CBE_N_C;
reg [3:0] FORCED_CBE_N_D;
reg [3:0] FORCED_CBE_N_E;
reg [3:0] FORCED_CBE_N_F;
reg [3:0] FORCED_CBE_N_G;
reg [3:0] FORCED_CBE_N_H;


reg CLK, RST_N;
reg [1:0] mode;

integer i = 0;

initial
begin 
	$dumpfile("Simulation.vcd");
	$dumpvars(0,PCI_tb_linux);
end

initial
begin 
for (i = 0; i < 160; i = i + 1) 
	begin
		#5 CLK = !CLK;
	end
#2 $finish;
end

/*
Device_A --> 32'h0000_0000 : 32'h0000_0009
Device_B --> 32'h0000_000A : 32'h0000_0013
Device_C --> 32'h0000_0014 : 32'h0000_001D
Device_D --> 32'h0000_001E : 32'h0000_0027
Device_E --> 32'h0000_0028 : 32'h0000_0031
Device_F --> 32'h0000_0032 : 32'h0000_003B
Device_G --> 32'h0000_003C : 32'h0000_0045
Device_H --> 32'h0000_0046 : 32'h0000_004F
*/

initial
begin

// ____ TA ____
CLK <= 1'b0;
RST_N <= 1'b0;
mode <= 2'b00;
#10
RST_N  <= 1;
FORCED_REQ_N <= 8'b1111_1110;
FORCED_ADDRESS_A <= 32'h0000_000A;
FORCED_CBE_N_A <= 4'b0111;
Forced_DataTfNo_A <= 3;
#10
FORCED_CBE_N_A <= 4'b000;
#30
FORCED_REQ_N <= 8'b1111_1101;
FORCED_ADDRESS_B <= 32'h0000_0005;
FORCED_CBE_N_B <= 4'b0111;
Forced_DataTfNo_B <= 2;
#30
FORCED_CBE_N_B <= 4'b000;
#50
// FORCED_REQ_N <= 8'b1111_1010;
// FORCED_ADDRESS_A <= 32'h0000_0014;
// FORCED_ADDRESS_C <= 32'h0000_0000;
// FORCED_CBE_N <= 4'b0111;
// Forced_DataTfNo_A <= 2;
// Forced_DataTfNo_C <= 1;
// #30
// FORCED_REQ_N <= 8'b1111_1011;
// FORCED_ADDRESS_C <= 32'h0000_000A;
// FORCED_CBE_N <= 4'b0111;
// Forced_DataTfNo_C <= 1;

// ____ PriorityArbiter ____
/*
RST_N <= 0;
mode <= 2'b00;
#15
RST_N  <= 1;
FORCED_REQ_N <= 8'b1111_1101;
FORCED_ADDRESS_B <= 32'h0000_0000;
FORCED_CBE_N_B <= 4'b0111;
Forced_DataTfNo_B <= 5;
#20
FORCED_CBE_N_B <= 4'b0000;
#30
FORCED_REQ_N <= 8'b1111_0111;
FORCED_ADDRESS_D <= 32'h0000_0028;
FORCED_CBE_N_D <= 4'b0110;
Forced_DataTfNo_D <= 5;
#80
FORCED_REQ_N <= 8'b1111_1111;
#50
FORCED_REQ_N <= 8'b0111_1011;
FORCED_ADDRESS_C <= 32'h0000_0000;
FORCED_CBE_N_C <= 4'b0111;
Forced_DataTfNo_C <= 5;
FORCED_ADDRESS_H <= 32'h0000_002A;
FORCED_CBE_N_H <= 4'b0111;
Forced_DataTfNo_H <= 3;
#15
FORCED_CBE_N_C <= 4'b0000;
#45
FORCED_REQ_N <= 8'b0111_1111;
#25
FORCED_CBE_N_H <= 4'b0000;

/ ____ RobinRoundArbiter ____
RST_N <= 0;
mode <= 2'b01;
#15
RST_N  <= 1;
*/
// ____ FCFSArbiter ____ 
RST_N <= 0;
mode <= 2'b11;
#15
RST_N  <= 1;

FORCED_REQ_N <= 8'b1111_1101;
FORCED_ADDRESS_B <= 32'h0000_0000;
FORCED_CBE_N_B <= 4'b0111;
Forced_DataTfNo_B <= 5;
#30
FORCED_CBE_N_B <= 4'b0000;
#30
FORCED_REQ_N <= 8'b1111_0111;
FORCED_ADDRESS_D <= 32'h0000_0028;
FORCED_CBE_N_D <= 4'b0110;
Forced_DataTfNo_D <= 5;
#80
FORCED_REQ_N <= 8'b1111_1111;
#50
FORCED_REQ_N <= 8'b0111_1011;
FORCED_ADDRESS_C <= 32'h0000_0000;
FORCED_CBE_N_C <= 4'b0111;
Forced_DataTfNo_C <= 5;
FORCED_ADDRESS_H <= 32'h0000_002A;
FORCED_CBE_N_H <= 4'b0111;
Forced_DataTfNo_H <= 3;
#25
FORCED_CBE_N_C <= 4'b0000;
#55
FORCED_REQ_N <= 8'b0111_1111;
#15
FORCED_CBE_N_H <= 4'b0000;

end


PCI pci(CLK, RST_N, FORCED_REQ_N, mode,
        FORCED_ADDRESS_A, FORCED_ADDRESS_B, FORCED_ADDRESS_C, FORCED_ADDRESS_D, FORCED_ADDRESS_E, FORCED_ADDRESS_F, FORCED_ADDRESS_G, FORCED_ADDRESS_H,
		FORCED_CBE_N_A, FORCED_CBE_N_B, FORCED_CBE_N_C, FORCED_CBE_N_D, FORCED_CBE_N_E, FORCED_CBE_N_F, FORCED_CBE_N_G, FORCED_CBE_N_H,
		Forced_DataTfNo_A, Forced_DataTfNo_B, Forced_DataTfNo_C, Forced_DataTfNo_D, Forced_DataTfNo_E, Forced_DataTfNo_F, Forced_DataTfNo_G, Forced_DataTfNo_H);

endmodule
