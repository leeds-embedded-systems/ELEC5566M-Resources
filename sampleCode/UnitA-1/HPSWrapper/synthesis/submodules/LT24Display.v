/*  
 * LT24 Display Driver
 * ------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 13th March 2017 
 *
 * Short Description
 * -----------------
 * This module is designed to interface with the LT24 Display Module
 * from Terasic. It provides functionality to initialise the display
 * and to allow individually addressed pixels to be written to the
 * internal frame buffer of the LT24.
 *
 * Interfaces
 * ----------
 * The following interfaces are provided:
 *
 * clock - Input - 1bit
 *       A free-running clock. This will be used to general logic clock
 * globalReset - Input - 1bit
 *       A global reset signal to reset the entire logic herein.
 * resetApp - Output - 1bit
 *       This is the reset which you should use for your code
 *
 * xAddr - Input - XBITS (parameterised)
 *       X-Coordinate of the pixel to be updated
 * yAddr - Input - YBITS (parameterised)
 *       Y-Coordinate of the pixel to be updated
 * pixelData - Input - 16bit
 *       An RGB565 encoded colour to be written to the addressed pixel
 * pixelWrite - Input - 1bit
 *       Setting this input high will trigger a write to the addressed pixel.
 *       This should be kept high until pixelReady goes high.
 * pixelReady - Output - 1bit
 *       This will be asserted when the LCD has accepted pixel data
 * pixelRawMode - Input - 1bit
 *       When high this disables setting of X-Y cursor and presents a raw pixel interface.
 *
 * cmdData - Input - 8bit
 *       Command Data to be written to the LCD
 * cmdWrite - Input - 1bit
 *       Setting this high will trigger a command to be written. This has priority over pixelWrite
 * cmdDone - Input - 1bit
 *       Indicates this is the last word in the command
 * cmdReady - Output - 1bit
 *       This will be high if LCD has accepted a command
 *
 * LT24* - Outputs
 *       LT24 external display interface
 */

