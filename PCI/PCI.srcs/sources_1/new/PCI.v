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

module arbiter_RobinRound(GNT_Neg , REQ_Neg , FRAME_Neg ,clk, RST_Neg);
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

module arbiter_FCFS(GNT_Neg , REQ_Neg , FRAME_Neg ,clk, RST_Neg);
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
   GNT_Neg=REQ_Neg;
   casez(GNT_Neg)
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


module FCFO_Protocall();


endmodule


/*module BIT_SHIFT(bit_location,out);
input  bit_location;
output reg [7:0]out;
initial
begin
    case(bit_location)
    0: out=8'b1111_1110;
    1: out=8'b1111_1101;
    2: out=8'b1111_1011;
    3: out=8'b1111_0111;
    4: out=8'b1110_1111;
    5: out=8'b1101_1111;
    6: out=8'b1011_1111;
    7: out=8'b0111_1111;
    
    endcase
end
endmodule*/


module REQ_THREADER(REQ,THREADING_REQ0,THREADING_REQ1,THREADING_REQ2,THREADING_REQ3,THREADING_REQ4,THREADING_REQ5,THREADING_REQ6,THREADING_REQ7);
//request output only 1 time
input [7:0]REQ;
output reg [7:0]THREADING_REQ0;
output reg [7:0]THREADING_REQ1;
output reg [7:0]THREADING_REQ2;
output reg [7:0]THREADING_REQ3;
output reg [7:0]THREADING_REQ4;
output reg [7:0]THREADING_REQ5;
output reg [7:0]THREADING_REQ6;
output reg [7:0]THREADING_REQ7;
reg [7:0]THREADING_REQ[0:7]; // memory
reg location;//memory location
reg bit_no;// 0 bit location
reg [7:0] BIT_SHIFT_OUT;// the out for 0 bit location
always@(*)
    begin
    
    location=0;
    bit_no=0;
            while(bit_no<8)
        begin
        
        if(REQ[bit_no]==1'b0)
            begin
         
       //   BIT_SHIFT x(bit_no,BIT_SHIFT_OUT);
            
           case(bit_no)
            0: BIT_SHIFT_OUT=8'b1111_1110;
            1: BIT_SHIFT_OUT=8'b1111_1101;
            2: BIT_SHIFT_OUT=8'b1111_1011;
            3: BIT_SHIFT_OUT=8'b1111_0111;
            4: BIT_SHIFT_OUT=8'b1110_1111;
            5: BIT_SHIFT_OUT=8'b1101_1111;
            6: BIT_SHIFT_OUT=8'b1011_1111;
            7: BIT_SHIFT_OUT=8'b0111_1111;
            default: BIT_SHIFT_OUT=8'b1111_1111;
           
            endcase
            THREADING_REQ[location]= BIT_SHIFT_OUT;
        
         location=location+1;
             end
       
         bit_no=bit_no + 1;
       end
     if(bit_no==8)
        begin
        THREADING_REQ1=THREADING_REQ[0];
        THREADING_REQ1=THREADING_REQ[1];
        THREADING_REQ2=THREADING_REQ[2];
        THREADING_REQ3=THREADING_REQ[3];
        THREADING_REQ4=THREADING_REQ[4];
        THREADING_REQ5=THREADING_REQ[5];
        THREADING_REQ6=THREADING_REQ[6];
        THREADING_REQ7=THREADING_REQ[7];
          
        end
    end



endmodule




module PCI();
endmodule

module tb_RTH();
reg[7:0]in;
wire [7:0] out0,out1,out2,out3,out4,out5,out6,out7;
reg z=0;
reg[7:0] y=8'b1111_1111;
initial
begin
$monitor( "REQ = %b   out0 = %b out1 = %b out2 = %b out3 = %b out4 = %b  out5 = %b out6 = %b out7 = %b " , in,out0,out1,out2,out3,out4,out5,out6,out7 );
in=8'b1111_1111;
#5

$display(y);
if(y[z]==1)
begin
y[z]=1'b0;
end
#5
$display(y[z]);
in=8'b0000_0010;


end
REQ_THREADER a1(in,out0,out1,out2,out3,out4,out5,out6,out7);


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



module tb_fcfs();

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


arbiter_FCFS arbiter_test(GNT,REQ,FRAME,clk,RST);
endmodule