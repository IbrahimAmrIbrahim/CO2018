`timescale 1ns / 1ps

module device(CLK, RST_N, AD, CBE_N, FRAME_N, IRDY_N, TRDY_N, DEVSEL_N, REQ_N, GNT_N);

input CLK, RST_N, GNT_N;
inout [31:0] AD;
inout [3:0] CBE_N;
inout FRAME_N, IRDY_N, TRDY_N, DEVSEL_N;
output GNT_N;

endmodule

module arbiter_priority();
endmodule

module arbiter_FCFS();
endmodule 

module PCI();
endmodule
