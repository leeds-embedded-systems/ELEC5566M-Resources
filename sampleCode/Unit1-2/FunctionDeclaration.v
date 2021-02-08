//Parameters in parent module can be used inside a function
localparam WIDTH = 16;
//Declare a function
//This example reverses a data bus when reverse is high
function [WIDTH-1:0] reverseBits; //function [optional:returnsize] functionName;
    //Inputs
    input [WIDTH-1:0] signal;  //First input
    input             reverse; //Second input
    //Local variables
    integer i, j;
begin
    //Procedural statements can be used
    if (reverse) begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            //We can do things with local variables and also
            //parameters from parent module
            j = WIDTH - 1 - i;
            //The "returned value" is the *name of the function*
            reverseBits[j] = signal[i];
        end
    end else begin
        //Simple assignments can be used to.
        reverseBits = signal;
    end
    //By the end of the function, all bits in the returned
    //value *must* have been assigned a value.
end endfunction //End of function
//To call a function, we do:
//   something = functionName(input1, input2, ...)
//The order of inputs to the function matches the order in the function declaration.
//Functions can be used in continuous assigment statements
assign someWire = reverseBits(someVariableOrConstant, anotherVariableOrConstant);
//They can also be used in procedural blocks
always @ (posedge clock) begin
    dataOut = reverseBits(dataIn, 1'b1);
end