//Useful Macro - calculates ceil(log2(x))
`define CLOG2(x) \
    (x <= 2) ? 1 : \
    (x <= 4) ? 2 : \
    (x <= 8) ? 3 : \
    (x <= 16) ? 4 : \
    (x <= 32) ? 5 : \
    (x <= 64) ? 6 : \
    (x <= 128) ? 7 : \
    (x <= 256) ? 8 : \
    (x <= 512) ? 9 : \
    (x <= 1024) ? 10 : \
    (x <= 2048) ? 11 : \
    (x <= 4096) ? 12 : \
    (x <= 8192) ? 13 : \
    (x <= 16384) ? 14 : \
    (x <= 32768) ? 15 : \
    (x <= 65536) ? 16 : \
    (x <= 131072) ? 17 : \
    (x <= 262144) ? 18 : \
    (x <= 524288) ? 19 : \
    (x <= 1048576) ? 20 : \
    (x <= 2097152) ? 21 : \
    (x <= 4194304) ? 22 : \
    (x <= 8388608) ? 23 : \
    (x <= 16777216) ? 24 : \
    -1 //This one will trigger compiler error.

//This is to suppress a warning about a missing port on the inferred rom.
//You should not suppress warnings this way.
(* altera_attribute = "-name MESSAGE_DISABLE 10030" *)

//Main Display Module. This is the one that you should infer.
module LT24Display #(
    //Clock frequency
    parameter CLOCK_FREQ = 50000000,
    //Display Specs
    parameter WIDTH = 240,
    parameter HEIGHT = 320,
    parameter XBITS = `CLOG2(WIDTH),
    parameter YBITS = `CLOG2(HEIGHT)
)(
    //
    // Global Clock/Reset
    // - Clock
    input              clock,
    // - Global Reset
    input              globalReset,
    // - Application Reset
    output             resetApp,
    
    //
    // FPGA Data Interface
    // - Address
    input  [XBITS-1:0] xAddr,
    input  [YBITS-1:0] yAddr,
    // - Data
    input  [     15:0] pixelData,
    // - Write Request
    input              pixelWrite,
    // - Write Done
    output reg         pixelReady,
    // - Raw Pixel Mode
    input              pixelRawMode,
    
    //
    // FPGA Command Interface
    // - Data
    input  [      7:0] cmdData,
    // - Write Request
    input              cmdWrite,
    // - Command Done
    input              cmdDone,
    // - Ready for command
    output reg         cmdReady,
    
    //
    // LT24 Interface
    // - Write Strobe (inverted)
    output             LT24Wr_n,
    // - Read Strobe (inverted)
    output             LT24Rd_n,
    // - Chip Select (inverted)
    output             LT24CS_n,
    // - Register Select
    output             LT24RS,
    // - LCD Reset
    output             LT24Reset_n,
    // - LCD Data
    output [     15:0] LT24Data,
    // - LCD Backlight On/Off
    output             LT24LCDOn
);

assign LT24LCDOn = 1'b1; //Backlight always on.

/*
 * Create power-on synchronous reset
 */
wire reset; //Synchronised Reset
ResetSynchroniser resetGen (
    .clock   (clock      ), //Global clock
    .resetIn (globalReset), //Global reset
    .resetOut(reset      )  //Synchronised reset
);

/*
 * LCD Initialisation Data
 */

reg  [6:0] initDataRomAddr;
wire [6:0] initRomMaxAddr;
wire [8:0] initData;
LT24InitialData #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
) initDataRom (
    .clock   (clock          ),
    .addr    (initDataRomAddr),
    .initData(initData       ),
    .maxAddr (initRomMaxAddr )
);

/*
 * State Machine for display interface
 */

reg        displayInitialised;
wire       displayReady;
reg        displayRegSelect;
reg [15:0] displayData;
reg        displayWrite;

reg [15:0] xAddrTemp; //Temp address registers are 16 bits wide so that address is correctly
reg [15:0] yAddrTemp; //padded for sending to the LT24 display.
reg [15:0] pixelDataTemp;

//State Machine
reg [3:0] stateMachine;
//General States
localparam INIT_STATE   = 4'b0000; //Display Initialisation
localparam LOAD_STATE   = 4'b0001; //Load Initialisation Data
localparam IDLE_STATE   = 4'b1111; //Idle
//Pixel Write States
localparam CASET_STATE  = 4'b1110; //Column Select
localparam XHADDR_STATE = 4'b1101; //Load X-High Address
localparam XLADDR_STATE = 4'b1100; //Load X-Low Address
localparam PASET_STATE  = 4'b1011; //Row Select
localparam YHADDR_STATE = 4'b1010; //Load Y-High Address
localparam YLADDR_STATE = 4'b1001; //Load Y-Low Address
localparam WRITE_STATE  = 4'b1000; //Memory Write Enable
//Command Write States
localparam CMD_STATE    = 4'b0111; //Send command


//State Machine Code
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        displayRegSelect                <= 1'b1;
        displayData                     <= 16'b0;
        displayWrite                    <= 1'b0;
        displayInitialised              <= 1'b0;
        initDataRomAddr                 <= 7'b0;
        cmdReady                        <= 1'b0;                        //Not ready for a command
        pixelReady                      <= 1'b0;                        //Not ready for data
        stateMachine                    <= INIT_STATE;                  //Come out of reset into initial state
    end else begin
        case (stateMachine)
            INIT_STATE: begin //Power on state - initialise pins
                displayInitialised      <= 1'b0;                        //Display not yet initialised
                initDataRomAddr         <= 7'b0;                        //Set initial ROM address one cycle early
                stateMachine            <= LOAD_STATE;                  //Begin load of ROM data into LT24
            end
            LOAD_STATE: begin //Load the initialisation data
                if (displayReady) begin //Load next cycle when display is ready
                    //Send initialisation command/data for previous address. (ROM has one cycle latency)
                    displayData         <= {8'b0,initData[7:0]};        //Repackage ROM payload
                    displayRegSelect    <= initData[8];                 //Select command or data
                    displayWrite        <= 1'b1;                        //Issue a write
                    //Prepare next address and state
                    if (initDataRomAddr < initRomMaxAddr) begin
                        //If we have not yet sent all ROM data
                        initDataRomAddr <= initDataRomAddr + 7'b1;      //Increment to address
                    end else begin
                        //Otherwise all initialisation data has been loaded
                        stateMachine    <= IDLE_STATE;                  //Move to Idle state to await commands.
                    end
                end
            end
            IDLE_STATE: begin
                displayInitialised      <= 1'b1;                        //Display is fully initialised once in Idle state.
                if (displayReady && cmdWrite) begin
                    //If command write requested (this has priority)
                    cmdReady            <= 1'b1;                        //Accepted command
                    pixelReady          <= 1'b0;                        //Not ready for data
                    //Issue first write in sequence
                    displayData         <= {8'b0,cmdData};              //Load command data onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                    displayRegSelect    <= 1'b0;                        //Loading a command word
                    stateMachine        <= CMD_STATE;                   //Jump to command state for payload
                end else if (displayReady && pixelWrite) begin
                    //Otherwise if pixel write requested
                    cmdReady            <= 1'b0;                        //Not ready for a command
                    pixelReady          <= 1'b1;                        //Accepted data
                    //Backup pixel information for later in the state machine
                    xAddrTemp           <= {{(16-XBITS){1'b0}},xAddr};  //Store the current x
                    yAddrTemp           <= {{(16-YBITS){1'b0}},yAddr};  //and y addresses
                    pixelDataTemp       <= pixelData;                   //Store the current pixel data
                    if (pixelRawMode) begin
                        //If in raw pixel mode, just load the data
                        displayRegSelect<= 1'b1;                        //Loading a pixel data word
                        displayData     <= pixelData;                   //Load raw pixel data
                    end else begin
                        //If in normal mode, go through setting of X-Y coordinates.
                        displayRegSelect<= 1'b0;                        //Loading a command word
                        displayData     <= 16'h2A;                      //Load CASET command onto display output
                        stateMachine    <= CASET_STATE;                 //Jump to CASET state
                    end
                    //Issue first write in sequence
                    displayWrite        <= 1'b1;                        //Issue a write
                end else begin
                    //Otherwise we are not ready until an access is requested
                    cmdReady            <= 1'b0;                        //Not ready for a command
                    pixelReady          <= 1'b0;                        //Not ready for data
                    displayWrite        <= 1'b0;                        //Don't perform write while in Idle
                end
            end
            CMD_STATE: begin
                cmdReady                <= displayReady;                //Control flow of data into command port based on when display is ready
                if (displayReady && cmdWrite) begin
                    //If additional payload, load next byte
                    displayData         <= {8'b0,cmdData};              //Load command data onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                    if (cmdDone) begin
                        //If this is the last command, go to cleanup state
                        stateMachine    <= IDLE_STATE;
                    end
                end else begin
                    displayWrite        <= 1'b0;                        //Write done
                end
            end
            CASET_STATE: begin //Column Select
                pixelReady              <= 1'b0;                        //Not ready for next pixel.
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    displayRegSelect    <= 1'b1;                        //Next display write is a payload
                    displayData         <= {8'b0,xAddrTemp[15:8]};      //Load X-High payload onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                    stateMachine        <= XHADDR_STATE;                //Next payload will be X-High
                end
            end
            XHADDR_STATE: begin //Load X-High Address
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    displayRegSelect    <= 1'b1;                        //Next display write is a payload
                    displayData         <= {8'b0,xAddrTemp[7:0]};       //Load X-Low payload onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                    stateMachine        <= XLADDR_STATE;                //Next payload will be X-Low
                end
            end
            XLADDR_STATE: begin //Load X-Low Address
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    stateMachine        <= PASET_STATE;                 //Next command will be PASET
                    displayRegSelect    <= 1'b0;                        //Next display write is a command
                    displayData         <= 16'h2B;                      //Load PASET command onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                end
            end
            PASET_STATE: begin //Row Select
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    stateMachine        <= YHADDR_STATE;                //Next payload will be Y-High
                    displayRegSelect    <= 1'b1;                        //Next display write is a payload
                    displayData         <= {8'b0,yAddrTemp[15:8]};      //Load Y-High payload onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                end
            end
            YHADDR_STATE: begin //Load Y-High Address
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    stateMachine        <= YLADDR_STATE;                //Next payload will be Y-Low
                    displayRegSelect    <= 1'b1;                        //Next display write is a payload
                    displayData         <= {8'b0,yAddrTemp[7:0]};       //Load Y-Low payload onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                end
            end
            YLADDR_STATE: begin //Load Y-Low Address
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    stateMachine        <= WRITE_STATE;                 //Next command will be Memory Write
                    displayRegSelect    <= 1'b0;                        //Next display write is a command
                    displayData         <= 16'h2C;                      //Load WRITE command onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                end
            end
            WRITE_STATE: begin //Memory Write Enable
                if (displayReady) begin
                    //Once the display is ready for next transfer
                    stateMachine        <= IDLE_STATE;                  //Next payload will be Pixel Data and we are done.
                    displayRegSelect    <= 1'b1;                        //Next display write is pixel data
                    displayData         <= pixelDataTemp;               //Load pixel data onto display output
                    displayWrite        <= 1'b1;                        //Issue a write
                end
            end
            default: begin
                stateMachine            <= INIT_STATE;                  //If something goes wrong, reinit the display.
            end
        endcase        
    end
end


//Hold application in reset until display initialised.
assign resetApp = reset || !displayInitialised;

/*
 * Generate interface signals for LT24
 */
LT24DisplayInterface #(
    .CLOCK_FREQ(CLOCK_FREQ)
) LT24Interface (
    //Clock/Reset
    .clock      (clock           ), //Global clock
    .reset      (reset           ), //Synchronised reset
    
    //FPGA Display Interface
    .regSelect  (displayRegSelect),
    .data       (displayData     ),
    .write      (displayWrite    ),
    .ready      (displayReady    ),
    
    //LT24 Interface
    .LT24Wr_n   (LT24Wr_n        ),
    .LT24Rd_n   (LT24Rd_n        ),
    .LT24CS_n   (LT24CS_n        ),
    .LT24RS     (LT24RS          ),
    .LT24Reset_n(LT24Reset_n     ),
    .LT24Data   (LT24Data        )
);


endmodule





/*
 *  LT24 Display Interface
 *  --------------------------------
 *  Generates transations on the LT24 display interface to 
 *  send data or commands.
 *
 *  The FPGA interface signals should not change while ready is 0
 */
module LT24DisplayInterface #(
    parameter CLOCK_FREQ = 64'd50000000
)(
    input              clock,
    input              reset,
    
    //FPGA Interface
    input              regSelect, //1 = Pixel Data, 0 = Command
    input      [ 15:0] data,
    input              write,     //Assert for 1 cycle to initialise write
    output             ready,     //Indicates the LCD is ready to receive data/command
    
    //LCD Interface
    output             LT24Wr_n,
    output             LT24Rd_n,
    output             LT24CS_n,
    output             LT24RS,
    output             LT24Reset_n,
    output     [ 15:0] LT24Data
);

/*
 * Reset pause timing
 */

//Determine requirements for power on reset
`ifdef MODEL_TECH   //For Simulation
localparam RESETTIME = 64'd0;   //ms - Skip delay during simulation.
`else               //For Synthesis
localparam RESETTIME = 64'd120; //ms - 120ms is required by display
`endif              //End preprocessor block
localparam RESETCOUNT = (RESETTIME * CLOCK_FREQ) / 64'd1000;
localparam RESETBITS = `CLOG2(RESETCOUNT+1); //The +1 ensures we always have room for counter to == RESETCOUNT

//These help make parameterised widths easier.
localparam ZERO = 0;
localparam ONE = 1;

//Reset delay counter
reg [RESETBITS-1:0] counter;
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        counter <= ZERO[RESETBITS-1:0];                 //Initially counter is zero
    end else if (counter < RESETCOUNT) begin //Once we are out of reset
        //If we haven't had a long enough reset pause
        counter <= counter + ONE[RESETBITS-1:0];        //Increment counter
    end
end

/*
 * Write control
 */

//Writes take two cycles, so track second cycle.
reg writeDly = 1'b0;
always @ (posedge clock) begin
    writeDly <= write && !writeDly;
end

//Assert ready after the reset pause and when we are not in the first write cycle
assign ready = !(counter < RESETCOUNT) && !(write && !writeDly);

/*
 * External interface
 */

assign LT24CS_n     = 1'b0;
assign LT24Rd_n     = 1'b1;
assign LT24Data     = data;
assign LT24RS       = regSelect;
assign LT24Wr_n     = writeDly;
assign LT24Reset_n  = !reset;


endmodule



/*
 *  Simple Reset Synchroniser
 *  --------------------------------
 *  This will generate a few clock cycle reset at power on
 *  or when the input reset is asserted.
 */
module ResetSynchroniser (
    input clock,
    input resetIn,
    
    output resetOut
);

//Reset synchroniser to avoid metastability if external push-button used
reg [3:0] resetSync = 4'hF;

always @ (posedge clock or posedge resetIn) begin
    if (resetIn) begin
        resetSync <= 4'hF; //Assert reset asynchronously
    end else begin
        resetSync <= {resetSync[2:0],1'b0}; //Deassert reset synchronously
    end
end

assign resetOut = resetSync[3];

endmodule



/*
 *  Initialisation Data Lookup Table
 *  --------------------------------
 *  Contains initialisation data for LT24 Display
 */

module LT24InitialData #(
    parameter WIDTH  = 240,
    parameter HEIGHT = 320
)(
    input            clock,
    input      [6:0] addr,
    output reg [8:0] initData,
    output     [6:0] maxAddr
);

localparam MAX_X_PIXEL = WIDTH - 1;
localparam MAX_Y_PIXEL = HEIGHT - 1;

localparam INIT_LENGTH = 102;
assign maxAddr = INIT_LENGTH[6:0]; //This can be used to determine when full ROM has been read.

localparam ROM_LENGTH = 2**(`CLOG2(INIT_LENGTH)); //Find next highest power of two that will fit the init data.
reg [8:0] ROM [ROM_LENGTH-1:0];

