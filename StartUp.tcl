#  File Name:         StartUp.tcl
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
#    01/2022   2022.01    New StartUp algorithm for detecting ActiveHDL's VSimSA.
#    10/2021   2021.10    Loads YAML utilities when YAML library available: OsvvmYamlSupport.tcl, NoYamlPackage.tcl
#                         Loads LocalScriptDefaults.tcl if it is in the SCRIPT_DIR.  This is a optional user settings file.
#                         LocalScriptsDefaults.tcl is not provided by OSVVM so your local settings will not be overwritten.  
#     2/2021   2021.02    Refactored.                                                          
#                         - Tool now determined in here (was in ToolConfiguration.tcl). 
#                            - Simplifies ActiveHDL startup
#                         - Initial tool settings now in VendorScripts_*.tcl (was in ToolConfiguration.tcl)              
#                         - Added: Default settings now in OsvvmScriptDefaults.tcl (was here)         
#                         - Removed: ToolConfiguration.tcl (now in StartUp.tcl and VendorScripts_*.tcl)                                
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     2/2020   2020.02    Moved tool determination to outer layer
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute 
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#                         as TCL scripts in conjunction with the library 
#                         procedures
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.  
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
  # Initial SCRIPT_DIR setup - revised by ActiveHDL VSimSA
  variable SCRIPT_DIR  [file dirname [file normalize [info script]]]
  variable OsvvmInitialized  "false"
  
  # 
  # Find the simulator
  #
  variable ToolExecutable [info nameofexecutable]
  variable ToolExecutableName [file rootname [file tail $ToolExecutable]]

  if {[info exists aldec]} {
    variable ToolFamily [lindex [split [vsim -version]] 2]
    if {$ToolFamily eq "Riviera-PRO"} { 
      source ${SCRIPT_DIR}/VendorScripts_RivieraPro.tcl
    } elseif {[string match -nocase $ToolExecutableName "vsimsa"]} {
      set SCRIPT_DIR [file dirname [string trim $argv0 ?{}?]]
      source ${SCRIPT_DIR}/VendorScripts_VSimSA.tcl
    } else {
      source ${SCRIPT_DIR}/VendorScripts_ActiveHDL.tcl
    }
  } elseif {$ToolExecutableName eq "vish" || $ToolExecutableName eq "vsimk"} {
    source ${SCRIPT_DIR}/VendorScripts_Mentor.tcl
  } elseif {[string match -nocase $ToolExecutableName "vivado"]} {
    source ${SCRIPT_DIR}/VendorScripts_Vivado.tcl
  } else {
    source ${SCRIPT_DIR}/VendorScripts_GHDL.tcl
  }
}

# OSVVM Project Scripts 
if {![catch {package require yaml}]} {
  source ${::osvvm::SCRIPT_DIR}/OsvvmYamlSupport.tcl
} else {
  source ${::osvvm::SCRIPT_DIR}/NoYamlPackage.tcl
}
source ${::osvvm::SCRIPT_DIR}/OsvvmProjectScripts.tcl
namespace import ::osvvm::*

# Set OSVVM Script Defaults - defaults may call scripts
source ${::osvvm::SCRIPT_DIR}/OsvvmScriptDefaults.tcl

if {[file exists ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults.tcl]} {
  source ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults.tcl
}

namespace eval ::osvvm {
  variable OsvvmInitialized  "true"
}