/*
 * N-bit D-Flip Flop
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 18th September 2023
 *
 * Module Description:
 * -------------------
 *
 * A simple N-bit wide register (DFF), optionally with reset or preset.
 *
 * The depth of the chain can also be configured. A depth of 1 (Default)
 * is a single DFF per bit. Longer depths result in longer chains of DFFs.
 * A depth of zero effectively bypassing the block.
 *
 * If VAR_DEPTH is set to non-zero, then a new input, depth, is available
 * to allow dynamically varying the depth of the DFF chain up to the
 * maximum DEPTH parameter.
 *
 */

module dff_hw #(
    parameter DEPTH = 1,
    parameter WIDTH = 1,
    parameter VAR_DEPTH = 0,
    parameter USE_RESET = 0,
    parameter USE_ENABLE = 0,
    parameter RESET_HIGH = 0,
    parameter RESET_VAL = {(WIDTH){1'b0}}, //Reset value, per-bit, used if (RESET_HIGH == 0)
    parameter DEPTH_BITS = 1 //Set to 1 for constant depth, or clog(DEPTH+1) for variable
)(    
    input                   clock,
    input                   reset,
    input                   enable,
    input  [DEPTH_BITS-1:0] depth,
    input  [     WIDTH-1:0] din,   //---.
    output [     WIDTH-1:0] qout   //<--'
);

// D-Flip-Flop Chain
reg [WIDTH-1:0] dff [DEPTH:0];
// Preload the chain such that if depth is zero, this is a direct pass through of the input (bypass).
always @ * begin
    dff[0] <= din;
end

// Select the correct DFF from the chain. Either the last (for constant), or use selection.
generate if (VAR_DEPTH) begin
    assign qout = dff[depth];
end else begin
    assign qout = dff[DEPTH];
end endgenerate

// Add DEPTH DFFs to the chain
genvar idx;
generate for (idx = 1; idx <= DEPTH; idx = idx + 1) begin : dff_loop
    if (USE_RESET) begin
        always @ (posedge clock or posedge reset) begin
            if (reset) begin
                dff[idx] <= RESET_HIGH ? {(WIDTH){1'b1}} : RESET_VAL[WIDTH-1:0];
            end else if (USE_ENABLE ? enable : 1'b1) begin
                dff[idx] <= dff[idx-1];
            end
        end
    end else begin
        always @ (posedge clock) begin
            if (USE_ENABLE ? enable : 1'b1) begin
                dff[idx] <= dff[idx-1];
            end
        end
    end
end endgenerate


endmodule
