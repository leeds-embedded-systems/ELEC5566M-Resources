/*
 * Structure of a For-loop 
 */
 
//Structure of a for loop
integer loopVal; //We typically use an 'integer' for the loop control variable
...
//for ( <initial assignment>; <limiting expression>; <step assignment>) begin
for (loopVal = 0; loopVal < 16; loopVal = loopVal + 1) begin
    //Keep looping while loopVal < 16, incrementing loopVal after each loop
    //Body of for loop, executed each loop
    array[loopVal] = 16'b0;
end

/*
 * Examples of Incorrect For-loops
 */
 
//ERROR: The value of someVariable is not known at synthesis
for (loopVal = 0; loopVal < someVariable; loopVal = loopVal + 1) begin

//ERROR: The loop variable must be changed by a constant amount each time!
for (loopVal = 0; loopVal < 16; loopVal = loopVal + someVariable) begin

//ERROR: The limiting expression must be based on loop variable.
for (loopVal = 0; someOtherVariable; loopVal = loopVal + 1) begin
