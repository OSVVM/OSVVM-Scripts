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
#  variable  TimeZoneName [clock format [clock seconds] -format %Z]

# -------------------------------------------------
proc  ElapsedTimeMs {StartTimeMs} {
  # Compute the time elapsed since a start time.
  #  StartTimeMs - Start time in milliseconds, from `clock milliseconds`.
  #
  # Returns the elapsed time in seconds with three decimals.
  set   FinishTimeMs  [clock milliseconds]
  set   Elapsed [expr ($FinishTimeMs - $StartTimeMs)]
  return [format %.3f [expr ${Elapsed}/1000.0]]
}

# -------------------------------------------------
proc  ElapsedTimeHms {StartTimeSec} {
  # Do nothing: placeholder for an elapsed time in hours, minutes and seconds.
  #  StartTimeSec - Start time in seconds.

#!! TODO Refactor from FinishBuildYaml
}

# -------------------------------------------------
proc GetIsoTime {TimeSeconds} {
  # Format a time as ISO 8601 date and time with the local time zone offset.
  #  TimeSeconds - Time in seconds, from `clock seconds`.
  #
  # Returns the time, formatted like `2026-10-10T16:20:00+02:00`.
  set  IsoTime [format "%s%s" [clock format $TimeSeconds -format {%Y-%m-%dT%H:%M:%S}] $::osvvm::IsoZone]
  return $IsoTime
}

# -------------------------------------------------
# SecondsToOsvvmTime
#
proc SecondsToOsvvmTime {TimeInSec} {
  # Format a time as date, time and time zone name.
  #  TimeInSec - Time in seconds, from `clock seconds`.
  #
  # Returns the time as `%Y-%m-%d`, a dash, `%H:%M:%S` and the time zone name in parentheses.
  return [clock format $TimeInSec -format {%Y-%m-%d - %H:%M:%S (%Z)}]
}

# -------------------------------------------------
proc StartBuildYaml {} {
  # Start the build's YAML file.
  #
  # Stores the build's start time in `BuildStartTime` and `BuildStartTimeMs`, prints it and writes the YAML
  # version and start date to the temporary build YAML file (`OsvvmTempYamlFile`), replacing an existing one.
  # Called by [build] when a build starts.
  variable BuildStartTime
  variable BuildStartTimeMs

  set  BuildStartTimeMs  [clock milliseconds]
  set  BuildStartTime    [clock seconds]
  set  StartTime [GetIsoTime $BuildStartTime]
  puts "Starting Build at time [clock format $BuildStartTime -format %T]"

  set   RunFile  [open ${::osvvm::OsvvmTempYamlFile} w]
  puts  $RunFile "Version: \"$::osvvm::OsvvmBuildYamlVersion\""
  puts  $RunFile "Date: $StartTime"
  close $RunFile
}
# -------------------------------------------------
proc WriteBuildInfoYaml {RunFile BuildName {NamePrefix ""} {InfoPrefix ""} } {
  # Write the build's name and information to a YAML file.
  #  RunFile    - Channel of the open YAML file.
  #  BuildName  - Name of the build.
  #  NamePrefix - Text written before the `Name` key.
  #  InfoPrefix - Text written before each key of the `BuildInfo` mapping.
  #
  # `BuildInfo` holds start and finish time, elapsed time, simulator name and version, OSVVM version, the build
  # error code and the analyze and simulate error counts.
  variable BuildStartTime
#  variable BuildStartTimeMs
  variable BuildErrorCode
  variable AnalyzeErrorCount
  variable SimulateErrorCount
  variable BuildFinishTime
  variable BuildElapsedTime

  puts  $RunFile "${NamePrefix}Name:     \"$BuildName\""
  puts  $RunFile "${InfoPrefix}BuildInfo:"
  puts  $RunFile "${InfoPrefix}  StartTime:            [GetIsoTime $BuildStartTime]"
  puts  $RunFile "${InfoPrefix}  FinishTime:           [GetIsoTime $BuildFinishTime]"
#  puts  $RunFile "${InfoPrefix}  ElapsedTime:              [ElapsedTimeMs $BuildStartTimeMs]"
  puts  $RunFile "${InfoPrefix}  ElapsedTime:              $BuildElapsedTime"
  if {$::osvvm::ToolArgs eq ""} {
    puts  $RunFile "${InfoPrefix}  Simulator:            \"${::osvvm::ToolName}\""
  } else {
    puts  $RunFile "${InfoPrefix}  Simulator:            \"${::osvvm::ToolName} ${::osvvm::ToolArgs}\""
  }
  puts  $RunFile "${InfoPrefix}  SimulatorVersion:     \"$::osvvm::ToolVersion\""
  puts  $RunFile "${InfoPrefix}  OsvvmVersion:         \"$::osvvm::OsvvmVersion\""

  puts  $RunFile "${InfoPrefix}  BuildErrorCode:       $BuildErrorCode"
  puts  $RunFile "${InfoPrefix}  AnalyzeErrorCount:    $AnalyzeErrorCount"
  puts  $RunFile "${InfoPrefix}  SimulateErrorCount:   $SimulateErrorCount"
}

# -------------------------------------------------
proc FinishBuildYaml {BuildName} {
  # Finish the build's YAML file.
  #  BuildName - Name of the build.
  #
  # Stores the finish and elapsed time, appends the build information (`WriteBuildInfoYaml`) and the report
  # settings (`WriteOsvvmSettingsYaml`) to the temporary build YAML file, and prints the start, finish and elapsed
  # time. Called by [build] when the build ends.
  variable BuildStartTimeMs
  variable BuildStartTime
  variable BuildFinishTime
  variable BuildElapsedTime

  # Print Elapsed time for last TestSuite (if any ran) and the entire build
  set   RunFile  [open ${::osvvm::OsvvmTempYamlFile} a]

  set   BuildFinishTime     [clock seconds]
  set   BuildElapsedTime    [ElapsedTimeMs $BuildStartTimeMs]
  set   BuildElapsedTimeSec    [expr ($BuildFinishTime - $BuildStartTime)]

  WriteBuildInfoYaml $RunFile $BuildName

  WriteOsvvmSettingsYaml $RunFile

  close $RunFile

  puts "Build Start time  [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  puts "Build Finish time [clock format $BuildFinishTime -format %T], Elapsed time: [format %d:%02d:%02d [expr ($BuildElapsedTimeSec/(60*60))] [expr (($BuildElapsedTimeSec/60)%60)] [expr (${BuildElapsedTimeSec}%60)]] "
}


# -------------------------------------------------
proc WriteIndexYaml {BuildName} {
  # Add the build to the YAML index of all builds.
  #  BuildName - Name of the build.
  #
  # Appends the build's entry to `OsvvmIndexYamlFile`, creating the file if it doesn't exist. The entry holds
  # directory, status, the passed, failed and skipped test case counts, error counts, times, tool and OSVVM
  # version. Called by [build] at its end; [Index2Html] creates the HTML index from the file.
  variable BuildStartTime
  variable BuildFinishTime
  variable BuildElapsedTime

  variable BuildStatus
  variable TestCasesPassed
  variable TestCasesFailed
  variable TestCasesSkipped
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable ToolName
  variable ToolArgs
  variable ToolVersion
  variable OsvvmVersion

  # Print Elapsed time for last TestSuite (if any ran) and the entire build
  if {[file exists ${::osvvm::OsvvmIndexYamlFile}]} {
    set   RunFile  [open ${::osvvm::OsvvmIndexYamlFile} a]
  } else {
    set   RunFile  [open ${::osvvm::OsvvmIndexYamlFile} w]
    puts $RunFile "Version:    \"${::osvvm::OsvvmIndexYamlVersion}\""
    puts $RunFile "Builds:"
  }

  # WriteBuildInfoYaml $RunFile $BuildName "  - " "    "
  puts  $RunFile "  - Name:     \"$BuildName\""
  puts  $RunFile "    Directory:           \"${BuildName}\""
  puts  $RunFile "    Status:              \"${BuildStatus}\""
  puts  $RunFile "    Passed:              ${TestCasesPassed}"
  puts  $RunFile "    Failed:              ${TestCasesFailed}"
  puts  $RunFile "    Skipped:             ${TestCasesSkipped}"
  puts  $RunFile "    Tests:               [expr {$TestCasesPassed + $TestCasesFailed + $TestCasesSkipped}]"
  puts  $RunFile "    AnalyzeErrorCount:   $ReportAnalyzeErrorCount"
  puts  $RunFile "    SimulateErrorCount:  $ReportSimulateErrorCount"
  puts  $RunFile "    BuildErrorCode:      $ReportBuildErrorCode"
  puts  $RunFile "    StartTime:           \"[GetIsoTime $BuildStartTime]\""
  puts  $RunFile "    FinishTime:          \"[GetIsoTime $BuildFinishTime]\""
  puts  $RunFile "    ElapsedTime:             $BuildElapsedTime"
  if {$::osvvm::ToolArgs eq ""} {
    puts  $RunFile "    ToolName:            \"${ToolName}\""
  } else {
    puts  $RunFile "    ToolName:            \"${ToolName} ${ToolArgs}\""
  }
  puts  $RunFile "    ToolVersion:          \"$ToolVersion\""
  puts  $RunFile "    OsvvmVersion:         \"$OsvvmVersion\""

  close $RunFile
}

