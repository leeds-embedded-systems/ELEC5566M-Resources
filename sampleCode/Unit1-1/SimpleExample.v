/* Name of Design
 * --------------
 * By: Doctor Who
 * Date: 25th December 2017
 *
 * Module Description:
 * -------------------
 * A description of the module, its ports, connections, and parameters.
 */                                        /*!\tikzmark{se_moduleheader}!*/
module SimpleExample (
    // Declare our input and output ports
    input A,
    input B,
    output wire Q
); 
    // Internal wire connection
    wire A_n;
    // Declare NOT gate primitive with input A and output to wire A_n
    not(A_n,A);
    // Declare AND gate primitive with inputs A_n and B with output Q
    and(Q,A_n,B);
endmodule
