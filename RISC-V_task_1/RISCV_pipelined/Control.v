module Control_Unit (
    input [6:0] opcode,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite,
    output reg jump // Added Jump signal
);

    always @(*) begin
        // Default values
        branch = 0;
        memRead = 0;
        memtoReg = 0;
        ALUOp = 2'b00;
        memWrite = 0;
        ALUSrc = 0;
        regWrite = 0;
        jump = 0; // Default jump to 0

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, etc.)
                regWrite = 1;
                ALUOp = 2'b10;
            end
            
            7'b0010011: begin // I-type (ADDI, etc.)
                regWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b10;
            end
            
            7'b0000011: begin // I-type (LW, etc.)
                memRead = 1;
                regWrite = 1;
                ALUSrc = 1;
                memtoReg = 1;
            end
            
            7'b0100011: begin // S-type (SW, etc.)
                memWrite = 1;
                ALUSrc = 1;
            end
            
            7'b1100011: begin // B-type (BEQ, BNE, etc.)
                branch = 1;
                ALUOp = 2'b01;
            end
            
            7'b1101111: begin // J-type (JAL)
                jump = 1;
                regWrite = 1; // Stores return address in rd
            end
            
            7'b1100111: begin // I-type (JALR)
                jump = 1;
                regWrite = 1;
                ALUSrc = 1; // Uses immediate offset
            end

            7'b1110011: begin // Custom Instruction (CTZ)
                regWrite = 1;
                ALUOp = 2'b11; // Custom ALU operation
                ALUSrc = 0; // Only uses rs1
            end

            default: begin
                // Default values already set
            end
        endcase
    end
endmodule
