/*
 * Qsys Interface Changer
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 8th April 2018 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This block is just a Qsys helper function - does nothing more than send the incoming signal back out.
 *
 */

module qsys_iface_change_hw #(
    parameter WIDTH = 1
)(
    input              clock, //Dummy, used for Av-St to Conduit
    input              reset, //Dummy, used for Av-St to Conduit
    input  [WIDTH-1:0] sigIn, //---.
    output [WIDTH-1:0] sigOut //<--'
);

assign sigOut = sigIn;


endmodule