# -------------------------------------------------
proc WriteDictOfDict2Yaml {YamlFile DictName {DictValues ""} {Prefix ""} } {
  # Write a key with a mapping of name value pairs to a YAML file.
  #  YamlFile   - Channel of the open YAML file.
  #  DictName   - Key to write.
  #  DictValues - Name value pairs. Empty: the key's value is `null`.
  #  Prefix     - Indentation written before each line.
  #
  # Values are written as quoted strings.
  if {$DictValues eq ""} {
    puts $YamlFile "${Prefix}${DictName}:           null"
  } else {
    puts $YamlFile "${Prefix}${DictName}:"
    foreach {Name Value} $DictValues {
      puts $YamlFile "${Prefix}  ${Name}: \"$Value\""
    }
  }
}

# -------------------------------------------------
proc WriteDictOfList2Yaml {YamlFile DictName {ListValues ""} {Prefix ""} } {
  # Write a key with a sequence of strings to a YAML file.
  #  YamlFile   - Channel of the open YAML file.
  #  DictName   - Key to write.
  #  ListValues - Strings to write. Empty: the key's value is an empty string.
  #  Prefix     - Indentation written before each line.
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
proc WriteDict2IndexYaml {YamlFile ListOfDictName {Indent "  "} } {
  # Write a list of mappings as a YAML sequence.
  #  YamlFile       - Channel of the open YAML file.
  #  ListOfDictName - List of mappings, each a list of name value pairs.
  #  Indent         - Indentation of the sequence.
  #
  # Values of keys ending in `Version` are written as quoted strings, other values as they are.
  set NominalPrefix [string cat $Indent "  " ]
  foreach DictName $ListOfDictName {
    set Prefix [string cat $Indent "- "]
    foreach {Name Value} $DictName {
#!!      if {[regexp {Version} $Name] } { }
      if {[string match {*Version} $Name] } {
        puts $YamlFile "${Prefix}${Name}: \"$Value\""
      } else {
        puts $YamlFile "${Prefix}${Name}: $Value"
      }
      set Prefix $NominalPrefix
    }
  }
}

# -------------------------------------------------
proc WriteDictOfString2Yaml {YamlFile DictKey {StringValue ""} {Prefix ""} } {
  # Write a key with a quoted string value to a YAML file.
  #  YamlFile    - Channel of the open YAML file.
  #  DictKey     - Key to write.
  #  StringValue - Value to write.
  #  Prefix      - Indentation written before the line.
  puts $YamlFile "${Prefix}${DictKey}: \"$StringValue\""
}

# -------------------------------------------------
proc WriteDictOfRelativePath2Yaml {YamlFile DictKey RelativePath {PathValue ""} {Prefix ""} } {
  # Write a key with a relative path to a YAML file.
  #  YamlFile     - Channel of the open YAML file.
  #  DictKey      - Key to write.
  #  RelativePath - Directory the path is made relative to.
  #  PathValue    - Path to write. Empty: the value is an empty string.
  #  Prefix       - Indentation written before the line.
  if {$PathValue ne ""} {
    puts $YamlFile "${Prefix}${DictKey}:  \"[::fileutil::relative $RelativePath $PathValue]\""
  } else {
    puts $YamlFile "${Prefix}${DictKey}: \"\""
  }
}

# -------------------------------------------------
proc WriteOsvvmSettingsYaml {ReportFile} {
  # Write the report settings to a YAML file.
  #  ReportFile - Channel of the open YAML file.
  #
  # Writes the mapping `OsvvmSettingsInfo`: the reports subdirectory, the build's log and HTML log files (if
  # `TranscriptExtension` creates them), the requirements subdirectory (if the build has a requirements file),
  # the code coverage file (if a simulation ran with code coverage), the report CSS files and the logo file.

  puts  $ReportFile "OsvvmSettingsInfo:"
#  puts  $ReportFile "  BaseDirectory:        \"$::osvvm::OsvvmBuildOutputDirectory\""  ;# no absolute paths
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
  # Write the settings YAML file of the current test case.
  #  FileName - YAML file to write.
  #
  # Holds the test case, test suite and build names, the test case's source file, generics, the paths of its
  # report files (relative to the build directory), its scoreboards, transcript files and the report settings
  # (`WriteOsvvmSettingsYaml`). Called after each [simulate]; [Simulate2Html] reads it.

  # Make paths relative to build directory
  set LocalOutDir [file join [pwd] $::osvvm::OutputBaseDirectory $::osvvm::BuildName]

  set  YamlFile [open ${FileName} w]
  WriteDictOfString2Yaml $YamlFile Version $::osvvm::OsvvmTestCaseYamlVersion
  WriteDictOfString2Yaml $YamlFile TestCaseName $::osvvm::TestCaseName
#  WriteDictOfString2Yaml $YamlFile TestCaseFile $::osvvm::LastAnalyzedFile
  WriteDictOfRelativePath2Yaml  $YamlFile  TestCaseFile  [file join $LocalOutDir $::osvvm::ReportsSubdirectory $::osvvm::TestSuiteName] $::osvvm::LastAnalyzedFile
	if {[info exists ::osvvm::TestSuiteName]} {
    set LocalTestSuiteName $::osvvm::TestSuiteName
  } else {
    set LocalTestSuiteName "Default"
  }
  WriteDictOfString2Yaml $YamlFile TestSuiteName  $LocalTestSuiteName
  WriteDictOfString2Yaml $YamlFile BuildName $::osvvm::BuildName
  WriteDictOfDict2Yaml   $YamlFile Generics $::osvvm::GenericDict

  WriteDictOfRelativePath2Yaml  $YamlFile  ReportsTestSuiteDirectory  $LocalOutDir  $::osvvm::ReportsTestSuiteDirectory
  WriteDictOfRelativePath2Yaml $YamlFile RequirementsYamlFile         $LocalOutDir $::osvvm::RequirementsYamlFile
  WriteDictOfRelativePath2Yaml $YamlFile AlertYamlFile                $LocalOutDir $::osvvm::AlertYamlFile
  WriteDictOfRelativePath2Yaml $YamlFile CovYamlFile                  $LocalOutDir $::osvvm::CovYamlFile
  WriteDictOfDict2Yaml     $YamlFile ScoreboardDict                   $::osvvm::ScoreboardDict
  WriteDictOfString2Yaml   $YamlFile TranscriptFiles                  $::osvvm::TranscriptFiles

  WriteDictOfString2Yaml $YamlFile TestCaseFileName             $::osvvm::TestCaseFileName
  WriteDictOfString2Yaml $YamlFile GenericNames                 $::osvvm::GenericNames

  WriteOsvvmSettingsYaml $YamlFile

  close $YamlFile
}

# -------------------------------------------------
proc StartTestSuiteBuildYaml {SuiteName FirstRun} {
  # Start a test suite in the build's YAML file.
  #  SuiteName - Name of the test suite.
  #  FirstRun  - `1` for the build's first test suite: the `TestSuites` key is written first.
  #
  # Appends the test suite's entry to the temporary build YAML file and stores its start time in
  # `TestSuiteStartTimeMs`. Called by [TestSuite].
  variable TestSuiteStartTimeMs

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]

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
  # Finish the current test suite in the build's YAML file.
  #
  # Appends the test suite's elapsed time to the temporary build YAML file. Called by [TestSuite] before the next
  # test suite starts, and by [build] at its end.
  variable TestSuiteStartTimeMs

  set   RunFile  [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "    ElapsedTime: [ElapsedTimeMs $TestSuiteStartTimeMs]"
  close $RunFile
}


# -------------------------------------------------
proc StartSimulateBuildYaml {TestName} {
  # Start a test case in the build's YAML file.
  #  TestName - Name of the test case.
  #
  # Stores the simulation's start time, prints it and appends the test case's entry to the temporary build YAML
  # file. Called by [simulate].
  variable SimulateStartTime
  variable SimulateStartTimeMs

  set SimulateStartTime   [clock seconds]
  set SimulateStartTimeMs [clock milliseconds]
  puts "Simulation Start time [clock format $SimulateStartTime -format %T]"

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "      - TestCaseName: \"$TestName\""
  close $RunFile
}


# -------------------------------------------------
proc FinishSimulateBuildYaml {} {
  # Finish the current test case in the build's YAML file.
  #
  # Prints the simulation's finish and elapsed time and appends the test case's file name, generics and elapsed
  # time to the temporary build YAML file. Called after each [simulate].
  variable TestCaseFileName
  variable SimulateStartTime
  variable SimulateStartTimeMs

  #puts "Start time  [clock format $SimulateStartTime -format %T]"
  set  SimulateFinishTime    [clock seconds]
  set  SimulateElapsedTime   [expr ($SimulateFinishTime - $SimulateStartTime)]

  puts "Simulation Finish time [clock format $SimulateFinishTime -format %T], Elapsed time: [format %d:%02d:%02d [expr ($SimulateElapsedTime/(60*60))] [expr (($SimulateElapsedTime/60)%60)] [expr (${SimulateElapsedTime}%60)]] "

  set  SimulateFinishTimeMs  [clock milliseconds]
  set  SimulateElapsedTimeMs [expr ($SimulateFinishTimeMs - $SimulateStartTimeMs)]

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
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
  # Add a skipped test case to the build's YAML file.
  #  SimName - Name of the test case.
  #  Reason  - Reason for skipping it.
  #
  # The test case's status is `SKIPPED`. Called by [SkipTest].

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "      - TestCaseName: $SimName"
  puts  $RunFile "        Name: $SimName"
  puts  $RunFile "        Status: \"SKIPPED\""
  puts  $RunFile "        Results: null"
  puts  $RunFile "        Reason: \"$Reason\""
  puts  $RunFile "        ElapsedTime: 0"
  close $RunFile
}

# -------------------------------------------------
# AnalyzeFailed
#
proc AnalyzeFailedBuildYaml {LibraryUnit Reason} {
  # Add a test case, whose analyze failed, to the build's YAML file.
  #  LibraryUnit - Name of the test case.
  #  Reason      - Reason for the failure.
  #
  # The test case's status is `ANALYZE_FAILED`. Called by [simulate] if the previous [analyze] failed.

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "      - TestCaseName: $LibraryUnit"
  puts  $RunFile "        Name: $LibraryUnit"
  puts  $RunFile "        Status: \"ANALYZE_FAILED\""
  puts  $RunFile "        Results: null"
  puts  $RunFile "        Reason: \"$Reason\""
  puts  $RunFile "        ElapsedTime: 0"
  close $RunFile
}

# -------------------------------------------------
# ExpectedStatus
#
proc ExpectedStatus {Status Failure Error Warning {Reason ""}} {
  # Set the expected result of the current test case.
  #  Status  - Expected status: `PASSED`, `FAILED`, `SKIPPED`, `NOREPORTS` or `ANALYZE_FAILED`.
  #  Failure - Expected number of failure alerts.
  #  Error   - Expected number of error alerts.
  #  Warning - Expected number of warning alerts.
  #  Reason  - Reason for the expected result.
  #
  # Call it after the test case's [simulate] or [SkipTest]. It appends the expected results to the test case's
  # entry in the build's YAML file. The build reports count the test case as passed if its status and alert
  # counts match the expected ones, else as failed. This way, a test case expected to fail passes.
  #
  # See also: [KnownStatus]

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "        ExpectedResults:"
  puts  $RunFile "          Status: \"$Status\""
  puts  $RunFile "          TotalErrors: [expr {abs($Failure) + abs($Error) + abs($Warning)}]"
  puts  $RunFile "          AlertCount:"
  puts  $RunFile "            Failure: $Failure"
  puts  $RunFile "            Error: $Error"
  puts  $RunFile "            Warning: $Warning"
  puts  $RunFile "        Reason: \"$Reason\""
  close $RunFile
}

# -------------------------------------------------
# KnownStatus
#
proc KnownStatus {Status Reason} {
  # Record the known status of the current test case.
  #  Status - Known status: `PASSED`, `FAILED`, `SKIPPED`, `NOREPORTS` or `ANALYZE_FAILED`.
  #  Reason - Reason for the status.
  #
  # Call it after the test case's [simulate] or [SkipTest]. It appends the known status to the test case's entry
  # in the build's YAML file. The build reports show it, and count a test case whose status differs from the
  # known one as a status change.
  #
  # See also: [ExpectedStatus]

  set RunFile [open ${::osvvm::OsvvmTempYamlFile} a]
  puts  $RunFile "        KnownStatus: \"$Status\""
  puts  $RunFile "        Reason: \"$Reason\""
  close $RunFile
}

namespace export ExpectedStatus KnownStatus

# end namespace ::osvvm
}
