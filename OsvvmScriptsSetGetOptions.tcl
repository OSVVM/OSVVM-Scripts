#  File Name:         OsvvmScriptsCore.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#     Markus Ferringer    Patterns for error handling and callbacks, ...
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
#    Version    Description
#    2025.06    Factored out from OsvvmScriptsCore.tcl.
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2018 - 2026 by SynthWorks Design Inc.
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
# StartUp
#   re-run the startup scripts, this program included
#
namespace eval ::osvvm {

# -------------------------------------------------
# SetVHDLVersion, GetVHDLVersion
#
proc SetVHDLVersion {Version} {
  # Set the VHDL language version used by [analyze].
  #  Version - VHDL version: `2008` or `08`, `2019` or `19`, `2002` or `02`, `1993` or `93`.
  #
  # Sets `VhdlVersion` and its two-digit form `VhdlShortVersion`. OSVVM requires VHDL-2008 or newer: `2002` and `1993`
  # print a warning. An unknown value prints a warning and selects `2008`.
  #
  # See also: [GetVHDLVersion]
  variable VhdlVersion
  variable VhdlShortVersion

  if {$Version eq "2008" || $Version eq "08"} {
    set VhdlVersion 2008
    set VhdlShortVersion 08
  } elseif {$Version eq "2019" || $Version eq "19" } {
    set VhdlVersion 2019
    set VhdlShortVersion 19
  } elseif {$Version eq "2002" || $Version eq "02" } {
    set VhdlVersion 2002
    set VhdlShortVersion 02
    puts "\nWARNING:  VHDL Version set to 2002.  OSVVM Requires 2008 or newer\n"
  } elseif {$Version eq "1993" || $Version eq "93" } {
    set VhdlVersion 93
    set VhdlShortVersion 93
    puts "\nWARNING:  VHDL Version set to 1993.  OSVVM Requires 2008 or newer\n"
  } else {
    set VhdlVersion 2008
    set VhdlShortVersion 08
    puts "\nWARNING:  Input to SetVHDLVersion not recognized.   Using 2008.\n"
  }
}

proc GetVHDLVersion {} {
  # Return the VHDL language version used by [analyze].
  #
  # Returns the VHDL version set by [SetVHDLVersion]: `2008`, `2019`, `2002` or `93`.
  #
  # See also: [SetVHDLVersion]
  variable VhdlVersion
  return $VhdlVersion
}

# -------------------------------------------------
# SetTranscriptType, GetTranscriptType
#
proc SetTranscriptType {{TranscriptType "html"}} {
  # Set the format of the build transcript.
  #  TranscriptType - Transcript format: `html`, `log` or `none`; case-insensitive.
  #
  # Sets `TranscriptExtension`. With `html`, the build's log file is also converted into an HTML transcript; with
  # `none`, no transcript is linked in the reports. Any other value selects `log`.
  #
  # See also: [GetTranscriptType]
  variable TranscriptExtension

  set lowerTranscriptType [string tolower $TranscriptType]

  set TranscriptExtension $lowerTranscriptType
  if {($lowerTranscriptType ne "html") && ($lowerTranscriptType ne "none")} {
    set TranscriptExtension "log"
  }
}

proc GetTranscriptType {} {
  # Return the format of the build transcript.
  #
  # Returns the transcript format set by [SetTranscriptType]: `html`, `log` or `none`.
  #
  # See also: [SetTranscriptType]
  variable TranscriptExtension
  return $TranscriptExtension
}

# -------------------------------------------------
# SetVhdlAnalyzeOptions, SetVerilogAnalyzeOptions
#
proc SetVhdlAnalyzeOptions {{Options ""}} {
  # Set the options passed to the simulator when analyzing VHDL files.
  #  Options - Simulator-specific options. Empty: no options.
  #
  # Sets `VhdlAnalyzeOptions`, used by [analyze] for `*.vhd` and `*.vhdl` files.
  #
  # See also: [GetVhdlAnalyzeOptions] [SetVerilogAnalyzeOptions]
  variable VhdlAnalyzeOptions
  set      VhdlAnalyzeOptions $Options
}
proc GetVhdlAnalyzeOptions {} {
  # Return the options passed to the simulator when analyzing VHDL files.
  #
  # Returns the options set by [SetVhdlAnalyzeOptions].
  #
  # See also: [SetVhdlAnalyzeOptions]
  variable VhdlAnalyzeOptions
  return  $VhdlAnalyzeOptions
}

proc SetVerilogAnalyzeOptions {{Options ""}} {
  # Set the options passed to the simulator when analyzing Verilog and SystemVerilog files.
  #  Options - Simulator-specific options. Empty: no options.
  #
  # Sets `VerilogAnalyzeOptions`, used by [analyze] for `*.v` and `*.sv` files.
  #
  # See also: [GetVerilogAnalyzeOptions] [SetVhdlAnalyzeOptions]
  variable VerilogAnalyzeOptions
  set      VerilogAnalyzeOptions $Options
}
proc GetVerilogAnalyzeOptions {} {
  # Return the options passed to the simulator when analyzing Verilog and SystemVerilog files.
  #
  # Returns the options set by [SetVerilogAnalyzeOptions].
  #
  # See also: [SetVerilogAnalyzeOptions]
  variable VerilogAnalyzeOptions
  return  $VerilogAnalyzeOptions
}

# -------------------------------------------------
# SetExtendedAnalyzeOptions, SetExtendedSimulateOptions
#
proc SetExtendedAnalyzeOptions {{Options ""}} {
  # Set additional options passed to the simulator by [analyze].
  #  Options - Simulator-specific options. Empty: no additional options.
  #
  # Sets `ExtendedAnalyzeOptions`. The vendor script appends them to the analyze command of VHDL and Verilog files. Set
  # them at a high level, for example in `OsvvmSettingsLocal.tcl`, to keep project scripts simulator independent.
  #
  # See also: [GetExtendedAnalyzeOptions]
  variable ExtendedAnalyzeOptions
  set ExtendedAnalyzeOptions $Options
}
proc GetExtendedAnalyzeOptions {} {
  # Return the additional options passed to the simulator by [analyze].
  #
  # Returns the options set by [SetExtendedAnalyzeOptions].
  #
  # See also: [SetExtendedAnalyzeOptions]
  variable ExtendedAnalyzeOptions
  return $ExtendedAnalyzeOptions
}

proc SetExtendedOptimizeOptions {{Options ""}} {
  # Set additional options passed to the simulator's optimization step.
  #  Options - Simulator-specific options. Empty: no additional options.
  #
  # Sets `ExtendedOptimizeOptions`. Only simulators with a separate optimization step use them: the Questa vendor script
  # passes them to `vopt`.
  #
  # See also: [GetExtendedOptimizeOptions]
  variable ExtendedOptimizeOptions
  set ExtendedOptimizeOptions $Options
}
proc GetExtendedOptimizeOptions {} {
  # Return the additional options passed to the simulator's optimization step.
  #
  # Returns the options set by [SetExtendedOptimizeOptions].
  #
  # See also: [SetExtendedOptimizeOptions]
  variable ExtendedOptimizeOptions
  return $ExtendedOptimizeOptions
}

proc SetExtendedSimulateOptions {{Options ""}} {
  # Set additional options passed to the simulator by [simulate].
  #  Options - Simulator-specific options. Empty: no additional options.
  #
  # Sets `ExtendedSimulateOptions`. The vendor script appends them to the simulate command. Set them at a high level,
  # for example in `OsvvmSettingsLocal.tcl`, to keep project scripts simulator independent.
  #
  # See also: [GetExtendedSimulateOptions]
  variable ExtendedSimulateOptions
  set ExtendedSimulateOptions $Options
}
proc GetExtendedSimulateOptions {} {
  # Return the additional options passed to the simulator by [simulate].
  #
  # Returns the options set by [SetExtendedSimulateOptions].
  #
  # See also: [SetExtendedSimulateOptions]
  variable ExtendedSimulateOptions
  return $ExtendedSimulateOptions
}

# -------------------------------------------------
# SetExtendedElaborateOptions, SetExtendedRunOptions
#    Only for simulators that elaborate and run separately - like GHDL
#    Currently only implemented for GHDL
#
proc SetExtendedElaborateOptions {{Options ""}} {
  # Set additional options passed to the simulator's elaboration step.
  #  Options - Simulator-specific options. Empty: no additional options.
  #
  # Sets `ExtendedElaborateOptions`. Only simulators that elaborate and run in separate steps use them: GHDL, NVC, VCS
  # and Xcelium.
  #
  # See also: [GetExtendedElaborateOptions] [SetExtendedRunOptions]
  variable ExtendedElaborateOptions
  set ExtendedElaborateOptions $Options
}
proc GetExtendedElaborateOptions {} {
  # Return the additional options passed to the simulator's elaboration step.
  #
  # Returns the options set by [SetExtendedElaborateOptions].
  #
  # See also: [SetExtendedElaborateOptions]
  variable ExtendedElaborateOptions
  return $ExtendedElaborateOptions
}

proc SetExtendedRunOptions {{Options ""}} {
  # Set additional options passed to the simulator's run step.
  #  Options - Simulator-specific options. Empty: no additional options.
  #
  # Sets `ExtendedRunOptions`. Only simulators that elaborate and run in separate steps use them: GHDL, NVC, VCS and
  # Xcelium.
  #
  # See also: [GetExtendedRunOptions] [SetExtendedElaborateOptions]
  variable ExtendedRunOptions
  set ExtendedRunOptions $Options
}
proc GetExtendedRunOptions {} {
  # Return the additional options passed to the simulator's run step.
  #
  # Returns the options set by [SetExtendedRunOptions].
  #
  # See also: [SetExtendedRunOptions]
  variable ExtendedRunOptions
  return $ExtendedRunOptions
}

# -------------------------------------------------
# SetSaveWaves
#    Important for simulators that do everything from the command line
#    Currently only implemented for GHDL and NVC
#
proc SetSaveWaves {{Options "true"}} {
  # Enable or disable saving waveforms during [simulate].
  #  Options - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) saves waveforms, false doesn't.
  #
  # Sets `SaveWaves` to `true` or `false`; a value that isn't a Tcl boolean is an error. Used by simulators run from the
  # command line, GHDL and NVC, which write a waveform file. The Siemens vendor scripts also use it. Initialized to
  # `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetSaveWaves]
  variable SaveWaves
  if {$Options} {
    set SaveWaves "true"
  } else {
    set SaveWaves "false"
  }
}
proc GetSaveWaves {} {
  # Return whether waveforms are saved during [simulate].
  #
  # Returns the value set by [SetSaveWaves]: `true` or `false`.
  #
  # See also: [SetSaveWaves]
  variable SaveWaves
  return $SaveWaves
}

# -------------------------------------------------
# SetInteractiveMode, SetDebugMode, SetLogSignals
#
proc SetInteractiveMode {{Options "true"}} {
  # Enable or disable the interactive mode.
  #  Options - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables, false disables the interactive mode.
  #
  # Sets `SimulateInteractive` to `true` or `false`; a value that isn't a Tcl boolean is an error.
  #
  # - Enabled: the analyze and simulate error stop counts (`AnalyzeErrorStopCount`, `SimulateErrorStopCount`) become
  #   `1`, so a build stops at the first error. Their previous values are saved when the mode changes from disabled to
  #   enabled.
  # - Disabled: the saved error stop counts are restored.
  #
  # The debug mode and signal logging follow this value unless they were set explicitly with [SetDebugMode] or
  # [SetLogSignals]. Initialized to `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetInteractiveMode]
  variable SimulateInteractive
  variable AnalyzeErrorStopCount
  variable SimulateErrorStopCount
  variable SavedAnalyzeErrorStopCount
  variable SavedSimulateErrorStopCount

  set PreviousSimulateInteractive $SimulateInteractive
  if {$Options} {
    set SimulateInteractive "true"
  } else {
    set SimulateInteractive "false"
  }

  if {($SimulateInteractive) && !($PreviousSimulateInteractive)} {
    # Only save ErrorStopCounts when options change from FALSE to TRUE
    set SavedAnalyzeErrorStopCount  $AnalyzeErrorStopCount
    set SavedSimulateErrorStopCount $SimulateErrorStopCount
  }

  if {($SimulateInteractive)} {
    # When running interactive, set ErrorStopCounts to 1
    set AnalyzeErrorStopCount  1
    set SimulateErrorStopCount 1
  } else {
    set AnalyzeErrorStopCount  $SavedAnalyzeErrorStopCount
    set SimulateErrorStopCount $SavedSimulateErrorStopCount
  }
  if {! $::osvvm::DebugIsSet} {
    set ::osvvm::Debug $SimulateInteractive
  }
  if {! $::osvvm::LogSignalsIsSet} {
    set ::osvvm::LogSignals $SimulateInteractive
  }
}
# SetInteractive is deprecated.
proc SetInteractive {{Options "true"}} {
  # Enable or disable the interactive mode; deprecated.
  #  Options - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables, false disables the interactive mode.
  #
  # Prints a deprecation message and calls [SetInteractiveMode].
  puts "SetInteractive is deprecated.  Use SetInteractiveMode instead"
  SetInteractiveMode $Options
}

proc GetInteractiveMode {} {
  # Return whether the interactive mode is enabled.
  #
  # Returns the value set by [SetInteractiveMode]: `true` or `false`.
  #
  # See also: [SetInteractiveMode]
  variable SimulateInteractive
  return $SimulateInteractive
}

proc SetDebugMode {{Options "true"}} {
  # Enable or disable the debug mode.
  #  Options - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables, false disables the debug mode.
  #
  # Sets `Debug` to `true` or `false` and marks it as set explicitly, so [SetInteractiveMode] no longer changes it; a
  # value that isn't a Tcl boolean is an error. In debug mode, the vendor scripts add the simulator's debugging options
  # to analyze and simulate. Initialized to `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetDebugMode]
  if {$Options} {
    set ::osvvm::Debug "true"
  } else {
    set ::osvvm::Debug "false"
  }
  set ::osvvm::DebugIsSet "true"
}
proc GetDebugMode {} {
  # Return whether the debug mode is enabled.
  #
  # Returns the value set by [SetDebugMode] or [SetInteractiveMode]: `true` or `false`.
  #
  # See also: [SetDebugMode]
  return $::osvvm::Debug
}

proc SetLogSignals {{Options "true"}} {
  # Enable or disable logging of signal values during [simulate].
  #  Options - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) logs signals, false doesn't.
  #
  # Sets `LogSignals` to `true` or `false` and marks it as set explicitly, so [SetInteractiveMode] no longer changes it;
  # a value that isn't a Tcl boolean is an error. Logged signals can be displayed later in the simulator's waveform
  # viewer. Initialized to `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetLogSignals]
  if {$Options} {
    set ::osvvm::LogSignals "true"
  } else {
    set ::osvvm::LogSignals "false"
  }
  set ::osvvm::LogSignalsIsSet "true"
}

proc GetLogSignals {} {
  # Return whether signal values are logged during [simulate].
  #
  # Returns the value set by [SetLogSignals] or [SetInteractiveMode]: `true` or `false`.
  #
  # See also: [SetLogSignals]
  variable LogSignals
  return $LogSignals
}

# -------------------------------------------------
# SetSecondSimulationTopLevel, GetSecondSimulationTopLevel
#
proc SetSecondSimulationTopLevel {{LibraryDotDesignUnit ""}} {  ; # Specify as Libary.DesignUnit
  # Set a second top-level design unit for [simulate].
  #  LibraryDotDesignUnit - Design unit as `<library>.<design unit>`. Empty: no second top level.
  #
  # Sets `SecondSimulationTopLevel`. The vendor scripts add it to the simulator's top-level design units. Call it before
  # [simulate].
  #
  # See also: [GetSecondSimulationTopLevel]
  variable SecondSimulationTopLevel
  set      SecondSimulationTopLevel $LibraryDotDesignUnit
}
proc GetSecondSimulationTopLevel {} {
  # Return the second top-level design unit for [simulate].
  #
  # Returns the design unit set by [SetSecondSimulationTopLevel], as `<library>.<design unit>`, or an empty string.
  #
  # See also: [SetSecondSimulationTopLevel]
  variable SecondSimulationTopLevel
  return  $SecondSimulationTopLevel
}

# -------------------------------------------------
# SetCoverageEnable, GetCoverageEnable
#
proc SetCoverageEnable {{Enable "true"}} {
  # Enable or disable code coverage.
  #  Enable - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables code coverage, false disables it.
  #
  # Sets `CoverageEnable` to `true` or `false` and prints the new value; a value that isn't a Tcl boolean is an error.
  # Code coverage is collected for a design unit only if it's also enabled for analyze ([SetCoverageAnalyzeEnable]) and
  # simulate ([SetCoverageSimulateEnable]). Initialized to `true`.
  #
  # See also: [GetCoverageEnable]
  variable CoverageEnable
  if {$Enable} {
    set CoverageEnable "true"
  } else {
    set CoverageEnable "false"
  }
  puts "SetCoverageEnable $CoverageEnable"
}
proc GetCoverageEnable {} {
  # Return whether code coverage is enabled.
  #
  # Returns the value set by [SetCoverageEnable]: `true` or `false`.
  #
  # See also: [SetCoverageEnable]
  variable CoverageEnable
  return $CoverageEnable
}

# -------------------------------------------------
# SetCoverageKinds, GetCoverageKinds
#
proc SetCoverageKinds {{Kinds "default"}} {
  # Set the kinds of code coverage to collect, independent of the simulator.
  #  Kinds - A list of kinds: `statement`, `branch`, `condition`, `expression`, `toggle`, `fsm`, `functional`;
  #          `all` stands for all of them, `default` for the kinds in `DefaultCoverageKinds`.
  #
  # Stores the kinds in `CoverageKinds` and prints them. Then it sets the code coverage options of analysis, elaboration
  # and simulation (`CoverageAnalyzeOptions`, `CoverageElaborateOptions`, `CoverageSimulateOptions`) to the vendor's
  # defaults for these kinds. This replaces options set before with [SetCoverageAnalyzeOptions],
  # [SetCoverageElaborateOptions] and [SetCoverageSimulateOptions]; call them afterwards to change the options. A kind
  # the simulator doesn't support is left out. An unknown kind is an error.
  #
  # `DefaultCoverageKinds` and the initial `CoverageKinds` are `statement branch fsm`, set in
  # `OsvvmSettingsDefault.tcl`.
  #
  # |Kind|NVC (elaborate)|Siemens tools (analyze)|Aldec tools (analyze, simulate)|
  # |---|---|---|---|
  # |`statement`|`statement`|`s`|`s`|
  # |`branch`|`branch`|`b`|`b`|
  # |`condition`|`expression`|`c`|`c`|
  # |`expression`|`expression`|`e`|`e`|
  # |`toggle`|`toggle`|`t`|-|
  # |`fsm`|`fsm-state`|`f`|`m`|
  # |`functional`|`functional`|-|-|
  #
  # See also: [GetCoverageKinds]
  set KnownKinds {statement branch condition expression toggle fsm functional}
  set CoverageKinds {}
  foreach Kind [string tolower $Kinds] {
    if {$Kind eq "all"} {
      set Expanded $KnownKinds
    } elseif {$Kind eq "default"} {
      set Expanded $::osvvm::DefaultCoverageKinds
    } elseif {[lsearch -exact $KnownKinds $Kind] >= 0} {
      set Expanded [list $Kind]
    } else {
      error "SetCoverageKinds: Unknown code coverage kind '$Kind'. Known kinds: $KnownKinds, all, default"
    }
    foreach Item $Expanded {
      if {[lsearch -exact $CoverageKinds $Item] < 0} {
        lappend CoverageKinds $Item
      }
    }
  }
  set ::osvvm::CoverageKinds            $CoverageKinds
  set ::osvvm::CoverageAnalyzeOptions   [vendor_SetCoverageAnalyzeDefaults]
  set ::osvvm::CoverageElaborateOptions [vendor_SetCoverageElaborateDefaults]
  set ::osvvm::CoverageSimulateOptions  [vendor_SetCoverageSimulateDefaults]
  puts "SetCoverageKinds $::osvvm::CoverageKinds"
}
proc GetCoverageKinds {} {
  # Return the kinds of code coverage to collect.
  #
  # Returns the kinds set by [SetCoverageKinds], with `all` and `default` expanded.
  #
  # See also: [SetCoverageKinds]
  return $::osvvm::CoverageKinds
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions, SetCoverageAnalyzeEnable
#
proc SetCoverageAnalyzeOptions {{Options ""}} {
  # Set the code coverage options passed to the simulator by [analyze].
  #  Options - Simulator-specific code coverage options. Empty: no options.
  #
  # Sets `CoverageAnalyzeOptions`, which replaces the vendor script's default. Used while code coverage is enabled for
  # analyze ([SetCoverageAnalyzeEnable]). [SetCoverageKinds] sets it to the vendor's default for the kinds.
  #
  # See also: [GetCoverageAnalyzeOptions] [SetCoverageKinds]
  set ::osvvm::CoverageAnalyzeOptions $Options
}
proc GetCoverageAnalyzeOptions {} {
  # Return the code coverage options passed to the simulator by [analyze].
  #
  # Returns the options set by [SetCoverageAnalyzeOptions], or the vendor script's default.
  #
  # See also: [SetCoverageAnalyzeOptions]
  return $::osvvm::CoverageAnalyzeOptions
}

proc SetCoverageAnalyzeEnable {{Enable "true"}} {
  # Enable or disable code coverage for the next [analyze] commands.
  #  Enable - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables code coverage, false disables it.
  #
  # Sets `CoverageAnalyzeEnable` to `true` or `false` and prints the new value; a value that isn't a Tcl boolean is an
  # error. A design unit collects code coverage only if it was analyzed with code coverage enabled. Initialized to
  # `false`, so simulations run faster.
  #
  # See also: [GetCoverageAnalyzeEnable] [SetCoverageAnalyzeOptions] [SetCoverageEnable]
  variable CoverageAnalyzeEnable
  if {$Enable} {
    set CoverageAnalyzeEnable "true"
  } else {
    set CoverageAnalyzeEnable "false"
  }
  puts "SetCoverageAnalyzeEnable $CoverageAnalyzeEnable"
}

proc GetCoverageAnalyzeEnable {} {
  # Return whether code coverage is enabled for [analyze].
  #
  # Returns the value set by [SetCoverageAnalyzeEnable]: `true` or `false`.
  #
  # See also: [SetCoverageAnalyzeEnable]
  return $::osvvm::CoverageAnalyzeEnable
}

# -------------------------------------------------
# SetCoverageElaborateOptions, GetCoverageElaborateOptions
#
proc SetCoverageElaborateOptions {{Options ""}} {
  # Set the code coverage options passed to the simulator's elaboration by [simulate].
  #  Options - Simulator-specific code coverage options. Empty: no options.
  #
  # Sets `CoverageElaborateOptions`, which replaces the vendor script's default. Used while code coverage is enabled for
  # simulate ([SetCoverageEnable], [SetCoverageSimulateEnable]); OSVVM elaborates only as part of [simulate].
  # [SetCoverageKinds] sets it to the vendor's default for the kinds.
  #
  # See also: [GetCoverageElaborateOptions] [SetCoverageKinds]
  set ::osvvm::CoverageElaborateOptions $Options
}
proc GetCoverageElaborateOptions {} {
  # Return the code coverage options passed to the simulator's elaboration by [simulate].
  #
  # Returns the options set by [SetCoverageElaborateOptions] or [SetCoverageKinds], or the vendor script's default.
  #
  # See also: [SetCoverageElaborateOptions]
  return $::osvvm::CoverageElaborateOptions
}

# -------------------------------------------------
# SetCoverageSimulateOptions, SetCoverageSimulateEnable
#
proc SetCoverageSimulateOptions {{Options ""}} {
  # Set the code coverage options passed to the simulator by [simulate].
  #  Options - Simulator-specific code coverage options. Empty: no options.
  #
  # Sets `CoverageSimulateOptions`, which replaces the vendor script's default. Used while code coverage is enabled for
  # simulate ([SetCoverageSimulateEnable]). [SetCoverageKinds] sets it to the vendor's default for the kinds.
  #
  # See also: [GetCoverageSimulateOptions] [SetCoverageElaborateOptions] [SetCoverageKinds]
  set ::osvvm::CoverageSimulateOptions $Options
}
proc GetCoverageSimulateOptions {} {
  # Return the code coverage options passed to the simulator by [simulate].
  #
  # Returns the options set by [SetCoverageSimulateOptions], or the vendor script's default.
  #
  # See also: [SetCoverageSimulateOptions]
  return $::osvvm::CoverageSimulateOptions
}

proc SetCoverageSimulateEnable {{Enable "true"}} {
  # Enable or disable code coverage for the next [simulate] commands.
  #  Enable - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) enables code coverage, false disables it.
  #
  # Sets `CoverageSimulateEnable` to `true` or `false` and prints the new value; a value that isn't a Tcl boolean is an
  # error. While enabled, the code coverage elaborate and simulate options are used and each simulation writes a code
  # coverage database, merged per test suite and per build. Initialized to `false`, so simulations run faster.
  #
  # See also: [GetCoverageSimulateEnable] [SetCoverageSimulateOptions] [SetCoverageElaborateOptions] [SetCoverageEnable]
  variable CoverageSimulateEnable
  if {$Enable} {
    set CoverageSimulateEnable "true" ;
  } else {
    set CoverageSimulateEnable "false" ;
  }
  puts "SetCoverageSimulateEnable $CoverageSimulateEnable"
}
proc GetCoverageSimulateEnable {} {
  # Return whether code coverage is enabled for [simulate].
  #
  # Returns the value set by [SetCoverageSimulateEnable]: `true` or `false`.
  #
  # See also: [SetCoverageSimulateEnable]
  return $::osvvm::CoverageSimulateEnable
}

# -------------------------------------------------
# SetCoverageExportEnable, GetCoverageExportEnable, SetCoverageExportOptions, GetCoverageExportOptions
#
proc SetCoverageExportEnable {{Enable "true"}} {
  # Enable or disable exporting the code coverage of every build into a well-known data format.
  #  Enable - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) exports at the end of every build that collected
  #           code coverage, false doesn't.
  #
  # Sets `CoverageExportEnable` to `true` or `false` and prints the new value; a value that isn't a Tcl boolean is an
  # error. The export is the one of [ExportCodeCoverage]: Cobertura XML for NVC. Initialized to `false` in
  # `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetCoverageExportEnable] [SetCoverageExportOptions]
  variable CoverageExportEnable
  if {$Enable} {
    set CoverageExportEnable "true"
  } else {
    set CoverageExportEnable "false"
  }
  puts "SetCoverageExportEnable $CoverageExportEnable"
}
proc GetCoverageExportEnable {} {
  # Return whether the code coverage of every build is exported.
  #
  # Returns the value set by [SetCoverageExportEnable]: `true` or `false`.
  #
  # See also: [SetCoverageExportEnable]
  return $::osvvm::CoverageExportEnable
}

proc SetCoverageExportOptions {{Options ""}} {
  # Set the options of every code coverage export.
  #  Options - Options of the simulator's export command, `--relative=.` for NVC. Empty: no options.
  #
  # Sets `CoverageExportOptions`, used by every [ExportCodeCoverage], also the automatic export at the end of a build
  # ([SetCoverageExportEnable]). [ExportOptions] adds options for a single [ExportCodeCoverage]. Initialized to empty
  # in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [GetCoverageExportOptions]
  set ::osvvm::CoverageExportOptions $Options
}
proc GetCoverageExportOptions {} {
  # Return the options of every code coverage export.
  #
  # Returns the options set by [SetCoverageExportOptions].
  #
  # See also: [SetCoverageExportOptions]
  return $::osvvm::CoverageExportOptions
}

# -------------------------------------------------
# SetSimulatorResolution, GetSimulatorResolution
#
proc SetSimulatorResolution {SimulatorResolution} {
  # Set the simulator's time resolution.
  #  SimulatorResolution - Time resolution as the simulator accepts it, for example `ps`.
  #
  # Sets `SimulateTimeUnits`, passed by the vendor scripts to the simulator.
  #
  # See also: [GetSimulatorResolution]
  variable SimulateTimeUnits
  set SimulateTimeUnits $SimulatorResolution
}

proc GetSimulatorResolution {} {
  # Return the simulator's time resolution.
  #
  # Returns the time resolution set by [SetSimulatorResolution].
  #
  # See also: [SetSimulatorResolution]
  variable SimulateTimeUnits
  return $SimulateTimeUnits
}

# -------------------------------------------------
# SetRequirementsUseSumOfGoals SetRequirementsCsvPrintStatus
#
proc SetRequirementUseSumOfGoals {{Status "true"}} {
  # Select how requirement goals of several test cases are combined.
  #  Status - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) sums up the goals, false uses the maximum goal.
  #
  # Sets `USE_SUM_OF_GOALS` to `true` or `false`, used by the requirements reports; a value that isn't a Tcl boolean is
  # an error. The maximum fits a merged specification, which states the total goal divided across the test cases; the
  # sum fits requirements without a specification. Initialized to `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [SetRequirementDoesNotExceedGoal] [Requirements2Html]
  if {$Status} {
    set ::osvvm::USE_SUM_OF_GOALS "true"
  } else {
    set ::osvvm::USE_SUM_OF_GOALS "false"
  }
}

proc SetRequirementCsvPrintStatus {{Status "true"}} {
  # Enable or disable the status column in the requirements CSV file.
  #  Status - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) writes the status, false doesn't.
  #
  # Sets `REQUIREMENT_CSV_PRINT_STATUS` to `true` or `false`, used by [Requirements2Csv]; a value that isn't a Tcl
  # boolean is an error. Initialized to `false` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [Requirements2Csv]
  if {$Status} {
    set ::osvvm::REQUIREMENT_CSV_PRINT_STATUS "true"
  } else {
    set ::osvvm::REQUIREMENT_CSV_PRINT_STATUS "false"
  }
}

proc SetRequirementTestCaseFailsIfLessThanGoal {{Status "true"}} {
  # Select whether a test case fails when a requirement doesn't reach its goal.
  #  Status - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) fails the test case, false keeps its status.
  #
  # Sets `REQUIREMENT_TEST_CASE_FAILS_IF_LESS_THAN_GOAL` to `true` or `false`, used by the requirements reports: a test
  # case whose passed count of a requirement is below the goal gets the status `FAILED`. A value that isn't a Tcl
  # boolean is an error. Initialized to `true` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [Requirements2Html]
  if {$Status} {
    set ::osvvm::REQUIREMENT_TEST_CASE_FAILS_IF_LESS_THAN_GOAL "true"
  } else {
    set ::osvvm::REQUIREMENT_TEST_CASE_FAILS_IF_LESS_THAN_GOAL "false"
  }
}

proc SetRequirementDoesNotExceedGoal {{Status "true"}} {
  # Select whether a requirement's passed count is limited to its goal.
  #  Status - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) limits the passed count to the goal, false sums
  #           up the passed counts.
  #
  # Sets `REQUIREMENT_DOES_NOT_EXCEED_GOAL` to `true` or `false`, used by the requirements reports; a value that isn't a
  # Tcl boolean is an error. Initialized to `true` in `OsvvmSettingsDefault.tcl`.
  #
  # See also: [SetRequirementUseSumOfGoals] [Requirements2Html]
  if {$Status} {
    set ::osvvm::REQUIREMENT_DOES_NOT_EXCEED_GOAL "true"
  } else {
    set ::osvvm::REQUIREMENT_DOES_NOT_EXCEED_GOAL "false"
  }
}


# -------------------------------------------------
# SetLibraryDirectory
#
proc SetLibraryDirectory {{LibraryDirectory "."}} {
  # Set the directory in which VHDL libraries are created.
  #  LibraryDirectory - Parent directory of the library directory; relative to the current directory.
  #
  # Sets `VhdlLibraryParentDirectory` to the normalized path. [library] creates libraries in
  # `<LibraryDirectory>/VHDL_LIBS/<tool version>/`.
  #
  # See also: [GetLibraryDirectory] [library]
  variable VhdlLibraryParentDirectory

  set VhdlLibraryParentDirectory [file normalize $LibraryDirectory]

}

proc GetLibraryDirectory {} {
  # Return the directory in which VHDL libraries are created.
  #
  # Prints a warning if the directory isn't set.
  #
  # Returns the normalized directory set by [SetLibraryDirectory], or an empty string if it isn't set.
  #
  # See also: [SetLibraryDirectory]
  variable VhdlLibraryParentDirectory

  if {[info exists VhdlLibraryParentDirectory]} {
    return "${VhdlLibraryParentDirectory}"
  } else {
    puts "WARNING:  GetLibraryDirectory VhdlLibraryParentDirectory not defined"
    return ""
  }
}


# Don't export the following due to conflicts with Tcl built-ins
# map

namespace export SetVHDLVersion GetVHDLVersion SetSimulatorResolution GetSimulatorResolution
namespace export SetTranscriptType GetTranscriptType
namespace export SetExtendedAnalyzeOptions GetExtendedAnalyzeOptions
namespace export SetExtendedOptimizeOptions GetExtendedOptimizeOptions
namespace export SetExtendedSimulateOptions GetExtendedSimulateOptions
namespace export SetVhdlAnalyzeOptions GetVhdlAnalyzeOptions SetVerilogAnalyzeOptions GetVerilogAnalyzeOptions
namespace export SetCoverageEnable GetCoverageEnable
namespace export SetCoverageKinds GetCoverageKinds
namespace export SetCoverageAnalyzeOptions GetCoverageAnalyzeOptions
namespace export SetCoverageAnalyzeEnable GetCoverageAnalyzeEnable
namespace export SetCoverageElaborateOptions GetCoverageElaborateOptions
namespace export SetCoverageSimulateOptions GetCoverageSimulateOptions
namespace export SetCoverageSimulateEnable GetCoverageSimulateEnable
namespace export SetCoverageExportEnable GetCoverageExportEnable SetCoverageExportOptions GetCoverageExportOptions
namespace export SetExtendedElaborateOptions GetExtendedElaborateOptions
namespace export SetExtendedRunOptions GetExtendedRunOptions
namespace export SetSaveWaves GetSaveWaves
namespace export SetInteractiveMode GetInteractiveMode
namespace export SetDebugMode GetDebugMode
namespace export SetLogSignals GetLogSignals
namespace export SetSecondSimulationTopLevel GetSecondSimulationTopLevel
namespace export SetRequirementUseSumOfGoals SetRequirementCsvPrintStatus
namespace export SetRequirementTestCaseFailsIfLessThanGoal SetRequirementDoesNotExceedGoal

namespace export SetLibraryDirectory GetLibraryDirectory

# end namespace ::osvvm
}
