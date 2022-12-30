#  File Name:         StartReports.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Tcl procedures to configure and adapt the OSVVM simulator 
#    scripting methodology for a particular project.
#    As part of its tasks, it runs OSVVM scripts that define
#    procedures use in the OSVVM scripting methodology.
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
#    12/2022              Created from StartQuesta.tcl
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


namespace eval ::osvvm {
  variable OsvvmScriptDirectory  [file dirname [file normalize [info script]]]
  
  variable OsvvmInitialized  "false"
  variable ScriptBaseName    "Reports"
}

# set this outside the OSVVM scope
variable ToolName          "Reports"


source ${::osvvm::OsvvmScriptDirectory}/StartUpShared.tcl

set ::osvvm::OsvvmInitialized "true"

puts -nonewline ""  ; # suppress printing of true from above line
