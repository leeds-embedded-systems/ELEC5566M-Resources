// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module HPSWrapper_arm_hps_fpga_interfaces(
// h2f_loan_io
  output wire [67 - 1 : 0 ] h2f_loan_in
 ,input wire [67 - 1 : 0 ] h2f_loan_out
 ,input wire [67 - 1 : 0 ] h2f_loan_oe
// loanio_gpio
 ,input wire [29 - 1 : 0 ] loanio_gpio_loanio0_i
 ,output wire [29 - 1 : 0 ] loanio_gpio_loanio0_oe
 ,output wire [29 - 1 : 0 ] loanio_gpio_loanio0_o
 ,input wire [29 - 1 : 0 ] loanio_gpio_loanio1_i
 ,output wire [29 - 1 : 0 ] loanio_gpio_loanio1_oe
 ,output wire [29 - 1 : 0 ] loanio_gpio_loanio1_o
 ,input wire [9 - 1 : 0 ] loanio_gpio_loanio2_i
 ,output wire [9 - 1 : 0 ] loanio_gpio_loanio2_oe
 ,output wire [9 - 1 : 0 ] loanio_gpio_loanio2_o
// h2f_reset
 ,output wire [1 - 1 : 0 ] h2f_rst_n
// h2f_user0_clock
 ,output wire [1 - 1 : 0 ] h2f_user0_clk
// h2f_lw_axi_clock
 ,input wire [1 - 1 : 0 ] h2f_lw_axi_clk
// h2f_lw_axi_master
 ,output wire [12 - 1 : 0 ] h2f_lw_AWID
 ,output wire [21 - 1 : 0 ] h2f_lw_AWADDR
 ,output wire [4 - 1 : 0 ] h2f_lw_AWLEN
 ,output wire [3 - 1 : 0 ] h2f_lw_AWSIZE
 ,output wire [2 - 1 : 0 ] h2f_lw_AWBURST
 ,output wire [2 - 1 : 0 ] h2f_lw_AWLOCK
 ,output wire [4 - 1 : 0 ] h2f_lw_AWCACHE
 ,output wire [3 - 1 : 0 ] h2f_lw_AWPROT
 ,output wire [1 - 1 : 0 ] h2f_lw_AWVALID
 ,input wire [1 - 1 : 0 ] h2f_lw_AWREADY
 ,output wire [12 - 1 : 0 ] h2f_lw_WID
 ,output wire [32 - 1 : 0 ] h2f_lw_WDATA
 ,output wire [4 - 1 : 0 ] h2f_lw_WSTRB
 ,output wire [1 - 1 : 0 ] h2f_lw_WLAST
 ,output wire [1 - 1 : 0 ] h2f_lw_WVALID
 ,input wire [1 - 1 : 0 ] h2f_lw_WREADY
 ,input wire [12 - 1 : 0 ] h2f_lw_BID
 ,input wire [2 - 1 : 0 ] h2f_lw_BRESP
 ,input wire [1 - 1 : 0 ] h2f_lw_BVALID
 ,output wire [1 - 1 : 0 ] h2f_lw_BREADY
 ,output wire [12 - 1 : 0 ] h2f_lw_ARID
 ,output wire [21 - 1 : 0 ] h2f_lw_ARADDR
 ,output wire [4 - 1 : 0 ] h2f_lw_ARLEN
 ,output wire [3 - 1 : 0 ] h2f_lw_ARSIZE
 ,output wire [2 - 1 : 0 ] h2f_lw_ARBURST
 ,output wire [2 - 1 : 0 ] h2f_lw_ARLOCK
 ,output wire [4 - 1 : 0 ] h2f_lw_ARCACHE
 ,output wire [3 - 1 : 0 ] h2f_lw_ARPROT
 ,output wire [1 - 1 : 0 ] h2f_lw_ARVALID
 ,input wire [1 - 1 : 0 ] h2f_lw_ARREADY
 ,input wire [12 - 1 : 0 ] h2f_lw_RID
 ,input wire [32 - 1 : 0 ] h2f_lw_RDATA
 ,input wire [2 - 1 : 0 ] h2f_lw_RRESP
 ,input wire [1 - 1 : 0 ] h2f_lw_RLAST
 ,input wire [1 - 1 : 0 ] h2f_lw_RVALID
 ,output wire [1 - 1 : 0 ] h2f_lw_RREADY
