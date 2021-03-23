/*
 * Clock Synchroniser Block
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 28th April 2015 (or earlier)
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
    parameter CHAIN_LEN         = 2,    //Number of register stages in synchroniser chain. Must be >= 1!
    parameter SIGNAL_WIDTH      = 1,    //Width of the data signal
    parameter ASYNC_INPUT       = 1'b0, //Whether to use Asynchronous Input mode.
    parameter RISING_EDGE       = 1'b0, //Whether to include a rising edge detector on the output.
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
    output [SIGNAL_WIDTH-1:0] out_signal
);

reg [SIGNAL_WIDTH-1:0] in_buf = {(SIGNAL_WIDTH){1'b0}};

generate if (ASYNC_INPUT) begin
    //if input is asynchronous, don't buffer it. 
    always @ * begin
        in_buf <= in_signal;
    end
end else begin
    //Otherwise we add a register stage which uses the input clock/reset.
    always @ (posedge in_clock or posedge in_reset) begin
        if (in_reset) begin
            in_buf <= {(SIGNAL_WIDTH){1'b0}};
        end else if (in_enable || !HAS_INPUT_ENABLE) begin //If the optional enable signal is not enabled, then always clock in the data, else only clock when disabled.
            in_buf <= in_signal;
        end
    end
end endgenerate

genvar i;
generate for (i = 0; i < SIGNAL_WIDTH; i = i + 1) begin : sync_loop
`ifdef MODEL_TECH
	//For modelsim we add an power up value to stop the whole thing going 'don't care'
    (* preserve, altera_attribute = "-name CUT ON -from *" *) reg sync_chain_0 = 1'b0; //The first register in the synchroniser chain has been separated from the rest of the chain such that timing constraints can be specified.
`else
    (* preserve, altera_attribute = "-name CUT ON -from *" *) reg sync_chain_0; //The first register in the synchroniser chain has been separated from the rest of the chain such that timing constraints can be specified.
`endif
    wire sync_chain_out; //Output of synchroniser
	if (ASYNC_INPUT) begin
        //For asynchronous input, sync_chain_0 replaces in_buf and has an asynchronous assert.
        always @ (posedge out_clock or posedge in_buf[i]) begin
            if (in_buf[i]) begin
                sync_chain_0 <= 1'b1; //When the input signal is high, asynchronously assert the first register in the chain - this ensures that any pulse on the input will always transfer across.
            end else begin
                sync_chain_0 <= 1'b0;
            end
        end
        (*preserve*) reg [CHAIN_LEN-1:0] sync_chain = {(CHAIN_LEN){1'b1}};
        wire [CHAIN_LEN-1:0] chain_in;
        if (CHAIN_LEN == 1) begin
            assign chain_in = {sync_chain_0};
        end else begin
            assign chain_in = {sync_chain[CHAIN_LEN-2:0], sync_chain_0};
        end
        assign sync_chain_out = sync_chain[CHAIN_LEN-1]; //The output is connected to the last register in the synchroniser chain.
        always @ (posedge out_clock or posedge out_reset) begin
            if (out_reset) begin
                sync_chain <= {(CHAIN_LEN){1'b1}}; //reset high as the async chain input will power up high.
            end else if (out_enable || !HAS_OUTPUT_ENABLE) begin
                sync_chain <= chain_in; //when enabled, clock the data through the synchroniser chain.
            end
        end
    end else begin
        if (CHAIN_LEN > 1) begin
            (*preserve*) reg [CHAIN_LEN-1:1] sync_chain = {(CHAIN_LEN-1){1'b0}};
            wire [CHAIN_LEN-1:0] chain_in;
            if (CHAIN_LEN == 2) begin
                assign chain_in = {sync_chain_0, in_buf[i]};
            end else begin
                assign chain_in = {sync_chain[CHAIN_LEN-2:1], sync_chain_0, in_buf[i]};
            end
            assign sync_chain_out = sync_chain[CHAIN_LEN-1];
            always @ (posedge out_clock or posedge out_reset) begin
                if (out_reset) begin
                    {sync_chain,sync_chain_0} <= {(CHAIN_LEN){1'b0}};
                end else if (out_enable || !HAS_OUTPUT_ENABLE) begin
                    {sync_chain,sync_chain_0} <= chain_in; //when enabled, clock the data through the synchroniser chain.
                end
            end
        end else begin
            //For a chain length of 1, we simply use a single register with an optional clock enable.
            assign sync_chain_out = sync_chain_0;
            always @ (posedge out_clock or posedge out_reset) begin
                if (out_reset) begin
                    sync_chain_0 <= 1'b0;
                end else if (out_enable || !HAS_OUTPUT_ENABLE) begin
                    sync_chain_0 <= in_buf[i];
                end
            end
        end
    end
    
    //Determine if we need an edge detector on the output.
    if (RISING_EDGE) begin
        edge_detector_hw rising_edge (    
            .clock (out_clock    ),
            .reset (out_reset    ),
            .inEdge(sync_chain_out), //---.
            .qout  (out_signal[i])
        );
    end else begin
        assign out_signal[i] = sync_chain_out;
    end
    
end endgenerate



endmodule
