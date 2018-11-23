`timescale 1ns / 1ps

module ReadWriteControlLogic(A , RDbar , WRbar ,CSbar , Reset);
input [1:0] A;
input RDbar , WRbar ,CSbar, Reset;

always @(A , RDbar , WRbar ,CSbar , Reset)
begin
if(~CSbar)
begin


end
end
endmodule

module PPI(D , PA , PB , PC , A , RDbar , WRbar , CSbar , Reset);
inout [7:0] D , PA , PB , PC;
input [1:0] A;
input RDbar , WRbar , CSbar , Reset;

assign PA = (~CSbar && Reset)? 8'b zzzz_zzzz : 8'b 1111_1111;


endmodule
