/*
 * Clock Synchroniser Block
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 6th March 2020 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This module is designed to be a universal synchroniser for clock domain crossing. It is capable of operating
 * in several different modes:
 *
 * 1. Asynchronous Input
 *   This mode is designed for crossing pulse type signals - one in which the fact that there has been a HIGH pulse
 *   is more important than the pulse width. A trigger signal is a good example of this. Basically any case where
 *   it needs to be guaranteed that when there is a HIGH pulse on the input, that a pulse is present on the output.
 *
 * 2. Synchronise Chain
 *   In this mode the input signal is passed through a synchroniser chain of the required length. The signal is
 *   first clocked into a register using the input clock to pipeline it nearby the synchroniser logic, and then
 *   is passed through a chain of registers clocked by the output clock to avoid metastability.
 *
 * 3. w/ Input and/or Output Enable signals.
 *   This mode is useful when the signal width is more than one bit. The input register is controlled by the
 *   input enabled, and the very last register in the chain is controlled by the output enable. In this way,
 *   handshaking can be used, where the data can be loaded on to the input register, then a control signal
 *   can be sent using a second synchroniser. Once the control signal reaches the other side, it then can act
 *   as an enable for the output register allowing the data to be clocked across without glitches.
 *
 * 4. Edge Detector Output
 *   In all modes it is possible to add a rising edge detector on to the output. This is mostly useful for trigger
 *   applications where a single cycle output is needed, which cannot be otherwise guaranteed.
 *
 * The module uses Altera in-line attributes for cutting timing paths between the input clock domain and output
 * clock domain for the synchroniser chain to avoid timing errors due to the clocks being asynchronous.
 *
 */

module clock_synchroniser_hw #(
    parameter CHAIN_LEN         = 2,    //Number of register stages in synchroniser chain. 0 = no synchronisation.
    parameter SIGNAL_WIDTH      = 1,    //Width of the data signal
    parameter ASYNC_INPUT       = 1'b0, //Whether to use Asynchronous Input mode.
    parameter SYNC_NO_IN_BUF    = 1'b0, //Whether input buffer in Synchronous mode should be omitted - useful if in clock is unavailable.
    parameter SYNC_RESET_HIGH   = 64'b0,//Whether reset signal in Synchronous mode is a Preset rather than a Reset - 1 bit per signal width
    parameter RISING_EDGE       = 1'b0, //Whether to include a rising edge detector on the output.  \__ If both rising and falling, will add
    parameter FALLING_EDGE      = 1'b0, //Whether to include a falling edge detector on the output. /   detection of both edges. 
    parameter EDGE_BUFFERING    = 1,    //The number of clock cycles of pipelining in the edge detector.
    parameter HAS_INPUT_ENABLE  = 1'b0, //Whether to use the optional input clock enable
    parameter HAS_OUTPUT_ENABLE = 1'b0  //Whether to use the optional output clock enable.
)(
    input                     in_clock,
    input                     in_reset,
    input                     in_enable, //Unused if HAS_INPUT_ENABLE = 0
    input  [SIGNAL_WIDTH-1:0] in_signal,
    
    input                     out_clock,
    input                     out_reset,
    input                     out_enable, //Unused if HAS_OUTPUT_ENABLE = 0
    output [SIGNAL_WIDTH-1:0] out_signal,
    output [SIGNAL_WIDTH-1:0] out_signalRaw // Output signal prior to any edge detection. Equals out_signal if edge detector disabled.
);

reg [SIGNAL_WIDTH-1:0] in_buf = SYNC_RESET_HIGH[SIGNAL_WIDTH-1:0];

generate if (ASYNC_INPUT || SYNC_NO_IN_BUF) begin
    //if input is asynchronous or sync without in buffer, don't buffer it. 
    always @ * begin
        in_buf <= in_signal;
    end
end else begin
    //Otherwise we add a register stage which uses the input clock/reset.
    always @ (posedge in_clock or posedge in_reset) begin
        if (in_reset) begin
            in_buf <= SYNC_RESET_HIGH[SIGNAL_WIDTH-1:0];
        end else if (in_enable || !HAS_INPUT_ENABLE) begin //If the optional enable signal is not enabled, then always clock in the data, else only clock when disabled.
            in_buf <= in_signal;
        end
    end
end endgenerate

