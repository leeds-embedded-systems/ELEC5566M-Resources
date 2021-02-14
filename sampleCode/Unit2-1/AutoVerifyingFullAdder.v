//You would have your DUT instantiation. Lets say it is a 2-bit gate-level full adder
//which has the following input/output wires. 
reg        cin;   
reg  [1:0] a;   
reg  [1:0] b;   
wire [1:0] sum;   
wire       cout;   
//For the stimulus you could use a for loop to generate all possible input values
//e.g. initial begin ... for (...) ... {a,b,cin} = i; ...
//Now we can add some "auto-verifying" code to check the outputs
//Create a wire to store expected value
wire [2:0] expected_value;       //1-bit wider than sum to include the carry out
//We can then calculate the expected value using alternate method to the DUT.
assign expected_value = a+b+cin; //In this case we use the behavioural + operator.
//Finally we add some code to continuously run an auto-checking comparison
always @ (*) begin
    if( expected_value != {cout,sum} ) begin //If DUT output doesn't match expected
        $display("Error when cin=%b, a=%b, b=%b. Output {cout,sum}={%b%b} != {%b}",
                 cin,a,b,cout,sum,expected_value); //Print an error message.
    end 
end
