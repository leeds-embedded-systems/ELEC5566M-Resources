/*
 * Power On Reset
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 30th July 2015 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This module simply generates a 4 cycle wide reset pulse when the design is first configured.
 *
 */

module power_on_reset_hw (
    input      clock,
    output reg reset = 1'b1
);

reg [3:0] resetGen = 4'b1111;

always @ (posedge clock) begin
    {reset,resetGen} <= {resetGen,1'b0}; //Run through a pulse when the power is first applied.
end

endmodule
