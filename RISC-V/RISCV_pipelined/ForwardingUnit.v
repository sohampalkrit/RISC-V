module forwarding_unit(
    input [4:0] RS1_E, RS2_E, RD_M, RD_W,
    input RegWriteM, RegWriteW,
    output reg [1:0] ForwardA_E, ForwardB_E
);

    always @(*) begin
        // Default: No forwarding
        ForwardA_E = 2'b00;
        ForwardB_E = 2'b00;

        // Forward from Memory stage
        if (RegWriteM && (RD_M != 0) && (RD_M == RS1_E))
            ForwardA_E = 2'b10;
        
        if (RegWriteM && (RD_M != 0) && (RD_M == RS2_E))
            ForwardB_E = 2'b10;

        // Forward from Write Back stage
        if (RegWriteW && (RD_W != 0) && 
            (RD_W == RS1_E) && 
            !(RegWriteM && (RD_M != 0) && (RD_M == RS1_E)))
            ForwardA_E = 2'b01;
        
        if (RegWriteW && (RD_W != 0) && 
            (RD_W == RS2_E) && 
            !(RegWriteM && (RD_M != 0) && (RD_M == RS2_E)))
            ForwardB_E = 2'b01;
    end
endmodule