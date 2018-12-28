`timescale 1ns / 1ps
`include "../../PCI.srcs/sources_1/new/PCI.v"
module PCI_testB();

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
reg CLK, RST_N, Forced_Frame, Forced_IRDY, Forced_TRDY;
reg [1:0] mode;
integer i;

initial
begin
	$dumpfile("Simulation.vcd");
	$dumpvars(0,PCI_testB);
end
initial
begin
	for (i = 0; i < 160; i = i + 1)
	begin
		#5 CLK = !CLK;
	end
	#2 $finish;
end
PCI pci(CLK, RST_N, FORCED_REQ_N, mode,Forced_Frame,Forced_IRDY, Forced_TRDY,FORCED_ADDRESS_A, FORCED_ADDRESS_B, FORCED_ADDRESS_C, FORCED_ADDRESS_D, FORCED_ADDRESS_E, FORCED_ADDRESS_F, FORCED_ADDRESS_G, FORCED_ADDRESS_H,FORCED_CBE_N_A, FORCED_CBE_N_B, FORCED_CBE_N_C, FORCED_CBE_N_D, FORCED_CBE_N_E, FORCED_CBE_N_F, FORCED_CBE_N_G, FORCED_CBE_N_H,Forced_DataTfNo_A, Forced_DataTfNo_B, Forced_DataTfNo_C, Forced_DataTfNo_D, Forced_DataTfNo_E, Forced_DataTfNo_F, Forced_DataTfNo_G, Forced_DataTfNo_H);

initial
begin
CLK <= 1'b0;
RST_N <= 1'b0;
mode <= 2'b00;

Forced_Frame <= 1'b0;
Forced_IRDY <= 1'b0;
Forced_TRDY <= 1'b0;
#10
RST_N  <= 1;


#3;
FORCED_REQ_N <= 8'b1111_1110;
FORCED_ADDRESS_A<= 32'h0000_000A;
FORCED_CBE_N_A<= 4'b0111;
Forced_DataTfNo_A<= 8;
#20
FORCED_CBE_N_A<= 0;
FORCED_REQ_N <= 8'b1111_1111;

#100
#3;
FORCED_REQ_N <= 8'b1110_1111;
FORCED_ADDRESS_E<= 32'h0000_0032;
FORCED_CBE_N_E<= 4'b0110;
Forced_DataTfNo_E<= 7;
#20
FORCED_CBE_N_E<= 0;
FORCED_REQ_N <= 8'b1111_1111;

#90
#6;
FORCED_REQ_N <= 8'b1111_0111;
FORCED_ADDRESS_D<= 32'h0000_003C;
FORCED_CBE_N_D<= 4'b0110;
Forced_DataTfNo_D<= 7;
#20
FORCED_CBE_N_D<= 0;
FORCED_REQ_N <= 8'b1111_1111;

#90
#6;
FORCED_REQ_N <= 8'b1111_1011;
FORCED_ADDRESS_C<= 32'h0000_0046;
FORCED_CBE_N_C<= 4'b0110;
Forced_DataTfNo_C<= 4;
#20
FORCED_CBE_N_C<= 0;
FORCED_REQ_N <= 8'b1111_1111;

#60RST_N <= 0;
end
endmodule