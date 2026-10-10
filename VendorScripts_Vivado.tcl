#  File Name:         VendorScripts_Vivado.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#     Rob Gaddi      email:  rgaddi@highlandtechnology.com
#
#  Description
#    Tcl procedures for Xilinx Vivado with the intent of making running
#    compiling and simulations tool independent
#
#  Revision History:
#    Date      Version    Description
#     5/2024   2024.05    Added ToolVersion variable
#     2/2022   2022.02    Added template of procedures needed for coverage support
#     4/2021   2021.02    Initial revision, tested under Vivado 2020.1
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021-2022 by SynthWorks Design Inc.
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
  variable ToolType    "synthesis"
  variable ToolVendor  "Xilinx"
  variable ToolName    "Vivado"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead
  variable ToolVersion [version -short]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion

  # Quite unfortunately, much of Vivado doesn't support VHDL-2008 properly.
  # Therefore the default assumption has to be for VHDL-2002
  variable DefaultVHDLVersion 2002

  # Try to get the default library name from the open project, but we can
  # fall back to a hard-coded default if necessary.
  #if {[catch set XILINX_LIB [get_property DEFAULT_LIB [current_project]]} {
  #  set XILINX_LIB xil_defaultlib
  #}

# -------------------------------------------------
# StartTranscript / StopTranscxript
#

# Haven't been able to find any way to get Vivado to support transcript control
# However, it is a convenient hook to use to suppress some warning messages
# that are otherwise tacky.

proc vendor_StartTranscript {FileName} {
  # WARNING: [filemgmt 56-12] File ... cannot be added to the project because
  # it already exists in the project, skipping this file
  set_msg_config -id {filemgmt 56-12} -suppress -quiet
}

proc vendor_StopTranscript {FileName} {
  reset_msg_config -id {filemgmt 56-12} -default_severity -quiet
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {xvhdl xelab xsim}}]
  return [regexp {xvhdl|xelab|xsim} $LineOfText]
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#    set defaults here
}

proc vendor_SetCoverageElaborateDefaults {} {
  # Set the default code coverage options for elaboration.
  #
  # There are none for Vivado.
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
  variable CoverageSimulateOptions
#    set defaults here
}

# -------------------------------------------------
# Library
#

# Vivado doesn't maintain library files per se, so there's nothing to do.

proc vendor_library {LibraryName PathToLib} {}
proc vendor_LinkLibrary {LibraryName PathToLib} {}
proc vendor_UnlinkLibrary {LibraryName PathToLib} {}

# -------------------------------------------------
# analyze
#

proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  if {$VhdlVersion eq "2008"} {
    set f [read_vhdl -library $LibraryName -vhdl2008 $FileName]
  } else {
    set f [read_vhdl -library $LibraryName $FileName]
  }

  if {$f eq {}} {
    # The file was already present in the project, so update the parameters
    set f [get_files $FileName]
    set_property LIBRARY $LibraryName $f
    if {$VhdlVersion eq "2008"} {
      set_property FILE_TYPE {VHDL 2008} $f
    } else {
      set_property FILE_TYPE {VHDL} $f
    }
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set f [read_verilog -library $LibraryName  {*}${args} $FileName]
  if {$f eq {}} {
    # The file was already present in the project, so update the parameters
    set f [get_files $FileName]
    set_property LIBRARY $LibraryName $f
  }
}

# -------------------------------------------------
# End Previous Simulation
#

# -------------------------------------------------
# Simulate

# Since Vivado simulator doesn't support OSVVM, don't even attempt to do
# any simulation stuff; just stub it.

proc vendor_end_previous_simulation {} {}
proc vendor_simulate {LibraryName LibraryUnit args} {}

# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
#  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
#  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
#  if {$CovFiles ne ""} {
#    acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]
#  }
}

proc vendor_ReportCodeCoverage {TestSuiteName ResultsDirectory} {
#  acdb report -html -i ${ResultsDirectory}/${TestSuiteName}.acdb -o ${ResultsDirectory}/${TestSuiteName}_code_cov.html
}

proc vendor_GetCoverageFileName {TestName} {
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
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
