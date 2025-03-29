module ImmGen (
    input [31:0] In,
    output reg [31:0] Imm_Ext
);
    wire [6:0] opcode;
    assign opcode = In[6:0];
    
    always @(*) begin
    case (opcode)
        7'b0000011: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I-type (load)
        7'b0010011: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I-type (arithmetic)
        7'b0100011: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; // S-type (store)
        7'b1100011: Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0}; // B-type (branch) (Shift Left by 1)
        7'b1101111: Imm_Ext = {{11{In[31]}}, In[19:12], In[20], In[30:21], 1'b0}; // J-type (jal) (Shift Left by 1)
        7'b1100111: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I-type (jalr)
        7'b0110111: Imm_Ext = {In[31:12], 12'b0}; // U-type (lui)
        7'b0010111: Imm_Ext = {In[31:12], 12'b0}; // U-type (auipc)
        default: Imm_Ext = 32'b0;
    endcase
end

endmodule