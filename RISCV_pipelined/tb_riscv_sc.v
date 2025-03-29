`timescale 1ns/1ps

module Pipeline_Top_tb;

    reg clk;
    reg rst;
    reg start;

    // Instantiate the processor
    Pipeline_Top uut (
        .clk(clk),
        .rst(rst),
        .start(start)
    );

    // Clock generation (50 MHz -> 20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;

        // Dump file setup for GTKWave
        $dumpfile("Pipeline_Top_tb.vcd");  // VCD file for waveform
        $dumpvars(0, Pipeline_Top_tb);      // Dump all variables in this module

        // Reset sequence
        #20 rst = 0;  
        #20 rst = 1;
        #20 rst = 0;  

        // Start execution
        #40 start = 1;

        // Run simulation for 2000 ns
        #2000 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t, PC=%h, Instruction=%h", $time, uut.Fetch.InstrD, uut.Fetch.PCD);
    end

endmodule