/*
 * Simple Tri-State Buffer
 * ------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 8th March 2021
 *
 * Description
 * ------------
 * The module shows a simple example of how to implement a
 * Tristate buffer using a Verilog Conditional Assignment.
 */

module TriBuf (
    input a, 
    input b,
    inout c  //Special inout tristate signal
);
    assign c = (b) ? a : 1'bz; //If b is high, c is a, else c is high-z
endmodule
