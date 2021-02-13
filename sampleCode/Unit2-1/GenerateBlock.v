/*
 * Syntax for instantiating a generate block
 */
generate : OptionalNameForBlock
    //Code here is inside the generate block and can use if-else and for
    //statements against parameter values.
endgenerate

/*
 * Example of using an if-else statement with a generate block.
 */
parameter PIPELINE_INPUT = ... 
//...
reg in_pipe;
//Some comment
generate
    if (PIPELINE_INPUT) begin
        //If PIPELINE_INPUT is a non-zero value, we add pipelining.
        always @ (posedge clock) begin
            in_pipe <= in; //Add pipeline state - a clocked register.
        end
    end else begin
        //Otherwise there is no pipelineing.
        always @ * begin
            in_pipe = in; //Connect the signal directly - not clocked.
        end
    end
endgenerate
