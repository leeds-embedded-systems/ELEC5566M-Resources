/*
 * Declaring Multi-Dimensional Arrays
 */

wire [3:0] a_3_4bit_wires   [0:2];      //An array of three 4-bit wires
reg        a_6_4bit_regs    [0:5];      //An array of six 1-bit wide regs  
reg  [1:0] a_4by6_2bit_regs [0:5][0:3]; //2D array, six by four 2-bit regs  

/*
 * Accessing Multi-Dimensional Arrays
 */

// A 2 by 4 array of 16bit numbers
reg [15:0] array [0:1][0:3];

//... Lets assume the array is initialised with the following values ...
//  16'd0, 16'd1, 16'd2, 16'd3, - Initial values for array[0][0:3]
//  16'd4, 16'd5, 16'd6, 16'd7  - Initial values for array[1][0:3]

//Element Selections
array[0][0]; //Equal to 16'd0. Extracts element [0][0]
array[1][0]; //Equal to 16'd4. Extracts element [1][0]
array[1][3]; //Equal to 16'd7. Extracts element [1][3]
//Partial Element Selections
array[1][3][2];    //Equal to 1'b1.  Extracts bit  [2]   of element [1][3]
array[1][2][2:1];  //Equal to 2'b11. Extracts bits [2:1] of element [1][2]
array[0][1][0+:2]; //Equal to 2'b01. Extracts bits [1:0] of element [0][1]

//Invalid Selections
array[0:1];        //ERROR, cannot part-select on array index
array[0][1:2];     //ERROR, cannot part-select on array index
array[1][2+:2];    //ERROR, cannot index part-select on array index
array[0][1:3][3:0];//ERROR, still can't part-select on array index!
//Note: They are allowed in SystemVerilog, called slicing, but NOT Verilog
