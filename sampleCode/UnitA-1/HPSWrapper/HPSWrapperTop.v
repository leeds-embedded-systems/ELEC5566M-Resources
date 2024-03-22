/*
 * HPS Wrapper for DDR3 and UART Pass-Through
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 11th March 2018
 *
 * Module Description:
 * -------------------
 * 
 * This module is designed to provide access to the DDR3
 * memory and UART pins on the DE1-SoC board by using the
 * embedded hard processor system to provide access. 
 *
 * The system also includes an instance of the LT24 driver
 * so when using HPSWrapperTop you do not need to instantiate
 * the LCD driver core separately.
 *
 * The module also support simulation with ModelSim. When the
 * simulation is detected, a functional model will be used in
 * place of the HPSWrapper. The HPS itself cannot be simulated
 * so we use a model instead.
 *
 * DDR3 Memory
 * -----------
 *
 * The two DDR3 memory provide access to 64MB of DDR3
 * memory which is connected to the ARM HPS. You can
 * use this memory in your project if you need to store
 * large amounts of data. 
 * 
 * However please note that the these interfaces are more
 * complex than simply interfacing with on-chip memory as
 * DDR3 memory has high latency and is not always ready
 * to have data read/written (e.g. if it is refreshing).
 *
 * The interfaces are called "Avalon Memory-Mapped" which
 * is a specification used by Altera. For more information
 * you should refer to the "Avalon® Interface Specifications"
 * document provided by Altera.
 *
 * If you are not using the DDR memory for your project, leave
 * the parameter USE_DDR3_MEMORY set to 0 and ignore the read_*
 * and write_* pins.
 *
 *
 * SDMMC Save Interface
 * --------------------
 *
 * This provides a handshake interface to request that the
 * HPS dump the 64MB chunk of DDR memory (or a piece of it)
 * to a file on the SD card.
 *
 * To save the memory, simply assert the handshake_in_port[16]
 * signal, and set handshake_in_port[15:0] equal to the amount
 * of data to save (the value represents number of 1kB chunks
 * with 0 meaning all 64MB).
 *
 * The handshake_in_port[16] signal should be held high until
 * the handshake_out_port[16] goes high after a few clock cycles,
 * after which handshake_in_port[16] should be set back low. The
 * is saved once handshake_out_port[16] goes low.
 *
 *          :___:___:                 :    _
 * Req: ____/   :   \\\\\\____________:___/_
 *          :   :___:_________________:
 * Ack: ____:___/   :                 \_____
 *          :   :   :                 :
 *         (1) (2) (3)  (<---4--->)  (5)
 *
 * (1): FPGA requests that DDR memory be saved to file
 * (2): HPS acknowledges request
 * (3): FPGA clears request signal
 * (4): DDR is being saved. Do not modify DDR, or set request high
 * (5): HPS clears acknowledge to indicated data has been saved.
 *
 * If you are not using the Handshake for your project, leave
 * the parameter USE_SDMMC_SAVE_INTERFACE set to 0 and ignore
 * the handshake_* pins.
 *
 *
 * UART Interface
 * --------------
 *
 * This provides access to the HPS UART RX and TX pins.
 * You can use the Mini-USB connector on the top-right
 * corner of the board (J4) which provides a USB-Serial
 * hardware conversion.
 *
 * You will have to write your own UART state-machine 
 * to encode/decode serial data. This core simply provides
 * access to the HPS pins.
 *
 * If you are not using the UART for your project, leave
 * the parameter USE_UART_INTERFACE set to 0 and ignore
 * the usb_uart_* pins.
 *
 */

