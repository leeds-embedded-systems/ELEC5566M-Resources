
# Requre quartus project
package require ::quartus::project

# Set pin locations for LCD on GPIO 0
set_location_assignment PIN_AJ17 -to LT24Data[0]
set_location_assignment PIN_AJ19 -to LT24Data[1]
set_location_assignment PIN_AK19 -to LT24Data[2]
set_location_assignment PIN_AK18 -to LT24Data[3]
set_location_assignment PIN_AE16 -to LT24Data[4]
set_location_assignment PIN_AF16 -to LT24Data[5]
set_location_assignment PIN_AG17 -to LT24Data[6]
set_location_assignment PIN_AA18 -to LT24Data[7]
set_location_assignment PIN_AA19 -to LT24Data[8]
set_location_assignment PIN_AE17 -to LT24Data[9]
set_location_assignment PIN_AC20 -to LT24Data[10]
set_location_assignment PIN_AH19 -to LT24Data[11]
set_location_assignment PIN_AJ20 -to LT24Data[12]
set_location_assignment PIN_AH20 -to LT24Data[13]
set_location_assignment PIN_AK21 -to LT24Data[14]
set_location_assignment PIN_AD19 -to LT24Data[15]
set_location_assignment PIN_AG20 -to LT24Reset_n
set_location_assignment PIN_AG16 -to LT24RS
set_location_assignment PIN_AD20 -to LT24CS_n
set_location_assignment PIN_AH18 -to LT24Rd_n
set_location_assignment PIN_AH17 -to LT24Wr_n
set_location_assignment PIN_AJ21 -to LT24LCDOn

# Set pin location for Clock
set_location_assignment PIN_AA16 -to clock

# Set pin locations for HPS IO
set_location_assignment PIN_F18 -to hps_io_hps_io_sdio_inst_CMD
set_location_assignment PIN_G18 -to hps_io_hps_io_sdio_inst_D0
set_location_assignment PIN_C17 -to hps_io_hps_io_sdio_inst_D1
set_location_assignment PIN_A16 -to hps_io_hps_io_sdio_inst_CLK
set_location_assignment PIN_D17 -to hps_io_hps_io_sdio_inst_D2
set_location_assignment PIN_B16 -to hps_io_hps_io_sdio_inst_D3
set_location_assignment PIN_B25 -to hps_io_hps_io_gpio_inst_LOANIO49
set_location_assignment PIN_C25 -to hps_io_hps_io_gpio_inst_LOANIO50
set_location_assignment PIN_C24 -to hps_io_hps_io_i2c0_inst_SDA
set_location_assignment PIN_E23 -to hps_io_hps_io_i2c0_inst_SCL
set_location_assignment PIN_B26 -to hps_io_hps_io_gpio_inst_GPIO48
set_location_assignment PIN_A24 -to hps_io_hps_io_gpio_inst_GPIO53
set_location_assignment PIN_G21 -to hps_io_hps_io_gpio_inst_GPIO54

# Set pin locations for HPS Memory
set_location_assignment PIN_F26 -to memory_mem_a[0]
set_location_assignment PIN_G30 -to memory_mem_a[1]
set_location_assignment PIN_F28 -to memory_mem_a[2]
set_location_assignment PIN_F30 -to memory_mem_a[3]
set_location_assignment PIN_J25 -to memory_mem_a[4]
set_location_assignment PIN_J27 -to memory_mem_a[5]
set_location_assignment PIN_F29 -to memory_mem_a[6]
set_location_assignment PIN_E28 -to memory_mem_a[7]
set_location_assignment PIN_H27 -to memory_mem_a[8]
set_location_assignment PIN_G26 -to memory_mem_a[9]
set_location_assignment PIN_D29 -to memory_mem_a[10]
set_location_assignment PIN_C30 -to memory_mem_a[11]
set_location_assignment PIN_B30 -to memory_mem_a[12]
set_location_assignment PIN_C29 -to memory_mem_a[13]
set_location_assignment PIN_H25 -to memory_mem_a[14]
set_location_assignment PIN_E29 -to memory_mem_ba[0]
set_location_assignment PIN_J24 -to memory_mem_ba[1]
set_location_assignment PIN_J23 -to memory_mem_ba[2]
set_location_assignment PIN_M23 -to memory_mem_ck
set_location_assignment PIN_L23 -to memory_mem_ck_n
set_location_assignment PIN_L29 -to memory_mem_cke
set_location_assignment PIN_H24 -to memory_mem_cs_n
set_location_assignment PIN_D30 -to memory_mem_ras_n
set_location_assignment PIN_E27 -to memory_mem_cas_n
set_location_assignment PIN_C28 -to memory_mem_we_n
set_location_assignment PIN_P30 -to memory_mem_reset_n
set_location_assignment PIN_K23 -to memory_mem_dq[0]
set_location_assignment PIN_K22 -to memory_mem_dq[1]
set_location_assignment PIN_H30 -to memory_mem_dq[2]
set_location_assignment PIN_G28 -to memory_mem_dq[3]
set_location_assignment PIN_L25 -to memory_mem_dq[4]
set_location_assignment PIN_L24 -to memory_mem_dq[5]
set_location_assignment PIN_J30 -to memory_mem_dq[6]
set_location_assignment PIN_J29 -to memory_mem_dq[7]
set_location_assignment PIN_K26 -to memory_mem_dq[8]
set_location_assignment PIN_L26 -to memory_mem_dq[9]
set_location_assignment PIN_K29 -to memory_mem_dq[10]
set_location_assignment PIN_K27 -to memory_mem_dq[11]
set_location_assignment PIN_M26 -to memory_mem_dq[12]
set_location_assignment PIN_M27 -to memory_mem_dq[13]
set_location_assignment PIN_L28 -to memory_mem_dq[14]
set_location_assignment PIN_M30 -to memory_mem_dq[15]
set_location_assignment PIN_U26 -to memory_mem_dq[16]
set_location_assignment PIN_T26 -to memory_mem_dq[17]
set_location_assignment PIN_N29 -to memory_mem_dq[18]
set_location_assignment PIN_N28 -to memory_mem_dq[19]
set_location_assignment PIN_P26 -to memory_mem_dq[20]
set_location_assignment PIN_P27 -to memory_mem_dq[21]
set_location_assignment PIN_N27 -to memory_mem_dq[22]
set_location_assignment PIN_R29 -to memory_mem_dq[23]
set_location_assignment PIN_P24 -to memory_mem_dq[24]
set_location_assignment PIN_P25 -to memory_mem_dq[25]
set_location_assignment PIN_T29 -to memory_mem_dq[26]
set_location_assignment PIN_T28 -to memory_mem_dq[27]
set_location_assignment PIN_R27 -to memory_mem_dq[28]
set_location_assignment PIN_R26 -to memory_mem_dq[29]
set_location_assignment PIN_V30 -to memory_mem_dq[30]
set_location_assignment PIN_W29 -to memory_mem_dq[31]
set_location_assignment PIN_N18 -to memory_mem_dqs[0]
set_location_assignment PIN_N25 -to memory_mem_dqs[1]
set_location_assignment PIN_R19 -to memory_mem_dqs[2]
set_location_assignment PIN_R22 -to memory_mem_dqs[3]
set_location_assignment PIN_M19 -to memory_mem_dqs_n[0]
set_location_assignment PIN_N24 -to memory_mem_dqs_n[1]
set_location_assignment PIN_R18 -to memory_mem_dqs_n[2]
set_location_assignment PIN_R21 -to memory_mem_dqs_n[3]
set_location_assignment PIN_H28 -to memory_mem_odt
set_location_assignment PIN_K28 -to memory_mem_dm[0]
set_location_assignment PIN_M28 -to memory_mem_dm[1]
set_location_assignment PIN_R28 -to memory_mem_dm[2]
set_location_assignment PIN_W30 -to memory_mem_dm[3]
set_location_assignment PIN_D27 -to memory_oct_rzqin

