`timescale 1ns / 1ps

module axi_ram(
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

    // Memory parameters
    parameter MEM_SIZE = 288;
    parameter MEM_ADDR_WIDTH = 8;
    
    // Memory array
    reg [7:0] mem [0:MEM_SIZE-1];
    
    // State machine states
    localparam [1:0] 
        IDLE = 2'b00,
        WRITE = 2'b01,
        READ = 2'b10;
    
    reg [1:0] state;
    reg [MEM_ADDR_WIDTH-1:0] read_addr;
    
    // Debug counters
    reg [31:0] write_operations;
    reg [31:0] read_operations;
    
    integer i; // For initialization loop

    // Initialize memory and registers
    initial begin
        state = IDLE;
        s_axis_tready = 1'b1;
        m_axis_tvalid = 1'b0;
        debug_rdata = 32'h0;
        read_addr = 0;
        write_operations = 0;
        read_operations = 0;
        
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 8'h0;
        end
    end

    // Main state machine
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            // Reset logic
            state <= IDLE;
            s_axis_tready <= 1'b1;
            m_axis_tvalid <= 1'b0;
            read_addr <= 0;
            write_operations <= 0;
            read_operations <= 0;
            
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                mem[i] <= 8'h0;
            end
        end
        else begin
            case (state)
                IDLE: begin
                    // Accept input data when valid
                    if (s_axis_tvalid && s_axis_tready) begin
                        state <= WRITE;
                        s_axis_tready <= 1'b0; // Not ready while processing
                    end
                end
                
                WRITE: begin
                    // Extract address from the correct position in the input data
                    if (s_axis_tdata[23:16] < MEM_SIZE) begin
                        // Store the data byte at the specified address
                        mem[s_axis_tdata[23:16]] <= s_axis_tdata[7:0];
                        write_operations <= write_operations + 1;
                    end
                    
                    // Return to IDLE state and indicate ready for next transaction
                    state <= IDLE;
                    s_axis_tready <= 1'b1;
                end
                
                READ: begin
                    // Only update tdata if not already valid (prevents overwriting during backpressure)
                    if (!m_axis_tvalid) begin
                        m_axis_tdata <= {24'h0, mem[read_addr]};
                        m_axis_tvalid <= 1'b1;
                        read_operations <= read_operations + 1;
                    end
                    
                    // When receiver is ready and data is valid, complete the transaction
                    if (m_axis_tready && m_axis_tvalid) begin
                        m_axis_tvalid <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // Debug read interface
    always @(posedge aclk) begin
        if (debug_rd_en) begin
            if (debug_addr < MEM_SIZE) begin
                // Return memory content at the specified address
                debug_rdata <= {24'h0, mem[debug_addr]};
                read_operations <= read_operations + 1;
            end
            else if (debug_addr == 8'hF0) begin
                // Return number of write operations
                debug_rdata <= write_operations;
            end
            else if (debug_addr == 8'hF4) begin
                // Return number of read operations
                debug_rdata <= read_operations;
            end
            else if (debug_addr == 8'hF8) begin
                // Return debug register indicating module is working
                debug_rdata <= 32'hABCD1234;
            end
            else begin
                debug_rdata <= 32'hDEADBEEF;
            end
        end
    end

endmodule