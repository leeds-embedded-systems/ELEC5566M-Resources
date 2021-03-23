 /*
 * Mini-Project Example Core Module
 * -------------------------------------
 *
 * This is an example core module for use with the LeedsFPGAPassthrough.
 *
 * The module is instantiated in LeedsFPGAPassthrough and will contain
 * all user logic.
 *
 * In this example we demonstrate the use of the various interfaces.
 *
 */

module ExampleCoreModule (

    //
    // Application Clock
    //
    input         clock,                  //Main application clock signal (UART, Save Request, LT24 all synchronous to this clock)
    
    //
    // Application Reset
    //
    input         reset,                  //Application Reset from LT24 - Use For All Logic Clocked with "clock"
    
    //
    // UART Interface
    //
    input         uart_rx,                //UART Receive Data Line (Data In to FPGA)
    output        uart_tx,                //UART Transmit Data Line (Data Out to USB)

    //
    // DDR Read Interface
    //
    output        ddr_read_clock,         //Clock for DDR3 Read Logic. Can be connected to "clock"
    input         ddr_read_reset,         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
    output [23:0] ddr_read_address,       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
    input         ddr_read_waitrequest,   //When wait request is high, read is ignored.
    output        ddr_read_read,          //Assert read for one cycle for each word of data to be read.
    input         ddr_read_readdatavalid, //Read Data Valid will be high for each word of data read, but latency varies from read.
    input  [31:0] ddr_read_readdata,      //Read Data should only be used if read data valid is high.

    //
    // DDR Write Interface
    //
    output        ddr_write_clock,        //Clock for DDR3 Write Logic. Can be connected to "clock"
    input         ddr_write_reset,        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
    output [23:0] ddr_write_address,      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
    input         ddr_write_waitrequest,  //When wait request is high, write is ignored.
    output        ddr_write_write,        //Assert write for one cycle for each word of data to be written
    output [31:0] ddr_write_writedata,    //Write data should be valid when write is high.
    output [ 3:0] ddr_write_byteenable,   //Byte enable should be valid when write is high.

    //
    // LT24 Data Interface
    //
    output [ 7:0] xAddr,                  // - X Address
    output [ 8:0] yAddr,                  // - Y Address
    output [15:0] pixelData,              // - Data
    output        pixelWrite,             // - Write Request
    input         pixelReady,             // - Write Done

    //
    // LT24 Command Interface
    //
    output        pixelRawMode,           // - Raw Pixel Mode
    output [ 7:0] cmdData,                // - Data
    output        cmdWrite,               // - Write Request
    output        cmdDone,                // - Command Done
    input         cmdReady,               // - Ready for command
    
    //
    // Save DDR3 to SD Card Interface
    //
    output        save_req,               //Asserting (setting high) requests that 64MB chunk of DDR be saved to the SD card. Keep signal high until save_ack goes high.
    output [15:0] save_req_info,          //Amount of data to be saved, in units of 1024-byte chunks. 1=1kB, 2=2kB, 3=3kB, ..., 65535=65535kB, 0=64MB. Note: Saved file size ~= save_req_info * 11kB
    input         save_ack,               //Save Complete. ACK will be high for a single clock cycle once the memory has been saved.
    input  [15:0] save_ack_info           //Status Code. 0 = Success. Otherwise Failed to Save.
    
);



/*
 * Test UART
 *
 * This is just a simple loop-back to test the UART is working.
 * In practice you need to make your own UART controller as the TX
 * and RX are just the raw pins.
 *
 */

assign uart_tx = uart_rx; //Loopback




/*
 * Test DDR Memory
 *
 * This will write 16kB to the DDR memory using the write interface
 *
 */


//We will use a single clock domain, so DDR write clock is the same as clock
assign ddr_write_clock = clock;


wire        writeWait;
reg         writeRequest;
reg  [23:0] writeAddress;
reg  [31:0] writeData;
reg  [ 3:0] writeByteEn;

reg         writeDone; //All addresses written when high.

always @ (posedge clock or posedge reset) begin //use "reset" for DDR write logic as single clock domain. If using multiple clocks, should use ddr_write_reset instead.
    if (reset) begin
        writeRequest     <= 1'b0;
        writeAddress     <= 24'h000000;
        writeData        <= 32'h00000000;
        writeByteEn      <= 4'hF;
        writeDone        <= 1'b0;
    end else begin
        writeByteEn  <= 4'hF;                           //All bytes written in each 32-bit word for this example.
        writeRequest <= !writeDone;                     //Request to write if we are not yet done.
        if (writeRequest && !writeWait && !writeDone) begin
            //Each time a write is accepted by the memory (i.e. writeRequest is high, and writeWait is low)
            writeAddress <= writeAddress + 24'h1;           //Increment the address
            writeData    <= {8'b0,writeAddress + 24'h1};    //For example, lets set data equal to the address.
