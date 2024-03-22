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
 */

module avmm_width_adapter_hw #(  
    //Slave port width settings
    parameter SLAVE_MEM_SYMBOL_WIDTH      = 32,                          // The width of the Slave data bus.
    parameter SLAVE_MEM_SYM_ADDRESS_WIDTH = 5,                           // Slave address width in 'Symbols'. If the master uses symbols as address units not words, this can be used. Else its the same as below.
    parameter SLAVE_MEM_ADDRESS_WIDTH     = 5,                           // If wider than MASTER_MEM_SYMBOL_WIDTH data will be padded on read and truncated on write
    parameter SLAVE_BYTE_EN_WIDTH         = (SLAVE_MEM_SYMBOL_WIDTH/8),  // Must be: (SLAVE_MEM_SYMBOL_WIDTH/BITS_IN_BYTE)

    //Master port width settings                                         
    parameter MASTER_MEM_SYMBOL_WIDTH     = 128,                         // The width of the Master data bus. Must be (SLAVE_MEM_SYMBOL_WIDTH * 2^n), where n is some non-negative integer (including zero)
    parameter MASTER_MEM_ADDRESS_WIDTH    = 3,                           // Width of the Master address signal in 'Words' - Must be >=0 (if 0, then the master address signal is unused)
    parameter MASTER_BYTE_EN_WIDTH        = (MASTER_MEM_SYMBOL_WIDTH/8), // Must be: (MASTER_MEM_SYMBOL_WIDTH/BITS_IN_BYTE)

    //Width adapter global options                                       
    parameter BRIDGE_IS_READONLY          = 0,                           // Set to 1 if the bridge is Read-Only, i.e. there should be no write signals.
    parameter BRIDGE_IS_WRITEONLY         = 0,                           // Set to 1 if the bridge is Write-Only, i.e. there should be no read signals.
    
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
    input  [    MASTER_MEM_SYMBOL_WIDTH-1:0] master_readdata   // /   is set to zero, otherwise leave unconnected
);

//If the read signal on the slave interface is inverted, i.e. active low, then we add an inverter to correct it for our internal logic
wire internal_read;
generate if (SLAVE_READ_INVERTED) begin
    assign internal_read = !slave_read;
end else begin
    assign internal_read = slave_read;
end endgenerate

//If the slave interface is addressed in Symbols rather than Words, we drop the lower address bits to round it to the nearest word.
wire [(SLAVE_MEM_ADDRESS_WIDTH-1):0] slave_address_word;
generate if (SLAVE_MEM_SYM_ADDRESS_WIDTH > SLAVE_MEM_ADDRESS_WIDTH) begin
    assign slave_address_word = slave_address[SLAVE_MEM_SYM_ADDRESS_WIDTH-1:(SLAVE_MEM_SYM_ADDRESS_WIDTH-SLAVE_MEM_ADDRESS_WIDTH)];
end else begin
    assign slave_address_word = slave_address;
end endgenerate

//Internal signals
reg slave_bursting;
reg [(SLAVE_MEM_ADDRESS_WIDTH-1):0] internal_address;
reg dataValid;

//Next we select whether bursting is enabled, and based on that connect up the master and slave control signals depending
//on which are enabled.
localparam BURST_MODE_ENABLED = !((SLAVE_BURST_MAX == 0) || (!BRIDGE_IS_READONLY) || (MASTER_HAVE_WAITREQ) || (!SLAVE_HAVE_WAITREQ));

generate if (!BURST_MODE_ENABLED) begin
    
    // If bursting is disabled, or the bridge is not read only, or the master has a wait request, or the slave doesn't, then we can't burst with the current settings!
        
    always @ * begin
        slave_bursting <= 1'b0;                 //Terminate the internal burst signal as we have no burst capability
        internal_address <= slave_address_word; //The internal address is just the slave address as no burst incrementing required
    end
    
    //Now connect up the read signals
    if (MASTER_HAVE_READ && SLAVE_HAVE_READ) begin
        assign master_read = internal_read; //If both master an slave have read signals, connect them
    end else if (MASTER_HAVE_READ) begin
        assign master_read = 1'b1; //Else if the master has a read signal, assume we are always reading.
    end else begin
        assign master_read = 1'b0; //Otherwise just terminate the signal to avoid synthesis warnings.
    end
    
    //And then the wait request signals
    if (MASTER_HAVE_WAITREQ && SLAVE_HAVE_WAITREQ) begin
        assign slave_waitreq = master_waitreq; //Connect the master to the slave if both have one
    end else begin
        assign slave_waitreq = 1'b0; //Else the slave never needs to wait.
    end
    
    //Then the clock enables
    if (MASTER_HAVE_CLOCKEN && SLAVE_HAVE_CLOCKEN) begin
        assign master_clock_en = slave_clock_en;  //Connect the slave to the master if both have one
    end else begin
        assign master_clock_en = 1'b1;            //Else the master is always enabled 
    end
    
    //Then the chip select
    if (MASTER_HAVE_CHIPSEL && SLAVE_HAVE_CHIPSEL) begin
        assign master_chip_sel = slave_chip_sel;  //Connect the slave to the master if both have one.
    end else begin
        assign master_chip_sel = 1'b1;            //Else the master is always selected.
    end
    
    
