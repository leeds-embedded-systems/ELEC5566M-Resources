/*
 * Mini-Project Example Top-Level Module
 * -------------------------------------
 *
 * This is an example top-level module which you can use for your mini-projects
 * to add functionality for using the HPSWrapper core. This wrapper provides
 * access to the DDR3 memory and the the USB-UART connection.
 *
 * There are a series of `define statements which are used to select which bits
 * of the functionality of the HPS Wrapper you want included.
 *
 * USE_HPS_WRAPPER
 * ---------------
 * If uncommented: Design will make use the the full HPSWrapper core. (default)
 * If commented:   Just the LT24 controller will be instantiated.
 *
 * USE_DDR3_MEMORY
 * ---------------
 * If 1: You can use 64MB of DDR3 memory in your design. (default)
 * If 0: There is no access to this memory.
 *
 * USE_SDMMC_SAVE_INTERFACE
 * ------------------------
 * If 1: An interface to allow DDR3 to be saved to SD Card (default)
 * If 0: No such interface.
 *
 * USE_UART_INTERFACE
 * ------------------
 * If 1: You can use the USB-UART connector (mini-USB). (default)
 * If 0: You cannot access these pins.
 *
 */

//Comment this line out if HPSWrapper not required
`define USE_HPS_WRAPPER
//-------------------------------------------

//Change this from 1 to 0 if DDR3 not required
`define USE_DDR3_MEMORY 1
//-------------------------------------------

//Change this from 1 to 0 if Save not required
`define USE_SDMMC_SAVE_INTERFACE 1
//-------------------------------------------

//Change this from 1 to 0 if UART not required
`define USE_UART_INTERFACE 1
//-------------------------------------------

module ExampleTopLevel (
/*
 *    --------->>>>   DO NOT CHANGE BETWEEN HERE
 */
`ifdef USE_HPS_WRAPPER
    //If we are using the HPS wrapper, and we are not simulating,
    //add the HPS top-level pins.
    //You do NOT need to connect these pins in your test-bench designs!!
    inout         hps_io_hps_io_sdio_inst_CMD     , // hps_io.hps_io_sdio_inst_CMD
    inout         hps_io_hps_io_sdio_inst_D0      , //       .hps_io_sdio_inst_D0
    inout         hps_io_hps_io_sdio_inst_D1      , //       .hps_io_sdio_inst_D1
    output        hps_io_hps_io_sdio_inst_CLK     , //       .hps_io_sdio_inst_CLK
    inout         hps_io_hps_io_sdio_inst_D2      , //       .hps_io_sdio_inst_D2
    inout         hps_io_hps_io_sdio_inst_D3      , //       .hps_io_sdio_inst_D3
    inout         hps_io_hps_io_i2c0_inst_SDA     , //       .hps_io_i2c0_inst_SDA
    inout         hps_io_hps_io_i2c0_inst_SCL     , //       .hps_io_i2c0_inst_SCL
    inout         hps_io_hps_io_gpio_inst_GPIO48  , //       .hps_io_gpio_inst_GPIO48
    inout         hps_io_hps_io_gpio_inst_GPIO53  , //       .hps_io_gpio_inst_GPIO53
    inout         hps_io_hps_io_gpio_inst_GPIO54  , //       .hps_io_gpio_inst_GPIO54
    inout         hps_io_hps_io_gpio_inst_LOANIO49, //       .hps_io_gpio_inst_LOANIO49
    inout         hps_io_hps_io_gpio_inst_LOANIO50, //       .hps_io_gpio_inst_LOANIO50
    output [14:0] memory_mem_a                    , // memory.mem_a
    output [ 2:0] memory_mem_ba                   , //       .mem_ba
    output        memory_mem_ck                   , //       .mem_ck
    output        memory_mem_ck_n                 , //       .mem_ck_n
    output        memory_mem_cke                  , //       .mem_cke
    output        memory_mem_cs_n                 , //       .mem_cs_n
    output        memory_mem_ras_n                , //       .mem_ras_n
    output        memory_mem_cas_n                , //       .mem_cas_n
    output        memory_mem_we_n                 , //       .mem_we_n
    output        memory_mem_reset_n              , //       .mem_reset_n
    inout  [31:0] memory_mem_dq                   , //       .mem_dq
    inout  [ 3:0] memory_mem_dqs                  , //       .mem_dqs
    inout  [ 3:0] memory_mem_dqs_n                , //       .mem_dqs_n
    output        memory_mem_odt                  , //       .mem_odt
    output [ 3:0] memory_mem_dm                   , //       .mem_dm
    input         memory_oct_rzqin                , //       .oct_rzqin
`endif
/*
 *   <<<<<--------- AND HERE
 */

/*
 *   Add Your Pins Here
 */

//e.g. LEDs, 7-Segs, etc.






//50MHz Clock 
    input         clock,
    
//LT24 Display
    output        LT24CS_n   ,
    output        LT24RS     ,
    output        LT24Rd_n   ,
    output        LT24Wr_n   ,
    output [15:0] LT24Data   ,
    output        LT24LCDOn  ,
    output        LT24Reset_n
    
);

