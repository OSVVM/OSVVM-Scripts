#  File Name:         OsvvmSettingsDefault.tcl
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
#    04/2024   2024.03    Renamed to OsvvmSettingsDefault.tcl
#    05/2022   2022.05    Refactored to move variable settings from OsvvmProjectScripts
#    02/2022   2022.02    Added call to SetTranscriptType to make HTML the default transcript
#     2/2021   2021.02    Refactored Default Settings from StartUp.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2021 - 2024 by SynthWorks Design Inc.  
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
# DO NOT CHANGE THESE SETTINGS
#   This file is overwritten with each new release.
#   Instead, create a LocalScriptDefaults.tcl and change them there.
#   If you do not have a LocalScriptDefaults.tcl, 
#   copy Example_LocalScriptDefaults.tcl to LocalScriptDefaults.tcl
#


# OSVVM Variable Defaults
namespace eval ::osvvm {
  #
  #  Initialize internal settings -- Do not change these
  #
    # CurrentWorkingDirectory is a relative path to the scripts currently running 
    variable CurrentWorkingDirectory ""
    # CurrentSimulationDirectory is an absolute path to the simulation directory (for reports and such)
#    variable CurrentSimulationDirectory [pwd]
    variable CurrentSimulationDirectory "Invalid Initial Path !@#$%^&*()+=|><| Should be replaced By CheckWorkingDir"
  
  #
  # Directory structure and results file management
  #
    variable OutputBaseDirectory        ""  
    variable LogSubdirectory            "logs/${ToolNameVersion}"
    variable ReportsSubdirectory        "reports"  ; # Directory scripts put reports into.
    variable ResultsSubdirectory        "results"  ; # Directory for files opened by TranscriptOpen
    variable CoverageSubdirectory       "CodeCoverage"
    variable InvalidLibraryDirectory    "Invalid Library Directory !@#$%^&*()+=|><|"
    variable VhdlLibraryParentDirectory $InvalidLibraryDirectory
#    variable VhdlLibraryParentDirectory [pwd]      ; # use local directory
    variable VhdlLibraryDirectory       "VHDL_LIBS"
    variable VhdlLibrarySubdirectory    "${ToolNameVersion}"
    
    # OsvvmTemporaryOutputDirectory is where temporary OSVVM output goes.   
    # Caution:  If you change the value of OsvvmTemporaryOutputDirectory, you must rerun OsvvmLibraries/osvvm/osvvm.pro
    # Files only remain in this directory when a tool does not complete correctly
    variable OsvvmTemporaryOutputDirectory   ""
    
    # OsvvmSettingsSubDirectory 
    # Location for package local and generated package bodies 
    # Settings are relative to $OsvvmLibraries/osvvm if SettingsAreRelativeToSimulationDirectory is false
    variable SettingsAreRelativeToSimulationDirectory "false"
    variable OsvvmSettingsSubDirectory      "" 


  # 
  # TCL Error signaling during a build 
  #
    if {![info exists FailOnBuildErrors]} {
      variable FailOnBuildErrors        "true"
    }
    if {![info exists FailOnReportErrors]} {
      variable FailOnReportErrors       "false"
    }
    if {![info exists FailOnTestCaseErrors]} {
      variable FailOnTestCaseErrors     "false"
  }
  
  #
  # Stop Counts for Failures seen by Analyze and Simulate
  #   Value 0 is special to mean, don't stop
  #   Otherwise Errors >= ErrorsStopCount, stop the build.
  #
    variable AnalyzeErrorStopCount       0
    variable SimulateErrorStopCount      0
  
  #
  #  Generate HTML transcripts if TranscriptExtension = "html".  
  #    Text based log files are always created  
  #
    variable TranscriptExtension      "html"     ;# Generate log and html transcripts
    variable CreateSimScripts         "false"    ;# Create a script with every simulator command run during this session
    variable CreateOsvvmOutput        "false"    ;# Text file with just OSVVM output

  #
  # VHDL Simulation Settings 
  #
    variable DefaultVHDLVersion     "2008"     ; # OSVVM requires > 2008.  Valid values 1993, 2002, 2008, 2019
    variable SimulateTimeUnits      "ps"
    variable DefaultLibraryName     "DefaultLib"
  
  # 
  # Default Coverage Options
  #
    variable CoverageEnable           "true"
    variable CoverageAnalyzeEnable    "false"
    variable CoverageSimulateEnable   "false"
    variable CoverageAnalyzeOptions   [vendor_SetCoverageAnalyzeDefaults] 
    variable CoverageSimulateOptions  [vendor_SetCoverageSimulateDefaults]

  #
  #  Simulation Controls
  #
    variable SimulateInteractive "false"
    variable DebugIsSet          "false"
    variable Debug               "false"
    variable LogSignalsIsSet     "false"
    variable LogSignals          "false"
    variable ScriptDebug         "false"
    variable OpenBuildHtmlFile   "false"

  # 
  # Extended Analyze and Simulate Options
  #
    variable VhdlAnalyzeOptions        ""
    variable VerilogAnalyzeOptions     ""
    variable ExtendedAnalyzeOptions    ""
    variable ExtendedSimulateOptions   ""
    
  #
  #  GHDL Analyze and Simulate Options
  #
    variable ExtendedElaborateOptions  ""
    variable ExtendedRunOptions        ""
    variable SaveWaves                 "false"
    variable SimulateInteractive       "false"
  
  #
  # Second Top
  #
    variable SecondSimulationTopLevel ""
  
  #
  # RemoveLibrary / RemoveLibraryDirectory Controls. 
  #    Also set by by VendorScripts_ActiveHDL.  
  #    Currently both must be false for ActiveHDL
  #
    if {![info exists RemoveLibraryDirectoryDeletesDirectory]} {
      variable RemoveLibraryDirectoryDeletesDirectory "true"
    }
    
    if {![info exists RemoveUnmappedLibraries]} {
      variable RemoveUnmappedLibraries    "true"
    }
  
}
