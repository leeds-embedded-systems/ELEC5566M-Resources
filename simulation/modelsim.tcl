#
# ModelSim Initialisation Script
# ==============================
# By: Thomas Carpenter
# Date: 31st December 2017
# For: University of Leeds
#
# Description
# ===========
# This is a script for configuring the behaviour of ModelSim.
#
# All commands in this script will be executed, and comments will
# be printed to the screen.
#

# This creates a new process called external_editor which loads Notepad++ at the correct line for any error messages
proc external_editor {filename linenumber} { exec C:/Program\ Files\ (x86)/Notepad++/notepad++.exe -n$linenumber $filename }

# This tells ModelSim that we should use the external_editor function when openning files
set PrefSource(altEditor) external_editor

# NOTE: The PrefSource(altEditor) is persistant (it will remain even after you close ModelSim.
# However, the external_editor process is not persistant. It must be redefined each time we
# load ModelSim, hence you must have this file in the simulation directory.
#
# If you want to switch back to the default internal editor, you can run the following command
# in ModelSim:
#
# unset PrefSource(altEditor)
#
