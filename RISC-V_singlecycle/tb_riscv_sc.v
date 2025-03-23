`timescale 1ns/1ps

module tb_riscv_sc;
// CPU Testbench

reg clk;
reg start;

// Instantiate the SingleCycleCPU
SingleCycleCPU riscv_DUT(clk, start);

// Clock Generation: Toggle every 5 time units
initial forever #5 clk = ~clk;

initial begin
    // Initialize signals
    clk = 0;
    start = 0;
    
    // Enable VCD waveform dumping
    $dumpfile("riscv_sc_tb.vcd");  // VCD file for GTKWave
    $dumpvars(0, tb_riscv_sc);      // Dump all variables in this module
    
    // Start simulation
    #10 start = 1;

    // Run simulation for 3000 time units
    #3000 $finish;
end

endmodule