integer i;

initial begin
    //Note - this is ugly. A better approach is to use a .mif file.
    ROM[7'd000] <= {1'b0,8'hEF};
    ROM[7'd001] <= {1'b1,8'h03};
    ROM[7'd002] <= {1'b1,8'h80};
    ROM[7'd003] <= {1'b1,8'h02};
    ROM[7'd004] <= {1'b0,8'hCF};
    ROM[7'd005] <= {1'b1,8'h00};
    ROM[7'd006] <= {1'b1,8'h81};
    ROM[7'd007] <= {1'b1,8'hc0};
    ROM[7'd008] <= {1'b0,8'hED};
    ROM[7'd009] <= {1'b1,8'h64};
    ROM[7'd010] <= {1'b1,8'h03};
    ROM[7'd011] <= {1'b1,8'h12};
    ROM[7'd012] <= {1'b1,8'h81};
    ROM[7'd013] <= {1'b0,8'hE8};
    ROM[7'd014] <= {1'b1,8'h85};
    ROM[7'd015] <= {1'b1,8'h01};
    ROM[7'd016] <= {1'b1,8'h78};
    ROM[7'd017] <= {1'b0,8'hCB};
    ROM[7'd018] <= {1'b1,8'h39};
    ROM[7'd019] <= {1'b1,8'h2C};
    ROM[7'd020] <= {1'b1,8'h00};
    ROM[7'd021] <= {1'b1,8'h34};
    ROM[7'd022] <= {1'b1,8'h02};
    ROM[7'd023] <= {1'b0,8'hF7};
    ROM[7'd024] <= {1'b1,8'h20};
    ROM[7'd025] <= {1'b0,8'hEA};
    ROM[7'd026] <= {1'b1,8'h00};
    ROM[7'd027] <= {1'b1,8'h00};
    ROM[7'd028] <= {1'b0,8'hC0};
    ROM[7'd029] <= {1'b1,8'h23};
    ROM[7'd030] <= {1'b0,8'hC1};
    ROM[7'd031] <= {1'b1,8'h10};
    ROM[7'd032] <= {1'b0,8'hC5};
    ROM[7'd033] <= {1'b1,8'h3E};
    ROM[7'd034] <= {1'b1,8'h28};
    ROM[7'd035] <= {1'b0,8'hC7};
    ROM[7'd036] <= {1'b1,8'h86};
    ROM[7'd037] <= {1'b0,8'h36};
    ROM[7'd038] <= {1'b1,8'h48};
    ROM[7'd039] <= {1'b0,8'h3A};
    ROM[7'd040] <= {1'b1,8'h55};
    ROM[7'd041] <= {1'b0,8'hB1};
    ROM[7'd042] <= {1'b1,8'h00};
    ROM[7'd043] <= {1'b1,8'h1b};
    ROM[7'd044] <= {1'b0,8'hB6};
    ROM[7'd045] <= {1'b1,8'h08};
    ROM[7'd046] <= {1'b1,8'h82};
    ROM[7'd047] <= {1'b1,8'h27};
    ROM[7'd048] <= {1'b0,8'hF2};
    ROM[7'd049] <= {1'b1,8'h00};
    ROM[7'd050] <= {1'b0,8'h26};
    ROM[7'd051] <= {1'b1,8'h01};
    ROM[7'd052] <= {1'b0,8'hE0};
    ROM[7'd053] <= {1'b1,8'h0F};
    ROM[7'd054] <= {1'b1,8'h31};
    ROM[7'd055] <= {1'b1,8'h2B};
    ROM[7'd056] <= {1'b1,8'h0C};
    ROM[7'd057] <= {1'b1,8'h0E};
    ROM[7'd058] <= {1'b1,8'h08};
    ROM[7'd059] <= {1'b1,8'h4E};
    ROM[7'd060] <= {1'b1,8'hF1};
    ROM[7'd061] <= {1'b1,8'h37};
    ROM[7'd062] <= {1'b1,8'h07};
    ROM[7'd063] <= {1'b1,8'h10};
    ROM[7'd064] <= {1'b1,8'h03};
    ROM[7'd065] <= {1'b1,8'h0E};
    ROM[7'd066] <= {1'b1,8'h09};
    ROM[7'd067] <= {1'b1,8'h00};
    ROM[7'd068] <= {1'b0,8'hE1};
    ROM[7'd069] <= {1'b1,8'h00};
    ROM[7'd070] <= {1'b1,8'h0E};
    ROM[7'd071] <= {1'b1,8'h14};
    ROM[7'd072] <= {1'b1,8'h03};
    ROM[7'd073] <= {1'b1,8'h11};
    ROM[7'd074] <= {1'b1,8'h07};
    ROM[7'd075] <= {1'b1,8'h31};
    ROM[7'd076] <= {1'b1,8'hC1};
    ROM[7'd077] <= {1'b1,8'h48};
    ROM[7'd078] <= {1'b1,8'h08};
    ROM[7'd079] <= {1'b1,8'h0F};
    ROM[7'd080] <= {1'b1,8'h0C};
    ROM[7'd081] <= {1'b1,8'h31};
    ROM[7'd082] <= {1'b1,8'h36};
    ROM[7'd083] <= {1'b1,8'h0f};
    ROM[7'd084] <= {1'b0,8'hB1};
    ROM[7'd085] <= {1'b1,8'h00};
    ROM[7'd086] <= {1'b1,8'h01};
    ROM[7'd087] <= {1'b0,8'hf6};
    ROM[7'd088] <= {1'b1,8'h01};
    ROM[7'd089] <= {1'b1,8'h10};
    ROM[7'd090] <= {1'b1,8'h00};
    ROM[7'd091] <= {1'b0,8'h11};
    ROM[7'd092] <= {1'b0,8'h2A};
    ROM[7'd093] <= {1'b1,8'h00};
    ROM[7'd094] <= {1'b1,8'h00};
    ROM[7'd095] <= {1'b1,MAX_X_PIXEL[15:8]};
    ROM[7'd096] <= {1'b1,MAX_X_PIXEL[ 7:0]};
    ROM[7'd097] <= {1'b0,8'h2B};
    ROM[7'd098] <= {1'b1,8'h00};
    ROM[7'd099] <= {1'b1,8'h00};
    ROM[7'd100] <= {1'b1,MAX_Y_PIXEL[15:8]};
    ROM[7'd101] <= {1'b1,MAX_Y_PIXEL[ 7:0]};
    ROM[7'd102] <= {1'b0,8'h29};
    for (i = INIT_LENGTH+1; i < ROM_LENGTH; i=i+1) begin
        ROM[i]  <= {1'b0,8'h00}; //Pad others as NOP command.
    end
end

always @ (posedge clock) begin
    initData <= ROM[addr];
end

endmodule
