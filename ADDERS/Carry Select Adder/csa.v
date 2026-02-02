`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 21:31:26
// Design Name: 
// Module Name: csa
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

module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    // Logic for Sum: A XOR B XOR Cin
    assign sum = a ^ b ^ cin;
    
    // Logic for Carry-out: (A AND B) OR (Cin AND (A XOR B))
    assign cout = (a & b) | (cin & (a ^ b));

endmodule

module rca_4bit(
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire c1, c2, c3;
    // 1-bit FA units connect kar rahe hain
    full_adder fa0(a[0], b[0], cin, sum[0], c1);
    full_adder fa1(a[1], b[1], c1,  sum[1], c2);
    full_adder fa2(a[2], b[2], c2,  sum[2], c3);
    full_adder fa3(a[3], b[3], c3,  sum[3], cout);
endmodule

module csa_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire c_mid;
    wire [3:0] sum_low, sum_high_0, sum_high_1;
    wire cout_high_0, cout_high_1;

    // Lower 4-bits: Standard RCA (isey piche ka wait nahi karna)
    rca_4bit lower_block(
        .a(a[3:0]), .b(b[3:0]), .cin(cin), 
        .sum(sum[3:0]), .cout(c_mid)
    );

    // Upper 4-bits (Case 0): Maan lo piche se carry 0 aaya
    rca_4bit upper_block_c0(
        .a(a[7:4]), .b(b[7:4]), .cin(1'b0), 
        .sum(sum_high_0), .cout(cout_high_0)
    );

    // Upper 4-bits (Case 1): Maan lo piche se carry 1 aaya
    rca_4bit upper_block_c1(
        .a(a[7:4]), .b(b[7:4]), .cin(1'b1), 
        .sum(sum_high_1), .cout(cout_high_1)
    );

    // MUX Logic: Jab actual c_mid aayega, tab sahi result select hoga
    // Sum selection
    assign sum[7:4] = (c_mid == 1'b0) ? sum_high_0 : sum_high_1;
    
    // Final Cout selection
    assign cout = (c_mid == 1'b0) ? cout_high_0 : cout_high_1;

endmodule

// --- 16-Bit Carry Select Adder Top Module ---
module csa_16bit(
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire c4, c8, c12;
    wire [3:0] s_h1_0, s_h1_1, s_h2_0, s_h2_1, s_h3_0, s_h3_1;
    wire c_h1_0, c_h1_1, c_h2_0, c_h2_1, c_h3_0, c_h3_1;

    // Block 0: 0-3 bits (Direct RCA)
    rca_4bit b0(a[3:0], b[3:0], cin, sum[3:0], c4);

    // Block 1: 4-7 bits (Speculative)
    rca_4bit b1_0(a[7:4], b[7:4], 1'b0, s_h1_0, c_h1_0);
    rca_4bit b1_1(a[7:4], b[7:4], 1'b1, s_h1_1, c_h1_1);
    assign sum[7:4] = (c4 == 1'b0) ? s_h1_0 : s_h1_1;
    assign c8       = (c4 == 1'b0) ? c_h1_0 : c_h1_1;

    // Block 2: 8-11 bits (Speculative)
    rca_4bit b2_0(a[11:8], b[11:8], 1'b0, s_h2_0, c_h2_0);
    rca_4bit b2_1(a[11:8], b[11:8], 1'b1, s_h2_1, c_h2_1);
    assign sum[11:8] = (c8 == 1'b0) ? s_h2_0 : s_h2_1;
    assign c12       = (c8 == 1'b0) ? c_h2_0 : c_h2_1;

    // Block 3: 12-15 bits (Speculative)
    rca_4bit b3_0(a[15:12], b[15:12], 1'b0, s_h3_0, c_h3_0);
    rca_4bit b3_1(a[15:12], b[15:12], 1'b1, s_h3_1, c_h3_1);
    assign sum[15:12] = (c12 == 1'b0) ? s_h3_0 : s_h3_1;
    assign cout       = (c12 == 1'b0) ? c_h3_0 : c_h3_1;

endmodule