end else begin

    // Otherwise we have all the required control signals to burst and bursting was requested.
    
    localparam ZERO = 0;
    localparam ONE = 1;
    
    wire internal_chip_sel;
    wire internal_clock_en;
    reg [(SLAVE_BURST_WIDTH-1):0] slave_burstremaining;
    
    //Create the bursting logic. This handles taking burst read requests from the slave and converting them into the individual read requests
    //that are sent to the master. Address incrementing is performed here as well.
    always @ (posedge clock or posedge reset) begin
        if (reset) begin
            slave_bursting <= 1'b0;
            internal_address <= ZERO[SLAVE_MEM_ADDRESS_WIDTH-1:0];
            slave_burstremaining <= ZERO[SLAVE_BURST_WIDTH-1:0];
        end else begin
            if (internal_clock_en && internal_chip_sel && internal_read && !slave_bursting) begin 
                //if this is a read request, and we are not currently bursting, then we are read to accept a burst, so load the address and burst count
                internal_address <= slave_address_word;                                    //load the starting address
                slave_bursting <= (slave_burstcount != ZERO[SLAVE_BURST_WIDTH-1:0]);       //only started bursting if non-zero length.
                slave_burstremaining <= slave_burstcount;                                  //load the total number of words to read.
            end else if (slave_burstremaining > ONE[SLAVE_BURST_WIDTH-1:0]) begin
                //If there are still some words outstanding, then request the next
                internal_address <= internal_address + ONE[SLAVE_MEM_ADDRESS_WIDTH-1:0];   //read the next word from the next address
                slave_burstremaining <= slave_burstremaining - ONE[SLAVE_BURST_WIDTH-1:0]; //and there will be one less burst remaining.
                slave_bursting <= 1'b1;                                                    //we are still bursting.
            end else begin
                slave_burstremaining <= ZERO[SLAVE_BURST_WIDTH-1:0];                       //Otherwise there are none remaining
                slave_bursting <= 1'b0;                                                    //And we have finished bursting.
            end
        end
    end
    
    //Connect the read signals
    if (MASTER_HAVE_READ) begin
        assign master_read = slave_bursting;        //If the master has a read signal, then we tell it to read while we are bursting
    end else begin
        assign master_read = 1'b0;                  //Otherwise just terminate the signal.
    end

    //Then the clock enables
    if (SLAVE_HAVE_CLOCKEN) begin                   
        assign internal_clock_en = slave_clock_en;  //Connect the slave to the master if both have one
    end else begin
        assign internal_clock_en = 1'b1;            //Else internally we are always enabled.
    end
    assign master_clock_en = slave_bursting;        //The master is only enabled while we are performing a burst read

    //Then the chip selects
    if (SLAVE_HAVE_CHIPSEL) begin
        assign internal_chip_sel = slave_chip_sel;  //Connect the slave to the master if both have one.
    end else begin
        assign internal_chip_sel = 1'b1;            //Internally we are always selected.
    end
    assign master_chip_sel = slave_bursting;        //The master is only selected while we are performing a burst read
    
    assign slave_waitreq = slave_bursting;          //We only allow 1 outstanding read request, so while we are bursting, the slave must wait for us to finish!
    
end endgenerate

assign slave_valid = dataValid; //If a valid signal is used by the slave, then it is valid only if the incoming data from the master is.


