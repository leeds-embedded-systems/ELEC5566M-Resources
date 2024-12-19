/*
 * Avalon-MM Adapter Module
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds & Georgia Institute of Technology
 * Date: 28th April 2015 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This module is designed to act as an adapter to allow a slave-master pair to be connected even if the slave and master have different
 * signal requirements and data widths. The module will allow a narrow master to interface with a larger master, but also slaves and
 * masters of the same width. It does not however fully support a wide master reading from a narrow slave. The module supports connecting
 * a master that is read-only or write-only to a slave that can do both - e.g. a Read-Only DMA controller to an on-chip RAM. In the case
 * that the slave device is narrower than the master device (i.e. this modules master port is narrower than its slave port), the data that
 * is being written will be simply truncated, with only the lower bits being kept, and MSBs of reads will be padded with zeros.
 *
 * It is also possible to use this module to interface a burst capable master with a non burst capable slave in which the read address
 * of the master points to the start of the burst. All of the address incrementing is performed internally and the master is not required
 * to hold its address signal constant during the read. The bursting option only supports burst reads and cannot be enabled on an interface
 * which is no write only. Additionally the slave device must not have a wait request signal but the burst master must. Bursting is optional
 * and can be disabled using the SLAVE_BURST_MAX parameter.
 *
 * Masters that use symbol addressing instead of word addressing are also supported, however it is assumed that the addresses must be word
 * aligned meaning the lower bits are always zero. It could be possible in future to allow non-aligned addresses by internally calculating
 * the symbol aligned byte enable signals. If symbol addressing is to be used, the SLAVE_MEM_SYM_ADDRESS_WIDTH width parameter should be
 * set to the address width of the master, while the SLAVE_MEM_ADDRESS_WIDTH should be set to the word address width. If word addressing
 * is used, both parameters should be set to the same value - the word address width.
 *
 * The module when operating in a mode which can perform read operations (in BRIDGE_IS_WRITEONLY = 0), is only capable of supporting a
 * slave device which has a read latency of 1. There is no pipe-lining in the module meaning it presents also with a read latency of one
 * allowing it to be transparently inserted between the master an slave. Because of this, if there is a large difference in width between
 * the master and slave, then the maximum frequency may suffer.
 *
 *
 * Writing to Wider Master
 * -----------------------
 * 
 * There are times when it is desireable for the master to have a wider width than the slave. To accomplish this, the byte-enable signal
 * on the master is by default used to select which part to write to, with the lower bits of the slave address being used to select which
 * slave-width word in the master to write to. This works fine if byte-enables are supported.
 *
 * However in situations where it is necessary to limit the number of write transations (e.g. to external memory), or where the master
 * interface requires the byte-enable to be disabled, then things get more complicated. For WRITE-ONLY bridges, an extra mode is included
 * which uses data bursts to populate multiple words in the wider master interface with the burst data. This is then written to the master
 * either at the end of the burst (if the whole burst fits into one transaction), or as each master word becomes full.
 *
 * When using the special master burst fill mode, a single burst into the slave interface cannot produce more than a single burst on the
 * master interface. For example if the master has no burst capabilities, the slave burst/offset must fit into a single master word. If
 * the master has a burst capability, the slave burst cannot populate more than the master burst count words.
 *
 */