//
// Application Reset
//
wire reset;             //Application Reset from LT24 - Use For All Logic Clocked with "clock"

//
// UART Interface
//
wire uart_rx;
wire uart_tx;

//
// LT24 Data Interface
//
wire [ 7:0] xAddr;      // - X Address
wire [ 8:0] yAddr;      // - Y Address
wire [15:0] pixelData;  // - Data
wire        pixelWrite; // - Write Request
wire        pixelReady; // - Write Done

//
// LT24 Command Interface
//
wire       pixelRawMode; // - Raw Pixel Mode
wire [7:0] cmdData;      // - Data
wire       cmdWrite;     // - Write Request
wire       cmdDone;      // - Command Done
wire       cmdReady;     // - Ready for command

//
// DDR Read Interface
//
wire        ddr_read_clock;         //Clock for DDR3 Read Logic. Can be connected to "clock"
wire        ddr_read_reset;         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
wire [23:0] ddr_read_address;       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
wire        ddr_read_waitrequest;   //When wait request is high, read is ignored.
wire        ddr_read_read;          //Assert read for one cycle for each word of data to be read.
wire        ddr_read_readdatavalid; //Read Data Valid will be high for each word of data read, but latency varies from read.
wire [31:0] ddr_read_readdata;      //Read Data should only be used if read data valid is high.

//
// DDR Write Interface
//
wire        ddr_write_clock;        //Clock for DDR3 Write Logic. Can be connected to "clock"
wire        ddr_write_reset;        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
wire [23:0] ddr_write_address;      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
wire        ddr_write_waitrequest;  //When wait request is high, write is ignored.
wire        ddr_write_write;        //Assert write for one cycle for each word of data to be written
wire [31:0] ddr_write_writedata;    //Write data should be valid when write is high.
wire [ 3:0] ddr_write_byteenable;   //Byte enable should be valid when write is high.

//
// Save DDR3 to SD Card Interface
//
wire        save_req;       //Asserting (setting high) requests that 64MB chunk of DDR be saved to the SD card. Keep signal high until save_ack goes high.
wire [15:0] save_req_info;  //Amount of data to be saved, in units of 1024-byte chunks. 1=1kB, 2=2kB, 3=3kB, ..., 65535=65535kB, 0=64MB. Note: Saved file size ~= save_req_info * 11kB
wire        save_ack;       //Save Complete. ACK will be high for a single clock cycle once the memory has been saved.
wire [15:0] save_ack_info;  //Status Code. 0 = Success. Otherwise Failed to Save.



/*
 *  Instantiate Your Core Module Here:
 */
 
