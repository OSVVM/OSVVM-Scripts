#  File Name:         VendorScripts_NVC.tcl
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
#     1/2026   2026.01    Added Supports2019fff to identify 2019 features supported
#     7/2024   2024.07    Added ability to find nvc on the search path
#     5/2024   2024.05    Added ToolVersion variable
#     1/2023   2023.01    Added options for CoSim
#    10/2022              Initial Version based on VendorScripts_GHDL.tcl
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2020 - 2022 by SynthWorks Design Inc.
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
  variable ToolType   "simulator"
  variable ToolVendor "NVC"
  variable ToolName   "NVC"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead

  # required for mintty
  if {[file writable "/dev/pty0" ]} {
    variable console "/dev/pty0"
  } else {
    variable console {}
  }

#  set nvc {*}[auto_execok nvc]
  if {[catch {[exec which nvc]} msg]} {
    set nvc nvc   ;# not running on linux/MSYS2
  } elseif { [info exists ::env(MSYSTEM)] } {
    # running on MSYS2 - convert which with cygpath
    set nvc [exec cygpath -m [exec which nvc]]
  } else {
    set nvc [exec which nvc]
  }

  regexp {nvc\s+\d+\.\d+\S*} [exec $nvc --version] VersionString
  variable ToolVersion [regsub {nvc\s+} $VersionString ""]
  variable ToolNameVersion ${ToolName}-${ToolVersion}

  if {[expr [string compare $ToolVersion "1.15.2"] >= 0]} {
    variable FunctionalCoverageIntegratedInSimulator "NVC"
  }

  if {[expr [string compare $ToolVersion "1.13.2"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019ImpureFunctions     "true"
  }

  if {[expr [string compare $ToolVersion "1.15.2"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019Interface           "true"
    variable Supports2019ImpureFunctions     "true"
    variable Supports2019FilePath            "true"
    variable Supports2019AssertApi           "true"
    variable Supports2019Integer64Bits       "true"
  }
  if {[expr [string compare $ToolVersion "1.20"] >= 0]} {
    variable Supports2019Generics            "true"
  }

  # Default memory to use for NVC
  variable SimulatorMemory         "-H 128m"
  variable ExtendedGlobalOptions   "--stderr=failure --ieee-warnings=off-at-0 --ignore-time"
  variable ExtendedRunOptions      "--exit-severity=failure"

  # Further options of NVC's code coverage, added to --cover=<kinds>,<options>: a space separated list, e.g.
  # "fsm-no-default-enums count-from-undefined". They become part of CoverageElaborateOptions when it is derived from
  # the kinds: set it in OsvvmSettingsLocal_NVC.tcl followed by
  #   variable CoverageElaborateOptions [vendor_SetCoverageElaborateDefaults]
  # or call SetCoverageKinds afterwards.
  variable NvcExtendedCoverageOptions ""

# -------------------------------------------------
# StartTranscript / StopTranscript
#

#
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageElaborateOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  # Return the simulator's default code coverage options for analyze.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageAnalyzeOptions`, and by
  # [SetCoverageKinds]. The value is used by [analyze] while code coverage is enabled for analyze, see
  # [SetCoverageAnalyzeEnable]. A user setting from [SetCoverageAnalyzeOptions] or `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Sets `CoverageAnalyzeOptions` to the options for the kinds in `CoverageKinds`, translated by
  # `vendor_GetCoverageKindOptions`, and returns it: empty, NVC has no code coverage options for
  # analysis.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageAnalyzeOptions
  variable CoverageKinds
  set CoverageAnalyzeOptions [vendor_GetCoverageKindOptions analyze $CoverageKinds]
}

proc vendor_SetCoverageElaborateDefaults {} {
  # Return the simulator's default code coverage options for elaboration.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageElaborateOptions`, and by
  # [SetCoverageKinds]. The value is passed to the elaboration by [simulate] (`ElaborateOptions`) while code coverage is
  # enabled for simulate, see [SetCoverageSimulateEnable]. A user setting from [SetCoverageElaborateOptions] or
  # `OsvvmSettingsLocal.tcl` replaces it.
  #
  # NVC: sets `CoverageElaborateOptions` to the options for the kinds in `CoverageKinds`, translated by
  # `vendor_GetCoverageKindOptions`, and returns it: `--cover=statement,branch,fsm-state` for the default kinds,
  # followed by NVC's further code coverage options in `NvcExtendedCoverageOptions`.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageElaborateOptions
  variable CoverageKinds
  set CoverageElaborateOptions [vendor_GetCoverageKindOptions elaborate $CoverageKinds]
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
  # NVC collects code coverage at elaboration: `--cover=...` with `statement`, `branch`, `expression` (for both
  # `condition` and `expression`), `toggle`, `fsm-state` (for `fsm`) and `functional`, followed by NVC's further code
  # coverage options in `NvcExtendedCoverageOptions`, e.g. `fsm-no-default-enums`:
  # `--cover=statement,branch,fsm-state,fsm-no-default-enums`.
  #
  # Returns the options for the step, or an empty string.
  variable NvcExtendedCoverageOptions

  if {$Step ne "elaborate"} {
    return ""
  }
  set NvcKinds {}
  foreach Kind $Kinds {
    set NvcKind [dict get {statement statement branch branch condition expression expression expression toggle toggle fsm fsm-state functional functional} $Kind]
    if {[lsearch -exact $NvcKinds $NvcKind] < 0} {
      lappend NvcKinds $NvcKind
    }
  }
  set CoverItems [concat $NvcKinds $NvcExtendedCoverageOptions]
  if {$CoverItems eq ""} {
    return ""
  }
  return "--cover=[join $CoverItems ","]"
}

proc vendor_SetCoverageSimulateDefaults {} {
  # Return the simulator's default code coverage options for simulate.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageSimulateOptions`, and by
  # [SetCoverageKinds]. The value is added to the simulator options by [simulate] while code coverage is enabled for
  # simulate, see [SetCoverageSimulateEnable]. A user setting from [SetCoverageSimulateOptions] or
  # `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Sets `CoverageSimulateOptions` to the options for the kinds in `CoverageKinds` and returns it: empty, NVC collects
  # code coverage at elaboration (see `vendor_SetCoverageElaborateDefaults`).
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageSimulateOptions
  variable CoverageKinds
  set CoverageSimulateOptions [vendor_GetCoverageKindOptions simulate $CoverageKinds]
}

# -------------------------------------------------
# Exit Code
#
# proc ExitCode {Code {Message ""}} {
#   puts $Message
#   exit -code $Code
# }

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
  # Return whether a transcript line is a command of this simulator.
  #  LineOfText - A line of the transcript.
  #
  # Used by `Log2Osvvm.tcl` to recognize the simulator commands in a log file. NVC: a line starting with `nvc `.
  #
  # Returns `1` if the line is an NVC command, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {nvc}}]
  return [regexp {^nvc } $LineOfText]
}

# -------------------------------------------------
# Library
#
proc NvcLibraryPath {LibraryName PathToLib} {
  # Return the path of an NVC library, without the VHDL version suffix.
  #  LibraryName - Name of the library.
  #  PathToLib   - Directory containing the library.
  #
  # The path is `<PathToLib>/<library name in upper case>`. The callers append `.<VHDL version>`, with the short VHDL
  # version such as `19`, to get the library directory.
  #
  # Returns the library's path without the version suffix.
  set PathAndLib "${PathToLib}/[string toupper ${LibraryName}]"
  return $PathAndLib
}

proc vendor_library {LibraryName PathToLib} {
  # Create a library if it doesn't exist, and make it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [library] after it resolved the directory and created it. An error is caught by [library] and reported
  # via `CallbackOnError_Library`.
  #
  # NVC: runs `nvc --std=<VHDL version> --work=<LibraryName>:<path>.<VHDL version> --init` with the path from
  # `NvcLibraryPath`, adds `-L <PathToLib>` to the library search paths `VHDL_RESOURCE_LIBRARY_PATHS`, if not yet in it,
  # and stores the path in `NVC_WORKING_LIBRARY_PATH`, which [analyze] and [simulate] use with `--work`. If `nvc` fails,
  # prints its output and raises the error `Failed: library init <LibraryName> (<path>)`.
  variable nvc
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable NVC_WORKING_LIBRARY_PATH
  variable VhdlShortVersion

  set PathAndLib [NvcLibraryPath $LibraryName $PathToLib]

  set  GlobalOptions [concat --std=${VhdlShortVersion} --work=${LibraryName}:${PathAndLib}.${VhdlShortVersion}]
  puts "nvc ${GlobalOptions} --init"
  if {[catch {exec $nvc {*}${GlobalOptions} --init} InitErrorMessage]} {
    puts $InitErrorMessage
    error "Failed: library init $LibraryName ($PathAndLib)"
  }


  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-L $PathToLib"
  }
  set NVC_WORKING_LIBRARY_PATH $PathAndLib
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught
  # and reported via `CallbackOnError_LinkLibrary`.
  #
  # NVC: adds `-L <PathToLib>` to the library search paths `VHDL_RESOURCE_LIBRARY_PATHS`, if not yet in it.
  variable VHDL_RESOURCE_LIBRARY_PATHS

  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-L $PathToLib"
  }
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Remove a library's mapping from the simulator.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [RemoveLibrary], [RemoveLibraryDirectory] and [RemoveAllLibraries] before the library directory is
  # deleted. An error is caught and printed as `LibraryError`.
  #
  # NVC: if no library in `LibraryList` is left in $PathToLib, removes `-L <PathToLib>` from the library search paths
  # `VHDL_RESOURCE_LIBRARY_PATHS`.
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable LibraryList

  # Was last library in directory deleted?
  if {[lsearch $LibraryList "* ${PathToLib}"] < 0} {
    # Remove it from NVC Library Paths
    set found [lsearch $VHDL_RESOURCE_LIBRARY_PATHS "-L $PathToLib"]
    if {$found >= 0} {
      set VHDL_RESOURCE_LIBRARY_PATHS [lreplace $VHDL_RESOURCE_LIBRARY_PATHS $found $found]
    }
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
  # extended analyze options, the code coverage analyze options if enabled, and the options given to [analyze]. An
  # error marks the analyze as failed.
  #
  # NVC: runs `nvc <global options> -a` with the options and the file, and prints the command and its output. The global
  # options are `--std=<VHDL version>`, `SimulatorMemory` (default `-H 128m`), `ExtendedGlobalOptions` (default
  # `--stderr=failure --ieee-warnings=off-at-0 --ignore-time`), the working library
  # `--work=<LibraryName>:<path>.<VHDL version>` and the library search paths. If `nvc` fails, prints its output with
  # the prefix `Error:` and raises the error `Failed: analyze <FileName>`.
  variable nvc
  variable VhdlShortVersion
##  variable console
##  variable NVC_TRANSCRIPT_FILE
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable VhdlLibraryFullPath
  variable NVC_WORKING_LIBRARY_PATH

  set  GlobalOptions [concat --std=${VhdlShortVersion} $::osvvm::SimulatorMemory $::osvvm::ExtendedGlobalOptions --work=${LibraryName}:${NVC_WORKING_LIBRARY_PATH}.${VhdlShortVersion} {*}${VHDL_RESOURCE_LIBRARY_PATHS}]
  set  AnalyzeOptions [concat {*}${args} ${FileName}]
  puts "nvc ${GlobalOptions} -a $AnalyzeOptions"
  if {[catch {exec $nvc {*}${GlobalOptions} -a {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
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
  # Called by [analyze] for files with extension `.v`, `.sv` or `.vh`. The options are the Verilog analyze options,
  # the extended analyze options, the code coverage analyze options if enabled, and the options given to [analyze].
  # An error marks the analyze as failed.
  #
  # NVC: runs `nvc <global options> -a` with the options and the file, and prints the command and its output. The global
  # options are `--std=<VHDL version>`, `SimulatorMemory` (default `-H 128m`), `ExtendedGlobalOptions` (default
  # `--stderr=failure --ieee-warnings=off-at-0 --ignore-time`) and the working library
  # `--work=<LibraryName>:<path>.<VHDL version>`; the VHDL version is passed, as the library may also hold VHDL units.
  # If `nvc` fails, prints its output with the prefix `Error:` and raises the error `Failed: analyze <FileName>`.
  variable nvc
  variable VhdlShortVersion
  variable NVC_WORKING_LIBRARY_PATH

  # VhdlShortVersion must be passed here for compatibility with VHDL
  # sources analyzed into the same library.
  set  GlobalOptions [concat --std=${VhdlShortVersion} $::osvvm::SimulatorMemory $::osvvm::ExtendedGlobalOptions --work=${LibraryName}:${NVC_WORKING_LIBRARY_PATH}.${VhdlShortVersion}]
  set  AnalyzeOptions [concat {*}${args} ${FileName}]
  puts "nvc ${GlobalOptions} -a $AnalyzeOptions"
  if {[catch {exec $nvc {*}${GlobalOptions} -a {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
    PrintWithPrefix "Error:" $AnalyzeErrorMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeErrorMessage
  }
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
  # Does nothing: each NVC simulation runs in its own process, which has ended.
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
  # given to [simulate], the extended simulate options and, if code coverage is enabled for simulate, the code
  # coverage simulate options. Generics set with [generic] are in `GenericOptions` (as returned by
  # `vendor_generic`) and `GenericDict`. An error marks the simulation as failed.
  #
  # NVC: runs `nvc <global options> -e --jit --no-save <elaborate options> <LibraryUnit> -r <run options> <LibraryUnit>`
  # in one call:
  # - global options: as for [analyze] of a VHDL file;
  # - elaborate options: OSVVM's elaborate options (`ElaborateOptions`: the code coverage elaborate options while code
  #   coverage is enabled for simulate), the extended elaborate options (see [SetExtendedElaborateOptions]), $args and
  #   the generics;
  # - run options: the extended run options (see [SetExtendedRunOptions], default `--exit-severity=failure`),
  #   `--load=./VProc.so` for a co-simulation.
  #
  # With code coverage enabled for simulate, `--cover-file` names the test case's database
  # `<CoverageDirectory>/<TestSuiteName>/<TestCaseFileName>.ncdb`, which `vendor_MergeCodeCoverage` merges. With
  # [SetSaveWaves] on, the waveform is written to `<LibraryUnit>.fst` in the test suite's reports directory. Prints the
  # command and the simulation output. If `nvc` fails, prints its output with the prefix `Error:` and raises the error
  # `Failed: simulate <LibraryUnit>`.
  variable nvc
  variable VhdlShortVersion
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable NVC_WORKING_LIBRARY_PATH
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions

  set LocalGlobalOptions    [concat --std=${VhdlShortVersion} $::osvvm::SimulatorMemory $::osvvm::ExtendedGlobalOptions --work=${LibraryName}:${NVC_WORKING_LIBRARY_PATH}.${VhdlShortVersion} {*}${VHDL_RESOURCE_LIBRARY_PATHS}]
  set LocalElaborateOptions [concat {*}${::osvvm::ElaborateOptions} {*}${ExtendedElaborateOptions} {*}${args}  {*}${::osvvm::GenericOptions}]

  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    set CoverageFile [file join ${::osvvm::CoverageDirectory} ${::osvvm::TestSuiteName} ${::osvvm::TestCaseFileName}.ncdb]
    set LocalElaborateOptions [concat {*}${LocalElaborateOptions} --cover-file=${CoverageFile}]
  }

  set CoSimRunOptions ""
  if {$::osvvm::RunningCoSim} {
    set CoSimRunOptions "--load=./VProc.so"
#    if {$::osvvm::OperatingSystemName eq "linux"} {
#      set CoSimRunOptions "--load=./VProc.so"
#    } else {
#      set ::env(NVC_FOREIGN_OBJ) VProc.so
#    }
  }

  set LocalRunOptions [concat {*}${ExtendedRunOptions} {*}${CoSimRunOptions}]
  if {$::osvvm::SaveWaves} {
    set LocalRunOptions [concat {*}${LocalRunOptions} --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.fst ]
  }

# format for select file
  set GlobalOptions ${LocalGlobalOptions}
  set ElaborateOptions [concat {*}${LocalElaborateOptions} ${LibraryUnit}]
  set RunOptions [concat {*}${LocalRunOptions} ${LibraryUnit}]

  puts "nvc ${GlobalOptions} -e --jit --no-save ${ElaborateOptions} -r ${RunOptions}"
  if { [catch {exec $nvc {*}${GlobalOptions} -e --jit --no-save {*}${ElaborateOptions} -r {*}${RunOptions} 2>@1} SimulateMessage]} {
    PrintWithPrefix "Error:" $SimulateMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $SimulateMessage
  }
}

# -------------------------------------------------
proc FindFirstFile {Name} {
  # Return the first existing file of a name in the working, simulation and script directory.
  #  Name - File name to search for.
  #
  # Searches the current working directory, the current simulation directory and the OSVVM script directory, in this
  # order. Not used by the NVC scripts.
  #
  # Returns the path of the first file found, or an empty string if none exists.
  set LocalPathName [file join ${::osvvm::CurrentWorkingDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  set LocalPathName [file join ${::osvvm::CurrentSimulationDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  set LocalPathName [file join ${::osvvm::OsvvmScriptDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  return ""
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  # Return the simulator option that sets a generic.
  #  Name  - Name of the generic.
  #  Value - Value of the generic.
  #
  # Called by [generic], which appends the result to `GenericOptions`; `vendor_simulate` adds these options.
  #
  # NVC: the elaborate option `-g<Name>=<Value>`.
  #
  # Returns the option, or an empty string if the simulator gets its generics another way.
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
  # Called at the end of a test suite, which ran with code coverage, with the test suite's name and the build name:
  # the databases in `<CoverageDirectory>/<TestSuiteName>` are merged into
  # `<CoverageDirectory>/<BuildName>/<TestSuiteName>`. Called at the end of the build with the build name and an empty
  # `BuildName`: the test suite databases are merged into `<CoverageDirectory>/<BuildName>`. [MergeCoverage] calls it
  # with a test suite name and a merge name.
  #
  # NVC: `nvc --cover-merge` merges the `*.ncdb` files into one `.ncdb` file. Without databases, nothing is merged. If
  # `nvc` fails, prints its output with the prefix `Error:` and raises the error
  # `Failed: merge code coverage of <TestSuiteName>`.
  variable nvc

  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.ncdb]
  if {$CovFiles ne ""} {
    puts "nvc --cover-merge --output=${CoverageFileBaseName}.ncdb $CovFiles"
    if {[catch {exec $nvc --cover-merge --output=${CoverageFileBaseName}.ncdb {*}$CovFiles 2>@1} MergeMessage]} {
      PrintWithPrefix "Error:" $MergeMessage
      error "Failed: merge code coverage of $TestSuiteName"
    } else {
      puts $MergeMessage
    }
  }
}

# -------------------------------------------------
# Report Coverage
#
proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
  # Write the HTML code coverage report of a build.
  #  TestSuiteName         - Name of the build, whose merged database is reported.
  #  CodeCoverageDirectory - The build's code coverage directory.
  #
  # Called at the end of a build that ran a simulation with code coverage, after `vendor_MergeCodeCoverage`. The report
  # is read from the merged database `<CodeCoverageDirectory>/<TestSuiteName>` and written next to it; the build report
  # links to it via `vendor_GetCoverageFileName`.
  #
  # NVC: `nvc --cover-report` writes `<TestSuiteName>_code_cov/index.html` from `<TestSuiteName>.ncdb` and replaces an
  # existing report directory. Without a database, nothing is written. If `nvc` fails, prints its output with the
  # prefix `Error:` and raises the error `Failed: report code coverage of <TestSuiteName>`. The Cobertura XML file is
  # written by `vendor_ExportCodeCoverage`.
  variable nvc

  set CoverageFile      ${CodeCoverageDirectory}/${TestSuiteName}.ncdb
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {![file exists $CoverageFile]} {
    return
  }
  if {[file exists $CodeCovResultsDir]} {
    file delete -force -- $CodeCovResultsDir
  }

  puts "nvc --cover-report --output=${CodeCovResultsDir} ${CoverageFile}"
  if {[catch {exec $nvc --cover-report --output=${CodeCovResultsDir} ${CoverageFile} 2>@1} ReportMessage]} {
    PrintWithPrefix "Error:" $ReportMessage
    error "Failed: report code coverage of $TestSuiteName"
  } else {
    puts $ReportMessage
  }
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
  # Called by [ExportCodeCoverage], and at the end of a build that collected code coverage if
  # [SetCoverageExportEnable] is on.
  #
  # NVC: `nvc --cover-export --format=cobertura` writes Cobertura XML from `<BuildName>.ncdb`; the default file is
  # `<BuildName>_code_cov.cobertura.xml`. The options are passed as given, e.g. `--relative=.`. Without a database,
  # prints a message and writes nothing. If `nvc` fails, prints its output with the prefix `Error:` and raises the error
  # `Failed: export code coverage of <BuildName> to Cobertura`.
  variable nvc

  set CoverageFile ${CodeCoverageDirectory}/${BuildName}.ncdb
  if {$FileName eq ""} {
    set FileName ${CodeCoverageDirectory}/${BuildName}_code_cov.cobertura.xml
  }
  if {![file exists $CoverageFile]} {
    puts "ExportCodeCoverage: No code coverage database '$CoverageFile'."
    return
  }

  puts "nvc --cover-export --format=cobertura --output=${FileName} $Options ${CoverageFile}"
  if {[catch {exec $nvc --cover-export --format=cobertura --output=${FileName} {*}$Options ${CoverageFile} 2>@1} ExportMessage]} {
    PrintWithPrefix "Error:" $ExportMessage
    error "Failed: export code coverage of $BuildName to Cobertura"
  } else {
    puts $ExportMessage
  }
}

proc vendor_GetCoverageFileName {TestName} {
  # Return the file name of a build's HTML code coverage report.
  #  TestName - Name of the build.
  #
  # Called while writing the build's YAML report, if the build ran a simulation with code coverage. The build report
  # links to `<CoverageSubdirectory>/<result>`.
  #
  # NVC: `<TestName>_code_cov/index.html`, written by `vendor_ReportCodeCoverage`.
  #
  # Returns the report's path relative to the build's code coverage directory.
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}
