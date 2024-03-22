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


module HPSWrapper_arm_hps_hps_io_border(
// gpio_loanio
  output wire [29 - 1 : 0 ] gpio_loanio_loanio0_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_o
 ,output wire [29 - 1 : 0 ] gpio_loanio_loanio1_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_o
 ,output wire [9 - 1 : 0 ] gpio_loanio_loanio2_i
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_oe
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_o
// memory
 ,output wire [15 - 1 : 0 ] mem_a
 ,output wire [3 - 1 : 0 ] mem_ba
 ,output wire [1 - 1 : 0 ] mem_ck
 ,output wire [1 - 1 : 0 ] mem_ck_n
 ,output wire [1 - 1 : 0 ] mem_cke
 ,output wire [1 - 1 : 0 ] mem_cs_n
 ,output wire [1 - 1 : 0 ] mem_ras_n
 ,output wire [1 - 1 : 0 ] mem_cas_n
 ,output wire [1 - 1 : 0 ] mem_we_n
 ,output wire [1 - 1 : 0 ] mem_reset_n
 ,inout wire [32 - 1 : 0 ] mem_dq
 ,inout wire [4 - 1 : 0 ] mem_dqs
 ,inout wire [4 - 1 : 0 ] mem_dqs_n
 ,output wire [1 - 1 : 0 ] mem_odt
 ,output wire [4 - 1 : 0 ] mem_dm
 ,input wire [1 - 1 : 0 ] oct_rzqin
// hps_io
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_CMD
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D0
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D1
 ,output wire [1 - 1 : 0 ] hps_io_sdio_inst_CLK
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D2
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D3
 ,inout wire [1 - 1 : 0 ] hps_io_i2c0_inst_SDA
 ,inout wire [1 - 1 : 0 ] hps_io_i2c0_inst_SCL
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO48
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO53
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_GPIO54
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO49
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO50
);

wire [22 - 1 : 0] intermediate;
wire [63 - 1 : 0] floating;

assign hps_io_sdio_inst_CMD = intermediate[1] ? intermediate[0] : 'z;
assign hps_io_sdio_inst_D0 = intermediate[3] ? intermediate[2] : 'z;
assign hps_io_sdio_inst_D1 = intermediate[5] ? intermediate[4] : 'z;
assign hps_io_sdio_inst_D2 = intermediate[7] ? intermediate[6] : 'z;
assign hps_io_sdio_inst_D3 = intermediate[9] ? intermediate[8] : 'z;
assign hps_io_i2c0_inst_SDA = intermediate[10] ? '0 : 'z;
assign hps_io_i2c0_inst_SCL = intermediate[11] ? '0 : 'z;
assign hps_io_gpio_inst_GPIO48 = intermediate[13] ? intermediate[12] : 'z;
assign hps_io_gpio_inst_GPIO53 = intermediate[15] ? intermediate[14] : 'z;
assign hps_io_gpio_inst_GPIO54 = intermediate[17] ? intermediate[16] : 'z;
assign hps_io_gpio_inst_LOANIO49 = intermediate[19] ? intermediate[18] : 'z;
assign hps_io_gpio_inst_LOANIO50 = intermediate[21] ? intermediate[20] : 'z;

cyclonev_hps_peripheral_sdmmc sdio_inst(
 .SDMMC_DATA_I({
    hps_io_sdio_inst_D3[0:0] // 3:3
   ,hps_io_sdio_inst_D2[0:0] // 2:2
   ,hps_io_sdio_inst_D1[0:0] // 1:1
   ,hps_io_sdio_inst_D0[0:0] // 0:0
  })
,.SDMMC_CMD_O({
    intermediate[0:0] // 0:0
  })
,.SDMMC_CCLK({
    hps_io_sdio_inst_CLK[0:0] // 0:0
  })
,.SDMMC_DATA_O({
    intermediate[8:8] // 3:3
   ,intermediate[6:6] // 2:2
   ,intermediate[4:4] // 1:1
   ,intermediate[2:2] // 0:0
  })
,.SDMMC_CMD_OE({
    intermediate[1:1] // 0:0
  })
,.SDMMC_CMD_I({
    hps_io_sdio_inst_CMD[0:0] // 0:0
  })
,.SDMMC_DATA_OE({
    intermediate[9:9] // 3:3
   ,intermediate[7:7] // 2:2
   ,intermediate[5:5] // 1:1
   ,intermediate[3:3] // 0:0
  })
);


