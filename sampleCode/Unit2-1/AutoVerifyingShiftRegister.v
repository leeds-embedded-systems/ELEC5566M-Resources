//Inputs/Outputs of the shift register
reg        clock;
reg        reset;
reg        serialIn;
wire [3:0] parallelOut;
//Instantiate DUT. You could have a go making this module if you want, though you
//might want to look at next-weeks lab notes to find out about parameterised hardware
ShiftRegisterNBit #(
    .WIDTH    (4),   //4-bit shift reg
    .MSB_FIRST(1)    //MSB first if 1, LSB first if 0.
) dut (
    .clock (clock      ),
    .reset (reset      ),
    .serIn (serialIn   ),
    .parOut(parallelOut)
);
//Generate our stimuli.
initial begin
    //Perform the reset as before.
    reset = 1'b1;                             //Start in reset.
    repeat(RST_CYCLES) @(posedge clock);      //Wait for a couple of clocks
    reset = 1'b0;                             //Then clear the reset signal.
    //Now lets test sending in a value of 4'hA = 4'b1010, MSB first.
    //Could do this with a for-loop with an array of input values.
    @(posedge clock);    //At the rising edge of the clock
    serialIn = 1'b1; //Send Bit 3
    @(posedge clock);    //At the rising edge of the clock
    serialIn = 1'b0; //Send Bit 2
    @(posedge clock);    //At the rising edge of the clock
    serialIn = 1'b1; //Send Bit 1
    @(posedge clock);    //At the rising edge of the clock
    serialIn = 1'b0; //Send Bit 0
    @(posedge clock);    //At the rising edge of the clock
    //Now we can check the expected value
    if (parallelOut == 4'hA) begin
        $display("Success!");
    end else begin
        $display("Error! Output 0x%X != 0xA", parallelOut);
    end
end
