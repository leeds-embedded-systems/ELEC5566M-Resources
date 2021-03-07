/*
 * Example of Top-Level Pin Assignments
 * ------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 7th March 2021
 *
 * Description
 * ------------
 * The module shows how pin assignments can be made using constraints
 * directly added to the top-level module of your design using the
 * Verilog Attributes (* *) command.
 *
 * These are made using the following command placed before each port:
 *     (* chip_pin = "pin"*) direction portName
 *
 * The constraint must be on the same line as the port declaration it
 * belongs to, or on the line immediately before with nothing in between.
 */

module TopLevel (
    //50MHz Clock input, assigned to the CLOCK_50 pin
    //Assignment can go on same line as port, or on line before
    (* chip_pin = "AF14" *) input clock,
    //Push Button Inputs - multiple pins are listed as comma separated
    //where the first pin is the MSB of the signal (e.g Y16 -> keys[3]).
    (* chip_pin = "Y16, W15, AA15, AA14" *)
    input [3:0] keys,
    //7-Segment Display - can do outputs in the same way
    (* chip_pin = "AH28, AG28, AF28, AG27, AE28, AE27, AE26" *)
    input [6:0] sevenSeg
);

//Body of module...

endmodule
