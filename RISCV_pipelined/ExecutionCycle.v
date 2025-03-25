`include "ALU.v"
`include "Mux_3_by_1.v"
`include "Adder.v"


module execute_cycle(
    input clk, rst, 
    input FlushE,
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
    input [31:0] ResultW,
    input [1:0] ForwardA_E, 
    input [1:0] ForwardB_E,

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

    // Declaration of Interim Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ResultE;
    wire ZeroE;

    // Declaration of Register
    reg RegWriteE_r, MemWriteE_r, ResultSrcE_r;
    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

    // 3 by 1 Mux for Source A (Forwarding)
    Mux_3_by_1 srca_mux (
        .s0(RD1_E),
        .s1(ResultW),
        .s2(ALU_ResultM),
        .sel(ForwardA_E),
        .out(Src_A)
    );

    // 3 by 1 Mux for Source B (Forwarding)
    Mux_3_by_1 srcb_mux (
        .s0(RD2_E),
        .s1(ResultW),
        .s2(ALU_ResultM),
        .sel(ForwardB_E),
        .out(Src_B_interim)
    );

    // ALU Source Mux (Immediate vs Register)
    Mux2to1 alu_src_mux (
        .s0(Src_B_interim),
        .s1(Imm_Ext_E),
        .sel(ALUSrcE),
        .out(Src_B)
    );

    // ALU Unit
    ALU alu (
        .A(Src_A),
        .B(Src_B),
        .ALUOut(ResultE),
        .ALUCtl(ALUControlE),
        .zero(ZeroE)
    );

    // Branch Target Adder
    Adder branch_adder (
        .a(PCE),
        .b(Imm_Ext_E),
        .sum(PCTargetE)
    );

    // Pipeline Register Logic with Flush Handling
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            // Reset all registers
            RegWriteE_r <= 1'b0; 
            MemWriteE_r <= 1'b0; 
            ResultSrcE_r <= 1'b0;
            RD_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000; 
            RD2_E_r <= 32'h00000000; 
            ResultE_r <= 32'h00000000;
        end
        else if(FlushE) begin
            // Flush: Clear control signals and invalidate the stage
            RegWriteE_r <= 1'b0; 
            MemWriteE_r <= 1'b0; 
            ResultSrcE_r <= 1'b0;
            RD_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000; 
            RD2_E_r <= 32'h00000000; 
            ResultE_r <= 32'h00000000;
        end
        else begin
            // Normal pipeline progression
            RegWriteE_r <= RegWriteE; 
            MemWriteE_r <= MemWriteE; 
            ResultSrcE_r <= ResultSrcE;
            RD_E_r <= RD_E;
            PCPlus4E_r <= PCPlus4E; 
            RD2_E_r <= Src_B_interim; 
            ResultE_r <= ResultE;
        end
    end

    // Output Assignments
    // PCSrcE now includes both Branch and Jump conditions
    assign PCSrcE = (ZeroE & BranchE) | JumpE;
    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign ResultSrcM = ResultSrcE_r;
    assign RD_M = RD_E_r;
    assign PCPlus4M = PCPlus4E_r;
    assign WriteDataM = RD2_E_r;
    assign ALU_ResultM = ResultE_r;

endmodule