#  File Name:         VendorScripts_RivieraPro.tcl
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
#     7/2024   2024.07    Added DoWaves capability
#     5/2024   2024.05    Added CloseAllFiles to vendor_end_previous_simulation.  Added ToolVersion variable
#     5/2022   2022.05    Coverage report name based on TestCaseName rather than LibraryUnit
#                         Updated variable naming
#     2/2022   2022.02    Added Coverage Collection
#    12/2021   2021.12    Updated to use relative paths.
#     3/2021   2021.03    In Simulate, added optional scripts to run as part of simulate
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute
#                         as TCL scripts in conjunction with the library
#                         procedures
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.
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
  variable ToolVendor  "Aldec"
  variable ToolName    "RivieraPRO"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead
  #  Could differentiate between RivieraPRO and VSimSA
  variable ToolVersion
  if {[catch {regexp {\d([\d\.]+)} [exec vsim -version] ToolVersion}]} {
    variable ToolVersion [asimVersion]
  }
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion

  if {[expr [string compare $ToolVersion "2021.04"] >= 0]} {
    SetVHDLVersion 2019
    # variable Supports2019Interface           "false"
    variable Supports2019ImpureFunctions     "true"
    variable Supports2019FilePath            "true"
    variable Supports2019AssertApi           "true"
    # variable Supports2019Generics            "false"
  }

  if {[expr [string compare $ToolVersion "2026.04"] >= 0]} {
    variable Supports2019Interface           "true"
    variable Supports2019Generics            "true"
  }

  if {[string match "2025.07*" $::osvvm::ToolVersion] | [string match "2026.01*" $::osvvm::ToolVersion]} {
    variable Supports2019Integer64Bits       "true"
  }

  variable FunctionalCoverageIntegratedInSimulator "Aldec"

  if {[catch {batch_mode}]} {
    # batch_mode command not exist = running from shell = in batch_mode
    variable NoGui "true"
  } elseif {[batch_mode]} {
    variable NoGui "true"
  } else {
    variable NoGui "false"
  }

# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  # Start writing the simulator's transcript to a file.
  #  FileName - Path of the temporary transcript file.
  #
  # Optional. Called by [StartTranscript] at the start of a [build]; if a vendor file doesn't define it,
  # `DefaultVendor_StartTranscript` copies stdout and stderr into the file. [StopTranscript] later moves the file into
  # the build's log directory.
  #
  # RivieraPRO: closes the current transcript file and writes the transcript to $FileName with `transcript file`.
  transcript file ""
  puts "transcript file $FileName"
  transcript file $FileName
}

proc vendor_StopTranscript {FileName} {
  # Stop writing the simulator's transcript to a file.
  #  FileName - Path of the temporary transcript file.
  #
  # Optional. Called by [StopTranscript] at the end of a [build], before the file is copied into the build's log
  # directory. If a vendor file doesn't define it, `DefaultVendor_StopTranscript` ends the copying of stdout and
  # stderr.
  #
  # RivieraPRO: closes the transcript file with `transcript file -close`.
  transcript file -close $FileName
}

