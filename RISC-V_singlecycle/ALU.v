module ALU (
    input [31:0] A,         // First operand
    input [31:0] B,         // Second operand
    input [3:0] ALUControl, // Operation control
    output reg [31:0] Result, // Result of operation
    output Zero              // Zero flag, set when Result == 0
);

    // Zero flag is set when Result is 0
    assign Zero = (Result == 32'b0);

    // ALU operations based on ALUControl
    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A & B;                     // AND
            4'b0001: Result = A << B[4:0];               // SLL (Shift Left Logical)
            4'b0010: Result = A + B;                     // ADD
            4'b0011: Result = A >> B[4:0];               // SRL (Shift Right Logical)
            4'b0100: Result = A ^ B;                     // XOR
            4'b0101: Result = $signed(A) >>> B[4:0];     // SRA (Shift Right Arithmetic)
            4'b0110: Result = A - B;                     // SUB
            4'b0111: Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT (Set Less Than, signed)
            4'b1000: Result = (A < B) ? 32'b1 : 32'b0;   // SLTU (Set Less Than, unsigned)
            4'b1001: Result = A | B;                     // OR
            4'b1010: Result = B;                         // Pass B (used for LUI)
            4'b1011: Result = A;                         // Pass A (sometimes useful)
            4'b1100: Result = ~(A | B);                  // NOR
            4'b1101: Result = ~(A & B);                  // NAND
            4'b1110: Result = ~A;                        // NOT A
            4'b1111: Result = ~B;                        // NOT B
            default: Result = 32'b0;                     // Default: 0
        endcase
    end

endmodule