`timescale 1ns / 1ps

module PPI(D , PA , PB , PC , A , RDbar , WRbar , CSbar , Reset );
inout [7:0] D , PA , PB , PC;
input [1:0] A;
inout RDbar , WRbar , CSbar , Reset;

endmodule
