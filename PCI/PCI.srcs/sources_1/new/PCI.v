`timescale 1ns / 1ps

module device_A(CLK, RST_N, AD, CBE_N, FRAME_N, IRDY_N, TRDY_N, DEVSEL_N, REQ_N, GNT_N, FORCED_REQ_N, FORCED_ADDRESS, FORCED_CBE_N);

parameter MyAddress = 32'hAA, TargetAddress = 32'hBC;
parameter AssertedMaster = 4'b0000, GrantGiven = 4'b0001, FrameAsserted = 4'b0010;
parameter DataPhase1 = 4'b0011, DataPhase2 = 4'b0100, DataPhase3 = 4'b0101, DataPhase4 = 4'b0110, DataPhase5 = 4'b0111;

input CLK, RST_N, GNT_N, FORCED_REQ_N;
input [31:0] FORCED_ADDRESS;
input [3:0] FORCED_CBE_N;
inout [31:0] AD;	
inout [3:0] CBE_N;
inout FRAME_N, IRDY_N, TRDY_N, DEVSEL_N; 
output REQ_N;
reg [31:0] ADreg; 
reg [3:0] CBE_Nreg; 
reg [3:0] Status = 0;
reg FRAME_Nreg, IRDY_Nreg, TRDY_Nreg, DEVSEL_Nreg;
reg MasterFlag = 0, GNTFlag = 0, ReadFlag = 0, WriteFlag = 0;
reg [31:0] value1;
reg [31:0] value2;
reg [31:0] value3;
reg [31:0] value4;

reg [31:0] memory [0:9];
initial
memory [9] = 32'hAAAA_AAAA; 

assign REQ_N = FORCED_REQ_N;

assign AD      = ADreg;	        assign CBE_N    = CBE_Nreg;
assign FRAME_N = FRAME_Nreg;	assign IRDY_N   = IRDY_Nreg;
assign TRDY_N  = TRDY_Nreg;	    //assign DEVSEL_N = DEVSEL_Nreg;

always @ (posedge CLK, RST_N)
    if (!RST_N)
        begin
         ADreg = {(32){1'bz}} ; CBE_Nreg = 4'bzzzz ; FRAME_Nreg = 1; IRDY_Nreg = 1; TRDY_Nreg = 1; DEVSEL_Nreg = 1;
         MasterFlag = 0;   
        end
    else
	begin 
        if(!REQ_N || MasterFlag) //Then Device is Master
        begin 
        MasterFlag = 1;
            case (Status)
                AssertedMaster:
                        begin 
                            if(!GNT_N)
                            begin
                                GNTFlag = 1;
                                Status <= GrantGiven;
                            end
                            else
                                GNTFlag = 0;    
                        end
                GrantGiven:
                        begin
                            FRAME_Nreg <= 0;
                            ADreg    <= FORCED_ADDRESS;
                            CBE_Nreg <= FORCED_CBE_N;
                            Status   <= FrameAsserted;
                        end
                FrameAsserted:
                        begin 
                            IRDY_Nreg <= 0;

                            if (CBE_N == 4'b0110)       //Read Operation
                                begin
                                    ReadFlag <= 1;
                                    ADreg    <= {(32){1'bz}};
                                    CBE_Nreg <= 4'b0000;
                                    Status   <= DataPhase1;
                                end
                            else if (CBE_N == 4'b0111) // Write Operation
                                begin
                                    WriteFlag = 1;
                                    ADreg    <= memory[9];
                                    CBE_Nreg <= 4'b0000;    // Also Write's operation Dataphase 1
                                end
                        end
                DataPhase1:
                        begin
                            if (ReadFlag)
                            begin
                                memory [0] = FORCED_ADDRESS;
                                ADreg <= memory [0];    //for debuging
                                if(!DEVSEL_N)
                                    Status <= DataPhase2;
                                else
                                if(!GNT_N)
                                    if (!REQ_N)
                                        MasterFlag = 1;
                                    else
                                        begin 
                                            MasterFlag <= 0;
                                            FRAME_Nreg <= 1;
                                            IRDY_Nreg  <= 1;
                                        end
                            end
                            else if (WriteFlag)
                                begin 
                                end
                        end
                DataPhase2:
                        begin
                            if (ReadFlag)
                            begin
                                memory [1]= FORCED_ADDRESS;
                                ADreg <= memory [1];    //for debuging
                                if(!DEVSEL_N)
                                    Status <= DataPhase3;
                                else
                                if(!GNT_N)
                                    if (!REQ_N)
                                        MasterFlag = 1;
                                    else
                                        begin 
                                            MasterFlag <= 0;
                                            FRAME_Nreg <= 1;
                                            IRDY_Nreg  <= 1;
                                        end
                            end
                            else if (WriteFlag)
                                begin 
                                end
                        end
                DataPhase3:
                        begin 
                            if (ReadFlag)
                            begin
                                memory [2]= FORCED_ADDRESS;
                                ADreg <= memory [2];    //for debuging
                                if(!DEVSEL_N)
                                    Status <= DataPhase4;
                                else            // if operation with target is Done check for another Transaction request before Rising Frame 
                                if(!GNT_N)
                                    if (!REQ_N)
                                        MasterFlag = 1;
                                    else
                                        begin 
                                            MasterFlag <= 0;
                                            FRAME_Nreg <= 1;
                                            IRDY_Nreg  <= 1;
                                        end
                            end
                            else if (WriteFlag)
                                begin 
                                end
                        end
                DataPhase4:
                        begin 
                            if (ReadFlag)
                            begin
                                memory [3]= FORCED_ADDRESS;
                                ADreg <= memory [3];    //for debuging
                                if(!DEVSEL_N)
                                    Status <= DataPhase5;
                                else
                                if(!GNT_N)
                                    if (!REQ_N)
                                        MasterFlag = 1;
                                    else
                                        begin 
                                            MasterFlag <= 0;
                                            FRAME_Nreg <= 1;
                                            IRDY_Nreg  <= 1;
                                        end
                            end
                            else if (WriteFlag)
                                begin 
                                end
                        end
                DataPhase5:         // Test Phase
                        begin
                        end   
                default : /* default */;
            endcase
        end
        else begin
            if(AD == MyAddress && IRDY_N)
                DEVSEL_Nreg <= 0;
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

reg [2:0] counter;

always @(posedge clk)
begin
    if(~RST_Neg)
    begin
        GNT_Neg <= 8'b1111_1111;
        counter <= 3'b000;
    end
    else if(FRAME_Neg)
    begin
        case(counter)
            3'b000:
                begin
                    casez(REQ_Neg)
                        8'bzzzz_zzz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                        8'bzzzz_zz01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                        8'bzzzz_z011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                        8'bzzzz_0111:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                        8'bzzz0_1111:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                        8'bzz01_1111:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                        8'bz011_1111:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                        8'b0111_1111:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                        default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b000; end
                    endcase
                end
            3'b001:
                begin
                    casez(REQ_Neg)
                        8'bzzzz_zz0z:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                        8'bzzzz_z01z:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                        8'bzzzz_011z:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                        8'bzzz0_111z:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                        8'bzz01_111z:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                        8'bz011_111z:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                        8'b0111_111z:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                        8'b1111_1110:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                        default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b001; end
                    endcase
                end
            3'b010:
                begin
                    casez(REQ_Neg)
                        8'bzzzz_z0zz:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                        8'bzzzz_01zz:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                        8'bzzz0_11zz:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                        8'bzz01_11zz:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                        8'bz011_11zz:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                        8'b0111_11zz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                        8'b1111_11z0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                        8'b1111_1101:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                        default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b010; end
                    endcase
                end
            3'b011:
                begin
                    casez(REQ_Neg)
                        8'bzzzz_0zzz:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                        8'bzzz0_1zzz:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                        8'bzz01_1zzz:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                        8'bz011_1zzz:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                        8'b0111_1zzz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                        8'b1111_1zz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                        8'b1111_1z01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                        8'b1111_1011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                        default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b011; end
                    endcase                
                end
            3'b100:
                begin
                    casez(REQ_Neg)
                    8'bzzz0_zzzz:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                    8'bzz01_zzzz:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                    8'bz011_zzzz:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                    8'b0111_zzzz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                    8'b1111_zzz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                    8'b1111_zz01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                    8'b1111_z011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                    8'b1111_0111:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                    default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b100; end
                endcase                
                end
            3'b101:
                begin
                    casez(REQ_Neg)
                    8'bzz0z_zzzz:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                    8'bz01z_zzzz:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                    8'b011z_zzzz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                    8'b111z_zzz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                    8'b111z_zz01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                    8'b111z_z011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                    8'b111z_0111:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                    8'b1110_1111:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                    default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b101; end
                endcase                
                end
            3'b110:
                begin
                    casez(REQ_Neg)
                    8'bz0zz_zzzz:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                    8'b01zz_zzzz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                    8'b11zz_zzz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                    8'b11zz_zz01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                    8'b11zz_z011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                    8'b11zz_0111:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                    8'b11z0_1111:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                    8'b1101_1111:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                    default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b110; end
                endcase               
                end
            3'b111:
                begin
                    casez(REQ_Neg)
                    8'b0zzz_zzzz:begin GNT_Neg <= 8'b0111_1111; counter = 3'b000; end
                    8'b1zzz_zzz0:begin GNT_Neg <= 8'b1111_1110; counter = 3'b001; end
                    8'b1zzz_zz01:begin GNT_Neg <= 8'b1111_1101; counter = 3'b010; end
                    8'b1zzz_z011:begin GNT_Neg <= 8'b1111_1011; counter = 3'b011; end
                    8'b1zzz_0111:begin GNT_Neg <= 8'b1111_0111; counter = 3'b100; end
                    8'b1zz0_1111:begin GNT_Neg <= 8'b1110_1111; counter = 3'b101; end
                    8'b1z01_1111:begin GNT_Neg <= 8'b1101_1111; counter = 3'b110; end
                    8'b1011_1111:begin GNT_Neg <= 8'b1011_1111; counter = 3'b111; end
                    default: begin GNT_Neg <= 8'b1111_1111; counter = 3'b111; end
                endcase                
                end
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

// thread the input depending on the zeros, all 1=> all1 and arragne them with piorty
module REQ_THREADER(REQ,THREADING_REQ0,THREADING_REQ1,THREADING_REQ2,THREADING_REQ3,THREADING_REQ4,THREADING_REQ5,THREADING_REQ6,THREADING_REQ7,MEMORY_ENABLE);
//request output only 1 time
input [7:0]REQ;
output MEMORY_ENABLE;
output reg [7:0]THREADING_REQ0;
output reg [7:0]THREADING_REQ1;
output reg [7:0]THREADING_REQ2;
output reg [7:0]THREADING_REQ3;
output reg [7:0]THREADING_REQ4;
output reg [7:0]THREADING_REQ5;
output reg [7:0]THREADING_REQ6;
output reg [7:0]THREADING_REQ7;
reg [7:0]THREADING_REQ[0:7]; // memory
reg flag;// finished all if
reg [2:0] step,location,free_location;
//if 0 get out 
//if all 1 output =1111_1111

always@(*)
    begin
    
 
     flag=0;
     step=0;
     location=0;
        if(flag==0)
        begin
        
        
        if(step==0)
        begin
        if(REQ[0]==1'b0)
        begin
        THREADING_REQ[location]= 8'b1111_1110;  
    
        location=location+1;
        end
        
           step=step+1;
        end
        
        if(step==1)
        begin
        if(REQ[1]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b1111_1101;  
        location=location+1;
        end
            step=step+1; 
        
        end
        
        if(step==2)
        begin
        if(REQ[2]==1'b0)
        begin
        
        
        THREADING_REQ[location]= 8'b1111_1011;
        location=location+1;
        end
           step=step+1;
        
        
        
        end
        
        if(step==3)
        begin
        if(REQ[3]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b1111_0111;
        location=location+1;
        end
            step=step+1;
        end
        
        if(step==4)
        begin
        if(REQ[4]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b1110_1111;
        location=location+1;
        end
           step=step+1;
        end
        
        if(step==5)
        begin
        if(REQ[5]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b1101_1111;
        location=location+1;
        end
           step=step+1;
        end
        
        if(step==6)
        begin
        if(REQ[6]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b1011_1111;
        location=location+1;
        end
           step=step+1;
        end
        
        if(step==7)
        begin
        if(REQ[7]==1'b0)
        begin
        
        THREADING_REQ[location]= 8'b0111_1111;
       location=location+1;
        
        end
           step=step+1;
        end

        free_location=location;
      
        case(free_location)
        0: begin
        THREADING_REQ[0]= 8'b1111_1111 ;
          THREADING_REQ[1]= 8'b1111_1111 ;
            THREADING_REQ[2]= 8'b1111_1111 ;
              THREADING_REQ[3]= 8'b1111_1111 ;
                THREADING_REQ[4]= 8'b1111_1111 ;
                  THREADING_REQ[5]= 8'b1111_1111 ;
                    THREADING_REQ[6]= 8'b1111_1111 ;
                      THREADING_REQ[7]= 8'b1111_1111 ;
        end
        
        1:begin
         THREADING_REQ[1]= 8'b1111_1111 ;
               THREADING_REQ[2]= 8'b1111_1111 ;
                 THREADING_REQ[3]= 8'b1111_1111 ;
                   THREADING_REQ[4]= 8'b1111_1111 ;
                     THREADING_REQ[5]= 8'b1111_1111 ;
                       THREADING_REQ[6]= 8'b1111_1111 ;
                         THREADING_REQ[7]= 8'b1111_1111 ;
        end
        
        2:begin
       THREADING_REQ[2]= 8'b1111_1111 ;          
          THREADING_REQ[3]= 8'b1111_1111 ;        
            THREADING_REQ[4]= 8'b1111_1111 ;      
              THREADING_REQ[5]= 8'b1111_1111 ;    
                THREADING_REQ[6]= 8'b1111_1111 ;  
                  THREADING_REQ[7]= 8'b1111_1111 ;
        end
        
        3:begin
      THREADING_REQ[3]= 8'b1111_1111 ;        
          THREADING_REQ[4]= 8'b1111_1111 ;      
            THREADING_REQ[5]= 8'b1111_1111 ;    
              THREADING_REQ[6]= 8'b1111_1111 ;  
                THREADING_REQ[7]= 8'b1111_1111 ;
        end
        4:begin
        THREADING_REQ[4]= 8'b1111_1111 ;      
          THREADING_REQ[5]= 8'b1111_1111 ;    
            THREADING_REQ[6]= 8'b1111_1111 ;  
              THREADING_REQ[7]= 8'b1111_1111 ;
        end
        5:begin
          THREADING_REQ[5]= 8'b1111_1111 ;    
                  THREADING_REQ[6]= 8'b1111_1111 ;  
                    THREADING_REQ[7]= 8'b1111_1111 ;
        end
        6:begin
         THREADING_REQ[6]= 8'b1111_1111 ;  
                           THREADING_REQ[7]= 8'b1111_1111 ;
        end
       7:begin
        
                          THREADING_REQ[7]= 8'b1111_1111 ;
        end
       
      
        endcase
      
        flag=1;
        
        end
        

       
   if(flag==1)
       begin
            
            THREADING_REQ0=THREADING_REQ[0];
            THREADING_REQ1=THREADING_REQ[1];
            THREADING_REQ2=THREADING_REQ[2];
            THREADING_REQ3=THREADING_REQ[3];
            THREADING_REQ4=THREADING_REQ[4];
            THREADING_REQ5=THREADING_REQ[5];
            THREADING_REQ6=THREADING_REQ[6];
            THREADING_REQ7=THREADING_REQ[7];
        end      
        
    end

assign MEMORY_ENABLE=1;

endmodule


module memory(IN0,IN1,IN2,IN3,IN4,IN5,IN6,IN7,OUT1,CLK);
input [7:0] IN0,IN1,IN2,IN3,IN4,IN5,IN6,IN7;
output reg [7:0] OUT1;
input CLK;
reg [7:0]MEGA_MIND[0:7], shift_dumy[0:7],MEGA_DUMY[0:7];
reg IN0_FLAG,IN1_FLAG,IN2_FLAG,IN3_FLAG,IN4_FLAG,IN5_FLAG,IN6_FLAG,IN7_FLAG;
//flag1 equals ex
reg first_time,not_first_time;
reg [1:0]flag;
reg [2:0]free_location;


always@(posedge CLK)
begin

 if(first_time==1)
   begin
   
   
   casez(MEGA_MIND[7])
 
    IN0:;
    IN1:;
    IN2:;
    IN3:;
    IN4:;
    IN5:;
    IN6:;
    IN7:;
    default:
    begin
    MEGA_MIND[7]=8'b1111_1111;
    free_location=free_location-1;
    end
    
   endcase
 
    casez(MEGA_MIND[6])
  
      IN0:;
      IN1:;
      IN2:;
      IN3:;
      IN4:;
      IN5:;
      IN6:;
      IN7:;
      default:
      begin
      MEGA_MIND[6]=MEGA_MIND[7];
      MEGA_MIND[7]=8'b1111_1111;
      free_location=free_location-1;
      end
      
      
      endcase
      
      casez(MEGA_MIND[5])
          IN0:;
           IN1:;
           IN2:;
           IN3:;
           IN4:;
           IN5:;
           IN6:;
           IN7:;
           default:
           begin
          
           MEGA_MIND[5]=MEGA_MIND[6];
           MEGA_MIND[6]=MEGA_MIND[7];
           MEGA_MIND[7]=8'b1111_1111;
           free_location=free_location-1;
           end
         
         endcase
         
         casez(MEGA_MIND[4])
            IN0:;
                    IN1:;
                    IN2:;
                    IN3:;
                    IN4:;
                    IN5:;
                    IN6:;
                    IN7:;
                    default:
                    begin
                    MEGA_MIND[4]=MEGA_MIND[5];
                    MEGA_MIND[5]=MEGA_MIND[6];
                    MEGA_MIND[6]=MEGA_MIND[7];
                    MEGA_MIND[7]=8'b1111_1111;
                    free_location=free_location-1;
                    end
            
            endcase
            
            casez(MEGA_MIND[3])
                  IN0:;
                     IN1:;
                     IN2:;
                     IN3:;
                     IN4:;
                     IN5:;
                     IN6:;
                     IN7:;
                     default:
                     begin
                     MEGA_MIND[3]=MEGA_MIND[4];
                     MEGA_MIND[4]=MEGA_MIND[5];
                     MEGA_MIND[5]=MEGA_MIND[6];
                     MEGA_MIND[6]=MEGA_MIND[7];
                     MEGA_MIND[7]=8'b1111_1111;
                     free_location=free_location-1;
                     end
       
               endcase
               
               casez(MEGA_MIND[2])
                     IN0:;
                                 IN1:;
                                 IN2:;
                                 IN3:;
                                 IN4:;
                                 IN5:;
                                 IN6:;
                                 IN7:;
                                 default:
                                 begin
                                 MEGA_MIND[2]=MEGA_MIND[3];
                                 MEGA_MIND[3]=MEGA_MIND[4];
                                 MEGA_MIND[4]=MEGA_MIND[5];
                                 MEGA_MIND[5]=MEGA_MIND[6];
                                 MEGA_MIND[6]=MEGA_MIND[7];
                                 MEGA_MIND[7]=8'b1111_1111;
                                 free_location=free_location-1;
                                 end
                  
                  endcase
                  
                  casez(MEGA_MIND[1])
                        IN0:;
                        IN1:;
                        IN2:;
                        IN3:;
                        IN4:;
                        IN5:;
                        IN6:;
                        IN7:;
                        default:
                        begin
                        MEGA_MIND[1]=MEGA_MIND[2];
                        MEGA_MIND[2]=MEGA_MIND[3];
                        MEGA_MIND[3]=MEGA_MIND[4];
                        MEGA_MIND[4]=MEGA_MIND[5];
                        MEGA_MIND[5]=MEGA_MIND[6];
                        MEGA_MIND[6]=MEGA_MIND[7];
                        MEGA_MIND[7]=8'b1111_1111;
                        free_location=free_location-1;
                        end
                     
                     endcase
                     
                     casez(MEGA_MIND[0])
                           IN0:;
                           IN1:;
                           IN2:;
                           IN3:;
                           IN4:;
                           IN5:;
                           IN6:;
                           IN7:;
                           default:
                           begin
                           MEGA_MIND[0]=MEGA_MIND[1];
                           MEGA_MIND[1]=MEGA_MIND[2];
                           MEGA_MIND[2]=MEGA_MIND[3];
                           MEGA_MIND[3]=MEGA_MIND[4];
                           MEGA_MIND[4]=MEGA_MIND[5];
                           MEGA_MIND[5]=MEGA_MIND[6];
                           MEGA_MIND[6]=MEGA_MIND[7];
                           MEGA_MIND[7]=8'b1111_1111;
                           free_location=free_location-1;
                           end
                        
                        endcase
                           
             //CHECK MEMORY INSIDE THE NEW DATA  AND REMOVE THE UNFOUND REQUESTS
            //===================================================================\\
            
       
        casez(IN0)
        MEGA_MIND[0]: ;
        MEGA_MIND[1]: ;
        MEGA_MIND[2]: ;
        MEGA_MIND[3]: ;
        MEGA_MIND[4]: ;
        MEGA_MIND[5]: ;
        MEGA_MIND[6]: ;
        MEGA_MIND[7]: ;
        default:begin
        
      
        MEGA_MIND[free_location]=IN0;
        free_location=free_location+1;
        end
        endcase
                
        casez(IN1)
        
               MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin
        
      
        
        MEGA_MIND[free_location]=IN1;
        free_location=free_location+1;
        end
        endcase
                
        casez(IN2)
        
      MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin
        
        MEGA_MIND[free_location]=IN2;
        free_location=free_location+1;
        end
        endcase
        
        casez(IN3)
        
               MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin
        
        
     
        MEGA_MIND[free_location]=IN3;
        free_location=free_location+1;
        end
        endcase
        
        casez(IN4)
        
       MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin 
        
       
        MEGA_MIND[free_location]=IN4;
        free_location=free_location+1;
        end
        endcase
        
        casez(IN5)
        
      MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin
        
        
        

        MEGA_MIND[free_location]=IN5;
        free_location=free_location+1;
        end
        endcase
        
        casez(IN6)
        
        MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
        
        default:begin
        
        
        
        
        MEGA_MIND[free_location]=IN6;
        free_location=free_location+1;
        end
        
        endcase
        
        casez(IN7)
        
        MEGA_MIND[0]: ;
               MEGA_MIND[1]: ;
               MEGA_MIND[2]: ;
               MEGA_MIND[3]: ;
               MEGA_MIND[4]: ;
               MEGA_MIND[5]: ;
               MEGA_MIND[6]: ;
               MEGA_MIND[7]: ;
       
        default:begin
        if(free_location>7)
      
        MEGA_MIND[free_location]=IN7;  
                
        
        
        free_location=free_location+1;
        end
        
        endcase
       
        OUT1=MEGA_MIND[0];//=============
        MEGA_DUMY[0]=MEGA_MIND[0];
        MEGA_DUMY[1]=MEGA_MIND[1];
        MEGA_DUMY[2]=MEGA_MIND[2];
        MEGA_DUMY[3]=MEGA_MIND[3];
        MEGA_DUMY[4]=MEGA_MIND[4];
        MEGA_DUMY[5]=MEGA_MIND[5];
        MEGA_DUMY[6]=MEGA_MIND[6];
        MEGA_DUMY[7]=MEGA_MIND[7];   
        
        MEGA_MIND[0]=    MEGA_DUMY[1];
        MEGA_MIND[1]=    MEGA_DUMY[2];
        MEGA_MIND[2]=    MEGA_DUMY[3];
        MEGA_MIND[3]=    MEGA_DUMY[4];
        MEGA_MIND[4]=    MEGA_DUMY[5];
        MEGA_MIND[5]=    MEGA_DUMY[6];
        MEGA_MIND[6]=    MEGA_DUMY[7];
        MEGA_MIND[7]=    8'b1111_1111;
        if(OUT1!=8'b1111_1111)
      free_location=free_location-1;   
      
                    end
else
 begin

  first_time=1;
   
    free_location=0;
    MEGA_MIND[free_location]=IN0;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN1;
    free_location=free_location+1;  
    MEGA_MIND[free_location]=IN2;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN3;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN4;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN5;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN6;
    free_location=free_location+1;
    MEGA_MIND[free_location]=IN7;
    //reset the free location
    if(IN0==8'b1111_1111)
    free_location=0;
    else if(IN1==8'b1111_1111)
    free_location=1;
    else if(IN2==8'b1111_1111)
    free_location=2;
    else if(IN3==8'b1111_1111)
    free_location=3;
    else if(IN4==8'b1111_1111)
    free_location=4;
    else if(IN5==8'b1111_1111)
    free_location=5;
    else if(IN6==8'b1111_1111)
    free_location=6;
    else if(IN7==8'b1111_1111) 
    free_location=7;  
    OUT1=MEGA_MIND[0];//==========
    
    MEGA_DUMY[0]=MEGA_MIND[0];
    MEGA_DUMY[1]=MEGA_MIND[1];
    MEGA_DUMY[2]=MEGA_MIND[2];
    MEGA_DUMY[3]=MEGA_MIND[3];
    MEGA_DUMY[4]=MEGA_MIND[4];
    MEGA_DUMY[5]=MEGA_MIND[5];
    MEGA_DUMY[6]=MEGA_MIND[6];
    MEGA_DUMY[7]=MEGA_MIND[7];  
    MEGA_MIND[0]=    MEGA_DUMY[1];
    MEGA_MIND[1]=    MEGA_DUMY[2];
    MEGA_MIND[2]=    MEGA_DUMY[3];
    MEGA_MIND[3]=    MEGA_DUMY[4];
    MEGA_MIND[4]=    MEGA_DUMY[5];
    MEGA_MIND[5]=    MEGA_DUMY[6];
    MEGA_MIND[6]=    MEGA_DUMY[7];
    MEGA_MIND[7]=    8'b1111_1111;
    if(OUT1!=8'b1111_1111)
    free_location=free_location-1;
    
    end
    
    
    
   


end

endmodule

module PCI();
endmodule




module tb_RTH_AND_MEMORY();
reg[7:0]in;
reg clk;
wire [7:0]gnt_out,gnt_out2,fl;
reg [7:0] out0,out1,out2,out3,out4,out5,out6,out7;
reg z=0;
reg[7:0] y=8'b1111_1111;
initial
begin
$monitor( "  out0 = %b out1 = %b out2 = %b out3 = %b out4 = %b  out5 = %b out6 = %b out7 = %b  gnt_out= %b  gnt_out2=%b  fl=%d" ,out0,out1,out2,out3,out4,out5,out6,out7,gnt_out,gnt_out2,fl );
  clk <= 0;
$display("----0-----");
out0=8'b1111_1110;
out1=8'b1111_1101;
out2=8'b1111_1111;
out3=8'b1111_1111;
out4=8'b1111_1111;
out5=8'b1111_1111;
out6=8'b1111_1111;
out7=8'b1111_1111;
#30
$display("----1-----");
out0<=8'b1111_1111;
out1<=8'b1111_1111;
out2<=8'b1111_1111;
out3<=8'b1111_1111;
out4<=8'b1111_1111;
out5<=8'b1111_1111;
out6<=8'b1111_1111;
out7<=8'b1111_1111;

#30
$display("----2-----");
out0<=8'b1111_1011;
out1<=8'b1110_1111;
out2<=8'b0111_1111;
out3<=8'b1111_1111;
out4<=8'b1111_1111;
out5<=8'b1111_1111;
out6<=8'b1111_1111;
out7<=8'b1111_1111;
#30
$display("----3-----");
out0<=8'b1111_1011;
out1<=8'b1110_1111;
out2<=8'b1011_1111;
out3<=8'b0111_1111;
out4<=8'b1111_1111;
out5<=8'b1111_1111;
out6<=8'b1111_1111;
out7<=8'b1111_1111;
#30
$display("----4-----");
out0<=8'b1111_1110;
out1<=8'b1110_1111;
out2<=8'b0111_1111;
out3<=8'b1111_1111;
out4<=8'b1111_1111;
out5<=8'b1111_1111;
out6<=8'b1111_1111;
out7<=8'b1111_1111;
 

end
always
begin
    #15
    clk = ~clk;
end

memory a2(out0,out1,out2,out3,out4,out5,out6,out7,gnt_out,clk);



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
        #10
        REQ <= $urandom %8;
        //  RST <= $urandom %2;
    end
end

always
begin
    #25
    FRAME = ~FRAME;
end

always
begin
    #5
    clk = ~clk;
end


arbiter_priority arbiter_priority_test(GNT,REQ,FRAME,clk,RST);
endmodule

module tb_arbiter_RobinRound();

wire [7:0] GNT;
reg [7:0] REQ;
reg FRAME,clk,RST;

integer i;
initial
    begin
    $monitor($time ,, "REQ = %b  FRAME = %b  GNT = %b  RST = %b" , REQ , FRAME , GNT , RST);
    clk <= 0;
    RST <= 0;
    FRAME <= 1;
    #8
    RST <= 1;
    for(i = 0 ; i < 20 ; i = i + 1)
    begin
        #10
        REQ <= $urandom %8;
        //  RST <= $urandom %2;
    end
end

always
begin
    #25
    FRAME = ~FRAME;
end

always
begin
    #5
    clk = ~clk;
end


arbiter_RobinRound arbiter_RobinRound_test(GNT,REQ,FRAME,clk,RST);
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