#
# NativeLink Simulation Initialisation Script
# ===========================================
# By: Thomas Carpenter
# Date: 31st December 2017
# For: University of Leeds
#
# Description
# ===========
# This is a basic sample script for initialising a simulation
#
# All commands in this script will be executed, and comments will
# be printed to the screen
#
# Most of the work in compiling is done by Quartus automatically.
# Here we can add some extra commands.
#
# There is lots of stuff you can do, such as running initialisation
# scripts, preparing memory contents, setting up the simulator.
#

#
# First lets clean up any old NativeLink backup files. Quartus
# creates a new backup file every time it runs. It never deletes
# these files so you end up with an ever increasing number of them.
#
# The {*}[glob -nocomplain ... ] command performs wildcard matching
# of filenames, to make sure we get all .bak files. The "-nocomplain"
# and "catch {}" ensure that if no backups exist, there is no error.
#

catch {file delete {*}[glob -nocomplain *_msim_rtl_verilog.do.bak*]}

#
# This will continue executing our script if a break point in the
# simulation is reached - for example the $stop command in Verilog
#

onbreak {resume}

# 
# Once you add signals to the Wave view to see them graphically
# and got them all set up to your liking (Radix, arrangement, etc.)
# it is possible to save that layout as a "Waveform Format Do File".
# From modelsim if you click on the Wave window and File->Save Format
# this will generate the "Do" file for you.
#
# I will assume that you saved the file with name "wave.do" (default)
# in the simulation folder (same place as this TCL).
#
# Each time we run the simulation, we can run this file to restore 
# the setup:
#
#   do <filename>
#
# Of course the first time you run the simulation the file might not
# yet exist - you might never choose to save a format. So we also
# first check if the file exists before do-ing it.
# 

# We normalise the filename to prevent issues with spaces in the filename
set waveFile [file normalize "./wave.do"]

if { [file exists $waveFile] } {
    #If the saved file exists, load it
    do $waveFile
} else {
    #Otherwise simply add all signals in the testbench formatted as unsigned decimal.
    add wave -radix unsigned -position insertpoint sim:/*
}

#
# Then we can configure the units for the timeline. Lets stick to
# nanoseconds instead of the default of picoseconds.
#

configure wave -timelineunits ns

# 
# Next we can start the simulation. We simply say "run".
#
# The "run" command can be followed by a time parameter, such as:
#
#     run 100ns     # Run for 100ns
#     run -all      # Run until the testbench stops changing stimuli
#     run 10        # Run for 10 "timesteps" (typically 1ps per step)
#
# ========== Simulation Starts Here ===========

run -all

# ========== Simulation Ends Here ===========
#
# Once the simulation finishes we will reach here
#
# Let's for example zoom out in the wave display to fit all data
#

wave zoom full
