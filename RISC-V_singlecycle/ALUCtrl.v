module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010; // lw/sw (add)
            2'b01: begin // Branch
                case (funct3)
                    3'b000: ALUControl = 4'b0110; // BEQ (subtract)
                    3'b001: ALUControl = 4'b0110; // BNE (subtract)
                    3'b100: ALUControl = 4'b0111; // BLT (set less than)
                    3'b101: ALUControl = 4'b0111; // BGE (set less than)
                    3'b110: ALUControl = 4'b1000; // BLTU (set less than unsigned)
                    3'b111: ALUControl = 4'b1000; // BGEU (set less than unsigned)
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b10: begin // R-type or I-type
                case (funct3)
                    3'b000: begin
                        if (ALUOp == 2'b10 && funct7 == 7'b0100000)
                            ALUControl = 4'b0110; // SUB
                        else
                            ALUControl = 4'b0010; // ADD/ADDI
                    end
                    3'b001: ALUControl = 4'b0001; // SLL/SLLI
                    3'b010: ALUControl = 4'b0111; // SLT/SLTI
                    3'b011: ALUControl = 4'b1000; // SLTU/SLTIU
                    3'b100: ALUControl = 4'b0100; // XOR/XORI
                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = 4'b0101; // SRA/SRAI
                        else
                            ALUControl = 4'b0011; // SRL/SRLI
                    end
                    3'b110: ALUControl = 4'b0000; // OR/ORI
                    3'b111: ALUControl = 4'b1100; // AND/ANDI
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule