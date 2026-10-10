#  File Name:         VendorScripts_VSimSA.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#      TCL abstraction layer to run OSVVM pro scripts with
#      running ActiveHDL from a TCL shell.
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
#  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.
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
  variable ToolName    "ActiveASim"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead
  variable ToolVersion [lindex [split [exec vsim -version]] 4]
#  variable ToolVersion [lindex [split $version] [llength $version]-1]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion

  if {[expr [string compare $ToolVersion "12.0"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019Interface           "false"
    variable Supports2019ImpureFunctions     "true"
    variable Supports2019FilePath            "true"
    variable Supports2019AssertApi           "true"
  }

  variable FunctionalCoverageIntegratedInSimulator "Aldec"

#  if {[batch_mode]} {
    variable NoGui "true"
#  } else {
#    variable NoGui "false"
#  }

# -------------------------------------------------
# StartTranscript / StopTranscxript
#
# proc vendor_StartTranscript {FileName} {
#   transcript off
#   puts "transcript to $FileName"
#   transcript to $FileName
# }
#
# proc vendor_StopTranscript {FileName} {
#   transcript to -off
# }

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {
#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {alib amap acom alog asim vlib vmap vcom vlog vsim run acdb}}]
   return [regexp {^alib |^amap |^acom |^alog |^asim |^vlib |^vmap |^vcom |^vlog |^vsim |^run |^acdb } $LineOfText]
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

proc vendor_GetCoverageKindOptions {Step Kinds} {
  # Translate the kinds of code coverage into ASim's options for a step.
  #
  #  Step  - `analyze`, `elaborate` or `simulate`.
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # ASim instruments code coverage at analysis (`-coverage`) and collects it at simulation (`-acdb_cov`), both
  # with `s` (statement), `b` (branch), `c` (condition), `e` (expression) and `m` (fsm). Toggle coverage isn't
  # chosen by a letter; functional coverage is collected without an option.
  #
  # Returns: The options for the step; none for elaboration.
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
  # Set the default code coverage options for simulation.
  #
  # The options for the kinds of code coverage in `CoverageKinds` (see [SetCoverageKinds]), translated by
  # `vendor_GetCoverageKindOptions`. Further options: `-acdb` and `-cc_all`.
  #
  # Returns: The default code coverage simulation options; also stored in `CoverageSimulateOptions`.
  variable CoverageSimulateOptions
  variable CoverageKinds
  set CoverageSimulateOptions [concat "-acdb" [vendor_GetCoverageKindOptions simulate $CoverageKinds] "-cc_all"]
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    puts "vlib    ${PathAndLib}"
    exec     vlib    ${PathAndLib}
    # after 1000
  }
  puts "vmap    $LibraryName  ${PathAndLib}"
  exec  vmap    $LibraryName  ${PathAndLib}
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {[file exists ${PathAndLib}]} {
    set ResolvedLib ${PathAndLib}
  } else {
    set ResolvedLib ${PathToLib}
  }
  puts "vmap    $LibraryName  ${ResolvedLib}"
  exec vmap    $LibraryName  ${ResolvedLib}
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  exec vmap -del ${LibraryName}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion

  # For now, do not use -dbg flag with coverage.
  set DebugOptions ""

  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -relax -work ${LibraryName} {*}${args} ${FileName}]

  puts "vcom $AnalyzeOptions"
#  exec  vcom {*}$AnalyzeOptions

  set ErrorCode [catch {exec vcom {*}$AnalyzeOptions} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: analyze $FileName"
  } else {
    puts $CatchMessage
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-l "] -work ${LibraryName} {*}${args} ${FileName}]
  puts "vlog $AnalyzeOptions"
#  exec  vlog {*}$AnalyzeOptions

  set ErrorCode [catch {exec vlog {*}$AnalyzeOptions} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: analyze $FileName"
  } else {
    puts $CatchMessage
  }
}

# -------------------------------------------------
proc NoNullRangeWarning  {} {
  return "-nowarn COMP96_0119"
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # endsim
}

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor
  variable TestSuiteName
  variable TestCaseFileName
  global aldec            ; #  required for matlab cosim

  # Create the script files
  set ErrorCode [catch {vendor_CreateSimulateDoFile $LibraryUnit OsvvmSimRun.tcl} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: vendor_CreateSimulateDoFile $LibraryUnit"
  }

#  puts "vendor simulate LN=$LibraryName LU=$LibraryUnit A=$args"
  set SimulateOptions [concat -c {*}${args} {*}${::osvvm::GenericOptions} -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel}]

  puts "vsim ${SimulateOptions}"
##  exec  vsim {*}${SimulateOptions} -tcl "OsvvmSimRun.tcl"

  set ErrorCode [catch {exec  vsim {*}${SimulateOptions} -tcl "OsvvmSimRun.tcl"} CatchMessage]
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
  variable ScriptFile

  # Open File
  set ScriptFile [open $ScriptFileName w]

  # Do Vendor Simulate pre-run stuff here

#?? is it possible that we want to save waves in a batch simulator

  SimulateCreateDoFile $LibraryUnit

  puts  $ScriptFile "run -all"

  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    puts $ScriptFile "acdb save -o ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseFileName}.acdb -testname ${TestCaseFileName}"
  }

#  puts  $ScriptFile "quit"
  close $ScriptFile
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
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
  if {$CovFiles ne ""} {
    exec vsim -c -tcl "acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]"
  }
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists ${CodeCovResultsDir}.html]} {
    file delete -force -- ${CodeCovResultsDir}.html
  }
  if {[file exists ${CodeCovResultsDir}_files]} {
    file delete -force -- ${CodeCovResultsDir}_files
  }
  exec vsim -c -tcl "acdb report -html -i ${CodeCoverageDirectory}/${TestSuiteName}.acdb -o ${CodeCovResultsDir}.html"
}

proc vendor_GetCoverageFileName {TestName} {
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}

# -------------------------------------------------
# Export Coverage
#
proc vendor_ExportCodeCoverage {BuildName CodeCoverageDirectory FileName Options} {
  # Export the code coverage of a build into ASim's UCDB XML with `acdb2xml`.
  #
  #  BuildName             - The build.
  #  CodeCoverageDirectory - The directory of the code coverage databases.
  #  FileName              - The file to write; if empty, `<BuildName>_code_cov.ucdb.xml` in *CodeCoverageDirectory*.
  #  Options               - Further options of `acdb2xml`.
  #
  # The build's database is `<BuildName>.acdb`. Without a database, nothing is written.
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
