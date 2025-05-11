# AXI-Lite LFSR Module Explanation

This document provides a detailed breakdown of the `s_axil` Verilog module, which implements an AXI-Lite slave interface controlling a Linear Feedback Shift Register (LFSR), with data output through an AXI-Stream master interface.

## Module Overview

The module combines three main components:
1. An AXI-Lite slave interface for register-based control
2. An 8-bit LFSR (Linear Feedback Shift Register) for sequence generation
3. An AXI-Stream master interface for outputting the generated values

## 1. Module Architecture

### Parameters and Ports

**Parameters:**
- `C_AXIL_ADDR_WIDTH`: Address width for AXI-Lite (default: 4 bits)
- `C_AXIL_DATA_WIDTH`: Data width for AXI-Lite (default: 32 bits)

**Ports:**
- AXI-Lite slave interface signals (for receiving commands)
- AXI-Stream master interface signals (for sending LFSR output)
- Clock (`aclk`) and reset (`aresetn`) signals

### Register Map

The module exposes four registers via the AXI-Lite interface:
- `0x00`: `start_reg` - Start the LFSR
- `0x04`: `stop_reg` - Stop the LFSR
- `0x08`: `seed_reg` - Initial value for the LFSR (8 bits)
- `0x0C`: `taps_reg` - LFSR polynomial taps configuration (8 bits)

### Internal Logic

#### AXI-Lite Write Path
1. **Write Address Channel**: Handles `s_axi_awaddr` and `s_axi_awvalid`
   - Asserts `s_axi_awready` when ready to accept a write address
   
2. **Write Data Channel**: Processes `s_axi_wdata` and `s_axi_wvalid`
   - Decodes the address and writes to the appropriate register
   - Sets default values for registers on reset

