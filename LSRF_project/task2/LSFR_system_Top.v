`include "axi_ram.v"
`include "saxl_lfsr.v"
`include "s_m_hist.v"
module histogram_system_top #(
    parameter AXIL_ADDR_WIDTH = 4,
    parameter AXIL_DATA_WIDTH = 32,
    parameter RAM_ADDR_WIDTH = 8,
    parameter RAM_DATA_WIDTH = 32
)(
    input aclk,
    input aresetn,
    
    // AXI-Lite Slave Interface for configuration
    input  [AXIL_ADDR_WIDTH-1:0] s_axi_awaddr,
    input                       s_axi_awvalid,
    output                      s_axi_awready,
    input  [AXIL_DATA_WIDTH-1:0] s_axi_wdata,
    input                       s_axi_wvalid,
    output                      s_axi_wready,
    output [1:0]                s_axi_bresp,
    output                      s_axi_bvalid,
    input                       s_axi_bready,
    input  [AXIL_ADDR_WIDTH-1:0] s_axi_araddr,
    input                       s_axi_arvalid,
    output                      s_axi_arready,
    output [AXIL_DATA_WIDTH-1:0] s_axi_rdata,
    output [1:0]                s_axi_rresp,
    output                      s_axi_rvalid,
    input                       s_axi_rready,
    
    // Debug interface for RAM access
    input [RAM_ADDR_WIDTH-1:0] debug_addr,
    input debug_rd_en,
    output [RAM_DATA_WIDTH-1:0] debug_rdata
);

    // Internal AXI-Stream connections
    wire [31:0] lfsr_to_hist_tdata;
    wire lfsr_to_hist_tvalid;
    wire lfsr_to_hist_tready;
    
    wire [31:0] hist_to_ram_tdata;
    wire hist_to_ram_tvalid;
    wire hist_to_ram_tready;
    
    // Compatibility signals (not used in this integration)
    wire [7:0] hist_wr_addr;
    wire [31:0] hist_wr_data;
    wire hist_wr_en;
    wire [7:0] hist_rd_addr;
    wire hist_rd_en;
    wire [31:0] hist_rd_data;
    
    // Unused RAM outputs
    wire [31:0] ram_to_nowhere_tdata;
    wire ram_to_nowhere_tvalid;
    
    // Instantiate LFSR module (s_axil)
    s_axil #(
        .C_AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .C_AXIL_DATA_WIDTH(AXIL_DATA_WIDTH)
    ) lfsr_inst (
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
        
        // Output stream to histogram module
        .m_axis_tdata(lfsr_to_hist_tdata),
        .m_axis_tvalid(lfsr_to_hist_tvalid),
        .m_axis_tready(lfsr_to_hist_tready)
    );
    
    // Instantiate Histogram Module (s_m_hist)
    s_m_hist hist_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // Input from LFSR
        .s_axis_tdata(lfsr_to_hist_tdata),
        .s_axis_tvalid(lfsr_to_hist_tvalid),
        .s_axis_tready(lfsr_to_hist_tready),
        
        // Output to RAM
        .m_axis_tdata(hist_to_ram_tdata),
        .m_axis_tvalid(hist_to_ram_tvalid),
        .m_axis_tready(hist_to_ram_tready),
        
        // Compatibility signals (not used)
        .wr_addr(hist_wr_addr),
        .wr_data(hist_wr_data),
        .wr_en(hist_wr_en),
        .rd_addr(hist_rd_addr),
        .rd_en(hist_rd_en),
        .rd_data(hist_rd_data)
    );
    
    // Instantiate AXI RAM module
    // Instantiate AXI RAM module
axi_ram #(
    //.ADDR_WIDTH(RAM_ADDR_WIDTH),
    //.DATA_WIDTH(RAM_DATA_WIDTH)
) ram_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    
    // Input from Histogram module
    .s_axis_tdata(hist_to_ram_tdata),
    .s_axis_tvalid(hist_to_ram_tvalid),  // FIXED: Connect to the actual valid signal
    .s_axis_tready(hist_to_ram_tready),
    
    // Master interface (unused in this integration)
    .m_axis_tdata(ram_to_nowhere_tdata),
    .m_axis_tvalid(ram_to_nowhere_tvalid),
    .m_axis_tready(1'b1), // Always ready since we don't use it
    
    // Debug interface
    .debug_addr(debug_addr),
    .debug_rd_en(debug_rd_en),
    .debug_rdata(debug_rdata)
);

endmodule