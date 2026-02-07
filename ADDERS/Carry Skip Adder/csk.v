`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 21:55:57
// Design Name: 
// Module Name: csk
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


module full_adder(input a, b, cin, output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

// --- 4-bit Carry Skip Block ---
module csk_block_4bit(
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire [3:1] c;
    wire c_ripple;
    wire [3:0] p;
    wire skip_en;

    // Standard Ripple Carry inside the block
    full_adder fa0(a[0], b[0], cin,  sum[0], c[1]);
    full_adder fa1(a[1], b[1], c[1], sum[1], c[2]);
    full_adder fa2(a[2], b[2], c[2], sum[2], c[3]);
    full_adder fa3(a[3], b[3], c[3], sum[3], c_ripple);

    // Skip Logic: P = A XOR B
    assign p = a ^ b;
    assign skip_en = &p; // All 4 bits are 1 then skip

    // MUX: If skip_en is 1, bypass the ripple carry
    assign cout = skip_en ? cin : c_ripple;
endmodule

// --- Top Module: 8-bit Carry Skip Adder ---
module cska_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire c_mid;

    csk_block_4bit block1(a[3:0], b[3:0], cin,   sum[3:0], c_mid);
    csk_block_4bit block2(a[7:4], b[7:4], c_mid, sum[7:4], cout);
endmodule

module cska_16bit(
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire c4, c8, c12;

    // Block 0: 0-3 bits
    csk_block_4bit cb1(.a(a[3:0]),   .b(b[3:0]),   .cin(cin), .sum(sum[3:0]),   .cout(c4));
    
    // Block 1: 4-7 bits
    csk_block_4bit cb2(.a(a[7:4]),   .b(b[7:4]),   .cin(c4),  .sum(sum[7:4]),   .cout(c8));
    
    // Block 2: 8-11 bits
    csk_block_4bit cb3(.a(a[11:8]),  .b(b[11:8]),  .cin(c8),  .sum(sum[11:8]),  .cout(c12));
    
    // Block 3: 12-15 bits
    csk_block_4bit cb4(.a(a[15:12]), .b(b[15:12]), .cin(c12), .sum(sum[15:12]), .cout(cout));

endmodule
