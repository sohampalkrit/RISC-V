`include "Control.v"
`include "ImmGen.v"
`include "Register.v"
`include "ALUCtrl.v"

module decode_cycle(
    input clk, rst, 
    input [31:0] InstrD, PCD, PCPlus4D, ResultW,
    input RegWriteW,
    input [4:0] RDW,
    output RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE,
    output [3:0] ALUControlE,
    output [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E,
    output [4:0] RS1_E, RS2_E, RD_E,
    output [4:0] RS1_D, RS2_D
);

    // Control Signals
    wire RegWriteD, ALUSrcD, MemWriteD, ResultSrcD, BranchD, JumpD;
    wire [1:0] ALUOpD;
    wire [3:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    // Pipeline Registers
    reg RegWriteD_r, ALUSrcD_r, MemWriteD_r, ResultSrcD_r, BranchD_r, JumpD_r;
    reg [3:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [31:0] PCD_r, PCPlus4D_r;

    // Assign RS1 and RS2 outputs (Used for forwarding/hazard detection)
    assign RS1_D = InstrD[19:15];
    assign RS2_D = InstrD[24:20];

    // Control Unit
    Control_Unit control (
        .opcode(InstrD[6:0]),
        .branch(BranchD),
        .memtoReg(ResultSrcD),
        .ALUOp(ALUOpD),
        .memWrite(MemWriteD),
        .ALUSrc(ALUSrcD),
        .regWrite(RegWriteD),
        .jump(JumpD)  // Jump signal added
    );

    // ALU Control
    ALUCtrl alu_control (
        .ALUOp(ALUOpD),
        .funct7(InstrD[31:25]),
        .funct3(InstrD[14:12]),
        .ALUControl(ALUControlD)
    );

    // Register File
    Register rf (
        .clk(clk),
        .rst(rst),
        .regWrite(RegWriteW),
        .writeData(ResultW),
        .readReg1(InstrD[19:15]),
        .readReg2(InstrD[24:20]),
        .writeReg(RDW),
        .readData1(RD1_D),
        .readData2(RD2_D)
    );

    // Immediate Generator
    ImmGen extension (
        .In(InstrD),
        .Imm_Ext(Imm_Ext_D)
    );

    // Pipeline Register Logic (Fetch → Decode)
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset all registers
            RegWriteD_r <= 0;
            ALUSrcD_r <= 0;
            MemWriteD_r <= 0;
            ResultSrcD_r <= 0;
            BranchD_r <= 0;
            JumpD_r <= 0;
            ALUControlD_r <= 4'b0000;
            RD1_D_r <= 0;
            RD2_D_r <= 0;
            Imm_Ext_D_r <= 0;
            RD_D_r <= 0;
            PCD_r <= 0;
            PCPlus4D_r <= 0;
            RS1_D_r <= 0;
            RS2_D_r <= 0;
        end 
        else begin
            // Normal pipeline progression
            RegWriteD_r <= RegWriteD;
            ALUSrcD_r <= ALUSrcD;
            MemWriteD_r <= MemWriteD;
            ResultSrcD_r <= ResultSrcD;
            BranchD_r <= BranchD;
            JumpD_r <= JumpD;
            ALUControlD_r <= ALUControlD;
            RD1_D_r <= RD1_D;
            RD2_D_r <= RD2_D;
            Imm_Ext_D_r <= Imm_Ext_D;
            RD_D_r <= InstrD[11:7];
            PCD_r <= PCD;
            PCPlus4D_r <= PCPlus4D;
            RS1_D_r <= InstrD[19:15];
            RS2_D_r <= InstrD[24:20];
        end
    end

    // Output Assignments
    assign RegWriteE = RegWriteD_r;
    assign ALUSrcE = ALUSrcD_r;
    assign MemWriteE = MemWriteD_r;
    assign ResultSrcE = ResultSrcD_r;
    assign BranchE = BranchD_r;
    assign JumpE = JumpD_r;
    assign ALUControlE = ALUControlD_r;
    assign RD1_E = RD1_D_r;
    assign RD2_E = RD2_D_r;
    assign Imm_Ext_E = Imm_Ext_D_r;
    assign RD_E = RD_D_r;
    assign PCE = PCD_r;
    assign PCPlus4E = PCPlus4D_r;
    assign RS1_E = RS1_D_r;
    assign RS2_E = RS2_D_r;

endmodule
