#  File Name:         VendorScripts_Sigasi.tcl
#  Purpose:           Scripts for running simulations in Sigasi
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Lieven Lemiengre    email:lieven.lemiengre@sigasi.com
# 
#  Description
#    Tcl procedures with the intent of making running 
#    compiling and simulations tool independent
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
#    02/2026   2025.09    Initial version for Sigasi Visual HDL
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2025 by SynthWorks Design Inc.    
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

# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "ide"
  variable ToolVendor  "Sigasi"
  variable ToolName    "Sigasi"
  variable ToolVersion "Visual-HDL"
  variable ToolNameVersion ${ToolName}-${ToolVersion}
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 
  
  if {[info exists ::env(OSVVM_VHDL_TARGET)] && $::env(OSVVM_VHDL_TARGET) >= 2019} {
    SetVHDLVersion 2019
    variable Supports2019Interface "true"
  } else {
    SetVHDLVersion 2008
  }
  set ::osvvm::GenerateOsvvmReports "false"


proc CallbackBefore_Build { Path_Or_File } {
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
}
proc vendor_LinkLibrary {LibraryName PathToLib} {
}
proc vendor_UnlinkLibrary {LibraryName PathToLib} {
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  
  set  AnalyzeOptions [concat -${VhdlVersion} -work ${LibraryName} {*}${args} ${FileName}]
  vcom {*}$AnalyzeOptions
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-L "] -work ${LibraryName} {*}${args} ${FileName}]
  vlog {*}$AnalyzeOptions
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # Sigasi does not run simulations, so nothing to do here
}

# -------------------------------------------------
# vendor_simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable SimulateTimeUnits
  
  set SimulateOptions [concat -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit} {*}${args} {*}${::osvvm::GenericOptions}]

  if {[info exists ::env(SIGASI_COMPILATION_LOG)]} {
    set logFileDir [file dirname $::env(SIGASI_COMPILATION_LOG)]
    set logFileName [file join $logFileDir "osvvm_simulation.log"]
    set fh [open $logFileName a]
    puts $fh "vsim {*}$SimulateOptions"
    close $fh
  }

  vsim {*}$SimulateOptions
}

# -------------------------------------------------
# vendor_CreateSimulateDoFile
#
proc vendor_CreateSimulateDoFile {LibraryUnit ScriptFileName} {
  # Sigasi does not run simulations, so nothing to do here
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  return "-g${Name}=${Value}"
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  # Sigasi does not handle coverage
}

proc vendor_SetCoverageElaborateDefaults {} {
  # Set the default code coverage options for elaboration.
  #
  # Sigasi doesn't handle coverage, so there are none.
  #
  # Returns: The default code coverage elaboration options.
  variable CoverageElaborateOptions
  set CoverageElaborateOptions ""
}

proc vendor_GetCoverageKindOptions {Step Kinds} {
  # Translate the kinds of code coverage into the simulator's options for a step.
  #
  #  Step  - `analyze`, `elaborate` or `simulate`.
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # Returns: The options for the step; none, there's no translation for this simulator yet.
  return ""
}

proc vendor_SetCoverageSimulateDefaults {} {
  # Sigasi does not handle coverage
}

# -------------------------------------------------
# Coverage - Not supported in Sigasi
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} { 
}

proc vendor_GetCoverageFileName {TestName} { 
  return ""
}

# -------------------------------------------------
# Export Coverage
#
proc vendor_ExportCodeCoverage {BuildName CodeCoverageDirectory FileName Options} {
  # Export the code coverage of a build into a well-known data format.
  #
  #  BuildName             - The build.
  #  CodeCoverageDirectory - The directory of the code coverage databases.
  #  FileName              - The file to write; if empty, chosen by the simulator.
  #  Options               - Further options of the simulator's export.
  #
  # There's no export for this simulator yet; it says so.
  puts "ExportCodeCoverage: Not supported for ${::osvvm::ToolName} yet."
}
