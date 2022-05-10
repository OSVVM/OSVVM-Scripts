#  File Name:         VendorScripts_RivieraPro.tcl
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
#     5/2022   2022.05    Coverage report name based on TestCaseName rather than LibraryUnit
#     2/2022   2022.02    Added Coverage Collection
#    12/2021   2021.12    Updated to use relative paths.
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
  variable ToolVendor  "Aldec"
  variable simulator   "RivieraPRO"
  #  Could differentiate between RivieraPRO and VSimSA
  variable ToolNameVersion ${simulator}-[asimVersion]
  puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  transcript file ""
  echo transcript file $FileName
  transcript file $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript file -close $FileName
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#  set CoverageAnalyzeOptions "-coverage sbmec"
  set CoverageAnalyzeOptions "-coverage sbm"
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
#  set CoverageSimulateOptions "-acdb -acdb_cov sbmec -cc_all"
  set CoverageSimulateOptions "-acdb -acdb_cov sbm -cc_all"
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    echo vlib    ${PathAndLib}
         vlib    ${PathAndLib}
    after 1000
  }
  if {![file exists ./compile/${LibraryName}.epr]} {
    echo vmap    $LibraryName  ${PathAndLib}
         vmap    $LibraryName  ${PathAndLib}
  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {[file exists ${PathAndLib}]} {
    set ResolvedLib ${PathAndLib}
  } else {
    set ResolvedLib ${PathToLib}
  }
  echo vmap    $LibraryName  ${ResolvedLib}
       vmap    $LibraryName  ${ResolvedLib}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName OptionalCommands} {
  variable VhdlVersion
  variable CoverageAnalyzeEnable
  variable CoverageSimulateEnable
  
  # For now, do not use -dbg flag with coverage.   
  if {[info exists CoverageAnalyzeEnable] || [info exists CoverageSimulateEnable]} {
    echo vcom -${VhdlVersion} -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
#        vcom -${VhdlVersion} -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
    if { [catch {vcom -${VhdlVersion} -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}} Msg]} {
      error $Msg "analyze $FileName $OptionalCommands" 1
    } 
  } else {
    echo vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
#         vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
# Catch does not remove stdout.  exec hides stdout
    if { [catch {vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}} Msg]} {
      error $Msg "analyze $FileName $OptionalCommands" 1
    } 
  }
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
#  Untested branch for Verilog - will need adjustment
#  Untested branch for Verilog - will need adjustment
  echo vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}
#       vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}
  if { [catch {vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}} Msg]} {
    error $Msg "analyze $FileName $OptionalCommands" 1
  } 
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  quit -sim
  framework.documents.closeall -vhdl
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
  variable TestSuiteName
  variable TestCaseName

  puts "vsim {*}${OptionalCommands} -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} "
#        vsim {*}${OptionalCommands} -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit}  
    if { [catch {vsim {*}${OptionalCommands} -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit}} Msg]} {
      error $Msg "simulate $LibraryUnit $OptionalCommands" 1
    } 
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
  # User wave.do
  if {[file exists wave.do]} {
    do wave.do
  }
  # User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    source ${LibraryUnit}.tcl
  }
  # User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${simulator}.tcl]} {
    source ${LibraryUnit}_${simulator}.tcl
  }

  log -rec [env]/*
  run -all 
  
  # Save Coverage Information 
  if {[info exists CoverageSimulateEnable]} {
    acdb save -o ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseName}.acdb -testname ${TestCaseName}
  }
}

# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  acdb merge        -o ${CoverageFileBaseName}.acdb -i {*}[join [glob ${CoverageDirectory}/${TestSuiteName}/*.acdb] " -i "]
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} { 
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists ${CodeCovResultsDir}.html]} {
    file delete -force -- ${CodeCovResultsDir}.html
  }
  if {[file exists ${CodeCovResultsDir}_files]} {
    file delete -force -- ${CodeCovResultsDir}_files
  }
  acdb report -html -i ${CodeCoverageDirectory}/${TestSuiteName}.acdb -o ${CodeCovResultsDir}.html
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}