# -------------------------------------------------
# Exit Code
#
proc ExitCode {Code {Message ""}} {
  # Print a message and exit the simulator with an exit code.
  #  Code    - Exit code.
  #  Message - Message printed before exiting.
  #
  # Replaces `ExitCode` of `OsvvmScriptsCore.tcl`; exits with the simulator's `exit -code`. Used by [build] at the
  # end of a build, if `ExitOnBuildDone` is set and neither interactive nor debug mode is on.
  puts $Message
  exit -code $Code
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
  # Return whether a transcript line is a command of this simulator.
  #  LineOfText - A line of the transcript.
  #
  # Used by `Log2Osvvm.tcl` to recognize the simulator commands in a log file. RivieraPRO: a line starting with one of
  # the commands `alib`, `amap`, `acom`, `alog`, `asim`, `vlib`, `vmap`, `vcom`, `vlog`, `vsim`, `run` or `acdb`,
  # followed by a space.
  #
  # Returns `1` if the line is a simulator command, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {alib amap acom alog asim vlib vmap vcom vlog vsim run acdb}}]
  return [regexp {^alib |^amap |^acom |^alog |^asim |^vlib |^vmap |^vcom |^vlog |^vsim |^run |^acdb } $LineOfText]
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
  # Sets `CoverageAnalyzeOptions` to the options for the kinds in `CoverageKinds`, translated by
  # `vendor_GetCoverageKindOptions`, and returns it: `-coverage sbm` for the default kinds (statement,
  # branch, FSM).
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
  # Riviera-PRO: sets `CoverageElaborateOptions` to the options for the kinds in `CoverageKinds`, translated by
  # `vendor_GetCoverageKindOptions`, and returns it: empty, the kinds add no elaborate options for this simulator.
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
  # Riviera-PRO instruments code coverage at analysis (`-coverage`) and collects it at simulation (`-acdb_cov`), both
  # with `s` (statement), `b` (branch), `c` (condition), `e` (expression) and `m` (fsm). Toggle coverage isn't chosen by
  # a letter; functional coverage is collected without an option.
  #
  # Returns the options for the step, or an empty string.
  set Letters ""
  foreach Kind $Kinds {
    append Letters [dict get {statement s branch b condition c expression e toggle "" fsm m functional ""} $Kind]
  }
  if {$Letters eq ""} {
    return ""
  }
  switch -exact -- $Step {
    analyze  {return "-coverage $Letters"}
    simulate {return "-acdb_cov $Letters"}
  }
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
  # Sets `CoverageSimulateOptions` to the options for the kinds (`-acdb_cov <letters>`) and `-cc_all`, and returns it:
  # `-acdb_cov sbm -cc_all` for the default kinds.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageSimulateOptions
  variable CoverageKinds
  set CoverageSimulateOptions [concat [vendor_GetCoverageKindOptions simulate $CoverageKinds] "-cc_all"]
}

# -------------------------------------------------
# Library
#
proc vendor_vlib {PathAndLib} {
    # Create a library directory with `vlib`.
    #  PathAndLib - Path of the library: its directory and name.
    #
    # Called by `vendor_library`, which retries once after 10 seconds if it fails. Prints the command.

    # after 1000
    puts "vlib    ${PathAndLib}"
          vlib    ${PathAndLib}
}

