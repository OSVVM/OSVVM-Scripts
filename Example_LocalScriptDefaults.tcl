#  File Name:         Example_LocalScriptDefaults.tcl
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
#     6/2022   2022.06    Initial
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


# Copy this file to:   OsvvmLibraries/Scripts/LocalScriptDefaults.tcl 
namespace eval ::osvvm {


# NOTE, SETTING variables only works in the context of LocalScriptDefaults
# IF YOU CHANGE these variables after running build, they may not work properly.

#  if {$ToolVendor eq "Siemens"} {
#    SetExtendedAnalyzeOptions  "-quiet"
#    SetExtendedSimulateOptions "-quiet"
#  } 


    # Directory for all Ouput
#    variable OutputBaseDirectory        ""                          ;# default value
#    variable OutputBaseDirectory        "osvvm"                     ;# puts output in a directory named osvvm

    # Directory for logs 
    # ToolNameVersion = <ToolName>-<Version>
#    variable LogSubdirectory            "logs/${ToolNameVersion}"   ;# default value
#    variable LogSubdirectory            "logs"                      ;# log directory without tool information

    # Directory for Reports (Test Case *.html)
#    variable ReportsSubdirectory        "reports"                   ;# default value

    # Directory for Reports (VHDL Code generated)
#    variable ResultsSubdirectory        "results"                   ;# default value

    # VHDL Library Directories
#    variable VhdlLibraryParentDirectory ""                          ;# default value
#    variable VhdlLibraryDirectory       "VHDL_LIBS"                 ;# default value
#    variable VhdlLibrarySubdirectory    "${ToolNameVersion}"        ;# default value

#    variable VhdlLibraryParentDirectory  "C:/tools/sim_temp"        ;# put libraries in temp space
#    variable VhdlLibraryDirectory        ""                         ;# good with above alternative


    # Code Coverage Directory
#    variable CoverageSubdirectory       "CodeCoverage"              ;# default value

  # TranscriptType:  html vs. log.   
#  variable TranscriptExtension      "html"                          ;# default value
#  variable TranscriptExtension      "log"                           ;# if you prefer plain text

}

  
