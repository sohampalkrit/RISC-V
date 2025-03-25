module Control_Unit (
    input [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite,
    output reg [2:0] ImmSrc  // <-- Fixed missing comma
);

    always @(*) begin
        // Default values (for undefined opcodes)
        branch   = 0;
        memRead  = 0;
        memtoReg = 0;
        ALUOp    = 2'b00;
        memWrite = 0;
        ALUSrc   = 0;
        regWrite = 0;
        ImmSrc   = 3'b000;  // Default to I-Type

        case (opcode)
            7'b0000011: begin // LW (Load Word)
                regWrite = 1;
                memRead  = 1;
                memtoReg = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Addition for address calculation
                ImmSrc   = 3'b000; // I-Type immediate
            end
            
            7'b0100011: begin // SW (Store Word)
                memWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Addition for address calculation
                ImmSrc   = 3'b001; // S-Type immediate
            end
            
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR)
                regWrite = 1;
                ALUOp    = 2'b10; // ALU uses funct3 and funct7
                ImmSrc   = 3'b000; // Not used in R-Type
            end
            
            7'b1100011: begin // BEQ, BGT (Branch)
                branch  = 1;
                ALUOp   = 2'b01; // Subtraction for comparison
                ImmSrc  = 3'b010; // B-Type immediate
            end
            
            7'b1101111: begin // JAL (Jump and Link)
                regWrite = 1;
                ALUOp    = 2'b00; // PC-relative jump
                ImmSrc   = 3'b011; // J-Type immediate
            end
            
            7'b1100111: begin // JALR (Jump and Link Register)
                regWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Uses immediate offset
                ImmSrc   = 3'b000; // I-Type immediate (same format as LW)
            end

            7'b0010011: begin // I-type (ADDI, ORI, SLLI, etc.)
                regWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Immediate operations
                ImmSrc   = 3'b000; // I-Type immediate
            end
            
            7'b0110111: begin // LUI (Load Upper Immediate)
                regWrite = 1;
                ALUOp    = 2'b00; // No ALU operation, just immediate load
                ImmSrc   = 3'b100; // U-Type immediate
            end
            
            7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
                regWrite = 1;
                ALUOp    = 2'b00; // PC + immediate
                ImmSrc   = 3'b100; // U-Type immediate
            end

            default: begin // Undefined opcode
                regWrite = 0;
                branch   = 0;
                memRead  = 0;
                memWrite = 0;
                ALUSrc   = 0;
                ALUOp    = 2'b00;
                ImmSrc   = 3'b000;
            end
        endcase
    end
endmodule
