#  File Name:         OsvvmRequiredSettings.tcl
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
#     5/2022   2022.05    Refactored Variable handling
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
# DO NOT CHANGE THESE SETTINGS
#   These settings are required by OSVVM to function properly
#   For user settings use LocalScriptDefaults.tcl.
#   If you do not have a LocalScriptDefaults.tcl, 
#   copy Example_LocalScriptDefaults.tcl to LocalScriptDefaults.tcl
#

namespace eval ::osvvm {

  variable OsvvmVersion 2022.11
  
  
  # 
  # Formalize settings in OsvvmDefaultSettings + LocalScriptDefaults
  #    Call OSVVM functions to do parameter checking and normalization
  #
    SetVHDLVersion         $DefaultVHDLVersion
    SetSimulatorResolution $SimulateTimeUnits
    SetTranscriptType      $TranscriptExtension
    SetLibraryDirectory    $VhdlLibraryParentDirectory 
  
  #
  # Variables set by VendorScripts_***.tcl
  #    Initialize values that were conditionally initialized
  #
    if {![info exists ToolArgs]} {
      variable ToolArgs ""
    }
    if {![info exists NoGui]} {
      variable NoGui "true"
    }
    if {![info exists ToolSupportsGenericPackages]} {
      variable ToolSupportsGenericPackages "true"
    }
  
  #
  # Create derived directory paths
  #
    variable ReportsDirectory          [file join ${OutputBaseDirectory} ${ReportsSubdirectory}]
    variable ResultsDirectory          [file join ${OutputBaseDirectory} ${ResultsSubdirectory}]
    variable CoverageDirectory         [file join ${OutputBaseDirectory} ${CoverageSubdirectory}]
  

  #
  #  Initialize OSVVM Internals
  #
  
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
    variable Report2HtmlErrorInfo      ""
    variable Report2JunitErrorInfo     ""
    variable Log2OsvvmErrorInfo        ""


    
    # When a build is started, run include instead of build
    variable BuildStarted "false"
    variable GenericList  ""
    variable GenericNames ""

    # VhdlReportsDirectory:  OSVVM temporary location for yml.  Moved to ${ReportsDirectory}/${TestSuiteName}
    variable VhdlReportsDirectory     "" ;  

    # OsvvmYamlResultsFile: temporary OSVVM name moved to ${OutputBaseDirectory}/${BuildName}.yaml
    variable OsvvmYamlResultsFile     "OsvvmRun.yml" ;  

    # OsvvmBuildFile: temporary OSVVM name moved to ${OutputBaseDirectory}/${LogSubDirectory}/${BuildName}.log
    variable OsvvmBuildFile           "OsvvmBuild.log" ;  

    #  TranscriptYamlFile: temporary file that contains set of files used in TranscriptOpen.  Deleted by scripts.
    variable TranscriptYamlFile       "OSVVM_transcript.yml" ;  
    
    # Error handling
    variable AnalyzeErrorCount 0
    variable ConsecutiveAnalyzeErrors 0
    variable SimulateErrorCount 0
    variable ConsecutiveSimulateErrors 0
    variable ScriptErrorCount 0 

    variable GotTee false

    # Initial saved values for ErrorStopCounts
    variable SavedAnalyzeErrorStopCount  $AnalyzeErrorStopCount
    variable SavedSimulateErrorStopCount $SimulateErrorStopCount
    
}