(* altera_attribute ="-name MESSAGE_DISABLE 113006; -name MESSAGE_DISABLE 10236; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10034; -name MESSAGE_DISABLE 10858; -name MESSAGE_DISABLE 10230; -name MESSAGE_DISABLE 10030; -name MESSAGE_DISABLE 12158; -name MESSAGE_DISABLE 12241; -name MESSAGE_DISABLE 13009; -name MESSAGE_DISABLE 13010" *) 
module HPSWrapperTop #(
    parameter USE_DDR3_MEMORY          = 0, //Whether to enable DDR.   If set to 0, leave ddr_write_* and ddr_read_* ports unconnected.
    parameter USE_SDMMC_SAVE_INTERFACE = 0, //Whether to enable SDMMC. If set to 0, leave handshake_* ports unconnected.
    parameter USE_UART_INTERFACE       = 0  //Whether to enable UART.  If set to 0, leave uart_* ports unconnected.
)(
    //Main Application Clock/Reset
    input         user_clock_clk,                   //      user_clock.clk
    output        user_reset_reset,                 //      user_reset.reset
    
    //LT24 Pixel Interface (synchronous to user_clock_clk)
    output        lt24_data_ready,                  //       lt24_data.ready
    input  [15:0] lt24_data_data,                   //                .data
    input         lt24_data_write,                  //                .write
    input  [ 7:0] lt24_data_xAddr,                  //                .xAddr
    input  [ 8:0] lt24_data_yAddr,                  //                .yAddr

    //LT24 Optional Command/Data Interface (synchronous to user_clock_clk)
    input         lt24_mode_raw,                    //       lt24_mode.raw
    output        lt24_cmd_ready,                   //        lt24_cmd.ready
    input  [ 7:0] lt24_cmd_data,                    //                .data
    input         lt24_cmd_write,                   //                .write
    input         lt24_cmd_done,                    //                .done
    
    //Connect up UART interface (synchronous to user_clock_clk)
    output        usb_uart_rx,                      //        usb_uart.rx
    input         usb_uart_tx,                      //                .tx
    
    //DDR3 Read Interface
    input         ddr_read_clock_clk,               //  ddr_read_clock.clk
    output        ddr_read_reset_reset,             //  ddr_read_reset.reset
    input  [23:0] ddr_read_address,                 //        ddr_read.address
    output        ddr_read_waitrequest,             //                .waitrequest
    input         ddr_read_read,                    //                .read
    output        ddr_read_readdatavalid,           //                .readdatavalid
    output [31:0] ddr_read_readdata,                //                .readdata
    
    //DDR3 Write Interface
    input         ddr_write_clock_clk,              // ddr_write_clock.clk
    output        ddr_write_reset_reset,            // ddr_write_reset.reset
    input  [23:0] ddr_write_address,                //       ddr_write.address
    output        ddr_write_waitrequest,            //                .waitrequest
    input         ddr_write_write,                  //                .write
    input  [31:0] ddr_write_writedata,              //                .writedata
    input  [ 3:0] ddr_write_byteenable,             //                .byteenable
    
    //Save DDR3 Memory to SDMMC
    input  [16:0] handshake_in_port,                //       handshake.in_port
    output [16:0] handshake_out_port,               //                .out_port
    
    //
    // External Interfaces - Connect Directly to Input/Output Port List
    //
    
    //External LT24 Connections
    output        lt24_display_cs_n,                //    lt24_display.cs_n
    output        lt24_display_rs,                  //                .rs
    output        lt24_display_rd_n,                //                .rd_n
    output        lt24_display_wr_n,                //                .wr_n
    output [15:0] lt24_display_data,                //                .data
    output        lt24_display_on,                  //                .on
    output        lt24_display_rst_n,               //                .rst_n
    
    //External GPIO Connections for HPS
    inout         hps_io_hps_io_sdio_inst_CMD,      //          hps_io.hps_io_sdio_inst_CMD
    inout         hps_io_hps_io_sdio_inst_D0,       //                .hps_io_sdio_inst_D0
    inout         hps_io_hps_io_sdio_inst_D1,       //                .hps_io_sdio_inst_D1
    output        hps_io_hps_io_sdio_inst_CLK,      //                .hps_io_sdio_inst_CLK
    inout         hps_io_hps_io_sdio_inst_D2,       //                .hps_io_sdio_inst_D2
    inout         hps_io_hps_io_sdio_inst_D3,       //                .hps_io_sdio_inst_D3
    inout         hps_io_hps_io_i2c0_inst_SDA,      //                .hps_io_i2c0_inst_SDA
    inout         hps_io_hps_io_i2c0_inst_SCL,      //                .hps_io_i2c0_inst_SCL
    inout         hps_io_hps_io_gpio_inst_GPIO48,   //                .hps_io_gpio_inst_GPIO48
    inout         hps_io_hps_io_gpio_inst_GPIO53,   //                .hps_io_gpio_inst_GPIO53
    inout         hps_io_hps_io_gpio_inst_GPIO54,   //                .hps_io_gpio_inst_GPIO54
    inout         hps_io_hps_io_gpio_inst_LOANIO49, //                .hps_io_gpio_inst_LOANIO49
    inout         hps_io_hps_io_gpio_inst_LOANIO50, //                .hps_io_gpio_inst_LOANIO50

    //External DDR3 Connections for HPS
    output [14:0] memory_mem_a,                     //          memory.mem_a
    output [ 2:0] memory_mem_ba,                    //                .mem_ba
    output        memory_mem_ck,                    //                .mem_ck
    output        memory_mem_ck_n,                  //                .mem_ck_n
    output        memory_mem_cke,                   //                .mem_cke
    output        memory_mem_cs_n,                  //                .mem_cs_n
    output        memory_mem_ras_n,                 //                .mem_ras_n
    output        memory_mem_cas_n,                 //                .mem_cas_n
    output        memory_mem_we_n,                  //                .mem_we_n
    output        memory_mem_reset_n,               //                .mem_reset_n
    inout  [31:0] memory_mem_dq,                    //                .mem_dq
    inout  [ 3:0] memory_mem_dqs,                   //                .mem_dqs
    inout  [ 3:0] memory_mem_dqs_n,                 //                .mem_dqs_n
    output        memory_mem_odt,                   //                .mem_odt
    output [ 3:0] memory_mem_dm,                    //                .mem_dm
    input         memory_oct_rzqin                  //                .oct_rzqin
    
);

