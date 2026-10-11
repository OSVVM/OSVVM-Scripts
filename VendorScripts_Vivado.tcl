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
  # Start writing the simulator's transcript to a file.
  #  FileName - Path of the temporary transcript file.
  #
  # Optional. Called by [StartTranscript] at the start of a [build]; if a vendor file doesn't define it,
  # `DefaultVendor_StartTranscript` copies stdout and stderr into the file. [StopTranscript] later moves the file into
  # the build's log directory.
  #
  # Vivado has no transcript control: `FileName` isn't used. Suppresses Vivado's message `filemgmt 56-12`, which reports
  # a file that is already in the project, until `vendor_StopTranscript`.

  # WARNING: [filemgmt 56-12] File ... cannot be added to the project because
  # it already exists in the project, skipping this file
  set_msg_config -id {filemgmt 56-12} -suppress -quiet
}

proc vendor_StopTranscript {FileName} {
  # Stop writing the simulator's transcript to a file.
  #  FileName - Path of the temporary transcript file.
  #
  # Optional. Called by [StopTranscript] at the end of a [build], before the file is copied into the build's log
  # directory. If a vendor file doesn't define it, `DefaultVendor_StopTranscript` ends the copying of stdout and stderr.
  #
  # Vivado has no transcript control: `FileName` isn't used. Restores the default severity of Vivado's message `filemgmt
  # 56-12`, suppressed by `vendor_StartTranscript`.
  reset_msg_config -id {filemgmt 56-12} -default_severity -quiet
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
  # Return whether a transcript line is a command of this simulator.
  #  LineOfText - A line of the transcript.
  #
  # Used by `Log2Osvvm.tcl` while it converts a transcript: matching lines are copied into the file of simulator
  # commands.
  #
  # Matches lines containing `xvhdl`, `xelab` or `xsim` anywhere.
  #
  # Returns `1` if the line is a command of this simulator, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {xvhdl xelab xsim}}]
  return [regexp {xvhdl|xelab|xsim} $LineOfText]
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  # Return the simulator's default code coverage options for analyze.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageAnalyzeOptions`, and by
  # [SetCoverageKinds]. The value is used by [analyze] while code coverage is enabled for analyze, see
  # [SetCoverageAnalyzeEnable]. A user setting from [SetCoverageAnalyzeOptions] or `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Code coverage isn't supported yet: there are no defaults.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageAnalyzeOptions
#    set defaults here
}

proc vendor_SetCoverageElaborateDefaults {} {
  # Return the simulator's default code coverage options for elaboration.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageElaborateOptions`, and by
  # [SetCoverageKinds]. The value is passed to the elaboration by [simulate] (`ElaborateOptions`) while code coverage is
  # enabled for simulate, see [SetCoverageSimulateEnable]. A user setting from [SetCoverageElaborateOptions] or
  # `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Vivado: none.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageElaborateOptions
  set CoverageElaborateOptions ""
}

proc vendor_GetCoverageKindOptions {Step Kinds} {
  # Translate the kinds of code coverage into the simulator's options for one step.
  #  Step  - `analyze`, `elaborate` or `simulate`.
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # Called by `vendor_SetCoverageAnalyzeDefaults`, `vendor_SetCoverageElaborateDefaults` and
  # `vendor_SetCoverageSimulateDefaults` with the kinds in `CoverageKinds`. A kind the simulator doesn't support is left
  # out.
  #
  # Vivado: no translation yet; always empty.
  #
  # Returns the options for the step, or an empty string.
  return ""
}

proc vendor_SetCoverageSimulateDefaults {} {
  # Return the simulator's default code coverage options for simulate.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageSimulateOptions`, and by
  # [SetCoverageKinds]. The value is added to the simulator options by [simulate] while code coverage is enabled for
  # simulate, see [SetCoverageSimulateEnable]. A user setting from [SetCoverageSimulateOptions] or
  # `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Code coverage isn't supported yet: there are no defaults.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageSimulateOptions
#    set defaults here
}

# -------------------------------------------------
# Library
#

# Vivado doesn't maintain library files per se, so there's nothing to do.

proc vendor_library {LibraryName PathToLib} {
  # Create a library if it doesn't exist, and make it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [library] after it resolved the directory and created it. An error is caught by [library] and reported via
  # `CallbackOnError_Library`.
  #
  # Does nothing: Vivado keeps no library files; [analyze] sets the library of each file in the project.
}
proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught and
  # reported via `CallbackOnError_LinkLibrary`.
  #
  # Does nothing: Vivado keeps no library files.
}
proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Remove a library's mapping from the simulator.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [RemoveLibrary], [RemoveLibraryDirectory] and [RemoveAllLibraries] before the library directory is
  # deleted. An error is caught and printed as `LibraryError`.
  #
  # Does nothing: Vivado keeps no library files.
}

# -------------------------------------------------
# analyze
#

