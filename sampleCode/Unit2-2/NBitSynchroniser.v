/*
 * A Simple N-Flop Synchroniser Chain
 *
 * You can use this to synchroniser inputs to a clock signal.
 */
 
module NBitSynchroniser #(
    parameter WIDTH = 1,  // Number of bits wide
    parameter LENGTH = 2  // 2-flop synchroniser by default
)(
    //Asynchronous Input
    input  [WIDTH-1:0] asyncIn,
    //Clock and Synchronous Output
    input              clock,
    output [WIDTH-1:0] syncOut
);

// A chain of register for each bit
reg [WIDTH-1:0] syncChain [LENGTH-1:0];

// The first register is most likely to go metastable as it reads asyncIn directly
always @ (posedge clock) begin
    syncChain[0] <= asyncIn;
end

// Subsequent registers reduce the probability of the metastable state propagating
genvar i;
generate for (i = 1; i < LENGTH; i = i + 1) begin : sync_loop
    // For each stage in the synchroniser, add a register
    always @ (posedge clock) begin
        syncChain[i] <= syncChain[i-1];
    end
end endgenerate

// The output comes from the end of the synchroniser chain
assign syncOut = syncChain[LENGTH-1];

endmodule
