`include "PC.v"
`include "Mux2to1.v"
`include "InstructionMemory.v"


module fetch_cycle(
    input clk, 
    input rst, 
    input start,           // New port
    input PCSrcE, 
    input [31:0] PCTargetE,
    input StallF,          // New port 
    output [31:0] InstrD, 
    output [31:0] PCD, 
    output [31:0] PCPlus4D
);
    // Declaring interim wires
    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Declaration of Registers
    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;

    // PC Multiplexer - Choose between PC+4 and Branch Target
    Mux2to1 PC_MUX (
        .s0(PCPlus4F),
        .s1(PCTargetE),
        .sel(PCSrcE),
        .out(PC_F)
    );


    PC Program_Counter (
        .clk(clk),
        .rst(!start),
        .pc_o(PCF),
        .pc_i(PC_F)
    );

    // Instruction Memory
    InstructionMemory IMEM (
        .readAddr(PCF),
        .inst(InstrF)
    );

    // PC Adder
    Adder PC_adder (
        .a(PCF),
        .b(32'h00000004),
        .sum(PCPlus4F)
    );

    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
        end
        else begin
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F_reg <= PCPlus4F;
        end
    end

    // Assigning Registers Value to the Output port
    assign InstrD = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
    assign PCD = (rst == 1'b0) ? 32'h00000000 : PCF_reg;
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;

endmodule