`include "PC.v"
`include "InstructionMemory.v"
`include "Register.v"
`include "ImmGen.v"
`include "ALU.v"
`include "Control.v"
`include "DataMemory.v"
`include "Adder.v"
`include "Mux2to1.v"
`include "ALUCtrl.v"
`include "ShiftLeftOne.v"

module SingleCycleCPU (
    input clk,
    input start
);
    wire [31:0] PC_Top, RD_Inst, RD1_Top, RD2_Top, IMM_top, ALU_result, Read_data, pcPlus4, branchTarget;
    wire [31:0] ALU_B_input, shifted_imm, WB_data;
    wire Regwrite, memwrite, memRead, memToReg, ALUSrc, branch, zero, PC_Src;
    wire [1:0] ALU_OP_top;
    wire [3:0] ALUControl_Top;
    
    // Program Counter with fixed logic
    PC m_PC(
        .clk(clk),
        .rst(start),
        .pc_i(PC_Src ? branchTarget : pcPlus4),
        .pc_o(PC_Top)
    );
    
    // PC + 4 Adder
    Adder m_Adder_1(
        .a(PC_Top),
        .b(32'd4),
        .sum(pcPlus4)
    );
    
    // Instruction Memory
    InstructionMemory m_InstMem(
        .readAddr(PC_Top),
        .inst(RD_Inst)
    );
    
    // Control Unit
    Control_Unit m_Control(
        .opcode(RD_Inst[6:0]),
        .branch(branch),
        .memRead(memRead),
        .memtoReg(memToReg),
        .ALUOp(ALU_OP_top),
        .memWrite(memwrite),
        .ALUSrc(ALUSrc),
        .regWrite(Regwrite)
    );
    
    // Register File
    Register m_Register(
        .clk(clk),
        .rst(start),
        .regWrite(Regwrite),
        .readReg1(RD_Inst[19:15]),
        .readReg2(RD_Inst[24:20]),
        .writeReg(RD_Inst[11:7]),
        .writeData(WB_data),
        .readData1(RD1_Top),
        .readData2(RD2_Top)
    );
    
    // Immediate Generator
    ImmGen m_ImmGen(
        .In(RD_Inst),
        .Imm_Ext(IMM_top)
    );
    
    // Shift Immediate Left by 1 (for branch calculations)
    ShiftLeftOne m_ShiftLeftOne(
        .i(IMM_top),
        .o(shifted_imm)
    );
    
    // Branch Target Calculation
    Adder m_Adder_2(
        .a(PC_Top),
        .b(shifted_imm),
        .sum(branchTarget)
    );
    
    // Simplified branch logic - for BEQ instructions
    // In RISC-V, branch opcode is 1100011 (0x63)
    // For BEQ, funct3 is 000
    wire is_branch = (RD_Inst[6:0] == 7'b1100011);
    wire [2:0] funct3 = RD_Inst[14:12];
    
    // Determine branch outcome based on instruction type
    reg branch_taken;
    always @(*) begin
        branch_taken = 0; // Default: don't take branch
        
        if (is_branch) begin
            case (funct3)
                3'b000: branch_taken = zero;          // BEQ - branch if equal (zero=1)
                3'b001: branch_taken = ~zero;         // BNE - branch if not equal (zero=0)
                3'b100: branch_taken = ALU_result[0]; // BLT - branch if less than (signed)
                3'b101: branch_taken = ~ALU_result[0];// BGE - branch if greater/equal (signed)
                3'b110: branch_taken = ALU_result[0]; // BLTU - branch if less than (unsigned)
                3'b111: branch_taken = ~ALU_result[0];// BGEU - branch if greater/equal (unsigned)
                default: branch_taken = 0;
            endcase
        end
    end
    
    assign PC_Src = branch & branch_taken;
    
    // ALU Source Selection
    Mux2to1 #(.size(32)) m_Mux_ALU(
        .sel(ALUSrc),
        .s0(RD2_Top),
        .s1(IMM_top),
        .out(ALU_B_input)
    );
    
    // ALU Control Unit
    ALUCtrl m_ALUCtrl(
        .ALUOp(ALU_OP_top),
        .funct7(RD_Inst[31:25]),
        .funct3(RD_Inst[14:12]),
        .ALUControl(ALUControl_Top)
    );
    
    // ALU Execution
    ALU m_ALU(
        .A(RD1_Top),
        .B(ALU_B_input),
        .ALUControl(ALUControl_Top),
        .Result(ALU_result),
        .Zero(zero)
    );
    
    // Data Memory
    DataMemory m_DataMemory(
        .rst(start),
        .clk(clk),
        .memWrite(memwrite),
        .memRead(memRead),
        .address(ALU_result),
        .writeData(RD2_Top),
        .readData(Read_data)
    );
    
    // Write-Back MUX
    Mux2to1 #(.size(32)) m_WB_Mux(
        .sel(memToReg),
        .s0(ALU_result),
        .s1(Read_data),
        .out(WB_data)
    );
    
endmodule