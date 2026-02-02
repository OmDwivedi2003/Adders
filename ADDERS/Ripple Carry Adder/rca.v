`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.08.2025 12:05:15
// Design Name: 
// Module Name: Ripple_Carry_Counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module T_ff(input clk,reset,t, output reg q);
always @ (negedge clk or posedge reset)
begin
if (reset) q<=1'b0;
else if(t) q<= ~q;
end
endmodule

module Ripple_Carry_Counter(
    input clk, reset,t,
    output [3:0] q
    );
    T_ff t0(clk,reset,t,q[0]);
    T_ff t1(q[0],reset,t,q[1]);
    T_ff t2(q[1],reset,t,q[2]);
    T_ff t3(q[2],reset,t,q[3]);
      
    
endmodule
