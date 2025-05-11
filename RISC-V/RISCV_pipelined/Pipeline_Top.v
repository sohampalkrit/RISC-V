`include "FetchCycle.v"
`include "DecodeCycle.v"
`include "ExecutionCycle.v"
`include "MemoryCycle.v"
`include "WriteBackCycle.v"

module Pipeline_Top(
    input clk, 
    input rst, 
    input start
);

    // Declaration of Interim Wires
    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE;
    wire RegWriteM, MemWriteM, ResultSrcM;
    wire ResultSrcW;
    wire [3:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW, RS1_D, RS2_D;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0] RS1_E, RS2_E;

    // Fetch Stage
    fetch_cycle Fetch (
        .clk(clk), 
        .rst(rst), 
        .PCSrcE(PCSrcE), 
        .PCTargetE(PCTargetE), 
        .InstrD(InstrD), 
        .PCD(PCD), 
        .PCPlus4D(PCPlus4D)
    );

    // Decode Stage
    decode_cycle Decode (
        .clk(clk), 
        .rst(rst), 
        .InstrD(InstrD), 
        .PCD(PCD), 
        .PCPlus4D(PCPlus4D), 
        .RegWriteW(RegWriteW), 
        .RDW(RDW), 
        .ResultW(ResultW), 
        .RS1_D(RS1_D),
        .RS2_D(RS2_D),
        .RegWriteE(RegWriteE), 
        .ALUSrcE(ALUSrcE), 
        .MemWriteE(MemWriteE), 
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JumpE(JumpE),  
        .ALUControlE(ALUControlE), 
        .RD1_E(RD1_E), 
        .RD2_E(RD2_E), 
        .Imm_Ext_E(Imm_Ext_E), 
        .RD_E(RD_E), 
        .PCE(PCE), 
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E)
    );

    // Execute Stage
    execute_cycle Execute (
        .clk(clk), 
        .rst(rst), 
        .RegWriteE(RegWriteE), 
        .ALUSrcE(ALUSrcE), 
        .MemWriteE(MemWriteE), 
        .ResultSrcE(ResultSrcE), 
        .BranchE(BranchE), 
        .JumpE(JumpE),
        .ALUControlE(ALUControlE), 
        .RD1_E(RD1_E), 
        .RD2_E(RD2_E), 
        .Imm_Ext_E(Imm_Ext_E), 
        .RD_E(RD_E), 
        .PCE(PCE), 
        .PCPlus4E(PCPlus4E), 
        .PCSrcE(PCSrcE), 
        .PCTargetE(PCTargetE), 
        .RegWriteM(RegWriteM), 
        .MemWriteM(MemWriteM), 
        .ResultSrcM(ResultSrcM), 
        .RD_M(RD_M), 
        .PCPlus4M(PCPlus4M), 
        .WriteDataM(WriteDataM), 
        .ALU_ResultM(ALU_ResultM)
    );
    
    // Memory Stage
    memory_cycle Memory (
        .clk(clk), 
        .rst(rst), 
        .RegWriteM(RegWriteM), 
        .MemWriteM(MemWriteM), 
        .ResultSrcM(ResultSrcM), 
        .RD_M(RD_M), 
        .PCPlus4M(PCPlus4M), 
        .WriteDataM(WriteDataM), 
        .ALU_ResultM(ALU_ResultM), 
        .RegWriteW(RegWriteW), 
        .ResultSrcW(ResultSrcW), 
        .RD_W(RDW), 
        .PCPlus4W(PCPlus4W), 
        .ALU_ResultW(ALU_ResultW), 
        .ReadDataW(ReadDataW)
    );

    // Write Back Stage
    writeback_cycle WriteBack (
        .clk(clk), 
        .rst(rst), 
        .ResultSrcW(ResultSrcW), 
        .PCPlus4W(PCPlus4W), 
        .ALU_ResultW(ALU_ResultW), 
        .ReadDataW(ReadDataW), 
        .ResultW(ResultW)
    );

endmodule