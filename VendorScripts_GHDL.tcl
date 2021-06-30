#  File Name:         VendorScripts_GHDL.tcl
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
#     6/2021   2021.06    Updated to better handle return values from GHDL
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     9/2020   2020.09    Initial Version
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2020 - 2021 by SynthWorks Design Inc.  
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
  variable ToolType   "simulator"
  variable ToolVendor "GHDL"
  variable simulator  "GHDL"
  variable ghdl "ghdl"
  
  # required for mintty
  if {[file writable "/dev/pty0" ]} {
    variable console "/dev/pty0"
  } else {
    variable console {}
  }
  
  regexp {GHDL\s+\d+\.\d+\S*} [exec $ghdl --version] VersionString
  variable ToolNameVersion [regsub {\s+} $VersionString -]
  puts $ToolNameVersion

# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  variable GHDL_TRANSCRIPT_FILE
   
  if {[info exists GHDL_TRANSCRIPT_FILE]} {
    unset GHDL_TRANSCRIPT_FILE 
  }
  set GHDL_TRANSCRIPT_FILE $FileName
  puts "Transcript $GHDL_TRANSCRIPT_FILE" 
  exec echo "Start Time [clock format [clock seconds] -format %T]" > $GHDL_TRANSCRIPT_FILE
}

proc vendor_StopTranscript {FileName} {
  variable GHDL_TRANSCRIPT_FILE
   
#  unset GHDL_TRANSCRIPT_FILE 
  puts "Stop Transcript $GHDL_TRANSCRIPT_FILE" 
  exec echo "Stop Time [clock format [clock seconds] -format %T]" >> $GHDL_TRANSCRIPT_FILE
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  variable VHDL_WORKING_LIBRARY_PATH
#  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_TRANSCRIPT_FILE
   
#  set PathAndLib ${PathToLib}/${LibraryName}.lib
  set PathAndLib ${PathToLib}/[string tolower ${LibraryName}]/v08

  if {![file exists ${PathAndLib}]} {
    puts "creating library directory ${PathAndLib}" 
    file mkdir   ${PathAndLib}
  }
# # Add old path to resource library paths
#   if {[info exists VHDL_WORKING_LIBRARY_PATH]} {
#     if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}] == -1} {
# #      puts "set VHDL_RESOURCE_LIBRARY_PATHS [concat $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}]"
#       set VHDL_RESOURCE_LIBRARY_PATHS [concat $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}]
#     }
#   } else {
# #    puts "set VHDL_RESOURCE_LIBRARY_PATHS [list ]"
#     set VHDL_RESOURCE_LIBRARY_PATHS [list ]
#   }
# #  puts "VHDL Resource Library Paths:  ${VHDL_RESOURCE_LIBRARY_PATHS}"
  set VHDL_WORKING_LIBRARY_PATH  ${PathAndLib}
}

proc vendor_map {LibraryName PathToLib} {
  variable VHDL_WORKING_LIBRARY_PATH
  variable GHDL_TRANSCRIPT_FILE

  set PathAndLib ${PathToLib}/[string tolower ${LibraryName}].lib

  if {![file exists ${PathAndLib}]} {
    error "Map:  Creating library ${PathAndLib} since it does not exist.  "
    puts "creating library directory ${PathAndLib}" 
    file mkdir   ${PathAndLib}
  }
  set VHDL_WORKING_LIBRARY_PATH  ${PathAndLib}
}

proc get_tee {} {
  variable GHDL_TRANSCRIPT_FILE
  variable console
  set tee [list tee -a $GHDL_TRANSCRIPT_FILE]
  if {$console ne {}} {
    lappend tee $console
  }
  return $tee
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
  variable VhdlShortVersion
  variable ghdl 
  variable console
  variable VHDL_WORKING_LIBRARY_PATH
#  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_TRANSCRIPT_FILE
  variable DIR_LIB

#  puts "$ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${FileName}" 
#  eval exec $ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${FileName} | tee -a $GHDL_TRANSCRIPT_FILE $console
  exec echo "$ghdl -a --std=${VhdlShortVersion} -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${FileName}" | {*}[get_tee]
  eval exec $ghdl -a --std=${VhdlShortVersion} -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${FileName} |& {*}[get_tee]
}

proc vendor_analyze_verilog {LibraryName FileName} {
  variable GHDL_TRANSCRIPT_FILE

  puts "Analyzing verilog files not supported by GHDL" 
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # Do Nothing
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable VhdlShortVersion
  variable ghdl 
  variable console
  variable VHDL_WORKING_LIBRARY_PATH
#  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_TRANSCRIPT_FILE
  variable DIR_LIB

#  puts "$ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${LibraryUnit}" 
#  eval exec $ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${LibraryUnit} | tee -a $GHDL_TRANSCRIPT_FILE $console
  exec echo "$ghdl --elab-run --std=${VhdlShortVersion} --syn-binding --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${LibraryUnit}" | {*}[get_tee]
#  eval exec $ghdl --elab-run --std=${VhdlShortVersion} --syn-binding --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${LibraryUnit} |& {*}[get_tee]
  if { [catch {eval exec $ghdl --elab-run --std=${VhdlShortVersion} --syn-binding --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${LibraryUnit} |& {*}[get_tee]} SimErr]} { 
    puts "ghdl --elab-run ended with error $SimErr"
  }
}