// h2f_axi_clock
 ,input wire [1 - 1 : 0 ] h2f_axi_clk
// h2f_axi_master
 ,output wire [12 - 1 : 0 ] h2f_AWID
 ,output wire [30 - 1 : 0 ] h2f_AWADDR
 ,output wire [4 - 1 : 0 ] h2f_AWLEN
 ,output wire [3 - 1 : 0 ] h2f_AWSIZE
 ,output wire [2 - 1 : 0 ] h2f_AWBURST
 ,output wire [2 - 1 : 0 ] h2f_AWLOCK
 ,output wire [4 - 1 : 0 ] h2f_AWCACHE
 ,output wire [3 - 1 : 0 ] h2f_AWPROT
 ,output wire [1 - 1 : 0 ] h2f_AWVALID
 ,input wire [1 - 1 : 0 ] h2f_AWREADY
 ,output wire [12 - 1 : 0 ] h2f_WID
 ,output wire [32 - 1 : 0 ] h2f_WDATA
 ,output wire [4 - 1 : 0 ] h2f_WSTRB
 ,output wire [1 - 1 : 0 ] h2f_WLAST
 ,output wire [1 - 1 : 0 ] h2f_WVALID
 ,input wire [1 - 1 : 0 ] h2f_WREADY
 ,input wire [12 - 1 : 0 ] h2f_BID
 ,input wire [2 - 1 : 0 ] h2f_BRESP
 ,input wire [1 - 1 : 0 ] h2f_BVALID
 ,output wire [1 - 1 : 0 ] h2f_BREADY
 ,output wire [12 - 1 : 0 ] h2f_ARID
 ,output wire [30 - 1 : 0 ] h2f_ARADDR
 ,output wire [4 - 1 : 0 ] h2f_ARLEN
 ,output wire [3 - 1 : 0 ] h2f_ARSIZE
 ,output wire [2 - 1 : 0 ] h2f_ARBURST
 ,output wire [2 - 1 : 0 ] h2f_ARLOCK
 ,output wire [4 - 1 : 0 ] h2f_ARCACHE
 ,output wire [3 - 1 : 0 ] h2f_ARPROT
 ,output wire [1 - 1 : 0 ] h2f_ARVALID
 ,input wire [1 - 1 : 0 ] h2f_ARREADY
 ,input wire [12 - 1 : 0 ] h2f_RID
 ,input wire [32 - 1 : 0 ] h2f_RDATA
 ,input wire [2 - 1 : 0 ] h2f_RRESP
 ,input wire [1 - 1 : 0 ] h2f_RLAST
 ,input wire [1 - 1 : 0 ] h2f_RVALID
 ,output wire [1 - 1 : 0 ] h2f_RREADY
// f2h_sdram0_data
 ,input wire [30 - 1 : 0 ] f2h_sdram0_ADDRESS
 ,input wire [8 - 1 : 0 ] f2h_sdram0_BURSTCOUNT
 ,output wire [1 - 1 : 0 ] f2h_sdram0_WAITREQUEST
 ,output wire [32 - 1 : 0 ] f2h_sdram0_READDATA
 ,output wire [1 - 1 : 0 ] f2h_sdram0_READDATAVALID
 ,input wire [1 - 1 : 0 ] f2h_sdram0_READ
// f2h_sdram0_clock
 ,input wire [1 - 1 : 0 ] f2h_sdram0_clk
// f2h_sdram1_data
 ,input wire [30 - 1 : 0 ] f2h_sdram1_ADDRESS
 ,input wire [8 - 1 : 0 ] f2h_sdram1_BURSTCOUNT
 ,output wire [1 - 1 : 0 ] f2h_sdram1_WAITREQUEST
 ,input wire [32 - 1 : 0 ] f2h_sdram1_WRITEDATA
 ,input wire [4 - 1 : 0 ] f2h_sdram1_BYTEENABLE
 ,input wire [1 - 1 : 0 ] f2h_sdram1_WRITE
// f2h_sdram1_clock
 ,input wire [1 - 1 : 0 ] f2h_sdram1_clk
