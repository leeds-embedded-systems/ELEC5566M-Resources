

// Timescale indicates unit of delays.
//  `timescale  unit / precision
// Where delays are given as:
//   #unit.precision
//
// Let's stick with a "unit" of 1ns. You may choose the "precision".
//
// e.g for `timescale 1ns/100ps then:
//   #1 = 1ns
//   #1.5 = 1.5ns
//   #1.25 = 1.3ns (rounded to nearest precision)
`timescale 1 ns/100 ps

module ExampleTopLevel_tb ;

//
// Parameter Declarations
//
localparam NUM_CYCLES = 50000;    //Simulate this many clock cycles. Max. 1 billion
localparam CLOCK_FREQ = 50000000; //Clock frequency (in Hz)
localparam RST_CYCLES = 2;        //Number of cycles of reset at beginning.

//
// Test Bench Generated Signals
//
reg  clock;

//
// Device Under Test
//

wire        LT24CS_n;
wire        LT24RS;
wire        LT24Rd_n;
wire        LT24Wr_n;
wire [15:0] LT24Data;
wire        LT24LCDOn;
wire        LT24Reset_n;

ExampleTopLevel dut (
   .clock                            ( clock ),
   .LT24CS_n                         ( LT24CS_n ),
   .LT24RS                           ( LT24RS ),
   .LT24Rd_n                         ( LT24Rd_n ),
   .LT24Wr_n                         ( LT24Wr_n ),
   .LT24Data                         ( LT24Data ),
   .LT24LCDOn                        ( LT24LCDOn ),
   .LT24Reset_n                      ( LT24Reset_n )
);

//
// Display Functional Model
//
LT24FunctionalModel #(
    .WIDTH  ( 240 ),
    .HEIGHT ( 320 )
) DisplayModel (
    // LT24 Interface
    .LT24Wr_n    ( LT24Wr_n    ),
    .LT24Rd_n    ( LT24Rd_n    ),
    .LT24CS_n    ( LT24CS_n    ),
    .LT24RS      ( LT24RS      ),
    .LT24Reset_n ( LT24Reset_n ),
    .LT24Data    ( LT24Data    ),
    .LT24LCDOn   ( LT24LCDOn   )
);


//
//Clock generator + simulation time limit.
//
initial begin
    clock = 1'b0; //Initialise the clock to zero.
end
//Next we convert our clock period to nanoseconds and half it
//to work out how long we must delay for each half clock cycle
//Note how we convert the integer CLOCK_FREQ parameter it a real
real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

//Now generate the clock
integer half_cycles = 0;
always begin
    //Generate the next half cycle of clock
    #(HALF_CLOCK_PERIOD);          //Delay for half a clock period.
    clock = ~clock;                //Toggle the clock
    half_cycles = half_cycles + 1; //Increment the counter
    
    //Check if we have simulated enough half clock cycles
    if (half_cycles == (2*NUM_CYCLES)) begin 
        //Once the number of cycles has been reached
		half_cycles = 0; 		   //Reset half cycles, so if we resume running with "run -all", we perform another chunk.
        $stop;                     //Break the simulation
        //Note: We can continue the simualation after this breakpoint using 
        //"run -continue" or "run ### ns" in modelsim.
    end
end



endmodule