3. **Write Response Channel**: Generates `s_axi_bresp` and `s_axi_bvalid`
   - Sends "OKAY" (2'b00) response after successful write

#### AXI-Lite Read Path
1. **Read Address Channel**: Handles `s_axi_araddr` and `s_axi_arvalid`
   - Asserts `s_axi_arready` when ready to accept a read address

2. **Read Data Channel**: Produces `s_axi_rdata`, `s_axi_rresp`, and `s_axi_rvalid`
   - Decodes the address and returns the value of the requested register
   - Sends "OKAY" (2'b00) response with the read data

#### LFSR Implementation
1. **LFSR Control Logic**:
   - Initializes the LFSR with `seed_reg` when `start_reg` is asserted
   - Stops the LFSR when `stop_reg` is asserted
   - Uses `taps_reg` to determine which bits contribute to the feedback

2. **LFSR Operation**:
   - Calculates feedback by XORing selected bits (determined by `taps_reg`)
   - Shifts the LFSR register and inserts the feedback bit
   - Sets `lfsr_output_valid` flag when new data is available

#### AXI-Stream Master
1. **Output Data Generation**:
   - Transmits the LFSR data through `m_axis_tdata` 
   - Asserts `m_axis_tvalid` when data is ready
   - Respects `m_axis_tready` handshaking signal from downstream

### Flow of Operation

1. The host writes to the registers via AXI-Lite to configure the LFSR
2. When the host sets `start_reg`, the LFSR begins operation
3. The LFSR continuously generates new values based on its current state and taps
4. Each generated value is output through the AXI-Stream interface
5. The host can stop the LFSR by setting `stop_reg`

## 2. Always Block Detailed Explanation

Below is a detailed explanation of each `always` block in the module:

### 2.1 Write Address Channel Block

```verilog
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        s_axi_awready <= 1'b0;
    end else begin
        if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
            s_axi_awready <= 1'b1;
        end else begin
            s_axi_awready <= 1'b0;
        end
    end
end
```

This block handles the AXI-Lite write address channel:
- On reset (`!aresetn`), it initializes `s_axi_awready` to 0 (not ready)
- It asserts `s_axi_awready` (sets to 1) when:
  - The module is currently not ready to accept an address (`~s_axi_awready`)
  - The master has a valid address to send (`s_axi_awvalid`)
  - The master has valid data to send (`s_axi_wvalid`)
- It deasserts `s_axi_awready` (sets to 0) in all other cases
- This implements a single-cycle handshake for accepting the write address

### 2.2 Write Data Channel Block

```verilog
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        s_axi_wready <= 1'b0;
        start_reg <= 1'b0;
        stop_reg <= 1'b0;
        seed_reg <= 8'h01; // Default non-zero seed
        taps_reg <= 8'b10001110; // Default polynomial tap configuration
    end else begin
        if (~s_axi_wready && s_axi_awvalid && s_axi_wvalid) begin
            s_axi_wready <= 1'b1;
            
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
        end else begin
            s_axi_wready <= 1'b0;
        end
    end
end
```

This block handles the AXI-Lite write data channel:
- On reset, it initializes:
  - `s_axi_wready` to 0 (not ready)
  - `start_reg` to 0 (LFSR not started)
  - `stop_reg` to 0 (LFSR not stopped)
  - `seed_reg` to 0x01 (default non-zero seed)
  - `taps_reg` to 0x8E (default LFSR polynomial configuration)
- When ready to accept data (`~s_axi_wready`) and valid address and data are present (`s_axi_awvalid && s_axi_wvalid`):
  - Sets `s_axi_wready` to 1
  - Uses a case statement to decode the address (`s_axi_awaddr[3:0]`) and write to the appropriate register:
    - 0x0: Write to `start_reg` (single bit)
    - 0x4: Write to `stop_reg` (single bit)
    - 0x8: Write to `seed_reg` (8 bits)
    - 0xC: Write to `taps_reg` (8 bits)
- In all other cases, sets `s_axi_wready` to 0

### 2.3 Write Response Channel Block

```verilog
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        s_axi_bvalid <= 1'b0;
        s_axi_bresp <= 2'b0;
    end else begin
        if (s_axi_awready && s_axi_awvalid && s_axi_wready && s_axi_wvalid && ~s_axi_bvalid) begin
            s_axi_bvalid <= 1'b1;
            s_axi_bresp <= 2'b00; // OKAY response
        end else if (s_axi_bready && s_axi_bvalid) begin
            s_axi_bvalid <= 1'b0;
        end
    end
end
```

This block generates the AXI-Lite write response:
- On reset, it initializes `s_axi_bvalid` to 0 and `s_axi_bresp` to 0
- When a write transaction is completed (all handshakes occurred and response not yet sent):
  - Sets `s_axi_bvalid` to 1 to indicate a valid response
  - Sets `s_axi_bresp` to 2'b00 (OKAY) indicating successful write
- When the master acknowledges the response (`s_axi_bready && s_axi_bvalid`):
  - Deasserts `s_axi_bvalid` to complete the write transaction

### 2.4 Read Address Channel Block

```verilog
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        s_axi_arready <= 1'b0;
    end else begin
        if (~s_axi_arready && s_axi_arvalid) begin
            s_axi_arready <= 1'b1;
        end else begin
            s_axi_arready <= 1'b0;
        end
    end
end
```

This block handles the AXI-Lite read address channel:
- On reset, it initializes `s_axi_arready` to 0 (not ready)
- When not ready and a valid read address is presented (`~s_axi_arready && s_axi_arvalid`):
  - Sets `s_axi_arready` to 1 to accept the address
- In all other cases, sets `s_axi_arready` to 0
- This implements a single-cycle handshake for accepting the read address

### 2.5 Read Data Channel Block

```verilog
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        s_axi_rvalid <= 1'b0;
        s_axi_rresp <= 2'b0;
    end else begin
        if (s_axi_arready && s_axi_arvalid && ~s_axi_rvalid) begin
            s_axi_rvalid <= 1'b1;
            s_axi_rresp <= 2'b00; // OKAY response
            
            // Read from the appropriate register based on address
            case (s_axi_araddr[3:0])
                4'h0: s_axi_rdata <= {31'b0, start_reg};
                4'h4: s_axi_rdata <= {31'b0, stop_reg};
                4'h8: s_axi_rdata <= {24'b0, seed_reg};
                4'hC: s_axi_rdata <= {24'b0, taps_reg};
                default: s_axi_rdata <= 32'h0;
            endcase
        end else if (s_axi_rready && s_axi_rvalid) begin
            s_axi_rvalid <= 1'b0;
        end
    end
end
```

This block handles the AXI-Lite read data channel:
- On reset, it initializes `s_axi_rvalid` to 0 and `s_axi_rresp` to 0
- When a read address has been accepted and response not yet sent:
  - Sets `s_axi_rvalid` to 1 to indicate valid read data
  - Sets `s_axi_rresp` to 2'b00 (OKAY) indicating successful read
  - Uses a case statement to decode the address and set `s_axi_rdata`:
    - 0x0: Returns `start_reg` (zero-extended to 32 bits)
    - 0x4: Returns `stop_reg` (zero-extended to 32 bits)  
    - 0x8: Returns `seed_reg` (zero-extended to 32 bits)
    - 0xC: Returns `taps_reg` (zero-extended to 32 bits)
    - default: Returns 0
- When the master acknowledges the read data (`s_axi_rready && s_axi_rvalid`):
  - Deasserts `s_axi_rvalid` to complete the read transaction

### 2.6 LFSR Control Logic Block

```verilog
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
```

This block implements the LFSR control logic:
- On reset, it initializes:
  - `lfsr_reg` to 0 (LFSR value)
  - `lfsr_active` to 0 (LFSR not running)
  - `lfsr_output_valid` to 0 (no valid output)
- When start is requested and LFSR is not active:
  - Loads `seed_reg` into `lfsr_reg`
  - Sets `lfsr_active` to 1
  - Sets `lfsr_output_valid` to 1
- When stop is requested:
  - Sets `lfsr_active` to 0
  - Sets `lfsr_output_valid` to 0
- When the LFSR is active and downstream is ready for data:
  - Calculates feedback by XORing selected bits (determined by `taps_reg`)
  - Shifts the LFSR by 1 bit and inserts the feedback at the LSB
  - Sets `lfsr_output_valid` to 1
- Otherwise, it maintains `lfsr_output_valid` equal to `lfsr_active`

### 2.7 AXI-Stream Master Logic Block

```verilog
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
```

This block implements the AXI-Stream master interface:
- On reset, it initializes `m_axis_tvalid` to 0 and `m_axis_tdata` to 0
- When LFSR has valid output and downstream is ready for data:
  - Sets `m_axis_tdata` to the LFSR value (zero-extended to 32 bits)
  - Sets `m_axis_tvalid` to 1 to indicate valid data
- When downstream is ready but no valid LFSR data:
  - Sets `m_axis_tvalid` to 0
- This ensures proper AXI-Stream handshaking

## 3. Output Waveforms

The following waveforms illustrate the operation of the AXI-Lite LFSR module in action:

### 3.1 AXI-Lite Write Transaction

This waveform shows a complete AXI-Lite write transaction to configure the LFSR:

![AXI-Lite Write Transaction Waveform][waveform1]

The waveform depicts:
- Initial assertion of `s_axi_awvalid` and `s_axi_wvalid` by the master
- Response with `s_axi_awready` and `s_axi_wready` by the slave
- Completion of the transaction with `s_axi_bvalid` and acknowledgment with `s_axi_bready`

### 3.2 LFSR Operation and Output Stream

This waveform shows the LFSR operation after being started and its output through the AXI-Stream interface:

![LFSR Operation and AXI-Stream Output Waveform][waveform2]

The waveform illustrates:
- Loading of the seed value
- Generation of successive LFSR values
- Handshaking between the AXI-Stream master and slave
- Continuous streaming of LFSR data values

[waveform1]: waveforms/waveform1.jpg
[waveform2]: waveforms/waveform2.jpg