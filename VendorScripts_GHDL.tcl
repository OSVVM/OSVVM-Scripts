#  File Name:         VendorScripts_GHDL.tcl
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
#     7/2024   2024.07    Added ability to find nvc on the search path
#     5/2024   2024.05    Added ToolVersion variable
#     1/2023   2023.01    Added options for CoSim
#     5/2022   2022.05    Updated variable naming
#     2/2022   2022.02    Added template of procedures needed for coverage support
#    12/2021   2021.12    Updated to use relative paths.
#     6/2021   2021.06    Updated to better handle return values from GHDL
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     9/2020   2020.09    Initial Version
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

package require fileutil

# -------------------------------------------------
# Tool Settings
#
  variable ToolType   "simulator"
  variable ToolVendor "GHDL"
  variable ToolName   "GHDL"
  variable simulator   $ToolName ; # Deprecated
##  variable ghdl "ghdl"

  # required for mintty
  if {[file writable "/dev/pty0" ]} {
    variable console "/dev/pty0"
  } else {
    variable console {}
  }

#  set ghdl {*}[auto_execok ghdl]
  if {[catch {[exec which ghdl]} msg]} {
    set ghdl ghdl   ;# not running on linux/MSYS2
  } elseif { [info exists ::env(MSYSTEM)] } {
    # running on MSYS2 - convert which with cygpath
    set ghdl [exec cygpath -m [exec which ghdl]]
  } else {
    set ghdl [exec which ghdl]
  }
  regexp {GHDL\s+\d+\.\d+\S*} [exec $ghdl --version] VersionString
  variable ToolVersion [regsub {GHDL\s+} $VersionString ""]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#  variable ToolNameVersion [regsub {\s+} $VersionString -]
#   puts $ToolNameVersion

#  variable GhdlRunOptions ""


# -------------------------------------------------
# StartTranscript / StopTranscript
#

#
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

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
  # GHDL: no defaults; code coverage isn't supported yet.
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
  # GHDL: none.
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
  # GHDL: no translation yet; always empty.
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
  # GHDL: no defaults; code coverage isn't supported yet.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageSimulateOptions
#    set defaults here
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
   # Return whether a transcript line is a command of this simulator.
   #  LineOfText - A line of the transcript.
   #
   # Used by `Log2Osvvm.tcl` to recognize the simulator commands in a log file. GHDL: a line starting with `ghdl `.
   #
   # Returns `1` if the line is a GHDL command, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {ghdl}}]
   return [regexp {^ghdl } $LineOfText]
}