genvar i;
generate for (i = 0; i < SIGNAL_WIDTH; i = i + 1) begin : sync_loop
    
    wire sync_chain_in;  //Input of synchroniser chain
    wire sync_chain_out; //Output of synchroniser chain
    
    //Read correct bit of sync chain.
    assign sync_chain_in = in_buf[i];
    
    //Create clock synchroniser block for this bit
    if (CHAIN_LEN >= 1) begin
        clock_synchroniser_sync_block #(
            .CHAIN_LEN        (CHAIN_LEN),
            .ASYNC_INPUT      (ASYNC_INPUT),
            .HAS_OUTPUT_ENABLE(HAS_OUTPUT_ENABLE),
            .RESET_HIGH       (SYNC_RESET_HIGH[i])
        ) clock_synchroniser_sync_block_inst (
            .clock (out_clock     ),
            .reset (out_reset     ),
            .enable(out_enable    ),
            .in    (sync_chain_in ),
            .out   (sync_chain_out)
        );
    end else begin
        assign sync_chain_out = sync_chain_in;
    end
    
    //Raw is the output straight out of the sync chain.
    assign out_signalRaw[i] = sync_chain_out;
    
    //Determine if we need an edge detector on the output.
    if (RISING_EDGE || FALLING_EDGE) begin
        edge_detector_hw #(
            .RISING_EDGE(RISING_EDGE),
            .FALLING_EDGE(FALLING_EDGE),
            .BUFFER_OUTPUT(EDGE_BUFFERING)
        ) edge_detector (    
            .clock (out_clock     ),
            .reset (out_reset     ),
            .inEdge(sync_chain_out), //---.
            .qout  (out_signal[i] )
        );
    end else begin
        assign out_signal[i] = sync_chain_out;
    end
    
end endgenerate



endmodule



module clock_synchroniser_sync_block #(
    parameter CHAIN_LEN         = 2,  //>=1
    parameter ASYNC_INPUT       = 1,
    parameter HAS_OUTPUT_ENABLE = 0,
    parameter RESET_HIGH        = 0   //N/A for ASYNC_INPUT
)(
    input  clock,
    input  reset,
    input  enable,
    input  in,
    output out
);

// Input to synchroniser chain
wire sync_chain_in;

// Logic for input depends on whether we are an ASYNC input.
generate if (ASYNC_INPUT) begin : in_reg_async

    // For asynchronous input, sync_chain_aset uses in_buf as an asynchronous assert.
    (* preserve, altera_attribute = {"-name SDC_STATEMENT \"set_false_path -to [get_pins -compatibility_mode -nocase -nowarn *|sync_loop[*].clock_synchroniser_sync_block_inst|in_reg_async.sync_chain_aset*|*clr*]\""} *)
    reg [1:0] sync_chain_aset /* synthesis translate_off */ = 2'b11 /* synthesis translate_on */; //The first register in the synchroniser chain has been separated from the rest of the chain such that timing constraints can be specified.

    always @ (posedge clock or posedge in) begin
        if (in) begin
            //When the input signal is high, asynchronously assert the first registers in the chain - this ensures that any pulse on the input will always transfer across.
            sync_chain_aset <= 2'b11;
        end else begin
            //Otherwise clock through a zero
            sync_chain_aset <= {sync_chain_aset[0],1'b0};
        end
    end
    
    // sync_chain_aset is first register in chain
    assign sync_chain_in = sync_chain_aset[1];
    
end else begin : in_reg_sync

    // For synchronous input, sync_chain_sync replaces first buffer in reset chain, loaded without preset.
    (* preserve, altera_attribute = {"-name SDC_STATEMENT \"set_false_path -to [get_pins -compatibility_mode -nocase -nowarn *|sync_loop[*].clock_synchroniser_sync_block_inst|in_reg_sync.sync_chain_sync|*d*]\""} *)
    reg sync_chain_sync;
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            sync_chain_sync <= (RESET_HIGH ? 1'b1 : 1'b0);
        end else begin
            sync_chain_sync <= in;
        end
    end
    
    // sync_chain_sync is first register in chain
    assign sync_chain_in = sync_chain_sync;
    
end endgenerate

// Chain length is one less as we have the input register
localparam CHAIN_REM_LEN = CHAIN_LEN-1;

// Build remainder of the chain
generate if (CHAIN_REM_LEN > 0) begin
    // For chain lengths > 0, we need to build a register chain
    
    localparam CHAIN_RST_VAL = {(CHAIN_REM_LEN){ASYNC_INPUT ? 1'b1 : (RESET_HIGH ? 1'b1 : 1'b0)}};
    
    // Create preserved registers for our chain
    (* preserve *) reg [CHAIN_REM_LEN-1:0] sync_chain  /* synthesis translate_off */ = CHAIN_RST_VAL /* synthesis translate_on */;
    
    // Build the input to our chain
    wire [CHAIN_REM_LEN-1:0] chain_in;
    if (CHAIN_REM_LEN == 1) begin
        // If the length is 1, only use sync_chain_in
        assign chain_in = {sync_chain_in};
    end else begin
        // Otherwise use lower N-1 register and sync_chain_in
        assign chain_in = {sync_chain[CHAIN_REM_LEN-2:0], sync_chain_in};
    end
    
    //Build the chain itself
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            // Reset chain to reset value
            sync_chain <= CHAIN_RST_VAL;
        end else if (enable || !HAS_OUTPUT_ENABLE) begin
            // When enabled, clock the data through the synchroniser chain.
            sync_chain <= chain_in;
        end
    end
    
    // The output is connected to the last register in the synchroniser chain.
    assign out = sync_chain[CHAIN_REM_LEN-1];
    
end else begin

    // Otherwise our input synchroniser is all that was requested
    assign out = sync_chain_in;
end endgenerate
    

endmodule

