/*
 * Examples of Continous Assignment
 */

//Let's declare some initialised wires
wire       aWire = 1'b1;               //Initialise with a constant
wire       whyAre = aWire;             //Initialise connected to aWire
wire       result = (aWire && whyAre); //Initialise with calculation 
wire [7:0] widerWire = 8'b1011;        //Can initialise multi-bit wires too
//These wires are uninitialised.
wire       emptyWire;
wire       theWire;
wire       zeroWire; 
wire [5:0] sixyWire; 
wire       concatA;
wire       concatB;
//So let's try assigning a value to them with the assign statement
assign emptyWire = aWire;           //Uninitialised, so can "assign" value
assign theWire = (aWire && whyAre); //Assign works with calculations also
assign zeroWire = 1'b0;             //And with constants 
assign sixyWire = widerWire[5:0];   //Multi-bit wires can be assigned too
assign {concatA, concatB} = 2'b10;  //Can assign to concatenated wires
//But we can't assign a value twice!
assign result = aWire;              //ERROR! already initialised "result"
assign theWire = 1'b0;              //ERROR! already assigned "theWire"
