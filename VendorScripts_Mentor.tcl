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
  variable ToolVendor  "Siemens"
  if {[lindex [split [vsim -version]] 0] eq "Questa"} {
    variable simulator   "QuestaSim"
  } else {
    variable simulator   "ModelSim"
  }
  variable ToolNameVersion ${simulator}-[vsimVersion]
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
  # FileName not used here
  transcript file ""
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#  set CoverageAnalyzeOptions "+cover=bcesft"
  set CoverageAnalyzeOptions "+cover=bsf"
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
  set CoverageSimulateOptions "-coverage"
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    puts "vlib   ${PathAndLib} "
          vlib   ${PathAndLib}
  }
  puts "vmap   $LibraryName  ${PathAndLib}"
        vmap   $LibraryName  ${PathAndLib}
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
  puts "vcom -${VhdlVersion} -work ${LibraryName} {*}${OptionalCommands} ${FileName} "
        vcom -${VhdlVersion} -work ${LibraryName} {*}${OptionalCommands} ${FileName}
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
#  Untested branch for Verilog - will need adjustment
#  Untested branch for Verilog - will need adjustment
  puts "vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName} "
        vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  global SourceMap

  # close junk in source window
  foreach index [array names SourceMap] { 
    noview source [file tail $index] 
  }
  
  quit -sim
}

# -------------------------------------------------
# vendor_simulate
#
# Note about ignored vsim warnings:
# OSVVM ignores the following errors in the call to vsim.  
#   They are QuestaSim alerting use to potential issues with port drivers.
#   Below we explain why they are not an issue for OSVVM verification components.
#   We ignore them only because they slow QuestaSim down to a crawl.
#
# Detailed analysis follows.   
#
# Using "verror 8683", QuestaSim produces the following explaination:
# vsim Message # 8683:
# An output port has no default expression in its declaration and has no
# drivers.  The VHDL LRM-compliant value it propagates to higher-level
# connected signals may not be what is desired.  In particular, this
# behavior might not correspond to the synthesis view of initialization.
# The vsim switch "-defaultstdlogicinittoz" or "-forcestdlogicinittoz"
# may be useful in this situation.
#
# OSVVM Verification Components use resolution functions that use  
#    minimum as a resolution function.  Hence, driving the default 
#    value (type'left) on a signal has no negative impact.
#    Hence, we disable this warning since it does not apply and
#    it slows Questasim down significantly
#
#
# Using "verror 8684", QuestaSim produces the following explaination:
# vsim Message # 8684:
# An output port having no drivers has been combined with a higher-level
# connected signal.  The port will get its initial value from this
# higher-level connected signal; this is not compliant with the behavior
# required by the VHDL LRM.
# LRM compliant behavior would require the port's initial value come from its
# declaration, however since it was combined or collapsed with the port or signal
# higher in the hierarchy, the initial value came from that port or signal.
# LRM compliant behavior can be obtained by preventing the collapsing of these
# ports with the vsim switch -donotcollapsepartiallydriven.
# If the port is collapsed to a port or signal with the same initialization (as
# is often the case of default initializations being applied), there is no
# problem and the proper initialization is done and the simulation is LRM
# compliant.
#
# Older OSVVM Verification Components initialize port values to 'Z'.  
#    QuestaSim in what is non-VHDL compliant behavior, ignore this.
#    If you are using older OSVVM verification component interfaces, 
#    make sure to initialize the transaction record in the test harness 
#    to all 'Z'.  This avoids any negative impact of the QuestaSim
#    non-VHDL compliant behavior.  
#    Hence, we disable this warning since if you use older OSVVM interfaces
#    and you initialize teh test harness signal also, then this 
#    does not apply and it slows Questasim down significantly
#
# OSVVM recommends that you migragate older interfaces to the newer 
#    that uses types and resolution functions defined in ResolutionPkg 
#    such as std_logic_max, std_logic_vector_max, or std_logic_vector_max_c 
#    rather than std_logic or std_logic_vector.   
#    ResolutionPkg supports a richer set of types, such as integer_max, real_max, ...
#    Note these then will still generate message 8683.
#
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable SCRIPT_DIR
  variable SIMULATE_TIME_UNITS
  variable ToolVendor
  variable simulator
  variable CoverageSimulateEnable
  variable TestSuiteName
  variable TestCaseName

  puts "vsim -voptargs='+acc' -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} -suppress 8683 -suppress 8684"
#  eval vsim -voptargs="+acc" -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} -suppress 8683 -suppress 8684 
  eval vsim -voptargs="+acc" -t $SIMULATE_TIME_UNITS -lib ${LibraryName} ${LibraryUnit} ${OptionalCommands} -suppress 8683 -suppress 8684

  
  ### Project level settings - in OsvvmLibraries/Scripts
  # Historical name.  Must be run with "do" for actions to work
  if {[file exists ${SCRIPT_DIR}/Mentor.do]} {
    do ${SCRIPT_DIR}/Mentor.do
  }
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
  
  # Removed.  Desirable, but causes crashes if no signals in testbench.
#  add log -r [env]/*
#  run 1 ns 
  run -all 
  
  if {[info exists CoverageSimulateEnable]} {
    coverage save ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseName}.ucdb 
  }
}

# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  vcover merge ${CoverageFileBaseName}.ucdb {*}[glob ${CoverageDirectory}/${TestSuiteName}/*.ucdb]
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} { 
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists $CodeCovResultsDir]} {
    file delete -force -- $CodeCovResultsDir
  }
  vcover report -html -annotate -details -verbose -output ${CodeCovResultsDir} ${CodeCoverageDirectory}/${TestSuiteName}.ucdb 
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}
