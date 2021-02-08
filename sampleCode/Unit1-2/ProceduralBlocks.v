/*
 * Examples of Procedural Blocks
 */

//The initial block is evaluated once at the beginning
initial begin
    //Actions performed here
    someReg = 1'b0; //Assign an initial value to the reg
end

//This always block is recalculated whenever a net on its "sensitivity list" 
//changes value. The list usually contains the name of any signal used in the
//block, seperated by the "or" keyword.
always @( net or newValue or ... ) begin
    //Actions performed here
    someReg = newValue; //e.g. assign the reg a new value
end

//With Verilog-2001, the following sensitivity list can be used
always @ * begin
    //Actions here will be executed whenever any signal 
    //used inside the block changes value. 
    someReg = newValue; //e.g. block executes when 'newValue' signal changes
end

//always blocks don't need to have sensitivity lists. This is valid
always begin
    //Actions here will be executed continously. Only used in simulation.
end


/*
 * Procedural Assignment Sequential Calculation
 */

always @ * begin
    x = a && b;  //Calculate the value for x
    y = x || c;  //Then calculate value for y
end                                               /*!\tikzmark{se_blockingassignment}!*/


/*
 * Using If-ElseIf in Procedural Blocks
 */

always @ * begin
    if (expression1) begin //Starts with an if statement. Note the begin/end!
        //Do this if expression1 is true.
    end else if (expression2) begin //Can use multiple else if statements.
        //Else, do this if expression2 is true.
    end else begin //Finally an optional else statement if needed.
        //Otherwise do this. 
    end
end


/*
 * Using Default Values to Prevent Latches
 */

always @ * begin
    firstOutput = 4'b0000; //Give firstOutput a default value of 0
    secondOutput = 1'b0;  //Give secondOutput a default value of 0
    if (xorValues) begin //If true
        firstOutput = a ^ b; //Reassign firstOutput equal to a bit-xor b
    end else if (somethingElse) begin //Else if something else true
        secondOutput = 1'b1; //Reassign secondOutput equal to 1
    end
end


/*
 * Example of a four way 8-bit multiplexer using a case statement
 */

always @ * begin
    case case ( expression )
        2'd0: out = in1; // constantExpr: action;
        2'd1: out = in2; // constantExpr: action;
        2'd2: out = in3; // constantExpr: action;
        ... // And so on.
        default: result = 8'b0000000;  // default: action; /*!\tikzmark{se_sevensegment}!*/
    endcase
end


/* 
 * Example of Case Statement with Multiple Actions per Value
 */

always @ * begin
    case ( expression )
        constant_1: begin
             // Multiple actions can be performed in here
        end
        constant_2: begin
             // Multiple actions can be performed in here
        end
        default: begin
             // Multiple actions can be performed in here
        end
    endcase
end
