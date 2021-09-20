#  File Name:         VendorScripts_Mentor.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Tcl procedures with the intent of making running 
#    compiling and simulations tool independent
#    
#  Developed by: 
#        SynthWorks Design Inc. 
#        VHDL Training Classes
#        OSVVM Methodology and Model Library
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
# 
#  Revision History:
#    Date      Version    Description
#     3/2021   2021.03    In Simulate, added optional scripts to run as part of simulate
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "simulator"
  variable ToolVendor  "Aldec"
  variable simulator   "VSimSA"
  variable ToolNameVersion ${simulator}-[lindex [split $version] [llength $version]-1]
  puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  transcript off
  echo transcript to $FileName
  transcript to $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript off
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}.lib

  if {![file exists ${PathAndLib}]} {
    echo vlib    ${PathAndLib}
    eval vlib    ${PathAndLib}
  }
  echo vmap    $LibraryName  ${PathAndLib}
  eval vmap    $LibraryName  ${PathAndLib}
}

proc vendor_map {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}.lib

  if {![file exists ${PathAndLib}]} {
    error "Map:  Creating library ${PathAndLib} since it does not exist.  "
    echo vlib    ${PathAndLib}
    eval vlib    ${PathAndLib}
  }
  echo vmap    $LibraryName  ${PathAndLib}
  eval vmap    $LibraryName  ${PathAndLib}
}


# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
  variable VhdlVersion
  echo vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} ${FileName}
  eval vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} ${FileName}
}

proc vendor_analyze_verilog {LibraryName FileName} {
#  Untested branch for Verilog - will need adjustment
  echo vlog -work ${LibraryName} ${FileName}
  eval vlog -work ${LibraryName} ${FileName}
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  endsim
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable SCRIPT_DIR
  variable SIMULATE_TIME_UNITS
  variable ToolVendor
  variable simulator

  puts "vsim -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands}"
  eval vsim -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} 
  
  ### Project level settings - in OsvvmLibraries/Scripts
  # Project Vendor script
  if {[file exists ${SCRIPT_DIR}/${ToolVendor}.tcl]} {
    source ${SCRIPT_DIR}/${ToolVendor}.tcl
  }
  # Project Simulator Script
  if {[file exists ${SCRIPT_DIR}/${simulator}.tcl]} {
    source ${SCRIPT_DIR}/${simulator}.tcl
  }

  ### User level settings for simulator in the simulation run directory
  # User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    source ${ToolVendor}.tcl
  }
  # User Simulator Script
  if {[file exists ${simulator}.tcl]} {
    source ${simulator}.tcl
  }
  # User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    source ${LibraryUnit}.tcl
  }
  # User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${simulator}.tcl]} {
    source ${LibraryUnit}_${simulator}.tcl
  }

#  add log -r /*
  run -all 
}
