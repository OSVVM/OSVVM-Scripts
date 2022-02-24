#  File Name:         VendorScripts_VCS.tcl
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
#     2/2022   2022.02    Added template of procedures needed for coverage support
#    12/2021   2021.12    Updated to use relative paths.
#     9/2021   2021.09    Created from VendorScripts_xxx.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2022 by SynthWorks Design Inc.  
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
  variable ToolVendor  "Synopsys"
  variable simulator   "VCS"
  variable ToolNameVersion "R2020_12"
  puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  variable VENDOR_TRANSCRIPT_FILE
   
  if {[info exists VENDOR_TRANSCRIPT_FILE]} {
    unset VENDOR_TRANSCRIPT_FILE 
  }
  set VENDOR_TRANSCRIPT_FILE $FileName
  exec echo "Stop Time [clock format [clock seconds] -format %T]" >> $VENDOR_TRANSCRIPT_FILE
}

proc vendor_StopTranscript {FileName} {
#  transcript file -close $FileName
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#    set defaults here
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
#    set defaults here
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    puts "file mkdir    ${PathAndLib}"
          file mkdir    ${PathAndLib}/64
  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
#  set PathAndLib ${PathToLib}/${LibraryName}
#
#  if {![file exists ${PathAndLib}]} {
#    error "LinkLibrary: ${PathAndLib} does not exist."
#  }
}

# -------------------------------------------------
proc CreateToolSetup {} {
  variable LibraryList
  
  set SetupFile [open "synopsys_sim.setup" w]
  puts $SetupFile "ASSERT_STOP=FAILURE" 
  
  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lindex $item 1]
    puts $SetupFile "${LibraryName} : ${PathToLib}/${LibraryName}"
  }
  close $SetupFile
}


# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName OptionalCommands} {
  variable VhdlShortVersion
  variable DIR_LIB
  variable VENDOR_TRANSCRIPT_FILE

  CreateToolSetup

  exec echo "vhdlan -full64 -vhdl${VhdlShortVersion} -verbose -nc -work ${LibraryName} ${FileName}"
  exec       vhdlan -full64 -vhdl${VhdlShortVersion} -verbose -nc -work ${LibraryName} ${FileName} |& tee -a ${VENDOR_TRANSCRIPT_FILE}
#  exec       vhdlan -full64 -vhdl${VhdlShortVersion} -kdb -verbose -nc -work ${LibraryName} ${FileName} |& tee -a ${VENDOR_TRANSCRIPT_FILE}
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
#  Untested branch for Verilog - will need adjustment
   puts "Verilog is not supported for now"
#        vlog -work ${LibraryName} ${FileName}
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
#  quit -sim
#  framework.documents.closeall -vhdl
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable SCRIPT_DIR
  variable SIMULATE_TIME_UNITS
  variable ToolVendor
  variable simulator
  variable VENDOR_TRANSCRIPT_FILE
  variable CoverageSimulateEnable

  CreateToolSetup

  # Building the Synopsys_run.tcl Script
  set SynFile [open "temp_Synopsys_run.tcl" w]

  # Project Vendor script
  if {[file exists ${SCRIPT_DIR}/${ToolVendor}.tcl]} {
    puts  $SynFile "source ${SCRIPT_DIR}/${ToolVendor}.tcl"
  }
# Project Simulator Script
  if {[file exists ${SCRIPT_DIR}/${simulator}.tcl]} {
    puts  $SynFile "source ${SCRIPT_DIR}/${simulator}.tcl"
  }
 
### User level settings for simulator in the simulation run directory
# User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    puts  $SynFile "source ${ToolVendor}.tcl"
  }
# User Simulator Script
  if {[file exists ${simulator}.tcl]} {
    puts  $SynFile "source ${simulator}.tcl"
  }
# User wave.do
  if {[file exists wave.do]} {
    puts  $SynFile "do wave.do"
  }
# User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}.tcl"
  }
# User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${simulator}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}_${simulator}.tcl"
  }
  puts  $SynFile "run" 
  
  # Save Coverage Information
  if {[info exists CoverageSimulateEnable]} {
#   puts $RunFile "Save Coverage Information Command Goes here"
  }
  
  puts  $SynFile "quit" 
  close $SynFile

  # removed $OptionalCommands
#  puts "exec vcs -full64 -a ${VENDOR_TRANSCRIPT_FILE} -R -sim_res=${SIMULATE_TIME_UNITS} +vhdllib+${LibraryName} ${LibraryUnit}"
# caution there is a performance impact of -debug_access+all
  puts      "vcs -full64 -time $SIMULATE_TIME_UNITS -debug_access+all ${LibraryName}.${LibraryUnit}"
  eval  exec vcs -full64 -time $SIMULATE_TIME_UNITS -debug_access+all ${LibraryName}.${LibraryUnit} |& tee -a ${VENDOR_TRANSCRIPT_FILE} 
#  eval  exec vcs -full64 -kdb -time $SIMULATE_TIME_UNITS -debug_access+all ${LibraryName}.${LibraryUnit} |& tee -a ${VENDOR_TRANSCRIPT_FILE} 
  puts "./simv -ucli -do temp_Synopsys_run.tcl"
  exec  ./simv -ucli -do temp_Synopsys_run.tcl |& tee -a ${VENDOR_TRANSCRIPT_FILE} 
}

# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
#  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
#  acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join [glob ${CoverageDirectory}/${TestSuiteName}/*.acdb] " -i "]
}

proc vendor_ReportCodeCoverage {TestSuiteName ResultsDirectory} { 
#  acdb report -html -i ${ResultsDirectory}/${TestSuiteName}.acdb -o ${ResultsDirectory}/${TestSuiteName}_code_cov.html
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}