cyclonev_hps_peripheral_i2c i2c0_inst(
 .I2C_DATA({
    hps_io_i2c0_inst_SDA[0:0] // 0:0
  })
,.I2C_CLK({
    hps_io_i2c0_inst_SCL[0:0] // 0:0
  })
,.I2C_DATA_OE({
    intermediate[10:10] // 0:0
  })
,.I2C_CLK_OE({
    intermediate[11:11] // 0:0
  })
);


cyclonev_hps_peripheral_gpio gpio_inst(
 .GPIO1_PORTA_I({
    hps_io_gpio_inst_GPIO54[0:0] // 25:25
   ,hps_io_gpio_inst_GPIO53[0:0] // 24:24
   ,floating[1:0] // 23:22
   ,hps_io_gpio_inst_LOANIO50[0:0] // 21:21
   ,hps_io_gpio_inst_LOANIO49[0:0] // 20:20
   ,hps_io_gpio_inst_GPIO48[0:0] // 19:19
   ,floating[20:2] // 18:0
  })
,.LOANIO1_O({
    gpio_loanio_loanio1_o[28:0] // 28:0
  })
,.LOANIO0_OE({
    gpio_loanio_loanio0_oe[28:0] // 28:0
  })
,.LOANIO0_I({
    gpio_loanio_loanio0_i[28:0] // 28:0
  })
,.GPIO1_PORTA_OE({
    intermediate[17:17] // 25:25
   ,intermediate[15:15] // 24:24
   ,floating[22:21] // 23:22
   ,intermediate[21:21] // 21:21
   ,intermediate[19:19] // 20:20
   ,intermediate[13:13] // 19:19
   ,floating[41:23] // 18:0
  })
,.LOANIO2_O({
    gpio_loanio_loanio2_o[8:0] // 8:0
  })
,.LOANIO1_I({
    gpio_loanio_loanio1_i[28:0] // 28:0
  })
,.LOANIO2_I({
    gpio_loanio_loanio2_i[8:0] // 8:0
  })
,.LOANIO2_OE({
    gpio_loanio_loanio2_oe[8:0] // 8:0
  })
,.GPIO1_PORTA_O({
    intermediate[16:16] // 25:25
   ,intermediate[14:14] // 24:24
   ,floating[43:42] // 23:22
   ,intermediate[20:20] // 21:21
   ,intermediate[18:18] // 20:20
   ,intermediate[12:12] // 19:19
   ,floating[62:44] // 18:0
  })
,.LOANIO1_OE({
    gpio_loanio_loanio1_oe[28:0] // 28:0
  })
,.LOANIO0_O({
    gpio_loanio_loanio0_o[28:0] // 28:0
  })
);


hps_sdram hps_sdram_inst(
 .mem_dq({
    mem_dq[31:0] // 31:0
  })
,.mem_odt({
    mem_odt[0:0] // 0:0
  })
,.mem_ras_n({
    mem_ras_n[0:0] // 0:0
  })
,.mem_dqs_n({
    mem_dqs_n[3:0] // 3:0
  })
,.mem_dqs({
    mem_dqs[3:0] // 3:0
  })
,.mem_dm({
    mem_dm[3:0] // 3:0
  })
,.mem_we_n({
    mem_we_n[0:0] // 0:0
  })
,.mem_cas_n({
    mem_cas_n[0:0] // 0:0
  })
,.mem_ba({
    mem_ba[2:0] // 2:0
  })
,.mem_a({
    mem_a[14:0] // 14:0
  })
,.mem_cs_n({
    mem_cs_n[0:0] // 0:0
  })
,.mem_ck({
    mem_ck[0:0] // 0:0
  })
,.mem_cke({
    mem_cke[0:0] // 0:0
  })
,.oct_rzqin({
    oct_rzqin[0:0] // 0:0
  })
,.mem_reset_n({
    mem_reset_n[0:0] // 0:0
  })
,.mem_ck_n({
    mem_ck_n[0:0] // 0:0
  })
);

endmodule

