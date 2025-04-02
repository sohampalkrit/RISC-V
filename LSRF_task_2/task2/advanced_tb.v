`timescale 1ns / 1ps

module tb_s_m_hist();

    // Parameters
    parameter NUM_BINS = 8;
    parameter CLK_PERIOD = 10; // 100 MHz clock

    // Signals
    reg aclk;
    reg aresetn;
    
    // AXI-Stream Slave Interface (Input from LFSR)
    reg [31:0] s_axis_tdata;
    reg s_axis_tvalid;
    wire s_axis_tready;
    
    // AXI-Stream Master Interface (Output to AXI RAM)
    wire [31:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    
    // Control Signals
    wire [7:0] wr_addr;
    wire [31:0] wr_data;
    wire wr_en;
    
    reg [7:0] rd_addr;
    reg rd_en;
    wire [31:0] rd_data;
    
    // Test variables (declared at module level)
    integer i, j;
    reg [7:0] test_data;
    integer bin_counts [0:NUM_BINS-1];
    integer expected_counts [0:NUM_BINS-1];
    integer bin_to_check;
    integer base_addr;
    integer addr_offset;
    
    // Instantiate the DUT
    s_m_hist dut (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // AXI-Stream Slave Interface
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        
        // AXI-Stream Master Interface
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        
        // Control Signals
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_en(wr_en),
        
        .rd_addr(rd_addr),
        .rd_en(rd_en),
        .rd_data(rd_data)
    );
    
    // Clock generation
    initial begin
        aclk = 1'b0;
        forever #(CLK_PERIOD/2) aclk = ~aclk;
    end
    
    // Reset generation
    initial begin
        aresetn = 1'b0;
        #(CLK_PERIOD*2) aresetn = 1'b1;
    end
    
    // Initialize expected counts
    initial begin
        for (i = 0; i < NUM_BINS; i = i + 1) begin
            expected_counts[i] = 0;
        end
    end
    
    // Main test sequence
    initial begin
        // Initialize signals
        s_axis_tvalid = 1'b0;
        m_axis_tready = 1'b1;
        rd_en = 1'b0;
        
        // Wait for reset to complete
        wait(aresetn == 1'b1);
        #(CLK_PERIOD*2);
        
        // Test 1: Send uniform random data (100 values)
        $display("Test 1: Sending 100 uniform random values");
        for (i = 0; i < 100; i = i + 1) begin
            // Generate random value between 1-255
            test_data = $random & 8'hFF;
            if (test_data == 0) test_data = 1; // Ensure value is 1-255
            s_axis_tdata = {24'h0, test_data};
            s_axis_tvalid = 1'b1;
            
            // Wait for ready signal
            while (s_axis_tready != 1'b1) @(posedge aclk);
            @(posedge aclk);
            
            // Calculate expected bin
            if (test_data >= 1 && test_data <= 32)
                expected_counts[0] = expected_counts[0] + 1;
            else if (test_data >= 33 && test_data <= 64)
                expected_counts[1] = expected_counts[1] + 1;
            else if (test_data >= 65 && test_data <= 96)
                expected_counts[2] = expected_counts[2] + 1;
            else if (test_data >= 97 && test_data <= 128)
                expected_counts[3] = expected_counts[3] + 1;
            else if (test_data >= 129 && test_data <= 160)
                expected_counts[4] = expected_counts[4] + 1;
            else if (test_data >= 161 && test_data <= 192)
                expected_counts[5] = expected_counts[5] + 1;
            else if (test_data >= 193 && test_data <= 224)
                expected_counts[6] = expected_counts[6] + 1;
            else
                expected_counts[7] = expected_counts[7] + 1;
                
            // Random delay between transactions
            #((($random & 3) + 1)*CLK_PERIOD);
            s_axis_tvalid = 1'b0;
        end
        
        // Wait for all writes to complete
        $display("Waiting for all writes to complete...");
        #(CLK_PERIOD*100);
        
        // Verify bin counts
        $display("Verifying bin counts...");
        for (i = 0; i < NUM_BINS; i = i + 1) begin
            rd_addr = i << 2; // Addresses are 0x00, 0x04, 0x08, etc.
            rd_en = 1'b1;
            @(posedge aclk);
            rd_en = 1'b0;
            
            $display("Bin %0d: Expected = %0d, Actual = %0d", 
                     i, expected_counts[i], rd_data);
                     
            if (rd_data !== expected_counts[i]) begin
                $display("ERROR: Bin %0d count mismatch! Expected %0d, got %0d", 
                      i, expected_counts[i], rd_data);
            end
        end
        
        // Test 2: Verify data storage (check a few random bins)
        $display("\nTest 2: Verifying data storage for random bins");
        for (i = 0; i < 3; i = i + 1) begin
            bin_to_check = ($random & 7); // Random bin 0-7
            base_addr = 32 + (bin_to_check * 32);
            
            $display("Checking bin %0d (base addr 0x%0h)", bin_to_check, base_addr);
            
            // Check a few addresses in this bin
            for (j = 0; j < 3; j = j + 1) begin
                addr_offset = ($random & 31);
                rd_addr = base_addr + addr_offset;
                rd_en = 1'b1;
                @(posedge aclk);
                rd_en = 1'b0;
                
                $display("  Addr 0x%0h: Value = 0x%0h", rd_addr, rd_data);
            end
        end
        
        // Test 3: Backpressure test
        $display("\nTest 3: Backpressure test");
        m_axis_tready = 1'b0; // Stop accepting data
        
        // Send 10 values while backpressured
        for (i = 0; i < 10; i = i + 1) begin
            test_data = ($random & 8'hFF);
            if (test_data == 0) test_data = 1;
            s_axis_tdata = {24'h0, test_data};
            s_axis_tvalid = 1'b1;
            
            // Wait for ready signal (should not come)
            #(CLK_PERIOD);
            if (s_axis_tready) begin
                $display("ERROR: s_axis_tready should be 0 during backpressure");
            end
            
            @(posedge aclk);
            s_axis_tvalid = 1'b0;
            #(CLK_PERIOD);
        end
        
        // Release backpressure
        m_axis_tready = 1'b1;
        #(CLK_PERIOD*50); // Let the module process queued data
        
        $display("\nAll tests completed");
        $finish;
    end
    
    // Monitor for AXI writes
    always @(posedge aclk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("AXI Write: Addr = 0x%0h, Data = 0x%0h", 
                    m_axis_tdata[23:16], m_axis_tdata[7:0]);
        end
    end
    
    // Simulation timeout
    initial begin
        #1000000 $display("Simulation timeout");
        $finish;
    end

endmodule