wire usb_uart_rx_i;
wire usb_uart_tx_i;

generate if (USE_UART_INTERFACE) begin
    //Pass-through internal to external if UART enabled
    assign usb_uart_tx_i = usb_uart_tx;
    assign usb_uart_rx   = usb_uart_rx_i;
end else begin
    //Otherwise terminate.
    assign usb_uart_tx_i = 1'b1;
    assign usb_uart_rx   = 1'b1;
end endgenerate

wire [16:0] handshake_in_port_i;
wire [16:0] handshake_out_port_i;

generate if (USE_SDMMC_SAVE_INTERFACE) begin
    //Pass-through internal to external if handshake enabled
    assign handshake_in_port_i = handshake_in_port;
    assign handshake_out_port  = handshake_out_port_i;
end else begin
    //Otherwise terminate.
    assign handshake_in_port_i = 17'b1;
    assign handshake_out_port  = 17'b0;
end endgenerate

wire        ddr_read_clock_clk_i;
wire [29:0] ddr_read_address_i;
wire        ddr_read_waitrequest_i;
wire [31:0] ddr_read_readdata_i;
wire        ddr_read_readdatavalid_i;
wire        ddr_read_read_i;
wire        ddr_write_clock_clk_i;
wire [29:0] ddr_write_address_i;
wire        ddr_write_waitrequest_i;
wire [31:0] ddr_write_writedata_i;
wire [3:0]  ddr_write_byteenable_i;
wire        ddr_write_write_i;
    