module avmm_width_adapter_hw #(  
    //Slave port width settings
    parameter SLAVE_MEM_SYMBOL_WIDTH      = 32,                          // The width of the Slave data bus.
    parameter SLAVE_MEM_ADDRESS_WIDTH     = 5,                           // If wider than MASTER_MEM_SYMBOL_WIDTH data will be padded on read and truncated on write
    parameter SLAVE_MEM_SYM_ADDRESS_WIDTH = SLAVE_MEM_ADDRESS_WIDTH,     // Slave address width in 'Symbols'. If the master uses symbols as address units not words, this can be used. Else its the same as below.
    parameter SLAVE_BYTE_EN_WIDTH         = (SLAVE_MEM_SYMBOL_WIDTH/8),  // Must be: (SLAVE_MEM_SYMBOL_WIDTH/BITS_IN_BYTE)

    //Master port width settings                                         
    parameter MASTER_MEM_SYMBOL_WIDTH     = 128,                         // The width of the Master data bus. Must be (SLAVE_MEM_SYMBOL_WIDTH * 2^n), where n is some non-negative integer (including zero)
    parameter MASTER_MEM_ADDRESS_WIDTH    = 3,                           // Width of the Master address signal in 'Words' - Must be >=0 (if 0, then the master address signal is unused)
    parameter MASTER_BYTE_EN_WIDTH        = (MASTER_MEM_SYMBOL_WIDTH/8), // Must be: (MASTER_MEM_SYMBOL_WIDTH/BITS_IN_BYTE)

    //By default the packing factor is a power of two symbols based on the difference in address width.
    //It is possible to change this to a non-power-of-two, but beware timing constraints imposed by doing both division and modulo by this factor.
    //When using wider master, then ensure: MASTER_MEM_SYMBOL_WIDTH = SLAVE_MEM_SYMBOL_WIDTH * PACKING_FACTOR, and ADDR_WIDTH_DIFF = clog2(PACKING_FACTOR)
    //Non-power-of-two can NOT be used in MASTER_BURST_PACKING mode.
    parameter PACKING_FACTOR              = (MASTER_MEM_SYMBOL_WIDTH >= SLAVE_MEM_SYMBOL_WIDTH) ? (MASTER_MEM_SYMBOL_WIDTH / SLAVE_MEM_SYMBOL_WIDTH) : 1,
    parameter ADDR_WIDTH_DIFF             = (SLAVE_MEM_ADDRESS_WIDTH > MASTER_MEM_ADDRESS_WIDTH) ? (SLAVE_MEM_ADDRESS_WIDTH - MASTER_MEM_ADDRESS_WIDTH) : 0,

    //Width adapter global options                                       
    parameter BRIDGE_IS_READONLY          = 0,                           // Set to 1 if the bridge is Read-Only, i.e. there should be no write signals.
    parameter BRIDGE_IS_WRITEONLY         = 0,                           // Set to 1 if the bridge is Write-Only, i.e. there should be no read signals.
    parameter USE_MASTER_BURST_PACKING    = 0,                           // Set to 1 to enable the special master burst packing mode. See description above
    parameter PIPELINE_MASTER_WRITE       = 0,                           // Set to 1 to add an extra clock cycle of latency in the form of pipelining of requests
    parameter PIPELINE_MASTER_READ        = 0,                           // Set to 1 to add an extra clock cycle of latency in the form of pipelining of responses
    
    //These next parameters are used to configure which optional signals the read and write interfaces have so that they can be connected to other masters an slaves which have specific signals without the need
    //of any additional Avalon-MM fabric logic. The signal conversion is done internally here.
    
    //Slave interface signal options
    parameter SLAVE_HAS_BYTE_EN           = 1,                           // Set to 1 if the slave requires a byte enable
    parameter SLAVE_HAVE_WAITREQ          = 0,                           // Set to 1 if the slave requires a wait request signal (asserts high)
    parameter SLAVE_HAVE_READ             = 0,                           // Set to 1 if the slave requires a read signal - some masters have no read signal and expect the slave to perform reads when 'write' is low.
    parameter SLAVE_HAVE_CHIPSEL          = 0,                           // Set to 1 if the slave requires a chip select signal
    parameter SLAVE_HAVE_CLOCKEN          = 1,                           // Set to 1 if the slave requires a clock enable signal
    parameter SLAVE_READ_INVERTED         = 0,                           // Set to 1 if the read signal is inverted - i.e. a read_n signal.
    parameter SLAVE_BURST_MAX             = 0,                           // Only used if BRIDGE_IS_READONLY == 1. Setting this to >0 will enable bursting capabilities for slave port. Else set to 0 to disable.
    parameter SLAVE_BURST_WIDTH           = 1,                           // If the above is >0, this sets the width of the burst count signal.
    
    //Master interface signal options
    parameter MASTER_HAVE_WAITREQ         = 0,                           // Set to 1 if the master should have a wait request signal (asserts high)
    parameter MASTER_HAVE_READ            = 0,                           // Set to 1 if the master should have a write signal
    parameter MASTER_HAVE_CHIPSEL         = 1,                           // Set to 1 if the master should have a chip select signal
    parameter MASTER_HAVE_CLOCKEN         = 1,                           // Set to 1 if the master should have a clock enable signal
    parameter MASTER_BURST_MAX            = 0,                           // Setting this to >0 only allowed in special master burst packing mode. Else set to 0 to disable.
    parameter MASTER_BURST_WIDTH          = 1,                           // If the above is >0, this sets the width of the burst count signal. This must be max(1,SLAVE_BURST_WIDTH - (SLAVE_MEM_ADDRESS_WIDTH - MASTER_MEM_ADDRESS_WIDTH))
    
    //This should not be changed, it is used to allow there to be no master address port without causing an error.
    parameter MASTER_ADDR_WIDTH           = ((MASTER_MEM_ADDRESS_WIDTH == 0) ? 1 : MASTER_MEM_ADDRESS_WIDTH) //If there is no master address (width==0), then make the port 1 to avoid error.
    
)
(
    input                                    clock,
    input                                    reset,            // Active high reset, used only for burst logic and read address multiplexing.
    
    //Slave Avalon-MM Port
    input  [SLAVE_MEM_SYM_ADDRESS_WIDTH-1:0] slave_address,    // REQUIRED! Lower bits used to select which 'Slave Word' in the 'Master Word' that we want.
    input  [        SLAVE_BYTE_EN_WIDTH-1:0] slave_byte_en,    // Used only if SLAVE_HAS_BYTE_EN is 1
    input                                    slave_chip_sel,   // Used only if SLAVE_HAVE_CHIPSEL is 1
    input                                    slave_clock_en,   // Used only if SLAVE_HAVE_CLOCKEN is 1
    output                                   slave_waitreq,    // Used only if SLAVE_HAVE_WAITREQ is 1
    input                                    slave_write,      // \__ These two are only used if BRIDGE_IS_READONLY
    input  [     SLAVE_MEM_SYMBOL_WIDTH-1:0] slave_writedata,  // /   is set to zero, otherwise leave unconnected
    input                                    slave_read,       // \__ These two are only used if BRIDGE_IS_WRITEONLY
    output [     SLAVE_MEM_SYMBOL_WIDTH-1:0] slave_readdata,   // /   is set to zero, otherwise leave unconnected
    input  [          SLAVE_BURST_WIDTH-1:0] slave_burstcount, // \__ These two are only used if bursting on the read
    output                                   slave_valid,      // /   interface is enabled by setting SLAVE_BURST_MAX > 0
    
    //Master Avalon-MM Port
    output [          MASTER_ADDR_WIDTH-1:0] master_address,   // Only used if MASTER_MEM_ADDRESS_WIDTH > 0
    output [       MASTER_BYTE_EN_WIDTH-1:0] master_byte_en,   // REQUIRED! This is used to select which 'Slave Word' to write or read from in the 'Master Word'.
    output                                   master_chip_sel,  // Used only if MASTER_HAVE_CHIPSEL is 1
    output                                   master_clock_en,  // Used only if MASTER_HAVE_CLOCKEN is 1
    input                                    master_waitreq,   // Used only if MASTER_HAVE_WAITREQ is 1
    output                                   master_write,     // \__ These two are only used if BRIDGE_IS_READONLY
    output [    MASTER_MEM_SYMBOL_WIDTH-1:0] master_writedata, // /   is set to zero, otherwise leave unconnected
    output                                   master_read,      // \__ These two are only used if BRIDGE_IS_WRITEONLY
    input  [    MASTER_MEM_SYMBOL_WIDTH-1:0] master_readdata,  // /   is set to zero, otherwise leave unconnected
    output [         MASTER_BURST_WIDTH-1:0] master_burstcount // Used in special master burst packing mode only
);

