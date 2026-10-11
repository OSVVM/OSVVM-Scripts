#  File Name:         VendorScripts_Xcelium.tcl
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
#     5/2024   2024.05    Added ToolVersion variable
#    12/2022   2022.12    Updated StartTranscript, StopTranscript, Analyze, Simulate
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
  variable ToolVendor  "Cadence"
  variable ToolName    "Xcelium"
  variable ToolSupportsGenericPackages "false"
  variable ToolVersion     [lindex [exec xmvhdl -version] 2]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion

  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead

# -------------------------------------------------
# StartTranscript / StopTranscript
#

#
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

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
  # Matches lines containing `xmvhdl`, `xmelab` or `xmsim` anywhere.
  #
  # Returns `1` if the line is a command of this simulator, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {xmvhdl xmelab xmsim}}]
    return [regexp {xmvhdl|xmelab|xmsim} $LineOfText]
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
  # Xcelium: none.
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
  # Xcelium: no translation yet; always empty.
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
  # Prints the library path and creates the directory `<PathToLib>/<LibraryName>` if it doesn't exist. Xcelium finds the
  # libraries through `cds.lib`, written by `CreateToolSetup` before each analyze and simulate.
  set PathAndLib ${PathToLib}/${LibraryName}
  puts $PathAndLib

  if {![file exists ${PathAndLib}]} {
    puts "file mkdir    ${PathAndLib}"
          file mkdir    ${PathAndLib}
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
  # Does nothing: `CreateToolSetup` writes all libraries of OSVVM's library list into `cds.lib`.
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Remove a library's mapping from the simulator.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [RemoveLibrary], [RemoveLibraryDirectory] and [RemoveAllLibraries] before the library directory is
  # deleted. An error is caught and printed as `LibraryError`.
  #
  # Does nothing: `CreateToolSetup` writes all libraries of OSVVM's library list into `cds.lib`.
}


# -------------------------------------------------
proc CreateToolSetup {} {
  # Write the library mapping files `cds.lib` and `hdl.var`.
  #
  # Writes `cds.lib` in the current directory: an include of Xcelium's own `cds.lib` and one `define <LibraryName>
  # <PathToLib>/<LibraryName>` line per library of OSVVM's library list. Writes `hdl.var` only if it doesn't exist: an
  # include of Xcelium's own `hdl.var` and `DEFINE intovf_severity_level WARNING`. Called by `vendor_analyze_vhdl`,
  # `vendor_analyze_verilog` and `vendor_simulate` before each run of an Xcelium tool.
  variable LibraryList

  set SetupFile [open "cds.lib" w]
  puts $SetupFile "softinclude \$CDS_INST_DIR/tools/inca/files/cds.lib"

  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lreplace $item 0 0]
    puts $SetupFile "define ${LibraryName} ${PathToLib}/${LibraryName}"
  }
  close $SetupFile

  if {![file exists hdl.var]} {
    set HdlFile [open "hdl.var" w]
    puts $HdlFile "softinclude \$CDS_INST_DIR/tools/inca/files/hdl.var"
    puts  $HdlFile "DEFINE intovf_severity_level WARNING"
    close $HdlFile
  }
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
  # Writes the library mapping (`CreateToolSetup`), then runs `xmvhdl -v200x -messages -IEEE2008 -controlrelax ALWGLOBAL
  # -w <LibraryName> -update <options> <FileName>`, whatever VHDL version is set. On an error, prints the message
  # prefixed with `Error:` and raises `Failed: analyze <FileName>`.
  variable VhdlShortVersion
  variable VhdlLibraryFullPath
#  variable VENDOR_TRANSCRIPT_FILE

  CreateToolSetup

