#  File Name:         CreateBuildYaml.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#
#  Description
#    Procedures that create the OSVVM OsvvmRun.yml
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
#    12/2022   2022.12    Refactored from OsvvmProjectScripts
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2018 - 2022 by SynthWorks Design Inc.
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


namespace eval ::osvvm {

proc StartBuildYaml {BuildName Path_Or_File} {

  ##!!TODO Refactor into StartBuildYaml
  set  BuildStartTime    [clock seconds]
  set  BuildStartTimeMs  [clock milliseconds]
  puts "Starting Build at time [clock format $BuildStartTime -format %T]"

  set   RunFile  [open ${::osvvm::OsvvmYamlResultsFile} w]
  puts  $RunFile "Version: $::osvvm::OsvvmVersion"
  puts  $RunFile "Build:"
  puts  $RunFile "  Name: $BuildName"
  puts  $RunFile "  Date: [clock format $BuildStartTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Simulator: \"${::osvvm::ToolName} ${::osvvm::ToolArgs}\""
  puts  $RunFile "  Version: $::osvvm::ToolNameVersion"
#  puts  $RunFile "  Date: [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  close $RunFile
}


proc FinishTestSuiteBuildYaml {BuildName Path_Or_File} {

  # Print Elapsed time for last TestSuite (if any ran) and the entire build
  set   RunFile  [open ${::osvvm::OsvvmYamlResultsFile} a]


  ##!!TODO Refactor into FinishBuildYaml

  set   BuildFinishTime     [clock seconds]
  set   BuildElapsedTime    [expr ($BuildFinishTime - $BuildStartTime)]
  puts  $RunFile "Run:"
  puts  $RunFile "  Start:    [clock format $BuildStartTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Finish:   [clock format $BuildFinishTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Elapsed:  [ElapsedTimeMs $BuildStartTimeMs]"
  close $RunFile

  puts "Build Start time  [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  puts "Build Finish time [clock format $BuildFinishTime -format %T], Elasped time: [format %d:%02d:%02d [expr ($BuildElapsedTime/(60*60))] [expr (($BuildElapsedTime/60)%60)] [expr (${BuildElapsedTime}%60)]] "
}

proc FinishTestSuiteBuildYaml {} {
  if {[info exists TestSuiteName]} {
    ##!!TODO Refactor into FinishTestSuiteBuildYaml
    puts  $RunFile "    ElapsedTime: [ElapsedTimeMs $TestSuiteStartTimeMs]"
    FinalizeTestSuite $TestSuiteName
    unset TestSuiteName
  }
}

proc AfterBuildReports {BuildName} {

  # short sleep to allow the file to close
  after 1000
  set BuildYamlFile [file join ${::osvvm::OutputBaseDirectory} ${BuildName}.yml]
  file rename -force ${::osvvm::OsvvmYamlResultsFile} ${BuildYamlFile}
  Report2Html  ${BuildYamlFile}
  Report2Junit ${BuildYamlFile}
  
  ReportBuildStatus  
}


proc AfterSimulateBuildYaml {} {
  variable TestCaseName
  variable TestSuiteName
  variable TestCaseFileName
  variable SimulateStartTime
  variable SimulateStartTimeMs

  ##!!TODO Refactor into AfterSimulateBuildYaml
  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
    puts  $RunFile "        TestCaseFileName: $TestCaseFileName"
    puts  $RunFile "        TestCaseGenerics: \"$::osvvm::GenericList\""
    puts  $RunFile "        ElapsedTime: [format %.3f [expr ${SimulateElapsedTimeMs}/1000.0]]"
    close $RunFile
  }
}

# -------------------------------------------------
proc StartTestSuiteBuildYaml {TestSuiteName} {
  variable TestSuiteName
  variable TestSuiteStartTimeMs

  ##!!TODO Refactor into StartTestSuiteBuildYaml
  puts  $RunFile "  - Name: $TestSuiteName"
  puts  $RunFile "    TestCases:"
  close $RunFile

  # Starting a Test Suite here
  set TestSuiteStartTimeMs   [clock milliseconds]
}

# -------------------------------------------------
proc StartTestCaseBuildYaml {Name} {

  ##!!TODO Refactor into StartTestCaseBuildYaml
  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
  } else {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} w]
  }
  puts  $RunFile "      - TestCaseName: $Name"
  close $RunFile
}


# -------------------------------------------------
# SkipTest
#
proc SkipTest {FileName Reason} {

  set SimName [file rootname [file tail $FileName]]

  puts "SkipTest $FileName $Reason"

  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
  } else {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} w]
  }
  puts  $RunFile "      - TestCaseName: $SimName"
  puts  $RunFile "        Name: $SimName"
  puts  $RunFile "        Status: SKIPPED"
  puts  $RunFile "        Results: {Reason: \"$Reason\"}"
  close $RunFile
}



# end namespace ::osvvm
}
