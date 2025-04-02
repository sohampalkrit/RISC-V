module ALU (
    input [31:0] A, B,
    input [3:0] ALUControl,  
    output Carry, OverFlow, Zero, Negative,
    output [31:0] Result
);

    wire [31:0] sum, sub;
    wire carry_add, carry_sub, overflow_add, overflow_sub;
    
    // ADD and SUB calculations
    assign {carry_add, sum} = A + B;  
    assign {carry_sub, sub} = A - B;  

    // Overflow detection for ADD and SUB
    assign overflow_add = (A[31] == B[31]) && (sum[31] != A[31]);
    assign overflow_sub = (A[31] != B[31]) && (sub[31] != A[31]);

    // ALU Operation Selection
    assign Result = (ALUControl == 4'b0000) ? sum :  // ADD
                    (ALUControl == 4'b0001) ? sub :  // SUB
                    (ALUControl == 4'b0010) ? (A & B) : // AND
                    (ALUControl == 4'b0011) ? (A | B) : // OR
                    (ALUControl == 4'b0100) ? (A ^ B) : // XOR
                    (ALUControl == 4'b0101) ? (A << B[4:0]) :  // SLL
                    (ALUControl == 4'b0110) ? (($signed(A) < $signed(B)) ? 32'b1 : 32'b0) : // SLT
                    (ALUControl == 4'b0111) ? ((A < B) ? 32'b1 : 32'b0) : // SLTU
                    (ALUControl == 4'b1000) ? (A >> B[4:0]) :  // SRL
                    (ALUControl == 4'b1001) ? ($signed(A) >>> B[4:0]) :  // SRA
                    32'b0;  // Default case

    // Flag Assignments
    assign Carry = (ALUControl == 4'b0000) ? carry_add :
                   (ALUControl == 4'b0001) ? carry_sub : 1'b0;
    assign OverFlow = (ALUControl == 4'b0000) ? overflow_add :
                      (ALUControl == 4'b0001) ? overflow_sub : 1'b0;
    assign Zero = (Result == 32'b0);
    assign Negative = Result[31];

endmodule
