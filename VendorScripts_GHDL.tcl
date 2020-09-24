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
#     9/2020   2020.09    Initial Version
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
  global GHDL_TRANSCIPT_FILE
   
  if {[info exists GHDL_TRANSCIPT_FILE]} {
    unset GHDL_TRANSCIPT_FILE 
  }
  set GHDL_TRANSCIPT_FILE $FileName
  puts "Transcript $GHDL_TRANSCIPT_FILE" 
}

proc vendor_StopTranscript {FileName} {
  global GHDL_TRANSCIPT_FILE
   
#  unset GHDL_TRANSCIPT_FILE 
  puts "Stop Transcript $GHDL_TRANSCIPT_FILE" 
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  global VHDL_WORKING_LIBRARY_PATH
  global VHDL_RESOURCE_LIBRARY_PATHS
  global GHDL_TRANSCIPT_FILE
   
#  set PathAndLib ${PathToLib}/${LibraryName}.lib
  set PathAndLib ${PathToLib}/${LibraryName}/v08

  if {![file exists ${PathAndLib}]} {
    puts "creating library directory ${PathAndLib}" 
    file mkdir   ${PathAndLib}
  }
# Add old path to resource library paths
  if {[info exists VHDL_WORKING_LIBRARY_PATH]} {
    if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}] == -1} {
#      puts "set VHDL_RESOURCE_LIBRARY_PATHS [concat $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}]"
      set VHDL_RESOURCE_LIBRARY_PATHS [concat $VHDL_RESOURCE_LIBRARY_PATHS -P${VHDL_WORKING_LIBRARY_PATH}]
    }
  } else {
#    puts "set VHDL_RESOURCE_LIBRARY_PATHS [list ]"
    set VHDL_RESOURCE_LIBRARY_PATHS [list ]
  }
#  puts "VHDL Resource Library Paths:  ${VHDL_RESOURCE_LIBRARY_PATHS}"
  set VHDL_WORKING_LIBRARY_PATH  ${PathAndLib}
}

proc vendor_map {LibraryName PathToLib} {
  global VHDL_WORKING_LIBRARY_PATH
  global GHDL_TRANSCIPT_FILE

  set PathAndLib ${PathToLib}/${LibraryName}.lib

  if {![file exists ${PathAndLib}]} {
    error "Map:  Creating library ${PathAndLib} since it does not exist.  "
    puts "creating library directory ${PathAndLib}" | tee -a $GHDL_TRANSCIPT_FILE
    file mkdir   ${PathAndLib}
  }
  set VHDL_WORKING_LIBRARY_PATH  ${PathAndLib}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName} {
  global ghdl console
  global VHDL_WORKING_LIBRARY_PATH
  global VHDL_RESOURCE_LIBRARY_PATHS
  global GHDL_TRANSCIPT_FILE
  global DIR_LIB

#  puts "$ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${FileName}" 
#  eval exec $ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${FileName} | tee -a $GHDL_TRANSCIPT_FILE $console
  puts "$ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${FileName}" 
  eval exec $ghdl -a --std=08 -Wno-hide --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${FileName} | tee -a $GHDL_TRANSCIPT_FILE $console
}

proc vendor_analyze_verilog {LibraryName FileName} {
  global GHDL_TRANSCIPT_FILE

  puts "Analyzing verilog files not supported by GHDL" 
}

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  global ghdl console
  global VHDL_WORKING_LIBRARY_PATH
  global VHDL_RESOURCE_LIBRARY_PATHS
  global GHDL_TRANSCIPT_FILE
  global DIR_LIB

#  puts "$ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${LibraryUnit}" 
#  eval exec $ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} ${LibraryUnit} | tee -a $GHDL_TRANSCIPT_FILE $console
  puts "$ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${LibraryUnit}" 
  eval exec $ghdl --elab-run --std=08 --work=${LibraryName} --workdir=${VHDL_WORKING_LIBRARY_PATH} -P${DIR_LIB} ${LibraryUnit} | tee -a $GHDL_TRANSCIPT_FILE $console

}