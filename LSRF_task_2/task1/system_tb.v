`timescale 1ns / 1ps

module s_axil_tb;

    reg aclk;
    reg aresetn;

    // AXI-Lite Write Address Channel
    reg [3:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;

    // AXI-Lite Write Data Channel
    reg [31:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;

    // AXI-Lite Write Response Channel
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;

    // AXI-Lite Read Address Channel
    reg [3:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;

    // AXI-Lite Read Data Channel
    wire [31:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready;

    // AXI-Stream signals
    wire [31:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;

    // Instantiate DUT
    s_axil dut (
        .aclk(aclk),
        .aresetn(aresetn),
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
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

    // Clock generation
    always #5 aclk = ~aclk;

    // Task for AXI Write Operation - SIMPLIFIED and FIXED
    task axi_write(input [3:0] addr, input [31:0] data);
        begin
            // Setup phase
            @(posedge aclk);
            s_axi_awaddr = addr;
            s_axi_awvalid = 1'b1;
            s_axi_wdata = data;
            s_axi_wvalid = 1'b1;
            s_axi_bready = 1'b1;
            
            // Wait for address and data to be accepted
            while (!(s_axi_awready && s_axi_wready)) @(posedge aclk);
            
            // Address and data accepted
            @(posedge aclk);
            s_axi_awvalid = 1'b0;
            s_axi_wvalid = 1'b0;
            
            // Wait for response
            while (!s_axi_bvalid) @(posedge aclk);
            
            // Complete transaction
            @(posedge aclk);
            s_axi_bready = 1'b0;
            
            // Gap between transactions
            @(posedge aclk);
            @(posedge aclk);
        end
    endtask

    // Task for AXI Read Operation - SIMPLIFIED and FIXED
    task axi_read(input [3:0] addr);
        begin
            // Setup phase
            @(posedge aclk);
            s_axi_araddr = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready = 1'b0;
            
            // Wait for address to be accepted
            while (!s_axi_arready) @(posedge aclk);
            
            // Address accepted
            @(posedge aclk);
            s_axi_arvalid = 1'b0;
            s_axi_rready = 1'b1;
            
            // Wait for data
            while (!s_axi_rvalid) @(posedge aclk);
            
            // Display read data
            $display("Read from address 0x%0h: 0x%0h", addr, s_axi_rdata);
            
            // Complete transaction
            @(posedge aclk);
            s_axi_rready = 1'b0;
            
            // Gap between transactions
            @(posedge aclk);
            @(posedge aclk);
        end
    endtask

    // Test Sequence
    initial begin
        // Initialize signals
        aclk = 0;
        aresetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        m_axis_tready = 1;

        // Dump file for waveform viewing
        $dumpfile("s_axil_tb.vcd");
        $dumpvars(0, s_axil_tb);

        // Reset sequence
        repeat(5) @(posedge aclk);
        aresetn = 1;
        repeat(2) @(posedge aclk);

        // Debug message
        $display("Starting AXI-Lite Test Sequence");
        
        // 1️⃣ Write seed value (Register @ 0x8)
        $display("\nWriting seed value 0xA5 to register 0x8");
        axi_write(4'h8, 32'h000000A5);
        $display("Seed register write completed");

        // 2️⃣ Write taps value (Register @ 0xC)
        $display("\nWriting taps value 0xB8 to register 0xC");
        axi_write(4'hC, 32'h000000B8);
        $display("Taps register write completed");

        // 3️⃣ Read back seed value (Register @ 0x8)
        $display("\nReading back seed value from register 0x8");
        axi_read(4'h8);

        // 4️⃣ Read back taps value (Register @ 0xC)
        $display("\nReading back taps value from register 0xC");
        axi_read(4'hC);

        // 5️⃣ Start LFSR (Control Register @ 0x0)
        $display("\nStarting LFSR by writing 1 to register 0x0");
        axi_write(4'h0, 32'h00000001);
        $display("LFSR start command sent");

        // 6️⃣ Read back control register (Register @ 0x0)
        $display("\nReading back control register 0x0");
        axi_read(4'h0);

        // Wait for LFSR outputs
        $display("\nWaiting for LFSR outputs...");
        repeat(10) @(posedge aclk);

        // 7️⃣ Stop LFSR (Control Register @ 0x4)
        $display("\nStopping LFSR by writing 1 to register 0x4");
        axi_write(4'h4, 32'h00000001);
        $display("LFSR stop command sent");

        // 8️⃣ Read back stop register (Register @ 0x4)
        $display("\nReading back stop register 0x4");
        axi_read(4'h4);

        // Final wait
        $display("\nTest complete");
        repeat(10) @(posedge aclk);
        $finish;
    end

    // Debug monitor for LFSR outputs
    initial begin
        forever begin
            @(posedge aclk);
            if (m_axis_tvalid && m_axis_tready) begin
                $display("LFSR Output: 0x%0h at time %0t", m_axis_tdata, $time);
            end
        end
    end

endmodule