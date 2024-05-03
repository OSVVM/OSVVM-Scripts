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
#    Defines the format of the OsvvmRun.yml file
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
#  Copyright (c) 2022 by SynthWorks Design Inc.
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
  variable  TclZone   [clock format [clock seconds] -format %z]
  variable  IsoZone   [format "%s:%s" [string range $TclZone 0 2] [string range $TclZone 3 4]] 


# -------------------------------------------------
proc  ElapsedTimeMs {StartTimeMs} {
  set   FinishTimeMs  [clock milliseconds]
  set   Elapsed [expr ($FinishTimeMs - $StartTimeMs)]
  return [format %.3f [expr ${Elapsed}/1000.0]]
}

# -------------------------------------------------
proc  ElapsedTimeHms {StartTimeSec} {
#!! TODO Refactor from FinishBuildYaml
}

# -------------------------------------------------
proc GetIsoTime {TimeSeconds} {
  set  IsoTime [format "%s%s" [clock format $TimeSeconds -format {%Y-%m-%dT%H:%M:%S}] $::osvvm::IsoZone]
  return $IsoTime
}

# -------------------------------------------------
proc StartBuildYaml {BuildName} {
  variable BuildStartTime
  variable BuildStartTimeMs

  set  BuildStartTimeMs  [clock milliseconds]
  set  BuildStartTime    [clock seconds]
  set  StartTime [GetIsoTime $BuildStartTime]
  puts "Starting Build at time [clock format $BuildStartTime -format %T]"

  set   RunFile  [open ${::osvvm::OsvvmBuildYamlFile} w]
#  puts  $RunFile "BuildName: $BuildName"
  puts  $RunFile "Version: $::osvvm::OsvvmVersion"
  puts  $RunFile "Date: $StartTime"
  puts  $RunFile "BuildInfo:"
  puts  $RunFile "  Start Time: $StartTime"
  puts  $RunFile "  Simulator: \"${::osvvm::ToolName} ${::osvvm::ToolArgs}\""
  puts  $RunFile "  Simulator Version: \"$::osvvm::ToolNameVersion\""
  puts  $RunFile "  OSVVM Version: \"$::osvvm::OsvvmVersion\""
#  set BuildTranscriptLinkPathPrefix [file join ${::osvvm::LogSubdirectory} ${BuildName}]
#  puts  $RunFile "  Simulation Transcript: <a href=\"${BuildTranscriptLinkPathPrefix}.log\">${BuildName}.log</a>"
  close $RunFile
}

# -------------------------------------------------
proc FinishBuildYaml {BuildName} {
  variable BuildStartTime
  variable BuildStartTimeMs
  variable BuildErrorCode
  variable AnalyzeErrorCount
  variable SimulateErrorCount

  # Print Elapsed time for last TestSuite (if any ran) and the entire build
  set   RunFile  [open ${::osvvm::OsvvmBuildYamlFile} a]

  set   BuildFinishTime     [clock seconds]
  set   BuildElapsedTime    [expr ($BuildFinishTime - $BuildStartTime)]
  puts  $RunFile "OptionalInfo:"
#  # OptionalInfo is not known until simulation finishes
#  if {$::osvvm::TranscriptExtension eq "html"} {
#    set BuildTranscriptLinkPathPrefix [file join ${::osvvm::LogSubdirectory} ${BuildName}]
#    puts $RunFile "  HTML Simulation Transcript: <a href=\"${BuildTranscriptLinkPathPrefix}_log.html\">${BuildName}_log.html</a>"
#  }
#  set CodeCoverageFile [vendor_GetCoverageFileName ${BuildName}]
#  if {$::osvvm::RanSimulationWithCoverage eq "true"} {
#    puts $RunFile "  Code Coverage: <a href=\"${::osvvm::CoverageSubdirectory}/${CodeCoverageFile}\">Code Coverage Results</a>"
#  }
  puts  $RunFile "  Finish Time: [GetIsoTime $BuildFinishTime]"
  
  puts  $RunFile "Run:"
  puts  $RunFile "  BuildErrorCode:       $BuildErrorCode"
  puts  $RunFile "  AnalyzeErrorCount:    $AnalyzeErrorCount"
  puts  $RunFile "  SimulateErrorCount:   $BuildErrorCode"
  puts  $RunFile "  Elapsed:  [ElapsedTimeMs $BuildStartTimeMs]"
  close $RunFile

  puts "Build Start time  [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  puts "Build Finish time [clock format $BuildFinishTime -format %T], Elapsed time: [format %d:%02d:%02d [expr ($BuildElapsedTime/(60*60))] [expr (($BuildElapsedTime/60)%60)] [expr (${BuildElapsedTime}%60)]] "
}


