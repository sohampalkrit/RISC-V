module PC (
    input clk,
    input rst,
    input [31:0] pc_i,
    output reg [31:0] pc_o
);

always @(posedge clk or negedge rst) begin
    if (!rst) 
        pc_o <= 32'b0;  // Reset PC to 0 when rst is LOW
    else 
        pc_o <= pc_i;   // Update PC on rising clock edge
end

endmodule