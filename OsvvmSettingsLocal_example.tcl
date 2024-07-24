#  File Name:         OsvvmSettingsLocal_example.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    This is an "example" file.   To use the settings in this 
#    file, copy it to LocalScriptDefaults.tcl.
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
#     7/2024   2024.07    Examples for setting FailOnNoChecks and ClockResetVersion
#     3/2024   2024.03    Added OsvvmVersionCompatibility
#     6/2022   2022.06    Initial
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 - 2024 by SynthWorks Design Inc.  
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
#   This file is a template for OSVVM initial variable settings go in 
#   Copy this file to OsvvmLibraries/Scripts/LocalScriptDefaults.tcl
#   Uncomment and customize the below settings
#


namespace eval ::osvvm {

  #
  # Directory structure and results file management
  #
    # OsvvmVersionCompatibility:  value does not have to match an exact revision tag. 
    #   The intent is to rarely change the settings. 
    # variable OsvvmVersionCompatibility $OsvvmVersion                 ;# default - format is:  YYYY.MMr.  YYYY= year.  MM= Month number.  r is a,b,c as minor revision tag 
    # variable OsvvmVersionCompatibility 2023.99                       ;# Use values established in 2023, but no updated values from 2024 or later

    # for 2024.07, FailOnNoChecks 1 (TRUE), 0 (FALSE).  1 is the default if OsvvmVersionCompatibility >= 2024.07 
    # variable FailOnNoChecks 0

    # for 2024.07, ClockResetVersion setting of less that 2024.07 selects version that was used prior to 2024.07
    # variable ClockResetVersion 2024.05

    #  Base directory for other OSVVM created directories 
    #  variable OutputBaseDirectory        ""                          ;# put output in $CurrentSimulationDirectory
    #  variable OutputBaseDirectory        "osvvm"                     ;# put output in $CurrentSimulationDirectory/osvvm

    #  Directory for log files = $OutputBaseDirectory/$LogSubdirectory
    #    Contains simulator transcript in text and optionally html
    #    ToolNameVersion = <ToolName>-<Version>
    #  variable LogSubdirectory            "logs/${ToolNameVersion}"   ;# default value
    #  variable LogSubdirectory            "logs"                      ;# log directory without tool information

    #  Directory for OSVVM generated reports = $OutputBaseDirectory/$ReportsSubdirectory
    #    Contains Test Case Report with Alerts, Functional Coverage, and Scoreboards
    #  variable ReportsSubdirectory        "reports"                   ;# default value

    #  Directory for OSVVM transcripts =  $ResultsSubdirectory/<test suite name>/<FileName>.html
    #    Contains files created by AlertLogPkg.TranscriptOpen
    #  variable ResultsSubdirectory        "results"                   ;# default value

    # Code Coverage Directory = $OutputBaseDirectory/$CoverageSubdirectory
    #    Code coverage collected by the simulator
    #  variable CoverageSubdirectory       "CodeCoverage"              ;# default value

    #  Library Directory structure is defined by
    #  [file join $VhdlLibraryParentDirectory $OutputBaseDirectory $VhdlLibraryDirectory $VhdlLibrarySubdirectory]
    #
    #  Library Parent Directory
    #    If "", use $OutputBaseDirectory as base
    #    If has an absolute path, use the absolute path as the library parent directory
    #  variable VhdlLibraryParentDirectory ""                          ;# default value
    #  variable VhdlLibraryParentDirectory  "C:/tools"                 ;# put libraries in temp space

    #  Library Directory
    #    variable VhdlLibraryDirectory       "VHDL_LIBS"               ;# default value
    
    #  Library Subdirectory
    #    variable VhdlLibrarySubdirectory    "${ToolNameVersion}"      ;# default value

    # OsvvmTemporaryOutputDirectory is where temporary OSVVM output goes.   
    # Caution:  If you change the value of OsvvmTemporaryOutputDirectory, you must rerun OsvvmLibraries/osvvm/osvvm.pro
    # Files only remain in this directory when a tool does not complete correctly
    #    variable OsvvmTemporaryOutputDirectory   ""
    