proc vendor_library {LibraryName PathToLib} {
  # Create a library if it doesn't exist, and make it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [library] after it resolved the directory and created it. An error is caught by [library] and reported
  # via `CallbackOnError_Library`.
  #
  # RivieraPRO: if `<PathToLib>/<LibraryName>` doesn't exist, creates it with `vendor_vlib`; if that fails, waits 10
  # seconds and tries once more. An existing library is mapped with `vendor_LinkLibrary`.
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    if {[catch {vendor_vlib $PathAndLib} LibraryErrMsg]} {
      # if fails first try, wait and try again
      after 10000
      vendor_vlib $PathAndLib
    }
  } else {
    vendor_LinkLibrary  $LibraryName  ${PathToLib}
  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught
  # and reported via `CallbackOnError_LinkLibrary`.
  #
  # RivieraPRO: skips a library that is already in the library list. Otherwise maps the library with `vmap` to
  # `<PathToLib>/<LibraryName>` if that exists, else to $PathToLib.
  set PathAndLib ${PathToLib}/${LibraryName}

  # Policy:  If library is already in library list, then skip this for Riviera
  if {[IsLibraryInList $LibraryName] < 0} {
    if {[file exists ${PathAndLib}]} {
      set ResolvedLib ${PathAndLib}
    } else {
      set ResolvedLib ${PathToLib}
    }
    puts "vmap    $LibraryName  ${ResolvedLib}"
          vmap    $LibraryName  ${ResolvedLib}
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
  # RivieraPRO: removes the mapping with `vmap -del -re`.
  vmap -del -re ${LibraryName}
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
  # RivieraPRO: runs `vcom -<VHDL version> -relax -work <LibraryName>` with the options and the file, and prints the
  # command. Adds `-dbg` in the GUI if [SetDebugMode] is on and code coverage is off for analyze and simulate.
  variable VhdlVersion

  set EffectiveCoverageAnalyzeEnable    [expr $::osvvm::CoverageEnable && $::osvvm::CoverageAnalyzeEnable]
  set EffectiveCoverageSimulateEnable   [expr $::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable]

  if {$::osvvm::NoGui || !($::osvvm::Debug) || $EffectiveCoverageAnalyzeEnable || $EffectiveCoverageSimulateEnable} {
    set DebugOptions ""
  } else {
    set DebugOptions "-dbg"
  }

# at least with RP 2024.10, relax mode is not needed, looks like it was there in the first version of this file
#  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -work ${LibraryName} {*}${args} ${FileName}]
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -relax -work ${LibraryName} {*}${args} ${FileName}]
  puts "vcom $AnalyzeOptions"
        vcom {*}$AnalyzeOptions
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
  # RivieraPRO: runs `vlog -work <LibraryName>` with `-l <library>` for each library in the library list, the options
  # and the file, and prints the command.
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-l "] -work ${LibraryName} {*}${args} ${FileName}]
  puts "vlog $AnalyzeOptions"
        vlog {*}$AnalyzeOptions
}