// f2h_irq0
 ,input wire [32 - 1 : 0 ] f2h_irq_p0
// f2h_irq1
 ,input wire [32 - 1 : 0 ] f2h_irq_p1
);


wire [14 - 1 : 0] intermediate;
assign intermediate[0:0] = ~intermediate[1:1];
assign intermediate[4:4] = intermediate[3:3];
assign intermediate[2:2] = intermediate[5:5];
assign intermediate[6:6] = intermediate[5:5];
assign intermediate[7:7] = ~intermediate[8:8];
assign intermediate[11:11] = intermediate[10:10];
assign intermediate[9:9] = intermediate[12:12];
assign intermediate[13:13] = intermediate[12:12];
assign f2h_sdram0_WAITREQUEST[0:0] = intermediate[0:0];
assign f2h_sdram1_WAITREQUEST[0:0] = intermediate[7:7];
assign intermediate[3:3] = f2h_sdram0_READ[0:0];
assign intermediate[5:5] = f2h_sdram0_clk[0:0];
assign intermediate[10:10] = f2h_sdram1_WRITE[0:0];
assign intermediate[12:12] = f2h_sdram1_clk[0:0];

cyclonev_hps_interface_loan_io loan_io_inst(
 .loanio_in({
    h2f_loan_in[66:0] // 66:0
  })
,.loanio_out({
    h2f_loan_out[66:0] // 66:0
  })
,.GPIO_OUT({
    loanio_gpio_loanio2_o[8:0] // 66:58
   ,loanio_gpio_loanio1_o[28:0] // 57:29
   ,loanio_gpio_loanio0_o[28:0] // 28:0
  })
,.GPIO_OE({
    loanio_gpio_loanio2_oe[8:0] // 66:58
   ,loanio_gpio_loanio1_oe[28:0] // 57:29
   ,loanio_gpio_loanio0_oe[28:0] // 28:0
  })
,.GPIO_IN({
    loanio_gpio_loanio2_i[8:0] // 66:58
   ,loanio_gpio_loanio1_i[28:0] // 57:29
   ,loanio_gpio_loanio0_i[28:0] // 28:0
  })
,.loanio_oe({
    h2f_loan_oe[66:0] // 66:0
  })
);


cyclonev_hps_interface_clocks_resets clocks_resets(
 .f2h_pending_rst_ack({
    1'b1 // 0:0
  })
,.f2h_warm_rst_req_n({
    1'b1 // 0:0
  })
,.f2h_dbg_rst_req_n({
    1'b1 // 0:0
  })
,.h2f_rst_n({
    h2f_rst_n[0:0] // 0:0
  })
,.f2h_cold_rst_req_n({
    1'b1 // 0:0
  })
,.h2f_user0_clk({
    h2f_user0_clk[0:0] // 0:0
  })
);


cyclonev_hps_interface_dbg_apb debug_apb(
 .DBG_APB_DISABLE({
    1'b0 // 0:0
  })
,.P_CLK_EN({
    1'b0 // 0:0
  })
);


cyclonev_hps_interface_tpiu_trace tpiu(
 .traceclk_ctl({
    1'b1 // 0:0
  })
);


cyclonev_hps_interface_boot_from_fpga boot_from_fpga(
 .boot_from_fpga_ready({
    1'b0 // 0:0
  })
,.boot_from_fpga_on_failure({
    1'b0 // 0:0
  })
,.bsel_en({
    1'b0 // 0:0
  })
,.csel_en({
    1'b0 // 0:0
  })
,.csel({
    2'b01 // 1:0
  })
,.bsel({
    3'b001 // 2:0
  })
);


cyclonev_hps_interface_fpga2hps fpga2hps(
 .port_size_config({
    2'b11 // 1:0
  })
);


