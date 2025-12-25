#  File Name:         OsvvmSettingsVendorScriptsDefault.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Sets the defaults for the VendorScripts_vvv.tcl which may override them
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
#    01/2026   2026.01    Refactored from OsvvmSettingsDefault.tcl and OsvvmSettingsRequired.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2025 by SynthWorks Design Inc.  
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
#   These are also overridden by VendorScripts_vvv.tcl
#   Instead, create a OsvvmSettingsLocal.tcl and change them there.
#   If you do not have a OsvvmSettingsLocal.tcl, 
#   copy OsvvmSettingsLocal_example.tcl to OsvvmSettingsLocal.tcl
#

# OSVVM Variable Defaults
namespace eval ::osvvm {
  #
  #  Simulator - Vendor Controls
  #    Specify which parts of 2019 are supported
  #    If set by vendor scripts do not change the setting
  #
  variable SimulatorMemory     ""  ;# currently only used by nvc, but can be used by any

  variable Supports2019Interface           "false"
  variable Supports2019ImpureFunctions     "false"
  variable Supports2019FilePath            "false"
  variable Supports2019AssertApi           "false"
  variable Supports2019Integer64Bits       "false"

  variable ToolArgs ""
  variable NoGui "true"
  variable ToolSupportsGenericPackages "true"
  variable ToolSupportsDeferredConstants "true"    

  # 
  # Extended Analyze Options
  #
  variable VhdlAnalyzeOptions        ""
  variable VerilogAnalyzeOptions     ""
  variable ExtendedAnalyzeOptions    ""
    
  #
  #  Extended Simulate Options Options 
  #    Not all used by all simulators
  #
  variable ExtendedSimulateOptions   ""  ; # Simulators that do one step optimize, elaborate, run
  variable ExtendedGlobalOptions     ""
  variable ExtendedOptimizeOptions   ""
  variable ExtendedElaborateOptions  ""
  variable ExtendedRunOptions        ""

  #
  # FunctionalCoverageIntegratedInSimulator controls whether osvvm.pro allows functional coverage to be linked into simulator interface
  #   osvvm.pro does:  analyze CoverageVendorApiPkg_${::osvvm::FunctionalCoverageIntegratedInSimulator}.vhd
  #   Currently valid values are:   
  #       "default" - do not use any simulator functional coverage linking.
  #       "Aldec"   - use the link for Aldec tools - works with RivieraPRO and ActiveHDL
  #       "NVC"     - works with NVC 1.15.1 or newer.
  #   Values other than "default" is set by VendorScripts_***.tcl for the respective simulator
  #   Here, if a value was not previously set, the value "default" will be set.
  #   To add capabilty to a simulator, 
  #      add a file named CoverageVendorApiPkg_<simualtor_or_vendor>.vhd to directory osvvm and 
  #      set this variable in the VendorScripts_***.tcl for the appropriate version of the simualtor (see VendorScripts_NVC.tcl)
  #
  variable FunctionalCoverageIntegratedInSimulator "default"

  #
  # RemoveLibrary / RemoveLibraryDirectory Controls. 
  #    Also set by by VendorScripts_ActiveHDL.  
  #    Currently both must be false for ActiveHDL
  #
  variable RemoveLibraryDirectoryDeletesDirectory "true"
  variable RemoveUnmappedLibraries    "true"

  #
  # Set argv0, argv, and argc in the event the tool forgets to.
  #
  if {![info exists ::argv0]} {
    variable ::argv0  ""
  }
  if {![info exists ::argv]} {
    variable ::argv  ""
  }
  if {![info exists ::argc]} {
    variable ::argc  ""
  }
}
