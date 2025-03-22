module tb_riscv_sc;
// Testbench for Single-Cycle RISC-V CPU

reg clk;
reg start;

// Instantiate the DUT (Device Under Test)
SingleCycleCPU riscv_DUT(clk, start);

// Clock Generation: Toggle every 5 time units
initial forever #5 clk = ~clk;

initial begin
    // Initialize signals
    clk = 0;
    start = 0;

    // Generate VCD file for GTKWave
    $dumpfile("riscv_sc_tb.vcd"); // VCD output file
    $dumpvars(0, tb_riscv_sc);     // Dump all variables in this module

    #10 start = 1;  // Start the CPU after 10 time units

    #3000 $finish;  // Stop simulation after 3000 time units
end

endmodule