cyclonev_hps_interface_hps2fpga_light_weight hps2fpga_light_weight(
 .arsize({
    h2f_lw_ARSIZE[2:0] // 2:0
  })
,.wvalid({
    h2f_lw_WVALID[0:0] // 0:0
  })
,.rlast({
    h2f_lw_RLAST[0:0] // 0:0
  })
,.clk({
    h2f_lw_axi_clk[0:0] // 0:0
  })
,.rresp({
    h2f_lw_RRESP[1:0] // 1:0
  })
,.arready({
    h2f_lw_ARREADY[0:0] // 0:0
  })
,.arprot({
    h2f_lw_ARPROT[2:0] // 2:0
  })
,.araddr({
    h2f_lw_ARADDR[20:0] // 20:0
  })
,.bvalid({
    h2f_lw_BVALID[0:0] // 0:0
  })
,.arid({
    h2f_lw_ARID[11:0] // 11:0
  })
,.bid({
    h2f_lw_BID[11:0] // 11:0
  })
,.arburst({
    h2f_lw_ARBURST[1:0] // 1:0
  })
,.arcache({
    h2f_lw_ARCACHE[3:0] // 3:0
  })
,.awvalid({
    h2f_lw_AWVALID[0:0] // 0:0
  })
,.wdata({
    h2f_lw_WDATA[31:0] // 31:0
  })
,.rid({
    h2f_lw_RID[11:0] // 11:0
  })
,.rvalid({
    h2f_lw_RVALID[0:0] // 0:0
  })
,.wready({
    h2f_lw_WREADY[0:0] // 0:0
  })
,.awlock({
    h2f_lw_AWLOCK[1:0] // 1:0
  })
,.bresp({
    h2f_lw_BRESP[1:0] // 1:0
  })
,.arlen({
    h2f_lw_ARLEN[3:0] // 3:0
  })
,.awsize({
    h2f_lw_AWSIZE[2:0] // 2:0
  })
,.awlen({
    h2f_lw_AWLEN[3:0] // 3:0
  })
,.bready({
    h2f_lw_BREADY[0:0] // 0:0
  })
,.awid({
    h2f_lw_AWID[11:0] // 11:0
  })
,.rdata({
    h2f_lw_RDATA[31:0] // 31:0
  })
,.awready({
    h2f_lw_AWREADY[0:0] // 0:0
  })
,.arvalid({
    h2f_lw_ARVALID[0:0] // 0:0
  })
,.wlast({
    h2f_lw_WLAST[0:0] // 0:0
  })
,.awprot({
    h2f_lw_AWPROT[2:0] // 2:0
  })
,.awaddr({
    h2f_lw_AWADDR[20:0] // 20:0
  })
,.wid({
    h2f_lw_WID[11:0] // 11:0
  })
,.awcache({
    h2f_lw_AWCACHE[3:0] // 3:0
  })
,.arlock({
    h2f_lw_ARLOCK[1:0] // 1:0
  })
,.awburst({
    h2f_lw_AWBURST[1:0] // 1:0
  })
,.rready({
    h2f_lw_RREADY[0:0] // 0:0
  })
,.wstrb({
    h2f_lw_WSTRB[3:0] // 3:0
  })
);


cyclonev_hps_interface_hps2fpga hps2fpga(
 .port_size_config({
    2'b00 // 1:0
  })
,.arsize({
    h2f_ARSIZE[2:0] // 2:0
  })
,.wvalid({
    h2f_WVALID[0:0] // 0:0
  })
,.rlast({
    h2f_RLAST[0:0] // 0:0
  })
,.clk({
    h2f_axi_clk[0:0] // 0:0
  })
,.rresp({
    h2f_RRESP[1:0] // 1:0
  })
,.arready({
    h2f_ARREADY[0:0] // 0:0
  })
,.arprot({
    h2f_ARPROT[2:0] // 2:0
  })
,.araddr({
    h2f_ARADDR[29:0] // 29:0
  })
,.bvalid({
    h2f_BVALID[0:0] // 0:0
  })
,.arid({
    h2f_ARID[11:0] // 11:0
  })
,.bid({
    h2f_BID[11:0] // 11:0
  })
,.arburst({
    h2f_ARBURST[1:0] // 1:0
  })
,.arcache({
    h2f_ARCACHE[3:0] // 3:0
  })
,.awvalid({
    h2f_AWVALID[0:0] // 0:0
  })
,.wdata({
    h2f_WDATA[31:0] // 31:0
  })
,.rid({
    h2f_RID[11:0] // 11:0
  })
,.rvalid({
    h2f_RVALID[0:0] // 0:0
  })
,.wready({
    h2f_WREADY[0:0] // 0:0
  })
,.awlock({
    h2f_AWLOCK[1:0] // 1:0
  })
,.bresp({
    h2f_BRESP[1:0] // 1:0
  })
,.arlen({
    h2f_ARLEN[3:0] // 3:0
  })
,.awsize({
    h2f_AWSIZE[2:0] // 2:0
  })
,.awlen({
    h2f_AWLEN[3:0] // 3:0
  })
,.bready({
    h2f_BREADY[0:0] // 0:0
  })
,.awid({
    h2f_AWID[11:0] // 11:0
  })
,.rdata({
    h2f_RDATA[31:0] // 31:0
  })
,.awready({
    h2f_AWREADY[0:0] // 0:0
  })
,.arvalid({
    h2f_ARVALID[0:0] // 0:0
  })
,.wlast({
    h2f_WLAST[0:0] // 0:0
  })
,.awprot({
    h2f_AWPROT[2:0] // 2:0
  })
,.awaddr({
    h2f_AWADDR[29:0] // 29:0
  })
,.wid({
    h2f_WID[11:0] // 11:0
  })
,.awcache({
    h2f_AWCACHE[3:0] // 3:0
  })
,.arlock({
    h2f_ARLOCK[1:0] // 1:0
  })
,.awburst({
    h2f_AWBURST[1:0] // 1:0
  })
,.rready({
    h2f_RREADY[0:0] // 0:0
  })
,.wstrb({
    h2f_WSTRB[3:0] // 3:0
  })
);


