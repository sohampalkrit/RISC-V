module s_axil #(
    parameter C_AXIL_ADDR_WIDTH = 4,
    parameter C_AXIL_DATA_WIDTH = 32
)(
    input aclk,
    input aresetn,

    // AXI-Lite Slave Interface
    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr,
    input                       s_axi_awvalid,
    output reg                  s_axi_awready,

    input  [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata,
    input                       s_axi_wvalid,
    output reg                  s_axi_wready,

    output reg [1:0]            s_axi_bresp,
    output reg                  s_axi_bvalid,
    input                       s_axi_bready,

    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr,
    input                       s_axi_arvalid,
    output reg                  s_axi_arready,

    output reg [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0]            s_axi_rresp,
    output reg                  s_axi_rvalid,
    input                       s_axi_rready,

    // AXI - Stream Master Interface
    output reg [C_AXIL_DATA_WIDTH-1:0] m_axis_tdata,
    output reg                    m_axis_tvalid,
    input                         m_axis_tready
);

    // Address map for these registers
    // 0x00 - start_reg
    // 0x04 - stop_reg
    // 0x08 - seed_reg
    // 0x0C - taps_reg

    // Registers
    reg start_reg;
    reg stop_reg;
    reg [7:0] seed_reg;
    reg [7:0] taps_reg;
    reg feedback;
    
    // LFSR State Register
    reg [7:0] lfsr_reg;
    reg lfsr_active;
    reg lfsr_output_valid;
    
    // Register to store read address
    reg [C_AXIL_ADDR_WIDTH-1:0] axi_araddr;
    
    // FIX: Initialize the ready signals to prevent protocol freeze
    initial begin
        s_axi_awready = 1'b1;
        s_axi_wready = 1'b1;
        s_axi_arready = 1'b1;
    end
    
    // Write Address Channel - FIXED
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b1;  // Initialize to HIGH
        end else begin
            if (s_axi_awready && s_axi_awvalid) begin
                s_axi_awready <= 1'b0;  // Address received, deassert ready
            end else if (~s_axi_bvalid) begin
                s_axi_awready <= 1'b1;  // Ready for next transaction
            end
        end
    end
    
    // Write Data Channel - FIXED
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_wready <= 1'b1;  // Initialize to HIGH
            start_reg <= 1'b0;
            stop_reg <= 1'b0;
            seed_reg <= 8'h01;     // Default non-zero seed
            taps_reg <= 8'b10001110; // Default polynomial tap configuration
        end else begin
            if (s_axi_wready && s_axi_wvalid) begin
                s_axi_wready <= 1'b0;  // Data received, deassert ready
                
                // Write to the appropriate register based on address
                case (s_axi_awaddr[3:0])
                    4'h0: start_reg <= s_axi_wdata[0];
                    4'h4: stop_reg <= s_axi_wdata[0];
                    4'h8: seed_reg <= s_axi_wdata[7:0];
                    4'hC: taps_reg <= s_axi_wdata[7:0];
                    default: begin
                        // No register to write to
                    end
                endcase
            end else if (~s_axi_bvalid) begin
                s_axi_wready <= 1'b1;  // Ready for next transaction
            end
        end
    end
    
    // Write Response Channel - FIXED
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_bvalid <= 1'b0;
            s_axi_bresp <= 2'b0;
        end else begin
            if (~s_axi_awready && ~s_axi_wready && ~s_axi_bvalid) begin
                // Both address and data received, generate response
                s_axi_bvalid <= 1'b1;
                s_axi_bresp <= 2'b00;  // OKAY response
            end else if (s_axi_bvalid && s_axi_bready) begin
                // Response accepted by master
                s_axi_bvalid <= 1'b0;
            end
        end
    end
    
    // Read Address Channel - FIXED
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_arready <= 1'b1;  // Initially ready for read address
            axi_araddr <= 0;
        end else begin
            if (s_axi_arready && s_axi_arvalid) begin
                axi_araddr <= s_axi_araddr;  // Capture the read address
                s_axi_arready <= 1'b0;       // Not ready for next address yet
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_arready <= 1'b1;       // Ready for next read address after current read completes
            end
        end
    end
    
    // Read Data Channel - FIXED
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rresp <= 2'b00;
            s_axi_rdata <= {C_AXIL_DATA_WIDTH{1'b0}};
        end else begin
            if (~s_axi_arready && ~s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;        // Assert valid when we have address data
                s_axi_rresp <= 2'b00;        // OKAY response
                
                // Read from registers based on captured address
                case (axi_araddr[3:0])
                    4'h0: s_axi_rdata <= {31'b0, start_reg};
                    4'h4: s_axi_rdata <= {31'b0, stop_reg};
                    4'h8: s_axi_rdata <= {24'b0, seed_reg};
                    4'hC: s_axi_rdata <= {24'b0, taps_reg};
                    default: s_axi_rdata <= 32'hDEADBEEF; // Return error value for debug
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;        // Clear valid after handshake completes
            end
        end
    end
    
    // LFSR control logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            lfsr_reg <= 8'h0;
            lfsr_active <= 1'b0;
            lfsr_output_valid <= 1'b0;
        end else begin
            // Ensure LFSR starts with the correct seed
            if (start_reg && !stop_reg && !lfsr_active) begin
                lfsr_reg <= seed_reg; // Load seed when starting
                lfsr_active <= 1'b1;
                lfsr_output_valid <= 1'b1;
            end else if (stop_reg) begin
                lfsr_active <= 1'b0;
                lfsr_output_valid <= 1'b0;
            end
            
            // If LFSR is active, generate next value
            if (lfsr_active && m_axis_tready) begin
                feedback = ^(lfsr_reg & taps_reg); // XOR taps
                lfsr_reg <= {lfsr_reg[6:0], feedback}; // Shift LFSR
                lfsr_output_valid <= 1'b1;
            end else begin
                lfsr_output_valid <= lfsr_active;
            end
        end
    end
    
    // AXI-Stream Master logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 32'h0;
        end else begin
            if (lfsr_output_valid && m_axis_tready) begin
                m_axis_tdata <= {24'h0, lfsr_reg};
                m_axis_tvalid <= 1'b1;
            end else if (m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule