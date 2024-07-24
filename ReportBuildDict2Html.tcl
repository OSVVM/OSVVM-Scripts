#  File Name:         ReportBuildDict2Html.tcl
#  Purpose:           Convert OSVVM YAML build reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM Build Dictionary into HTML Build Report
#    Visible externally:  ReportBuildDict2Html
#    Must call ReportBuildYaml2Dict first.
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
#    07/2024   2024.07    Handling for GenericDict and naming updates.
#    05/2024   2024.05    Refactored. Must call ReportBuildYaml2Dict first.
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
# ReportBuildDict2Html
#
proc ReportBuildDict2Html {} {
  variable ResultsFile
  variable ReportFileRoot

  # Open results file  
  set ResultsFile [open ${ReportFileRoot}.html w]
  
  # Convert YAML file to HTML & catch results
  set ErrorCode [catch {LocalReportBuildDict2Html} errmsg]
  
  # Close Results file - done here s.t. it is closed even if it fails
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_ReportBuildDict2Html ${ReportFileRoot}.html $errmsg
  }
}

# -------------------------------------------------
# LocalReportBuildDict2Html
#
proc LocalReportBuildDict2Html {} {
  variable ResultsFile
  variable ReportBuildName
  variable BuildDict
  
  CreateOsvvmReportHeader $ResultsFile "$ReportBuildName Build Report"
  
  CreateHtmlSummary $BuildDict
  
  CreateTestSuiteSummary 
  
  CreateTestCaseSummaries $BuildDict
  
  CreateOsvvmReportFooter $ResultsFile
}


# -------------------------------------------------
# CreateHtmlSummary
#
proc CreateHtmlSummary {TestDict} {
  variable ResultsFile
  variable ReportBuildName
  
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus 
  variable ReportStartTime
  variable ReportFinishTime
  variable ElapsedTimeSeconds
  variable ElapsedTimeSecondsInt
  variable ElapsedTimeHms
  variable ReportSimulator
  variable ReportSimulatorVersion
  variable OsvvmVersion
  variable RequirementsRelativeHtml

  variable TestCasesPassed 
  variable TestCasesFailed 
  variable TestCasesSkipped 
  variable TestCasesRun 
  
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
  if {$ReportStartTime ne ""} {
    puts $ResultsFile "          <tr><td>Start Time</td> <td>$ReportStartTime</td></tr>"
  } 
  if {$ReportFinishTime ne ""} {
    puts $ResultsFile "          <tr><td>Finish Time</td> <td>$ReportFinishTime</td></tr>"
  } 

  puts $ResultsFile "          <tr><td>Elapsed Time (h:m:s)</td>                <td>$ElapsedTimeHms</td></tr>"
  puts $ResultsFile "          <tr><td>Simulator (Version)</td> <td>${ReportSimulator} ($ReportSimulatorVersion)</td></tr>"

  if {$OsvvmVersion ne ""} {
    puts $ResultsFile "          <tr><td>OSVVM Version</td> <td>$OsvvmVersion</td></tr>"
  } 

  if {$::osvvm::Report2SimulationLogFile ne ""} {
    puts $ResultsFile "          <tr><td>Simulation Transcript</td><td><a href=\"${::osvvm::Report2SimulationLogFile}\">${ReportBuildName}.log</a></td></tr>"
  }
  if {$::osvvm::Report2SimulationHtmlLogFile ne ""} {
    puts $ResultsFile "          <tr><td>HTML Simulation Transcript</td><td><a href=\"${::osvvm::Report2SimulationHtmlLogFile}\">${ReportBuildName}_log.html</a></td></tr>"
  }

  if {$RequirementsRelativeHtml ne ""} {
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
  variable TestSuiteSummaryArrayOfDictionaries
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

    foreach TestSuite $TestSuiteSummaryArrayOfDictionaries {
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
        if { [dict exists $TestCase Generics] } { 
          set TestCaseGenerics [dict get $TestCase Generics]
          if {${TestCaseGenerics} ne ""} {
            set GenericValueList [dict values $TestCaseGenerics] 
            set i 0
            set ListLen [llength ${GenericValueList}]
            append TestCaseName " (" 
            foreach GenericValue $GenericValueList {
              incr i
              if {$i != $ListLen} {
                append TestCaseName $GenericValue " ,"
              } else {
                append TestCaseName $GenericValue ")"
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
          puts $ResultsFile "            <td style=\"text-align: left\" colspan=\"8\"> &emsp; $Reason</td>"
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
# Report2Html - provided for backward compatibility
#
proc Report2Html {BuildYamlFile} {
  ReportBuildYaml2Dict ${BuildYamlFile}
  ReportBuildDict2Html
}