//Pin width difference to 1 to ensure signal widths cope.
localparam ADDR_WIDTH_DIFF_I = (ADDR_WIDTH_DIFF == 0) ? 1 : ADDR_WIDTH_DIFF;

//If the slave interface is addressed in Symbols rather than Words, we drop the lower address bits to round it to the nearest word.
wire [(SLAVE_MEM_ADDRESS_WIDTH-1):0] slave_address_word;
generate if (SLAVE_MEM_SYM_ADDRESS_WIDTH > SLAVE_MEM_ADDRESS_WIDTH) begin
    assign slave_address_word = slave_address[SLAVE_MEM_SYM_ADDRESS_WIDTH-1:(SLAVE_MEM_SYM_ADDRESS_WIDTH-SLAVE_MEM_ADDRESS_WIDTH)];
end else begin
    assign slave_address_word = slave_address;
end endgenerate

//Internal signals
reg slave_bursting;
reg [SLAVE_MEM_ADDRESS_WIDTH-1:0] internal_address;
reg [    SLAVE_BYTE_EN_WIDTH-1:0] internal_byte_en;    //create an internal byte enable signal which will be demultiplexed out to the masters byte enables.
reg [   MASTER_BYTE_EN_WIDTH-1:0] internal_mbyte_en;   //Override for master byte enable in some modes
reg [MASTER_MEM_SYMBOL_WIDTH-1:0] internal_mwritedata; //write data possibly buffered to align with control signals if required.

// Generated internal signals based on whether the slave has the source signal or not
wire internal_read;
wire internal_chip_sel;
wire internal_clock_en;
wire internal_waitreq;

