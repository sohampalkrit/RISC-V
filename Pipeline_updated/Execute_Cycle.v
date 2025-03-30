module execute_cycle(
    input clk, rst,
    input RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE,
    input [3:0] ALUControlE,
    input [31:0] RD1_E, RD2_E, Imm_Ext_E,
    input [4:0] RD_E,
    input [31:0] PCE, PCPlus4E,
    input [31:0] ResultW,
    input [1:0] ForwardA_E, ForwardB_E,
    output PCSrcE, RegWriteM, MemWriteM, ResultSrcM,
    output [4:0] RD_M,
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM, PCTargetE
);

    // Internal Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ALU_Result_Main, ALU_Result_Branch;
    wire ZeroE, Zero_Branch;
    wire UseBranchALU;

    // Mux for Source A
    Mux_3_by_1 srca_mux(
        .a(RD1_E), .b(ResultW), .c(ALU_ResultM), .s(ForwardA_E), .d(Src_A)
    );

    // Mux for Source B
    Mux_3_by_1 srcb_mux(
        .a(RD2_E), .b(ResultW), .c(ALU_ResultM), .s(ForwardB_E), .d(Src_B_interim)
    );
    
    // ALU Source Mux
    Mux alu_src_mux(
        .a(Src_B_interim), .b(Imm_Ext_E), .s(ALUSrcE), .c(Src_B)
    );

    // Main ALU for arithmetic and logic operations
    ALU alu_main (
        .A(Src_A), .B(Src_B), .Result(ALU_Result_Main),
        .ALUControl(ALUControlE), .OverFlow(), .Carry(), .Zero(ZeroE), .Negative()
    );

    // Branch ALU for PC calculations (only for branches)
    ALU alu_branch (
        .A(PCE), .B(Imm_Ext_E), .Result(ALU_Result_Branch),
        .ALUControl(4'b0000),  // Always performs addition for branch target
        .OverFlow(), .Carry(), .Zero(Zero_Branch), .Negative()
    );

    // ALU Selection Logic
    assign UseBranchALU = (BranchE);  // Only use branch ALU if branch condition is met
    assign ALU_ResultM = (UseBranchALU) ? ALU_Result_Branch : ALU_Result_Main;
    assign PCTargetE = ALU_Result_Branch;

    // Register Logic
    reg RegWriteE_r, MemWriteE_r, ResultSrcE_r;
    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteE_r <= 1'b0;
            MemWriteE_r <= 1'b0;
            ResultSrcE_r <= 1'b0;
            RD_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000;
            RD2_E_r <= 32'h00000000;
        end else begin
            RegWriteE_r <= RegWriteE;
            MemWriteE_r <= MemWriteE;
            ResultSrcE_r <= ResultSrcE;
            RD_E_r <= RD_E;
            PCPlus4E_r <= PCPlus4E;
            RD2_E_r <= Src_B_interim;
        end
    end

    // Output Assignments
    assign PCSrcE = (BranchE & ZeroE); // Ensure branch only happens on correct condition
    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign ResultSrcM = ResultSrcE_r;
    assign RD_M = RD_E_r;
    assign PCPlus4M = PCPlus4E_r;
    assign WriteDataM = RD2_E_r;

endmodule
