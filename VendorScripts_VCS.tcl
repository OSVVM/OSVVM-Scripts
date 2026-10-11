#  File Name:         VendorScripts_VCS.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
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
#     7/2024   2024.07    Updated ToolVersion to run vhdlan
#     5/2024   2024.05    Added ToolVersion variable
#    12/2022   2022.12    Updated StartTranscript, StopTranscript, Analyze, Simulate
#    05/2022   2022.05    Updated naming
#     2/2022   2022.02    Added template of procedures needed for coverage support
#    12/2021   2021.12    Updated to use relative paths.
#     9/2021   2021.09    Created from VendorScripts_xxx.tcl
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


# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "simulator"
  variable ToolVendor  "Synopsys"
  variable ToolName    "VCS"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead
#  variable ToolNameVersion "${ToolName}-T2022.06"
#  variable ToolVersion "T2022.06"
  variable ToolVersion [regsub {vhdlan.*: } [exec vhdlan -V] ""]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscript
#

# #
# #  Comment out these if TCL version is >= 8.6
# #
# proc vendor_StartTranscript {FileName} {
# }
#
# proc vendor_StopTranscript {FileName} {
# }

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
  # Matches lines containing `vhdlan`, `vcs` or `simv` anywhere.
  #
  # Returns `1` if the line is a command of this simulator, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {vhdlan vcs simv}}]
  return [regexp {vhdlan|vcs|simv} $LineOfText]
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
  # VCS: none.
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
  # VCS: no translation yet; always empty.
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
proc vendor_library {LibraryName PathToLib} {
  # Create a library if it doesn't exist, and make it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [library] after it resolved the directory and created it. An error is caught by [library] and reported via
  # `CallbackOnError_Library`.
  #
  # Creates the directory `<PathToLib>/<LibraryName>/64` if `<PathToLib>/<LibraryName>` doesn't exist. VCS finds the
  # libraries through `synopsys_sim.setup`, written by `CreateToolSetup` before each analyze and simulate.
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    puts "file mkdir    ${PathAndLib}"
          file mkdir    ${PathAndLib}/64
  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught and
  # reported via `CallbackOnError_LinkLibrary`.
  #
  # Does nothing: `CreateToolSetup` writes all libraries of OSVVM's library list into `synopsys_sim.setup`.
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Remove a library's mapping from the simulator.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [RemoveLibrary], [RemoveLibraryDirectory] and [RemoveAllLibraries] before the library directory is
  # deleted. An error is caught and printed as `LibraryError`.
  #
  # Does nothing: `CreateToolSetup` writes all libraries of OSVVM's library list into `synopsys_sim.setup`.
}

# -------------------------------------------------
proc CreateToolSetup {} {
  # Write the library mapping file `synopsys_sim.setup`.
  #
  # Writes `synopsys_sim.setup` in the current directory: `ASSERT_STOP=FAILURE` and one line `<LibraryName> :
  # <PathToLib>/<LibraryName>` per library of OSVVM's library list. Called by `vendor_analyze_vhdl` and
  # `vendor_simulate` before each run of a VCS tool.
  variable LibraryList

  set SetupFile [open "synopsys_sim.setup" w]
  puts $SetupFile "ASSERT_STOP=FAILURE"

  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lreplace $item 0 0]
    puts $SetupFile "${LibraryName} : ${PathToLib}/${LibraryName}"
  }
  close $SetupFile
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
  # Writes `synopsys_sim.setup` (`CreateToolSetup`), then runs `vhdlan -full64 -vhdl<VhdlShortVersion> -nc -work
  # <LibraryName> <options> <FileName>` and prints its output.
  #
  # Analyze errors aren't detected yet: the procedure doesn't raise an error.
  variable VhdlShortVersion
  variable VhdlLibraryFullPath
#  variable VENDOR_TRANSCRIPT_FILE

  CreateToolSetup

#  set  AnalyzeOptions [concat -full64 -vhdl${VhdlShortVersion} -verbose -nc -work ${LibraryName} {*}${args} ${FileName}]
  set  AnalyzeOptions [concat -full64 -vhdl${VhdlShortVersion} -nc -work ${LibraryName} {*}${args} ${FileName}]
  puts "vhdlan $AnalyzeOptions"
  set AnalyzeErrorCode [catch {exec vhdlan {*}$AnalyzeOptions} AnalyzeErrorMessage]
##    puts "AnalyzeErrorCode $AnalyzeErrorCode" ;# returns 1 on success
  puts "$AnalyzeErrorMessage"
##!! TODO:  Need vhdlan error codes for proper handling
#  if {[catch {exec vhdlan {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
#    PrintWithPrefix "Error:" $AnalyzeErrorMessage
#    error "Failed: analyze $FileName"
#  } else {
#    puts $AnalyzeErrorMessage
#  }
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
  # Verilog isn't supported: prints `Verilog is not supported for now` and returns without error.

#  Untested branch for Verilog - will need adjustment
   puts "Verilog is not supported for now"
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # End the running simulation and release its files.
  #
  # Called by [EndSimulation]: at the start of a [build] and before a [simulate] if a simulation was started, after a
  # [simulate] that failed outside interactive mode, and before exiting on report errors.
  #
  # Does nothing: VCS runs each simulation as a separate process.

#  quit -sim
#  framework.documents.closeall -vhdl
}

