// Updated s_m_hist module to match your top level interface
module s_m_hist (
    input aclk,
    input aresetn,

    // AXI-Stream Slave Interface (Input from LFSR)
    input [31:0] s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master Interface (Output to AXI RAM)
    output reg [31:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,

    // Compatibility signals maintained for the top level
    output reg [7:0] wr_addr,
    output reg [31:0] wr_data,
    output reg wr_en,

    input [7:0] rd_addr,
    input rd_en,
    output reg [31:0] rd_data
);

    // Number of bins
    localparam NUM_BINS = 8;
    
    // State machine for data processing
    reg [2:0] state;
    localparam IDLE = 3'b000;
    localparam PROCESS = 3'b001;
    localparam WRITE_COUNT = 3'b010;
    localparam WAIT_COUNT_ACK = 3'b011;
    localparam WRITE_DATA = 3'b100;
    localparam WAIT_DATA_ACK = 3'b101;
    
    // Bin count registers - store how many values are in each bin
    reg [31:0] bin_counts [0:NUM_BINS-1];
    
    // Bin data pointers - track where to store the next value in each bin
    reg [7:0] bin_ptrs [0:NUM_BINS-1];
    
    // Temporary registers for bin calculation
    reg [7:0] current_value;
    reg [2:0] current_bin;
    reg [7:0] bin_storage_addr;
    reg [7:0] bin_count_addr;
    
    // Initialize registers and state
    integer i;
    initial begin
        state = IDLE;
        s_axis_tready = 1'b1;
        m_axis_tvalid = 1'b0;
        wr_en = 1'b0;
        
        // Initialize bin counts and pointers
        for (i = 0; i < NUM_BINS; i = i + 1) begin
            bin_counts[i] = 32'h0;
            bin_ptrs[i] = 8'h0;
        end
    end
    
    // Function to determine bin number based on input value
    function [2:0] get_bin;
        input [7:0] value;
        begin
            if (value <= 8'd32)  
                get_bin = 3'd0;
            else if (value >= 8'd33 && value <= 8'd64)
                get_bin = 3'd1;
            else if (value >= 8'd65 && value <= 8'd96)
                get_bin = 3'd2;
            else if (value >= 8'd97 && value <= 8'd128)
                get_bin = 3'd3;
            else if (value >= 8'd129 && value <= 8'd160)
                get_bin = 3'd4;
            else if (value >= 8'd161 && value <= 8'd192)
                get_bin = 3'd5;
            else if (value >= 8'd193 && value <= 8'd224)
                get_bin = 3'd6;
            else // value >= 8'd225 && value <= 8'd255
                get_bin = 3'd7;
        end
    endfunction
    
    // Function to calculate the base address for a bin's data storage
    function [7:0] get_bin_base_addr;
        input [2:0] bin_num;
        begin
            // Each bin gets 32 bytes starting at address 0x20
            get_bin_base_addr = 8'h20 + (bin_num << 5);
        end
    endfunction
    
    // Function to get the address for the bin count
    function [7:0] get_bin_count_addr;
        input [2:0] bin_num;
        begin
            // 4 bytes per count starting at address 0x00
            get_bin_count_addr = bin_num << 2;
        end
    endfunction
    
    // Main state machine - streamlined for direct AXI-Stream communication
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state <= IDLE;
            s_axis_tready <= 1'b1;
            m_axis_tvalid <= 1'b0;
            wr_en <= 1'b0;
            
            // Reset bin counts and pointers
            for (i = 0; i < NUM_BINS; i = i + 1) begin
                bin_counts[i] <= 32'h0;
                bin_ptrs[i] <= 8'h0;
            end
        end else begin
            case (state)
                IDLE: begin
                    // Ready to receive new data
                    s_axis_tready <= 1'b1;
                    wr_en <= 1'b0;
                    
                    // If valid data received, start processing
                    if (s_axis_tvalid && s_axis_tready) begin
                        // Extract 8-bit value from 32-bit data
                        current_value <= s_axis_tdata[7:0];
                        state <= PROCESS;
                        s_axis_tready <= 1'b0; // Not ready while processing
                    end
                end
                
                PROCESS: begin
                    // Determine which bin the value belongs to
                    current_bin <= get_bin(current_value);
                    
                    // Update bin count in local register
                    bin_counts[current_bin] <= bin_counts[current_bin] + 1;
                    
                    // Get addresses for writing
                    bin_count_addr <= get_bin_count_addr(current_bin);
                    bin_storage_addr <= get_bin_base_addr(current_bin) + bin_ptrs[current_bin];
                    
                    // Update pointer if bin is not full (max 31 items per bin)
                    if (bin_ptrs[current_bin] < 8'd31) begin
                        bin_ptrs[current_bin] <= bin_ptrs[current_bin] + 1;
                    end
                    
                    // Move to write count to AXI RAM
                    state <= WRITE_COUNT;
                end
                
                WRITE_COUNT: begin
                    // Format data for AXI RAM: [31:24]=0, [23:16]=addr, [15:8]=0, [7:0]=count LSB
                    m_axis_tdata <= {8'h0, bin_count_addr, 8'h0, bin_counts[current_bin][7:0]};
                    m_axis_tvalid <= 1'b1;
                    
                    // Also update compatibility signals
                    wr_addr <= bin_count_addr;
                    wr_data <= {24'h0, bin_counts[current_bin][7:0]};
                    wr_en <= 1'b1;
                    
                    state <= WAIT_COUNT_ACK;
                end
                
                WAIT_COUNT_ACK: begin
                    if (m_axis_tready && m_axis_tvalid) begin
                        // Transaction complete, clear valid
                        m_axis_tvalid <= 1'b0;
                        wr_en <= 1'b0;
                        
                        // Move to writing the data value
                        state <= WRITE_DATA;
                    end
                end
                
                WRITE_DATA: begin
                    // Format data for AXI RAM: [31:24]=0, [23:16]=addr, [15:8]=0, [7:0]=data value
                    m_axis_tdata <= {8'h0, bin_storage_addr, 8'h0, current_value};
                    m_axis_tvalid <= 1'b1;
                    
                    // Also update compatibility signals
                    wr_addr <= bin_storage_addr;
                    wr_data <= {24'h0, current_value};
                    wr_en <= 1'b1;
                    
                    state <= WAIT_DATA_ACK;
                end
                
                WAIT_DATA_ACK: begin
                    if (m_axis_tready && m_axis_tvalid) begin
                        // Transaction complete, clear valid
                        m_axis_tvalid <= 1'b0;
                        wr_en <= 1'b0;
                        
                        // Return to IDLE state, ready for next input
                        state <= IDLE;
                        s_axis_tready <= 1'b1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
    // Handle read requests - return full 32-bit values for bin counts
    always @(*) begin
        if (rd_en) begin
            // Check if reading bin counts or bin data
            if (rd_addr < 8'h20) begin
                // Reading bin counts (0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C)
                rd_data = bin_counts[rd_addr[4:2]]; // Maps address to bin index
            end else begin
                // Reading bin data would come from AXI RAM via external signals
                rd_data = 32'h0;
            end
        end else begin
            rd_data = 32'h0;
        end
    end

endmodule