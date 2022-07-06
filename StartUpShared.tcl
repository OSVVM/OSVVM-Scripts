#  File Name:         StartUpShared.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    StartUp scripts that are shared by any simulator
#    Called by StartUp and StartVCS, StartXcelium, ...
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
#    05/2022   2022.05    Refactored StartUp.tcl to remove items 
#                         shared by all StartUp scripts
#    10/2021   2021.10    Loads OsvvmYamlSupport.tcl when YAML library available
#                         Loads LocalScriptDefaults.tcl if it is in the SCRIPT_DIR
#                            This is a optional user settings file.
#                         LocalScriptsDefaults.tcl is not provided by OSVVM so your local settings will not be overwritten.  
#     2/2021   2021.02    Refactored.                                                          
#                         - Initial tool settings now in VendorScripts_*.tcl (was in ToolConfiguration.tcl)              
#                         - Added: Default settings now in OsvvmScriptDefaults.tcl (was here)         
#                         - Removed: ToolConfiguration.tcl (now in StartUp.tcl and VendorScripts_*.tcl)                                
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute 
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#                         as TCL scripts in conjunction with the library 
#                         procedures
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2022 by SynthWorks Design Inc.  
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


# Load Base OSVVM Project Scripts and Vendor Specific Scripts
source ${::osvvm::SCRIPT_DIR}/OsvvmProjectScripts.tcl
namespace eval ::osvvm {
  source ${::osvvm::SCRIPT_DIR}/VendorScripts_${::osvvm::ScriptBaseName}.tcl
}

# Load OSVVM YAML support if yaml support available 
# Could be made conditional for only simulators
if {![catch {package require yaml}]} {
  source ${::osvvm::SCRIPT_DIR}/OsvvmYamlSupport.tcl
} else {
  source ${::osvvm::SCRIPT_DIR}/NoYamlPackage.tcl
}

# Import any procedure exported by previous OSVVM scripts
namespace import ::osvvm::*

# Load OSVVM Defaults and then User Defaults (LocalScriptDefaults)
# Dependencies in here depend on VendorScripts_???.tcl
source ${::osvvm::SCRIPT_DIR}/OsvvmDefaultSettings.tcl
# Load User Settings if they exist
if {[file exists ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults.tcl]} {
  source ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults.tcl
}
# Simulator specific defaults
if {[file exists ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl]} {
  source ${::osvvm::SCRIPT_DIR}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl
}

# Finalize Settings
source ${::osvvm::SCRIPT_DIR}/OsvvmRequiredSettings.tcl

source ${::osvvm::SCRIPT_DIR}/Log2Html.tcl


# Set OSVVM Script Defaults - defaults may call scripts
source ${::osvvm::SCRIPT_DIR}/CallBacksDefaults.tcl
# Override common actions here
#   While intended for call back feature, can be used to replace any
#   previously defined procedure
if {[file exists ${::osvvm::SCRIPT_DIR}/LocalCallBacks.tcl]} {
  source ${::osvvm::SCRIPT_DIR}/LocalCallBacks.tcl
}
# Override simulator specific actions here
#   While intended for call back feature, can be used to replace any
#   previously defined procedure - such as vendor_SetCoverageAnalyzeDefaults
if {[file exists ${::osvvm::SCRIPT_DIR}/CallBacks_${::osvvm::ScriptBaseName}.tcl]} {
  source ${::osvvm::SCRIPT_DIR}/CallBacks_${::osvvm::ScriptBaseName}.tcl
}

#
# If the tee scripts load, mark them as available
#
if {${::osvvm::ToolName} ne "XSIM"} {
  if {[catch {source ${::osvvm::SCRIPT_DIR}/tee.tcl}]} {
     variable ::osvvm::GotTee false
  } else {
     variable ::osvvm::GotTee true
  }
}
