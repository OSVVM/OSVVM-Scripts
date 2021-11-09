#  File Name:         Report2Html.tcl
#  Purpose:           Convert OSVVM coverage in YAML to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Tcl procedures to configure and adapt the OSVVM simulator
#    scripting methodology for a particular project.
#    As part of its tasks, it runs OSVVM scripts that define
#    procedures use in the OSVVM scripting methodology.
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
#    10/2021   Alpha      Report2Html: Convert OSVVM coverage results to HTML
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021 by SynthWorks Design Inc.
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

proc Report2Html {ReportFile} {
  variable ResultsFile

  set FileName  [file rootname ${ReportFile}].html
  file copy -force ${::osvvm::SCRIPT_DIR}/header_report.html ${FileName}
  set ResultsFile [open ${FileName} a]

  set Report2HtmlDict [::yaml::yaml2dict -file ${ReportFile}]
  set VersionNum  [dict get $Report2HtmlDict Version]

  ReportElaborateStatus $Report2HtmlDict
  
  ReportTestSuites $Report2HtmlDict

  puts $ResultsFile "<br><br>"
  puts $ResultsFile "</body>"
  puts $ResultsFile "</html>"
  close $ResultsFile
}

proc ReportElaborateStatus {TestDict} {
  variable ResultsFile

  if {[info exists ReportTestSuiteSummary]} {
    unset ReportTestSuiteSummary
  }

  set BuildStatus "PASSED"
  set TestCasesPassed 0
  set TestCasesFailed 0
  set TestCasesSkipped 0
  set TestCasesRun 0
  
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
          } else {
            set TestReqGoal   0
            set TestReqPassed 0
          }
          set VhdlName [dict get $TestCase Name]
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
  #    lappend ReportTestSuiteSummary [dict create Name $SuiteName Status $SuiteStatus Passed $SuitePassed Failed $SuiteFailed Skipped $SuiteSkipped ReqPassed $SuiteReqPassed ReqGoal $SuiteReqGoal]
      lappend ReportTestSuiteSummary $SuiteDict

    }
  }
#  puts $ReportTestSuiteSummary
#  puts "Build Status: $BuildStatus"
#  puts  "TestCasesPassed:  $TestCasesPassed"
#  puts  "TestCasesFailed:  $TestCasesFailed"
#  puts  "TestCasesSkipped: $TestCasesSkipped"
#  puts  "TestCasesRun: $TestCasesRun"

  set BuildInfo [dict get $TestDict Build]
  set RunInfo   [dict get $TestDict Run] 
  set BuildName [dict get $BuildInfo Name]
  puts $ResultsFile "<title>$BuildName Build Report</title>"
  puts $ResultsFile "</head>"
  puts $ResultsFile "<body>"
  set PassedColor  "#000000"
  set FailedColor  "#000000"
  set SkippedColor "#000000"
  if { ${BuildStatus} eq "PASSED" } {
    set StatusColor  "#00C000" 
    set PassedColor  "#00C000"
  } elseif { ${BuildStatus} eq "FAILED" } {
    set StatusColor  "#FF0000" 
    set FailedColor  "#FF0000"
  } else {
    set StatusColor  "#D09000" 
    set SkippedColor "#D09000"
  }
  puts $ResultsFile "<br>"
  puts $ResultsFile "<h1>OSVVM Build Report for $BuildName</h1>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr style=\"height:40px\"><th>Build</th><th>$BuildName</th></tr>"
  puts $ResultsFile "  <tr style=color:${StatusColor}><td>Status</td>   <td>$BuildStatus</td></tr>"
  puts $ResultsFile "  <tr style=color:${PassedColor}><td>PASSED</td>  <td>$TestCasesPassed</td></tr>"
  puts $ResultsFile "  <tr style=color:${FailedColor}><td>FAILED</td>  <td>$TestCasesFailed</td></tr>"
  puts $ResultsFile "  <tr style=color:${SkippedColor}><td>SKIPPED</td> <td>$TestCasesSkipped</td></tr>"
  puts $ResultsFile "  <tr><td>Elapsed Time</td>                      <td>[dict get $RunInfo Elapsed]</td></tr>"
  puts $ResultsFile "  <tr><td>Date</td>                              <td>[dict get $BuildInfo Date]</td></tr>"
  puts $ResultsFile "  <tr><td>Simulator</td>                         <td>[dict get $BuildInfo Simulator]</td></tr>"
  puts $ResultsFile "  <tr><td>Version</td>                           <td>[dict get $BuildInfo Version]</td></tr>"
  puts $ResultsFile "  <tr><td>OSVVM YAML Version</td>                <td>[dict get $TestDict Version]</td></tr>"
  puts $ResultsFile "</table>"
  puts $ResultsFile "<DIV STYLE=\"font-size:25px\"><BR></DIV>"
  
  if { $HaveTestSuites } {
    puts $ResultsFile "<details open><summary><strong>$BuildName Test Suite Summary</strong></summary>"
    puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
    puts $ResultsFile "<table>"
    puts $ResultsFile "  <tr><th rowspan=\"2\">TestSuites</th>"
    puts $ResultsFile "      <th rowspan=\"2\">Status</th>"
    puts $ResultsFile "      <th rowspan=\"2\">PASSED </th>"
    puts $ResultsFile "      <th rowspan=\"2\">FAILED </th>"
    puts $ResultsFile "      <th rowspan=\"2\">SKIPPED</th>"
    puts $ResultsFile "      <th rowspan=\"2\">Requirements<br>passed / goal</th>"
    puts $ResultsFile "      <th rowspan=\"2\">Disabled<br>Alerts</th>"
    puts $ResultsFile "      <th rowspan=\"2\">Elapsed<br>Time</th>"
    puts $ResultsFile "  </tr>"
    puts $ResultsFile "  <tr></tr>"

    foreach TestSuite $ReportTestSuiteSummary {
      set SuiteName [dict get $TestSuite Name]
      set SuiteStatus  [dict get $TestSuite Status]
      if { ${SuiteStatus} eq "PASSED" } {
        set StatusColor  "#00C000" 
      } elseif { ${SuiteStatus} eq "FAILED" } {
        set StatusColor  "#FF0000" 
      } else {
        set StatusColor  "#D09000" 
      }
      puts $ResultsFile "  <tr style=color:${StatusColor}>"
      puts $ResultsFile "      <td><a href=\"#${SuiteName}\">${SuiteName}</a></td>"
      puts $ResultsFile "      <td>$SuiteStatus</td>"
      puts $ResultsFile "      <td>[dict get $TestSuite PASSED] </td>"
      puts $ResultsFile "      <td>[dict get $TestSuite FAILED] </td>"
      puts $ResultsFile "      <td>[dict get $TestSuite SKIPPED]</td>"
      puts $ResultsFile "      <td>[dict get $TestSuite ReqPassed] / [dict get $TestSuite ReqGoal]</td>"
      puts $ResultsFile "      <td>[dict get $TestSuite DisabledAlerts]</td>"
  # Add Elapsed Time in Simulation Scripts
      puts $ResultsFile "      <td>0 </td>"
      puts $ResultsFile "  </tr>"
    }
    puts $ResultsFile "</table>"
    puts $ResultsFile "</details>"
  }
}

