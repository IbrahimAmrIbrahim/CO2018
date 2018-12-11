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


module memory(IN0,IN1,IN2,IN3,IN4,IN5,IN6,IN7,OUT1,ENABLE);
input [7:0] IN0,IN1,IN2,IN3,IN4,IN5,IN6,IN7;
output reg [7:0] OUT1;
input ENABLE;
reg [7:0]MEGA_MIND[0:7];
reg IN0_FLAG,IN1_FLAG,IN2_FLAG,IN3_FLAG,IN4_FLAG,IN5_FLAG,IN6_FLAG,IN7_FLAG;
//flag1 equals ex
reg first_time;
reg [2:0]free_location;
always@(ENABLE)
begin

 
 if(1)
 begin
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
    OUT1=MEGA_MIND[free_location];// megamind
 end
 
 else
 begin
  if(1)
    begin
    casez(IN0)
    MEGA_MIND[0]: ;
    MEGA_MIND[1]: ;
    MEGA_MIND[2]: ;
    MEGA_MIND[3]: ;
    MEGA_MIND[4]: ;
    MEGA_MIND[5]: ;
    MEGA_MIND[6]: ;
    MEGA_MIND[7]: ;
    default:IN0_FLAG=0;
    endcase
    end
    
    
    casez(IN1)
    MEGA_MIND[0]:IN1_FLAG=1;
    MEGA_MIND[1]:IN1_FLAG=1;
    MEGA_MIND[2]:IN1_FLAG=1;
    MEGA_MIND[3]:IN1_FLAG=1;
    MEGA_MIND[4]:IN1_FLAG=1;
    MEGA_MIND[5]:IN1_FLAG=1;
    MEGA_MIND[6]:IN1_FLAG=1;
    MEGA_MIND[7]:IN1_FLAG=1;
    default:IN1_FLAG=0;
    
    endcase
    
      
    casez(IN2)
    MEGA_MIND[0]:IN2_FLAG=1;
    MEGA_MIND[1]:IN2_FLAG=1;
    MEGA_MIND[2]:IN2_FLAG=1;
    MEGA_MIND[3]:IN2_FLAG=1;
    MEGA_MIND[4]:IN2_FLAG=1;
    MEGA_MIND[5]:IN2_FLAG=1;
    MEGA_MIND[6]:IN2_FLAG=1;
    MEGA_MIND[7]:IN2_FLAG=1;
    default:IN2_FLAG=0;
    endcase
    
    casez(IN3)
    MEGA_MIND[0]:IN3_FLAG=1;
    MEGA_MIND[1]:IN3_FLAG=1;
    MEGA_MIND[2]:IN3_FLAG=1;
    MEGA_MIND[3]:IN3_FLAG=1;
    MEGA_MIND[4]:IN3_FLAG=1;
    MEGA_MIND[5]:IN3_FLAG=1;
    MEGA_MIND[6]:IN3_FLAG=1;
    MEGA_MIND[7]:IN3_FLAG=1;
    default:IN3_FLAG=0;
    endcase
      
    casez(IN4)
    MEGA_MIND[0]:IN4_FLAG=1;
    MEGA_MIND[1]:IN4_FLAG=1;
    MEGA_MIND[2]:IN4_FLAG=1;
    MEGA_MIND[3]:IN4_FLAG=1;
    MEGA_MIND[4]:IN4_FLAG=1;
    MEGA_MIND[5]:IN4_FLAG=1;
    MEGA_MIND[6]:IN4_FLAG=1;
    MEGA_MIND[7]:IN4_FLAG=1;
    default:IN4_FLAG=0;
    endcase
      
    casez(IN5)
    MEGA_MIND[0]:IN5_FLAG=1;
    MEGA_MIND[1]:IN5_FLAG=1;
    MEGA_MIND[2]:IN5_FLAG=1;
    MEGA_MIND[3]:IN5_FLAG=1;
    MEGA_MIND[4]:IN5_FLAG=1;
    MEGA_MIND[5]:IN5_FLAG=1;
    MEGA_MIND[6]:IN5_FLAG=1;
    MEGA_MIND[7]:IN5_FLAG=1;
    default:IN5_FLAG=0;
    endcase
      
    casez(IN6)
    MEGA_MIND[0]:IN6_FLAG=1;
    MEGA_MIND[1]:IN6_FLAG=1;
    MEGA_MIND[2]:IN6_FLAG=1;
    MEGA_MIND[3]:IN6_FLAG=1;
    MEGA_MIND[4]:IN6_FLAG=1;
    MEGA_MIND[5]:IN6_FLAG=1;
    MEGA_MIND[6]:IN6_FLAG=1;
    MEGA_MIND[7]:IN6_FLAG=1;
    default:IN6_FLAG=0;
    
    endcase
      
    casez(IN7)
    MEGA_MIND[0]:IN7_FLAG=1;
    MEGA_MIND[1]:IN7_FLAG=1;
    MEGA_MIND[2]:IN7_FLAG=1;
    MEGA_MIND[3]:IN7_FLAG=1;
    MEGA_MIND[4]:IN7_FLAG=1;
    MEGA_MIND[5]:IN7_FLAG=1;
    MEGA_MIND[6]:IN7_FLAG=1;
    MEGA_MIND[7]:IN7_FLAG=1;
    default:IN7_FLAG=0;
    endcase
    
 end

end

endmodule




module PCI();
endmodule

module tb_RTH_AND_MEMORY();
reg[7:0]in;
wire [7:0] out0,out1,out2,out3,out4,out5,out6,out7,gnt_out;
reg z=0;
reg[7:0] y=8'b1111_1111;
initial
begin
$monitor( "REQ = %b   out0 = %b out1 = %b out2 = %b out3 = %b out4 = %b  out5 = %b out6 = %b out7 = %b  gnt_out= %b" , in,out0,out1,out2,out3,out4,out5,out6,out7,gnt_out );
in=8'b1111_1111;
#5

#5
$display("---------");
#5
$display("--------");
in=8'b0000_0100;



end
REQ_THREADER a1(in,out0,out1,out2,out3,out4,out5,out6,out7);
//memory a2(out0,out1,out2,out3,out4,out5,out6,out7,gnt_out,1);

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