//Next we generate the selection logic to determine which part of the master interface we need to read from or write too.
generate if (SLAVE_MEM_ADDRESS_WIDTH > MASTER_MEM_ADDRESS_WIDTH) begin
    
    //We only need the selection logic if the master has a larger word width than the slave
    
    //Calculate the width of the multiplexers
    localparam MULTIPLEXER_WIDTH = SLAVE_MEM_ADDRESS_WIDTH - MASTER_MEM_ADDRESS_WIDTH;

    //Pass the upper bits of the slave address straight through to the master - lower bits are used for word selection.
    if (MASTER_MEM_ADDRESS_WIDTH != 0) begin
        assign master_address = internal_address[SLAVE_MEM_ADDRESS_WIDTH-1:MULTIPLEXER_WIDTH]; //But only if we have a master address signal.
    end
    
    //And connect the byte enables
    wire [(SLAVE_BYTE_EN_WIDTH-1):0] internal_byte_en; //create an internal byte enable signal which will be demultiplexed out to the masters byte enables.
    if (SLAVE_HAS_BYTE_EN) begin
        assign internal_byte_en = slave_byte_en;                  //If the slave has a byte enable, then pass that through to the master
    end else begin
        assign internal_byte_en = {(SLAVE_BYTE_EN_WIDTH){1'b1}}; //Otherwise make all bytes in the master always enabled.
    end
    
    
    //For each slave word in the master data bus, we only enable it if that word is selected by the address
    //This logic ensures that only one slave word in the master is ever selected.
    genvar i;
    for (i = 0; i < (1<<MULTIPLEXER_WIDTH); i=i+1) begin : write_data_loop
        localparam k = i * SLAVE_BYTE_EN_WIDTH;
        //if this word is currently selected - i.e. the lower address equals the index of this word, then its byte enables selected to be our internal byte enable signal. Otherwise they are all zeros
        assign master_byte_en[k+:SLAVE_BYTE_EN_WIDTH] = (internal_address[MULTIPLEXER_WIDTH-1:0] == i[MULTIPLEXER_WIDTH-1:0]) ? internal_byte_en : {(SLAVE_BYTE_EN_WIDTH){1'b0}}; 
    end
        
    
    //Connect the write specific signals
    if (!BRIDGE_IS_READONLY) begin
        //If the bridge is not read only, then we have a write interface
        assign master_write = slave_write;         //So pass the write control signal
        //Then connect up the master write data.
        for (i = 0; i < (1<<MULTIPLEXER_WIDTH); i=i+1) begin : write_data_loop
            localparam j = i * SLAVE_MEM_SYMBOL_WIDTH;
            assign master_writedata[j+:SLAVE_MEM_SYMBOL_WIDTH] = slave_writedata; //might as well just duplicate the slave data across all master memory symbols as the byte_en will do the rest.
        end
    end else if (!MASTER_HAVE_READ) begin 
        //Otherwise we have a read-only interface without a read signal, so assume the master has a write signal and that that must be low for a read
        assign master_write = 1'b0;                //never write, so must be reading
        assign master_writedata = {(MASTER_MEM_SYMBOL_WIDTH){1'b0}}; //Terminate the write data signal.
    end

    //Connect the read specific signals
    if (!BRIDGE_IS_WRITEONLY) begin
        wire latchAddress;
        wire clocken;
        wire chipsel;
        wire readlat;
        wire waitreq;
        //Determine if we should be reading from the master this cycle
        assign clocken = (!SLAVE_HAVE_CLOCKEN || slave_clock_en);
        assign chipsel = (!SLAVE_HAVE_CHIPSEL || slave_chip_sel);
        assign readlat = (!SLAVE_HAVE_READ || internal_read);
        assign waitreq = (!SLAVE_HAVE_WAITREQ || slave_waitreq);
        assign latchAddress = (BURST_MODE_ENABLED ? slave_bursting : (chipsel && clocken && readlat && !waitreq)); //in burst mode, slave_bursting controls reading of data, else use other signals.
        //The master has a 1 cycle read latency, so we delay our valid signal one cycle to line up with the returned data.
        always @ (posedge clock or posedge reset) begin
            if (reset) begin
                dataValid <= 1'b0;
            end else begin
                dataValid <= latchAddress; //The read data is valid next cycle if we performed a read this cycle
            end
        end
        
        //We also need to delay the lower bits of the address as well so we can use them as the select signal for the read data multiplexer.
        reg [MULTIPLEXER_WIDTH-1:0] lowAddress;
        always @ (posedge clock or posedge reset) begin
            if (reset) begin
                lowAddress <= {(MULTIPLEXER_WIDTH){1'b0}};
            end else if (latchAddress) begin //if chip selected and clock enabled, so...
                lowAddress <= internal_address[MULTIPLEXER_WIDTH-1:0]; //latch in the low bits of the slave address as they will control the mux on the data output.
            end
        end
    
        //As the slave read data and master read data are different widths, we need to add a multiplexer to select which part of the master data
        //bus we send through to the slave. So add a multiplexer.
        avmm_width_adapter_mux #(
            .MUX_SELECT_WIDTH(MULTIPLEXER_WIDTH), //Multiplexer is larger enough to bring all of the symbols in the master down to the slave.
            .SYMBOL_WIDTH(SLAVE_MEM_SYMBOL_WIDTH)
        ) data_mux (
            .in(master_readdata), //Master data goes in
            .select(lowAddress),  //Use the latched address as the selection signal.
            .out(slave_readdata)  //Multiplexed data comes out to the slave
        );
    end

end else begin
    
    //Otherwise, generate some simple pass through logic if the addresses are equal

    //Pass the address straight through
    if (MASTER_MEM_ADDRESS_WIDTH != 0) begin
        assign master_address = internal_address; //But only if we have a master address signal!
    end
    
    //And connect the byte enables
    if (SLAVE_HAS_BYTE_EN) begin
        assign master_byte_en = slave_byte_en[MASTER_BYTE_EN_WIDTH-1:0]; //If the slave has a byte enable, then pass that through to the master
    end else begin
        assign master_byte_en = {(MASTER_BYTE_EN_WIDTH){1'b1}};          //Otherwise make all bytes in the master always enabled.
    end
    
    //Connect the write specific signals
    if (!BRIDGE_IS_READONLY) begin
        //If the bridge is not read only, then we have a write interface
        assign master_write = slave_write;                                      //So pass the write control signal
        assign master_writedata = slave_writedata[MASTER_MEM_SYMBOL_WIDTH-1:0]; //And the write data through
    end else if (!MASTER_HAVE_READ) begin 
        //Otherwise we have a read-only interface without a read signal, so assume the master has a write signal and that that must be low for a read
        assign master_write = 1'b0;                                             //never write, so must be reading
        assign master_writedata = {(MASTER_MEM_SYMBOL_WIDTH){1'b0}};            //Terminate the write data signal.
    end
    
    //Connect the read specific signals
    if (!BRIDGE_IS_WRITEONLY) begin
        wire latchAddress;
        wire clocken;
        wire chipsel;
        wire readlat;
        wire waitreq;
        //Determine if we should be reading from the master this cycle
        assign clocken = (!SLAVE_HAVE_CLOCKEN || slave_clock_en);
        assign chipsel = (!SLAVE_HAVE_CHIPSEL || slave_chip_sel);
        assign readlat = (!SLAVE_HAVE_READ    || internal_read );
        assign waitreq = (!SLAVE_HAVE_WAITREQ || slave_waitreq );
        assign latchAddress = (BURST_MODE_ENABLED ? slave_bursting : (chipsel && clocken && readlat && !waitreq)); //in burst mode, slave_bursting controls reading of data, else use other signals.
        //The master has a 1 cycle read latency, so we delay our valid signal one cycle to line up with the returned data.
        always @ (posedge clock or posedge reset) begin
            if (reset) begin
                dataValid <= 1'b0;
            end else begin
                dataValid <= latchAddress; //The read data is valid next cycle if we performed a read this cycle
            end
        end
        localparam PADDING_WIDTH = SLAVE_MEM_SYMBOL_WIDTH - MASTER_MEM_SYMBOL_WIDTH;
        assign slave_readdata = {{(PADDING_WIDTH){1'b0}},master_readdata};           //Pass the read data through, padding if not the same width as the master.
    end
    
end endgenerate

endmodule

/*
 * Width Adapter Helper - Multiplexer
 *
 * This module is simply a multiplexer for a data bus. Nothing particularly special.
 */
module avmm_width_adapter_mux #(
    parameter MUX_SELECT_WIDTH = 2,
    parameter SYMBOL_WIDTH = 32,
    parameter MUX_INPUTS = (1<<MUX_SELECT_WIDTH)
)(
    input  [(MUX_INPUTS*SYMBOL_WIDTH)-1:0] in,
    input  [MUX_SELECT_WIDTH-1:0] select,
    output [SYMBOL_WIDTH-1:0]out
);

wire [SYMBOL_WIDTH-1:0] mux [MUX_INPUTS-1:0];
genvar i;
generate for (i = 0; i < MUX_INPUTS; i=i+1) begin : mux_loop
    localparam j = i * SYMBOL_WIDTH;
    assign mux[i] = in[j+:SYMBOL_WIDTH]; //Connect all the symbols on the wider input. Each symbol goes to a different multiplexer input
end endgenerate

assign out = mux[select]; //Select which one we want!


endmodule
