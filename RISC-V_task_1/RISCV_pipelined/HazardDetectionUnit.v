module HazardDetectionUnit(
    input [4:0] RS1_D, RS2_D, RD_E,
    input ResultSrcE, RegWriteM,
    output reg StallF, StallD, FlushE
);

    always @(*) begin
        // Default values
        StallF = 1'b0;
        StallD = 1'b0;
        FlushE = 1'b0;

        // Load-Use Hazard Detection
        if (ResultSrcE && ((RD_E == RS1_D) || (RD_E == RS2_D))) begin
            StallF = 1'b1;
            StallD = 1'b1;
            FlushE = 1'b1;
        end
    end
endmodule