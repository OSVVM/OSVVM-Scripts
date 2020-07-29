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
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#     1/2020   2020.01    Updated Licenses to Apache
#     7/2020   2020.07    Refactored for simpler vendor customization
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  echo $::START_TRANSCRIPT $FileName
  eval $::START_TRANSCRIPT $FileName
}

proc vendor_StopTranscript {FileName} {
  # FileName used within the STOP_TRANSCRIPT variable if required
  echo $::STOP_TRANSCRIPT 
  eval $::STOP_TRANSCRIPT 
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName ResolvedPathToLib} {
  if {![file exists ${ResolvedPathToLib}]} {
    echo vlib    ${ResolvedPathToLib}
    vlib         ${ResolvedPathToLib}
  }
  echo vmap    $LibraryName  ${ResolvedPathToLib}
  vmap         $LibraryName  ${ResolvedPathToLib}
}

proc vendor_map {LibraryName ResolvedPathToLib} {
  if {![file exists ${ResolvedPathToLib}]} {
    error "Map:  Creating library ${ResolvedPathToLib} since it does not exist.  "
    echo vlib    ${ResolvedPathToLib}
    vlib         ${ResolvedPathToLib}
  }
  echo vmap    $LibraryName  ${ResolvedPathToLib}
  vmap         $LibraryName  ${ResolvedPathToLib}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
    echo $::VHDL_ANALYZE_COMMAND $::VHDL_ANALYZE_OPTIONS $::VHDL_ANALYZE_LIBRARY $::VHDL_WORKING_LIBRARY ${FileName}
    eval $::VHDL_ANALYZE_COMMAND $::VHDL_ANALYZE_OPTIONS $::VHDL_ANALYZE_LIBRARY $::VHDL_WORKING_LIBRARY ${FileName}
}

proc vendor_analyze_verilog {LibraryName FileName} {
#  Untested branch for Verilog - will need adjustment
    echo $::VERILOG_ANALYZE_COMMAND $::VERILOG_ANALYZE_OPTIONS $::VHDL_ANALYZE_LIBRARY $::VHDL_WORKING_LIBRARY ${FileName}
    eval $::VERILOG_ANALYZE_COMMAND $::VERILOG_ANALYZE_OPTIONS $::VHDL_ANALYZE_LIBRARY $::VHDL_WORKING_LIBRARY ${FileName}
}

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  echo $::SIMULATE_COMMAND $::SIMULATE_OPTIONS_FIRST $::SIMULATE_LIBRARY ${LibraryName} ${LibraryUnit} $OptionalCommands $::SIMULATE_OPTIONS_LAST
  eval $::SIMULATE_COMMAND $::SIMULATE_OPTIONS_FIRST $::SIMULATE_LIBRARY ${LibraryName} ${LibraryUnit} $OptionalCommands $::SIMULATE_OPTIONS_LAST
  
  if {[file exists ${LibraryUnit}.tcl]} {
    source ${LibraryUnit}.tcl
  }
  if {[file exists ${LibraryUnit}_$::simulator.tcl]} {
    source ${LibraryUnit}_$::simulator.tcl
  }

  echo $::SIMULATE_RUN
  eval $::SIMULATE_RUN
}