module ImmGen #(
    parameter Width = 32
)(
    input [Width-1:0] inst,
    input [2:0] ImmSrc, // Control signal from Control Unit
    output reg signed [Width-1:0] imm
);
    always @(*) begin
        case (ImmSrc)
            3'b000:  imm = {{20{inst[31]}}, inst[31:20]};               // I-type (ADDI, LW)
            3'b001:  imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};   // S-type (SW)
            3'b010:  imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};  // B-type (BEQ, BNE)
            3'b011:  imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // J-type (JAL)
            3'b100:  imm = {inst[31:12], 12'b0};         // U-type (LUI, AUIPC)
            default: imm = 32'b0; // Default case
        endcase
    end
endmodule
