#  File Name:         VendorScripts_Xsim.tcl
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
  variable ToolVendor  "Xilinx"
  variable simulator   "XSIM"
  variable ToolNameVersion "xsim_21_1"
  puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
#  transcript file ""
#  puts transcript file $FileName
#  transcript file $FileName
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
#  set PathAndLib ${PathToLib}/${LibraryName}
#
#  if {![file exists ${PathAndLib}]} {
#    puts "file mkdir    ${PathAndLib}"
#    puts "" > ${PathAndLib}
#    eval file mkdir    ${PathAndLib}
#  }
#  if {![file exists ./compile/${LibraryName}.epr]} {
#    puts vmap    $LibraryName  ${PathAndLib}
#    eval vmap    $LibraryName  ${PathAndLib}
#  }
}

proc vendor_map {LibraryName PathToLib} {
#  set PathAndLib ${PathToLib}/${LibraryName}.lib
#
#  if {![file exists ${PathAndLib}]} {
#    error "Map:  Creating library ${PathAndLib} since it does not exist.  "
#    puts vlib    ${PathAndLib}
#    eval vlib    ${PathAndLib}
#  }
#  if {![file exists ./compile/${LibraryName}.epr]} {
#    puts vmap    $LibraryName  ${PathAndLib}
#    eval vmap    $LibraryName  ${PathAndLib}
#  }
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName OptionalCommands} {
  variable VhdlVersion
  variable DIR_LIB

# note if VhdlVersion /= 2008 then do not use --$Version  
# it supports --relax
# --log <log name>
# 
#  No library open, can specify it in the --work as --work ${LibraryName}=${DIR_LIB}/${LibraryName}
  puts "xvhdl --${VhdlVersion} --work ${LibraryName} ${FileName}"
#   exec xvhdl --${VhdlVersion} --work ${LibraryName} ${FileName}
   exec xvhdl --${VhdlVersion} --work ${LibraryName} ${FileName}
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
#  Untested branch for Verilog - will need adjustment
   puts "Verilog is not supported for now"
#   eval vlog -work ${LibraryName} ${FileName}
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
  variable CoverageSimulateEnable

  # removed $OptionalCommands
#  puts "xelab --timeprecision_vhdl 1${SIMULATE_TIME_UNITS} --mt off  ${LibraryName}.${LibraryUnit} --runall"
#  exec  xelab --timeprecision_vhdl 1${SIMULATE_TIME_UNITS} --mt off  ${LibraryName}.${LibraryUnit} --runall
  puts "xelab --timeprecision_vhdl 1${SIMULATE_TIME_UNITS} --mt off  ${LibraryName}.${LibraryUnit} --snapshot ${LibraryName}_${LibraryUnit}" 
  exec  xelab --timeprecision_vhdl 1${SIMULATE_TIME_UNITS} --mt off  ${LibraryName}.${LibraryUnit} --snapshot ${LibraryName}_${LibraryUnit} 
  puts "xsim  -runall ${LibraryName}_${LibraryUnit}" 
  exec  xsim  -runall ${LibraryName}_${LibraryUnit} 

#  ### Project level settings - in OsvvmLibraries/Scripts
#  # Project Vendor script
#  if {[file exists ${SCRIPT_DIR}/${ToolVendor}.tcl]} {
#    source ${SCRIPT_DIR}/${ToolVendor}.tcl
#  }
#  # Project Simulator Script
#  if {[file exists ${SCRIPT_DIR}/${simulator}.tcl]} {
#    source ${SCRIPT_DIR}/${simulator}.tcl
#  }
#
#  ### User level settings for simulator in the simulation run directory
#  # User Vendor script
#  if {[file exists ${ToolVendor}.tcl]} {
#    source ${ToolVendor}.tcl
#  }
#  # User Simulator Script
#  if {[file exists ${simulator}.tcl]} {
#    source ${simulator}.tcl
#  }
#  # User Testbench Script
#  if {[file exists ${LibraryUnit}.tcl]} {
#    source ${LibraryUnit}.tcl
#  }
#  # User Testbench + Simulator Script
#  if {[file exists ${LibraryUnit}_${simulator}.tcl]} {
#    source ${LibraryUnit}_${simulator}.tcl
#  }
#  # User wave.do
#  if {[file exists wave.do]} {
#    do wave.do
#  }
#
#  log -rec [env]/*
#  run -all 
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
