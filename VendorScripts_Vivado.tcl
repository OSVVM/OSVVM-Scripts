#  File Name:         VendorScripts_Vivado.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
#     Rob Gaddi      email:  rgaddi@highlandtechnology.com
# 
#  Description
#    Tcl procedures for Xilinx Vivado with the intent of making running 
#    compiling and simulations tool independent
#    
#  Revision History:
#    Date      Version    Description
#     2/2022   2022.02    Added template of procedures needed for coverage support
#     4/2021   2021.02    Initial revision, tested under Vivado 2020.1
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2021-2022 by SynthWorks Design Inc.  
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
  variable ToolType    "synthesis"
  variable ToolVendor  "Xilinx"
  variable simulator   "Vivado"
  variable ToolNameVersion "Vivado-[version -short]"
  puts $ToolNameVersion
  
  # Quite unfortunately, much of Vivado doesn't support VHDL-2008 properly.
  # Therefore the default assumption has to be for VHDL-2002
  variable DefaultVHDLVersion 2002
  
  # Try to get the default library name from the open project, but we can
  # fall back to a hard-coded default if necessary.
  #if {[catch set XILINX_LIB [get_property DEFAULT_LIB [current_project]]} {
  #  set XILINX_LIB xil_defaultlib
  #}

# -------------------------------------------------
# StartTranscript / StopTranscxript
#

# Haven't been able to find any way to get Vivado to support transcript control
# However, it is a convenient hook to use to suppress some warning messages
# that are otherwise tacky.

proc vendor_StartTranscript {FileName} {
  # WARNING: [filemgmt 56-12] File ... cannot be added to the project because
  # it already exists in the project, skipping this file 
  set_msg_config -id {filemgmt 56-12} -suppress -quiet
}

proc vendor_StopTranscript {FileName} {
  reset_msg_config -id {filemgmt 56-12} -default_severity -quiet
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

# Vivado doesn't maintain library files per se, so there's nothing to do.

proc vendor_library {LibraryName PathToLib} {}
proc vendor_map {LibraryName PathToLib} {}

# -------------------------------------------------
# analyze
#

proc vendor_analyze_vhdl {LibraryName FileName OptionalCommands} {
  variable VhdlVersion
  if {$VhdlVersion eq "2008"} {
    set f [read_vhdl -library $LibraryName -vhdl2008 $FileName]
  } else {
    set f [read_vhdl -library $LibraryName $FileName]
  }
  
  if {$f eq {}} {
    # The file was already present in the project, so update the parameters
    set f [get_files $FileName]
    set_property LIBRARY $LibraryName $f
    if {$VhdlVersion eq "2008"} {
      set_property FILE_TYPE {VHDL 2008} $f
    } else {
      set_property FILE_TYPE {VHDL} $f
    }
  }
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
  set f [read_verilog -library $LibraryName  {*}${OptionalCommands} $FileName]
  if {$f eq {}} { 
    # The file was already present in the project, so update the parameters
    set f [get_files $FileName]
    set_property LIBRARY $LibraryName $f
  }
}

# -------------------------------------------------
# End Previous Simulation
#

# -------------------------------------------------
# Simulate

# Since Vivado simulator doesn't support OSVVM, don't even attempt to do
# any simulation stuff; just stub it.

proc vendor_end_previous_simulation {} {}
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {}

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
