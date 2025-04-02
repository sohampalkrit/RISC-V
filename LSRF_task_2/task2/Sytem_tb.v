`timescale 1ns / 1ps

module histogram_system_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 100 MHz clock
    parameter AXIL_ADDR_WIDTH = 4;
    parameter AXIL_DATA_WIDTH = 32;
    parameter RAM_ADDR_WIDTH = 8;
    parameter RAM_DATA_WIDTH = 32;
    parameter NUM_CYCLE = 500; // Number of samples to generate
    
    // Testbench signals
    reg aclk = 0;
    reg aresetn = 0;
    
    // AXI-Lite interface signals
    reg [AXIL_ADDR_WIDTH-1:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    reg [AXIL_DATA_WIDTH-1:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    reg [AXIL_ADDR_WIDTH-1:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;
    wire [AXIL_DATA_WIDTH-1:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready;
    
    // Debug interface signals
    reg [RAM_ADDR_WIDTH-1:0] debug_addr;
    reg debug_rd_en;
    wire [RAM_DATA_WIDTH-1:0] debug_rdata;
    
    // Bin counters for histogram verification
    integer bin_counts[0:7];
    integer total_samples;
    
    // DUT (Device Under Test)
    histogram_system_top #(
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .RAM_DATA_WIDTH(RAM_DATA_WIDTH)
    ) dut (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // AXI-Lite interface
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        
        // Debug interface
        .debug_addr(debug_addr),
        .debug_rd_en(debug_rd_en),
        .debug_rdata(debug_rdata)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) aclk = ~aclk;
    
    // Tasks for AXI-Lite operations
    task axi_lite_write;
        input [AXIL_ADDR_WIDTH-1:0] addr;
        input [AXIL_DATA_WIDTH-1:0] data;
        begin
            // Set address
            s_axi_awaddr = addr;
            s_axi_awvalid = 1'b1;
            s_axi_wdata = data;
            s_axi_wvalid = 1'b1;
            s_axi_bready = 1'b1;
            
            // Wait for address ready
            wait(s_axi_awready);
            @(posedge aclk);
            
            // Address accepted, wait for write ready
            wait(s_axi_wready);
            @(posedge aclk);
            
            // Clear valid signals
            s_axi_awvalid = 1'b0;
            s_axi_wvalid = 1'b0;
            
            // Wait for write response
            wait(s_axi_bvalid);
            @(posedge aclk);
            
            // Response received
            s_axi_bready = 1'b0;
        end
    endtask
    
    task axi_lite_read;
        input [AXIL_ADDR_WIDTH-1:0] addr;
        output [AXIL_DATA_WIDTH-1:0] data;
        begin
            // Set address
            s_axi_araddr = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready = 1'b1;
            
            // Wait for address ready
            wait(s_axi_arready);
            @(posedge aclk);
            
            // Address accepted, clear valid
            s_axi_arvalid = 1'b0;
            
            // Wait for read data
            wait(s_axi_rvalid);
            data = s_axi_rdata;
            @(posedge aclk);
            
            // Data received
            s_axi_rready = 1'b0;
        end
    endtask
    
    // Task to check memory contents
    task check_memory;
        input [7:0] addr;
        output [7:0] data;
        begin
            debug_addr = addr;
            debug_rd_en = 1'b1;
            @(posedge aclk);
            @(posedge aclk);
            data = debug_rdata[7:0];
            debug_rd_en = 1'b0;
        end
    endtask
    
    // Task to display bin data
    task display_bin_data;
        input integer bin_num;
        input integer count;
        reg [7:0] data_val;
        integer i, max_display;
        begin
            max_display = (count > 5) ? 5 : count;
            
            $write("Values: ");
            for (i = 0; i < max_display; i = i + 1) begin
                check_memory(8'h20 + (bin_num * 32) + i, data_val);
                if (i > 0) $write(", ");
                $write("%d", data_val);
            end
            
            if (count > max_display) $write("...");
            $display("");
        end
    endtask
    
    // Function to determine bin for a value
    function integer get_bin;
        input [7:0] value;
        begin
            if (value <= 8'd32)
                get_bin = 0;
            else if (value >= 8'd33 && value <= 8'd64)
                get_bin = 1;
            else if (value >= 8'd65 && value <= 8'd96)
                get_bin = 2;
            else if (value >= 8'd97 && value <= 8'd128)
                get_bin = 3;
            else if (value >= 8'd129 && value <= 8'd160)
                get_bin = 4;
            else if (value >= 8'd161 && value <= 8'd192)
                get_bin = 5;
            else if (value >= 8'd193 && value <= 8'd224)
                get_bin = 6;
            else // value >= 8'd225 && value <= 8'd255
                get_bin = 7;
        end
    endfunction
    
    // Variables for testbench
    reg [31:0] read_data;
    reg [7:0] mem_data;
    integer i, bin, value, seed;
    
    // Main test sequence
    initial begin
        // Initialize
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_arvalid = 0;

        s_axi_rready = 0;
        debug_addr = 0;
        debug_rd_en = 0;
        total_samples = 0;
        
        // Initialize bin counts
        for (i = 0; i < 8; i = i + 1) begin
            bin_counts[i] = 0;
        end
        
        // Reset sequence
        aresetn = 0;
        #(CLK_PERIOD * 10);
        aresetn = 1;
        #(CLK_PERIOD * 5);
        
        // Initial setup - set seed and taps
        $display("Setting up LFSR with seed=0x01 and taps=0x8E (10001110)");
        axi_lite_write(4'h8, 32'h01);       // Set seed to 0x01
        axi_lite_write(4'hC, 32'h8E);       // Set taps to 0x8E (10001110)
        
        // Start LFSR
        // Add after starting the LFSR
$display("Starting LFSR");
axi_lite_write(4'h0, 32'h01);       // Set start_reg to 1

    
        // Wait for samples to be generated and processed
        $display("Generating %0d samples...", NUM_CYCLE);
        #(CLK_PERIOD * NUM_CYCLE * 5);
        
        // Stop LFSR
        $display("Stopping LFSR");
        axi_lite_write(4'h4, 32'h01);       // Set stop_reg to 1
        
        // Wait for all data to be processed
        #(CLK_PERIOD * 100);
        
        // Read bin counts from memory
        $display("\n---- Histogram Results ----");
        $display("Bin  | Range      | Count");
        $display("-----|------------|-------");
        
        for (i = 0; i < 8; i = i + 1) begin
            check_memory(i*4, mem_data);
            bin_counts[i] = mem_data;
            total_samples = total_samples + mem_data;
            
            // case (i)
            //     0: $display("Bin %0d | 1-32       | %4d", i, mem_data);
            //     1: $display("Bin %0d | 33-64      | %4d", i, mem_data);
            //     2: $display("Bin %0d | 65-96      | %4d", i, mem_data);
            //     3: $display("Bin %0d | 97-128     | %4d", i, mem_data);
            //     4: $display("Bin %0d | 129-160    | %4d", i, mem_data);
            //     5: $display("Bin %0d | 161-192    | %4d", i, mem_data);
            //     6: $display("Bin %0d | 193-224    | %4d", i, mem_data);
            //     7: $display("Bin %0d | 225-255    | %4d", i, mem_data);
            // endcase
            
            //display_bin_data(i, mem_data);
        end
        
        $display("-----|------------|-------");
        $display("Total|            | %4d", total_samples);
        
        // Generate histogram visualization
        $display("\n---- Histogram Visualization ----");
        for (i = 0; i < 8; i = i + 1) begin
            case (i)
                0: $write("Bin %0d | 1-32    | ", i);
                1: $write("Bin %0d | 33-64   | ", i);
                2: $write("Bin %0d | 65-96   | ", i);
                3: $write("Bin %0d | 97-128  | ", i);
                4: $write("Bin %0d | 129-160 | ", i);
                5: $write("Bin %0d | 161-192 | ", i);
                6: $write("Bin %0d | 193-224 | ", i);
                7: $write("Bin %0d | 225-255 | ", i);
            endcase
            
            // Print bar representing count
            for (seed = 0; seed < bin_counts[i]; seed = seed + 1) begin
                if (seed % 5 == 0) $write("#");
            end
            $display(" (%0d)", bin_counts[i]);
        end
        
        
        // Finish test
        $display("\nTest completed successfully!");
        #(CLK_PERIOD * 20);
        $finish;
    end
        // Add this at the end of the initial block (just before the endmodule)
    initial begin
        $dumpfile("histogram_system_tb.vcd");
        $dumpvars(0, histogram_system_tb);
    end



endmodule