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
  # `vendor_GetCoverageKindOptions`, including NVC's further code coverage options in `NvcExtendedCoverageOptions`.
  #
  # Returns: The default code coverage elaboration options; also stored in `CoverageElaborateOptions`.
  variable CoverageElaborateOptions
  variable CoverageKinds
  set CoverageElaborateOptions [vendor_GetCoverageKindOptions elaborate $CoverageKinds]
}

proc vendor_GetCoverageKindOptions {Step Kinds} {
  # Translate the kinds of code coverage into NVC's options for a step.
  #
  #  Step  - `analyze`, `elaborate` or `simulate`.
  #  Kinds - The kinds of code coverage, see [SetCoverageKinds].
  #
  # NVC collects code coverage at elaboration: `--cover=...` with `statement`, `branch`, `expression` (for both
  # `condition` and `expression`), `toggle`, `fsm-state` (for `fsm`) and `functional`, followed by NVC's further
  # code coverage options in `NvcExtendedCoverageOptions`, e.g. `fsm-no-default-enums`:
  # `--cover=statement,branch,fsm-state,fsm-no-default-enums`.
  #
  # Returns: The options for the step; none for analysis and simulation.
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
  # Set the default code coverage options for simulation.
  #
  # The options for the kinds of code coverage in `CoverageKinds` (see [SetCoverageKinds]), translated by
  # `vendor_GetCoverageKindOptions`.
  #
  # Returns: The default code coverage simulation options; also stored in `CoverageSimulateOptions`.
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
#!!    set cmd [lindex $LineOfText 0]
#!!    return [expr {$cmd in {nvc}}]
  return [regexp {^nvc } $LineOfText]
}

# -------------------------------------------------
# Library
#
proc NvcLibraryPath {LibraryName PathToLib} {
  set PathAndLib "${PathToLib}/[string toupper ${LibraryName}]"
  return $PathAndLib
}

proc vendor_library {LibraryName PathToLib} {
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
  # Do Nothing
}

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  # Elaborate and run a design unit in one NVC call (`nvc -e --jit --no-save ... -r ...`).
  #
  #  LibraryName - The library of the design unit.
  #  LibraryUnit - The design unit to simulate.
  #  args        - The simulate options, passed to the elaboration.
  #
  # The elaboration also gets OSVVM's elaborate options LocalSimulate computed (`::osvvm::ElaborateOptions`), the
  # user's extended elaborate options ([SetExtendedElaborateOptions]) and the generics. With code coverage enabled
  # for simulation, `--cover-file` names the test case's coverage database
  # `<CoverageDirectory>/<TestSuiteName>/<TestCaseFileName>.ncdb`, which [vendor_MergeCodeCoverage] merges.
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

  return "-g${Name}=${Value}"
}


# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
  # Merge code coverage databases with `nvc --cover-merge`.
  #
  #  TestSuiteName     - The test suite, or the build at the end of a build.
  #  CoverageDirectory - The directory of the code coverage databases.
  #  BuildName         - The build, or empty at the end of a build.
  #
  # At the end of a test suite, the test cases' databases `<TestSuiteName>/*.ncdb` are merged into
  # `<BuildName>/<TestSuiteName>.ncdb`. At the end of a build, the test suites' databases `<TestSuiteName>/*.ncdb` -
  # *TestSuiteName* is the build then - are merged into `<TestSuiteName>.ncdb`.
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
  # Write the code coverage reports of a build.
  #
  #  TestSuiteName         - The build.
  #  CodeCoverageDirectory - The directory of the code coverage databases.
  #
  # From the build's database `<TestSuiteName>.ncdb`, `nvc --cover-report` writes the HTML report
  # `<TestSuiteName>_code_cov/index.html`. Without a database, nothing is written. The Cobertura XML file is written by
  # [vendor_ExportCodeCoverage].
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
  # Export the code coverage of a build into Cobertura XML with `nvc --cover-export --format=cobertura`.
  #
  #  BuildName             - The build.
  #  CodeCoverageDirectory - The directory of the code coverage databases.
  #  FileName              - The file to write; if empty, `<BuildName>_code_cov.cobertura.xml` in
  #                          *CodeCoverageDirectory*.
  #  Options               - Further options of `nvc --cover-export`, e.g. `--relative=.`.
  #
  # The build's database is `<BuildName>.ncdb`. Without a database, nothing is written.
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
  # Get the file name of the HTML code coverage report the build report links.
  #
  #  TestName - The build.
  #
  # Returns: `<TestName>_code_cov/index.html`, relative to the code coverage directory.
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}
