
module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALU_ResultW, ReadDataW, ResultW);

// Declaration of IOs
input clk, rst, ResultSrcW;
input [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

output [31:0] ResultW;

// Declaration of Module
Mux2to1 result_mux (    
                .s0(ALU_ResultW),
                .s1(ReadDataW),
                .sel(ResultSrcW),
                .out(ResultW)
                );
endmodule