#  File Name:         ReportBuildYaml2Dict.tcl
#  Purpose:           Convert OSVVM YAML build reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM YAML build reports to TCL Dictionary
#    Visible externally:  ReportBuildYaml2Dict
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
#    07/2024   2024.07    Handling NOCHECKS as FAIL or PASS.  Naming updates
#    05/2024   2024.05    Refactored. Decoupled.  Yaml = source of information.
#    04/2024   2024.04    Updated report formatting
#    07/2023   2023.07    Updated file handler to search for user defined HTML headers
#    12/2022   2022.12    Refactored to only use static OSVVM information
#    05/2022   2022.05    Updated directory handling
#    02/2022   2022.02    Added links for code coverage.
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021 - 2024 by SynthWorks Design Inc.
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

package require yaml

#  Notes:
#  The following variables are set by GetPathSettings that read the YAML file
#      Report2HtmlThemeDirectory
#      Report2BaseDirectory
#      Report2ReportsSubdirectory
#      Report2LogSubdirectory
#      Report2HtmlThemeSourceDirectory
#      Report2RequirementsSubdirectory - value is "" if requirements not used
#      Report2CoverageSubdirectory - value is "" if coverage not used
#

# -------------------------------------------------
# CreateBuildReports
#
proc CreateBuildReports {ReportFile} {
  # Create the HTML and JUnit XML build summary reports from a build YAML file.
  #  ReportFile - Build YAML file `<BuildName>.yml`.
  #
  # Reads the file ([ReportBuildYaml2Dict]) and writes `<BuildName>.html` ([ReportBuildDict2Html]) and `<BuildName>.xml`
  # ([ReportBuildDict2Junit]) into its directory. Afterwards `BuildDict` is cleared, unless `TclDebug` is set.
  #
  # Called at the end of a [build].
  #
  # See also: [ReportBuildYaml2Dict] [ReportBuildDict2Html] [ReportBuildDict2Junit]
  ReportBuildYaml2Dict ${ReportFile}
  ReportBuildDict2Html
  ReportBuildDict2Junit
  if {!$::osvvm::TclDebug} {
    set ::osvvm::BuildDict ""
  }
}

# -------------------------------------------------
# ReportBuildYaml2Dict
#
proc ReportBuildYaml2Dict {ReportFile} {
  # Read a build YAML file and compute the results of the build.
  #  ReportFile - Build YAML file `<BuildName>.yml`.
  #
  # Sets `Report2BaseDirectory` to the file's directory, `ReportFileRoot` to its path without extension,
  # `ReportBuildName` to its name without extension and `BuildDict` to its contents. Then computes the path settings,
  # the test suite summaries and the build status (`LocalReportBuildYaml2Dict`), used by [ReportBuildDict2Html],
  # [ReportBuildDict2Junit] and `ReportBuildStatus`. On an error, `CallbackOnError_ReportBuildYaml2Dict` is called.
  #
  # See also: [CreateBuildReports]
  variable ReportFileRoot
  variable ReportBuildName
  variable BuildDict
  variable Report2BaseDirectory


  # Extract BaseDirectory, BuildName, and HtmlFileName from ReportFile
  set Report2BaseDirectory   [file dirname $ReportFile]    ;# Set before GetOsvvmPathSettings
  set ReportFileRoot         [file rootname $ReportFile]
  set ReportBuildName        [file tail $ReportFileRoot]


  # Read the YAML file into a dictionary
  set BuildDict [::yaml::yaml2dict -file ${ReportFile}]

  # Convert YAML file to HTML & catch results
  set ErrorCode [catch {LocalReportBuildYaml2Dict $BuildDict} errmsg]

  if {$ErrorCode} {
    CallbackOnError_ReportBuildYaml2Dict $ReportFile $errmsg
  }
}

# -------------------------------------------------
# LocalReportBuildYaml2Dict
#
proc LocalReportBuildYaml2Dict {BuildDict} {
  # Compute the path settings, the test suite summaries and the status of a build.
  #  BuildDict - Contents of the build YAML file.
  #
  # Calls `GetOsvvmPathSettings`, `ElaborateTestSuites` and `GetBuildStatus`. Errors are handled by
  # [ReportBuildYaml2Dict].
  variable ReportBuildName

  GetOsvvmPathSettings $BuildDict

  ElaborateTestSuites $BuildDict

  GetBuildStatus $BuildDict

}

# -------------------------------------------------
# ReportBuildStatus
#
proc ReportBuildStatus {} {
  # Print the summary line of the build.
  #
  # Prints `Build: <BuildName> PASSED`, followed by the number of passed, failed and skipped test cases and of analyze
  # and simulate errors. For a failed build, the line starts with `BuildError:` and ends with the build error code. Uses
  # the results of [ReportBuildYaml2Dict].
  variable ReportBuildName
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus
  variable TestCasesPassed
  variable TestCasesFailed
  variable TestCasesSkipped

  if {$BuildStatus eq "PASSED"} {
    puts "Build: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount}"
  } else {
    puts "BuildError: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount},  Build Error Code: $ReportBuildErrorCode"
  }
}

# -------------------------------------------------
# MatchExpectedResults
#
proc MatchExpectedResults {TestStatus TestCase} {
  # Check whether a test case has its expected results.
  #  TestStatus - Status of the test case.
  #  TestCase   - Results of the test case from the build YAML file, with its `ExpectedResults`.
  #
  # For the status `NOREPORTS`, `SKIPPED` or `ANALYZE_FAILED`, only the status is compared. Otherwise the status, the
  # total error count and the failure, error and warning alert counts must equal the expected ones.
  #
  # Returns 1 if the test case has its expected results, else 0.
  #
  # See also: [ExpectedStatus]
  set ExpectedResults      [dict get $TestCase ExpectedResults]
  set ExpectedAlertCount   [dict get $ExpectedResults AlertCount]
  set ExpectedStatus       [dict get $ExpectedResults Status]
  set ExpectedTotalErrors  [dict get $ExpectedResults TotalErrors]
  set ExpectedFailure      [dict get $ExpectedAlertCount Failure]
  set ExpectedError        [dict get $ExpectedAlertCount Error]
  set ExpectedWarning      [dict get $ExpectedAlertCount Warning]

  if { $TestStatus eq "NOREPORTS" || $TestStatus eq "SKIPPED" || $TestStatus eq "ANALYZE_FAILED"} {
    return [expr {($ExpectedStatus eq $TestStatus)}]

  } else {
    set ActualStatus         [dict get $TestCase Status]
    set ActualResults        [dict get $TestCase Results]
    set ActualAlertCount     [dict get $ActualResults AlertCount]
    set ActualTotalErrors    [dict get $ActualResults TotalErrors]
    set ActualFailure        [dict get $ActualAlertCount Failure]
    set ActualError          [dict get $ActualAlertCount Error]
    set ActualWarning        [dict get $ActualAlertCount Warning]

    # set MatchStatus [expr $ExpectedStatus eq $TestStatus]
    set MatchErrors [expr {$ExpectedTotalErrors == $ActualTotalErrors}]
    set MatchAlerts [expr ($ExpectedFailure == $ActualFailure) && ($ExpectedError == $ActualError) && ($ExpectedWarning == $ActualWarning)]
    return [expr {($ExpectedStatus eq $ActualStatus) && $MatchErrors && $MatchAlerts}]
  }

}

