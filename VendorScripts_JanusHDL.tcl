#  File Name:         VendorScripts_JanusHDL.tcl
#  Purpose:           Scripts for running simulations with JanusHDL
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#     Rune Baeverrud
#
#  Description
#    Tcl procedures with the intent of making running
#    compiling and simulations tool independent
#
#    Select with:  source StartJanusHDL.tcl  (from tclsh)
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
#    11/2026   2026.11    Initial version
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2026 by SynthWorks Design Inc.
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
  variable ToolVendor "JanusHDL"
  variable ToolName   "JanusHDL"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead

  # jhdl is found on the PATH, or in the directory named by JANUSHDL_PATH
  if {[info exists ::env(JANUSHDL_PATH)]} {
    variable jhdl [file join $::env(JANUSHDL_PATH) jhdl]
  } else {
    variable jhdl jhdl
  }
  if {[catch {exec $jhdl --version} VersionOutput]} {
    error "JanusHDL not found: '$jhdl --version' failed. Put jhdl on the PATH or set JANUSHDL_PATH to its directory.\n$VersionOutput"
  }
  # First line: "jhdl MAJOR.MINOR.PATCH"
  if {![regexp {jhdl\s+(\d+\.\d+\.\d+)} $VersionOutput -> ToolVersion]} {
    error "JanusHDL version not recognized in: $VersionOutput"
  }
  # Libraries kept in directories (--library) are in JanusHDL 0.13.0 and newer
  if {[package vcompare $ToolVersion 0.13.0] < 0} {
    error "JanusHDL $ToolVersion found: OSVVM needs JanusHDL 0.13.0 or newer"
  }
  variable ToolVersion $ToolVersion
  variable ToolNameVersion ${ToolName}-${ToolVersion}

  # JanusHDL supports VHDL-2019 and mixes versions in one design
  SetVHDLVersion 2019
  variable Supports2019Interface           "true"
  variable Supports2019ImpureFunctions     "true"
  variable Supports2019FilePath            "true"
  variable Supports2019AssertApi           "true"
  variable Supports2019Integer64Bits       "true"
  variable Supports2019Generics            "true"

# -------------------------------------------------
# StartTranscript / StopTranscript
#
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#    set defaults here
}

proc vendor_SetCoverageElaborateDefaults {} {
  variable CoverageElaborateOptions
#    set defaults here
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
#    set defaults here
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
  return [regexp {^jhdl } $LineOfText]
}

# -------------------------------------------------
# Library
#   A JanusHDL library is a directory, <PathToLib>/<library>, created on the
#   first analysis into it.  Every call gives every library with
#   --library NAME=DIRECTORY; an analysis names its library with --work.
#
proc JanusHDLLibraryPath {LibraryName PathToLib} {
  return [file join $PathToLib [string tolower $LibraryName]]
}

proc vendor_library {LibraryName PathToLib} {
  variable JANUSHDL_LIBRARIES

  set PathAndLib [JanusHDLLibraryPath $LibraryName $PathToLib]
  # The library's own directory too: an empty library until files are analyzed into it
  file mkdir $PathAndLib
  dict set JANUSHDL_LIBRARIES [string tolower $LibraryName] $PathAndLib
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  variable JANUSHDL_LIBRARIES
  dict set JANUSHDL_LIBRARIES [string tolower $LibraryName] [JanusHDLLibraryPath $LibraryName $PathToLib]
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  variable JANUSHDL_LIBRARIES
  if {[info exists JANUSHDL_LIBRARIES]} {
    set JANUSHDL_LIBRARIES [dict remove $JANUSHDL_LIBRARIES [string tolower $LibraryName]]
  }
}

proc JanusHDLLibraryOptions {} {
  variable JANUSHDL_LIBRARIES
  set Options [list]
  if {[info exists JANUSHDL_LIBRARIES]} {
    dict for {Name Path} $JANUSHDL_LIBRARIES {
      lappend Options --library ${Name}=${Path}
    }
  }
  return $Options
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable jhdl
  variable VhdlShortVersion

  # (args: VhdlAnalyzeOptions, ExtendedAnalyzeOptions and the call's own)
  set Options [concat {*}$::osvvm::ExtendedGlobalOptions --std $VhdlShortVersion {*}[JanusHDLLibraryOptions] --work [string tolower $LibraryName] --analyze-only {*}${args} ${FileName}]
  puts "jhdl ${Options}"
  if {[catch {exec $jhdl {*}${Options} 2>@1} AnalyzeMessage]} {
    PrintWithPrefix "Error:" $AnalyzeMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeMessage
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  error "JanusHDL does not simulate Verilog yet: $FileName"
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # Do Nothing
}

# -------------------------------------------------
# Simulate
#   jhdl elaborates and simulates in one step, from the libraries.
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable jhdl
  variable VhdlShortVersion

  # (args: the call's own options and ExtendedSimulateOptions.  ElaborateOptions
  #  holds only code coverage options, which JanusHDL does not have yet.)
  set Options [concat {*}$::osvvm::ExtendedGlobalOptions --std $VhdlShortVersion {*}[JanusHDLLibraryOptions] {*}${::osvvm::ExtendedElaborateOptions} {*}${::osvvm::ExtendedRunOptions} {*}${args} {*}${::osvvm::GenericOptions}]
  if {$::osvvm::SaveWaves} {
    # JanusHDL's own waveform database (opened with jhdlw) and FST
    set WaveBase [file join ${::osvvm::ReportsTestSuiteDirectory} ${LibraryUnit}]
    lappend Options --wave ${WaveBase}.jhw --fst ${WaveBase}.fst
  }
  lappend Options --top [string tolower $LibraryName].${LibraryUnit}

  puts "jhdl ${Options}"
  if {[catch {exec $jhdl {*}${Options} 2>@1} SimulateMessage]} {
    PrintWithPrefix "Error:" $SimulateMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $SimulateMessage
  }
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  return "-g${Name}=${Value}"
}

# -------------------------------------------------
# Merge Coverage
#   JanusHDL does not have code coverage yet
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
}

proc vendor_ExportCodeCoverage {BuildName CodeCoverageDirectory FileName Options} {
}

proc vendor_GetCoverageFileName {TestName} {
  return ${TestName}_code_cov.html
}
