`timescale 1ns / 1ps

module device_A(CLK, RST_N, AD, CBE_N, FRAME_N, IRDY_N, TRDY_N, DEVSEL_N, REQ_N, GNT_N, FORCED_REQ_N, FORCED_ADDRESS, FORCED_CBE_N);

parameter MyAddress = 32'hAA, TargetAddress = 32'hBC;

input CLK, RST_N, GNT_N, FORCED_REQ_N, FORCED_ADDRESS, FORCED_CBE_N;
inout [31:0] AD;	reg [31:0] ADreg;  
inout [3:0] CBE_N;	reg [3:0] CBE_Nreg;
inout FRAME_N, IRDY_N, TRDY_N, DEVSEL_N; 
reg FRAME_Nreg, IRDY_Nreg, TRDY_Nreg, DEVSEL_Nreg;
output REQ_N;
reg [31:0] memory [9:0];
reg MasterFlag = 0, GNTFlag = 0;
assign REQ_N = FORCED_REQ_N;

assign AD = ADreg;	          	assign CBE_N = CBE_Nreg;
assign FRAME_N = FRAME_Nreg;	assign IRDY_N = IRDY_Nreg;
assign TRDY_N = TRDY_Nreg;	    assign DEVSEL_N = DEVSEL_Nreg;

always @ (posedge CLK)
	begin 
        if(!REQ_N) //Then Device is Master
            MasterFlag = 1;

        if (MasterFlag)
            if(!GNT_N)
                GNTFlag = 1;
            else
                begin 
                    GNTFlag = 0;
                    MasterFlag = 0;
                end
        
        if (GNTFlag)
            begin
                FRAME_Nreg <= 0;
                ADreg    <= FORCED_ADDRESS;
                CBE_Nreg <= 4'b0110;
            end

        if(!FRAME_N)
                IRDY_Nreg = 0;
        if(!IRDY_N)
            begin
                ADreg    <= {(32){1'bz}};
                CBE_Nreg <= 4'b1111;

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