proc SumAlertCount {AlertCountDict} {
  return [expr [dict get $AlertCountDict Failure] + [dict get $AlertCountDict Error] + [dict get $AlertCountDict Warning]]
}

proc ReportTestSuites {TestDict} {
  variable ResultsFile

  if { [dict exists $TestDict TestSuites] } {
    foreach TestSuite [dict get $TestDict TestSuites] {
      set SuiteName [dict get $TestSuite Name]
      puts $ResultsFile "<DIV STYLE=\"font-size:25px\"><BR></DIV>"
      puts $ResultsFile "<details open><summary id=\"$SuiteName\"><strong>$SuiteName Test Case Summary</strong></summary>"
      puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
      puts $ResultsFile "<table>"
      puts $ResultsFile "  <tr><th rowspan=\"2\">Test Case</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Status</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Checks<br>passed / checked</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Errors</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Requirements<br>passed / goal</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Functional<br>Coverage</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Disabled<br>Alerts</th>"
      puts $ResultsFile "      <th rowspan=\"2\">Elapsed<br>Time</th>"
      puts $ResultsFile "  </tr>"
      puts $ResultsFile "  <tr></tr>"

      foreach TestCase [dict get $TestSuite TestCases] {
        set TestName    [dict get $TestCase TestCaseName]
        
        if { [dict exists $TestCase Results] } { 
          set TestResults [dict get $TestCase Results]
          set TestStatus  [dict get $TestCase Status]
          set VhdlName    [dict get $TestCase Name]
          if { $TestStatus ne "SKIPPED" } {
            set DisabledAlertCount [dict get $TestResults DisabledAlertCount]
          } else {
            set DisabledAlertCount [dict create Failure 0 Error 0 Warning 0]
          }
        } else {
          set TestResults [dict create RequirementsGoal 0 RequirementsPassed 0 PassedCount 0 AffirmCount 0 TotalErrors 1 ]
          set TestStatus  "FAILED"
          set VhdlName    $TestName
          set DisabledAlertCount [dict create Failure 0 Error 0 Warning 0]
        }
        
        if { ${TestName} ne ${VhdlName} } {
          set TestStatus "NAME_MISMATCH"
          set TestColor "#D09000" 
        } elseif { ${TestStatus} eq "PASSED" } {
          set TestColor "#00C000" 
        } elseif { ${TestStatus} eq "SKIPPED" } {
          set TestColor "#D09000" 
        } else {
          set TestColor "#FF0000" 
        }
        puts $ResultsFile "  <tr style=color:${TestColor}>"
        puts $ResultsFile "      <td><a href=\"reports/${TestName}.html#AlertSummary\">${TestName}</a></td>"
        puts $ResultsFile "      <td>$TestStatus</td>"
        if { $TestStatus ne "SKIPPED" } {
          puts $ResultsFile "      <td>[dict get $TestResults PassedCount] /  [dict get $TestResults AffirmCount]</td>"
          puts $ResultsFile "      <td>[dict get $TestResults TotalErrors] </td>"
          puts $ResultsFile "      <td>[dict get $TestResults RequirementsPassed] /  [dict get $TestResults RequirementsGoal]</td>"
          set FunctionalCov [dict get $TestCase FunctionalCoverage]
          if { ${FunctionalCov} ne "" } {
            puts $ResultsFile "      <td><a href=\"reports/${TestName}.html#FunctionalCoverage\">${FunctionalCov}</a></td>"
          } else {
            puts $ResultsFile "      <td>-</td>"
          }
          puts $ResultsFile "      <td>[SumAlertCount ${DisabledAlertCount}]</td>"
          puts $ResultsFile "      <td>[dict get $TestCase ElapsedTime]</td>"
        } else {
          puts $ResultsFile "      <td colspan=\"5\">[dict get $TestResults Reason]</td>"
        }
        puts $ResultsFile "  </tr>"
      }
      
      puts $ResultsFile "</table>"
      puts $ResultsFile "<br>"
      puts $ResultsFile "</details>"
    }
  }
}



