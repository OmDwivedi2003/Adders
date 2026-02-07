`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 19:49:45
// Design Name: 
// Module Name: rca
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

//module rca_16bit (
//    input [15:0] A,
//    input [15:0] B,
//    input Cin,
//    output [15:0] Sum,
//    output Cout
//);

//    // This internal wire carries the 'carry' signal between bits
//    // wire [16] is used so we can map the final Cout easily
//    wire [16:0] carry;

//    // The first carry-in comes from the module input
//    assign carry[0] = Cin;

//    // We use a 'generate' loop to instantiate 16 full adders automatically.
//    // This is much cleaner than writing them out one by one.
//    genvar i;
//    generate
//        for (i = 0; i < 16; i = i + 1) begin : adder_loop
//            full_adder fa_inst (
//                .a(A[i]),
//                .b(B[i]),
//                .cin(carry[i]),
//                .sum(Sum[i]),
//                .cout(carry[i+1])
//            );
//        end
//    endgenerate

//    // The last carry-out from the loop is our final Cout
//    assign Cout = carry[16];

//endmodule

module rca_8bit (
    input [7:0] A,
    input [7:0] B,
    input Cin,
    output [7:0] Sum,
    output Cout
);

    // Internal wires to carry the signal from one stage to the next
    wire c1, c2, c3, c4, c5, c6, c7;

    // Bit 0: Pehla adder jo external Cin lega
    full_adder fa0 (.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c1));

    // Bit 1: Iska carry-in pichle stage (fa0) se aayega
    full_adder fa1 (.a(A[1]), .b(B[1]), .cin(c1),  .sum(Sum[1]), .cout(c2));

    // Bit 2
    full_adder fa2 (.a(A[2]), .b(B[2]), .cin(c2),  .sum(Sum[2]), .cout(c3));

    // Bit 3
    full_adder fa3 (.a(A[3]), .b(B[3]), .cin(c3),  .sum(Sum[3]), .cout(c4));

    // Bit 4
    full_adder fa4 (.a(A[4]), .b(B[4]), .cin(c4),  .sum(Sum[4]), .cout(c5));

    // Bit 5
    full_adder fa5 (.a(A[5]), .b(B[5]), .cin(c5),  .sum(Sum[5]), .cout(c6));

    // Bit 6
    full_adder fa6 (.a(A[6]), .b(B[6]), .cin(c6),  .sum(Sum[6]), .cout(c7));

    // Bit 7: Aakhri stage ka cout final output banega
    full_adder fa7 (.a(A[7]), .b(B[7]), .cin(c7),  .sum(Sum[7]), .cout(Cout));

endmodule

