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

module arbiter_priority(GNT_Neg , REQ_Neg , FRAME_Neg ,clk, RST_Neg);
output reg [7:0] GNT_Neg;
input [7:0] REQ_Neg;
input FRAME_Neg,RST_Neg,clk;

always @(posedge clk)
begin
    if(~RST_Neg)
    begin
        GNT_Neg <= 8'b1111_1111;
    end
    else if(FRAME_Neg)
    begin
        casez(REQ_Neg)
            8'bzzzz_zzz0:GNT_Neg <= 8'b1111_1110;
            8'bzzzz_zz01:GNT_Neg <= 8'b1111_1101;
            8'bzzzz_z011:GNT_Neg <= 8'b1111_1011;
            8'bzzzz_0111:GNT_Neg <= 8'b1111_0111;
            8'bzzz0_1111:GNT_Neg <= 8'b1110_1111;
            8'bzz01_1111:GNT_Neg <= 8'b1101_1111;
            8'bz011_1111:GNT_Neg <= 8'b1011_1111;
            8'b0111_1111:GNT_Neg <= 8'b0111_1111;
            default:GNT_Neg <= 8'b1111_1111;
        endcase
    end
end
endmodule

module arbiter_RobinRound();
endmodule 

module PCI();
endmodule

module tb_arbiter_priority();

wire [7:0] GNT;
reg [7:0] REQ;
reg FRAME,clk,RST;

integer i;
initial
    begin
    $monitor($time ,, "REQ = %b  FRAME = %b  GNT = %b  RST = %b" , REQ , FRAME , GNT , RST);
    #2
    clk <= 0;
    RST <= 0;
    FRAME <= 1;
    #5
    RST <= 1;
        for(i = 0 ; i < 20 ; i = i + 1)
    begin
        #5
        REQ <= $urandom %8;
        //  RST <= $urandom %2;
        // FRAME <= $urandom %2;
    end
end

always
begin
    #5
    clk = ~clk;
end


arbiter_priority arbiter_test(GNT,REQ,FRAME,clk,RST);
endmodule