proc vendor_analyze_vhdl {LibraryName FileName args} {
  # Analyze (compile) a VHDL file into a library.
  #  LibraryName - Name of the working library.
  #  FileName    - Path of the VHDL file, relative to the current directory.
  #  args        - The analyze options as one list element.
  #
  # Called by [analyze] for files with extension `.vhd` or `.vhdl`. The options are the VHDL analyze options, the
  # extended analyze options, the code coverage analyze options if enabled, and the options given to [analyze]. An error
  # marks the analyze as failed.
  #
  # Adds the file to the open Vivado project with `read_vhdl -library <LibraryName>`, with `-vhdl2008` if the VHDL
  # version is 2008. If the file is already in the project, updates its library and its file type, `VHDL 2008` or
  # `VHDL`. The options in `args` aren't used. Vivado's default VHDL version is 2002.
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
  # Analyze (compile) a Verilog or SystemVerilog file into a library.
  #  LibraryName - Name of the working library.
  #  FileName    - Path of the Verilog file, relative to the current directory.
  #  args        - The analyze options as one list element.
  #
  # Called by [analyze] for files with extension `.v`, `.sv` or `.vh`. The options are the Verilog analyze options, the
  # extended analyze options, the code coverage analyze options if enabled, and the options given to [analyze]. An error
  # marks the analyze as failed.
  #
  # Adds the file to the open Vivado project with `read_verilog -library <LibraryName> <options>`. If the file is
  # already in the project, updates its library.
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

proc vendor_end_previous_simulation {} {
  # End the running simulation and release its files.
  #
  # Called by [EndSimulation]: at the start of a [build] and before a [simulate] if a simulation was started, after a
  # [simulate] that failed outside interactive mode, and before exiting on report errors.
  #
  # Does nothing: Vivado doesn't run simulations here.
}
proc vendor_simulate {LibraryName LibraryUnit args} {
  # Elaborate and run a simulation.
  #  LibraryName - Name of the working library.
  #  LibraryUnit - Top-level design unit: an entity or a configuration.
  #  args        - Simulator options.
  #
  # Called by [simulate] between `CallbackBefore_Simulate` and `CallbackAfter_Simulate`. The options are the options
  # given to [simulate], the extended simulate options and, if code coverage is enabled for simulate, the code coverage
  # simulate options. Generics set with [generic] are in `GenericOptions` (as returned by `vendor_generic`) and
  # `GenericDict`. An error marks the simulation as failed.
  #
  # Does nothing: Vivado's simulator doesn't support OSVVM.
}

# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
  # Merge the code coverage databases of a test suite or a build.
  #  TestSuiteName     - Name of the test suite, or of the build at the end of a build.
  #  CoverageDirectory - The build's code coverage directory.
  #  BuildName         - Name of the build; empty at the end of a build.
  #
  # Called at the end of a test suite, which ran with code coverage, with the test suite's name and the build name: the
  # databases in `<CoverageDirectory>/<TestSuiteName>` are merged into
  # `<CoverageDirectory>/<BuildName>/<TestSuiteName>`. Called at the end of the build with the build name and an empty
  # `BuildName`: the test suite databases are merged into `<CoverageDirectory>/<BuildName>`. [MergeCoverage] calls it
  # with a test suite name and a merge name.
  #
  # Does nothing: code coverage isn't supported yet.

#  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
#  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
#  if {$CovFiles ne ""} {
#    acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]
#  }
}

proc vendor_ReportCodeCoverage {TestSuiteName ResultsDirectory} {
  # Write the HTML code coverage report of a build.
  #  TestSuiteName    - Name of the build, whose merged database is reported.
  #  ResultsDirectory - The build's code coverage directory.
  #
  # Called at the end of a build that ran a simulation with code coverage, after `vendor_MergeCodeCoverage`. The report
  # is read from the merged database `<ResultsDirectory>/<TestSuiteName>` and written next to it; the build report links
  # to it via `vendor_GetCoverageFileName`.
  #
  # Does nothing: code coverage isn't supported yet.

#  acdb report -html -i ${ResultsDirectory}/${TestSuiteName}.acdb -o ${ResultsDirectory}/${TestSuiteName}_code_cov.html
}

proc vendor_GetCoverageFileName {TestName} {
  # Return the file name of a build's HTML code coverage report.
  #  TestName - Name of the build.
  #
  # Called while writing the build's YAML report, if the build ran a simulation with code coverage. The build report
  # links to `<CoverageSubdirectory>/<result>`.
  #
  # This file names the report `<TestName>_code_cov.html`. The file isn't written, as code coverage isn't supported yet.
  #
  # Returns the report's path relative to the build's code coverage directory.
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}

# -------------------------------------------------
# Export Coverage
#
proc vendor_ExportCodeCoverage {BuildName CodeCoverageDirectory FileName Options} {
  # Export the code coverage of a build into a well-known data format.
  #  BuildName             - Name of the build.
  #  CodeCoverageDirectory - The build's code coverage directory.
  #  FileName              - The file to write; empty: the simulator's default name in *CodeCoverageDirectory*.
  #  Options               - Further options of the simulator's export command.
  #
  # Called by [ExportCodeCoverage], and at the end of a build that collected code coverage if [SetCoverageExportEnable]
  # is on.
  #
  # Vivado: no export yet; prints `ExportCodeCoverage: Not supported for <ToolName> yet.` and writes nothing.
  puts "ExportCodeCoverage: Not supported for ${::osvvm::ToolName} yet."
}
