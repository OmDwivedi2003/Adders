`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 22:31:21
// Design Name: 
// Module Name: ksa_8bit
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



module ksa_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    // Signals for Propagate and Generate
    wire [7:0] g0, p0, g1, p1, g2, p2, g3, p3;

    // --- STEP 1: Pre-processing ---
    assign g0 = a & b;
    assign p0 = a ^ b;

    // --- STEP 2: Prefix Tree ---
    
    // STAGE 1: Distance 1 (Shift by 1)
    // Bit 0 incorporates Cin
    assign g1[0] = g0[0] | (p0[0] & cin);
    assign p1[0] = p0[0];
    
    // For bits 1 to 7, combine with i-1
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin : stage1
            assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
            assign p1[i] = p0[i] & p0[i-1];
        end
    endgenerate

    // STAGE 2: Distance 2 (Shift by 2)
    assign g2[1:0] = g1[1:0]; // First 2 bits remain same
    assign p2[1:0] = p1[1:0];
    generate
        for (i = 2; i < 8; i = i + 1) begin : stage2
            assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
            assign p2[i] = p1[i] & p1[i-2];
        end
    endgenerate

    // STAGE 3: Distance 4 (Shift by 4)
    assign g3[3:0] = g2[3:0]; // First 4 bits remain same
    assign p3[3:0] = p2[3:0];
    generate
        for (i = 4; i < 8; i = i + 1) begin : stage3
            assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
            assign p3[i] = p2[i] & p2[i-4];
        end
    endgenerate

    // --- STEP 3: Post-processing ---
    assign sum[0] = p0[0] ^ cin;
    assign sum[7:1] = p0[7:1] ^ g3[6:0]; // Sum_i = P0_i XOR Carry_(i-1)
    assign cout = g3[7];

endmodule

module lfa_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire [7:0] g, p;
    wire [7:0] c; // Final carries for each bit

    // --- STEP 1: Pre-processing ---
    assign g = a & b;
    assign p = a ^ b;

    // --- STEP 2: Prefix Tree (Ladner-Fischer Logic) ---
    // Stage 1: Distance 1
    wire [7:0] g1, p1;
    assign g1[0] = g[0] | (p[0] & cin);
    assign g1[1] = g[1] | (p[1] & g[0]);
    assign g1[3] = g[3] | (p[3] & g[2]);
    assign g1[5] = g[5] | (p[5] & g[4]);
    assign g1[7] = g[7] | (p[7] & g[6]);
    
    assign p1[1] = p[1] & p[0];
    assign p1[3] = p[3] & p[2];
    assign p1[5] = p[5] & p[4];
    assign p1[7] = p[7] & p[6];

    // Stage 2: Distance 2 (Calculating carries for bit 1, 2, 3)
    wire g2_3, p2_3, g2_7, p2_7;
    assign c[0] = g1[0]; 
    assign c[1] = g1[1] | (p1[1] & cin);
    
    assign g2_3 = g1[3] | (p1[3] & g1[1]);
    assign p2_3 = p1[3] & p1[1];
    
    assign c[2] = g[2] | (p[2] & c[1]);
    assign c[3] = g2_3 | (p2_3 & cin);

    // Stage 3: Distance 4 (Calculating carries for bits 4, 5, 6, 7)
    assign g2_7 = g1[7] | (p1[7] & g1[5]);
    assign p2_7 = p1[7] & p1[5];
    
    wire g3_7;
    assign g3_7 = g2_7 | (p2_7 & g2_3);

    assign c[4] = g[4] | (p[4] & c[3]);
    assign c[5] = g1[5] | (p1[5] & c[3]);
    assign c[6] = g[6] | (p[6] & c[5]);
    assign c[7] = g3_7 | (p2_7 & p2_3 & cin);

    // --- STEP 3: Final Sum ---
    assign sum[0] = p[0] ^ cin;
    assign sum[7:1] = p[7:1] ^ c[6:0];
    assign cout = c[7];

endmodule


module bka_8bit(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire [7:0] g, p;
    // Step 1: Pre-processing
    assign g = a & b;
    assign p = a ^ b;

    // Step 2: Forward Tree (Reduction)
    wire g1_1, p1_1, g1_3, p1_3, g1_5, p1_5, g1_7, p1_7;
    assign g1_1 = g[1] | (p[1] & g[0]);
    assign p1_1 = p[1] & p[0];

    assign g1_3 = g[3] | (p[3] & g[2]);
    assign p1_3 = p[3] & p[2];

    assign g1_5 = g[5] | (p[5] & g[4]);
    assign p1_5 = p[5] & p[4];

    assign g1_7 = g[7] | (p[7] & g[6]);
    assign p1_7 = p[7] & p[6];

    // Second level of reduction
    wire g2_3, p2_3, g2_7, p2_7;
    assign g2_3 = g1_3 | (p1_3 & g1_1);
    assign p2_3 = p1_3 & p1_1;

    assign g2_7 = g1_7 | (p1_7 & g1_5);
    assign p2_7 = p1_7 & p1_5;

    // Third level (Final carry for 8-bit)
    wire g3_7, p3_7;
    assign g3_7 = g2_7 | (p2_7 & g2_3);
    assign p3_7 = p2_7 & p2_3;

    // Step 3: Backward Tree (Expansion to find missing carries)
    wire [7:0] c;
    assign c[0] = g[0] | (p[0] & cin);
    assign c[1] = g1_1 | (p1_1 & cin);
    assign c[3] = g2_3 | (p2_3 & cin);
    assign c[7] = g3_7 | (p3_7 & cin);

    // Finding c[2], c[4], c[5], c[6] using expansion
    assign c[2] = g[2] | (p[2] & c[1]);
    assign c[5] = g1_5 | (p1_5 & c[3]);
    assign c[4] = g[4] | (p[4] & c[3]);
    assign c[6] = g[6] | (p[6] & c[5]);

    // Step 4: Post-processing
    assign sum[0] = p[0] ^ cin;
    assign sum[7:1] = p[7:1] ^ c[6:0];
    assign cout = c[7];

endmodule
