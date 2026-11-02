#  File Name:         VendorScripts_YAVS.tcl
#  Purpose:           Scripts for running simulations with yavs
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
#    Select with:  set ::env(OSVVM_TOOL) YAVS
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
#    11/2026   2026.11    Initial Version based on VendorScripts_NVC.tcl
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
  variable ToolVendor "YAVS"
  variable ToolName   "YAVS"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead

  # yavs is found on PATH, or in the directory named by VUNIT_YAVS_PATH
  if {[info exists ::env(VUNIT_YAVS_PATH)]} {
    set yavs [file join $::env(VUNIT_YAVS_PATH) yavs]
  } else {
    set yavs yavs
  }
  if {[catch {exec $yavs --version} VersionOutput]} {
    error "YAVS not found: '$yavs --version' failed. Put yavs on PATH or set VUNIT_YAVS_PATH.\n$VersionOutput"
  }
  # First line is "yavs MAJOR.MINOR.PATCH[-PRERELEASE] [(details)]"
  if {![regexp {yavs\s+(\d+\.\d+(\.\d+)?)} $VersionOutput -> ToolVersion]} {
    error "YAVS version not recognised in: $VersionOutput"
  }
  variable ToolVersion $ToolVersion
  variable ToolNameVersion ${ToolName}-${ToolVersion}

  # yavs supports 2008 and 2019 (--std=2008|2019) and mixes them in one design
  SetVHDLVersion 2019
  variable Supports2019Interface           "true"
  variable Supports2019ImpureFunctions     "true"
  variable Supports2019FilePath            "true"
  variable Supports2019AssertApi           "true"
  variable Supports2019Integer64Bits       "true"
  variable Supports2019Generics            "true"

  variable ExtendedGlobalOptions   "--ieee-warnings=off"
  variable ExtendedRunOptions      "--exit-severity=failure"

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
  return [regexp {^yavs } $LineOfText]
}

# -------------------------------------------------
# Library
#   A yavs library is a directory created on first analysis, so there is no init step.
#   Every library is passed with --map, the one being analyzed also with --work.
#
proc YavsLibraryPath {LibraryName PathToLib} {
  return "${PathToLib}/[string toupper ${LibraryName}]"
}

proc vendor_library {LibraryName PathToLib} {
  variable YAVS_LIBRARY_MAPS
  variable YAVS_WORKING_LIBRARY_PATH

  set PathAndLib [YavsLibraryPath $LibraryName $PathToLib]
  file mkdir $PathToLib
  dict set YAVS_LIBRARY_MAPS $LibraryName $PathAndLib
  set YAVS_WORKING_LIBRARY_PATH $PathAndLib
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  variable YAVS_LIBRARY_MAPS
  dict set YAVS_LIBRARY_MAPS $LibraryName [YavsLibraryPath $LibraryName $PathToLib]
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  variable YAVS_LIBRARY_MAPS
  if {[info exists YAVS_LIBRARY_MAPS]} {
    set YAVS_LIBRARY_MAPS [dict remove $YAVS_LIBRARY_MAPS $LibraryName]
  }
}

proc YavsLibraryOptions {LibraryName} {
  variable YAVS_LIBRARY_MAPS
  variable YAVS_WORKING_LIBRARY_PATH

  set Options [list --work=${LibraryName}:${YAVS_WORKING_LIBRARY_PATH}]
  dict for {Name Path} $YAVS_LIBRARY_MAPS {
    lappend Options --map=${Name}:${Path}
  }
  return $Options
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable yavs
  variable VhdlShortVersion

  set Options [concat --std=[expr {$VhdlShortVersion eq "93" ? "1993" : "20$VhdlShortVersion"}] {*}[YavsLibraryOptions $LibraryName] {*}${args} ${FileName}]
  puts "yavs analyze ${Options}"
  if {[catch {exec $yavs analyze {*}${Options} 2>@1} AnalyzeMessage]} {
    PrintWithPrefix "Error:" $AnalyzeMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeMessage
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  error "yavs does not support Verilog: $FileName"
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # Do Nothing
}

# -------------------------------------------------
# Simulate
#   yavs run elaborates and simulates in one step.
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable yavs
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions

  set Options [concat {*}$::osvvm::ExtendedGlobalOptions {*}[YavsLibraryOptions $LibraryName] {*}${::osvvm::ElaborateOptions} {*}${ExtendedElaborateOptions} {*}${ExtendedRunOptions} {*}${args} {*}${::osvvm::GenericOptions}]
  if {$::osvvm::SaveWaves} {
    lappend Options --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.fst
  }
  lappend Options ${LibraryUnit}

  puts "yavs run ${Options}"
  if {[catch {exec $yavs run {*}${Options} 2>@1} SimulateMessage]} {
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
#   yavs code coverage is not driven from OSVVM yet
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
