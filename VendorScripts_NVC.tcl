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
#    10/2026   2026.10    Added code coverage: statement and branch coverage, merge, HTML and Cobertura reports
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
#   NVC collects code coverage at elaboration (nvc -e --cover=...).
#   Analysis has no coverage options.
#   vendor_simulate elaborates and runs in one call, so the simulate options are elaboration options.
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
  set CoverageAnalyzeOptions ""
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
  set CoverageSimulateOptions "--cover=statement,branch"
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
  variable nvc
  variable VhdlShortVersion
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable NVC_WORKING_LIBRARY_PATH
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions

  set LocalGlobalOptions    [concat --std=${VhdlShortVersion} $::osvvm::SimulatorMemory $::osvvm::ExtendedGlobalOptions --work=${LibraryName}:${NVC_WORKING_LIBRARY_PATH}.${VhdlShortVersion} {*}${VHDL_RESOURCE_LIBRARY_PATHS}]
  set LocalElaborateOptions [concat {*}${ExtendedElaborateOptions} {*}${args}  {*}${::osvvm::GenericOptions}]

  # Coverage database of this test case, merged per test suite by vendor_MergeCodeCoverage
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
#   Called at the end of a test suite: merges the test cases' databases <TestSuiteName>/*.ncdb into
#   <BuildName>/<TestSuiteName>.ncdb.
#   Called at the end of a build (BuildName is ""): merges the test suites' databases <TestSuiteName>/*.ncdb, where
#   TestSuiteName is the build's name, into <TestSuiteName>.ncdb.
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} {
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
#   Writes the HTML report <TestSuiteName>_code_cov/index.html and the Cobertura XML file
#   <TestSuiteName>_code_cov.cobertura.xml from <TestSuiteName>.ncdb.
#
proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} {
  variable nvc

  set CoverageFile      ${CodeCoverageDirectory}/${TestSuiteName}.ncdb
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  set CoberturaFile     ${CodeCoverageDirectory}/${TestSuiteName}_code_cov.cobertura.xml
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

  puts "nvc --cover-export --format=cobertura --output=${CoberturaFile} ${CoverageFile}"
  if {[catch {exec $nvc --cover-export --format=cobertura --output=${CoberturaFile} ${CoverageFile} 2>@1} ExportMessage]} {
    PrintWithPrefix "Error:" $ExportMessage
    error "Failed: export code coverage of $TestSuiteName to Cobertura"
  } else {
    puts $ExportMessage
  }
}

proc vendor_GetCoverageFileName {TestName} {
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}
