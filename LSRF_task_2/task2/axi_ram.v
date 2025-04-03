module axi_ram (
    input aclk,
    input aresetn,

    // AXI-Stream Slave Interface
    input [31:0] s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master Interface
    output reg [31:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,

    // Debug interface
    input [7:0] debug_addr,
    input debug_rd_en,
    output reg [31:0] debug_rdata
);

    // RAM storage - 256 bytes
    reg [7:0] memory [0:255];
    
    // Format: [31:24]=unused, [23:16]=address, [15:8]=unused, [7:0]=data
    wire [7:0] write_addr = s_axis_tdata[23:16];
    wire [7:0] write_data = s_axis_tdata[7:0];
    
    // Write state machine
    reg write_state;
    localparam WRITE_IDLE = 1'b0;
    localparam WRITE_ACK = 1'b1;
    
    // Initialize memory
    integer i;
    initial begin
        s_axis_tready = 1'b1;
        m_axis_tvalid = 1'b0;
        write_state = WRITE_IDLE;
        
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h0;
        end
    end
    
    // Write logic - handle incoming AXI-Stream data
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axis_tready <= 1'b1;
            write_state <= WRITE_IDLE;
            
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 8'h0;
            end
        end else begin
            case (write_state)
                WRITE_IDLE: begin
                    // Handle write requests from the AXI-Stream interface
                    if (s_axis_tvalid && s_axis_tready) begin
                        // Write data to memory
                        memory[write_addr] <= write_data;
                        
                        // Go to acknowledge state
                        s_axis_tready <= 1'b0;
                        write_state <= WRITE_ACK;
                    end
                end
                
                WRITE_ACK: begin
                    // Wait one cycle to acknowledge the write
                    // This simulates the delay of a real memory
                    s_axis_tready <= 1'b1;
                    write_state <= WRITE_IDLE;
                end
                
                default: begin
                    write_state <= WRITE_IDLE;
                    s_axis_tready <= 1'b1;
                end
            endcase
        end
    end
    
    // Read logic - handle debug reads
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            debug_rdata <= 32'h0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 32'h0;
        end else begin
            // Handle debug read requests
            if (debug_rd_en) begin
                debug_rdata <= {24'h0, memory[debug_addr]};
            end
            
            // Handle AXI-Stream read requests (if needed)
            if (m_axis_tready && m_axis_tvalid) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule