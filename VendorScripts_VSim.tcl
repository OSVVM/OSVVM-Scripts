#  File Name:         VendorScripts_Mentor.tcl
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
#     7/2024   2024.07    Added SaveWaves functionality to save the wlf files
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

package require fileutil

# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "simulator"
  variable ToolVendor  "Siemens"
  variable SiemensVsimError 0
  catch {onElabError {set ::osvvm::SiemensVsimError 1}}

  if {![catch {vsimVersionString} msg]} {
    set VersionString [vsimVersionString]
  } else {
    set VersionString [exec vsim -version]
  }

  if {[info exists ::ToolName]} {
    variable ToolName $::ToolName
  } else {
#    if {[lindex [split [vsimVersionString]] 2] eq "ModelSim"} {}
    if {[lindex [split $VersionString] 2] eq "ModelSim"} {
      variable ToolName   "ModelSim"
    } else {
      variable ToolName   "QuestaSim"
    }
  }
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead

  if {![catch {batch_mode} msg]} {
    variable shell ""
    variable SiemensSimulateOptions ""
    if {[batch_mode]} {
      variable ToolArgs $::argv
      variable NoGui "true"
      variable SiemensSimulateOptions "-batch"
      variable DebugOptions "-debug"
    } else {
      variable ToolArgs "-gui"
      variable NoGui "false"
      variable SiemensSimulateOptions "-visualizer"
      variable DebugOptions "-debug,livesim"
    }
  } else {
    # Started from Shell
    variable shell "exec"
    variable ToolArgs "none"
    variable NoGui "true"
    variable SiemensSimulateOptions "-batch"
    variable DebugOptions "-debug"
  }

  if {![catch {vsimId} msg]} {
    variable ToolVersion [vsimId]
  } else {
    set ToolVersion tbd
  }
  variable ToolNameVersion ${ToolName}-${ToolVersion}

  if {[expr [string compare $ToolVersion "2020.1"] >= 0]} {
#    variable DebugOptions "-debug,cell"
    variable DebugOptions "+acc"
  } else {
    variable DebugOptions "+acc"
  }

#  if {[expr [string compare $ToolVersion "2024.2"] >= 0]} {
#    SetVHDLVersion 2019
#  }

  # Set if not set
  if {![info exists ::VoptArgs]} {
    set ::VoptArgs " "
  }
  if {![info exists ::VsimArgs]} {
    set ::VsimArgs " "
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
  # In the GUI, redirects the transcript with `transcript file`. In batch mode or when started from a shell, uses
  # `DefaultVendor_StartTranscript`, unless the simulator was started with `-batch` (`ToolArgs`).
  variable NoGui

#  puts "NoGui: $NoGui"

  if {$NoGui} {
    if {![regexp {\-batch} $::osvvm::ToolArgs]} {
      DefaultVendor_StartTranscript $FileName
    }
  } else {
    transcript file ""
    echo transcript file $FileName
    transcript file $FileName
  }
}

proc vendor_StopTranscript {FileName} {
  # Stop writing the simulator's transcript to a file.
  #  FileName - Path of the temporary transcript file.
  #
  # Optional. Called by [StopTranscript] at the end of a [build], before the file is copied into the build's log
  # directory. If a vendor file doesn't define it, `DefaultVendor_StopTranscript` ends the copying of stdout and stderr.
  #
  # In the GUI, closes the transcript file with `transcript file` and an empty name. Otherwise calls
  # `DefaultVendor_StopTranscript`, unless the simulator was started with `-batch`.
  variable NoGui

  # FileName not used here
#  transcript file ""
  if {$NoGui} {
    if {![regexp {\-batch} $::osvvm::ToolArgs]} {
      DefaultVendor_StopTranscript $FileName
    }
  } else {
    transcript file ""
  }
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
  # Return whether a transcript line is a command of this simulator.
  #  LineOfText - A line of the build's log.
  #
  # Called by `Log2Osvvm.tcl` while converting the build's log, to mark the lines that are simulator commands.
  #
  # Matches lines starting with `vlib`, `vmap`, `vcom`, `vlog`, `vsim`, `run`, `coverage` or `vcover`.
  #
  # Returns `1` if the line starts with one of these commands, else `0`.

#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {vlib vmap vcom vlog vopt vsim run coverage vcover}}]
  return [regexp {^vlib |^vmap |^vcom |^vlog |^vsim |^run |^coverage |^vcover } $LineOfText]
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
  # `vendor_GetCoverageKindOptions`, and returns it: `+cover=sbf` for the default kinds (statement, branch, FSM).
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
  # VSim: sets `CoverageElaborateOptions` to the options for the kinds in `CoverageKinds`, translated by
  # `vendor_GetCoverageKindOptions`, and returns it: empty, the kinds add no elaborate options for this simulator.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageElaborateOptions
  variable CoverageKinds
  set CoverageElaborateOptions [vendor_GetCoverageKindOptions elaborate $CoverageKinds]
}