# -------------------------------------------------
# ElaborateTestSuites
#
proc ElaborateTestSuites {TestDict} {
  # Count the results of the test cases per test suite and for the build.
  #  TestDict - Contents of the build YAML file.
  #
  # Sets `HaveTestSuites`, the counts `TestCasesPassed`, `TestCasesFailed`, `TestCasesSkipped`, `TrackedTestCasesFailed`
  # and `TrackedTestCasesStatusChange`, and `BuildStatus`. Fills `TestSuiteSummaryArrayOfDictionaries` with one entry
  # per test suite: name, status, passed, failed and skipped test cases, requirements passed and goal, disabled alerts
  # and elapsed time.
  #
  # - A test case with expected results passes if it has them (`MatchExpectedResults`).
  # - Otherwise it fails if its test name doesn't match its VHDL name and `FailOnVhdlNameNotMatchTestName` is set. It
  #   passes with the status `PASSED`, or `NOCHECKS` while `FailOnNoChecks` isn't set, and fails with any other
  #   status. A test case without results has the status `NOREPORTS`.
  # - A failed test case with a known status ([KnownStatus]) counts as tracked failure if its status equals the known
  #   status. A test case whose status differs from its known status counts as status change.
  # - A test suite is `FAILED` with a failed test case, else `PASSED` with a passed one, else `SKIPPED` with a skipped
  #   one, else `EMPTY`. A failed test suite fails the build, an empty one if `FailOnEmptyTestSuite` is set.

  # Summary dictionaries
  variable TestSuiteSummaryArrayOfDictionaries ""
  variable HaveTestSuites
  # Detailed Build Status
  variable BuildStatus "PASSED"
  variable TestCasesPassed 0
  variable TestCasesFailed 0
  variable TestCasesSkipped 0
  variable TrackedTestCasesFailed 0
  variable TrackedTestCasesStatusChange 0

  set HaveTestSuites [dict exists $TestDict TestSuites]

  if { $HaveTestSuites } {
    foreach TestSuite [dict get $TestDict TestSuites] {
      set SuitePassed 0
      set SuiteFailed 0
      set SuiteSkipped 0
      set TrackedSuiteFailed 0
      set TrackedSuiteStatusChange 0
      set SuiteReqPassed 0
      set SuiteReqGoal 0
      set SuiteDisabledAlerts 0
      set SuiteName [dict get $TestSuite Name]
      foreach TestCase [dict get $TestSuite TestCases] {
        set TestName    [dict get $TestCase TestCaseName]
#!! This could all be simplified with a dict merge that sets TestStatus "FAILED", TestReqGoal 0, TestReqPassed 0, DisabledAlertCount 0
#!! Independent of SkipTest, ..., VHDL side will fail with no results and no TestStatus
#!! Good defaults could minimize info provided by SkipTest and others
        if { [dict exists $TestCase Results] } {
          set TestStatus  [dict get $TestCase Status]
          set TestResults [dict get $TestCase Results]
          if { $TestStatus ne "SKIPPED" && $TestStatus ne "ANALYZE_FAILED"} {
            set TestReqGoal   [dict get $TestResults RequirementsGoal]
            set TestReqPassed [dict get $TestResults RequirementsPassed]
            set SuiteDisabledAlerts [expr $SuiteDisabledAlerts + [SumAlertCount [dict get $TestResults DisabledAlertCount]]]
            set VhdlName [dict get $TestCase Name]
          } else {
            set TestReqGoal   0
            set TestReqPassed 0
            set VhdlName $TestName
          }
        } else {
          # Nothing is there
          set TestStatus  "NOREPORTS"
          set TestReqGoal   0
          set TestReqPassed 0
          set VhdlName $TestName
        }

        # Count results.
        # If test cases run parallel, must be done here.
        set  ThisTestFailed FALSE
        if { [dict exists $TestCase ExpectedResults] } {
          if {[MatchExpectedResults $TestStatus $TestCase]} {
            incr SuitePassed
            incr TestCasesPassed
          } else {
            incr SuiteFailed
            incr TestCasesFailed
            set  ThisTestFailed TRUE
          }
        } elseif { $TestStatus eq "SKIPPED" } {
          incr SuiteSkipped
          incr TestCasesSkipped
        } else {
          if { (${TestName} ne ${VhdlName}) && $::osvvm::FailOnVhdlNameNotMatchTestName} {
            incr SuiteFailed
            incr TestCasesFailed
            set  ThisTestFailed TRUE
          } elseif { ($TestStatus eq "PASSED") || (($TestStatus eq "NOCHECKS") && !($::osvvm::FailOnNoChecks)) } {
            incr SuitePassed
            incr TestCasesPassed
            if { $TestReqGoal > 0 } {
              incr SuiteReqGoal
              if { $TestReqPassed >= $TestReqGoal } {
                incr SuiteReqPassed
              }
            }
          } else {
            # TestStatus = FAILED or TIMEOUT or ANALYZE_FAILED or STOPLIMIT
            # TestStatus = NOCHECKS if OsvvmVersionCompatibility is 2024.07 (or later) or
            #    FailOnNoChecks is set to TRUE in OsvvmSettingsLocal.tcl
            incr SuiteFailed
            incr TestCasesFailed
            set  ThisTestFailed TRUE
          }
        }
# Mark FAILED before this and if
        if { [dict exists $TestCase KnownStatus] } {
          set KnownStatus     [dict get $TestCase KnownStatus]
          if {$TestStatus eq $KnownStatus} {
            if {$ThisTestFailed} {
              incr TrackedTestCasesFailed
              incr TrackedSuiteFailed
            }
          } else {
            incr TrackedTestCasesStatusChange
            incr TrackedSuiteStatusChange
          }
        }
      }
      if {[dict exists $TestSuite ElapsedTime]} {
        set SuiteElapsedTime [dict get $TestSuite ElapsedTime]
      } else {
        set SuiteElapsedTime 0
      }
      if {$SuiteFailed > 0} {
        set SuiteStatus "FAILED"
        set BuildStatus "FAILED"
      } elseif { $SuitePassed > 0 } {
        set SuiteStatus "PASSED"
      } elseif { $SuiteSkipped > 0 } {
        set SuiteStatus "SKIPPED"
      } else {
        set SuiteStatus "EMPTY"
        if {$::osvvm::FailOnEmptyTestSuite} {
          set BuildStatus "FAILED"
        }
      }
      set SuiteDict [dict create Name       $SuiteName]
      dict append SuiteDict Status          $SuiteStatus
      dict append SuiteDict PASSED          $SuitePassed
      dict append SuiteDict FAILED          $SuiteFailed
      dict append SuiteDict SKIPPED         $SuiteSkipped
      dict append SuiteDict ReqPassed       $SuiteReqPassed
      dict append SuiteDict ReqGoal         $SuiteReqGoal
      dict append SuiteDict DisabledAlerts  $SuiteDisabledAlerts
      dict append SuiteDict ElapsedTime     $SuiteElapsedTime
      lappend TestSuiteSummaryArrayOfDictionaries $SuiteDict
    }
  }
}