# -------------------------------------------------
proc StartTestSuiteBuildYaml {SuiteName FirstRun} {
  variable TestSuiteStartTimeMs
  
  set RunFile [open ${::osvvm::OsvvmBuildYamlFile} a]

  if {$FirstRun} {
    puts  $RunFile "TestSuites: "
  }

  puts  $RunFile "  - Name: $SuiteName"
#  puts  $RunFile "    ReportsDirectory: [file join ${::osvvm::ReportsSubdirectory} $SuiteName]"
  puts  $RunFile "    TestCases:"
  close $RunFile
  
  # Starting a Test Suite here
  set TestSuiteStartTimeMs   [clock milliseconds]
}

# -------------------------------------------------
proc FinishTestSuiteBuildYaml {} {
  variable TestSuiteStartTimeMs

  set   RunFile  [open ${::osvvm::OsvvmBuildYamlFile} a]
  puts  $RunFile "    ElapsedTime: [ElapsedTimeMs $TestSuiteStartTimeMs]"
  close $RunFile
}


# -------------------------------------------------
proc StartSimulateBuildYaml {TestName} {
  variable SimulateStartTime
  variable SimulateStartTimeMs

  set SimulateStartTime   [clock seconds]
  set SimulateStartTimeMs [clock milliseconds]
  puts "Simulation Start time [clock format $SimulateStartTime -format %T]"

  set RunFile [open ${::osvvm::OsvvmBuildYamlFile} a]
  puts  $RunFile "      - TestCaseName: \"$TestName\""
  close $RunFile
}


proc FinishSimulateBuildYaml {} {
  variable TestCaseFileName
  variable SimulateStartTime
  variable SimulateStartTimeMs
  
  #puts "Start time  [clock format $SimulateStartTime -format %T]"
  set  SimulateFinishTime    [clock seconds]
  set  SimulateElapsedTime   [expr ($SimulateFinishTime - $SimulateStartTime)]

  puts "Simulation Finish time [clock format $SimulateFinishTime -format %T], Elapsed time: [format %d:%02d:%02d [expr ($SimulateElapsedTime/(60*60))] [expr (($SimulateElapsedTime/60)%60)] [expr (${SimulateElapsedTime}%60)]] "

  set  SimulateFinishTimeMs  [clock milliseconds]
  set  SimulateElapsedTimeMs [expr ($SimulateFinishTimeMs - $SimulateStartTimeMs)]
  
  set RunFile [open ${::osvvm::OsvvmBuildYamlFile} a]
  puts  $RunFile "        TestCaseFileName: \"$TestCaseFileName\""
  puts  $RunFile "        TestCaseGenerics: \"$::osvvm::GenericList\""
  puts  $RunFile "        ElapsedTime: [format %.3f [expr ${SimulateElapsedTimeMs}/1000.0]]"
  close $RunFile
}

# -------------------------------------------------
# SkipTest
#
proc SkipTestBuildYaml {SimName Reason} {

  set RunFile [open ${::osvvm::OsvvmBuildYamlFile} a]
  puts  $RunFile "      - TestCaseName: $SimName"
  puts  $RunFile "        Name: $SimName"
  puts  $RunFile "        Status: SKIPPED"
  puts  $RunFile "        Results: {Reason: \"$Reason\"}"
  close $RunFile
}

# end namespace ::osvvm
}