    # OsvvmSettingsSubDirectory 
    # Location for package bodies generated:  OsvvmScriptSettingsPkg_generated.vhd and OsvvmScriptSettingsPkg_generated.vhd
    # Project/User settings OsvvmSettingsPkg_local.vhd 
    #    variable SettingsAreRelativeToSimulationDirectory "false"
    #    variable OsvvmSettingsSubDirectory      ""  


  #
  #  TCL Error signaling during a build 
  #
    #   variable FailOnBuildErrors        "true"
    #   variable FailOnReportErrors       "false"
    #   variable FailOnTestCaseErrors     "false"
  
  #
  # Stop Counts for Failures seen by Analyze and Simulate
  #   Value 0 is special to mean, don't stop
  #   Otherwise Errors >= ErrorsStopCount, stop the build.
  #
    #  variable AnalyzeErrorStopCount       0
    #  variable SimulateErrorStopCount      0

  #
  #  Generate HTML transcripts if TranscriptExtension = "html".  
  #    Text based log files are always created  
  #
    #  variable TranscriptExtension      "html"    ;# default value. Generate log and html transcripts
    #  variable TranscriptExtension      "log"     ;# Only generate log transcripts
    #  variable CreateSimScripts         "true"    ;# Create a script with every simulator command run during this session
    #  variable CreateOsvvmOutput        "true"    ;# Text file with just OSVVM output

  #
  # VHDL Simulation Settings 
  #
    #  variable DefaultVHDLVersion     "2008"      ; # OSVVM requires > 2008.  Valid values 1993, 2002, 2008, 2019
    #  variable SimulateTimeUnits      "ps"
    #  variable DefaultLibraryName     "DefaultLib"

  # 
  # Default Coverage Options
  #
    #  variable CoverageEnable           "true"
    #  variable CoverageAnalyzeEnable    "false"
    #  variable CoverageSimulateEnable   "false"
    #  variable CoverageAnalyzeOptions   [vendor_SetCoverageAnalyzeDefaults] 
    #  variable CoverageSimulateOptions  [vendor_SetCoverageSimulateDefaults]

  #
  #  Simulation Controls
  #
    #  variable SimulateInteractive "false"
    #  variable DebugIsSet          "false"
    #  variable Debug               "false"
    #  variable LogSignalsIsSet     "false"
    #  variable LogSignals          "false"
    #  variable ScriptDebug         "false"

  # 
  # Extended Analyze and Simulate Options
  #
    #  variable VhdlAnalyzeOptions        ""
    #  variable VerilogAnalyzeOptions     ""
    #  variable ExtendedAnalyzeOptions    ""
    #  variable ExtendedSimulateOptions   ""
    #  if {$ToolVendor eq "Siemens"} {
    #    variable ExtendedAnalyzeOptions   "-quiet"
    #    variable ExtendedSimulateOptions  "-quiet"
    #  } 

  #
  #  GHDL Analyze and Simulate Options
  #
    #  variable ExtendedElaborateOptions  ""
    #  variable ExtendedRunOptions        ""
    #  variable SaveWaves                 "false"
    #  variable SimulateInteractive       "false"
  
  #
  # Second Top
  #
    #  variable SecondSimulationTopLevel ""


  #  RemoveLibrary / RemoveLibraryDirectory Controls.  Only set to false.  Do not set to true.
  #    Currently both must be false for ActiveHDL
    #  variable RemoveLibraryDirectoryDeletesDirectory  "false"
    #  variable RemoveUnmappedLibraries                 "false"


  #
  #  Variables set by VendorScripts_***.tcl (or OsvvmRequiredSettings)
  #    Don't set these here, but you can use them in your scripts
  #
    #  variable ToolType    
    #  variable ToolVendor  
    #  variable ToolName   
    #  variable ToolNameVersion 
    #  variable ToolArgs 
    #  variable NoGui 
    #  variable ToolSupportsGenericPackages 

}

  
