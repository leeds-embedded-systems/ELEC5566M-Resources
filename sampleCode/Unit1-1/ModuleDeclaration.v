/*
 * Verilog 2001 Style Module Declaration
 * 
 * We will use this style for ELEC5566M
 *
 */
module TheModuleName (
    // Port Declaration List
    input        portName,   // Single-bit input port
    input  [3:0] nextPort,   // Multi-bit input port
    output       anotherPort // <- no comma at end as the last port.
); // <- Semi-colon after the list is finished
... // The body of the module
endmodule // End of module   

/*
 * Old Verilog '95 Style Module Declaration
 * 
 * You should avoid using this style.
 *
 */
module TheModuleName (
    // Port Declaration List
    portName, nextPort, anotherPort // Ports declared as untyped list
); // <- Semi-colon after the list is finished
// Declare whether ports are inputs or outputs and their width.
input        portName;    // \
input  [3:0] nextPort;    //  }- Semi-Colons like regular wires
output       anotherPort; // /
... // The body of the module
endmodule // End of module  

