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
        // Default values
        branch = 0;
        memRead = 0;
        memtoReg = 0;
        ALUOp = 2'b00;
        memWrite = 0;
        ALUSrc = 0;
        regWrite = 0;
        
        case (opcode)
            7'b0110011: begin // R-type (add, sub, etc.)
                regWrite = 1;
                ALUOp = 2'b10;
            end
            
            7'b0010011: begin // I-type (addi, etc.)
                regWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b10;
            end
            
            7'b0000011: begin // I-type (lw, etc.)
                memRead = 1;
                regWrite = 1;
                ALUSrc = 1;
                memtoReg = 1;
            end
            
            7'b0100011: begin // S-type (sw, etc.)
                memWrite = 1;
                ALUSrc = 1;
            end
            
            7'b1100011: begin // B-type (beq, bne, etc.)
                branch = 1;
                ALUOp = 2'b01;
            end
            
            default: begin
                // Default values already set
            end
        endcase
    end
endmodule