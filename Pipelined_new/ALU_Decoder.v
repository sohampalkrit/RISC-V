module ALU_Decoder(ALUOp, funct3, funct7, op, ALUControl);
    input [1:0] ALUOp;
    input [2:0] funct3;
    input [6:0] funct7, op;
    output [3:0] ALUControl;

    assign ALUControl = 
        (ALUOp == 2'b00) ? 4'b0000 : // ADD for Load/Store
        (ALUOp == 2'b01) ? 4'b0001 : // SUB for Branches
        (ALUOp == 2'b10) ? (
            (funct3 == 3'b000) ? (({op[5],funct7[5]} == 2'b11) ? 4'b0001 : 4'b0000) :  // ADD/SUB
            (funct3 == 3'b010) ? 4'b0110 :  // SLT (Signed)
            (funct3 == 3'b011) ? 4'b0111 :  // SLTU (Unsigned)
            (funct3 == 3'b100) ? 4'b0100 :  // XOR
            (funct3 == 3'b110) ? 4'b0011 :  // OR
            (funct3 == 3'b111) ? 4'b0010 :  // AND
            (funct3 == 3'b001) ? 4'b0101 :  // SLL
            (funct3 == 3'b101) ? ((funct7[5] == 1'b1) ? 4'b1001 : 4'b1000) : // SRA / SRL
            4'b0000 // Default (ADD)
        ) : 4'b0000; // Default case

endmodule
