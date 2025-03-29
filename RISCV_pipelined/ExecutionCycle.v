`include "ALU.v"
`include "Adder.v"

module execute_cycle(
    input clk, rst, 
    input RegWriteE, 
    input ALUSrcE, 
    input MemWriteE, 
    input ResultSrcE, 
    input BranchE, 
    input JumpE,
    input [3:0] ALUControlE,
    input [31:0] RD1_E, 
    input [31:0] RD2_E, 
    input [31:0] Imm_Ext_E, 
    input [4:0] RD_E,
    input [31:0] PCE, 
    input [31:0] PCPlus4E,

    output PCSrcE, 
    output RegWriteM, 
    output MemWriteM, 
    output ResultSrcM,
    output [4:0] RD_M, 
    output [31:0] PCPlus4M, 
    output [31:0] WriteDataM, 
    output [31:0] ALU_ResultM,
    output [31:0] PCTargetE
);

    // ALU Source Mux (Immediate vs Register)
    wire [31:0] Src_B;
    Mux2to1 alu_src_mux (
        .s0(RD2_E),
        .s1(Imm_Ext_E),
        .sel(ALUSrcE),
        .out(Src_B)
    );

    // ALU Unit
    wire [31:0] ALU_Result;
    wire ZeroE;
    ALU alu (
        .A(RD1_E),
        .B(Src_B),
        .Result(ALU_Result),
        .ALUControl(ALUControlE),
        .Zero(ZeroE)
    );

    // Branch Target Calculation
    Adder branch_adder (
        .a(PCE),
        .b(Imm_Ext_E),
        .sum(PCTargetE)
    );

    // Pipeline Registers (Execute to Memory)
    reg RegWriteM_r, MemWriteM_r, ResultSrcM_r;
    reg [4:0] RD_M_r;
    reg [31:0] PCPlus4M_r, WriteDataM_r, ALU_ResultM_r;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset all registers
            RegWriteM_r <= 0; 
            MemWriteM_r <= 0; 
            ResultSrcM_r <= 0;
            RD_M_r <= 0;
            PCPlus4M_r <= 0;
            WriteDataM_r <= 0;
            ALU_ResultM_r <= 0;
        end else begin
            // Normal pipeline progression
            RegWriteM_r <= RegWriteE; 
            MemWriteM_r <= MemWriteE; 
            ResultSrcM_r <= ResultSrcE;
            RD_M_r <= RD_E;
            PCPlus4M_r <= PCPlus4E;
            WriteDataM_r <= RD2_E;  // Unmodified RD2_E as we removed forwarding
            ALU_ResultM_r <= ALU_Result;
        end
    end

    // Output Assignments
    assign PCSrcE = (ZeroE & BranchE) | JumpE;
    assign RegWriteM = RegWriteM_r;
    assign MemWriteM = MemWriteM_r;
    assign ResultSrcM = ResultSrcM_r;
    assign RD_M = RD_M_r;
    assign PCPlus4M = PCPlus4M_r;
    assign WriteDataM = WriteDataM_r;
    assign ALU_ResultM = ALU_ResultM_r;

endmodule  
