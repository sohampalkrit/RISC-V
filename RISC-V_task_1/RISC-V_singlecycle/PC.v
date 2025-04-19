module PC (
    input clk,
    input rst,
    input [31:0] pc_i,    // Next PC value input
    output reg [31:0] pc_o // Current PC value output
);

    // On reset, PC is set to 0
    // On clock edge, PC is updated with next value
    always @(posedge clk or posedge rst) begin
        if (!rst)
            pc_o <= 32'h00000000;
        else
            pc_o <= pc_i;
    end

endmodule