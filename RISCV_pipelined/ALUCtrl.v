module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7,   // Changed to 7 bits to properly check funct7[5]
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtl = 4'b0000; // Load/Store (LW, SW) -> ADD
            
            2'b01: begin // Branch Instructions
                case (funct3)
                    3'b000: ALUCtl = 4'b0001; // BEQ (SUB for comparison)
                    3'b100: ALUCtl = 4'b1010; // BLT (Set Less Than)
                    3'b101: ALUCtl = 4'b1011; // BGE (Set Greater or Equal)
                    default: ALUCtl = 4'b0000; // Default to ADD
                endcase
            end
            
            2'b10: begin // R-Type Instructions
                case (funct3)
                    3'b000: ALUCtl = (funct7[5]) ? 4'b0001 : 4'b0000; // ADD (0000) or SUB (0001)
                    3'b001: ALUCtl = 4'b0010; // SLL (Shift Left Logical)
                    3'b010: ALUCtl = 4'b1010; // SLT (Set Less Than)
                    3'b011: ALUCtl = 4'b1100; // SLTU (Set Less Than Unsigned)
                    3'b100: ALUCtl = 4'b0101; // XOR
                    3'b101: ALUCtl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRL (0110) or SRA (0111)
                    3'b110: ALUCtl = 4'b0011; // OR
                    3'b111: ALUCtl = 4'b0100; // AND
                    default: ALUCtl = 4'b0000; // Default to ADD
                endcase
            end
            
            default: ALUCtl = 4'b0000; // Default to ADD
        endcase
    end
endmodule
