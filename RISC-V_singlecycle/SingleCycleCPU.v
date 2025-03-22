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
        wire [31:0] PC_Top, RD_Inst, RD1_Top, RD2_Top, IMM_top, ALU_result, Read_data, pcPLus4, branchTarget;
        wire [31:0] ALU_B_input, shifted_imm;
        wire Regwrite, memwrite, memRead, memToReg, ALUSrc, branch, zero, PC_Src;
        wire [1:0] ALU_OP_top;
        wire [3:0] ALUControl_Top;
        
        // When input start is zero, cpu should reset
        // When input start is high, cpu start running
        
        PC m_PC(
            .clk(clk),
            .rst(!start),
            .pc_i(PC_Src ? branchTarget : pcPLus4),
            .pc_o(PC_Top)
        );

        // PC + 4 adder
        Adder m_Adder_1(
            .a(PC_Top),
            .b(32'd4),
            .sum(pcPLus4)
        );

        InstructionMemory m_InstMem(
            .readAddr(PC_Top),
            .inst(RD_Inst)
        );

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
    
        Register m_Register(
            .clk(clk),
            .rst(!start),
            .regWrite(Regwrite),
            .readReg1(RD_Inst[19:15]),
            .readReg2(RD_Inst[24:20]),
            .writeReg(RD_Inst[11:7]),
            .writeData(memToReg ? Read_data : ALU_result),
            .readData1(RD1_Top),
            .readData2(RD2_Top)
        );
    
        ImmGen #(.Width(32)) m_ImmGen(
            .inst(RD_Inst),
            .imm(IMM_top)
        );

        // ShiftLeftOne for branch address calculation (for B-type instructions)
        ShiftLeftOne m_ShiftLeftOne(
            .i(IMM_top),
            .o(shifted_imm)
        );

        // Branch target calculation adder
        Adder m_Adder_2(
            .a(PC_Top),
            .b(shifted_imm),
            .sum(branchTarget)
        );

        // Branch logic - AND gate between branch control signal and ALU zero flag
        assign PC_Src = branch & zero;

        // ALU source mux
        Mux2to1 #(.size(32)) m_Mux_ALU(
            .sel(ALUSrc),
            .s0(RD2_Top),
            .s1(IMM_top),
            .out(ALU_B_input)
        );

        ALUCtrl m_ALUCtrl(
            .ALUOp(ALU_OP_top),
            .funct7(RD_Inst[30]), // Just the relevant bit from funct7
            .funct3(RD_Inst[14:12]),
            .ALUCtl(ALUControl_Top)
        );

        ALU m_ALU(
            .ALUCtl(ALUControl_Top),
            .A(RD1_Top),
            .B(ALU_B_input),
            .ALUOut(ALU_result),
            .zero(zero)
        );

        DataMemory m_DataMemory(
            .rst(!start),
            .clk(clk),
            .memWrite(memwrite),
            .memRead(memRead),
            .address(ALU_result),
            .writeData(RD2_Top),
            .readData(Read_data)
        );

        // MUX for memory to register is incorporated in the Register module
        
    endmodule