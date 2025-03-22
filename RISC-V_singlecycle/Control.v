module Control_Unit (
    input [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite
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
        
        case (opcode)
            7'b0000011: begin // LW (Load Word)
                regWrite = 1;
                memRead  = 1;
                memtoReg = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Addition for address calculation
            end
            
            7'b0100011: begin // SW (Store Word)
                memWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00; // Addition for address calculation
            end
            
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR)
                regWrite = 1;
                ALUOp    = 2'b10; // ALU uses funct3 and funct7
            end
            
            7'b1100011: begin // BEQ, BGT (Branch)
                branch  = 1;
                ALUOp   = 2'b01; // Subtraction for comparison
            end
            
            7'b1101111: begin // JAL (Jump and Link)
                regWrite = 1;
                ALUOp    = 2'b00; // Changed from 2'bxx to avoid x propagation
            end
            
            7'b0010011: begin // I-type (ADDI, ORI, SLLI)
                regWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b11; // Immediate operations
            end
            
            default: begin // Undefined opcode
                regWrite = 0;
                branch   = 0;
                memRead  = 0;
                memWrite = 0;
                ALUSrc   = 0;
                ALUOp    = 2'b00;
            end
        endcase
    end
endmodule