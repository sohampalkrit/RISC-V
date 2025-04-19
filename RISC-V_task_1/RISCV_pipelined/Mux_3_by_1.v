module Mux_3_by_1 #(
    parameter size = 32
) 
(
    input [1:0] sel,  // 2-bit select input
    input signed [size-1:0] s0,
    input signed [size-1:0] s1,
    input signed [size-1:0] s2,
    output reg signed [size-1:0] out // reg type for always block
);

always @(*) begin
    case(sel)
        2'b00: out = s0;
        2'b01: out = s1;
        2'b10: out = s2;
        default: out = s0; // Default case for safety
    endcase 
end

endmodule
