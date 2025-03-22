module ALU (
    input [3:0] ALUCtl,
    input [31:0] A, B,
    output reg [31:0] ALUOut,
    output zero
);

    // ALU Operation Codes
    parameter ALU_ADD  = 4'b0000;  // ADD, ADDI, LW, SW
    parameter ALU_SUB  = 4'b0001;  // SUB, BEQ
    parameter ALU_AND  = 4'b0010;  // AND
    parameter ALU_OR   = 4'b0011;  // OR, ORI
    parameter ALU_XOR  = 4'b0100;  // XOR
    parameter ALU_SLL  = 4'b0101;  // SLLI
    parameter ALU_SRL  = 4'b0110;  // SRL
    parameter ALU_SRA  = 4'b0111;  // SRA
    parameter ALU_SLT  = 4'b1000;  // SLT
    parameter ALU_BGT  = 4'b1001;  // BGT (A > B)
    parameter ALU_JAL  = 4'b1010;  // JAL (PC + 4)

    always @(*) begin
        case (ALUCtl)
            ALU_ADD:  ALUOut = A + B;                        // Addition (LW, SW, ADD, ADDI)
            ALU_SUB:  ALUOut = A - B;                        // Subtraction (SUB, BEQ)
            ALU_AND:  ALUOut = A & B;                        // Bitwise AND
            ALU_OR:   ALUOut = A | B;                        // Bitwise OR (ORI)
            ALU_XOR:  ALUOut = A ^ B;                        // Bitwise XOR
            ALU_SLL:  ALUOut = A << B[4:0];                  // Logical Left Shift (SLLI)
            ALU_SRL:  ALUOut = A >> B[4:0];                  // Logical Right Shift
            ALU_SRA:  ALUOut = $signed(A) >>> B[4:0];        // Arithmetic Right Shift
            ALU_SLT:  ALUOut = ($signed(A) < $signed(B)) ? 1 : 0;  // Set Less Than (SLT)
            ALU_BGT:  ALUOut = ($signed(A) > $signed(B)) ? 1 : 0;  // Branch Greater Than (BGT)
            ALU_JAL:  ALUOut = A + 4;                        // Jump and Link (JAL)
            default:  ALUOut = 32'h0;                        // Default case
        endcase
    end

    // Zero flag for BEQ
    assign zero = (ALUOut == 32'h0);

endmodule
