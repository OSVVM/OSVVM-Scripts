#  File Name:         VendorScripts_Reports.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    VendorScript stub for report generation
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
#     5/2024   2024.05    Added ToolVersion variable 
#    12/2022   2022.12    Updated variable naming 
#     2/2022   2022.02    Added template of procedures needed for coverage support
#     9/2021   2021.09    Created from VendorScripts_xxx.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 by SynthWorks Design Inc.  
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


#
# Load the tool vendor base files so we get the files it compiles
#
#  variable ScriptBaseName $::env(OSVVM_TOOL2)
#  source ${::osvvm::OsvvmScriptDirectory}/VendorScripts_${::osvvm::ScriptBaseName}.tcl
  
 #
 # Now replace base level procedures with the following
 #
 

namespace eval ::osvvm {


# -------------------------------------------------
# StartTranscript / StopTranscpript
#
# proc vendor_StartTranscript {FileName} {
# }
# 
# proc vendor_StopTranscript {FileName} {
# }


# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return "false"
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
}

proc vendor_LinkLibrary {LibraryName PathToLib} {}
proc vendor_UnlinkLibrary {LibraryName PathToLib} {}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  set ListOfLibraryFiles  [open ${LibraryName}_${::osvvm::ToolName}.files a]
  puts $ListOfLibraryFiles $FileName
  close $ListOfLibraryFiles
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set ListOfLibraryFiles  [open ${LibraryName}_${::osvvm::ToolName}.files a]
  puts $ListOfLibraryFiles $FileName
  close $ListOfLibraryFiles
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
}


# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
}

proc vendor_ReportCodeCoverage {TestSuiteName ResultsDirectory} { 
}

proc vendor_GetCoverageFileName {TestName} { 
  return $TestName
}

# end namespace ::osvvm
}
