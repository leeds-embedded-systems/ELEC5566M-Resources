
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

# Commit assignments
export_assignments
