#  File Name:         VendorScripts_Visualizer.tcl
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
#     7/2024   2024.07    Initial.   Derived from VendorScripts_Siemens
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

  if {![catch {vsimVersionString} msg]} {
    set VersionString [vsimVersionString]
  } else {
    set VersionString [exec vsim -version]
  }

  if {[info exists ::ToolName]} {
    variable ToolName $::ToolName
  } else {
    variable ToolName "Visualizer"
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
    variable ToolVersion tbd
  }

#  SetVHDLVersion 2019

  # Set if not set
  if {![info exists ::VoptArgs]} {
    set ::VoptArgs " "
  }
  if {![info exists ::VsimArgs]} {
    set ::VsimArgs " "
  }

#  variable ToolVersion [vsimVersion]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  variable NoGui

#  puts "NoGui: $NoGui"

  if {$NoGui} {
    DefaultVendor_StartTranscript $FileName
  } else {
    transcript file ""
    echo transcript file $FileName
    transcript file $FileName
  }
}

proc vendor_StopTranscript {FileName} {
  variable NoGui

  # FileName not used here
#  transcript file ""
  if {$NoGui} {
    DefaultVendor_StopTranscript $FileName
  } else {
    transcript file ""
  }
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {vlib vmap vcom vlog vopt vsim run coverage vcover}}]
  return [regexp {^vlib |^vmap |^vcom |^vlog |^vopt |^vsim |^run |^coverage |^vcover } $LineOfText]
}


# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  # Set the default code coverage options for analysis.
  #
  # The options for the kinds of code coverage in `CoverageKinds` (see [SetCoverageKinds]), translated by
  # `vendor_GetCoverageKindOptions`.
  #
  # Returns: The default code coverage analysis options; also stored in `CoverageAnalyzeOptions`.
  variable CoverageAnalyzeOptions
  variable CoverageKinds
  set CoverageAnalyzeOptions [vendor_GetCoverageKindOptions analyze $CoverageKinds]
}

proc vendor_SetCoverageElaborateDefaults {} {
  # Set the default code coverage options for elaboration.
  #
  # The options for the kinds of code coverage in `CoverageKinds` (see [SetCoverageKinds]), translated by
  # `vendor_GetCoverageKindOptions`.
  #
  # Returns: The default code coverage elaboration options; also stored in `CoverageElaborateOptions`.
  variable CoverageElaborateOptions
  variable CoverageKinds
  set CoverageElaborateOptions [vendor_GetCoverageKindOptions elaborate $CoverageKinds]
}

proc vendor_GetCoverageKindLetters {Kinds} {
  # Translate the kinds of code coverage into Visualizer's letters, used by `+cover=` and `vcover report -code`.
  #
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # `s` (statement), `b` (branch), `c` (condition), `e` (expression), `t` (toggle) and `f` (fsm); functional coverage
  # has no letter.
  #
  # Returns: The letters, e.g. `sbf`.
  set Letters ""
  foreach Kind $Kinds {
    append Letters [dict get {statement s branch b condition c expression e toggle t fsm f functional ""} $Kind]
  }
  return $Letters
}

proc vendor_GetCoverageKindOptions {Step Kinds} {
  # Translate the kinds of code coverage into Visualizer's options for a step.
  #
  #  Step  - `analyze`, `elaborate` or `simulate`.
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # Visualizer instruments code coverage at analysis: `+cover=` with `s` (statement), `b` (branch), `c` (condition),
  # `e` (expression), `t` (toggle) and `f` (fsm). Functional coverage is collected without an option.
  #
  # Returns: The options for the step; none for elaboration and simulation.
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
  # Set the default code coverage options for simulation.
  #
  # The options for the kinds of code coverage in `CoverageKinds` (see [SetCoverageKinds]), translated by
  # `vendor_GetCoverageKindOptions`. `-coverage` records the coverage instrumented at analysis.
  #
  # Returns: The default code coverage simulation options; also stored in `CoverageSimulateOptions`.
  variable CoverageSimulateOptions
  variable CoverageKinds
  set CoverageSimulateOptions [concat "-coverage" [vendor_GetCoverageKindOptions simulate $CoverageKinds]]
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib [::fileutil::relative [pwd] ${PathToLib}/${LibraryName}]

  if {![file exists ${PathAndLib}]} {
    puts "vlib   ${PathAndLib} "
    eval $::osvvm::shell  vlib   ${PathAndLib}
  }
  puts                 "vmap   $LibraryName  ${PathAndLib}"
  eval $::osvvm::shell  vmap   $LibraryName  ${PathAndLib}
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
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
  eval $::osvvm::shell vmap -del ${LibraryName}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion

  set  AnalyzeOptions [concat -${VhdlVersion} -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vcom $AnalyzeOptions"
  eval $::osvvm::shell vcom {*}$AnalyzeOptions
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-L "] -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vlog $AnalyzeOptions"
  eval $::osvvm::shell vlog {*}$AnalyzeOptions
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  global SourceMap
  variable NoGui

  # close junk in source window
  if {! $NoGui} {
    catch {noview source}
    catch {noview source}
  }
  puts "quit -sim"
  quit -sim
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
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable TestSuiteName
  variable TestCaseFileName
  variable ReportsTestSuiteDirectory

  if {($::osvvm::Debug)} {
	  set OptimizeOptions $::osvvm::DebugOptions
  } else {
	  set OptimizeOptions " "
  }

  set OptimizeOptions [concat $::VoptArgs $OptimizeOptions  -work ${LibraryName} -L ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} -o ${LibraryUnit}_opt ]

  puts "vopt {*}${OptimizeOptions} -designfile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_design.bin]"
  eval $::osvvm::shell vopt {*}${OptimizeOptions} -quiet -designfile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_design.bin]


  if {$::osvvm::SaveWaves} {
    set WaveOptions "-qwavedb=+signals+wavefile=[file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_qwave.db]"
  } else {
    set WaveOptions ""
  }

  set SimulateOptions [concat $::VsimArgs $::osvvm::SiemensSimulateOptions -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}_opt ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}${::osvvm::GenericOptions} -suppress 8683 -suppress 8684]

  puts "vsim {*}${SimulateOptions} ${WaveOptions}"
  eval $::osvvm::shell vsim {*}${SimulateOptions} ${WaveOptions}

  # Historical name.  Must be run with "do" for actions to work
  if {[file exists ${OsvvmScriptDirectory}/Siemens.do]} {
    do ${OsvvmScriptDirectory}/Siemens.do
  }

  SimulateRunScripts ${LibraryUnit}

  run -all

  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    coverage save ${::osvvm::CoverageDirectory}/${::osvvm::TestSuiteName}/${::osvvm::TestCaseFileName}.ucdb
  }
}

# -------------------------------------------------
proc vendor_generic {Name Value} {

  return "-g${Name}=${Value}"
}


# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.ucdb]
  if {$CovFiles ne ""} {
    eval $::osvvm::shell vcover merge ${CoverageFileBaseName}.ucdb {*}$CovFiles
  }
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists $CodeCovResultsDir]} {
    file delete -force -- $CodeCovResultsDir
  }
  eval $::osvvm::shell vcover report -html -annotate -details -verbose -output ${CodeCovResultsDir} ${CodeCoverageDirectory}/${TestSuiteName}.ucdb
}

proc vendor_GetCoverageFileName {TestName} {
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}

# -------------------------------------------------
# Export Coverage
#
proc vendor_ExportCodeCoverage {BuildName CodeCoverageDirectory FileName Options} {
  # Export the code coverage of a build into Visualizer's coverage report XML with `vcover report -xml -details`.
  #
  #  BuildName             - The build.
  #  CodeCoverageDirectory - The directory of the code coverage databases.
  #  FileName              - The file to write; if empty, `<BuildName>_code_cov.questa.xml` in *CodeCoverageDirectory*.
  #  Options               - Further options of `vcover report`.
  #
  # The build's database is `<BuildName>.ucdb`. `-details` writes per instance the source files, statements and
  # branches with their counts; `-code` chooses the kinds of [SetCoverageKinds] (see
  # [vendor_GetCoverageKindLetters]). Without a database, nothing is written.
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
