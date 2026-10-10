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
  variable VhdlVersion
  return $VhdlVersion
}

# -------------------------------------------------
# SetTranscriptType, GetTranscriptType
#
proc SetTranscriptType {{TranscriptType "html"}} {
  variable TranscriptExtension

  set lowerTranscriptType [string tolower $TranscriptType]

  set TranscriptExtension $lowerTranscriptType
  if {($lowerTranscriptType ne "html") && ($lowerTranscriptType ne "none")} {
    set TranscriptExtension "log"
  }
}

proc GetTranscriptType {} {
  variable TranscriptExtension
  return $TranscriptExtension
}

# -------------------------------------------------
# SetVhdlAnalyzeOptions, SetVerilogAnalyzeOptions
#
proc SetVhdlAnalyzeOptions {{Options ""}} {
  variable VhdlAnalyzeOptions
  set      VhdlAnalyzeOptions $Options
}
proc GetVhdlAnalyzeOptions {} {
  variable VhdlAnalyzeOptions
  return  $VhdlAnalyzeOptions
}

proc SetVerilogAnalyzeOptions {{Options ""}} {
  variable VerilogAnalyzeOptions
  set      VerilogAnalyzeOptions $Options
}
proc GetVerilogAnalyzeOptions {} {
  variable VerilogAnalyzeOptions
  return  $VerilogAnalyzeOptions
}

# -------------------------------------------------
# SetExtendedAnalyzeOptions, SetExtendedSimulateOptions
#
proc SetExtendedAnalyzeOptions {{Options ""}} {
  variable ExtendedAnalyzeOptions
  set ExtendedAnalyzeOptions $Options
}
proc GetExtendedAnalyzeOptions {} {
  variable ExtendedAnalyzeOptions
  return $ExtendedAnalyzeOptions
}

proc SetExtendedOptimizeOptions {{Options ""}} {
  variable ExtendedOptimizeOptions
  set ExtendedOptimizeOptions $Options
}
proc GetExtendedOptimizeOptions {} {
  variable ExtendedOptimizeOptions
  return $ExtendedOptimizeOptions
}

proc SetExtendedSimulateOptions {{Options ""}} {
  variable ExtendedSimulateOptions
  set ExtendedSimulateOptions $Options
}
proc GetExtendedSimulateOptions {} {
  variable ExtendedSimulateOptions
  return $ExtendedSimulateOptions
}

# -------------------------------------------------
# SetExtendedElaborateOptions, SetExtendedRunOptions
#    Only for simulators that elaborate and run separately - like GHDL
#    Currently only implemented for GHDL
#
proc SetExtendedElaborateOptions {{Options ""}} {
  variable ExtendedElaborateOptions
  set ExtendedElaborateOptions $Options
}
proc GetExtendedElaborateOptions {} {
  variable ExtendedElaborateOptions
  return $ExtendedElaborateOptions
}

proc SetExtendedRunOptions {{Options ""}} {
  variable ExtendedRunOptions
  set ExtendedRunOptions $Options
}
proc GetExtendedRunOptions {} {
  variable ExtendedRunOptions
  return $ExtendedRunOptions
}

# -------------------------------------------------
# SetSaveWaves
#    Important for simulators that do everything from the command line
#    Currently only implemented for GHDL and NVC
#
proc SetSaveWaves {{Options "true"}} {
  variable SaveWaves
  if {$Options} {
    set SaveWaves "true"
  } else {
    set SaveWaves "false"
  }
}
proc GetSaveWaves {} {
  variable SaveWaves
  return $SaveWaves
}

# -------------------------------------------------
# SetInteractiveMode, SetDebugMode, SetLogSignals
#
proc SetInteractiveMode {{Options "true"}} {
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
  puts "SetInteractive is deprecated.  Use SetInteractiveMode instead"
  SetInteractiveMode $Options
}

proc GetInteractiveMode {} {
  variable SimulateInteractive
  return $SimulateInteractive
}

proc SetDebugMode {{Options "true"}} {
  if {$Options} {
    set ::osvvm::Debug "true"
  } else {
    set ::osvvm::Debug "false"
  }
  set ::osvvm::DebugIsSet "true"
}
proc GetDebugMode {} {
  return $::osvvm::Debug
}

proc SetLogSignals {{Options "true"}} {
  if {$Options} {
    set ::osvvm::LogSignals "true"
  } else {
    set ::osvvm::LogSignals "false"
  }
  set ::osvvm::LogSignalsIsSet "true"
}

proc GetLogSignals {} {
  variable LogSignals
  return $LogSignals
}

# -------------------------------------------------
# SetSecondSimulationTopLevel, GetSecondSimulationTopLevel
#
proc SetSecondSimulationTopLevel {{LibraryDotDesignUnit ""}} {  ; # Specify as Libary.DesignUnit
  variable SecondSimulationTopLevel
  set      SecondSimulationTopLevel $LibraryDotDesignUnit
}
proc GetSecondSimulationTopLevel {} {
  variable SecondSimulationTopLevel
  return  $SecondSimulationTopLevel
}

# -------------------------------------------------
# SetCoverageEnable, GetCoverageEnable
#
proc SetCoverageEnable {{Enable "true"}} {
  variable CoverageEnable
  if {$Enable} {
    set CoverageEnable "true"
  } else {
    set CoverageEnable "false"
  }
  puts "SetCoverageEnable $CoverageEnable"
}
proc GetCoverageEnable {} {
  variable CoverageEnable
  return $CoverageEnable
}

# -------------------------------------------------
# SetCoverageKinds, GetCoverageKinds
#
proc SetCoverageKinds {{Kinds "default"}} {
  # Set the kinds of code coverage to collect, independent of the simulator.
  #
  #  Kinds - A list of kinds: `statement`, `branch`, `condition`, `expression`, `toggle`, `fsm`, `functional`;
  #          `all` stands for all of them, `default` for the kinds in `DefaultCoverageKinds`.
  #
  # Stores the kinds in `CoverageKinds`, then sets the code coverage options of analysis, elaboration and simulation
  # to the vendor's defaults for these kinds (vendor_SetCoverageAnalyzeDefaults, vendor_SetCoverageElaborateDefaults,
  # vendor_SetCoverageSimulateDefaults). This replaces options set before with [SetCoverageAnalyzeOptions],
  # [SetCoverageElaborateOptions] and [SetCoverageSimulateOptions]; call them afterwards to change the options. A kind
  # the simulator doesn't support is left out. An unknown kind is an error.
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
  # Get the kinds of code coverage to collect.
  #
  # Returns: The kinds, set by [SetCoverageKinds].
  return $::osvvm::CoverageKinds
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions, SetCoverageAnalyzeEnable
#
proc SetCoverageAnalyzeOptions {{Options ""}} {
  set ::osvvm::CoverageAnalyzeOptions $Options
}
proc GetCoverageAnalyzeOptions {} {
  return $::osvvm::CoverageAnalyzeOptions
}

proc SetCoverageAnalyzeEnable {{Enable "true"}} {
  variable CoverageAnalyzeEnable
  if {$Enable} {
    set CoverageAnalyzeEnable "true"
  } else {
    set CoverageAnalyzeEnable "false"
  }
  puts "SetCoverageAnalyzeEnable $CoverageAnalyzeEnable"
}

proc GetCoverageAnalyzeEnable {} {
  return $::osvvm::CoverageAnalyzeEnable
}

# -------------------------------------------------
# SetCoverageElaborateOptions, GetCoverageElaborateOptions
#
proc SetCoverageElaborateOptions {{Options ""}} {
  # Set the code coverage options for elaboration.
  #
  #  Options - The options, passed to the simulator's elaboration.
  #
  # They are used while code coverage is enabled for simulation: [SetCoverageEnable] and
  # [SetCoverageSimulateEnable]. The defaults come from vendor_SetCoverageElaborateDefaults; [SetCoverageKinds] sets
  # them to the vendor's defaults for the kinds.
  set ::osvvm::CoverageElaborateOptions $Options
}
proc GetCoverageElaborateOptions {} {
  # Get the code coverage options for elaboration.
  #
  # Returns: The options, set by [SetCoverageElaborateOptions].
  return $::osvvm::CoverageElaborateOptions
}

# -------------------------------------------------
# SetCoverageSimulateOptions, SetCoverageSimulateEnable
#
proc SetCoverageSimulateOptions {{Options ""}} {
  set ::osvvm::CoverageSimulateOptions $Options
}
proc GetCoverageSimulateOptions {} {
  return $::osvvm::CoverageSimulateOptions
}

proc SetCoverageSimulateEnable {{Enable "true"}} {
  variable CoverageSimulateEnable
  if {$Enable} {
    set CoverageSimulateEnable "true" ;
  } else {
    set CoverageSimulateEnable "false" ;
  }
  puts "SetCoverageSimulateEnable $CoverageSimulateEnable"
}
proc GetCoverageSimulateEnable {} {
  return $::osvvm::CoverageSimulateEnable
}

# -------------------------------------------------
# SetCoverageExportEnable, GetCoverageExportEnable, SetCoverageExportOptions, GetCoverageExportOptions
#
proc SetCoverageExportEnable {{Enable "true"}} {
  # Enable or disable exporting the code coverage of every build into a well-known data format.
  #
  #  Enable - A Tcl boolean: true (`true`, `yes`, `on`, `1`, any case) to export at the end of every build that
  #           collected code coverage.
  #
  # Stores `true` or `false`; a value that isn't a Tcl boolean is an error. The export is the one of
  # [ExportCodeCoverage], e.g. Cobertura XML for NVC. Default: `false`.
  variable CoverageExportEnable
  if {$Enable} {
    set CoverageExportEnable "true"
  } else {
    set CoverageExportEnable "false"
  }
  puts "SetCoverageExportEnable $CoverageExportEnable"
}
proc GetCoverageExportEnable {} {
  # Get whether the code coverage of every build is exported.
  #
  # Returns: `true` or `false`, set by [SetCoverageExportEnable].
  return $::osvvm::CoverageExportEnable
}

proc SetCoverageExportOptions {{Options ""}} {
  # Set the options of every code coverage export.
  #
  #  Options - The options, in the simulator's syntax, e.g. `--relative=.` for NVC.
  #
  # [ExportOptions] adds options for a single [ExportCodeCoverage].
  set ::osvvm::CoverageExportOptions $Options
}
proc GetCoverageExportOptions {} {
  # Get the options of every code coverage export.
  #
  # Returns: The options, set by [SetCoverageExportOptions].
  return $::osvvm::CoverageExportOptions
}

# -------------------------------------------------
# SetSimulatorResolution, GetSimulatorResolution
#
proc SetSimulatorResolution {SimulatorResolution} {
  variable SimulateTimeUnits
  set SimulateTimeUnits $SimulatorResolution
}

proc GetSimulatorResolution {} {
  variable SimulateTimeUnits
  return $SimulateTimeUnits
}

# -------------------------------------------------
# SetRequirementsUseSumOfGoals SetRequirementsCsvPrintStatus
#
proc SetRequirementUseSumOfGoals {{Status "true"}} {
  # Current default is false - historical assumed reading Spec.
  if {$Status} {
    set ::osvvm::USE_SUM_OF_GOALS "true"
  } else {
    set ::osvvm::USE_SUM_OF_GOALS "false"
  }
}

proc SetRequirementCsvPrintStatus {{Status "true"}} {
  # Current default is true
  if {$Status} {
    set ::osvvm::REQUIREMENT_CSV_PRINT_STATUS "true"
  } else {
    set ::osvvm::REQUIREMENT_CSV_PRINT_STATUS "false"
  }
}

proc SetRequirementTestCaseFailsIfLessThanGoal {{Status "true"}} {
  # Current default is true
  if {$Status} {
    set ::osvvm::REQUIREMENT_TEST_CASE_FAILS_IF_LESS_THAN_GOAL "true"
  } else {
    set ::osvvm::REQUIREMENT_TEST_CASE_FAILS_IF_LESS_THAN_GOAL "false"
  }
}

proc SetRequirementDoesNotExceedGoal {{Status "true"}} {
  # Current default is true
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
  variable VhdlLibraryParentDirectory

  set VhdlLibraryParentDirectory [file normalize $LibraryDirectory]

}

proc GetLibraryDirectory {} {
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
