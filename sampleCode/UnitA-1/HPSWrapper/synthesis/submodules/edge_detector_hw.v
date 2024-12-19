/*
 * Edge Detector Hardware
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 12th April 2017 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This block is used to detect the rising edge of a signal. The output will be high for one clock cycle whenever a
 * rising edge is detected on the input signal.
 *
 * The internal delay register resets high to ensure that if the input signal is high when coming out of reset, the
 * output doesn't detect a rising edge. The input must be low for at least 1 clock cycle after reset is deasserted
 * for a rising edge to be detected.
 */

module edge_detector_hw #(
    parameter RISING_EDGE   = 1,
    parameter FALLING_EDGE  = 1,
    parameter BUFFER_INPUT  = 0,
    parameter BUFFER_OUTPUT = 1,
    parameter USE_ENABLE    = 0, //Whether to include a clock enable
    parameter WIDTH         = 1,
    //Enable optional depth control for output buffer (input buffer is fixed depth)
    parameter VAR_DEPTH     = 0,
    parameter DEPTH_BITS    = 1  //Set to 1 for constant depth, or clog(DEPTH+1) for variable
)(    
    input                   clock,
    input                   reset,
    input                   enable,  // Used only if USE_ENABLE==1
    input  [DEPTH_BITS-1:0] depth,   // Used only if VAR_DEPTH ==1
    input  [     WIDTH-1:0] inEdge,  //-[edge]-.   Input signal
    output [     WIDTH-1:0] rawEdge, //<-------+   Unbuffered edge detection
    output [     WIDTH-1:0] qout     //<-[dly]-'   Buffered edge detection
);

wire [WIDTH-1:0] pipeInEdge;
dff_hw #(
    .DEPTH(BUFFER_INPUT),
    .USE_ENABLE(USE_ENABLE),
    .WIDTH(WIDTH),
    .USE_RESET(1)
) bufferedInput (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .din (inEdge),
    .qout(pipeInEdge)
);

reg [WIDTH-1:0] sigInEdge;
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        sigInEdge <= {(WIDTH){(RISING_EDGE && !FALLING_EDGE) ? 1'b1 : 1'b0}};
    end else if (!USE_ENABLE || enable) begin
        sigInEdge <= pipeInEdge;
    end
end

generate if (RISING_EDGE && FALLING_EDGE) begin
    assign rawEdge = pipeInEdge ^ sigInEdge;
end else if (FALLING_EDGE) begin
    assign rawEdge = ~pipeInEdge & sigInEdge;
end else begin
    assign rawEdge = pipeInEdge & ~sigInEdge;
end endgenerate
    
dff_hw #(
    .DEPTH(BUFFER_OUTPUT),
    .VAR_DEPTH(VAR_DEPTH),
    .USE_ENABLE(USE_ENABLE),
    .WIDTH(WIDTH),
    .USE_RESET(1),
    .DEPTH_BITS(DEPTH_BITS)
) bufferedOutput (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .depth(depth),
    .din (rawEdge),
    .qout(qout)
);

endmodule