cyclonev_hps_interface_fpga2sdram f2sdram(
 .cmd_data_1({
    18'b000000000000000000 // 59:42
   ,f2h_sdram1_BURSTCOUNT[7:0] // 41:34
   ,2'b00 // 33:32
   ,f2h_sdram1_ADDRESS[29:0] // 31:2
   ,intermediate[10:10] // 1:1
   ,1'b0 // 0:0
  })
,.cmd_data_0({
    18'b000000000000000000 // 59:42
   ,f2h_sdram0_BURSTCOUNT[7:0] // 41:34
   ,2'b00 // 33:32
   ,f2h_sdram0_ADDRESS[29:0] // 31:2
   ,1'b0 // 1:1
   ,intermediate[3:3] // 0:0
  })
,.cfg_port_width({
    12'b000000000000 // 11:0
  })
,.rd_valid_0({
    f2h_sdram0_READDATAVALID[0:0] // 0:0
  })
,.wr_clk_0({
    intermediate[9:9] // 0:0
  })
,.cfg_cport_type({
    12'b000000000110 // 11:0
  })
,.wr_data_0({
    6'b000000 // 89:84
   ,f2h_sdram1_BYTEENABLE[3:0] // 83:80
   ,48'b000000000000000000000000000000000000000000000000 // 79:32
   ,f2h_sdram1_WRITEDATA[31:0] // 31:0
  })
,.cfg_rfifo_cport_map({
    16'b0000000000000000 // 15:0
  })
,.cfg_cport_wfifo_map({
    18'b000000000000000000 // 17:0
  })
,.cmd_port_clk_1({
    intermediate[13:13] // 0:0
  })
,.cmd_port_clk_0({
    intermediate[6:6] // 0:0
  })
,.cfg_cport_rfifo_map({
    18'b000000000000000000 // 17:0
  })
,.rd_ready_0({
    1'b1 // 0:0
  })
,.cmd_ready_1({
    intermediate[8:8] // 0:0
  })
,.cmd_ready_0({
    intermediate[1:1] // 0:0
  })
,.rd_clk_0({
    intermediate[2:2] // 0:0
  })
,.cfg_wfifo_cport_map({
    16'b0000000000000001 // 15:0
  })
,.wrack_ready_1({
    1'b1 // 0:0
  })
,.cmd_valid_1({
    intermediate[11:11] // 0:0
  })
,.cmd_valid_0({
    intermediate[4:4] // 0:0
  })
,.rd_data_0({
    f2h_sdram0_READDATA[31:0] // 31:0
  })
,.cfg_axi_mm_select({
    6'b000000 // 5:0
  })
);


cyclonev_hps_interface_interrupts interrupts(
 .irq({
    f2h_irq_p1[31:0] // 63:32
   ,f2h_irq_p0[31:0] // 31:0
  })
);

endmodule

