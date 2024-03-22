/*
 * HPS Loan-IO to UART
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 10th March 2018 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This block extracts the UART pins from a Cyclone V HPS
 * Loan-IO conduit to allow driving from the FPGA.
 *
 */

module loanio_uart_hw #(
    parameter INCLUDE_SYNCHRONISER = 0
)(
    //HPS Loan-IO Conduit
    output [66:0] loan_io_out,
    output [66:0] loan_io_oe,
    input  [66:0] loan_io_in,
    //UART Interface
    input  clock,   //Clock for synchronizer if enabled.
    output uart_rx, //(Data In to FPGA) - If unused, leave unconnected
    input  uart_tx  //(Data Out to USB) - If unused, tie to 1'b1.
);

wire uart_rx_n;

generate if (INCLUDE_SYNCHRONISER) begin
    //Add a clock synchronizer to avoid metastability issues later on.
    clock_synchroniser_hw #(
        .CHAIN_LEN        (2), //2 Cycles of synchronization
        .SIGNAL_WIDTH     (1), //1-bit RX Signal
        .ASYNC_INPUT      (0), //Synchronous mode
        .RISING_EDGE      (0), //No rising edge detector
        .HAS_INPUT_ENABLE (0), //No input enable
        .HAS_OUTPUT_ENABLE(0)  //No output enable
    ) rx_sync (
        .in_clock  (clock),
        .in_reset  (1'b0),
        .in_enable (1'b1),
        .in_signal (~loan_io_in[49]),
        
        .out_clock (clock),
        .out_reset (1'b0),
        .out_enable(1'b1),
        .out_signal(uart_rx_n)
    );
    assign uart_rx = ~uart_rx_n;
end else begin
    //Just pass RX through unchanged. You should add your own synchronization
    assign uart_rx = loan_io_in[49];
end endgenerate

assign loan_io_out = {16'b0,uart_tx,50'b0};
assign loan_io_oe = {16'b0,1'b1,50'b0};

endmodule
