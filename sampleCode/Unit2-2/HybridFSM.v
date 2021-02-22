/*
 * Extract from a 32-bit SPI Controller
 *
 * This is a Hybrid state machine which allows controlling of the
 * state and the outputs based on the inputs, like a Mealy machine,
 * but is fully synchronous like a Moore machine.
 *
 * We use flags like shiftDone and shiftLoad to interact with the
 * rest of the system to instruct it that we have started sending
 * or finished receiving data.
 *
 */

//State Machine Register
reg [2:0] stateMachine;

//State Names
localparam IDLE_STATE = 3'b000;
localparam DONE_STATE = 3'b001;
localparam OUTL_STATE = 3'b100;
localparam OUTW_STATE = 3'b101;
localparam INL_STATE  = 3'b110;
localparam INW_STATE  = 3'b111;

//SPI Signals
reg                spiClock;
reg                spiOut;
reg [SS_WIDTH-1:0] spiSS;

//Shift Register
reg [        31:0] shiftReg;

//Counters
reg [CLK_BITS-1:0] clockCntr;
reg [         4:0] bitCntr;

//State Machine Transitions and Output Generation
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        stateMachine             <= IDLE_STATE;
        shiftEmpty               <= 1'b1;
        shiftLoad                <= 1'b0;
        shiftDone                <= 1'b0;
        spiClock                 <= 1'b0;
        spiOut                   <= 1'b0;
        bitCntr                  <= 5'b0;
        clockCntr                <= CLK_INCR;
    end else begin
        case (stateMachine)
        IDLE_STATE: begin
            //Wait in idle until transfer requested
            if (!txReady) begin
                //If there is data in the txData register to send
                shiftReg         <= txData;           //Copy TX data into shift reg
                shiftLoad        <= 1'b1;             //Indicate load has been done
                shiftEmpty       <= 1'b0;             //No longer empty
                spiSS            <= ~chipSelect;      //Select required devices
                stateMachine     <= OUTL_STATE;       //Jump to data out load state
            end
            bitCntr              <= 5'b0;             //Reset bit counter
            shiftDone            <= 1'b0;             //Clear shift done flag
        end
        OUTL_STATE: begin
            //Data out load transfer
            {spiOut,shiftReg}    <= {shiftReg, 1'b0); //Shift data out to MOSI
            spiClock             <= 1'b0;             //Lower clock
            clockCntr            <= CLK_INCR;         //Reset clock divider counter
            //Clear values set on entry from IDLE_STATE
            shiftLoad            <= 1'b0;             //No longer loading data
            stateMachine         <= OUTW_STATE;       //Wait for a half clock period
        end
        OUTW_STATE: begin
            //Wait for half clock period
            if (clockCntr == CLK_MAX) begin
                //If max count is reached
                stateMachine     <= INL_STATE;        //Jump to data in load state
            end
            clockCntr            <= clockCntr + 1;    //Increment delay counter
        end
        INL_STATE: begin
            //Data in load transfer
            shiftReg[0]          <= spiIn;            //Load in data from MISO
            spiClock             <= 1'b1;             //Raise clock
            clockCntr            <= CLK_INCR;         //Reset clock divider counter
            stateMachine         <= INW_STATE;        //Wait for a half clock period
        end
        INW_STATE: begin
            //Wait for half clock period
            if (clockCntr == CLK_MAX) begin
                //Once half period has been reached
                if (bitCntr == 5'd31) begin
                    //If all bits have been sent
                    stateMachine <= DONE_STATE;       //We are done
                end else begin
                    //Otherwise more to send
                    stateMachine <= OUTL_STATE;       //Move to data out load state
                end
                bitCntr          <= bitCntr + 5'b1;   //One more bit sent
            end
            clockCntr            <= clockCntr + 1;    //Increment delay counter
        end
        DONE_STATE: begin
            //Finished transfer
            rxData               <= shiftReg;         //Save the received data
            spiOut               <= 1'b0;             //MISO idles low
            spiClock             <= 1'b0;             //Clock idles low
            shiftDone            <= 1'b1;             //Assert shift done flag
            shiftEmpty           <= 1'b1;             //Shift register now empty
            stateMachine         <= IDLE_STATE;       //Finished. Return to IDLE
        end
        endcase
    end
end