# -------------------------------------------------
proc NoNullRangeWarning  {} {
  # Return the analyze option that suppresses the warning about null ranges.
  #
  # Replaces [NoNullRangeWarning] of `OsvvmScriptsCore.tcl`, which returns an empty string. Used as
  # `analyze <file> [NoNullRangeWarning]`.
  #
  # Returns `-nowarn COMP96_0119`.
  return "-nowarn COMP96_0119"
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
  # RivieraPRO: ends the simulation with `quit -sim`, closes the VHDL documents of the GUI and the files opened by
  # OSVVM's scripts (`CloseAllFiles`).
  catch {quit -sim}                    ;# catch suppresses the simulator messages
  framework.documents.closeall -vhdl
  ::osvvm::CloseAllFiles
  puts ""
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
  # RivieraPRO: loads the design with `vsim -interceptcoutput -t <SimulateTimeUnits> -lib <LibraryName> <LibraryUnit>`,
  # the second top-level unit of [SetSecondSimulationTopLevel], $args and the generics; adds `+access +r` if
  # [SetDebugMode] is on. Then runs the user scripts (`SimulateRunScripts`), logs all signals if [SetLogSignals] is
  # on, runs the wave files collected by [DoWaves], and runs the simulation with `run -all`.
  #
  # With code coverage enabled for simulate, `acdb save` writes the coverage database to
  # `<CoverageDirectory>/<TestSuiteName>/<TestCaseFileName>.acdb`, with the test case file name as test name.
  variable SimulateTimeUnits
  variable TestSuiteName
  variable TestCaseFileName
  variable SimulateOptions
  variable WaveFiles
  global aldec            ; #  required for matlab cosim

  if {($::osvvm::Debug)} {
    set DebugOptions "+access +r"
  } else {
    set DebugOptions ""
  }

#  puts "vendor_simulate  LibraryName: $LibraryName    LibraryUnit:  $LibraryUnit   args:  $args"
  set SimulateOptions [concat $DebugOptions -interceptcoutput -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}${::osvvm::GenericOptions}]

  puts "vsim ${SimulateOptions}"
        vsim {*}${SimulateOptions}

  SimulateRunScripts ${LibraryUnit}

  if {$::osvvm::LogSignals} {
    log -rec [env]/*
  }
  if {$WaveFiles ne ""} {
    foreach wave $WaveFiles {
      do $wave
    }
  }
  set WaveFiles ""
  run -all

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    acdb save -o ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseFileName}.acdb -testname ${TestCaseFileName}
  }
}

# -------------------------------------------------
proc vendor_DoWaves {args} {
  # Collect wave files to run in the next simulation.
  #  args - Wave files, as one list element.
  #
  # Optional. Called by [DoWaves], which returns this procedure's result instead of `-do` options. The files are
  # stored in `WaveFiles`; `vendor_simulate` runs them with `do` before the simulation runs and clears the list.
  #
  # Returns an empty string, so nothing is added to the [simulate] options.
  variable WaveFiles

  if {$args ne ""} {
    foreach wave {*}$args {
      lappend WaveFiles $wave
    }
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
  # RivieraPRO: `-g<Name>=<Value>`.
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
  # RivieraPRO: if `<CoverageDirectory>/<TestSuiteName>` holds `*.acdb` databases, merges them with `acdb merge` into
  # `<CoverageDirectory>/<BuildName>/<TestSuiteName>.acdb`.
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
  if {$CovFiles ne ""} {
    acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]
  }
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
  # Write the HTML code coverage report of a build.
  #  TestSuiteName         - Name of the build, whose merged database is reported.
  #  CodeCoverageDirectory - The build's code coverage directory.
  #
  # Called at the end of a build that ran a simulation with code coverage, after `vendor_MergeCodeCoverage`. The report
  # is read from the merged database `<CodeCoverageDirectory>/<TestSuiteName>` and written next to it; the build report
  # links to it via `vendor_GetCoverageFileName`.
  #
  # RivieraPRO: deletes an old report, then writes the report with `acdb report -html` into
  # `<CodeCoverageDirectory>/<TestSuiteName>_code_cov.html` and the directory `<TestSuiteName>_code_cov_files` from
  # the database `<CodeCoverageDirectory>/<TestSuiteName>.acdb`.
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists ${CodeCovResultsDir}.html]} {
    file delete -force -- ${CodeCovResultsDir}.html
  }
  if {[file exists ${CodeCovResultsDir}_files]} {
    file delete -force -- ${CodeCovResultsDir}_files
  }
  acdb report -html -i ${CodeCoverageDirectory}/${TestSuiteName}.acdb -o ${CodeCovResultsDir}.html
}

proc vendor_GetCoverageFileName {TestName} {
  # Return the file name of a build's HTML code coverage report.
  #  TestName - Name of the build.
  #
  # Called while writing the build's YAML report, if the build ran a simulation with code coverage. The build report
  # links to `<CoverageSubdirectory>/<result>`.
  #
  # RivieraPRO: `<TestName>_code_cov.html`, written by `vendor_ReportCodeCoverage`.
  #
  # Returns the report's path relative to the build's code coverage directory.
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}

# proc vendor_OpenBuildHtml {BuildHtmlFile BuildName} {
#   catch {framework.window.close -window $BuildName} Msg
#   system.open "$BuildHtmlFile" -title $BuildName
# }

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
  # Riviera-PRO: `acdb2xml` writes UCDB XML from `<BuildName>.acdb`; the default file is
  # `<BuildName>_code_cov.ucdb.xml`. The options are passed as given. Without a database, prints a message and writes
  # nothing.
  set CoverageFile ${CodeCoverageDirectory}/${BuildName}.acdb
  if {$FileName eq ""} {
    set FileName ${CodeCoverageDirectory}/${BuildName}_code_cov.ucdb.xml
  }
  if {![file exists $CoverageFile]} {
    puts "ExportCodeCoverage: No code coverage database '$CoverageFile'."
    return
  }
  puts "acdb2xml -i ${CoverageFile} -o ${FileName} $Options"
  acdb2xml -i ${CoverageFile} -o ${FileName} {*}$Options
}