proc vendor_GetCoverageKindLetters {Kinds} {
  # Translate the kinds of code coverage into the letters of `+cover=` and `vcover report -code`.
  #
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # `s` (statement), `b` (branch), `c` (condition), `e` (expression), `t` (toggle) and `f` (fsm); functional coverage
  # has no letter.
  #
  # Called by `vendor_GetCoverageKindOptions` and `vendor_ExportCodeCoverage`.
  #
  # Returns: The letters, e.g. `sbf`.
  set Letters ""
  foreach Kind $Kinds {
    append Letters [dict get {statement s branch b condition c expression e toggle t fsm f functional ""} $Kind]
  }
  return $Letters
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
  # VSim instruments code coverage at analysis: `+cover=` with `s` (statement), `b` (branch), `c` (condition), `e`
  # (expression), `t` (toggle) and `f` (fsm). Functional coverage is collected without an option.
  #
  # Returns the options for the step, or an empty string.
  if {$Step ne "analyze"} {
    return ""
  }
  set Letters [vendor_GetCoverageKindLetters $Kinds]
  if {$Letters eq ""} {
    return ""
  }
  return "+cover=$Letters"
}

proc vendor_SetCoverageSimulateDefaults {} {
  # Return the simulator's default code coverage options for simulate.
  #
  # Called at start-up by `OsvvmSettingsDefault.tcl`, which stores the result in `CoverageSimulateOptions`, and by
  # [SetCoverageKinds]. The value is added to the simulator options by [simulate] while code coverage is enabled for
  # simulate, see [SetCoverageSimulateEnable]. A user setting from [SetCoverageSimulateOptions] or
  # `OsvvmSettingsLocal.tcl` replaces it.
  #
  # Sets `CoverageSimulateOptions` to `-coverage`, which records the coverage instrumented at analysis, and returns it.
  # The kinds of code coverage add no simulate options for this simulator.
  #
  # Returns the default options, or an empty string if the simulator has none.
  variable CoverageSimulateOptions
  variable CoverageKinds
  set CoverageSimulateOptions [concat "-coverage" [vendor_GetCoverageKindOptions simulate $CoverageKinds]]
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
  # Creates the library with `vlib` as `<PathToLib>/<LibraryName>`, relative to the current directory, if that directory
  # doesn't exist, then maps it with `vmap`. When started from a shell, the commands run via `exec`.
  set PathAndLib [::fileutil::relative [pwd] ${PathToLib}/${LibraryName}]

  if {![file exists ${PathAndLib}]} {
    puts "vlib   ${PathAndLib} "
    eval $::osvvm::shell  vlib   ${PathAndLib}
  }
  puts                 "vmap   $LibraryName  ${PathAndLib}"
  eval $::osvvm::shell  vmap   $LibraryName  ${PathAndLib}
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  # Make an existing library visible to the simulator, without making it the working library.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [LinkLibrary], [LinkLibraryDirectory] and [LinkCurrentLibraries] for each library. An error is caught and
  # reported via `CallbackOnError_LinkLibrary`.
  #
  # Maps the library with `vmap` to `<PathToLib>/<LibraryName>` if that directory exists, else to `PathToLib`. When
  # started from a shell, the command runs via `exec`.
  set PathAndLib [::fileutil::relative [pwd] ${PathToLib}/${LibraryName}]

  if {[file exists ${PathAndLib}]} {
    set ResolvedLib ${PathAndLib}
  } else {
    set ResolvedLib ${PathToLib}
  }
  puts                "vmap    $LibraryName  ${ResolvedLib}"
  eval $::osvvm::shell vmap    $LibraryName  ${ResolvedLib}
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Remove a library's mapping from the simulator.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory containing the library.
  #
  # Called by [RemoveLibrary], [RemoveLibraryDirectory] and [RemoveAllLibraries] before the library directory is
  # deleted. An error is caught and printed as `LibraryError`.
  #
  # Removes the mapping with `vmap -del`. When started from a shell, the command runs via `exec`.
  eval $::osvvm::shell vmap -del ${LibraryName}
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
  # Runs `vcom -<VhdlVersion> -work <LibraryName>` with the options and the file. When started from a shell, the command
  # runs via `exec`.
  variable VhdlVersion

  set  AnalyzeOptions [concat -${VhdlVersion} -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vcom $AnalyzeOptions"
  eval $::osvvm::shell vcom {*}$AnalyzeOptions
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
  # Runs `vlog` with `-L <library>` for each library in OSVVM's library list, `-work <LibraryName>`, the options and the
  # file. When started from a shell, the command runs via `exec`.
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-L "] -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vlog $AnalyzeOptions"
  eval $::osvvm::shell vlog {*}$AnalyzeOptions
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
  # Does nothing: closing the source windows and `quit -sim` are commented out.
  global SourceMap
  variable NoGui

#  # close junk in source window
#  if {! $NoGui} {
#    if {![catch {noview} msg]} {
#      foreach index [array names SourceMap] {
#        noview source [file tail $index]
#      }
#    }
#  }
#
#  quit -sim
}

# -------------------------------------------------
# vendor_simulate
#
# Note about ignored vsim warnings:
# During simulation OSVVM suppresses QuestaSim/ModelSim messages 8683 and 8684.
# These are warnings about potential issues with port drivers due to QuestaSim/ModelSim
# using non-VHDL compliant optimizations.  The potential issues these warn about
# do not occur with OSVVM interfaces.   As a result, these warnings are suppressed
# because they consume significant time at the startup of simulations.
#
# You can learn more about these messages by doing “verror 8683” or “verror 8684”
# from within the tool GUI.
#
# verror 8683
# ------------------------------------------
#
# An output port has no default expression in its declaration and has no drivers.
# The VHDL LRM-compliant value it propagates to higher-level connected signals may
# not be what is desired.  In particular, this behavior might not correspond to
# the synthesis view of initialization.  The vsim switch "-defaultstdlogicinittoz"
# or "-forcestdlogicinittoz" may be useful in this situation.
#
# OSVVM Analysis of Message # 8683
# ------------------------------------------
#
# OSVVM interfaces that is used to connect VC to the test sequencer (TestCtrl) use
# minimum as a resolution function.  Driving the default value (type'left) on a
# signal has no negative impact.  Hence, OSVVM disables this warning since it does
# not apply.
#
# verror 8684
# ------------------------------------------
#
# An output port having no drivers has been combined with a higher-level connected
# signal.  The port will get its initial value from this higher-level connected
# signal; this is not compliant with the behavior required by the VHDL LRM.
#
# LRM compliant behavior would require the port's initial value come from its
# declaration, however, since it was combined or collapsed with the port or signal
# higher in the hierarchy, the initial value came from that port or signal.
#
# LRM compliant behavior can be obtained by preventing the collapsing of these ports
# with the vsim switch -donotcollapsepartiallydriven. If the port is collapsed to a
# port or signal with the same initialization (as is often the case of default
# initializations being applied), there is no problem and the proper initialization
# is done and the simulation is LRM compliant.
#
# OSVVM Analysis of Message # 8684
# ------------------------------------------
#
# Older OSVVM VC use records whose elements are std_logic_vector.   These VC
# initialize port values to 'Z'.  QuestaSim non-VHDL compliant optimizations, such as
# port collapsing, remove these values.  If you are using older OSVVM verification
# components, you can avoid any impact of this non compliant behavior if you initialize
# the transaction interface signal in the test harness to all 'Z'.
#
# Hence, OSVVM disables this warning since it does not apply if you use the due
# care recommended above.
#
# OSVVM recommends that you migrate older interfaces to the newer that uses types
# and resolution functions defined in ResolutionPkg such as std_logic_max,
# std_logic_vector_max, or std_logic_vector_max_c rather than std_logic or
# std_logic_vector.   ResolutionPkg supports a richer set of types, such as
# integer_max, real_max, ...
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
  # Optimizes the design with `vopt` into `<LibraryUnit>_opt`, writes `OsvvmSimRun.tcl` with
  # `vendor_CreateSimulateDoFile` and simulates with `vsim`, whose `-do` option sources `OsvvmSimRun.tcl` and exits with
  # its status. An error of `vopt` or `vsim` is an error. Prints the call and the optimize options.
  #
  # - `vopt` gets `::VoptArgs`, `DebugOptions` (`+acc`) in the GUI with [SetDebugMode], `-work` and `-L <LibraryName>`,
  #   the design unit and the second top-level unit ([SetSecondSimulationTopLevel]). Its design file
  #   `<TestCaseFileName>_design.bin` goes to `ReportsTestSuiteDirectory`.
  # - `vsim` gets `::VsimArgs`, `SiemensSimulateOptions` (`-batch` in batch mode or from a shell, `-visualizer` in the
  #   GUI), `-t <SimulateTimeUnits>`, `-lib <LibraryName>`, `<LibraryUnit>_opt`, the second top-level unit, the options
  #   and the generics.
  # - With [SetSaveWaves], the waveforms are written to `<TestCaseFileName>_qwave.db` (`-qwavedb`) in
  #   `ReportsTestSuiteDirectory`.
  #
  # Messages 8683 and 8684 (port driver warnings) are suppressed with `-suppress`; see the note above this procedure.
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable TestSuiteName
  variable TestCaseFileName
  variable ReportsTestSuiteDirectory

  puts "vendor_simulate $LibraryName $LibraryUnit $args"

  if {($::osvvm::NoGui) || !($::osvvm::Debug)} {
	  set OptimizeOptions " "
  } else {
	  set OptimizeOptions $::osvvm::DebugOptions
  }

  set OptimizeOptions [concat $::VoptArgs $OptimizeOptions  -work ${LibraryName} -L ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} -o ${LibraryUnit}_opt ]
  puts "OptimizeOptions: $OptimizeOptions"

