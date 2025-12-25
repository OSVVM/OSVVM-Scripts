#  File Name:         OsvvmSettingsRequired.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Required initializations for variables. 
#    DO NOT CHANGE THESE.
#    For things users can change, see OsvvmDefaultSettings.tcl
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
#     7/2024   2024.07    Set FailOnNoChecks and ClockResetVersion if not already set in OsvvmSettingsLocal (user defined)
#                         Naming updates.  Added WaveFiles default. 
#     3/2024   2024.03    Revision Update for release
#                         Added default values for argc, argv, argv0 for questa -batch
#                         Sets OsvvmVersionCompatibility if it is not set in LocalScriptDefaults.tcl
#     1/2023   2023.01    Added OsvvmHomeDirectory and OsvvmCoSimDirectory.  
#                         Added options for CoSim 
#     5/2022   2022.05    Refactored Variable handling
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 - 2025 by SynthWorks Design Inc.  
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
#   These settings are required by OSVVM to function properly
#   For user settings use LocalScriptDefaults.tcl.
#   If you do not have a LocalScriptDefaults.tcl, 
#   copy Example_LocalScriptDefaults.tcl to LocalScriptDefaults.tcl
#

namespace eval ::osvvm {

  variable OsvvmVersion                 2026.01
  variable OsvvmBuildYamlVersion        2025.02
  variable OsvvmTestCaseYamlVersion     1.0
 # The following are set in VHDL code.  Either need to pass these or have it directly in the VHDL Code.
  variable OsvvmAlertYamlVersion        InVhdlCodeVersionTbd
  variable OsvvmCoverageYamlVersion     InVhdlCodeVersionTbd
  variable OsvvmScoreboardYamlVersion   InVhdlCodeVersionTbd
  variable OsvvmRequirementsYamlVersion InVhdlCodeVersionTbd   ;# file is an array of requirements - version not possible w/o file change

  # Do not update if user set these already
  if {![info exists OsvvmVersionCompatibility]} {
    variable OsvvmVersionCompatibility $OsvvmVersion
  }
  if {![info exists FailOnNoChecks]} {
    variable FailOnNoChecks [expr [string compare $OsvvmVersionCompatibility "2024.07"] >= 0]
  }
  if {![info exists ClockResetVersion]} {
    variable ClockResetVersion $OsvvmVersionCompatibility
  }

  # 
  # OsvvmTempOutputDirectory - Used as temp directory for output
  # DefaultBuildOutputDirectory - Default value if a build is not active
  # OsvvmBuildOutputDirectory   - Apply default to Build Output Directory 
  #
  # ToolName not set when OsvvmSettingsDefault called
  variable OsvvmTempOutputDirectory    $OsvvmTempOutputSubdirectory
#    variable OsvvmTempOutputDirectory    [file join $OutputBaseDirectory  $OsvvmTempOutputSubdirectory] 
  # Default OsvvmBuildOutputDirectory - otherwise it is [file join $OutputBaseDirectory $BuildName]
#  variable DefaultBuildOutputDirectory    [file join $OutputBaseDirectory  $OsvvmTempOutputSubdirectory] 
  variable DefaultBuildOutputDirectory    $OsvvmTempOutputSubdirectory
  variable OsvvmBuildOutputDirectory    $DefaultBuildOutputDirectory 

  # 
  # Formalize settings in OsvvmDefaultSettings + LocalScriptDefaults
  #    Call OSVVM functions to do parameter checking and normalization
  #
  if {![info exists VhdlVersion]} {
    SetVHDLVersion         $DefaultVHDLVersion
  }
  #  SetSimulatorResolution $SimulateTimeUnits  ;# SimulateTimeUnits is the definitive value
  SetTranscriptType      $TranscriptExtension
  SetLibraryDirectory    $VhdlLibraryParentDirectory 
    

  #
  # Create derived directory paths
  variable OsvvmCoSimDirectory  ${OsvvmHomeDirectory}/CoSim

  #  The following directories are now dynamically created by CheckSimulationDirs - locate these in the build directory
  variable ReportsDirectory       $InvalidDirectory
  variable ResultsDirectory       $InvalidDirectory
  variable CoverageDirectory      $InvalidDirectory

  # Dynamically created by StartTranscript
  variable LogDirectory           $InvalidDirectory

  #
  #  Initialize OSVVM Internals
  #
    # Wave files for a single simulation run - set by vendor_DoWaves for some simulators
    variable WaveFiles ""

  
    #
    # Extended TCL information about errors - for debugging
    #   TCL's errorInfo is saved to these as build finishes
    #
    variable AnalyzeErrorInfo          ""
    variable SimulateErrorInfo         ""
    variable WaveErrorInfo             ""
    variable BuildErrorInfo            ""
    variable BuildReportErrorInfo      ""
    variable SimulateReportErrorInfo   ""
    variable Simulate2HtmlErrorInfo    ""
    variable ReportErrorInfo           ""
    variable Report2HtmlErrorInfo      ""
    variable Report2JunitErrorInfo     ""
    variable Log2OsvvmErrorInfo        ""


    variable BuildStarted          "false"   ; # Detects if build is running and if build is called, call include instead
    variable HaveNotCreatedBuildOutputDirectory "true"
    variable BuildName             ""
    variable BuildStatus           "FAILED"
    variable LastBuildName         ""
    variable LastAnalyzedFile      ""
    variable GenericDict           ""
    variable GenericNames          ""
    variable GenericOptions        ""
    variable RunningCoSim              "false"
    variable RanSimulationWithCoverage "false"
    
    if {[catch {set OperatingSystemName [string tolower [exec uname]]} err]} {
      set OperatingSystemName windows
    }

    # OsvvmIndex...File - locates index.html for summarizing different builds
    variable OsvvmIndexYamlFile  [file join ${::osvvm::OutputBaseDirectory} index.yml]
    variable OsvvmIndexHtmlFile  [file rootname ${::osvvm::OsvvmIndexYamlFile}].html

    # OsvvmTempYamlFile: temporary OSVVM name.  Moved to ${OutputBaseDirectory}/${BuildName}/${BuildName}.yaml when build finishes
    # Both VHDL and Scripts add to this file
    variable OsvvmTempYamlFile     [file join ${OsvvmTempOutputDirectory} "OsvvmRun.yml"] ;  

    #  TempTranscriptYamlFile: temporary file that contains set of files used in TranscriptOpen.  Deleted by scripts.
    variable TempTranscriptYamlFile     [file join ${OsvvmTempOutputDirectory} "OSVVM_transcript.yml"] ;  
    
    # OsvvmTempLogFile: temporary OSVVM name. Moved to ${OutputBaseDirectory}/${BuildName}/${LogSubDirectory}/${BuildName}.log when scripts complete
    # Created in temporary space since BuildName may not have been established yet.   
    variable OsvvmTempLogFile      [file join ${OsvvmTempOutputDirectory} "OsvvmBuild.log"] ;  
    

    # Error handling
    variable AnalyzeErrorCount 0
    variable LastAnalyzeHasError FALSE
    variable ConsecutiveAnalyzeErrors 0
    variable SimulateErrorCount 0
    variable ConsecutiveSimulateErrors 0
    variable ScriptErrorCount 0 
    
    variable GotTee false

    # Initial saved values for ErrorStopCounts
    variable SavedAnalyzeErrorStopCount  $AnalyzeErrorStopCount
    variable SavedSimulateErrorStopCount $SimulateErrorStopCount
    
}