ExampleCoreModule core (

    //
    // Application Clock
    //
    .clock                 (clock),                 //Main application clock signal (UART, Save Request, LT24 all synchronous to this clock)

    //
    // Application Reset
    //
    .reset                 (reset),                 //Application Reset from LT24 - Use For All Logic Clocked with "clock"
    
    //
    // UART Interface
    //
    .uart_rx               (uart_rx),               //UART Receive Data Line (Data In to FPGA)
    .uart_tx               (uart_tx),               //UART Transmit Data Line (Data Out to USB)

    //
    // DDR Read Interface
    //
    .ddr_read_clock        (ddr_read_clock),         //Clock for DDR3 Read Logic. Can be connected to "clock"
    .ddr_read_reset        (ddr_read_reset),         //Reset for DDR3 Read Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR read logic instead of this wire.
    .ddr_read_address      (ddr_read_address),       //64MB Chunk of DDR3. Word Address (unit of address is 32bit).
    .ddr_read_waitrequest  (ddr_read_waitrequest),   //When wait request is high, read is ignored.
    .ddr_read_read         (ddr_read_read),          //Assert read for one cycle for each word of data to be read.
    .ddr_read_readdatavalid(ddr_read_readdatavalid), //Read Data Valid will be high for each word of data read, but latency varies from read.
    .ddr_read_readdata     (ddr_read_readdata),      //Read Data should only be used if read data valid is high.

    //
    // DDR Write Interface
    //
    .ddr_write_clock       (ddr_write_clock),        //Clock for DDR3 Write Logic. Can be connected to "clock"
    .ddr_write_reset       (ddr_write_reset),        //Reset for DDR3 Write Logic. If "ddr_read_clock" is connected to "clock", use "reset" for DDR write logic instead of this wire.
    .ddr_write_address     (ddr_write_address),      //64MB Chunk of DDR3. Word Address (unit of address is 32bit).  
    .ddr_write_waitrequest (ddr_write_waitrequest),  //When wait request is high, write is ignored.
    .ddr_write_write       (ddr_write_write),        //Assert write for one cycle for each word of data to be written
    .ddr_write_writedata   (ddr_write_writedata),    //Write data should be valid when write is high.
    .ddr_write_byteenable  (ddr_write_byteenable),   //Byte enable should be valid when write is high.

    //
    // LT24 Data Interface
    //
    .xAddr                 (xAddr),                  // - X Address
    .yAddr                 (yAddr),                  // - Y Address
    .pixelData             (pixelData),              // - Data
    .pixelWrite            (pixelWrite),             // - Write Request
    .pixelReady            (pixelReady),             // - Write Done

    //
    // LT24 Command Interface
    //
    .pixelRawMode          (pixelRawMode),           // - Raw Pixel Mode
    .cmdData               (cmdData),                // - Data
    .cmdWrite              (cmdWrite),               // - Write Request
    .cmdDone               (cmdDone),                // - Command Done
    .cmdReady              (cmdReady),               // - Ready for command
    
    //
    // Save DDR3 to SD Card Interface
    //
    .save_req              (save_req),               //Asserting (setting high) requests that 64MB chunk of DDR be saved to the SD card. Keep signal high until save_ack goes high.
    .save_req_info         (save_req_info),          //Amount of data to be saved, in units of 1024-byte chunks. 1=1kB, 2=2kB, 3=3kB, ..., 65535=65535kB, 0=64MB. Note: Saved file size ~= save_req_info * 11kB
    .save_ack              (save_ack),               //Save Complete. ACK will be high for a single clock cycle once the memory has been saved.
    .save_ack_info         (save_ack_info)           //Status Code. 0 = Success. Otherwise Failed to Save.

);



/*
 *  DO NOT EDIT BELOW THIS LINE
 *
 *  Here we instantiate either the HPSWrapper core, or the LT24 display controller.
 *
 */

