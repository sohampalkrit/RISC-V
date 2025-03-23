module ALU (
    input [31:0] A,        // Operand 1
    input [31:0] B,        // Operand 2
    input [3:0] ALUControl, // Control signal from ALU_Control unit
    output reg [31:0] Result, // ALU result
    output reg Zero         // Zero flag (for branch instructions)
);

    always @(*) begin
        // Default values
        Result = 32'b0;
        
        case (ALUControl)
            4'b0000: Result = A + B;       // ADD, ADDI, LW, SW
            4'b0001: Result = A - B;       // SUB, BEQ, BNE (Zero flag used)
            4'b0010: Result = A & B;       // AND, ANDI
            4'b0011: Result = A | B;       // OR, ORI
            4'b0100: Result = A ^ B;       // XOR, XORI
            4'b0101: Result = A << B[4:0]; // SLL, SLLI
            4'b0110: Result = A >> B[4:0]; // SRL, SRLI
            4'b0111: Result = $signed(A) >>> B[4:0]; // SRA, SRAI
            4'b1000: Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT, SLTI
            4'b1001: Result = (A < B) ? 32'b1 : 32'b0; // SLTU, SLTIU
            default: Result = 32'b0; // Undefined
        endcase
        
        // Zero flag for BEQ, BNE, BLT, BGE
        Zero = (Result == 0) ? 1'b1 : 1'b0;
    end
endmodule