##  exec echo "xmvhdl -v200x -messages -inc_v200x_pkg -controlrelax ALWGLOBAL -ENB_SLV_SULV_INTOPT -w ${LibraryName} -update ${FileName}"
##  exec       xmvhdl -v200x -messages -inc_v200x_pkg -controlrelax ALWGLOBAL -ENB_SLV_SULV_INTOPT -w ${LibraryName} -update ${FileName}
###  exec       xmvhdl -v200x -messages -inc_v200x_pkg -controlrelax ALWGLOBAL -ENB_SLV_SULV_INTOPT -w ${LibraryName} -update ${FileName}  |& tee -a ${VENDOR_TRANSCRIPT_FILE}
####  exec       xmvhdl -CDSLIB cds.lib -v200x -messages -inc_v200x_pkg -controlrelax ALWGLOBAL -ENB_SLV_SULV_INTOPT -w ${LibraryName} -update ${FileName}  |& tee -a ${VENDOR_TRANSCRIPT_FILE}

  set  AnalyzeOptions [concat -v200x -messages -IEEE2008 -controlrelax ALWGLOBAL -w ${LibraryName} -update {*}${args} ${FileName}]
  puts "xmvhdl $AnalyzeOptions"
  if {[catch {exec xmvhdl {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
    PrintWithPrefix "Error:" $AnalyzeErrorMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeErrorMessage
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
  # Writes the library mapping (`CreateToolSetup`). Verilog isn't supported: prints `Verilog is not supported for now`
  # and returns without error.

#  Untested branch for Verilog - will need adjustment
  CreateToolSetup

   puts "Verilog is not supported for now"
#        vlog -work ${LibraryName} ${FileName}
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
  # Does nothing: Xcelium runs each simulation as a separate process.

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
  # Writes the library mapping (`CreateToolSetup`) and the run script `temp_Cadence_run.tcl`. The run script sets
  # `assert_stop_level failure` and `intovf_severity_level WARNING`, sources the existing ones of these user scripts in
  # this order: `<ToolVendor>.tcl` and `<ToolName>.tcl` in the OSVVM script directory, `<ToolVendor>.tcl`,
  # `<ToolName>.tcl`, `wave.do` (with `do`), `<LibraryUnit>.tcl` and `<LibraryUnit>_<ToolName>.tcl` in the current
  # directory; then `run` and `exit`.
  #
  # Elaborates with `xmelab <ExtendedElaborateOptions> <LibraryName>.<LibraryUnit>` and runs `xmsim <ExtendedRunOptions>
  # -input temp_Cadence_run.tcl <LibraryName>.<LibraryUnit>`. On an error, prints the message prefixed with `Error:` and
  # raises `Failed: simulate <LibraryUnit> during xmelab` or `... during xmsim`.
  #
  # The options in `args` and the generics aren't passed to Xcelium. Code coverage isn't supported.
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor
  variable ToolName
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions
#  variable VENDOR_TRANSCRIPT_FILE

#!!TODO:   Where do generics get applied:   {*}${::osvvm::GenericOptions}

  CreateToolSetup

  # Building the temp_Cadence_run.tcl Script
  set RunFile [open "temp_Cadence_run.tcl" w]

  puts  $RunFile "set assert_stop_level failure"
  puts  $RunFile "set intovf_severity_level WARNING"

  # Project Vendor script
  if {[file exists ${OsvvmScriptDirectory}/${ToolVendor}.tcl]} {
    puts  $RunFile "source ${OsvvmScriptDirectory}/${ToolVendor}.tcl"
  }
# Project Simulator Script
  if {[file exists ${OsvvmScriptDirectory}/${ToolName}.tcl]} {
    puts  $RunFile "source ${OsvvmScriptDirectory}/${ToolName}.tcl"
  }

### User level settings for simulator in the simulation run directory
# User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    puts  $RunFile "source ${ToolVendor}.tcl"
  }
# User Simulator Script
  if {[file exists ${ToolName}.tcl]} {
    puts  $RunFile "source ${ToolName}.tcl"
  }
# User wave.do
  if {[file exists wave.do]} {
    puts  $RunFile "do wave.do"
  }
# User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    puts  $RunFile "source ${LibraryUnit}.tcl"
  }
# User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${ToolName}.tcl]} {
    puts  $RunFile "source ${LibraryUnit}_${ToolName}.tcl"
  }
  puts  $RunFile "run"

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
#   puts $RunFile "Save Coverage Information Command Goes here"
  }

  puts  $RunFile "exit"
  close $RunFile

##  # removed $args  {*}${::osvvm::GenericOptions}
##  puts  "xmelab  ${LibraryName}.${LibraryUnit}"
##  eval  exec xmelab  ${LibraryName}.${LibraryUnit}
###  eval  exec xmelab  ${LibraryName}.${LibraryUnit} |& tee -a ${VENDOR_TRANSCRIPT_FILE}

  set ElaborateOptions [concat {*}${ExtendedElaborateOptions} ${LibraryName}.${LibraryUnit}]
  puts "xmelab ${ElaborateOptions}"
  if { [catch {exec xmelab {*}${ElaborateOptions}} SimulateErrorMessage]} {
    PrintWithPrefix "Error:" $SimulateErrorMessage
    error "Failed: simulate $LibraryUnit during xmelab"
  } else {
    puts $SimulateErrorMessage
  }

##  puts  "xmsim  -input temp_Cadence_run.tcl ${LibraryName}.${LibraryUnit}"
##  exec  xmsim  -input temp_Cadence_run.tcl ${LibraryName}.${LibraryUnit}
###  exec  xmsim  -input temp_Cadence_run.tcl ${LibraryName}.${LibraryUnit} |& tee -a ${VENDOR_TRANSCRIPT_FILE}
###  run
###  exit

  set SimulateOptions [concat {*}${ExtendedRunOptions} -input temp_Cadence_run.tcl ${LibraryName}.${LibraryUnit}]
  puts "xmsim ${SimulateOptions}"
  if { [catch {exec xmsim {*}${SimulateOptions}} SimulateErrorMessage]} {
    PrintWithPrefix "Error:" $SimulateErrorMessage
    error "Failed: simulate $LibraryUnit during xmsim"
  } else {
    puts $SimulateErrorMessage
  }

}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  # Return the simulator option that sets a generic.
  #  Name  - Name of the generic.
  #  Value - Value of the generic.
  #
  # Called by [generic], which appends the result to `GenericOptions`; `vendor_simulate` adds these options.
  #
  # Returns `-g<Name>=<Value>`. Not used yet: `vendor_simulate` doesn't pass generics to Xcelium.

  return "-g${Name}=${Value}"
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
  # Xcelium: no export yet; prints `ExportCodeCoverage: Not supported for <ToolName> yet.` and writes nothing.
  puts "ExportCodeCoverage: Not supported for ${::osvvm::ToolName} yet."
}
