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
  variable simulator   "ActiveHDL"
  variable ToolNameVersion ${simulator}-${version}
  puts $ToolNameVersion
  # Allow variable OSVVM library to be updated
  setlibrarymode -rw osvvm


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
  variable vendor_simulate_started
  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set MY_START_DIR [pwd]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    echo design create -a  $LibraryName ${PathToLib}
    design create -a  $LibraryName ${PathToLib}
  }
  echo design open -a  ${PathAndLib}
  design open -a  ${PathAndLib}
  design activate $LibraryName
  cd ${PathAndLib}
  if {![file exists results]} {
    file link -symbolic results ${MY_START_DIR}/results  
  }
  cd $MY_START_DIR
}


proc vendor_map {LibraryName ResolvedPathToLib} {
  variable vendor_simulate_started
  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set MY_START_DIR [pwd]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    error "Map:  Creating library ${ResolvedPathToLib} since it does not exist.  "
    echo design create -a  $LibraryName ${PathToLib}
    design create -a  $LibraryName ${PathToLib}
  }
  echo design open -a  ${PathAndLib}
  design open -a  ${PathAndLib}
  
  design activate $LibraryName
  cd $MY_START_DIR
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
  variable VhdlVersion
  variable DIR_LIB
  
  set MY_START_DIR [pwd]
  set FileBaseName [file rootname [file tail $FileName]]
  
  # Check src to see if it has been added
  if {![file isfile ${DIR_LIB}/$LibraryName/src/${FileBaseName}.vcom]} {
    echo addfile ${FileName}
    addfile ${FileName}
    filevhdloptions -${VhdlVersion} ${FileName}
  }
  # Compile it.
  echo vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} ${FileName} 
  echo vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} ${FileName} > ${DIR_LIB}/$LibraryName/src/${FileBaseName}.vcom
  eval vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} ${FileName}
  
  cd $MY_START_DIR
}

proc vendor_analyze_verilog {LibraryName FileName} {
  set MY_START_DIR [pwd]

#  Untested branch for Verilog - will need adjustment
#  Untested branch for Verilog - will need adjustment
    echo vlog -work ${LibraryName} ${FileName}
    eval vlog -work ${LibraryName} ${FileName}
  cd $MY_START_DIR
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

  set MY_START_DIR [pwd]
  
  puts "vsim -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands}" 
  eval vsim -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} 
  
  # ActiveHDL changes the directory, so change it back to the OSVVM run directory
  cd $MY_START_DIR
  
  ### Project level settings - in OsvvmLibraries/Scripts
  # Project Vendor script
  if {[file exists ${SCRIPT_DIR}/${ToolVendor}.tcl]} {
    source ${SCRIPT_DIR}/${ToolVendor}.tcl
    cd $MY_START_DIR
  }
  # Project Simulator Script
  if {[file exists ${SCRIPT_DIR}/${simulator}.tcl]} {
    source ${SCRIPT_DIR}/${simulator}.tcl
    cd $MY_START_DIR
  }

  ### User level settings for simulator in the simulation run directory
  # User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    source ${ToolVendor}.tcl
    cd $MY_START_DIR
  }
  # User Simulator Script
  if {[file exists ${simulator}.tcl]} {
    source ${simulator}.tcl
    cd $MY_START_DIR
  }
  # User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    source ${LibraryUnit}.tcl
    cd $MY_START_DIR
  }
  # User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${simulator}.tcl]} {
    source ${LibraryUnit}_${simulator}.tcl
    cd $MY_START_DIR
  }
  # User wave.do
  if {[file exists wave.do]} {
    do wave.do
    cd $MY_START_DIR
  }

  log -rec [env]/*
  run -all 
  cd $MY_START_DIR
}