# Set IO parameters for HPS Memory
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_oct_rzqin -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[4] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[4] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[4] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[5] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[5] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[5] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[6] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[6] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[6] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[7] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[7] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[7] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[8] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[8] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[8] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[9] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[9] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[9] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[10] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[10] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[10] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[11] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[11] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[11] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[12] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[12] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[12] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[13] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[13] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[13] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[14] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[14] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[14] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[15] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[15] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[15] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[16] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[16] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[16] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[17] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[17] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[17] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[18] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[18] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[18] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[19] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[19] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[19] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[20] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[20] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[20] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[21] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[21] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[21] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[22] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[22] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[22] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[23] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[23] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[23] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[24] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[24] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[24] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[25] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[25] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[25] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[26] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[26] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[26] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[27] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[27] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[27] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[28] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[28] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[28] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[29] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[29] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[29] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[30] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[30] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[30] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[31] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[31] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[31] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_ck -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to memory_mem_ck -tag __hps_sdram_p0
set_instance_assignment -name D5_DELAY 2 -to memory_mem_ck -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_ck_n -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to memory_mem_ck_n -tag __hps_sdram_p0
set_instance_assignment -name D5_DELAY 2 -to memory_mem_ck_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[0] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[10] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[10] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[11] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[11] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[12] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[12] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[13] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[13] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[14] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[14] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[1] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[2] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[3] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[3] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[4] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[4] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[5] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[5] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[6] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[6] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[7] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[7] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[8] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[8] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[9] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[9] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[0] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[1] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[2] -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cas_n -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cas_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cke -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cke -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cs_n -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cs_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_odt -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_odt -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ras_n -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ras_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_we_n -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_we_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_reset_n -tag __hps_sdram_p0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_reset_n -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[0] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[0] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[1] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[1] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[2] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[2] -tag __hps_sdram_p0
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[3] -tag __hps_sdram_p0
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[4] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[5] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[6] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[7] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[8] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[9] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[10] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[11] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[12] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[13] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[14] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[15] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[16] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[17] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[18] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[19] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[20] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[21] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[22] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[23] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[24] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[25] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[26] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[27] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[28] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[29] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[30] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[31] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[10] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[11] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[12] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[13] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[14] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[3] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[4] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[5] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[6] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[7] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[8] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[9] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[0] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[1] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[2] -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cas_n -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cke -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cs_n -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_odt -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ras_n -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_we_n -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_reset_n -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ck -tag __hps_sdram_p0
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ck_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_mem_stable_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[0].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[1].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[2].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[3].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[3] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[3] -tag __hps_sdram_p0
set_instance_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION_FOR_NON_GLOBAL_CLOCKS ON -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst -tag __hps_sdram_p0
set_instance_assignment -name PLL_COMPENSATION_MODE DIRECT -to hps_system|hps_qsys_system|arm_hps|hps_io|border|hps_sdram_inst|pll0|fbout -tag __hps_sdram_p0


# Commit assignments
export_assignments
   