function [MASTER_BYTE_EN_WIDTH-1:0] byteEnPack(
    input [  ADDR_WIDTH_DIFF_I-1:0] lowAddr,
    input [SLAVE_BYTE_EN_WIDTH-1:0] slvByteEn
);
integer wordCnt;
begin
    byteEnPack = {(MASTER_BYTE_EN_WIDTH){1'b0}};
    for (wordCnt = 0; wordCnt < PACKING_FACTOR; wordCnt=wordCnt+1) begin
        byteEnPack[(wordCnt*SLAVE_BYTE_EN_WIDTH)+:SLAVE_BYTE_EN_WIDTH] = (lowAddr == wordCnt[ADDR_WIDTH_DIFF_I-1:0]) ? slvByteEn : {(SLAVE_BYTE_EN_WIDTH){1'b0}}; 
    end
end endfunction

genvar i;
generate
    
if (!SLAVE_HAVE_READ || BRIDGE_IS_WRITEONLY) begin
    //If the slave has no read signal or this is a write only bridge, then we are always reading if not write only.
    assign internal_read = !BRIDGE_IS_WRITEONLY;
end else if (SLAVE_READ_INVERTED) begin
    //If the read signal on the slave interface is inverted, i.e. active low, then we add an inverter to correct it for our internal logic
    assign internal_read = !slave_read;
end else begin
    assign internal_read = slave_read;
end
if (SLAVE_HAVE_CLOCKEN) begin                   
    assign internal_clock_en = slave_clock_en;  //Slave controls if clock is enabled
end else begin
    assign internal_clock_en = 1'b1;            //Else internally we are always enabled.
end
if (SLAVE_HAVE_CHIPSEL) begin
    assign internal_chip_sel = slave_chip_sel;  //Slave controls if chip select is high
end else begin
    assign internal_chip_sel = 1'b1;            //Internally we are always selected.
end
if (MASTER_HAVE_WAITREQ) begin
    assign internal_waitreq = master_waitreq;  //Master controls if we wait
end else begin
    assign internal_waitreq = 1'b0;            //Else master never requires us to wait
end

//Enable pipeline stages (if used) when we are not being asked to wait, or when we are in a burst.
//Also enable when the pipeline doesn't contain a pending read or write to allow prefetching (some
//slaves won't deassert the wait request until a request is made).
wire pipe_enable;
assign pipe_enable = slave_bursting || !internal_waitreq || (PIPELINE_MASTER_WRITE && !(master_write || master_read));
    
//Whether using master burst logic
localparam BURST_PACKING_MASTER = (BRIDGE_IS_WRITEONLY && USE_MASTER_BURST_PACKING);

//Next we select whether bursting is enabled, and based on that connect up the master and slave control signals depending
//on which are enabled.
localparam BURST_MODE_ENABLED = (SLAVE_BURST_MAX > 0) && (SLAVE_HAVE_WAITREQ) && (BRIDGE_IS_READONLY) && (!MASTER_HAVE_WAITREQ);

if (BURST_PACKING_MASTER) begin
    
    //If using special master burst write packing mode
    
    ////// This mode is untested and will need a revisit in the logic.
    
    //Burst begins on a write when we are not in the middle of a burst
    wire burst_begin;
    assign burst_begin = (internal_clock_en && internal_chip_sel && slave_write && !internal_waitreq && !slave_bursting);
    
    //Work out the master burst count based on the ceiling division by the difference in address width
    //The number of slave words is the slave burst count, plus the starting offset in the master word.
    //We then add the max burst address and truncate to ensure the truncation is a ceiling division by 2.
    localparam MAX_BURST_ADDR = PACKING_FACTOR - 1;
    wire [SLAVE_BURST_WIDTH-1:0] slave_burst_words_in_master;
    assign slave_burst_words_in_master = ((slave_address_word % PACKING_FACTOR[ADDR_WIDTH_DIFF_I:0]) + slave_burstcount + MAX_BURST_ADDR[SLAVE_BURST_WIDTH-1:0]);
    
    reg [MASTER_BURST_WIDTH-1:0] internal_burstcount;
    avmm_width_adapter_pipe #(
        .WIDTH(MASTER_BURST_WIDTH),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) burstCount (
        .clock(clock),
        .reset(reset),
        
        .in(internal_burstcount),
        .en(pipe_enable),
        .out(master_burstcount)
    );
    
    wire [MASTER_MEM_SYMBOL_WIDTH-1:0] duplicated_writedata;
    assign duplicated_writedata = {(PACKING_FACTOR){slave_writedata}};
    
    wire [MASTER_BYTE_EN_WIDTH-1:0] initial_byteen;
    assign initial_byteen = byteEnPack(slave_address_word[ADDR_WIDTH_DIFF_I-1:0], SLAVE_HAS_BYTE_EN ? slave_byte_en : {(SLAVE_BYTE_EN_WIDTH){1'b1}});

    wire [MASTER_BYTE_EN_WIDTH-1:0] remaining_byteen;
    assign remaining_byteen = byteEnPack(internal_address[ADDR_WIDTH_DIFF_I-1:0], internal_byte_en);

    wire clear_mbe;
    assign clear_mbe = (internal_address[ADDR_WIDTH_DIFF_I-1:0] == {(ADDR_WIDTH_DIFF_I){1'b1}});

    //Create the bursting logic. This handles taking burst write requests from the slave and converting them into a packed
    //burst that is sent to the master. Address incrementing is performed here as well.
    reg  [SLAVE_BURST_WIDTH-1:0] slave_burstremaining;
    wire [ADDR_WIDTH_DIFF_I-1:0] wordOffset;
    assign wordOffset = internal_address[ADDR_WIDTH_DIFF_I-1:0];
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            slave_bursting        <= 1'b0;
            internal_address      <= 1'b0;
            internal_byte_en      <= 1'b0;
            internal_mbyte_en     <= 1'b0;
            slave_burstremaining  <= 1'b0;
            internal_burstcount   <= 1'b0;
        end else begin
            if (burst_begin) begin 
                //if this is a read request, and we are not currently bursting, then we are read to accept a burst, so load the address and burst count
                internal_mwritedata[initial_byteen]   <= duplicated_writedata;
                internal_burstcount                   <= slave_burst_words_in_master / PACKING_FACTOR[ADDR_WIDTH_DIFF_I:0];
                internal_address                      <= slave_address_word;                           //load the starting address.
                internal_byte_en                      <= SLAVE_HAS_BYTE_EN ? slave_byte_en : {(SLAVE_BYTE_EN_WIDTH){1'b1}};
                internal_mbyte_en                     <= initial_byteen;
                slave_bursting                        <= (slave_burstcount != 1'b0);                   //only started bursting if non-zero length.
                slave_burstremaining                  <= slave_burstcount;                             //load the total number of words to read.
            end else if (slave_burstremaining > 1'b1) begin
                //If there are still some words outstanding, then request the next
                internal_mwritedata[remaining_byteen] <= duplicated_writedata;
                internal_address                      <= internal_address + 1'b1;                      //read the next word from the next address
                internal_mbyte_en                     <= (clear_mbe ? 1'b0: internal_mbyte_en) | remaining_byteen;
                slave_burstremaining                  <= slave_burstremaining - 1'b1;                  //and there will be one less burst remaining.
                slave_bursting                        <= 1'b1;                                         //we are still bursting.
            end else begin
                slave_burstremaining                  <= 1'b0;                                         //Otherwise there are none remaining
                slave_bursting                        <= 1'b0;                                         //And we have finished bursting.
            end
        end
    end
    
    
    //Never reading in master burst write mode
    assign master_read = 1'b0;
    
    //Enable the master interface only during the burst.
    avmm_width_adapter_pipe #(
        .WIDTH(1),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) masterWrite (
        .clock(clock),
        .reset(reset),
        
        .in(slave_bursting),
        .en(1'b1),
        .out(master_write)
    );
    assign master_clock_en = master_write;
    assign master_chip_sel = master_write;
    
    //We only allow 1 outstanding read request, so while we are bursting, the slave must wait for us to finish, and for master to be ready
    assign slave_waitreq = slave_bursting || internal_waitreq;
    
end else if (!BURST_MODE_ENABLED) begin
    
    // If bursting is disabled, or the bridge is not read only, or the master has a wait request, or the slave doesn't, then we can't burst with the current settings!
    
    always @ * begin
        slave_bursting          <= 1'b0;                                         //Terminate the internal burst signal as we have no burst capability
        internal_address        <= slave_address_word;                           //The internal address is just the slave address as no burst incrementing required
        internal_byte_en        <= SLAVE_HAS_BYTE_EN ? slave_byte_en : {(SLAVE_BYTE_EN_WIDTH){1'b1}};
        if (SLAVE_MEM_SYMBOL_WIDTH > MASTER_MEM_SYMBOL_WIDTH) begin
            internal_mwritedata <= slave_writedata[MASTER_MEM_SYMBOL_WIDTH-1:0]; //Simply truncate write data if master port is narrower.
        end else begin
            internal_mwritedata <= {(PACKING_FACTOR){slave_writedata}};          //Otherwise duplicate the slave write data to all master write data symbols as byteen controls access.
        end
    end
    
    //Now connect up other sideband signals
    assign slave_waitreq = !pipe_enable; //Wait while the pipeline is held.
    
    avmm_width_adapter_pipe #(
        .WIDTH(MASTER_BURST_WIDTH + 3),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) masterCtl (
        .clock(clock),
        .reset(reset),
        
        .in({slave_burstcount,internal_read,internal_chip_sel,internal_clock_en}),
        .en(pipe_enable),
        .out({master_burstcount,master_read,master_chip_sel,master_clock_en})
    );
    
    if (BRIDGE_IS_READONLY) begin
        assign master_write = 1'b0;
    end else begin
        avmm_width_adapter_pipe #(
            .WIDTH(1),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) masterWrite (
            .clock(clock),
            .reset(reset),
            
            .in(slave_write),
            .en(pipe_enable),
            .out(master_write)
        );
    end
    
end else begin

    //Otherwise we have all the required control signals to burst and bursting was requested.
    //Master cannot have a wait request, so this is relatively simple logic to handle.
    wire burst_begin;
    assign burst_begin = (internal_clock_en && internal_chip_sel && internal_read && !slave_bursting);
    
    //This is a readonly mode, so writedata is ignored.
    always @ * begin
        internal_mwritedata <= 1'b0;
    end
    
    //Create the bursting logic. This handles taking burst read requests from the slave and converting them into the individual read requests
    //that are sent to the master. Address incrementing is performed here as well.
    reg [ SLAVE_BURST_WIDTH-1:0] slave_burstremaining;
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            slave_bursting <= 1'b0;
            internal_address <= 1'b0;
            internal_byte_en <= 1'b0;
            slave_burstremaining <= 1'b0;
        end else begin
            if (burst_begin) begin 
                //if this is a read request, and we are not currently bursting, then we are read to accept a burst, so load the address and burst count
                internal_address <= slave_address_word;                     //load the starting address.
                internal_byte_en <= SLAVE_HAS_BYTE_EN ? slave_byte_en : {(SLAVE_BYTE_EN_WIDTH){1'b1}}; //same byte enable for all burst words
                slave_bursting <= (slave_burstcount != 1'b0);               //only started bursting if non-zero length.
                slave_burstremaining <= slave_burstcount;                   //load the total number of words to read.
            end else if (slave_burstremaining > 1'b1) begin
                //If there are still some words outstanding, then request the next
                internal_address <= internal_address + 1'b1;                //read the next word from the next address
                slave_burstremaining <= slave_burstremaining - 1'b1;        //and there will be one less burst remaining.
                slave_bursting <= 1'b1;                                     //we are still bursting.
            end else begin
                slave_burstremaining <= 1'b0;                               //Otherwise there are none remaining
                slave_bursting <= 1'b0;                                     //And we have finished bursting.
            end
        end
    end
    
    //Never writing in read burst mode
    assign master_write = 1'b0;
    
    //Enable the master interface only during the burst.
    avmm_width_adapter_pipe #(
        .WIDTH(1),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) masterRead (
        .clock(clock),
        .reset(reset),
        
        .in(slave_bursting),
        .en(1'b1),
        .out(master_read)
    );
    assign master_clock_en = master_read;
    assign master_chip_sel = master_read;
    
    //We only allow 1 outstanding read request, so while we are bursting, the slave must wait for us to finish!
    assign slave_waitreq = slave_bursting;
        
end 

//Connect the write specific signals
if (!BRIDGE_IS_READONLY) begin
    //If the bridge is not read only, then we have a write interface
    avmm_width_adapter_pipe #(
        .WIDTH(MASTER_MEM_SYMBOL_WIDTH),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) writeData (
        .clock(clock),
        .reset(reset),
        
        .in(internal_mwritedata),
        .en(pipe_enable),
        .out(master_writedata)
    );
end else begin 
    assign master_writedata = 1'b0; //Terminate the write data signal.
end

//Next we generate the selection logic to determine which part of the master interface we need to read from or write too.
if (SLAVE_MEM_ADDRESS_WIDTH > MASTER_MEM_ADDRESS_WIDTH) begin
    //We only need the selection logic if the master has a larger word width than the slave
    
    //Calculate the address and symbol offset for the master interface
    wire [SLAVE_MEM_ADDRESS_WIDTH-1:0] internal_maddress;
    wire [      ADDR_WIDTH_DIFF_I-1:0] internal_moffset;
    parameter PACKING_FACTOR_MASK = PACKING_FACTOR - 1;
    if (!(PACKING_FACTOR & PACKING_FACTOR_MASK)) begin
        // For powers of two, the divide will optimise to simple shift, and modulo can be done as a mask.
        assign internal_maddress = internal_address / PACKING_FACTOR[ADDR_WIDTH_DIFF_I:0];
        assign internal_moffset = internal_address[ADDR_WIDTH_DIFF_I-1:0] & PACKING_FACTOR_MASK[ADDR_WIDTH_DIFF_I-1:0];
    end else begin
        lpm_divide #(
            .lpm_drepresentation("UNSIGNED"                                   ),
            .lpm_hint           ("MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=TRUE"),
            .lpm_nrepresentation("UNSIGNED"                                   ),
            .lpm_pipeline       (0                                            ),
            .lpm_type           ("LPM_DIVIDE"                                 ),
            .lpm_widthd         (ADDR_WIDTH_DIFF_I                            ),
            .lpm_widthn         (SLAVE_MEM_ADDRESS_WIDTH                      )
        ) addrDivMod (
            .clock (clock),
            .aclr  (reset),
            .clken (1'b1),
            // Div/Mod internal address by the constant packing factor
            .numer (internal_address),
            .denom (PACKING_FACTOR[ADDR_WIDTH_DIFF_I-1:0]),
            // Quotient is address, remainder is symbol offset.
            .quotient (internal_maddress),
            .remain (internal_moffset)
        );
    end
    
    //Pass the divided address straight through to the master but only if we have a master address signal.
    if (MASTER_MEM_ADDRESS_WIDTH != 0) begin
        avmm_width_adapter_pipe #(
            .WIDTH(MASTER_ADDR_WIDTH),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) address (
            .clock(clock),
            .reset(reset),
            
            .in(internal_maddress[MASTER_ADDR_WIDTH-1:0]),
            .en(pipe_enable),
            .out(master_address)
        );
    end
    
    //For each slave word in the master data bus, we only enable it if that word is selected by the address
    //This logic ensures that only one slave word in the master is ever selected.
    avmm_width_adapter_pipe #(
        .WIDTH(MASTER_BYTE_EN_WIDTH),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) byteen (
        .clock(clock),
        .reset(reset),
        
        .in((BURST_PACKING_MASTER ? internal_mbyte_en : byteEnPack(internal_moffset[ADDR_WIDTH_DIFF_I-1:0], internal_byte_en))),
        .en(pipe_enable),
        .out(master_byte_en)
    );

    //Connect the read specific signals
    if (!BRIDGE_IS_WRITEONLY) begin
        
        //in burst mode, slave_bursting controls reading of data, else use other signals.
        wire internal_readdatavalid;
        avmm_width_adapter_pipe #(
            .WIDTH(1),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) readValid (
            .clock(clock),
            .reset(reset),
            
            .in((BURST_MODE_ENABLED ? slave_bursting : (internal_chip_sel && internal_clock_en && internal_read && !internal_waitreq))),
            .en(1'b1),
            .out(internal_readdatavalid)
        );
        
        //We also need to delay the lower bits of the address as well so we can use them as the select signal for the read data multiplexer.
        wire [ADDR_WIDTH_DIFF_I-1:0] internal_readdataselect;
        avmm_width_adapter_pipe #(
            .WIDTH(ADDR_WIDTH_DIFF_I),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) addrRem (
            .clock(clock),
            .reset(reset),
            
            .in(internal_moffset[ADDR_WIDTH_DIFF_I-1:0]),
            .en(pipe_enable),
            .out(internal_readdataselect)
        );
    
        //As the slave read data and master read data are different widths, we need to add a multiplexer to select which part of the master data
        //bus we send through to the slave. So add a multiplexer.
        avmm_width_adapter_mux #(
            .MUX_SELECT_WIDTH(ADDR_WIDTH_DIFF_I), //Multiplexer is larger enough to bring all of the symbols in the master down to the slave.
            .SYMBOL_WIDTH(SLAVE_MEM_SYMBOL_WIDTH),
            .MUX_INPUTS(PACKING_FACTOR),
            .READDATA_LATENCY(1),
            .PIPELINE(PIPELINE_MASTER_READ)
        ) readData (
            .clock(clock),
            .reset(reset),
            .in(master_readdata), //Master data goes in
            .validIn(internal_readdatavalid),
            .select(internal_readdataselect),
            .out(slave_readdata), //Multiplexed data comes out to the slave
            .validOut(slave_valid)
        );
    end

end else begin
    
    //Otherwise, generate some simple pass through logic if the addresses are equal

    //Pass the address straight through if we have a master address signal
    if (MASTER_MEM_ADDRESS_WIDTH != 0) begin
        avmm_width_adapter_pipe #(
            .WIDTH(MASTER_ADDR_WIDTH),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) address (
            .clock(clock),
            .reset(reset),
            
            .in(internal_address),
            .en(pipe_enable),
            .out(master_address)
        );
    end
    
    //And connect a truncated version of the slave byte enable
    avmm_width_adapter_pipe #(
        .WIDTH(MASTER_BYTE_EN_WIDTH),
        .BYPASS(!PIPELINE_MASTER_WRITE)
    ) byteen (
        .clock(clock),
        .reset(reset),
        
        .in(internal_byte_en[MASTER_BYTE_EN_WIDTH-1:0]),
        .en(pipe_enable),
        .out(master_byte_en)
    );
    
    //Connect the read specific signals
    if (!BRIDGE_IS_WRITEONLY) begin
        
        //in burst mode, slave_bursting controls reading of data, else use other signals.
        wire internal_readdatavalid;
        avmm_width_adapter_pipe #(
            .WIDTH(1),
            .BYPASS(!PIPELINE_MASTER_WRITE)
        ) readValid (
            .clock(clock),
            .reset(reset),
            
            .in((BURST_MODE_ENABLED ? slave_bursting : (internal_chip_sel && internal_clock_en && internal_read && !internal_waitreq))),
            .en(1'b1),
            .out(internal_readdatavalid)
        );
        
        localparam PADDING_WIDTH = SLAVE_MEM_SYMBOL_WIDTH - MASTER_MEM_SYMBOL_WIDTH;
        wire [MASTER_MEM_SYMBOL_WIDTH-1:0] internal_mreaddata;
        avmm_width_adapter_mux #(
            .MUX_SELECT_WIDTH(1),
            .SYMBOL_WIDTH(MASTER_MEM_SYMBOL_WIDTH),
            .MUX_INPUTS(1),
            .READDATA_LATENCY(1),
            .PIPELINE(PIPELINE_MASTER_READ)
        ) readData (
            .clock(clock),
            .reset(reset),
            .in(master_readdata),
            .validIn(internal_readdatavalid),
            .select(1'b0),
            .out(internal_mreaddata),
            .validOut(slave_valid)
        );
        assign slave_readdata = {{(PADDING_WIDTH){1'b0}},internal_mreaddata}; //Pad the master readdata bus to the slave readdata width.
    end
    
end 

endgenerate



endmodule

/*
 * Width Adapter Helper - Multiplexer
 *
 * This module is simply a multiplexer for a data bus. Nothing particularly special.
 */
module avmm_width_adapter_mux #(
    parameter MUX_SELECT_WIDTH = 2,
    parameter SYMBOL_WIDTH = 32,
    parameter MUX_INPUTS = (1<<MUX_SELECT_WIDTH),
    parameter READDATA_LATENCY = 1,
    parameter PIPELINE = 0
)(
    input                                      clock,
    input                                      reset,
    input      [(MUX_INPUTS*SYMBOL_WIDTH)-1:0] in,
    input                                      validIn,
    input      [         MUX_SELECT_WIDTH-1:0] select,
    output reg [             SYMBOL_WIDTH-1:0] out,
    output reg                                 validOut
);

genvar i;
generate 

// Account for any latency in the read data
reg [MUX_SELECT_WIDTH-1:0] selectDly [READDATA_LATENCY:0];
reg                        validDly  [READDATA_LATENCY:0];
always @ * begin
    selectDly[0] <= select;
    validDly[0] <= validIn;
end
for (i = 0; i < READDATA_LATENCY; i = i + 1) begin : dly_loop
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            selectDly[i+1] <= 1'b0;
            validDly[i+1]  <= 1'b0;
        end else begin
            if ((i > 0) || validDly[i]) begin
                selectDly[i+1] <= selectDly[i];
            end
            validDly[i+1]  <= validDly[i];
        end
    end
end

wire [SYMBOL_WIDTH-1:0] mux [MUX_INPUTS-1:0];
for (i = 0; i < MUX_INPUTS; i=i+1) begin : mux_loop
    localparam j = i * SYMBOL_WIDTH;
    assign mux[i] = in[j+:SYMBOL_WIDTH]; //Connect all the symbols on the wider input. Each symbol goes to a different multiplexer input
end

if (PIPELINE) begin
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            out      <= 1'b0;
            validOut <= 1'b0;
        end else begin
            out      <= mux[selectDly[READDATA_LATENCY]]; //Select which one we want!
            validOut <= validDly[READDATA_LATENCY];
        end
    end
end else begin
    always @ * begin
        out      <= mux[selectDly[READDATA_LATENCY]]; //Select which one we want!
        validOut <= validDly[READDATA_LATENCY];
    end
end

endgenerate

endmodule

module avmm_width_adapter_pipe #(
    parameter WIDTH = 1,
    parameter BYPASS = 0,
    parameter RST_HIGH = 0
)(
    input clock,
    input reset,
    
    input      [WIDTH-1:0] in,
    input                  en,
    output reg [WIDTH-1:0] out
);

generate if (BYPASS) begin
    always @ * begin
        out <= in[WIDTH-1:0];
    end
end else begin
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            out <= {(WIDTH){RST_HIGH[0]}};
        end else if (en) begin
            //Don't send until the master stops asking us to wait
            out <= in[WIDTH-1:0];
        end
    end
end endgenerate

endmodule