# -------------------------------------------------
# Simulate
#
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
  # Writes `synopsys_sim.setup` (`CreateToolSetup`) and the run script `temp_Synopsys_run.tcl`. The run script sources
  # the existing ones of these user scripts in this order: `<ToolVendor>.tcl` and `<ToolName>.tcl` in the OSVVM script
  # directory, `<ToolVendor>.tcl`, `<ToolName>.tcl`, `wave.do` (with `do`), `<LibraryUnit>.tcl` and
  # `<LibraryUnit>_<ToolName>.tcl` in the current directory; then `run` and `quit`.
  #
  # Elaborates with `vcs -full64 -time <SimulateTimeUnits> <ExtendedElaborateOptions> <LibraryName>.<LibraryUnit>`,
  # adding `-debug_access+all` in debug mode with a GUI. Generics from `GenericDict` are written to
  # `synopsys_generics.txt` (`CreateGenericFile`) and passed with `-lca -g synopsys_generics.txt`. Then runs `./simv
  # <ExtendedRunOptions> -ucli -do temp_Synopsys_run.tcl`.
  #
  # The options in `args` aren't passed to VCS. Errors of `vcs` and `simv` aren't detected yet: the procedure doesn't
  # raise an error. Code coverage isn't supported.
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor
  variable ToolName
#  variable VENDOR_TRANSCRIPT_FILE
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions

#!!TODO:   Where do generics get applied:   {*}${::osvvm::GenericOptions}

  CreateToolSetup

  # Building the Synopsys_run.tcl Script
  set SynFile [open "temp_Synopsys_run.tcl" w]

  # Project Vendor script
  if {[file exists ${OsvvmScriptDirectory}/${ToolVendor}.tcl]} {
    puts  $SynFile "source ${OsvvmScriptDirectory}/${ToolVendor}.tcl"
  }
# Project Simulator Script
  if {[file exists ${OsvvmScriptDirectory}/${ToolName}.tcl]} {
    puts  $SynFile "source ${OsvvmScriptDirectory}/${ToolName}.tcl"
  }

### User level settings for simulator in the simulation run directory
# User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    puts  $SynFile "source ${ToolVendor}.tcl"
  }
# User Simulator Script
  if {[file exists ${ToolName}.tcl]} {
    puts  $SynFile "source ${ToolName}.tcl"
  }
# User wave.do
  if {[file exists wave.do]} {
    puts  $SynFile "do wave.do"
  }
# User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}.tcl"
  }
# User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${ToolName}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}_${ToolName}.tcl"
  }
  puts  $SynFile "run"

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
#   puts $RunFile "Save Coverage Information Command Goes here"
  }

  puts  $SynFile "quit"
  close $SynFile

  if {$::osvvm::NoGui || !($::osvvm::Debug)} {
    set DebugOptions ""
  } else {
    set DebugOptions "-debug_access+all"
  }

  if {$::osvvm::GenericDict ne ""} {
    set SynopsysGenericOptions "-lca -g synopsys_generics.txt"
    CreateGenericFile ${::osvvm::GenericDict}
  } else {
    set SynopsysGenericOptions ""
  }

  set ElaborateOptions [concat -full64 -time $SimulateTimeUnits ${DebugOptions} {*}${ExtendedElaborateOptions} ${LibraryName}.${LibraryUnit} {*}${SynopsysGenericOptions}]
  puts "vcs ${ElaborateOptions}"
  set VcsErrorCode [catch {exec vcs {*}${ElaborateOptions}} SimulateErrorMessage]
#  puts "VcsErrorCode $VcsErrorCode" ;# returns 1 on success
  puts "$SimulateErrorMessage"
##!! TODO:  Need vcs error codes for proper handling
#  if { [catch {exec vcs {*}${ElaborateOptions}} SimulateErrorMessage]} {
#    PrintWithPrefix "Error:" $SimulateErrorMessage
#    error "Failed: simulate $LibraryUnit during vcs"
#  } else {
#    puts $SimulateErrorMessage
#  }

  set SimulateOptions [concat {*}${ExtendedRunOptions} -ucli -do temp_Synopsys_run.tcl]
  puts "./simv ${SimulateOptions}"
  set SimVErrorCode [catch {exec ./simv {*}${SimulateOptions}} SimulateErrorMessage]
#  puts "SimVErrorCode $SimVErrorCode" ; # returns 0 on success
  puts "$SimulateErrorMessage"

##!! TODO:  Need simv error codes
#  if { [catch {exec ./simv {*}${SimulateOptions}} SimulateErrorMessage]} {
#    PrintWithPrefix "Error:" $SimulateErrorMessage
#    error "Failed: simulate $LibraryUnit during simv"
#  } else {
#    puts $SimulateErrorMessage
#  }
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  # Return the simulator option that sets a generic.
  #  Name  - Name of the generic.
  #  Value - Value of the generic.
  #
  # Called by [generic], which appends the result to `GenericOptions`; `vendor_simulate` adds these options.
  #
  # Returns `-gv <Name>=<Value>`. Not used by `vendor_simulate`, which passes the generics in `synopsys_generics.txt`,
  # because `-gv` requires integer and real values.

  # Not used.  gvalue requires integer and real number values
  return "-gv ${Name}=${Value} "
}

# -------------------------------------------------
proc CreateGenericFile {GenericDict} {
  # Write the generics of the next simulation to `synopsys_generics.txt`.
  #  GenericDict - Generic names and values, as set by [generic].
  #
  # Writes one line `assign <Value> <Name>` per generic into `synopsys_generics.txt` in the current directory. Called by
  # `vendor_simulate`, which passes the file with `vcs -lca -g`.

  set GenericsFile [open "synopsys_generics.txt" w]
  foreach {GenericName GenericValue} $GenericDict {
    # cannot do /$LibraryUnit/$GenericName as LibraryUnit may be a configuration name
    puts $GenericsFile "assign ${GenericValue} ${GenericName}"
  }
  close $GenericsFile
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
  # VCS: no export yet; prints `ExportCodeCoverage: Not supported for <ToolName> yet.` and writes nothing.
  puts "ExportCodeCoverage: Not supported for ${::osvvm::ToolName} yet."
}
