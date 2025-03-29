module Forwarding_Unit(
    input [4:0] RS1_E, RS2_E,  // Source registers in EX stage
    input [4:0] RD_M, RD_W,    // Destination registers from MEM/WB stage
    input RegWriteM, RegWriteW, // Write enable signals from MEM/WB stage
    output reg [1:0] ForwardAE, ForwardBE // Forwarding control signals
);

always @(*) begin
    // Default: No Forwarding
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forward from MEM stage (EX/MEM pipeline register)
    if ((RegWriteM == 1'b1) && (RD_M != 5'b0) && (RD_M == RS1_E))
        ForwardAE = 2'b10;
    if ((RegWriteM == 1'b1) && (RD_M != 5'b0) && (RD_M == RS2_E))
        ForwardBE = 2'b10;

    // Forward from WB stage (MEM/WB pipeline register)
    if ((RegWriteW == 1'b1) && (RD_W != 5'b0) && (RD_W == RS1_E) && !(RegWriteM && (RD_M == RS1_E)))
        ForwardAE = 2'b01;
    if ((RegWriteW == 1'b1) && (RD_W != 5'b0) && (RD_W == RS2_E) && !(RegWriteM && (RD_M == RS2_E)))
        ForwardBE = 2'b01;
end

endmodule
