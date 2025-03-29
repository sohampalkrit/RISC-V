module Data_Memory (
    input clk, rst, WE,
    input [31:0] A, WD,
    output reg [31:0] RD
);

    reg [31:0] mem [1023:0];

    // Pipeline Registers
    reg [31:0] A_reg, WD_reg, RD_reg;
    reg WE_reg;

    // Stage 1: Latch Inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 32'd0;
            WD_reg <= 32'd0;
            WE_reg <= 1'b0;
        end else begin
            A_reg <= A;
            WD_reg <= WD;
            WE_reg <= WE;
        end
    end

    // Stage 2: Perform Memory Read/Write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD_reg <= 32'd0;
        end else if (WE_reg) begin
            mem[A_reg] <= WD_reg;  // Memory Write
        end else begin
            RD_reg <= mem[A_reg];  // Memory Read
        end
    end

    // Stage 3: Output Latched Read Data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD <= 32'd0;
        end else begin
            RD <= RD_reg;
        end
    end

    // Initialize Memory
    initial begin
        mem[0] = 32'h00000000;
    end

endmodule