# This probably belongs in the library directory
  puts "vopt {*}${OptimizeOptions} -designfile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_design.bin]"
  set ErrorCode [catch {eval $::osvvm::shell vopt {*}${OptimizeOptions} -quiet -designfile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_design.bin]} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: vopt $LibraryUnit"
  } else {
    puts $CatchMessage
  }


  # Create the script files
  set ErrorCode [catch {vendor_CreateSimulateDoFile $LibraryUnit OsvvmSimRun.tcl} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: vendor_CreateSimulateDoFile $LibraryUnit"
  }

  if {$::osvvm::SaveWaves} {
    set WaveOptions "-qwavedb=+signals+wavefile=[file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_qwave.db]"
  } else {
    set WaveOptions ""
  }

  set SimulateOptions [concat $::VsimArgs $::osvvm::SiemensSimulateOptions -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}_opt ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}${::osvvm::GenericOptions} -suppress 8683 -suppress 8684]

  puts "vsim {*}${SimulateOptions} {*}${WaveOptions} -do \"exit -code \[catch {source OsvvmSimRun.tcl}\]\""
  set ErrorCode [catch {$::osvvm::shell vsim {*}${SimulateOptions} {*}${WaveOptions} -do "exit -code \[catch {source OsvvmSimRun.tcl}\]"} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $CatchMessage
  }
}

