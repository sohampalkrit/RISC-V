module ImmGen #(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011,  // I-type (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI)
            7'b0000011,  // Load (LW, LH, LB, LHU, LBU)
            7'b1100111:  // JALR
                imm = {{20{inst[31]}}, inst[31:20]};  // Correct 12-bit sign-extended immediate

            7'b0100011:  // S-type (SW, SH, SB)
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};  // Correct 12-bit sign-extended immediate

            7'b1100011:  // B-type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                // Corrected B-type immediate format
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

            7'b1101111:  // J-type (JAL)
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // Corrected 20-bit immediate

            7'b0110111,  // LUI
            7'b0010111:  // AUIPC
                imm = {inst[31:12], 12'b0};  // 20-bit immediate shifted left

            default: 
                imm = 32'b0;  // Default case
        endcase
    end
endmodule