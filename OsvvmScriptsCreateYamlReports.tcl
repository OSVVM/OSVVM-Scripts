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
#    05/2024   2024.05    Updated to Decouple Report2Html from OSVVM.  Yaml = source of information.
#    04/2024   2024.04    Updated report formatting
#    12/2022   2022.12    Refactored from OsvvmProjectScripts
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2022-2024 by SynthWorks Design Inc.
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
  variable  TclZone      [clock format [clock seconds] -format %z]
  variable  IsoZone      [format "%s:%s" [string range $TclZone 0 2] [string range $TclZone 3 4]] 
  variable  TimeZoneName [clock format [clock seconds] -format %Z]

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
  puts  $RunFile "Version: $::osvvm::OsvvmVersion"
  puts  $RunFile "Date: $StartTime"
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
  puts  $RunFile "BuildInfo:"
  puts  $RunFile "  StartTime:            [GetIsoTime $BuildStartTime]"
  puts  $RunFile "  FinishTime:           [GetIsoTime $BuildFinishTime]"
  puts  $RunFile "  Elapsed:              [ElapsedTimeMs $BuildStartTimeMs]"
  puts  $RunFile "  Simulator:            \"${::osvvm::ToolName} ${::osvvm::ToolArgs}\""
  puts  $RunFile "  SimulatorVersion:     \"$::osvvm::ToolVersion\""
  puts  $RunFile "  OsvvmVersion:         \"$::osvvm::OsvvmVersion\""

  puts  $RunFile "  BuildErrorCode:       $BuildErrorCode"
  puts  $RunFile "  AnalyzeErrorCount:    $AnalyzeErrorCount"
  puts  $RunFile "  SimulateErrorCount:   $BuildErrorCode"
  
  WriteOsvvmSettingsYaml $RunFile

  close $RunFile

  puts "Build Start time  [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  puts "Build Finish time [clock format $BuildFinishTime -format %T], Elapsed time: [format %d:%02d:%02d [expr ($BuildElapsedTime/(60*60))] [expr (($BuildElapsedTime/60)%60)] [expr (${BuildElapsedTime}%60)]] "
}

# -------------------------------------------------
proc WriteOsvvmSettingsYaml {ReportFile} {
  
  puts  $ReportFile "OsvvmSettingsInfo:"
  puts  $ReportFile "  BaseDirectory:        \"$::osvvm::OutputBaseDirectory\""
  puts  $ReportFile "  ReportsSubdirectory:  \"$::osvvm::ReportsSubdirectory\""
  puts  $ReportFile "  CssSubdirectory:      \"$::osvvm::CssSubdirectory\""  
  if {$::osvvm::TranscriptExtension ne "none"} {
    puts  $ReportFile "  SimulationLogFile: \"[file join ${::osvvm::LogSubdirectory} ${::osvvm::BuildName}.log]\""
  } else {
    puts  $ReportFile "  SimulationLogFile: \"\""
  }
  if {$::osvvm::TranscriptExtension eq "html"} {
    puts  $ReportFile "  SimulationHtmlLogFile: \"[file join ${::osvvm::LogSubdirectory} ${::osvvm::BuildName}_log.html]\""
  } else {
    puts  $ReportFile "  SimulationHtmlLogFile: \"\""
  }
  puts  $ReportFile "  CssPngSourceDirectory:   \"${::osvvm::OsvvmScriptDirectory}\""
  if {[file exists [file join $::osvvm::ReportsDirectory ${::osvvm::BuildName}_req.yml]]} {
    puts  $ReportFile "  RequirementsSubdirectory: \"$::osvvm::ReportsSubdirectory\""
  } else {
    puts  $ReportFile "  RequirementsSubdirectory: \"\""
  }
  if {$::osvvm::RanSimulationWithCoverage eq "true"} {
    set CodeCoverageFile [vendor_GetCoverageFileName ${::osvvm::BuildName}]
    puts  $ReportFile "  CoverageSubdirectory:    \"[file join $::osvvm::CoverageSubdirectory  $CodeCoverageFile]\"" 
  } else {
    puts  $ReportFile "  CoverageSubdirectory: \"\""
  }
  
  puts $ReportFile "  Report2CssFiles: \"$::osvvm::Report2CssFiles\""
  puts $ReportFile "  Report2PngFile:  \"$::osvvm::Report2PngFile\""
}

# -------------------------------------------------
proc WriteTestCaseSettingsYaml {FileName} {

  set  SettingsFile [open ${FileName} w]
  puts $SettingsFile "TestCaseName:           \"$::osvvm::TestCaseName\""
	if {[info exists ::osvvm::TestSuiteName]} {
    puts $SettingsFile "TestSuiteName:          \"$::osvvm::TestSuiteName\""
  } else {
    puts $SettingsFile "TestSuiteName:          \"\""
  }
  puts $SettingsFile "BuildName:              \"$::osvvm::BuildName\""
  puts $SettingsFile "GenericList:            \"$::osvvm::GenericList\""
  puts $SettingsFile "TestCaseFileName:       \"$::osvvm::TestCaseFileName\""
  puts $SettingsFile "GenericNames:           \"$::osvvm::GenericNames\""
  
  puts $SettingsFile "TestSuiteDirectory:    \"$::osvvm::TestSuiteDirectory\""
  puts $SettingsFile "RequirementsYamlFile:  \"$::osvvm::RequirementsYamlFile\""
  puts $SettingsFile "AlertYamlFile:         \"$::osvvm::AlertYamlFile\""
  puts $SettingsFile "CovYamlFile:           \"$::osvvm::CovYamlFile\""
  puts $SettingsFile "ScoreboardFiles:       \"$::osvvm::ScoreboardFiles\""
  puts $SettingsFile "ScoreboardNames:       \"$::osvvm::ScoreboardNames\""
  puts $SettingsFile "TranscriptFiles:       \"$::osvvm::TranscriptFiles\""
  
  WriteOsvvmSettingsYaml $SettingsFile
  
  close $SettingsFile
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


# -------------------------------------------------
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
