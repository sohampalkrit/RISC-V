module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD (for LW, SW, ADDI)
            2'b01: begin  // Branch instructions
                case (funct3)
                    3'b000: ALUControl = 4'b0001; // BEQ - Subtraction
                    3'b001: ALUControl = 4'b0001; // BNE - Subtraction
                    3'b100: ALUControl = 4'b1000; // BLT - Set less than (signed)
                    3'b101: ALUControl = 4'b1000; // BGE - Set less than (signed)
                    3'b110: ALUControl = 4'b1001; // BLTU - Set less than (unsigned)
                    3'b111: ALUControl = 4'b1001; // BGEU - Set less than (unsigned)
                    default: ALUControl = 4'b0001; // Default to subtraction
                endcase
            end
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB or ADD 
                    3'b111: ALUControl = 4'b0010; // AND
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b101: ALUControl = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA or SRL
                    3'b010: ALUControl = 4'b1000; // SLT
                    3'b011: ALUControl = 4'b1001; // SLTU
                    3'b100: ALUControl = 4'b0100; // XOR
                    default: ALUControl = 4'b0000; // Default: ADD
                endcase
            end
            2'b11: begin
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b001: ALUControl = 4'b0101; // SLLI
                    3'b101: ALUControl = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRAI or SRLI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule