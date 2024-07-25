#  File Name:         OsvvmScriptsCreateYamlReports.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#
#  Description
#    Support procedures to create the OSVVM YAML output
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
#     7/2024   2024.07    Updated YAML output and naming
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

package require fileutil


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
  puts  $RunFile "Version: \"$::osvvm::OsvvmBuildYamlVersion\""
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
  if {$::osvvm::ToolArgs eq ""} {
    puts  $RunFile "  Simulator:            \"${::osvvm::ToolName}\""
  } else { 
    puts  $RunFile "  Simulator:            \"${::osvvm::ToolName} ${::osvvm::ToolArgs}\""
  }
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
proc WriteDictOfDict2Yaml {YamlFile DictName {DictValues ""} {Prefix ""} } {
  if {$DictValues eq ""} {
    puts $YamlFile "${Prefix}${DictName}:            {}"
#    puts $YamlFile "${Prefix}${DictName}:            \"\""
  } else {
    puts $YamlFile "${Prefix}${DictName}:"
    foreach {Name Value} $DictValues {
      puts $YamlFile "${Prefix}  ${Name}: \"$Value\""
    }
  }
}

# -------------------------------------------------
proc WriteDictOfList2Yaml {YamlFile DictName {ListValues ""} {Prefix ""} } {
  if {$ListValues eq ""} {
    puts $YamlFile "${Prefix}${DictName}:            \"\""
  } else {
    puts $YamlFile "${Prefix}${DictName}:"
    foreach Name $ListValues {
      puts $YamlFile "${Prefix}  - \"${Name}\""
    }
  }
}

# -------------------------------------------------
proc WriteDictOfString2Yaml {YamlFile DictName {StringValue ""} {Prefix ""} } {
  puts $YamlFile "${Prefix}${DictName}: \"$StringValue\""
}

# -------------------------------------------------
proc WriteOsvvmSettingsYaml {ReportFile} {
  
  puts  $ReportFile "OsvvmSettingsInfo:"
  puts  $ReportFile "  BaseDirectory:        \"$::osvvm::OutputBaseDirectory\""
  puts  $ReportFile "  ReportsSubdirectory:  \"$::osvvm::ReportsSubdirectory\""
#  puts  $ReportFile "  HtmlThemeSubdirectory:      \"$::osvvm::HtmlThemeSubdirectory\""  
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
  
#   if {[catch {set HtmlThemeSourceDirectoryRel [::fileutil::relative [pwd] $::osvvm::OsvvmScriptDirectory]} errmsg]}  {
#     set HtmlThemeSourceDirectoryRel $::osvvm::OsvvmScriptDirectory
#   }
#   puts  $ReportFile "  HtmlThemeSourceDirectory:   \"${HtmlThemeSourceDirectoryRel}\""
  
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
  
  WriteDictOfList2Yaml   $ReportFile Report2CssFiles   $::osvvm::Report2CssFiles "  "
  puts $ReportFile "  Report2PngFile:  \"$::osvvm::Report2PngFile\""
}

# -------------------------------------------------
proc WriteTestCaseSettingsYaml {FileName} {

  set  YamlFile [open ${FileName} w]
  WriteDictOfString2Yaml $YamlFile Version $::osvvm::OsvvmTestCaseYamlVersion
  WriteDictOfString2Yaml $YamlFile TestCaseName $::osvvm::TestCaseName
	if {[info exists ::osvvm::TestSuiteName]} {
    WriteDictOfString2Yaml $YamlFile TestSuiteName  $::osvvm::TestSuiteName
  } else {
    WriteDictOfString2Yaml $YamlFile TestSuiteName
  }
  WriteDictOfString2Yaml $YamlFile BuildName $::osvvm::BuildName
  WriteDictOfDict2Yaml   $YamlFile Generics $::osvvm::GenericDict

  WriteDictOfString2Yaml $YamlFile TestSuiteDirectory    $::osvvm::TestSuiteDirectory
  WriteDictOfString2Yaml $YamlFile RequirementsYamlFile  $::osvvm::RequirementsYamlFile
  WriteDictOfString2Yaml $YamlFile AlertYamlFile         $::osvvm::AlertYamlFile
  WriteDictOfString2Yaml $YamlFile CovYamlFile           $::osvvm::CovYamlFile
  WriteDictOfDict2Yaml   $YamlFile ScoreboardDict        $::osvvm::ScoreboardDict
  WriteDictOfList2Yaml   $YamlFile TranscriptFiles       $::osvvm::TranscriptFiles

  WriteDictOfString2Yaml $YamlFile TestCaseFileName      $::osvvm::TestCaseFileName
  WriteDictOfString2Yaml $YamlFile GenericNames          $::osvvm::GenericNames

  WriteOsvvmSettingsYaml $YamlFile
  
  close $YamlFile
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
  WriteDictOfDict2Yaml $RunFile Generics $::osvvm::GenericDict  "        "
#  puts  $RunFile "        TestCaseGenerics: \"$::osvvm::GenericDict\""
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
