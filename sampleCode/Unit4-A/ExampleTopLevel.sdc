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
# We start by defining our clock. We will call it clock50
# it has a period of 50MHz, and it comes from  the top level
# port named "clock"
create_clock -name clock50 -period "50MHz" [get_ports clock]

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
# in the clock due to internal jitters, etc.
derive_clock_uncertainty

#**************************************************************
# Set Output Delay Requirements
#**************************************************************
# Now we constrain the outputs. This is to tell Quartus what
# the maximum skew we can tolerate is before the parallel bus
# stops functioning. In this case we will say a nominal 4ns
# either side of the clock for all ports named LT24* where
# the * is a wildcard meaning anything.
#set_output_delay -max  4 -clock clock50 [get_ports LT24* ]
#set_output_delay -min -4 -clock clock50 [get_ports LT24* ]