# -------------------------------------------------
# vendor_CreateSimulateDoFile
#
proc vendor_CreateSimulateDoFile {LibraryUnit ScriptFileName} {
  # Write the script the simulator runs after loading the design.
  #  LibraryUnit    - Top-level design unit of the simulation.
  #  ScriptFileName - Path of the script file to write.
  #
  # Called by `vendor_simulate` of this file. The script holds the user scripts found by `SimulateCreateDoFile`, signal
  # logging if [SetLogSignals] is on, the run command and, if code coverage is enabled for simulate, the command saving
  # the coverage database.
  #
  # The script contains, in this order:
  #
  # - `do <OsvvmScriptDirectory>/Siemens.do`, if that file exists,
  # - the user scripts found by `SimulateCreateDoFile`,
  # - `run -all`,
  # - `coverage save <CoverageDirectory>/<TestSuiteName>/<TestCaseFileName>.ucdb`, if code coverage is enabled for
  #   simulate.
  #
  # Signal logging for [SetLogSignals] is commented out.
  variable ScriptFile

  # Open File
  set ScriptFile [open $ScriptFileName w]

  # Do Vendor Simulate pre-run stuff here

  # Historical name.  Must be run with "do" for actions to work
  if {[file exists ${::osvvm::OsvvmScriptDirectory}/Siemens.do]} {
    puts  $ScriptFile  "do ${::osvvm::OsvvmScriptDirectory}/Siemens.do"
  }

  SimulateCreateDoFile $LibraryUnit

#?? is it possible that we want to save waves in a batch simulator
#  if {$::osvvm::LogSignals} {
#    puts $ScriptFile "catch {add log -r [env]/*}"
#  }

  puts  $ScriptFile "run -all"

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    puts $ScriptFile "coverage save ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseFileName}.ucdb"
  }