`ifndef USE_HPS_WRAPPER
    //If not using HPS Wrapper, Instantiate LT24 Display and Power-on Reset

    //Generate a reset signal at power-on.
    wire globalReset;
    power_on_reset_hw power_on_reset (
        .clock(clock      ),
        .reset(globalReset)
    );

    //Instantiate LT24 Display controller
    LT24Display #(
        .WIDTH      (240),
        .HEIGHT     (320),
        .CLOCK_FREQ (50000000)
    ) lt24_fpga (
        //Clock/Reset Inputs
        .clock        (clock      ),
        .globalReset  (globalReset),
       
        //Application Reset
        .resetApp     (reset),
        
        //Pixel Interface
        .pixelReady   (pixelReady),
        .pixelData    (pixelData ),
        .pixelWrite   (pixelWrite),
        .xAddr        (xAddr     ),
        .yAddr        (yAddr     ),
        
        //Optional Command/Data Interface
        .pixelRawMode (pixelRawMode),
        .cmdReady     (cmdReady    ),
        .cmdData      (cmdData     ),
        .cmdWrite     (cmdWrite    ),
        .cmdDone      (cmdDone     ),
        
        //LT24 Display Interface - DO NOT RENAME
        .LT24CS_n     (LT24CS_n   ),
        .LT24RS       (LT24RS     ),
        .LT24Rd_n     (LT24Rd_n   ),
        .LT24Wr_n     (LT24Wr_n   ),
        .LT24Data     (LT24Data   ),
        .LT24LCDOn    (LT24LCDOn  ),
        .LT24Reset_n  (LT24Reset_n)
    );

`else
    //Otherwise we are using the HPS Wrapper
    HPSWrapperTop #(
        .USE_DDR3_MEMORY         (`USE_DDR3_MEMORY         ), //Whether to enable DDR.   If set to 0, leave ddr_write_* and ddr_read_* ports unconnected.
        .USE_SDMMC_SAVE_INTERFACE(`USE_SDMMC_SAVE_INTERFACE), //Whether to enable SDMMC. If set to 0, leave handshake_* ports unconnected.
        .USE_UART_INTERFACE      (`USE_UART_INTERFACE      )  //Whether to enable UART.  If set to 0, leave uart_* ports unconnected.
    ) hps_system (
        //Main Application Clock/Reset
        .user_clock_clk   ( clock ), //Application logic clock input signal
        .user_reset_reset ( reset ), //Application logic reset output signal
        
        //LT24 Pixel Interface (synchronous to user_clock_clk)
        .lt24_data_ready ( pixelReady ),
        .lt24_data_data  ( pixelData  ),
        .lt24_data_write ( pixelWrite ),
        .lt24_data_xAddr ( xAddr      ),
        .lt24_data_yAddr ( yAddr      ),

        //LT24 Optional Command/Data Interface (synchronous to user_clock_clk)
        .lt24_mode_raw  ( pixelRawMode ),
        .lt24_cmd_ready ( cmdReady     ),
        .lt24_cmd_data  ( cmdData      ),
        .lt24_cmd_write ( cmdWrite     ),
        .lt24_cmd_done  ( cmdDone      ),
        
        //Connect up UART interface (synchronous to user_clock_clk)
        .usb_uart_rx ( uart_rx ), //(Data In to FPGA)
        .usb_uart_tx ( uart_tx ), //(Data Out to USB)
        
        //DDR3 Read Interface
        .ddr_read_clock_clk     ( ddr_read_clock         ), //Clock for DDR Read Interface. Can be same as user_clock_clk
        .ddr_read_reset_reset   ( ddr_read_reset         ), //If ddr_read_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset for read logic.
        .ddr_read_address       ( ddr_read_address       ), //Use upper chunk of DDR3 memory, HPS base address 0x30000000
        .ddr_read_waitrequest   ( ddr_read_waitrequest   ), //When wait request is high, read is ignored.
        .ddr_read_read          ( ddr_read_read          ), //Assert read for one cycle for each word of data to be read.
        .ddr_read_readdatavalid ( ddr_read_readdatavalid ), //Read Data Valid will be high for each word of data read, but latency varies from read.
        .ddr_read_readdata      ( ddr_read_readdata      ), //Read Data should only be used if read data valid is high.
        
        //DDR3 Write Interface
        .ddr_write_clock_clk   ( ddr_write_clock       ), //Clock for DDR Write Interface. Can be same as user_clock_clk
        .ddr_write_reset_reset ( ddr_write_reset       ), //If ddr_write_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset instead.
        .ddr_write_address     ( ddr_write_address     ),
        .ddr_write_waitrequest ( ddr_write_waitrequest ), //When wait request is high, write is ignored.
        .ddr_write_write       ( ddr_write_write       ), //Assert write for one cycle for each word of data to be written
        .ddr_write_writedata   ( ddr_write_writedata   ), //Write data should be valid when write is high.
        .ddr_write_byteenable  ( ddr_write_byteenable  ), //Byte enable should be valid when write is high.
        
        //Save DDR3 Memory to SDMMC
        .handshake_in_port  ( {save_req, save_req_info} ),
        .handshake_out_port ( {save_ack, save_ack_info} ),

        //
        // External Interfaces - Connect Directly to Input/Output Port List
        //
        
        //External LT24 Connections - DO NOT RENAME
        .lt24_display_cs_n  ( LT24CS_n     ),
        .lt24_display_rs    ( LT24RS       ),
        .lt24_display_rd_n  ( LT24Rd_n     ),
        .lt24_display_wr_n  ( LT24Wr_n     ),
        .lt24_display_data  ( LT24Data     ),
        .lt24_display_on    ( LT24LCDOn    ),
        .lt24_display_rst_n ( LT24Reset_n  ),
        
        //External GPIO Connections for HPS - DO NOT RENAME
        .hps_io_hps_io_sdio_inst_CMD      ( hps_io_hps_io_sdio_inst_CMD      ),
        .hps_io_hps_io_sdio_inst_D0       ( hps_io_hps_io_sdio_inst_D0       ),
        .hps_io_hps_io_sdio_inst_D1       ( hps_io_hps_io_sdio_inst_D1       ),
        .hps_io_hps_io_sdio_inst_CLK      ( hps_io_hps_io_sdio_inst_CLK      ),
        .hps_io_hps_io_sdio_inst_D2       ( hps_io_hps_io_sdio_inst_D2       ),
        .hps_io_hps_io_sdio_inst_D3       ( hps_io_hps_io_sdio_inst_D3       ),
        .hps_io_hps_io_i2c0_inst_SDA      ( hps_io_hps_io_i2c0_inst_SDA      ),
        .hps_io_hps_io_i2c0_inst_SCL      ( hps_io_hps_io_i2c0_inst_SCL      ),
        .hps_io_hps_io_gpio_inst_GPIO48   ( hps_io_hps_io_gpio_inst_GPIO48   ),
        .hps_io_hps_io_gpio_inst_GPIO53   ( hps_io_hps_io_gpio_inst_GPIO53   ),
        .hps_io_hps_io_gpio_inst_GPIO54   ( hps_io_hps_io_gpio_inst_GPIO54   ),
        .hps_io_hps_io_gpio_inst_LOANIO49 ( hps_io_hps_io_gpio_inst_LOANIO49 ),
        .hps_io_hps_io_gpio_inst_LOANIO50 ( hps_io_hps_io_gpio_inst_LOANIO50 ),

        //External DDR3 Connections for HPS - DO NOT RENAME
        .memory_mem_a       ( memory_mem_a       ),
        .memory_mem_ba      ( memory_mem_ba      ),
        .memory_mem_ck      ( memory_mem_ck      ),
        .memory_mem_ck_n    ( memory_mem_ck_n    ),
        .memory_mem_cke     ( memory_mem_cke     ),
        .memory_mem_cs_n    ( memory_mem_cs_n    ),
        .memory_mem_ras_n   ( memory_mem_ras_n   ),
        .memory_mem_cas_n   ( memory_mem_cas_n   ),
        .memory_mem_we_n    ( memory_mem_we_n    ),
        .memory_mem_reset_n ( memory_mem_reset_n ),
        .memory_mem_dq      ( memory_mem_dq      ),
        .memory_mem_dqs     ( memory_mem_dqs     ),
        .memory_mem_dqs_n   ( memory_mem_dqs_n   ),
        .memory_mem_odt     ( memory_mem_odt     ),
        .memory_mem_dm      ( memory_mem_dm      ),
        .memory_oct_rzqin   ( memory_oct_rzqin   )
    );
        
`endif //USE_HPS_WRAPPER


endmodule

