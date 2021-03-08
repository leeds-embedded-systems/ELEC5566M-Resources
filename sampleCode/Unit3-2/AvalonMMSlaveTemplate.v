/*
 * Avalon-MM Slave Template
 * ------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 8th March 2021
 *
 * Description
 * ------------
 * This module implements a basic slave configuration status interface
 * compatible with the Altera Avalon Memory Mapped Interface standard.
 *
 * Such interfaces are typically used in large processor controlled
 * systems to allow memory mapped access to peripherals. The Leeds SoC
 * Computer design used for the ELEC5620M module makes use of a number
 * of peripherals based around this interface style controlled by the
 * ARM CPU on the Cyclone V SoC.
 */

module AvalonMMSlaveTemplate (                                                  /*!\tikzmark{avmm_codeedge}!*/
    input             clock,
    input             reset,
    //Typical CSR Interface
    input      [ 0:0] csr_address,    //Lets say a 1-bit address. Can be any width
    input             csr_chipselect,
    input             csr_write,
    input      [31:0] csr_writedata,  //We'll use a 32-bit data bus, common for CPUs
    input      [ 3:0] csr_byteenable, //32-bit = 4 bytes, so we need four enable bits
    input             csr_read,
    output reg [31:0] csr_readdata    //A 32-bit read data bus
);
//Internal Variables
reg  [15:0] oneSignal; //We need registers for all signals that we will be writing 
reg  [ 7:0] twoSignal; //to in the CSR. They can be any width you want. 
//Set up the Read Data Map for the CSR. /*!\tikzmark{avmm_readstart}!*/
//Input signals are mapped to correct bits at the correct addresses here. 
wire [31:0] readMap [1:0];
assign readMap[0] = { 16'b0,     oneSignal }; 
assign readMap[1] = { twoSignal,     24'b0 }; 
//... so on for other addresses
always @ (posedge clock) begin
    if (csr_read && csr_chipselect) begin //when CSR read is asserted
        csr_readdata <= dataToMaster[csr_address]; //Read from CSR map
    end
end /*!\tikzmark{avmm_readend}!*/
//Convert byte enable signal into bit enable. Basically each group of 8 bits  /*!\tikzmark{avmm_bestart}!*/
//is assigned to the value of the corresponding byte enable. 
wire [31:0] bitenable;
assign bitenable = {{8{csr_byteenable[3]}},
                    {8{csr_byteenable[2]}},
                    {8{csr_byteenable[1]}},
                    {8{csr_byteenable[0]}}};  /*!\tikzmark{avmm_beend}!*/
//Next comes the Write logic /*!\tikzmark{avmm_writestart}!*/
wire [31:0] maskedWrite; 
assign maskedWrite = csr_writedata & bitenable; //Mask off disabled bits
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        oneSignal     <= 16'b0;
        twoSignal     <= 8'b0;
    end else if (csr_write && csr_chipselect) begin //When a write is issued
        //update the registers at the corresponding address.
        if (csr_address == 1'd0) begin //You could also use a case statement
            oneSignal <= (oneSignal & ~bitenable[0+:16]) | maskedWrite[0+:16];
            //We have one line here for each of the registers we can write to.
            //Each clears bits being written, and then ORs in the write data
        end
        if (csr_address == 1'd1) begin
            twoSignal <= (twoSignal & ~bitenable[24+:8]) | maskedWrite[24+:8]; 
        end
    end
end /*!\tikzmark{avmm_writeend}!*/
//... End CSR ...
endmodule
