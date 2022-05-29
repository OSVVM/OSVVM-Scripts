#  File Name:         OsvvmScriptDefaults.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Sets the defaults for the OSVVM Scripts
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
#    05/2022   2022.05    Refactored to move variable settings from OsvvmProjectScripts
#    02/2022   2022.02    Added call to SetTranscriptType to make HTML the default transcript
#     2/2021   2021.02    Refactored Default Settings from StartUp.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2021 - 2022 by SynthWorks Design Inc.  
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


# OSVVM Variable Defaults
namespace eval ::osvvm {

  # Directory and Results file management
  variable OutputBaseDirectory        ""  
  variable LogSubdirectory            "logs/${ToolNameVersion}"
  variable ReportsSubdirectory        "reports"  ; # Directory scripts put reports into.
  variable ResultsSubdirectory        "results"  ; # Directory for files opened by TranscriptOpen
  variable CoverageSubdirectory       "CodeCoverage"
  variable VhdlLibraryDirectory       "VHDL_LIBS"
  variable VhdlLibrarySubdirectory    "${ToolNameVersion}"
  variable VhdlLibraryParentDirectory [pwd]      ; # use local directory
  
  # Also change with SetTranscriptType html 
  variable TranscriptExtension      "html"     ; # Set Transcripts to be html by default
#   if {!($ToolVendor eq "Siemens" || $ToolVendor eq "Aldec" || $ToolName eq "GHDL") } {
#     variable TranscriptExtension      "log"     ; # html currently supported for Aldec and Siemens simulators
#   } 
  

  # Settings 
  variable DefaultVHDLVersion     "2008"     ; # OSVVM requires > 2008.  Valid values 1993, 2002, 2008, 2019
  variable SimulateTimeUnits      "ps"
#  variable DefaultLibraryName     "default"
  
  # 
  # Default Coverage Options
  #
  variable CoverageEnable           "true"
  variable CoverageAnalyzeOptions   [vendor_SetCoverageAnalyzeDefaults]
  variable CoverageSimulateOptions  [vendor_SetCoverageSimulateDefaults]

  #
  # Stop Counts for Failures seen by Analyze and Simulate
  #   Value 0 is special to mean, don't stop
  #   Otherwise Errors >= ErrorsStopCount, stop the build.
  #
  variable AnalyzeErrorsStopCount  0
  variable SimulateErrorsStopCount 0
  
  # 
  # Extended Analyze and Simulate Options
  #
  variable VhdlAnalyzeOptions       ""
  variable VerilogAnalyzeOptions    ""
  variable ExtendedAnalyzeOptions   ""
  variable ExtendedSimulateOptions  ""

  # 
  # If Reports Fail, procude an error message
  #    For CI jobs, set this to "false" so the CI error reporter will attempt to run
  #
  variable FailOnReportErrors       "true"
}
