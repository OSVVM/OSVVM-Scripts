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
#    05/2024   2024.05    Updated for renaming during refactoring 
#    05/2022   2022.05    Refactored StartUp.tcl to remove items 
#                         shared by all StartUp scripts
#    10/2021   2021.10    Loads OsvvmYamlSupport.tcl when YAML library available
#                         Loads LocalScriptDefaults.tcl if it is in the OsvvmScriptDirectory
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

namespace eval ::osvvm {

  # --------------------------------
  # Set OsvvmScriptDirectory if it is not already set
  # --------------------------------
  # Usage of SCRIPT_DIR is deprecated.
  if {![info exists OsvvmScriptDirectory]} {
    # if a calling script uses SCRIPT_DIR, this supports backward compatibility
    variable OsvvmScriptDirectory ${SCRIPT_DIR}
  } else {
    # if a user add on script uses SCRIPT_DIR, this supports backward compatibility
    variable SCRIPT_DIR ${OsvvmScriptDirectory}
  }
  variable OsvvmHomeDirectory   [file normalize ${OsvvmScriptDirectory}/..]
}

variable OsvvmLibraries $::osvvm::OsvvmHomeDirectory

# --------------------------------
# Load OSVVM Core API
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsCreateYamlReports.tcl   ;#  Helpers for creating YAML files
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsCore.tcl                ;#  OSVVM Core API
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsSimulateSupport.tcl     ;#  OSVVM Simulate Support Scripts - should this be called by OsvvmScriptsCore after proc simulate?
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsFileCreate.tcl          ;#  OSVVM API for file creation

# --------------------------------
# Load Vendor Script Default settings
#   These are updated by VendorScripts_vvv.tcl
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsVendorScriptsDefault.tcl

# --------------------------------
# Vendor personalization of OSVVM API
# --------------------------------
namespace eval ::osvvm {
  source ${::osvvm::OsvvmScriptDirectory}/VendorScripts_${::osvvm::ScriptBaseName}.tcl
}

# --------------------------------
# Scripts to convert OSVVM Yaml outputs to HTML and XML files
# --------------------------------
if {[catch {package require yaml}]} {
  source ${::osvvm::OsvvmScriptDirectory}/StartUpYamlMockReports.tcl
} else {
  source ${::osvvm::OsvvmScriptDirectory}/StartUpYamlLoadReports.tcl
}

# --------------------------------
# Convert tool generated log files to HTML, ...
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/Log2Osvvm.tcl

# --------------------------------
# CoSim API additions
# --------------------------------
if {[file exists ${::osvvm::OsvvmScriptDirectory}/../CoSim]} { 
  source ${::osvvm::OsvvmScriptDirectory}/../CoSim/Scripts/MakeVproc.tcl
}


# Import any procedure exported by previous OSVVM scripts
namespace import ::osvvm::*

# --------------------------------
# Load OSVVM Default settings
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsDefault.tcl


# --------------------------------
# Load User settings
# --------------------------------
# Get Directory for User settings
variable ::osvvm::OsvvmUserSettingsDirectory [FindOsvvmSettingsDirectory "Scripts"]

# Settings Second:  OSVVM User/Project Customizations - not required 
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults.tcl]} {
  # Deprecated:  Uses old name - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults.tcl
}

# --------------------------------
# Load User Tool specific settings
# Settings Third   OSVVM User Simulator specific defaults - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated:  Uses old name - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl
}

# Settings Final   OSVVM Finalize Settings - builds names that are dependent on other names
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsRequired.tcl


# --------------------------------
# CallBacks & Error Handlers:  Callback*.tcl
# --------------------------------
# Callbacks First:  OSVVM Default CallBacks
source ${::osvvm::OsvvmScriptDirectory}/CallbackDefaults.tcl

# Callbacks Second:   OSVVM User/Project Customizations - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks.tcl
}


# Callback Third:      OSVVM User Simulator specific defaults - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl
}


# --------------------------------
# If the tee scripts load, mark them as available
# --------------------------------
if {[catch {source ${::osvvm::OsvvmScriptDirectory}/tee.tcl}]} {
   variable ::osvvm::GotTee false
} else {
   variable ::osvvm::GotTee true
}

puts "OSVVM Script Version:  $::osvvm::OsvvmVersion"
puts "Simulator Version:     $::osvvm::ToolNameVersion"


