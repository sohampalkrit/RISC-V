module ALU (
    input clk, rst,
    input [31:0] A, B,
    input [3:0] ALUControl,  
    output reg Carry, OverFlow, Zero, Negative,
    output reg [31:0] Result
);

    // Pipeline Registers
    reg [31:0] A_reg, B_reg, Result_reg;
    reg [3:0] ALUControl_reg;
    reg Carry_reg, OverFlow_reg, Zero_reg, Negative_reg;

    // Stage 1: Latching Inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 32'b0;
            B_reg <= 32'b0;
            ALUControl_reg <= 4'b0;
        end else begin
            A_reg <= A;
            B_reg <= B;
            ALUControl_reg <= ALUControl;
        end
    end

    // Stage 2: ALU Operations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Result_reg <= 32'b0;
            Carry_reg <= 1'b0;
            OverFlow_reg <= 1'b0;
            Zero_reg <= 1'b0;
            Negative_reg <= 1'b0;
        end else begin
            case (ALUControl_reg)
                4'b0000: Result_reg = A_reg + B_reg;  // ADD
                4'b0001: Result_reg = A_reg - B_reg;  // SUB
                4'b0010: Result_reg = A_reg & B_reg;  // AND
                4'b0011: Result_reg = A_reg | B_reg;  // OR
                4'b0100: Result_reg = A_reg ^ B_reg;  // XOR
                4'b0101: Result_reg = A_reg << B_reg[4:0];  // SLL (Shift Left Logical)
                4'b0110: Result_reg = ($signed(A_reg) < $signed(B_reg)) ? 32'b1 : 32'b0;  // SLT (Signed)
                4'b0111: Result_reg = (A_reg < B_reg) ? 32'b1 : 32'b0;  // SLTU (Unsigned)
                4'b1000: Result_reg = A_reg >> B_reg[4:0];  // SRL (Logical Shift Right)
                4'b1001: Result_reg = $signed(A_reg) >>> B_reg[4:0];  // SRA (Arithmetic Shift Right)
                default: Result_reg = 32'b0;
            endcase

            // Flags computation
            OverFlow_reg = (ALUControl_reg == 4'b0000 || ALUControl_reg == 4'b0001) ? 
                           ((A_reg[31] == B_reg[31]) && (Result_reg[31] != A_reg[31])) : 1'b0;
            Carry_reg = (ALUControl_reg == 4'b0000 || ALUControl_reg == 4'b0001) ? 
                        (A_reg[31] & B_reg[31]) | ((A_reg[31] | B_reg[31]) & ~Result_reg[31]) : 1'b0;
            Zero_reg = (Result_reg == 32'b0) ? 1'b1 : 1'b0;
            Negative_reg = Result_reg[31];
        end
    end

    // Stage 3: Latching Outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Result <= 32'b0;
            Carry <= 1'b0;
            OverFlow <= 1'b0;
            Zero <= 1'b0;
            Negative <= 1'b0;
        end else begin
            Result <= Result_reg;
            Carry <= Carry_reg;
            OverFlow <= OverFlow_reg;
            Zero <= Zero_reg;
            Negative <= Negative_reg;
        end
    end

endmodule
