`timescale 1ns / 1ps

module device_A(CLK, RST_N, AD, CBE_N, FRAME_N, IRDY_N, TRDY_N, DEVSEL_N, REQ_N, GNT_N);

parameter MyAddress = 32'hAA, TargetAddress = 32'hBC;

input CLK, RST_N, GNT_N;
inout [31:0] AD;	reg [31:0] ADreg;
inout [3:0] CBE_N;	reg [3:0] CBE_Nreg;
inout FRAME_N, IRDY_N, TRDY_N, DEVSEL_N; 
reg REQ_Nreg = 1,FRAME_Nreg, IRDY_Nreg, TRDY_Nreg, DEVSEL_Nreg;
output REQ_N;
reg [31:0] memory [9:0];

assign AD = ADreg;	assign REQ_N = REQ_Nreg;	assign CBE_N = CBE_Nreg;
assign FRAME_N = FRAME_Nreg;	assign IRDY_N = IRDY_Nreg;
assign TRDY_N = TRDY_Nreg;	assign DEVSEL_N = DEVSEL_Nreg;

always @ (posedge CLK)
	
	begin 
		while (!GNT_N)
		begin
			#1 FRAME_Nreg <= 0; ADreg <= TargetAddress; CBE_Nreg <= 4'b1111;
		end
	end

endmodule

module arbiter_priority(GNT_Neg , REQ_Neg , FRAME_Neg);
output reg [7:0] GNT_Neg;
input [7:0] REQ_Neg;
input FRAME_Neg;

endmodule

module arbiter_RobinRound();
endmodule 

module PCI();
endmodule
