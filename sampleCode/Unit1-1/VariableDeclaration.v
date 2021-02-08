/*
 * Declaration of Wires
 */
wire   [3:0] i_am_a_4bit_wire;        //A 4-bit wide internal wire 

input        i_am_an_output_wire,     //An input wire in a module
output       i_am_an_output_wire,     //An output wire in a module
output [1:0] i_am_a_2bit_output_wire, //An 2-bit module output wire

/*
 * Declaration of Wires
 */
reg              i_am_a_reg;             //A single bit wide reg 
reg        [3:0] i_am_a_4bit_reg;        //A 4-bit wide reg

output reg       i_am_an_output_reg,     //An output reg in a module 
output reg [1:0] i_am_a_2bit_output_reg, //An 2-bit output reg definition    

/*
 * Declaration of Signed Variables
 */
reg   signed [7:0] an_8bit_signed_reg;  //An 8-bit wide 2's complement reg
input signed [3:0] a_4bit_signed_input, //A 4-bit input, treated as signed 

/*
 * Declaration of Local Parameters
 */
wire [3:0] a;
//Create local parameter and assign a value
localparam CLOCK_RATE = 16'd32768; //Fine - assigning a constant value
localparam DOUBLE_RATE = 2 * CLOCK_RATE; //Fine - CLOCK_RATE is parameter
localparam BAD = a + 1; //INVALID - 'a' is not a constant or parameter!
