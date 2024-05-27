#  File Name:         Report2Html.tcl
#  Purpose:           Convert OSVVM YAML build reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM YAML build reports to HTML
#    Visible externally:  Report2Html
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
#      Report2CssDirectory 
#      Report2BaseDirectory
#      Report2ReportsSubdirectory
#      Report2LogSubdirectory
#      Report2CssPngSourceDirectory
#      Report2RequirementsSubdirectory - value is "" if requirements not used
#      Report2CoverageSubdirectory - value is "" if coverage not used
#

# -------------------------------------------------
# build
#
proc Report2Html {ReportFile} {
  variable ResultsFile
  variable ReportBuildName

  # Extract BuildName and HtmlFileName from ReportFile
  set ReportFileRoot  [file rootname $ReportFile]
  set ReportBuildName [file tail $ReportFileRoot]
  set FileName ${ReportFileRoot}.html
  
  
  # Read the YAML file into a dictionary
  set Report2HtmlDict [::yaml::yaml2dict -file ${ReportFile}]

  # Open results file
  set ResultsFile [open ${FileName} w]
  
  # Convert YAML file to HTML & catch results
  set ErrorCode [catch {LocalReport2Html $Report2HtmlDict} errmsg]
  
  # Close Results file - done here s.t. it is closed even if it fails
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Report2Html $ReportFile $errmsg
  }
}

# -------------------------------------------------
# build
#
proc LocalReport2Html {Report2HtmlDict} {
  variable ResultsFile
  variable ReportBuildName

  set VersionNum  [dict get $Report2HtmlDict Version]
  
  GetOsvvmPathSettings $Report2HtmlDict 
  
  CreateOsvvmReportHeader $ResultsFile "$ReportBuildName Build Report"
  
  ElaborateTestSuites $Report2HtmlDict

  CreateBuildReportSummary $Report2HtmlDict
  
  CreateTestSuiteSummary 
  
  CreateTestCaseSummaries $Report2HtmlDict
  
  CreateOsvvmReportFooter $ResultsFile

}

# -------------------------------------------------
# ReportBuildStatus
#
proc ReportBuildStatus {} {
  variable ReportBuildName
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus 
  variable TestCasesPassed 
  variable TestCasesFailed 
  variable TestCasesSkipped 
  variable TestCasesRun 
  
  if {$BuildStatus eq "PASSED"} {
    puts "Build: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount}"
  } else {
    puts "BuildError: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount},  Build Error Code: $ReportBuildErrorCode"
  }
}