# -------------------------------------------------
# Library
#
proc GhdlLibraryPath {LibraryName PathToLib} {
  # Return the path of a GHDL library directory.
  #  LibraryName - Name of the library.
  #  PathToLib   - Directory containing the library.
  #
  # The path is `<PathToLib>/<library name in lower case>/v<VHDL version>`, with the short VHDL version such as `08`,
  # relative to the current directory.
  #
  # Returns the library directory's path.
  set PathAndLib "[::fileutil::relative [pwd] ${PathToLib}/[string tolower ${LibraryName}]/v${::osvvm::VhdlShortVersion}]"
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
  # GHDL: creates the library directory `GhdlLibraryPath` returns, adds `-P<PathToLib>` to the library search paths
  # `VHDL_RESOURCE_LIBRARY_PATHS`, if not yet in it, and stores the library directory in `GHDL_WORKING_LIBRARY_PATH`,
  # which [analyze] and [simulate] use as `--workdir`.
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_TRANSCRIPT_FILE
  variable GHDL_WORKING_LIBRARY_PATH

  set PathAndLib [GhdlLibraryPath $LibraryName $PathToLib]

  CreateDirectory ${PathAndLib}

  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"
  }
  set GHDL_WORKING_LIBRARY_PATH $PathAndLib
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught
  # and reported via `CallbackOnError_LinkLibrary`.
  #
  # GHDL: adds `-P<PathToLib>` to the library search paths `VHDL_RESOURCE_LIBRARY_PATHS`, if not yet in it.
  variable VHDL_RESOURCE_LIBRARY_PATHS

  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"
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
  # GHDL: if no library in `LibraryList` is left in $PathToLib, removes `-P<PathToLib>` from the library search paths
  # `VHDL_RESOURCE_LIBRARY_PATHS`.
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable LibraryList

  # Was last library in directory deleted?
  if {[lsearch $LibraryList "* ${PathToLib}"] < 0} {
    # Remove it from GHDL Library Paths
    set found [lsearch $VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"]
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
  # GHDL: runs `ghdl -a` with `--std=<VHDL version> -Wno-library -Wno-hide`, the working library and its directory, the
  # library search paths and the options, and prints the command and its output. If `ghdl` fails, prints its output
  # with the prefix `Error:` and raises the error `Failed: analyze <FileName>`.
  variable VhdlShortVersion
  variable ghdl
##  variable console
##  variable GHDL_TRANSCRIPT_FILE
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable VhdlLibraryFullPath
  variable GHDL_WORKING_LIBRARY_PATH

  set  AnalyzeOptions [concat --std=${VhdlShortVersion} -Wno-library -Wno-hide --work=${LibraryName} --workdir=${GHDL_WORKING_LIBRARY_PATH} {*}${VHDL_RESOURCE_LIBRARY_PATHS} {*}${args} ${FileName}]
  puts "ghdl -a $AnalyzeOptions"
#  exec $ghdl -a {*}$AnalyzeOptions
  if {[catch {exec $ghdl -a {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
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
  # GHDL: not supported; prints a message and returns without an error.

  puts "Analyzing verilog files not supported by GHDL"
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
  # Does nothing: each GHDL simulation runs in its own process, which has ended.
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
  # GHDL: runs `ghdl --elab-run`, or the command in variable `GhdlRunCmd` if it exists, in one call:
  # - elaborate options: `--std=<VHDL version> --syn-binding`, the extended elaborate options (see
  # [SetExtendedElaborateOptions]), `-Wl,-lpthread` for a co-simulation on Linux, the working library and its
  # directory, the library search paths and $args;
  # - run options: the extended run options (see [SetExtendedRunOptions]) and the generics.
  #
  # With [SetSaveWaves] on, the waveform is written to `<LibraryUnit>.ghw` in the test suite's reports directory; a
  # file `<LibraryUnit>.ghdl`, found by `FindFirstFile`, selects the signals with `--read-wave-opt`. Prints the
  # command and the simulation output. If `ghdl` fails, prints its output with the prefix `Error:` and raises the
  # error `Failed: simulate <LibraryUnit>`. Code coverage isn't supported yet.
  variable ghdl
  variable VhdlShortVersion
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_WORKING_LIBRARY_PATH
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions
#  variable GhdlRunOptions
  variable GhdlRunCmd

  if {[info exists GhdlRunCmd]} {
    set runcmd $GhdlRunCmd
  } else {
    set runcmd "--elab-run"
  }

  set CoSimElaborateOptions ""
  if {$::osvvm::RunningCoSim} {
    if {$::osvvm::OperatingSystemName eq "linux"} {
      set CoSimElaborateOptions "-Wl,-lpthread"
    }
  }

  set LocalElaborateOptions [concat --std=${VhdlShortVersion} --syn-binding {*}${ExtendedElaborateOptions} {*}${CoSimElaborateOptions} --work=${LibraryName} --workdir=${GHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} {*}${args}]

  set SignalSelectionFile [FindFirstFile ${LibraryUnit}.ghdl]
  if {${SignalSelectionFile} ne ""} {
    set SignalSelectionOptions "--read-wave-opt=${SignalSelectionFile}"
  } else {
    set SignalSelectionOptions ""
  }

  if {$::osvvm::SaveWaves} {
#    set LocalRunOptions [concat {*}${ExtendedRunOptions} --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw ${SignalSelectionOptions} ${GhdlRunOptions} ]
    set LocalRunOptions [concat {*}${ExtendedRunOptions} --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw ${SignalSelectionOptions} {*}${::osvvm::GenericOptions} ]
  } else {
#    set LocalRunOptions [concat {*}${ExtendedRunOptions} ${GhdlRunOptions}]
    set LocalRunOptions [concat {*}${ExtendedRunOptions} {*}${::osvvm::GenericOptions}]
  }
#  set GhdlRunOptions ""

# format for select file
  set SimulateOptions [concat {*}${LocalElaborateOptions} ${LibraryUnit} {*}${LocalRunOptions}]
  puts "ghdl $runcmd ${SimulateOptions}"

  set SimulateErrorCode [catch {exec $ghdl $runcmd {*}${SimulateOptions} 2>@1} SimulateErrorMessage]
#  if {[file exists ${LibraryUnit}.ghw]} {
#    file rename -force ${LibraryUnit}.ghw ${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw
#  }
  if {$SimulateErrorCode != 0} {
    PrintWithPrefix "Error:" $SimulateErrorMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $SimulateErrorMessage
  }

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
#    acdb save -o ${LibraryUnit}.acdb -testname ${LibraryUnit}
  }
}

# -------------------------------------------------
proc FindFirstFile {Name} {
  # Return the first existing file of a name in the working, simulation and script directory.
  #  Name - File name to search for.
  #
  # Searches the current working directory, the current simulation directory and the OSVVM script directory, in this
  # order. [simulate] uses it to find the wave option file `<LibraryUnit>.ghdl`.
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
  # GHDL: the run option `-g<Name>=<Value>`.
  #
  # Returns the option, or an empty string if the simulator gets its generics another way.

#  variable GhdlRunOptions

#  append GhdlRunOptions "-g${Name}=${Value} "

  return "-g${Name}=${Value}"
#  return ""
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
  # is read from the merged database `<ResultsDirectory>/<TestSuiteName>` and written next to it; the build report
  # links to it via `vendor_GetCoverageFileName`.
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
  # GHDL: `<TestName>_code_cov.html`; no such file is written, code coverage isn't supported yet.
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
  # GHDL: no export yet; prints `ExportCodeCoverage: Not supported for <ToolName> yet.` and writes nothing.
  puts "ExportCodeCoverage: Not supported for ${::osvvm::ToolName} yet."
}
