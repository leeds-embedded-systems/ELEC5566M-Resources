/*
 * The following provides three ways of initialising a Verilog
 * memory:
 *
 *  1. Using an initial block
 *  2. Reading from a text file with $readmemb/h
 *  3. Initialising from structured memory initialisation file by attribute.
 *
 */

//Initialise using an initial block
//  - This should work with all synthesis tools
reg [7:0] ram [0:15];
initial begin
    ram[0] = 8'd100;
    ram[1] = 8'd123;
    ram[2] = 8'd0;
    ...
end

//Initialize with the Verilog HDL $readmemb or $readmemh
//  - This is supported by most synthesis tools
reg [7:0] ram [0:15];
initial begin
    $readmemb("ram.txt", ram);
end

//Initialize with a structured file using Verilog Attribute
//  - This is Quartus specific.
(* ram_init_file = "ram.mif" *)
reg [7:0] ram [0:15];