generate if (USE_DDR3_MEMORY) begin
    //Pass-through read internal to/from external if DDR enabled
    assign ddr_read_clock_clk_i   = ddr_read_clock_clk;
	assign ddr_read_address_i     = {6'b001100,ddr_read_address};
	assign ddr_read_waitrequest   = ddr_read_waitrequest_i;
	assign ddr_read_readdata      = ddr_read_readdata_i;
	assign ddr_read_readdatavalid = ddr_read_readdatavalid_i;
	assign ddr_read_read_i        = ddr_read_read;
    //Pass-through write internal to/from external if DDR enabled
    assign ddr_write_clock_clk_i  = ddr_write_clock_clk;
	assign ddr_write_address_i    = {6'b001100,ddr_write_address};
	assign ddr_write_waitrequest  = ddr_write_waitrequest_i;
	assign ddr_write_writedata_i  = ddr_write_writedata;
	assign ddr_write_byteenable_i = ddr_write_byteenable;
	assign ddr_write_write_i      = ddr_write_write;
end else begin
    //Otherwise connect up read/write clocks to user clock
    assign ddr_read_clock_clk_i   = user_clock_clk;
    assign ddr_write_clock_clk_i  = user_clock_clk;
    
    //When not using DDR3, add some filler logic to prevent the
    //interfaces being optimised away causing hundreds of SDC
    //warnings.
    reg [12:0] ddr_unusedaddress;

    always @ (posedge user_clock_clk or posedge user_reset_reset) begin
        if (user_reset_reset) begin
            ddr_unusedaddress <= 13'b0;
        end else if (ddr_write_write_i && !ddr_write_waitrequest_i) begin
            if (ddr_unusedaddress < 13'h1000) begin
                ddr_unusedaddress <= ddr_unusedaddress + 13'h1000;
            end
        end
    end

    assign ddr_write_address_i = {11'b0,ddr_unusedaddress};
    assign ddr_write_writedata_i = {ddr_unusedaddress[5:0],2'd3,ddr_unusedaddress[5:0],2'd2,ddr_unusedaddress[5:0],2'd1,ddr_unusedaddress[5:0],2'd0};
    assign ddr_write_byteenable_i = 4'b1111;
    assign ddr_write_write_i = ddr_read_readdatavalid_i;

    assign ddr_read_address_i = {11'b0,ddr_unusedaddress};

    reg [1:0] ddr_read_cntr;
    always @ (posedge user_clock_clk or posedge user_reset_reset) begin
        if (user_reset_reset) begin
            ddr_read_cntr <= 2'd3;
        end else if ((ddr_read_cntr != 2'b0) && !ddr_read_waitrequest_i) begin
            ddr_read_cntr <= ddr_read_cntr + 2'b1; 
        end
    end
    assign ddr_read_read_i = (ddr_read_cntr == 2'b0);
end endgenerate


`ifndef MODEL_TECH
    
    //We are performing Synthesis, so use the HPSWrapper core
    
    HPSWrapper hps_qsys_system (
        //Main Application Clock/Reset
        .user_clock_clk   ( user_clock_clk   ), //Application logic clock input signal
        .user_reset_reset ( user_reset_reset ), //Application logic reset output signal
        
        //LT24 Pixel Interface (synchronous to user_clock_clk)
        .lt24_data_ready ( lt24_data_ready ),
        .lt24_data_data  ( lt24_data_data  ),
        .lt24_data_write ( lt24_data_write ),
        .lt24_data_xAddr ( lt24_data_xAddr ),
        .lt24_data_yAddr ( lt24_data_yAddr ),

        //LT24 Optional Command/Data Interface (synchronous to user_clock_clk)
        .lt24_mode_raw  ( lt24_mode_raw  ),
        .lt24_cmd_ready ( lt24_cmd_ready ),
        .lt24_cmd_data  ( lt24_cmd_data  ),
        .lt24_cmd_write ( lt24_cmd_write ),
        .lt24_cmd_done  ( lt24_cmd_done  ),
        
        //Connect up UART interface (synchronous to user_clock_clk)
        .usb_uart_rx ( usb_uart_rx_i ), //(Data In to FPGA)
        .usb_uart_tx ( usb_uart_tx_i ), //(Data Out to USB)
        
        //DDR3 Read Interface
        .ddr_read_clock_clk     ( ddr_read_clock_clk_i     ), //Clock for DDR Read Interface. Can be same as user_clock_clk
        .ddr_read_reset_reset   ( ddr_read_reset_reset     ), //If ddr_read_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset for read logic.
        .ddr_read_address       ( ddr_read_address_i       ), //Use upper chunk of DDR3 memory, HPS base address 0x30000000
        .ddr_read_burstcount    ( 8'b1                     ),
        .ddr_read_waitrequest   ( ddr_read_waitrequest_i   ), //When wait request is high, read is ignored.
        .ddr_read_read          ( ddr_read_read_i          ), //Assert read for one cycle for each word of data to be read.
        .ddr_read_readdatavalid ( ddr_read_readdatavalid_i ), //Read Data Valid will be high for each word of data read, but latency varies from read.
        .ddr_read_readdata      ( ddr_read_readdata_i      ), //Read Data should only be used if read data valid is high.
        
        //DDR3 Write Interface
        .ddr_write_clock_clk   ( ddr_write_clock_clk_i   ), //Clock for DDR Write Interface. Can be same as user_clock_clk
        .ddr_write_reset_reset ( ddr_write_reset_reset   ), //If ddr_write_clock_clk is same as user_clock_clk, leave unconnected and use user_reset_reset instead.
        .ddr_write_address     ( ddr_write_address_i     ),
        .ddr_write_burstcount  ( 8'b1                    ),
        .ddr_write_waitrequest ( ddr_write_waitrequest_i ), //When wait request is high, write is ignored.
        .ddr_write_write       ( ddr_write_write_i       ), //Assert write for one cycle for each word of data to be written
        .ddr_write_writedata   ( ddr_write_writedata_i   ), //Write data should be valid when write is high.
        .ddr_write_byteenable  ( ddr_write_byteenable_i  ), //Byte enable should be valid when write is high.
        
        //Save DDR3 Memory to SDMMC
        .handshake_in_port  ( handshake_in_port_i ),
        .handshake_out_port ( handshake_out_port_i ),
        
        //Avalon-MM Master - From HPS. Unused.
        .hps_avmm_master_chipselect (       ),
        .hps_avmm_master_read       (       ),
        .hps_avmm_master_readdata   ( 32'b0 ),
        .hps_avmm_master_writedata  (       ),
        .hps_avmm_master_write      (       ),
        .hps_avmm_master_byteenable (       ),
        .hps_avmm_master_address    (       ),

        //
        // External Interfaces - Connect Directly to Input/Output Port List
        //
        
        //External LT24 Connections - DO NOT RENAME
        .lt24_display_cs_n  ( lt24_display_cs_n  ),
        .lt24_display_rs    ( lt24_display_rs    ),
        .lt24_display_rd_n  ( lt24_display_rd_n  ),
        .lt24_display_wr_n  ( lt24_display_wr_n  ),
        .lt24_display_data  ( lt24_display_data  ),
        .lt24_display_on    ( lt24_display_on    ),
        .lt24_display_rst_n ( lt24_display_rst_n ),
        
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

`else
    
    /*
     *
     *  LT24 Display Functionality
     *
     */
     
    //Generate a reset signal at power-on.
    wire globalReset;
    power_on_reset_hw power_on_reset (
        .clock(user_clock_clk),
        .reset(globalReset   )
    );

    //Instantiate LT24 Display controller
    LT24Display #(
        .WIDTH      (240),
        .HEIGHT     (320),
        .CLOCK_FREQ (50000000)
    ) lt24_fpga (
        //Clock/Reset Inputs
        .clock        (user_clock_clk),
        .globalReset  (globalReset   ),
       
        //Application Reset
        .resetApp     (user_reset_reset),
        
        //Pixel Interface
        .pixelReady   (lt24_data_ready),
        .pixelData    (lt24_data_data ),
        .pixelWrite   (lt24_data_write),
        .xAddr        (lt24_data_xAddr),
        .yAddr        (lt24_data_yAddr),
        
        //Optional Command/Data Interface
        .pixelRawMode (lt24_mode_raw ),
        .cmdReady     (lt24_cmd_ready),
        .cmdData      (lt24_cmd_data ),
        .cmdWrite     (lt24_cmd_write),
        .cmdDone      (lt24_cmd_done ),
        
        //LT24 Display Interface - DO NOT RENAME
        .LT24CS_n     (lt24_display_cs_n ),
        .LT24RS       (lt24_display_rs   ),
        .LT24Rd_n     (lt24_display_rd_n ),
        .LT24Wr_n     (lt24_display_wr_n ),
        .LT24Data     (lt24_display_data ),
        .LT24LCDOn    (lt24_display_on   ),
        .LT24Reset_n  (lt24_display_rst_n)
    );

    /*
     *
     *  UART Functionality
     *
     */
     
    assign usb_uart_rx_i = 1'b1; //Nothing received in simulation.

    /*
     *
     *  DDR3 Functionality
     *
     */

    //
    //Reset signals
    //
    altera_reset_synchronizer #(
        .ASYNC_RESET(1),
        .DEPTH      (2)
    ) ddr_read_reset (
        //Async Reset
        .reset_in (user_reset_reset),
        //Sync Reset
        .clk      (ddr_read_clock_clk_i),
        .reset_out(ddr_read_reset_reset)
    );

    altera_reset_synchronizer #(
        .ASYNC_RESET(1),
        .DEPTH      (2)
    ) ddr_write_reset (
        //Async Reset
        .reset_in (user_reset_reset),
        //Sync Reset
        .clk      (ddr_write_clock_clk_i),
        .reset_out(ddr_write_reset_reset)
    );

    //
    //Create a 64MB Memory
    //
    reg [31:0] DDR [0:(2**24)-1];

    //
    // Wait Requests - Generate some cycles where waitreq is high.
    //
    reg [1:0] waitreq_cntr_write;
    reg ddr_write_waitrequest_i_reg;
    assign ddr_write_waitrequest_i = ddr_write_waitrequest_i_reg;
    always @ (posedge ddr_write_clock_clk_i or posedge ddr_write_reset_reset) begin
        if (ddr_write_reset_reset) begin
            waitreq_cntr_write          <= 2'b0;
            ddr_write_waitrequest_i_reg <= 1'b1;
        end else begin
            waitreq_cntr_write          <= waitreq_cntr_write + 2'b1;
            ddr_write_waitrequest_i_reg <= (waitreq_cntr_write == $unsigned($random)%4);
        end
    end 
    reg [1:0] waitreq_cntr_read; 
    reg ddr_read_waitrequest_i_reg;
    assign ddr_read_waitrequest_i = ddr_read_waitrequest_i_reg;
    always @ (posedge ddr_read_clock_clk_i or posedge ddr_read_reset_reset) begin
        if (ddr_read_reset_reset) begin
            waitreq_cntr_read          <= 2'b0;
            ddr_read_waitrequest_i_reg <= 1'b1;
        end else begin
            waitreq_cntr_read          <= waitreq_cntr_read + 2'b1;
            ddr_read_waitrequest_i_reg <= (waitreq_cntr_read == $unsigned($random)%4);
        end
    end


    //
    //Write port
    //
    always @ (posedge ddr_write_clock_clk_i or posedge ddr_write_reset_reset) begin
        if (ddr_write_reset_reset) begin
            //Do nothing in reset...
        end else if (ddr_write_write_i && !ddr_write_waitrequest_i) begin //If a write and not waiting
            //Write only enabled bytes to DDR[write_address]
            if (ddr_write_byteenable_i[0]) DDR[ddr_write_address_i[23:0]][ 7: 0] <= ddr_write_writedata_i[ 7: 0];
            if (ddr_write_byteenable_i[1]) DDR[ddr_write_address_i[23:0]][15: 8] <= ddr_write_writedata_i[15: 8];
            if (ddr_write_byteenable_i[2]) DDR[ddr_write_address_i[23:0]][23:16] <= ddr_write_writedata_i[23:16];
            if (ddr_write_byteenable_i[3]) DDR[ddr_write_address_i[23:0]][31:24] <= ddr_write_writedata_i[31:24];
        end
    end

    //
    //Read port
    //
    reg [5:0] ddr_read_read_dly;
    always @ (posedge ddr_read_clock_clk_i or posedge ddr_read_reset_reset) begin
        if (ddr_read_reset_reset) begin
            ddr_read_read_dly <= 6'b0;
        end else begin
            ddr_read_read_dly <= {ddr_read_read_dly[4:0], (ddr_read_read_i && !ddr_read_waitrequest_i)}; //Fake some latency. In practice this wont be a fixed amount.
        end
    end

    reg [31:0] ddr_read_readdata_reg;
    reg        ddr_read_readdatavalid_reg;
    always @ (posedge ddr_read_clock_clk_i or posedge ddr_read_reset_reset) begin
        if (ddr_read_reset_reset) begin          //If in reset
            ddr_read_readdata_reg      <= 'bx;                         //Mark read data as unknown for sim purposes
            ddr_read_readdatavalid_reg <= 1'b0;                        //And no valid data
        end else if (ddr_read_read_dly[5]) begin //If a read
            ddr_read_readdata_reg      <= DDR[ddr_read_address_i[23:0]]; //Read from DDR[read_address]
            ddr_read_readdatavalid_reg <= 1'b1;                        //And mark as valid data
        end else begin                           //Else no read
            ddr_read_readdata_reg      <= 'bx;                         //Mark read data as unknown for sim purposes
            ddr_read_readdatavalid_reg <= 1'b0;                        //And no valid data
        end
    end
    assign ddr_read_readdata_i = ddr_read_readdata_reg;
    assign ddr_read_readdatavalid_i = ddr_read_readdatavalid_reg;


    /*
     *
     *  SD Card Dump Functionality
     *
     */

    reg ack;
    reg [3:0] hscnt; //Fake a delay for handshake.

    localparam IDLE_STATE = 2'b00;
    localparam REQ_STATE  = 2'b01;
    localparam ACK_STATE  = 2'b10;
    reg [1:0] stateMachine;

    integer dumpSize, idx;
    integer file;

    always @ (posedge user_clock_clk or posedge user_reset_reset) begin
        if (user_reset_reset) begin
            ack                      = 1'b0;
            hscnt                    = 4'b0;
            dumpSize                 = 0;
            stateMachine             = IDLE_STATE;
        end else begin
            case (stateMachine)
                IDLE_STATE: begin
                    ack              = 1'b0;                    //No acknowledge.
                    hscnt            = 4'b0;                    //Keep mini counter reset.
                    if (handshake_in_port_i[16]) begin
                        //If request is asserted
                        stateMachine = REQ_STATE;               //Jump to requested state.
                        dumpSize     = (handshake_in_port_i[15:0] == 16'b0) ? {8'b0, handshake_in_port_i[15:0],8'b0} : (2**22); //64MB in 4-byte words.
                        file         = $fopen("DDR.bin","wb");   //Open file to dump
                        $display("DDR.bin File Opened. Saving...");        //Quick info to user
                    end
                end
                REQ_STATE: begin
                    hscnt            = hscnt + 4'b1;            //Increment mini counter
                    if (hscnt == 4'hF) begin
                        //After delay
                        for (idx = 0; idx < dumpSize; idx = idx + 1) begin
                            $fwrite(file,"%u",DDR[idx]);
                        end
                        $display("DDR3 Dumped to DDR.bin");     //Info to user
                        ack          = 1'b1;                    //Assert acknowledge.
                        stateMachine = ACK_STATE;               //Jump to acknowledged state.
                    end
                end
                ACK_STATE: begin
                    if (!handshake_in_port_i[16]) begin
                        //Once request goes low
                        ack          = 1'b0;                    //Ack is high until request goes low.
                        $fclose(file);  
                        $display("DDR.bin File Closed");        //Info to user
                        stateMachine = IDLE_STATE;              //We are done. Return to IDLE.
                    end
                end
            endcase
        end
    end

    assign handshake_out_port_i[15: 0] = 16'b0; //For model assume always success.
    assign handshake_out_port_i[   16] = ack;   //Acknowledge goes to handshake out.
    
`endif //MODEL_TECH

endmodule
