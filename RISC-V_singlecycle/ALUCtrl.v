module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtl = 4'b0000; // Load/Store (LW, SW)  ADD
            2'b01: ALUCtl = (funct3 == 3'b000) ? 4'b0001 : // BEQ (SUB)
                           (funct3 == 3'b101) ? 4'b1010 : // BGT (Set Less Than)
                           4'b0000;
            2'b10: begin // R-Type instructions
                case (funct3)
                    3'b000: ALUCtl = (funct7) ? 4'b0001 : 4'b0000; // ADD (0000), SUB (0001)
                    3'b001: ALUCtl = 4'b0010; // SLL (Shift Left Logical)
                    3'b110: ALUCtl = 4'b0011; // OR
                    3'b111: ALUCtl = 4'b0100; // AND
                    default: ALUCtl = 4'b0000;
                endcase
            end
            default: ALUCtl = 4'b0000;
        endcase
    end
endmodule

