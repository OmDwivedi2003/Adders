`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 20:02:48
// Design Name: 
// Module Name: cla
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


module cla_4bit(
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire [3:0] g, p;
    wire [4:0] c;

    assign g = a & b; 
    assign p = a ^ b; 

    // Carry Look-Ahead Logic
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);

    assign sum = p ^ c[3:0];
    assign cout = c[4];
endmodule


module cla_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire c_mid;
    cla_4bit c0(a[3:0], b[3:0], cin,   sum[3:0], c_mid);
    cla_4bit c1(a[7:4], b[7:4], c_mid, sum[7:4], cout);
endmodule

module cla_16bit(
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire c1, c2, c3;

    cla_4bit block0(a[3:0],   b[3:0],   cin, sum[3:0],   c1);
    cla_4bit block1(a[7:4],   b[7:4],   c1,  sum[7:4],   c2);
    cla_4bit block2(a[11:8],  b[11:8],  c2,  sum[11:8],  c3);
    cla_4bit block3(a[15:12], b[15:12], c3,  sum[15:12], cout);
endmodule

