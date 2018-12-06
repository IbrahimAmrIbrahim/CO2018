`timescale 1ns / 1ps
module PortA(DataBus,A,Sel,RD_bar,WR_bar,Reset,CS_bar);

inout [7:0] A;
inout [7:0] DataBus;
input [1:0] Sel;
reg[7:0]DB;
input RD_bar,WR_bar,Reset,CS_bar ;

reg op,mode,type,forceR;
reg phase;
reg dataenable;
  
always@(*)

begin
    if(Reset)
    begin
        forceR=1;
    end
    else
    begin
        forceR=0;
        if(~CS_bar)
        begin
            if(Sel==2'b11)        
            begin
                op=1;
                dataenable=1;
                if(DataBus[7] ==1 && DataBus[4] == 1  && DataBus[6] == 0 && DataBus[5] == 0)
                begin
                    phase<=0;
                    type <=0;
                end
                else if (DataBus[7] == 1 && DataBus[4] == 0 && DataBus[6] == 0 && DataBus[5] == 0)
                begin
                    phase<=0;
                    type<=1;
                end
                if (DataBus[7] == 0)
                begin
                    phase<=1;
                end
             end             
             else if (Sel==2'b00)
             begin
                op=0;
                if(~RD_bar)
                begin
                    dataenable=0;
                    mode=0;
                end
                else if (~WR_bar)
                begin
                    dataenable=1;
                    mode=1;
                end
            end                 
        end
     end
end

assign A = (forceR)? 8'bzzzz_zzzz : (phase)? A : (op)? (type)? (mode)? A : 8'b0000_0000 : 8'bzzzz_zzzz :(mode)? (type)? DataBus :A : (type)? A : 8'bzzzz_zzzz;
assign DataBus = (dataenable)? 8'bzzzz_zzzz  : A  ;

endmodule

module PortB(DataBus,B,Sel,RD_bar,WR_bar,Reset,CS_bar);
inout [7:0] B;
inout [7:0] DataBus;
input [1:0] Sel;
reg[7:0]DB;
input RD_bar,WR_bar,Reset,CS_bar ;
reg op,mode,type,forceR;
reg phase;
reg dataenable;
  
always@(*)

begin
    if(Reset)
    begin
        forceR=1;
    end
    else
    begin
        forceR=0;
        if(~CS_bar)
        begin
            if(Sel==2'b11)
            begin
                op=1;
                dataenable=1;
                if(DataBus[7] ==1 && DataBus[1] == 1  && DataBus[6] == 0 && DataBus[5] == 0)
                begin
                    phase<=0;
                    type <=0;
                end
                else if (DataBus[7] == 1 && DataBus[1] == 0 && DataBus[6] == 0 && DataBus[5] == 0)
                begin
                    phase<=0;
                    type<=1;
                end
                if (DataBus[7] == 0)
                begin
                    phase<=1;
                end
            end
            else if (Sel==2'b00)
            begin
                op=0;
                if(~RD_bar)
                begin
                    dataenable=0;
                    mode=0;
                end
                else if (~WR_bar)
                begin
                    dataenable=1;
                    mode=1;
                end
            end
        end
    end
end

assign B = (forceR)? 8'bzzzz_zzzz : (phase)? B : (op)? (type)? (mode)? B : 8'b0000_0000 : 8'bzzzz_zzzz : (mode)? (type)? DataBus : B : (type)? B : 8'bzzzz_zzzz;
assign DataBus = (dataenable)? 8'bzzzz_zzzz  : B;

endmodule

module PortUC(DataBus,C,Sel,RD_bar,WR_bar,Reset,CS_bar);

inout [3:0] C;
inout [7:0] DataBus;
input [1:0] Sel;
input RD_bar,WR_bar,Reset,CS_bar;
reg [1:0] ctrl;
reg [3:0] Port; 
reg mode;
/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign DataBus = (ctrl[0])? ({C,DataBus[3:0]}) : 8'bzzzz_zzzz;
assign C = (ctrl[1])? Port : 4'bzzzz;

always @(*)
begin
    if(Reset)
    begin
        ctrl[0] <= 0;
        ctrl[1] <= 0;
        mode <= 0;
        Port <= 4'b0000;
    end
    else if(~CS_bar)
    begin
        if (Sel == 2'b10)
        begin
            if((ctrl[1] == 0) && (~RD_bar) && (~mode))
            begin
               ctrl[0] <= 1;
            end
            else if((ctrl[1] == 1) && (~WR_bar) && (~mode))
            begin
               ctrl[0] <= 0; 
               Port <= DataBus[7:4];
            end
            else
            begin
               ctrl[0] <= 0;
            end
        end
        else if(Sel == 2'b11)
        begin
            if(~WR_bar)
            begin
                ctrl[0] <= 0;
                if (DataBus[7] == 1)
                begin
                    if(DataBus[5] == 0 && DataBus[6] == 0)
                    begin
                        ctrl[1] <= ~DataBus[3];
                        mode <= 0;
                    end
                    else
                    begin
                        mode <= 1;
                    end
                end    
                else
                begin
                    ctrl[1] <= 1;
                    case({DataBus[3],DataBus[2],DataBus[1]})
                        3'b100: Port <= {Port[3:1] , DataBus[0]};
                        3'b101: Port <= {Port[3:2] , DataBus[0] , Port[0]};
                        3'b110: Port <= {Port[3] , DataBus[0] , Port[1:0]};
                        3'b111: Port <= {DataBus[0] , Port[3:0]};
                    endcase
                end
            end    
        end
    end
    else
    begin
        ctrl[0] <= 0;
    end
end

endmodule

module PortLC(DataBus,C,Sel,RD_bar,WR_bar,Reset,CS_bar);

inout [3:0] C;
inout [7:0] DataBus;
input [1:0] Sel;
input RD_bar,WR_bar,Reset,CS_bar;
reg [1:0] ctrl;
reg [3:0] Port; 
reg mode;

/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign DataBus = (ctrl[0])? ({DataBus[7:4],C}) : 8'bzzzz_zzzz;
assign C = (ctrl[1])? Port : 4'bzzzz;

always @(*)
begin
    if(Reset)
    begin
     ctrl[0] <= 0;
     ctrl[1] <= 0;
     mode <= 0;
     Port <= 4'b0000;
    end
    else if(~CS_bar)
    begin
        if (Sel == 2'b10)
        begin
            if((ctrl[1] == 0) && (~RD_bar) && (~mode))
            begin
               ctrl[0] <= 1;
            end
            else if((ctrl[1] == 1) && (~WR_bar) && (~mode))
            begin
               ctrl[0] <= 0; 
               Port <= DataBus[3:0];
            end
            else
            begin
               ctrl[0] <= 0;
            end
        end
        else if(Sel == 2'b11)
        begin
            if(~WR_bar)
            begin
                ctrl[0] <= 0;
                if(DataBus[7] == 1)
                begin
                    if(DataBus[2] == 0)
                    begin
                        ctrl[1] <= ~DataBus[0];
                        mode <= 0;
                    end
                    else
                    begin
                        mode <=1;
                    end
                end
                else
                begin
                    ctrl[1] <= 1;
                    case({DataBus[3],DataBus[2],DataBus[1]})
                        3'b000: Port <= {Port[3:1] , DataBus[0]};
                        3'b001: Port <= {Port[3:2] , DataBus[0] , Port[0]};
                        3'b010: Port <= {Port[3] , DataBus[0] , Port[1:0]};
                        3'b011: Port <= {DataBus[0] , Port[2:0]};
                     endcase
                end
            end    
        end
    end
    else
    begin
        ctrl[0] <= 0;
    end
end

endmodule

module DataBusBuffer(DataBus,D,RD_bar,WR_bar,Reset,CS_bar);
inout [7:0] D;
inout [7:0] DataBus;
input RD_bar,WR_bar,Reset,CS_bar ;
reg [1:0] ctrl;
/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign DataBus = (ctrl[0])? D : 8'bzzzz_zzzz;
assign D = (ctrl[1])? DataBus : 8'bzzzz_zzzz;

always @(*)
begin
    if(~Reset && ~CS_bar)
    begin
        if(~RD_bar)
        begin
            ctrl[0] <= 0;
            ctrl[1] <= 1;
        end
        else if(~WR_bar)
        begin
            ctrl[0] <= 1; 
            ctrl[1] <= 0;
        end
        else
        begin
            ctrl[0] <= 0;
            ctrl[1] <= 0;
        end
    end
    else
    begin 
        ctrl[0] <= 0;
        ctrl[1] <= 0;
    end
end
endmodule

module PPI(PortA,PortB,PortC,D,Sel,RD_bar,WR_bar,Reset,CS_bar);

inout [7:0] PortA,PortB,PortC,D;
input [1:0] Sel;
input RD_bar,WR_bar,Reset,CS_bar;
wire [7:0] DataBus;

PortA A1(DataBus,PortA,Sel,RD_bar,WR_bar,Reset,CS_bar);
PortB B1(DataBus,PortB,Sel,RD_bar,WR_bar,Reset,CS_bar);
PortUC UC1(DataBus,PortC[7:4],Sel,RD_bar,WR_bar,Reset,CS_bar);
PortLC LC1(DataBus,PortC[3:0],Sel,RD_bar,WR_bar,Reset,CS_bar);
DataBusBuffer DDB1(DataBus,D,RD_bar,WR_bar,Reset,CS_bar);

endmodule

module PortA_tb();

reg RD , WR , CS , Reset;
reg [1:0] Sel;
wire [7:0] DataBus_pins,A_pins;
reg [1:0] ctrl;
reg [7:0] DataBus_data , A_data;

/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign A_pins = (ctrl[0])? A_data : 8'bzzzz_zzzz;
assign DataBus_pins = (ctrl[1])? DataBus_data: 8'bzzzz_zzzz;

initial
begin
$monitor($time ,, "CS=%b RD=%b WR=%b Sel=%b Reset=%b C=%b DataBus=%b", CS , RD , WR , Sel , Reset , A_pins , DataBus_pins);
$display("Reset");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 1;
#5
$display("Nothing");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("chip select");
    ctrl <= 2'b00;
    CS <= 0;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("Wrong Read confg");
    DataBus_data <= 8'b1001_xxxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    A_data <= 8'b1010_1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read confg");
    DataBus_data <= 8'b1001_xxxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    A_data <= 8'b1010_1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("write confg");
    DataBus_data <= 8'b1000_xxxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
#5
$display("write");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("BSR");
    DataBus_data <= 8'b0000_0011;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
#5
$display("error Read & write signal");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("nothing");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("Reset");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;

end
PortA A1(DataBus_pins,A_pins,Sel,RD,WR,Reset,CS);

endmodule

module PortB_tb();

reg RD , WR , CS , Reset;
reg [1:0] Sel;
wire [7:0] DataBus_pins,B_pins;
reg [1:0] ctrl;
reg [7:0] DataBus_data , B_data;

/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign B_pins = (ctrl[0])? B_data : 8'bzzzz_zzzz;
assign DataBus_pins = (ctrl[1])? DataBus_data: 8'bzzzz_zzzz;

initial
begin
$monitor($time ,, "CS=%b RD=%b WR=%b Sel=%b Reset=%b C=%b DataBus=%b", CS , RD , WR , Sel , Reset , B_pins , DataBus_pins);
$display("Reset");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 1;
#5
$display("Nothing");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("chip select");
    ctrl <= 2'b00;
    CS <= 0;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("Wrong Read confg");
    DataBus_data <= 8'b1xxx_x11x;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    B_data <= 8'b1010_1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read confg");
    DataBus_data <= 8'b1xxx_x01x;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    B_data <= 8'b1010_1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("write confg");
    DataBus_data <= 8'b1xxx_x00x;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
#5
$display("write");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("BSR");
    DataBus_data <= 8'b0000_0011;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
#5
$display("error Read & write signal");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("nothing");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b00;
    Reset <= 0;
#5
$display("Reset");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;

end
PortB B_t(DataBus_pins,B_pins,Sel,RD,WR,Reset,CS);

endmodule

module DataBusBuffer_tb();
reg RD , WR , CS , Reset;
wire [7 : 0] D , DataBus;

assign D = (~RD)? 8'b zzzz_zzzz : 8'b 1111_1111;
assign DataBus = (~RD)? 8'b 0101_0101 :  8'b zzzz_zzzz;

initial
begin
$monitor($time , "CS=%b RD=%b WR=%b Reset=%b D=%b DataBus=%b", CS , RD , WR , Reset , D , DataBus);
$display("Reset");
    WR <= 1;
    RD <= 1;
    Reset <= 1;
    CS <= 1;
#5
$display("Nothing");
    WR <= 1;
    RD <= 1;
    Reset <= 0;
    CS <= 1;
#5
$display("chip select");
    WR <= 1;
    RD <= 1;
    Reset <= 0;
    CS <= 0;
#5
$display("write");
    WR <= 0;
    RD <= 1;
    Reset <= 0;
    CS <= 0;
#5
$display("Read");
    WR <= 1;
    RD <= 0;
    Reset <= 0;
    CS <= 0;
#5
$display("nothing");
    WR <= 1;
    RD <= 1;
    Reset <= 0;
    CS <= 1;
#5
$display("chip unselect");
    WR <= 1;
    RD <= 1;
    Reset <= 0;
    CS <= 0;
end

DataBusBuffer DBB_t(DataBus,D,RD,WR,Reset,CS);

endmodule

module PortUC_tb();
reg RD , WR , CS , Reset;
reg [1:0] Sel;
wire [3 : 0] C_pins;
wire [7:0] DataBus_pins;
reg [1:0] ctrl;
reg [3 : 0] C_data;
reg [7:0] DataBus_data;

/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign C_pins = (ctrl[0])? C_data : 4'bzzzz;
assign DataBus_pins = (ctrl[1])? DataBus_data: 8'bzzzz_zzzz;

initial
begin
$monitor($time ,, "CS=%b RD=%b WR=%b Sel=%b Reset=%b C=%b DataBus=%b", CS , RD , WR , Sel , Reset , C_pins , DataBus_pins);
$display("Reset");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;
#5
$display("Nothing");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("chip select");
    ctrl <= 2'b00;
    CS <= 0;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("Wrong Read confg");
    DataBus_data <= 8'b101x_1xxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    C_data <= 4'b1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read confg");
    DataBus_data <= 8'b100x_1xxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11; 
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    C_data <= 4'b1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("write confg");
    DataBus_data <= 8'b100x_0xxx;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
#5
$display("write");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("error Read & write signal");
    DataBus_data <= 8'b1111_0000;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("nothing");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("Reset");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;
#5
$display("BSR");
    DataBus_data <= 8'b0000_1011;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;  
 end

PortUC UC_t(DataBus_pins,C_pins,Sel,RD,WR,Reset,CS);

endmodule

module PortLC_tb();
reg RD , WR , CS , Reset;
reg [1:0] Sel;
wire [3 : 0] C_pins;
wire [7:0] DataBus_pins;
reg [1:0] ctrl;
reg [3 : 0] C_data;
reg [7:0] DataBus_data;

/*
Read  --> ctrl = 01
Write --> ctrl = 10
*/

assign C_pins = (ctrl[0])? C_data : 4'b zzzz;
assign DataBus_pins = (ctrl[1])? DataBus_data: 8'bzzzz_zzzz;

initial
begin
$monitor($time ,, "CS=%b RD=%b WR=%b Sel=%b Reset=%b C=%b DataBus=%b", CS , RD , WR , Sel , Reset , C_pins , DataBus_pins);
$display("Reset");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;
#5
$display("Nothing");
    ctrl <= 2'b00;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("chip select");
    ctrl <= 2'b00;
    CS <= 0;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("Wrong Read confg");
    DataBus_data <= 8'b1xxx_x1x1;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    C_data <= 4'b1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read confg");
    DataBus_data <= 8'b1xxx_x0x1;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Read");
    C_data <= 4'b1010;
    ctrl <= 2'b01;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("write confg");
    DataBus_data <= 8'b1xxx_x0x0;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("write");
    DataBus_data <= 8'b1101_0010;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("nothing");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 0;
#5
$display("Reset");
    ctrl <= 2'b10;
    CS <= 1;
    RD <= 1;
    WR <= 1;
    Sel <= 2'b10;
    Reset <= 1;
#5
$display("BSR");
    DataBus_data <= 8'b0000_0111;
    ctrl <= 2'b10;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
 end

PortLC LC_t(DataBus_pins,C_pins,Sel,RD,WR,Reset,CS);

endmodule

module PPI_tb();

reg RD , WR , CS , Reset;
reg [1:0] Sel;
wire [7:0] PortA_pins , PortB_pins ,PortC_pins ,D_pins;
reg [3:0] ctrl;
reg [7:0] PortA_data , PortB_data ,PortC_data ,D_data;

/*
PortA Read  ---> ctrl[0] = 0
PortA Write ---> ctrl[0] = 1

PortB Read  ---> ctrl[1] = 0
PortB Write ---> ctrl[1] = 1

PortC Read  ---> ctrl[2] = 0
PortC Write ---> ctrl[2] = 1

D Read  ---> ctrl[3] = 0
D Write ---> ctrl[3] = 1
*/

assign PortA_pins = (ctrl[0])? PortA_data : 8'bzzzz_zzzz;
assign PortB_pins = (ctrl[1])? PortB_data : 8'bzzzz_zzzz;
assign PortC_pins = (ctrl[2])? PortC_data : 8'bzzzz_zzzz;
assign D_pins = (ctrl[3])? D_data : 8'bzzzz_zzzz;

initial
begin
$monitor($time ,, "CS=%b RD=%b WR=%b Sel=%b Reset=%b PortA=%b PortB=%b PortC=%b D=%b", CS , RD , WR , Sel , Reset , PortA_pins , PortB_pins, PortC_pins, D_pins);
$display("Reset");
    Reset <= 1;
#5
$display("***********************************************************1st************************************************");
$display("PortA output,PortB output,PortUC output , PortLC output confg");
    D_data <= 8'b100_00_0_00;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
#5
$display("Reset");
    Reset <= 1;
#5
$display("********************************************************2nd***************************************************");
$display("PortA output,PortB output,PortUC output , PortLC Input confg");
    D_data <= 8'b100_00_0_01;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortUC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortLC");
    PortC_data <= 8'bzzzz_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*****************************************************3rd*****************************************************");
$display("PortA output,PortB input,PortUC output , PortLC output confg");
    D_data <= 8'b100_00_0_10;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b1111_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortC");
    D_data <= 8'b0101_0101; 
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************4th****************************************************");
$display("PortA output,PortB input,PortUC output , PortLC Input confg");
    D_data <= 8'b100_00_0_11;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b1111_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortUC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortLC");
    PortC_data <= 8'bzzzz_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************5th****************************************************");
$display("PortA output,PortB output,PortUC input , PortLC output confg");
    D_data <= 8'b100_01_0_00;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b0101_zzzz;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortLC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************6th****************************************************");
$display("PortA output,PortB output,PortUC input , PortLC input confg");
    D_data <= 8'b100_01_0_01;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b1111_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************7th****************************************************");
$display("PortA output,PortB input,PortUC input , PortLC output confg");
    D_data <= 8'b100_01_0_10;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b0101_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b0101_zzzz;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortLC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************8th****************************************************");
$display("PortA output,PortB input,PortUC input , PortLC input confg");
    D_data <= 8'b100_01_0_11;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b0101_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortC");
    PortC_data <= 8'b0101_1100;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************9th****************************************************");
$display("PortA input,PortB output,PortUC output , PortLC output confg");
    D_data <= 8'b100_10_0_00;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("********************************************************10th***************************************************");
$display("PortA input,PortB output,PortUC output , PortLC Input confg");
    D_data <= 8'b100_10_0_01;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortUC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortLC");
    PortC_data <= 8'bzzzz_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*****************************************************11th*****************************************************");
$display("PortA input,PortB input,PortUC output , PortLC output confg");
    D_data <= 8'b100_10_0_10;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b1111_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortC");
    D_data <= 8'b0101_0101; 
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************12th****************************************************");
$display("PortA input,PortB input,PortUC output , PortLC Input confg");
    D_data <= 8'b100_10_0_11;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b1111_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortUC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortLC");
    PortC_data <= 8'bzzzz_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************13th****************************************************");
$display("PortA input,PortB output,PortUC input , PortLC output confg");
    D_data <= 8'b100_11_0_00;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;        
$display("write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b0101_zzzz;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortLC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************14th****************************************************");
$display("PortA input,PortB output,PortUC input , PortLC input confg");
    D_data <= 8'b100_11_0_01;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("write in PortB");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b1111_1111;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************15th****************************************************");
$display("PortA input,PortB input,PortUC input , PortLC output confg");
    D_data <= 8'b100_11_0_10;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b0101_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortUC");
    PortC_data <= 8'b0101_zzzz;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortLC");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************16th****************************************************");
$display("PortA input,PortB input,PortUC input , PortLC input confg");
    D_data <= 8'b100_11_0_11;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortA");
    PortA_data <= 8'b1111_1111;
    ctrl <= 4'b0001;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortB");
    PortB_data <= 8'b0101_1111;
    ctrl <= 4'b0010;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Read from PortC");
    PortC_data <= 8'b0101_1100;
    ctrl <= 4'b0100;
    CS <= 0;
    Sel <= 2'b10;
    Reset <= 0;
    #2
    RD <= 0;
    WR <= 1;
    #2
    RD <= 1;
    WR <= 1;
$display("Reset");
    Reset <= 1;
#5
$display("*******************************************************17th****************************************************");
$display("PortA output,PortB output,PortUC output , PortLC output confg");
    D_data <= 8'b100_00_0_00;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortA");
    D_data <= 8'b0101_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b00;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("Write in PortB");
    D_data <= 8'b1111_0000;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b01;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("PortC BSR set bit 2");
    D_data <= 8'b0xxx_0101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("PortC BSR set bit 6");
    D_data <= 8'b0xxx_1101;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("PortC BSR reset bit 2");
    D_data <= 8'b0xxx_0100;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("PortC BSR set bit 0");
    D_data <= 8'b0xxx_0001;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
$display("PortC BSR set bit 3");
    D_data <= 8'b0xxx_0111;
    ctrl <= 4'b1000;
    CS <= 0;
    Sel <= 2'b11;
    Reset <= 0;
    #2
    RD <= 1;
    WR <= 0;
    #2
    RD <= 1;
    WR <= 1;
 
end

PPI PPI1(PortA_pins,PortB_pins,PortC_pins,D_pins,Sel,RD,WR,Reset,CS);

endmodule