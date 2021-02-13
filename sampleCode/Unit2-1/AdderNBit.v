/*
 * N-Bit Full Adder Example
 */
module AdderNBit #(
    parameter N = 4  //Number of bits in adder (default 4)
)(
    // Declare input and output ports
    input          cin,
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] sum,
    output         cout
);

wire [N-0:0] carry;     //Internal carry signal, N+1 wide to include carry in/out
assign carry[0] = cin;  //First bit is Carry In
assign cout = carry[N]; //Last bit is Carry Out

genvar i;  //Generate variable to be used in the for loop

generate 
    for (i = 0; i < N; i = i + 1) begin : adder_loop //Loop "N" Times.
        //We can do maths with the genvar valus using localparam statements, e.g.
        localparam j = i + 1;
        //You can also do things like: if (i[0]) ... which would happen on even loops
        //or even if(i == 1) ... which would be the first loop. 
        //We can instantiate modules...
        //Instantiate "N" 1-bit FullAdder modules (From Lab 1, QuartusTest.v)
        Adder1Bit adder (
            .cin (carry[i]),
            .a   (    a[i]),
            .b   (    b[i]),
            .sum (  sum[i]),
            .cout(carry[j])
        );
        //We can do procedural blocks
        // always @ ( whatever ) do something...
        //Or make local variables
        // wire localVar; <- only visible inside the loop. Can do this in if-else too
    end
endgenerate

endmodule
