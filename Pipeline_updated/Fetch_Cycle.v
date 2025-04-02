
module fetch_cycle(
    input clk, rst,
    input PCSrcE, FlushE,
    input [31:0] PCTargetE,
    output [31:0] InstrD,
    output [31:0] PCD, PCPlus4D,
    output  PredictionF, // Pass the prediction to Decode
    output  [31:0] PredictedPCE // Predicted PC to Decode
);

    // Declaring interim wires
    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Branch Prediction BHT
    reg [31:0] BHT [0:15];  // Simple Branch History Table (16 entries)
    reg [3:0] BHT_index;    // Indexing BHT using lower PC bits
    reg PredictionF;         // Stores last branch prediction (1-bit)

    // Register for Fetch Cycle
    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;
    reg [31:0] PredictedPCE_reg;

    // Compute Branch Prediction Index
    always @(*) begin
        BHT_index = PCF[5:2];  // Extracting lower PC bits for indexing
        PredictionF = BHT[BHT_index];  // Fetch prediction from BHT
    end

    // Compute Predicted PC
    assign PredictedPCE = Prediction ? PCTargetE : PCPlus4F;

    // Modified PC Mux (Integrated Branch Prediction)
    Mux PC_MUX (
        .a(PCPlus4F),          // Default Next PC
        .b(PCTargetE),         // Target PC on branch taken
        .s(Prediction),        // Prediction selects branch or sequential
        .c(PC_F)               // Selected PC
    );

    // Program Counter Register
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            PCF_reg <= 32'h00000000;
        end else if (FlushE) begin
            PCF_reg <= PCTargetE; // Flush on misprediction
        end else begin
            PCF_reg <= PC_F;
        end
    end

    // Instruction Memory
    Instruction_Memory IMEM (
        .rst(rst),
        .A(PCF_reg),
        .RD(InstrF)
    );

    // PC Adder (Increment PC by 4)
    PC_Adder PC_adder (
        .a(PCF_reg),
        .b(32'h00000004),
        .c(PCPlus4F)
    );

    // Updating BHT Based on Actual Branch Outcome
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            BHT[BHT_index] <= 0;  // Reset branch predictor table
        end else if (PCSrcE) begin
            BHT[BHT_index] <= 1;  // Update predictor to "Taken"
        end else begin
            BHT[BHT_index] <= 0;  // Update predictor to "Not Taken"
        end
    end

    // Fetch Cycle Register Logic
    always @(posedge clk or negedge rst) begin
        if (!rst || FlushE) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
            PredictedPCE_reg <= 32'h00000000;
        end else begin
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F_reg <= PCPlus4F;
            PredictedPCE_reg <= PredictedPCE;
        end
    end

    // Assigning Outputs
    assign InstrD = rst ? InstrF_reg : 32'h00000000;
    assign PCD = rst ? PCF_reg : 32'h00000000;
    assign PCPlus4D = rst ? PCPlus4F_reg : 32'h00000000;
    assign PredictedPCE = rst ? PredictedPCE_reg : 32'h00000000;

endmodule