`ifdef MODEL_TECH
            writeDone    <= (writeAddress == 24'h2000);     //Done once last address is written. For simulation, we'll use a smaller max value so we don't have to wait as long.
`else
            writeDone    <= (writeAddress == 24'hFFFFFF);   //Done once last address is written.
`endif
        end
    end
end

//External interface signals
assign writeWait = ddr_write_waitrequest;
assign ddr_write_address = writeAddress;
assign ddr_write_writedata = writeData;
assign ddr_write_byteenable = writeByteEn;
assign ddr_write_write = writeRequest;







/*
 * Test LCD + DDR Read
 *
 * Let's test the DDR read interface to write data to
 * the LCD
 *
 */

//Not using command interface for LT24, so will tie control signals to zero as in Lab 5.
assign pixelRawMode = 1'b0; // - Raw Pixel Mode
assign cmdData      = 8'b0; // - Data
assign cmdWrite     = 1'b0; // - Write Request
assign cmdDone      = 1'b0; // - Command Done

//As we are using DDR read to drive the LCD, it *must* be on the same clock domain as the LCD (i.e. "clock")
assign ddr_read_clock = clock;


//LCD signals for state machine
reg        pixelWriteGen;
reg [15:0] pixelDataGen;
reg [16:0] pixelAddressGen;

//DDR signals for state machine
wire        readValid;
reg         readRequest;
reg  [23:0] readAddress;
wire [31:0] readData;
wire        readWait;

//State machine
reg [1:0] stateMachine;

localparam IDLE_STATE = 2'b00;
localparam READ_STATE = 2'b01;
localparam WAIT_STATE = 2'b10;
localparam DONE_STATE = 2'b11;


always @ (posedge clock or posedge reset) begin
    if (reset) begin
        readRequest     <= 1'b0;
        readAddress     <= 24'h0;
        pixelWriteGen   <= 1'b0;
        pixelAddressGen <= 17'b0;
        pixelDataGen    <= 16'b0;
        stateMachine    <= IDLE_STATE;
    end else begin
        case (stateMachine)
            IDLE_STATE: begin
                if (writeDone) begin
                    //If the display is read to receive data
                    readRequest     <= 1'b1;                   //Issue read request for current address
                    stateMachine    <= READ_STATE;             //And jump to read state
                end
            end
            READ_STATE: begin
                if (!readWait) begin
                    //Once the read request has been accepted
                    readRequest     <= 1'b0;                   //Drop request signal
                    stateMachine    <= WAIT_STATE;             //And wait for valid data
                end
            end
            WAIT_STATE: begin
                if (readValid) begin
                    //Once valid data has arrived
                    pixelWriteGen   <= 1'b1;                   //Begin writing to LCD
                    pixelAddressGen <= readAddress[16:0];      //Write data to pixel equal to read address
                    pixelDataGen    <= readData[15:0];         //Data is lower 16-bits of DDR read data
                    stateMachine    <= DONE_STATE;             //And jump to done state
                end
            end
            DONE_STATE: begin
                if (pixelReady) begin
                    //Once pixel has been accepted, we are finished
                    pixelWriteGen       <= 1'b0;                   //Ensure we only send one write to the LCD
                    readAddress         <= readAddress + 24'b1;    //Increment to next read address
                    stateMachine        <= IDLE_STATE;             //Return to idle ready to read next pixel.
                end
            end
        endcase
    end
end

//External interface signals
assign readWait = ddr_read_waitrequest;
assign readValid = ddr_read_readdatavalid;
assign readData  = ddr_read_readdata;
assign ddr_read_read = readRequest;
assign ddr_read_address = readAddress;

assign pixelWrite = pixelWriteGen;
assign pixelData = pixelDataGen;
assign {yAddr,xAddr} = pixelAddressGen;





/*
 * Test Handshake
 *
 * This module tests the Save-To-SDCard interface.
 * When the DDR write address reaches 0x2000 (32kB),
 * it will request saving of 32kB to SD.
 *
 */


reg  saveRequest;
wire saveAcknowledge;

always @ (posedge clock or posedge reset) begin
    if (reset) begin
        saveRequest     <= 1'b0;
    end else if (saveAcknowledge) begin
        //Once save is acknowledged
        saveRequest <= 1'b0;  //Clear request signal
    end else if (writeAddress == 24'h2000) begin
        //Request save once write address is 0x2000
        saveRequest <= 1'b1;
    end
end

assign save_req_info = 16'd32; //Save 32 x 1kB chunks (i.e. 32kB).
assign save_req = saveRequest;
assign saveAcknowledge = save_ack;

//End of ExampleCoreModule
endmodule