# -------------------------------------------------
# GetBuildStatus
#
proc GetBuildStatus {TestDict} {
  # Read the build information of a build and complete its status.
  #  TestDict - Contents of the build YAML file.
  #
  # Sets from `BuildInfo`: the build error code, the analyze and simulate error counts, start and finish time, elapsed
  # time (seconds, rounded seconds and `h:mm:ss`), simulator, simulator version and OSVVM version. Missing entries get
  # defaults; a missing `BuildInfo` counts as build error. Sets `BuildStatus` to `FAILED` on a build, analyze or
  # simulate error, and `RequirementsRelativeHtml` to the build's requirements report if the build uses requirements.
  variable ReportBuildName

  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus
  variable ReportStartTime
  variable ReportIsoStartTime
  variable ReportFinishTime
  variable ElapsedTimeSeconds
  variable ElapsedTimeSecondsInt
  variable ElapsedTimeHms
  variable ReportSimulator
  variable ReportSimulatorVersion
  variable OsvvmVersion
  variable RequirementsRelativeHtml


#!! Simplify with dict merge
  if { [dict exists $TestDict BuildInfo] } {
    set RunInfo   [dict get $TestDict BuildInfo]
  } else {
    set RunInfo   [dict create BuildErrorCode 1]
  }
  if {[dict exists $RunInfo BuildErrorCode]} {
    set ReportBuildErrorCode [dict get $RunInfo BuildErrorCode]
  } else {
    set ReportBuildErrorCode 1
  }
  if {[dict exists $RunInfo AnalyzeErrorCount]} {
    set ReportAnalyzeErrorCount [dict get $RunInfo AnalyzeErrorCount]
  } else {
    set ReportAnalyzeErrorCount 0
  }
  if {[dict exists $RunInfo SimulateErrorCount]} {
    set ReportSimulateErrorCount [dict get $RunInfo SimulateErrorCount]
  } else {
    set ReportSimulateErrorCount 0
  }
  if {($ReportBuildErrorCode != 0) || $ReportAnalyzeErrorCount || $ReportSimulateErrorCount} {
    set BuildStatus "FAILED"
  }

  # Print BuildInfo
  set BuildInfo $RunInfo
  if {[dict exists $RunInfo StartTime]} {
    set ReportIsoStartTime [dict get $RunInfo StartTime]
    set ReportStartTime [IsoToOsvvmTime $ReportIsoStartTime]
  } else {
    set ReportIsoStartTime ""
    set ReportStartTime ""
  }
  if {[dict exists $RunInfo FinishTime]} {
    set ReportFinishTime [IsoToOsvvmTime [dict get $RunInfo FinishTime]]
  } else {
    set ReportFinishTime ""
  }

  if {[dict exists $RunInfo ElapsedTime]} {
    set ElapsedTimeSeconds [dict get $RunInfo ElapsedTime]
  } else {
    set ElapsedTimeSeconds 0.0
  }
  set ElapsedTimeSecondsInt [expr {round($ElapsedTimeSeconds)}]
  set ElapsedTimeHms     [format %d:%02d:%02d [expr ($ElapsedTimeSecondsInt/(60*60))] [expr (($ElapsedTimeSecondsInt/60)%60)] [expr (${ElapsedTimeSecondsInt}%60)]]

  if {[dict exists $RunInfo Simulator]} {
    set ReportSimulator [dict get $RunInfo Simulator]
  } else {
    set ReportSimulator "Unknown"
  }

  if {[dict exists $RunInfo SimulatorVersion]} {
    set ReportSimulatorVersion [dict get $RunInfo SimulatorVersion]
  } else {
    set ReportSimulatorVersion "Unknown"
  }

  if {[dict exists $RunInfo OsvvmVersion]} {
    set OsvvmVersion [dict get $RunInfo OsvvmVersion]
  } else {
    set OsvvmVersion ""
  }

  if {$::osvvm::Report2RequirementsSubdirectory ne ""} {
    set RequirementsRelativeHtml [file join $::osvvm::Report2RequirementsSubdirectory ${ReportBuildName}_req.html]
  } else {
    set RequirementsRelativeHtml ""
  }
}


# -------------------------------------------------
# IsoToOsvvmTime
#
proc IsoToOsvvmTime {IsoTime} {
  # Convert an ISO 8601 time stamp to the time format of OSVVM's reports.
  #  IsoTime - Time stamp `YYYY-MM-DDThh:mm:ss+hhmm`.
  #
  # Returns the time as `YYYY-MM-DD - hh:mm:ss (<time zone>)`, in the local time zone.
  set TimeInSec [clock scan $IsoTime -format {%Y-%m-%dT%H:%M:%S%z} ]
  return [clock format $TimeInSec -format {%Y-%m-%d - %H:%M:%S (%Z)}]
}




