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
#    06/2025   2025.06    Link to top level index
#    04/2025   2025.04    Print VHDL Test Case
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
#  Copyright (c) 2021 - 2025 by SynthWorks Design Inc.
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
package require fileutil

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
  
  set IndexPath [file normalize [file join $::osvvm::CurrentSimulationDirectory $::osvvm::OutputBaseDirectory index.html]]
  set RelativeIndexPath  "[::fileutil::relative [file normalize [file join ${::osvvm::OutputBaseDirectory} $ReportBuildName]] $IndexPath]"
  puts $ResultsFile "          <tr><td>Build Index</td><td><a href=\"$RelativeIndexPath\">index.html</a></td></tr>"

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
    # Show Brief column only when at least one suite explicitly sets Brief.
    set ShowSuiteBriefCol 0
    foreach TsForBrief $TestSuiteSummaryArrayOfDictionaries {
      if { [dict exists $TsForBrief Brief] && [string trim [dict get $TsForBrief Brief]] ne "" } {
        set ShowSuiteBriefCol 1
        break
      }
    }

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
    if {$ShowSuiteBriefCol} {
      puts $ResultsFile "              <th rowspan=\"2\" style=\"width: 50%; text-align: center;\">Brief</th>"
    }
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
      set SuiteDisplayName $SuiteName
      if {[dict exists $TestSuite Title]} {
        set CandidateTitle [string trim [dict get $TestSuite Title]]
        if {$CandidateTitle ne ""} {
          set SuiteDisplayName $CandidateTitle
        }
      }
      set SuiteStatus  [dict get $TestSuite Status]
      if {$ShowSuiteBriefCol && [dict exists $TestSuite Brief]} {
        set SuiteBrief [dict get $TestSuite Brief]
      } else {
        set SuiteBrief ""
      }

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
      puts $ResultsFile "            <td><a href=\"#${SuiteName}\">[EscapeHtml ${SuiteDisplayName}]</a></td>"
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
      if {$ShowSuiteBriefCol} {
        puts $ResultsFile "          <td style=\"text-align: left;\">"
        if {${SuiteBrief} ne ""} {
          puts $ResultsFile "            [EscapeHtml $SuiteBrief]"
        }
        puts $ResultsFile "          </td>"
      }
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
      set SuiteDisplayName $SuiteName
      if {[dict exists $TestSuite Title]} {
        set CandidateTitle [string trim [dict get $TestSuite Title]]
        if {$CandidateTitle ne ""} {
          set SuiteDisplayName $CandidateTitle
        }
      }

      # Show Brief column only when at least one testcase explicitly sets Brief.
      set ShowTestBriefCol 0
      foreach TcForBrief [dict get $TestSuite TestCases] {
        if { [dict exists $TcForBrief Brief] && [string trim [dict get $TcForBrief Brief]] ne "" } {
          set ShowTestBriefCol 1
          break
        }
      }

      # Configuration hooks (set via OSVVM-Scripts/OsvvmScriptsCore.tcl APIs)
      set ConfigShowGenerics 1
      if {[info exists ::osvvm::TestCaseSummaryShowGenerics]} {
        set ConfigShowGenerics $::osvvm::TestCaseSummaryShowGenerics
      }
      set ConfigGenericWhitelist {}
      if {[info exists ::osvvm::TestCaseSummaryGenericNames]} {
        set ConfigGenericWhitelist $::osvvm::TestCaseSummaryGenericNames
      }

      # Default: cap the number of generic columns to keep tables readable.
      set ConfigMaxGenericsColumns 0
      if {[info exists ::osvvm::TestCaseSummaryMaxGenericsColumns]} {
        set ConfigMaxGenericsColumns $::osvvm::TestCaseSummaryMaxGenericsColumns
      }

      # Default: show tags in the Test Case Summary table
      set ConfigShowTags 1
      if {[info exists ::osvvm::TestCaseSummaryShowTags]} {
        set ConfigShowTags $::osvvm::TestCaseSummaryShowTags
      }
      set ConfigTagWhitelist {}
      if {[info exists ::osvvm::TestCaseSummaryTagNames]} {
        set ConfigTagWhitelist $::osvvm::TestCaseSummaryTagNames
      }

      # Default: cap the number of tag columns to keep tables readable.
      set ConfigMaxTagsColumns 0
      if {[info exists ::osvvm::TestCaseSummaryMaxTagsColumns]} {
        set ConfigMaxTagsColumns $::osvvm::TestCaseSummaryMaxTagsColumns
      }

      # Collect a stable list of generic names used by any test case in this suite.
      # These become the subcolumns under the "Generics" column group.
      set SuiteGenericNamesAll {}
      foreach TcForGenerics [dict get $TestSuite TestCases] {
        if { [dict exists $TcForGenerics Generics] } {
          set GenDict [dict get $TcForGenerics Generics]
          if {![catch {dict size $GenDict}]} {
            foreach GenName [dict keys $GenDict] {
              if {[lsearch -exact $SuiteGenericNamesAll $GenName] < 0} {
                lappend SuiteGenericNamesAll $GenName
              }
            }
          }
        }
      }

      # Apply generics configuration
      if {!$ConfigShowGenerics} {
        set SuiteGenericNames {}
      } elseif {[llength $ConfigGenericWhitelist] == 0} {
        set SuiteGenericNames $SuiteGenericNamesAll
      } else {
        set SuiteGenericNames {}
        foreach GenName $ConfigGenericWhitelist {
          if {[lsearch -exact $SuiteGenericNamesAll $GenName] >= 0} {
            lappend SuiteGenericNames $GenName
          }
        }
      }
      set SuiteGenericCount [llength $SuiteGenericNames]
      set SuiteGenericCountAll [llength $SuiteGenericNamesAll]

      # Enforce max generics columns (0/negative => unlimited)
      if {$SuiteGenericCount > 0 && $ConfigMaxGenericsColumns > 0 && $SuiteGenericCount > $ConfigMaxGenericsColumns} {
        puts "Warning: Test Case Summary generics columns truncated from $SuiteGenericCount to $ConfigMaxGenericsColumns for suite $SuiteName"
        set SuiteGenericNames [lrange $SuiteGenericNames 0 [expr {$ConfigMaxGenericsColumns - 1}]]
        set SuiteGenericCount [llength $SuiteGenericNames]
      }

      # Collect tag names (stable order) and determine visibility across all testcases.
      # A tag column is included if the tag is visible in ANY testcase.
      set SuiteTagNamesAll {}
      set SuiteTagVisibleAny [dict create]
      if {$ConfigShowTags} {
        foreach TcForTags [dict get $TestSuite TestCases] {
          if { [dict exists $TcForTags Tags] } {
            set TagsDict [dict get $TcForTags Tags]
            if {![catch {dict size $TagsDict}]} {
              foreach TagName [dict keys $TagsDict] {
                # Maintain stable ordering based on first occurrence in the suite.
                if {[lsearch -exact $SuiteTagNamesAll $TagName] < 0} {
                  lappend SuiteTagNamesAll $TagName
                }

                # Per-tag visibility for this testcase (default visible).
                set IsVisible 1
                if {[dict exists $TcForTags TagSummaryVisibility]} {
                  set VisDict [dict get $TcForTags TagSummaryVisibility]
                  if {![catch {dict size $VisDict}]} {
                    if {[dict exists $VisDict $TagName]} {
                      set VisVal [dict get $VisDict $TagName]
                      if {$VisVal eq 0 || $VisVal eq "0" || [string equal -nocase $VisVal "false"]} {
                        set IsVisible 0
                      }
                    }
                  }
                }

                # Track if visible in any testcase.
                if {$IsVisible} {
                  dict set SuiteTagVisibleAny $TagName 1
                } elseif {![dict exists $SuiteTagVisibleAny $TagName]} {
                  dict set SuiteTagVisibleAny $TagName 0
                }
              }
            }
          }
        }
      }

      # Filter final set of tag columns: include only tags visible in ANY testcase.
      if {!$ConfigShowTags} {
        set SuiteTagNames {}
      } else {
        # Candidate tags by order (either auto-discovered or whitelist)
        if {[llength $ConfigTagWhitelist] == 0} {
          set CandidateTagNames $SuiteTagNamesAll
        } else {
          set CandidateTagNames $ConfigTagWhitelist
        }

        set SuiteTagNames {}
        foreach TagName $CandidateTagNames {
          # If a whitelist asks for a tag not present in the suite, skip it.
          if {[lsearch -exact $SuiteTagNamesAll $TagName] < 0} {
            continue
          }
          # Only include if visible in any testcase.
          if {[dict exists $SuiteTagVisibleAny $TagName] && [dict get $SuiteTagVisibleAny $TagName]} {
            lappend SuiteTagNames $TagName
          }
        }
      }
      set SuiteTagCount [llength $SuiteTagNames]

      # Enforce max tags columns (0/negative => unlimited)
      if {$SuiteTagCount > 0 && $ConfigMaxTagsColumns > 0 && $SuiteTagCount > $ConfigMaxTagsColumns} {
        puts "Warning: Test Case Summary tag columns truncated from $SuiteTagCount to $ConfigMaxTagsColumns for suite $SuiteName"
        set SuiteTagNames [lrange $SuiteTagNames 0 [expr {$ConfigMaxTagsColumns - 1}]]
        set SuiteTagCount [llength $SuiteTagNames]
      }

      puts $ResultsFile "  <div class=\"testcase\">"
      puts $ResultsFile "    <details open class=\"suite-testcase-summary\"><summary id=\"$SuiteName\" class=\"suite-testcase-summary-heading\"><span class=\"suite-name\">[EscapeHtml $SuiteDisplayName]</span><span class=\"suite-sep\"> — </span><span class=\"suite-suffix\">Test Case Summary</span></summary>"
      puts $ResultsFile "      <table class=\"testcase-summary-table\">"
      puts $ResultsFile "        <thead>"
      puts $ResultsFile "          <tr><th rowspan=\"2\">Test Case</th>"
      if { $SuiteGenericCount > 0 } {
        puts $ResultsFile "              <th colspan=\"$SuiteGenericCount\">Generics</th>"
      }
      if { $SuiteTagCount > 0 } {
        puts $ResultsFile "              <th colspan=\"$SuiteTagCount\">Tags</th>"
      }
      puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
      puts $ResultsFile "              <th colspan=\"3\">Checks</th>"
      puts $ResultsFile "              <th colspan=\"2\">Requirements</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Functional<br>Coverage</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Disabled<br>Alerts</th>"
      puts $ResultsFile "              <th rowspan=\"2\">Elapsed<br>Time</th>"
      if {$ShowTestBriefCol} {
        puts $ResultsFile "              <th rowspan=\"2\" style=\"width: 50%; text-align: center;\">Brief</th>"
      }
      puts $ResultsFile "          </tr>"
      puts $ResultsFile "          <tr>"
      if { $SuiteGenericCount > 0 } {
        foreach GenName $SuiteGenericNames {
          puts $ResultsFile "              <th style=\"text-align: center;\">$GenName</th>"
        }
      }
      if { $SuiteTagCount > 0 } {
        foreach TagName $SuiteTagNames {
          puts $ResultsFile "              <th style=\"text-align: center;\">$TagName</th>"
        }
      }
      puts $ResultsFile "              <th>Total</th>"
      puts $ResultsFile "              <th>Passed</th>"
      puts $ResultsFile "              <th>Failed</th>"
      puts $ResultsFile "              <th>Goal</th>"
      puts $ResultsFile "              <th>Passed</th>"
      puts $ResultsFile "          </tr>"
      puts $ResultsFile "        </thead>"
      puts $ResultsFile "        <tbody>"

      set TestSuiteReportsDirectory [file join $::osvvm::Report2ReportsSubdirectory $SuiteName]

      foreach TestCase [dict get $TestSuite TestCases] {
        set TestName     [dict get $TestCase TestCaseName]

        # Display title in the Name column when explicitly set.
        set DisplayName $TestName
        if {[dict exists $TestCase Title]} {
          set CandidateTitle [string trim [dict get $TestCase Title]]
          if {$CandidateTitle ne ""} {
            set DisplayName $CandidateTitle
          }
        }

        # Get test brief only if explicitly set
        if {$ShowTestBriefCol && [dict exists $TestCase Brief]} {
          set TestBrief [dict get $TestCase Brief]
        } else {
          set TestBrief ""
        }
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
        set TestCaseHtmlFile [file join ${TestSuiteReportsDirectory} ${TestFileName}.html]
        set TestCaseName $TestName
        set DisplayNameWithGenerics $DisplayName
        # Backward compatibility: if there are no generic columns, append generic values to the Test Case name.
        # Do this only when the suite truly has no generics (not when generics are hidden via config).
        if { ($SuiteGenericCountAll == 0) && [dict exists $TestCase Generics] } {
          set TestCaseGenerics [dict get $TestCase Generics]
          if {![catch {dict size $TestCaseGenerics}] && ([dict size $TestCaseGenerics] > 0)} {
            set GenericValueList [dict values $TestCaseGenerics]
            set i 0
            set ListLen [llength ${GenericValueList}]
            append TestCaseName " ("
            append DisplayNameWithGenerics " ("
            foreach GenericValue $GenericValueList {
              incr i
              if {$i != $ListLen} {
                append TestCaseName $GenericValue " ,"
                append DisplayNameWithGenerics $GenericValue " ,"
              } else {
                append TestCaseName $GenericValue ")"
                append DisplayNameWithGenerics $GenericValue ")"
              }
            }
          }
        }
        puts $ResultsFile "          <tr>"
        puts $ResultsFile "            <td><a href=\"${TestCaseHtmlFile}\">${DisplayNameWithGenerics}</a></td>"

        # Generics are the second column group (after Test Case name).
        if { $SuiteGenericCount > 0 } {
          if { [dict exists $TestCase Generics] } {
            set TestCaseGenerics [dict get $TestCase Generics]
          } else {
            set TestCaseGenerics ""
          }
          set HasGenerics 0
          if {![catch {dict size $TestCaseGenerics}] && ([dict size $TestCaseGenerics] > 0)} {
            set HasGenerics 1
          }
          foreach GenName $SuiteGenericNames {
            if { $HasGenerics && [dict exists $TestCaseGenerics $GenName] } {
              set GenValue [dict get $TestCaseGenerics $GenName]
            } else {
              set GenValue "⸻"
            }
            set GenDisplayValue [FormatGenericValueForHtml $GenName $GenValue $TestFileName]
            puts $ResultsFile "            <td style=\"text-align: right;\">$GenDisplayValue</td>"
          }
        }

        # Optional Tags column group (after Generics, before Status).
        if { $SuiteTagCount > 0 } {
          if { [dict exists $TestCase Tags] } {
            set TestCaseTags [dict get $TestCase Tags]
          } else {
            set TestCaseTags ""
          }
          set HasTags 0
          if {![catch {dict size $TestCaseTags}] && ([dict size $TestCaseTags] > 0)} {
            set HasTags 1
          }
          foreach TagName $SuiteTagNames {
            # TagSummaryVisibility is used only to decide whether a tag column exists.
            # If the column exists (visible in any testcase), then show the tag
            # value for every testcase that has it.
            if { $HasTags && [dict exists $TestCaseTags $TagName] } {
              set TagValue [dict get $TestCaseTags $TagName]
              set TagDisplay [EscapeHtml [FormatScalarForHtml $TagValue]]
            } else {
              set TagDisplay "⸻"
            }
            puts $ResultsFile "            <td style=\"text-align: right;\">$TagDisplay</td>"
          }
        }

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
          if {$ShowTestBriefCol} {
            puts $ResultsFile "            <td style=\"text-align: left;\">"
            if {${TestBrief} ne ""} {
              puts $ResultsFile "              [EscapeHtml $TestBrief]"
            }
            puts $ResultsFile "            </td>"
          }
        } else {
          # Remaining columns after Test Case + (optional Generics) + Status
          set RemainingColumns [expr {8 + ($ShowTestBriefCol ? 1 : 0)}]
          puts $ResultsFile "            <td style=\"text-align: left\" colspan=\"$RemainingColumns\"> &emsp; $Reason</td>"
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