#  puts  $ScriptFile "quit"
  close $ScriptFile
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  # Return the simulator option that sets a generic.
  #  Name  - Name of the generic.
  #  Value - Value of the generic.
  #
  # Called by [generic], which appends the result to `GenericOptions`; `vendor_simulate` adds these options.
  #
  # The option is `-g<Name>=<Value>`.
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
  # Called at the end of a test suite, which ran with code coverage, with the test suite's name and the build name: the
  # databases in `<CoverageDirectory>/<TestSuiteName>` are merged into
  # `<CoverageDirectory>/<BuildName>/<TestSuiteName>`. Called at the end of the build with the build name and an empty
  # `BuildName`: the test suite databases are merged into `<CoverageDirectory>/<BuildName>`. [MergeCoverage] calls it
  # with a test suite name and a merge name.
  #
  # Runs `vcover merge` of the `*.ucdb` files in `<CoverageDirectory>/<TestSuiteName>` into
  # `<CoverageDirectory>/<BuildName>/<TestSuiteName>.ucdb`; does nothing if there are none.
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.ucdb]
  if {$CovFiles ne ""} {
    eval $::osvvm::shell vcover merge ${CoverageFileBaseName}.ucdb {*}$CovFiles
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
  # Runs `vcover report -html -annotate -details -verbose` on `<CodeCoverageDirectory>/<TestSuiteName>.ucdb` and writes
  # the report into the directory `<CodeCoverageDirectory>/<TestSuiteName>_code_cov`, which is deleted first.
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists $CodeCovResultsDir]} {
    file delete -force -- $CodeCovResultsDir
  }
  eval $::osvvm::shell vcover report -html -annotate -details -verbose -output ${CodeCovResultsDir} ${CodeCoverageDirectory}/${TestSuiteName}.ucdb
}

proc vendor_GetCoverageFileName {TestName} {
  # Return the file name of a build's HTML code coverage report.
  #  TestName - Name of the build.
  #
  # Called while writing the build's YAML report, if the build ran a simulation with code coverage. The build report
  # links to `<CoverageSubdirectory>/<result>`.
  #
  # Returns the report's path relative to the build's code coverage directory: `<TestName>_code_cov/index.html`.
  set CoverageFileName ${TestName}_code_cov/index.html
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
  # VSim: `vcover report -xml -details -code <letters>` writes the coverage report XML from `<BuildName>.ucdb`; the
  # default file is `<BuildName>_code_cov.questa.xml`. `-details` writes per instance the source files, statements and
  # branches with their counts; `-code` chooses the kinds in `CoverageKinds` (see `vendor_GetCoverageKindLetters`).
  # Without a database, prints a message and writes nothing.
  set CoverageFile ${CodeCoverageDirectory}/${BuildName}.ucdb
  if {$FileName eq ""} {
    set FileName ${CodeCoverageDirectory}/${BuildName}_code_cov.questa.xml
  }
  if {![file exists $CoverageFile]} {
    puts "ExportCodeCoverage: No code coverage database '$CoverageFile'."
    return
  }
  set CodeOptions ""
  set Letters [vendor_GetCoverageKindLetters $::osvvm::CoverageKinds]
  if {$Letters ne ""} {
    set CodeOptions "-code $Letters"
  }
  puts "vcover report -xml -details $CodeOptions -output ${FileName} $Options ${CoverageFile}"
  eval $::osvvm::shell vcover report -xml -details {*}$CodeOptions -output ${FileName} {*}$Options ${CoverageFile}
}
