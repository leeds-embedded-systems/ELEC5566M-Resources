#
# The purpose of this file is to tell Quartus what the timing
# requirements of the design are so that it can try to make
# sure the design can run as fast as we require without any
# glitches caused by propagation delays, etc.
#
# When you run the TimeQuest step in the compilation, it will
# use this file to determine whether or not the design has met
# timing (i.e. can run fast enough), and if not it will report
# information on the failing parts of the design.
#

#**************************************************************
# Create Clock
#**************************************************************
# We start by defining our clocks. For example we could call it
# clock50 and give a period of 50MHz, and say it comes from a
# top level port named "clock". This would be declared as:
#
# create_clock -name clock50 -period "50MHz" [get_ports clock]
#

# There are no clocks in this sample design

#**************************************************************
# Create Generated Clock
#**************************************************************
# There are no PLLs in our design, but it is good practice to
# have Quartus check for any clocks generated from a PLL.

derive_pll_clocks

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
# This is an internal command to derive any default uncertainty
# in clocks and routing due to internal jitters, etc.

derive_clock_uncertainty

#**************************************************************
# Set Output Delay Requirements
#**************************************************************
# Now we constrain the outputs. This is to tell Quartus what
# the maximum skew we can tolerate is before the parallel bus
# stops functioning. For example we could say a nominal 4ns
# either side of the clock for all ports named LT24_* where
# the * is a wildcard meaning anything.
#
# set_output_delay -max  4 -clock clock50 [get_ports LT24_* ]
# set_output_delay -min -4 -clock clock50 [get_ports LT24_* ]
#

# For this sample design we have no clocks, so no output delay
# requirements needed.