# -------------------------------------------------
# ElaborateTestSuites
#
proc ElaborateTestSuites {TestDict} {
  variable BuildStatus "PASSED"
  variable TestCasesPassed 0
  variable TestCasesFailed 0
  variable TestCasesSkipped 0
  variable TestCasesRun 0
  variable CreateTestCaseSummariesummary ""
  variable HaveTestSuites
  
  set HaveTestSuites [dict exists $TestDict TestSuites]

  if { $HaveTestSuites } {
    foreach TestSuite [dict get $TestDict TestSuites] {
      set SuitePassed 0
      set SuiteFailed 0
      set SuiteSkipped 0
      set SuiteReqPassed 0
      set SuiteReqGoal 0
      set SuiteDisabledAlerts 0
      set SuiteName [dict get $TestSuite Name]
      foreach TestCase [dict get $TestSuite TestCases] {
        set TestName    [dict get $TestCase TestCaseName]
        if { [dict exists $TestCase Results] } { 
          set TestStatus  [dict get $TestCase Status]
          set TestResults [dict get $TestCase Results]
          if { $TestStatus ne "SKIPPED" } {
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
          set TestStatus  "FAILED"
          set TestReqGoal   0
          set TestReqPassed 0
          set VhdlName $TestName
        }
        if { $TestStatus eq "SKIPPED" } {
          incr SuiteSkipped
          incr TestCasesSkipped
        } else {
          incr TestCasesRun
          if { ${TestName} ne ${VhdlName} } {
            incr SuiteFailed
            incr TestCasesFailed
          } elseif { $TestStatus eq "PASSED" } {
            incr SuitePassed
            incr TestCasesPassed
            if { $TestReqGoal > 0 } {
              incr SuiteReqGoal
              if { $TestReqPassed >= $TestReqGoal } {
                incr SuiteReqPassed
              }
            }
          } else {
            incr SuiteFailed
            incr TestCasesFailed
          }
        }
      }
      if {[dict exists $TestSuite ElapsedTime]} {
        set SuiteElapsedTime [dict get $TestSuite ElapsedTime]
      } else {
        set SuiteElapsedTime 0
      }
      if { $SuitePassed > 0 && $SuiteFailed == 0 } {
        set SuiteStatus "PASSED"
      } else {
        set SuiteStatus "FAILED"
        set BuildStatus "FAILED"
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
      lappend CreateTestCaseSummariesummary $SuiteDict
    }
  }
}

# -------------------------------------------------
# CreateBuildReportSummary
#
proc CreateBuildReportSummary {TestDict} {
  variable ResultsFile
  variable ReportBuildName
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus 
  variable TestCasesPassed 
  variable TestCasesFailed 
  variable TestCasesSkipped 
  variable TestCasesRun 

  if {[info exists CreateTestCaseSummariesummary]} {
    unset CreateTestCaseSummariesummary
  }

#  set ReportBuildName [dict get $TestDict BuildName] ; # now comes from FileName

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
  
  set PassedClass  ""
  set FailedClass  ""
  set SkippedClass ""
  if { ${BuildStatus} eq "PASSED" } {
    set StatusClass  "class=\"passed\"" 
    set PassedClass  "class=\"passed\""
  } elseif { ${BuildStatus} eq "FAILED" } {
    set StatusClass  "class=\"failed\""
    set FailedClass  "class=\"failed\""
  } else {
    set StatusClass  "class=\"skipped\"" 
    set SkippedClass "class=\"skipped\""
  }
  if {$ReportAnalyzeErrorCount} {
    set AnalyzeClass  "class=\"failed\""
  } else {
    set AnalyzeClass  ""
  }
  if {$ReportSimulateErrorCount} {
    set SimulateClass  "class=\"failed\""
  } else {
    set SimulateClass  ""
  }
  
  puts $ResultsFile "  <div class=\"summary-parent\">"
  puts $ResultsFile "    <div  class=\"summary-table\">"
  puts $ResultsFile "      <table  class=\"summary-table\">"
  puts $ResultsFile "        <thead>"
  puts $ResultsFile "          <tr class=\"column-header\"><th>Build</th>         <th>$ReportBuildName</th></tr>"
  puts $ResultsFile "        </thead>"
  puts $ResultsFile "        <tbody>"
  puts $ResultsFile "          <tr ${StatusClass}><td>Status</td>   <td>$BuildStatus</td></tr>"
  puts $ResultsFile "          <tr ${PassedClass}><td>PASSED</td>   <td>$TestCasesPassed</td></tr>"
  puts $ResultsFile "          <tr ${FailedClass}><td>FAILED</td>   <td>$TestCasesFailed</td></tr>"
  puts $ResultsFile "          <tr ${SkippedClass}><td>SKIPPED</td> <td>$TestCasesSkipped</td></tr>"
  puts $ResultsFile "          <tr ${AnalyzeClass}><td>Analyze Failures</td>   <td>$ReportAnalyzeErrorCount</td></tr>"
  puts $ResultsFile "          <tr ${SimulateClass}><td>Simulate Failures</td> <td>$ReportSimulateErrorCount</td></tr>"

  # Print BuildInfo
  set BuildInfo $RunInfo
  if {[dict exists $RunInfo StartTime]} {
    set ReportStartTime [dict get $RunInfo StartTime]
    puts $ResultsFile "          <tr><td>Start Time</td> <td>[IsoToOsvvmTime $ReportStartTime]</td></tr>"
  } 
  if {[dict exists $RunInfo FinishTime]} {
    set ReportFinishTime [dict get $RunInfo FinishTime]
    puts $ResultsFile "          <tr><td>Finish Time</td> <td>[IsoToOsvvmTime $ReportFinishTime]</td></tr>"
  } 

  if {[dict exists $RunInfo Elapsed]} {
    set ElapsedTimeSeconds [dict get $RunInfo Elapsed]
  } else {
    set ElapsedTimeSeconds 0.0
  }
  set ElapsedTimeSecondsInt [expr {round($ElapsedTimeSeconds)}]
  set ElapsedTimeHms     [format %d:%02d:%02d [expr ($ElapsedTimeSecondsInt/(60*60))] [expr (($ElapsedTimeSecondsInt/60)%60)] [expr (${ElapsedTimeSecondsInt}%60)]]
  puts $ResultsFile "          <tr><td>Elapsed Time (h:m:s)</td>                <td>$ElapsedTimeHms</td></tr>"

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
  puts $ResultsFile "          <tr><td>Simulator (Version)</td> <td>${ReportSimulator} ($ReportSimulatorVersion)</td></tr>"

  if {[dict exists $RunInfo OsvvmVersion]} {
    puts $ResultsFile "          <tr><td>OSVVM Version</td> <td>[dict get $RunInfo OsvvmVersion]</td></tr>"
  } 

  if {$::osvvm::Report2SimulationLogFile ne ""} {
    puts $ResultsFile "          <tr><td>Simulation Transcript</td><td><a href=\"${::osvvm::Report2SimulationLogFile}\">${ReportBuildName}.log</a></td></tr>"
  }
  if {$::osvvm::Report2SimulationHtmlLogFile ne ""} {
    puts $ResultsFile "          <tr><td>HTML Simulation Transcript</td><td><a href=\"${::osvvm::Report2SimulationHtmlLogFile}\">${ReportBuildName}_log.html</a></td></tr>"
  }

  if {$::osvvm::Report2RequirementsSubdirectory ne ""} {
    set RequirementsRelativeHtml [file join $::osvvm::Report2RequirementsSubdirectory ${ReportBuildName}_req.html]
    puts $ResultsFile "          <tr><td>Requirements Summary</td><td><a href=\"${RequirementsRelativeHtml}\">[file tail $RequirementsRelativeHtml]</a></td></tr>"
  }

  if {$::osvvm::Report2CoverageSubdirectory ne ""} {
    puts $ResultsFile "          <tr><td>Code Coverage</td><td><a href=\"${::osvvm::Report2CoverageSubdirectory}\">Code Coverage Results</a></td></tr>"
  }

  puts $ResultsFile "        </tbody>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "    </div>"
  
  LinkLogoFile $ResultsFile

  puts $ResultsFile "  </div>"
  
}

# -------------------------------------------------
# CreateTestSuiteSummary
#
proc CreateTestSuiteSummary  {} {
  variable HaveTestSuites
  variable CreateTestCaseSummariesummary
  variable ResultsFile
  variable ReportBuildName

  if { $HaveTestSuites } {
    puts $ResultsFile "  <div class=\"testsuite\">"
    puts $ResultsFile "    <details open=\"open\" class=\"testsuite-details\"><summary>Test Suite Summary</summary>"
    puts $ResultsFile "      <table class=\"testsuite-summary-table\">"
    puts $ResultsFile "        <thead>"
    puts $ResultsFile "          <tr><th rowspan=\"2\">TestSuites</th>"
    puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
    puts $ResultsFile "              <th colspan=\"3\">Test Cases</th>"
    puts $ResultsFile "              <th rowspan=\"2\">Requirements<br>passed / goal</th>"
    puts $ResultsFile "              <th rowspan=\"2\">Disabled<br>Alerts</th>"
    puts $ResultsFile "              <th rowspan=\"2\">Elapsed<br>Time</th>"
    puts $ResultsFile "          </tr>"
    puts $ResultsFile "          <tr>"
    puts $ResultsFile "              <th>PASSED </th>"
    puts $ResultsFile "              <th>FAILED </th>"
    puts $ResultsFile "              <th>SKIPPED</th>"
    puts $ResultsFile "          </tr>"
    puts $ResultsFile "        </thead>"
    puts $ResultsFile "        <tbody>"

    foreach TestSuite $CreateTestCaseSummariesummary {
      set SuiteName [dict get $TestSuite Name]
      set SuiteStatus  [dict get $TestSuite Status]

      set PassedClass  "" 
      set FailedClass  "" 
      if { ${SuiteStatus} eq "PASSED" } {
        set StatusClass  "class=\"passed\"" 
        set PassedClass  "class=\"passed\"" 
      } elseif { ${SuiteStatus} eq "FAILED" } {
        set StatusClass  "class=\"failed\"" 
        set FailedClass  "class=\"failed\"" 
      } else {
        set StatusClass  "class=\"skipped\"" 
      }

      puts $ResultsFile "          <tr>"
      puts $ResultsFile "            <td><a href=\"#${SuiteName}\">${SuiteName}</a></td>"
      puts $ResultsFile "            <td ${StatusClass}>$SuiteStatus</td>"
      puts $ResultsFile "            <td ${PassedClass}>[dict get $TestSuite PASSED] </td>"
      puts $ResultsFile "            <td ${FailedClass}>[dict get $TestSuite FAILED] </td>"
      puts $ResultsFile "            <td>[dict get $TestSuite SKIPPED]</td>"
      set RequirementRelativeHtml [file join $::osvvm::Report2RequirementsSubdirectory $ReportBuildName ${SuiteName}_req.html]
      set RequirementsHtml        [file join $::osvvm::Report2BaseDirectory $RequirementRelativeHtml]
      set ReqGoal [dict get $TestSuite ReqGoal]
      set ReqPassed [dict get $TestSuite ReqPassed]
      if {[file exists $RequirementsHtml]} {
        puts $ResultsFile "          <td><a href=\"${RequirementRelativeHtml}\">$ReqPassed / $ReqGoal</a></td>"
      } else {
        if {($ReqGoal > 0) || ($ReqPassed > 0)} {
          puts $ResultsFile "          <td>$ReqPassed / $ReqGoal</td>"
        } else {
          puts $ResultsFile "          <td>⸻</td>"
        }
      }
      puts $ResultsFile "          <td>[dict get $TestSuite DisabledAlerts]</td>"
      puts $ResultsFile "          <td>[dict get $TestSuite ElapsedTime]</td>"
      puts $ResultsFile "        </tr>"
    }
    puts $ResultsFile "        </tbody>"
    puts $ResultsFile "      </table>"
    puts $ResultsFile "    </details>"
    puts $ResultsFile "  </div>"
  }
}

# -------------------------------------------------
# CreateTestCaseSummaries
#
proc CreateTestCaseSummaries {TestDict} {
  variable ResultsFile

  if { [dict exists $TestDict TestSuites] } {
    foreach TestSuite [dict get $TestDict TestSuites] {
      set SuiteName [dict get $TestSuite Name]
      puts $ResultsFile "  <div class=\"testcase\">"
      puts $ResultsFile "    <details open><summary id=\"$SuiteName\">$SuiteName Test Case Summary</summary>"
      puts $ResultsFile "      <table class=\"testcase-summary-table\">"
      puts $ResultsFile "        <thead>"
      puts $ResultsFile "          <tr><th rowspan=\"2\">Test Case</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
      puts $ResultsFile "              <th colspan=\"3\">Checks</th>"
      puts $ResultsFile "              <th colspan=\"2\">Requirements</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Functional<br>Coverage</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Disabled<br>Alerts</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Elapsed<br>Time</th>"
      puts $ResultsFile "          </tr>"
      puts $ResultsFile "          <tr>"
      puts $ResultsFile "              <th>Total</th>"
      puts $ResultsFile "              <th>Passed</th>"
      puts $ResultsFile "              <th>Failed</th>"
      puts $ResultsFile "              <th>Goal</th>"
      puts $ResultsFile "              <th>Passed</th>"
      puts $ResultsFile "          </tr>"
      puts $ResultsFile "        </thead>"
      puts $ResultsFile "        <tbody>"

      set ReportsDirectory [file join $::osvvm::Report2ReportsSubdirectory $SuiteName]

      foreach TestCase [dict get $TestSuite TestCases] {
        set TestName     [dict get $TestCase TestCaseName]
        if { [dict exists $TestCase Status] } { 
          set TestStatus    [dict get $TestCase Status]
          set TestResults [dict get $TestCase Results]
          if { $TestStatus eq "SKIPPED" } {
            set TestReport  "NONE"
            set Reason      [dict get $TestResults Reason]
          } else {
            set TestReport  "REPORT"
            set VhdlName    [dict get $TestCase Name]
          }
        } elseif { ![dict exists $TestCase FunctionalCoverage] } { 
          set TestReport "NONE"
          set TestStatus "FAILED"
          set Reason     "Simulate Did Not Run"
        } else { 
          set TestReport "NONE"
          set TestStatus "FAILED"
          set Reason     "No VHDL Results.  Test did not call EndOfTestReports"
        }
        
        set PassedClass  "" 
        set FailedClass  "" 
        if { ${TestReport} eq "REPORT"} {
          if { ${TestName} ne ${VhdlName} } {
            set TestStatus   "NAME_MISMATCH"
            set StatusClass  "class=\"warning\"" 
            set PassedClass  "class=\"warning\"" 
            set FailedClass  "class=\"warning\"" 
          } elseif { ${TestStatus} eq "PASSED" } {
            set StatusClass  "class=\"passed\"" 
            set PassedClass  "class=\"passed\"" 
          } else {
            set StatusClass  "class=\"failed\"" 
            set FailedClass  "class=\"failed\"" 
          }
        } else {
          if { ${TestStatus} eq "SKIPPED" } {
            set StatusClass  "class=\"skipped\""
            set PassedClass  "class=\"skipped\""
            set FailedClass  "class=\"skipped\""
          } else {
            set StatusClass  "class=\"failed\"" 
            set FailedClass  "class=\"failed\"" 
          }
        }
        if { [dict exists $TestCase TestCaseFileName] } { 
          set TestFileName [dict get $TestCase TestCaseFileName]
        } else {
          set TestFileName $TestName
        }
        set TestCaseHtmlFile [file join ${ReportsDirectory} ${TestFileName}.html]
        set TestCaseName $TestName
        if { [dict exists $TestCase TestCaseGenerics] } { 
          set TestCaseGenerics [dict get $TestCase TestCaseGenerics]
          if {${TestCaseGenerics} ne ""} {
            set i 0
            set ListLen [llength ${TestCaseGenerics}]
            append TestCaseName " (" 
            foreach GenericName $TestCaseGenerics {
              incr i
              if {$i != $ListLen} {
                append TestCaseName [lindex $GenericName 1] " ,"
              } else {
                append TestCaseName [lindex $GenericName 1] ")"
              }
            }
          }
        }
        puts $ResultsFile "          <tr>"
        puts $ResultsFile "            <td><a href=\"${TestCaseHtmlFile}\">${TestCaseName}</a></td>"
        puts $ResultsFile "            <td ${StatusClass}>$TestStatus</td>"
        if { $TestReport eq "REPORT" } {
          puts $ResultsFile "            <td ${PassedClass}>[dict get $TestResults AffirmCount]</td>"
          puts $ResultsFile "            <td ${PassedClass}>[dict get $TestResults PassedCount]</td>"
          puts $ResultsFile "            <td ${FailedClass}>[dict get $TestResults TotalErrors]</td>"
          set RequirementsGoal [dict get $TestResults RequirementsGoal]
          set RequirementsPassed [dict get $TestResults RequirementsPassed]
          if {($RequirementsGoal > 0) || ($RequirementsPassed > 0)} {
            puts $ResultsFile "            <td>$RequirementsGoal</td>"
            puts $ResultsFile "            <td>$RequirementsPassed</td>"
          } else {
            puts $ResultsFile "            <td>⸻</td>"
            puts $ResultsFile "            <td>⸻</td>"
          }
          if { [dict exists $TestCase FunctionalCoverage] } { 
            set FunctionalCov [dict get $TestCase FunctionalCoverage]
          } else {
            set FunctionalCov ""
          }
          if { ${FunctionalCov} ne "" } {
            puts $ResultsFile "            <td><a href=\"${TestCaseHtmlFile}#FunctionalCoverage\">${FunctionalCov}</a></td>"
          } else {
            puts $ResultsFile "            <td>⸻</td>"
          }
          puts $ResultsFile "            <td>[SumAlertCount [dict get $TestResults DisabledAlertCount]]</td>"
          if {[dict exists $TestCase ElapsedTime]} {
            set TestCaseElapsedTime [dict get $TestCase ElapsedTime]
          } else {
            set TestCaseElapsedTime missing
          }
          puts $ResultsFile "            <td>$TestCaseElapsedTime</td>"
        } else {
          puts $ResultsFile "            <td style=\"text-align: left\" colspan=\"8\">$Reason</td>"
        }
        puts $ResultsFile "          </tr>"
      }
      puts $ResultsFile "        </tbody>"
      puts $ResultsFile "      </table>"
      puts $ResultsFile "    </details>"
      puts $ResultsFile "  </div>"
    }
  }
}

# -------------------------------------------------
# SumAlertCount
#
proc SumAlertCount {AlertCountDict} {
  return [expr [dict get $AlertCountDict Failure] + [dict get $AlertCountDict Error] + [dict get $AlertCountDict Warning]]
}

# -------------------------------------------------
# IsoToOsvvmTime
#
proc IsoToOsvvmTime {IsoTime} {
  set TimeInSec [clock scan $IsoTime -format {%Y-%m-%dT%H:%M:%S%z} ]
  return [clock format $TimeInSec -format {%Y-%m-%d - %H:%M:%S (%Z)}]
}




