#  File Name:         Simulate2Html.tcl
#  Purpose:           Convert OSVVM Alert and Coverage results to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM Alert, Coverage, and Scoreboard results to HTML
#    Visible externally:  Simulate2Html
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
#    07/2024   2024.07    Changed *List to *Dict for Scoreboard and Generic
#    05/2024   2024.05    Refactored.  Separating file copy from creating HTML.  New Call interface.
#    04/2024   2024.04    Updated report formatting
#    03/2024   2024.03    Updated handling of TranscriptFile to account for simulator still having it open (due to abnormal exit)
#    07/2023   2023.07    Updated OpenSimulationReportFile to search for user defined HTML headers
#    02/2023   2023.02    CreateDirectory if results/<TestSuiteName> does not exist
#    12/2022   2022.12    Refactored to minimize dependecies on other scripts.
#    05/2022   2022.05    Updated directory handling
#    03/2022   2022.03    Added Transcript File reporting.
#    02/2022   2022.02    Added Scoreboard Reports. Updated YAML file handling.
#    10/2021   Initial    Initial Revision
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
package require fileutil


#--------------------------------------------------------------
proc Simulate2Html {SettingsFileWithPath} {
  variable ResultsFile
  
  variable Report2AlertYamlFile              
#  variable Report2RequirementsYamlFile 
  variable Report2CovYamlFile          
  
    
  GetTestCaseSettings $SettingsFileWithPath 

  # Align local script variables with ::osvvm settings parsed from YAML
  # (avoids stale values between testcases)
  set Report2AlertYamlFile $::osvvm::Report2AlertYamlFile
  set Report2CovYamlFile   $::osvvm::Report2CovYamlFile
  
  set TestCaseFileName $::osvvm::Report2TestCaseFileName
  set TestCaseName     $::osvvm::Report2TestCaseName  
  set TestSuiteName    $::osvvm::Report2TestSuiteName 
  set BuildName        $::osvvm::Report2BuildName     
  set GenericDict      $::osvvm::Report2GenericDict   

  # Some older/alternate run.yml formats may not include TestCaseFileName.
  # When possible, derive it from TestCaseName + GenericNames (the file naming convention).
  if {$TestCaseFileName eq "" && [info exists ::osvvm::Report2GenericNames] && $::osvvm::Report2GenericNames ne ""} {
    set TestCaseFileName "${TestCaseName}${::osvvm::Report2GenericNames}"
  }

  # Initialize fields sourced from alerts/build YAML to empty
  set ::osvvm::Report2TestTitle ""
  set ::osvvm::Report2TestDescription ""
  set ::osvvm::Report2TestBrief ""
  set ::osvvm::Report2TestTags ""
  set ::osvvm::Report2TestTagSummaryVisibility ""
  set ::osvvm::Report2TestTagTypes ""
  set ::osvvm::Report2TestStatus ""
  if {![info exists ::osvvm::Report2TestCaseSimulationTime]} {
    set ::osvvm::Report2TestCaseSimulationTime ""
  }
  if {![info exists ::osvvm::Report2TestCaseElapsedTime]} {
    set ::osvvm::Report2TestCaseElapsedTime ""
  }

  # Try to get SimulationTime/ElapsedTime from the build YAML.
  # Different flows place this file in slightly different locations, so search a few common candidates.
  set BuildYamlCandidates {}
  lappend BuildYamlCandidates [file join $::osvvm::Report2BaseDirectory ${BuildName}.yml]
  lappend BuildYamlCandidates [file join $::osvvm::Report2BaseDirectory ${BuildName}.yaml]
  if {[info exists ::osvvm::Report2ReportsSubdirectory] && $::osvvm::Report2ReportsSubdirectory ne ""} {
    lappend BuildYamlCandidates [file join $::osvvm::Report2BaseDirectory $::osvvm::Report2ReportsSubdirectory ${BuildName}.yml]
    lappend BuildYamlCandidates [file join $::osvvm::Report2BaseDirectory $::osvvm::Report2ReportsSubdirectory ${BuildName}.yaml]
  }
  if {[info exists ::osvvm::Report2ReportsDirectory] && $::osvvm::Report2ReportsDirectory ne ""} {
    lappend BuildYamlCandidates [file join $::osvvm::Report2ReportsDirectory ${BuildName}.yml]
    lappend BuildYamlCandidates [file join $::osvvm::Report2ReportsDirectory ${BuildName}.yaml]
  }
  if {[info exists ::osvvm::Report2ReportsTestSuiteDirectory] && $::osvvm::Report2ReportsTestSuiteDirectory ne ""} {
    set SuiteReportsBase [file dirname $::osvvm::Report2ReportsTestSuiteDirectory]
    lappend BuildYamlCandidates [file join $SuiteReportsBase ${BuildName}.yml]
    lappend BuildYamlCandidates [file join $SuiteReportsBase ${BuildName}.yaml]
  }

  set BuildYamlFile ""
  foreach Candidate $BuildYamlCandidates {
    if {[file exists $Candidate]} {
      set BuildYamlFile $Candidate
      break
    }
  }

  if {$BuildYamlFile ne ""} {
    set BuildDict [::yaml::yaml2dict -file $BuildYamlFile]
    if {[dict exists $BuildDict TestSuites]} {
      foreach Suite [dict get $BuildDict TestSuites] {
        if {![dict exists $Suite Name] || ![dict exists $Suite TestCases]} {
          continue
        }
        if {[dict get $Suite Name] ne $TestSuiteName} {
          continue
        }
        set FoundTc 0
        foreach Tc [dict get $Suite TestCases] {
          if {[dict exists $Tc TestCaseFileName] && [dict get $Tc TestCaseFileName] eq $TestCaseFileName} {
            if {[dict exists $Tc SimulationTime] && $::osvvm::Report2TestCaseSimulationTime eq ""} {
              set ::osvvm::Report2TestCaseSimulationTime [dict get $Tc SimulationTime]
            }
            if {[dict exists $Tc ElapsedTime] && $::osvvm::Report2TestCaseElapsedTime eq ""} {
              set ::osvvm::Report2TestCaseElapsedTime [dict get $Tc ElapsedTime]
            }
            set FoundTc 1
            break
          }
        }
        # Fallback: if no exact file-name match, match by TestCaseName (useful when TestCaseFileName is absent).
        if {!$FoundTc} {
          foreach Tc [dict get $Suite TestCases] {
            if {[dict exists $Tc TestCaseName] && [dict get $Tc TestCaseName] eq $TestCaseName} {
              if {[dict exists $Tc SimulationTime] && $::osvvm::Report2TestCaseSimulationTime eq ""} {
                set ::osvvm::Report2TestCaseSimulationTime [dict get $Tc SimulationTime]
              }
              if {[dict exists $Tc ElapsedTime] && $::osvvm::Report2TestCaseElapsedTime eq ""} {
                set ::osvvm::Report2TestCaseElapsedTime [dict get $Tc ElapsedTime]
              }
              break
            }
          }
        }
        break
      }
    }
  }

  # Read Description and Tags from Alert YAML file before creating summary table
  if {[file exists ${Report2AlertYamlFile}]} {
    set AlertDict [::yaml::yaml2dict -file ${Report2AlertYamlFile}]
    if {[dict exists $AlertDict Status]} {
      set ::osvvm::Report2TestStatus [dict get $AlertDict Status]
    }
    if {[dict exists $AlertDict Title]} {
      set ::osvvm::Report2TestTitle [dict get $AlertDict Title]
    }
    if {[dict exists $AlertDict Brief]} {
      set ::osvvm::Report2TestBrief [dict get $AlertDict Brief]
    }
    if {[dict exists $AlertDict Description]} {
      set ::osvvm::Report2TestDescription [dict get $AlertDict Description]
    }
    if {[dict exists $AlertDict Tags]} {
      set ::osvvm::Report2TestTags [dict get $AlertDict Tags]
    }
    if {[dict exists $AlertDict TagSummaryVisibility]} {
      set ::osvvm::Report2TestTagSummaryVisibility [dict get $AlertDict TagSummaryVisibility]
    }
    if {[dict exists $AlertDict TagTypes]} {
      set ::osvvm::Report2TestTagTypes [dict get $AlertDict TagTypes]
    }
  }

  # Compute display name for the HTML page: prefer Title when set.
  set TestDisplayName $TestCaseName
  if {[info exists ::osvvm::Report2TestTitle]} {
    set CandidateTitle [string trim $::osvvm::Report2TestTitle]
    if {$CandidateTitle ne ""} {
      set TestDisplayName $CandidateTitle
    }
  }

  CreateTestCaseSummaryTable ${TestCaseName} ${TestDisplayName} ${TestSuiteName} ${BuildName} ${GenericDict}
  
  if {[file exists ${Report2AlertYamlFile}]} {
    Alert2Html ${TestCaseName} ${TestSuiteName} ${Report2AlertYamlFile}
  }

#  if {[file exists ${Report2RequirementsYamlFile}]} {
#    # Generate Test Case requirements file - redundant as reported as alerts too. 
#    Requirements2Html ${Report2RequirementsYamlFile} $TestCaseName $TestSuiteName ;# this form deprecated
#  }

  if {[file exists ${Report2CovYamlFile}]} {
    Cov2Html ${TestCaseName} ${TestSuiteName} ${Report2CovYamlFile}
  }
  
  if {$::osvvm::Report2ScoreboardDict ne ""} {
    foreach {SbName SbFile} ${::osvvm::Report2ScoreboardDict} {
      Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbFile} Scoreboard_${SbName}
    }
  }
  
  FinalizeSimulationReportFile
}

#--------------------------------------------------------------
proc OpenSimulationReportFile {FileName {initialize 0}} {
  variable ResultsFile

  if { $initialize } {
    set ResultsFile [open ${FileName} w]
  } else {
    set ResultsFile [open ${FileName} a]
  }
}

#--------------------------------------------------------------
proc CreateTestCaseSummaryTable {TestCaseName TestDisplayName TestSuiteName BuildName GenericDict} {
  variable ResultsFile

  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml] 1

  set ErrorCode [catch {LocalCreateTestCaseSummaryTable $TestCaseName $TestDisplayName $TestSuiteName $BuildName $GenericDict} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }
}

#--------------------------------------------------------------
proc LocalCreateTestCaseSummaryTable {TestCaseName TestDisplayName TestSuiteName BuildName GenericDict} {
  variable ResultsFile

  
  if {$::osvvm::Report2ReportsSubdirectory eq ""} {
    set ReportsPrefix ".."
  } else {
    set ReportsPrefix "../.."
  }

  CreateOsvvmReportHeader $ResultsFile "$TestDisplayName Test Case Report" $ReportsPrefix


  puts $ResultsFile "  <div class=\"summary-parent\">"
  puts $ResultsFile "    <div  class=\"summary-table\">"
  puts $ResultsFile "      <table  class=\"summary-table\">"
  puts $ResultsFile "        <thead>"
  puts $ResultsFile "          <tr class=\"column-header\"><th>Available Reports</th></tr>"
  puts $ResultsFile "        </thead>"
  puts $ResultsFile "        <tbody>"

  if {[file exists ${::osvvm::Report2AlertYamlFile}]} {
    puts $ResultsFile "          <tr><td><a href=\"#AlertSummary\">Alert Report</a></td></tr>"
  }
  if {[file exists ${::osvvm::Report2CovYamlFile}]} {
    puts $ResultsFile "          <tr><td><a href=\"#FunctionalCoverage\">Functional Coverage Report(s)</a></td></tr>"
  }
  
  if {$::osvvm::Report2ScoreboardDict ne ""} {
    foreach SbName [dict keys ${::osvvm::Report2ScoreboardDict}] {
      puts $ResultsFile "          <tr><td><a href=\"#Scoreboard_${SbName}\">ScoreboardPkg_${SbName} Report(s)</a></td></tr>"
    }
  }
  
  # Add link to simulation results in HTML Log File
  if {$::osvvm::Report2SimulationHtmlLogFile ne ""} {
    set TestCaseLink "#${TestSuiteName}_${TestCaseName}${::osvvm::Report2GenericNames}"
    puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${::osvvm::Report2SimulationHtmlLogFile}${TestCaseLink}\">Link to Simulation Results</a></td></tr>"
  }
  
  # Add link to Test Case file
  set TestCaseFile [::fileutil::relative $::osvvm::Report2ReportsDirectory $::osvvm::Report2TestCaseFile]
  set TestCaseFileTail [file tail $TestCaseFile]
  if {$::osvvm::Report2TestCaseFile ne ""} {
    puts $ResultsFile "          <tr><td><a href=\"${::osvvm::VhdlFileViewerPrefix}${TestCaseFile}\">$TestCaseFileTail</a></td></tr>"
  }
  
  # Add Transcript Filess to Table
  if {$::osvvm::Report2TranscriptFiles ne ""} {
    foreach TranscriptFile ${::osvvm::Report2TranscriptFiles} {
      set TranscriptFileName [file tail $TranscriptFile]
      puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${TranscriptFile}\">${TranscriptFileName}</a></td></tr>"
    }
  }

  # Print link back to Build Summary Report
  if {$BuildName ne ""} {
    set BuildLink ${ReportsPrefix}/${BuildName}.html
    puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${BuildName}.html\">${BuildName} Build Summary</a></td></tr>"
  }
    
  puts $ResultsFile "        </tbody>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "    </div>"

  LinkLogoFile $ResultsFile $ReportsPrefix

  puts $ResultsFile "  </div>"

  # Test Result near top (quick essentials)
  puts $ResultsFile "  <div class=\"TestFacts\">"
  puts $ResultsFile "    <details open><summary class=\"subtitle testcase-section-heading\"><span class=\"tc-name\">[EscapeHtml $TestDisplayName]</span><span class=\"tc-sep\"> — </span><span class=\"tc-suffix\">Summary</span></summary>"
  puts $ResultsFile "      <table class=\"AlertSettings\">"
  puts $ResultsFile "        <thead><tr><th>Field</th><th>Value</th></tr></thead>"
  puts $ResultsFile "        <tbody>"
  set StatusValue "⸻"
  if {[info exists ::osvvm::Report2TestStatus] && $::osvvm::Report2TestStatus ne ""} {
    set StatusValue $::osvvm::Report2TestStatus
  }
  set SimTimeValue "⸻"
  if {[info exists ::osvvm::Report2TestCaseSimulationTime] && $::osvvm::Report2TestCaseSimulationTime ne ""} {
    set SimTimeValue $::osvvm::Report2TestCaseSimulationTime
  }
  set ElapsedValue "⸻"
  if {[info exists ::osvvm::Report2TestCaseElapsedTime] && $::osvvm::Report2TestCaseElapsedTime ne ""} {
    set ElapsedValue $::osvvm::Report2TestCaseElapsedTime
  }
  set StatusClass ""
  set StatusUpper [string toupper $StatusValue]
  if {[string first "PASS" $StatusUpper] >= 0} {
    set StatusClass "passed"
  } elseif {[string first "FAIL" $StatusUpper] >= 0 || [string first "ERROR" $StatusUpper] >= 0} {
    set StatusClass "failed"
  } elseif {[string first "SKIP" $StatusUpper] >= 0} {
    set StatusClass "skipped"
  }
  if {$StatusClass ne ""} {
    puts $ResultsFile "          <tr><td>Status</td><td><span class=\"$StatusClass\">$StatusValue</span></td></tr>"
  } else {
    puts $ResultsFile "          <tr><td>Status</td><td>$StatusValue</td></tr>"
  }
  puts $ResultsFile "          <tr><td>Elapsed Time</td><td>$ElapsedValue</td></tr>"
  puts $ResultsFile "          <tr><td>Suite Name</td><td>$TestSuiteName</td></tr>"

  # Include the VHDL test case source file name when available
  set TestCaseSourceFileName "⸻"
  if {[info exists ::osvvm::Report2TestCaseFile] && $::osvvm::Report2TestCaseFile ne ""} {
    set TestCaseSourceFileName [file tail $::osvvm::Report2TestCaseFile]
  }
  puts $ResultsFile "          <tr><td>File</td><td>[EscapeHtml $TestCaseSourceFileName]</td></tr>"

  # Include Title (only when explicitly set; no fallback)
  set TitleValue "⸻"
  if {[info exists ::osvvm::Report2TestTitle] && [string trim $::osvvm::Report2TestTitle] ne ""} {
    set TitleValue $::osvvm::Report2TestTitle
  }
  puts $ResultsFile "          <tr><td>Title</td><td>[EscapeHtml $TitleValue]</td></tr>"

  # Include Brief (only when explicitly set; no fallback)
  set BriefValue "⸻"
  if {[info exists ::osvvm::Report2TestBrief] && [string trim $::osvvm::Report2TestBrief] ne ""} {
    set BriefValue $::osvvm::Report2TestBrief
  }
  puts $ResultsFile "          <tr><td>Brief</td><td>[EscapeHtml $BriefValue]</td></tr>"

  puts $ResultsFile "        </tbody>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "    </details>"
  puts $ResultsFile "  </div>"

  # Render Description / Tags / Generics as independent sections
  # (user-requested: Description not in a table; Tags + Generics in tables)
  if {[info exists ::osvvm::Report2TestDescription] && $::osvvm::Report2TestDescription ne ""} {
    puts $ResultsFile "  <div class=\"TestDescription\">"
    puts $ResultsFile "    <details open><summary class=\"subtitle testcase-section-heading\"><span class=\"tc-name\">[EscapeHtml $TestDisplayName]</span><span class=\"tc-sep\"> — </span><span class=\"tc-suffix\">Description</span></summary>"
    WriteMarkdownSubsetAsHtml $ResultsFile $::osvvm::Report2TestDescription "      "
    puts $ResultsFile "    </details>"
    puts $ResultsFile "  </div>"
  }

  if {[info exists ::osvvm::Report2TestTags] && $::osvvm::Report2TestTags ne ""} {
    puts $ResultsFile "  <div class=\"TestTags\">"
    puts $ResultsFile "    <details open><summary class=\"subtitle testcase-section-heading\"><span class=\"tc-name\">[EscapeHtml $TestDisplayName]</span><span class=\"tc-sep\"> — </span><span class=\"tc-suffix\">Tags</span></summary>"
    puts $ResultsFile "      <table class=\"AlertSettings\">"
    set HasTagSummaryVisibility 0
    if {[info exists ::osvvm::Report2TestTagSummaryVisibility] && $::osvvm::Report2TestTagSummaryVisibility ne ""} {
      if {![catch {dict size $::osvvm::Report2TestTagSummaryVisibility}] && ([dict size $::osvvm::Report2TestTagSummaryVisibility] > 0)} {
        set HasTagSummaryVisibility 1
      }
    }
    if {$HasTagSummaryVisibility} {
      puts $ResultsFile "        <thead><tr><th>Name</th><th>Value</th><th>Type</th><th>ShowInSummary</th></tr></thead>"
    } else {
      puts $ResultsFile "        <thead><tr><th>Name</th><th>Value</th><th>Type</th></tr></thead>"
    }
    puts $ResultsFile "        <tbody>"
    foreach {TagName TagValue} $::osvvm::Report2TestTags {
      set TagDisplayValue [FormatScalarForHtml $TagValue]

      # Prefer explicit tag types from YAML when available.
      set TagType ""
      if {[info exists ::osvvm::Report2TestTagTypes] && $::osvvm::Report2TestTagTypes ne ""} {
        if {![catch {dict size $::osvvm::Report2TestTagTypes}] && [dict exists $::osvvm::Report2TestTagTypes $TagName]} {
          set TagTypeToken [dict get $::osvvm::Report2TestTagTypes $TagName]
          switch -nocase -- $TagTypeToken {
            TAG_STRING    { set TagType "string" }
            TAG_BOOL      { set TagType "boolean" }
            TAG_INT       { set TagType "integer" }
            TAG_REAL      { set TagType "real" }
            TAG_TIME      { set TagType "time" }
            TAG_STD_LOGIC { set TagType "std_logic" }
            default       { set TagType "" }
          }
        }
      }

      # Backward compatible fallback for older YAML (no TagTypes)
      if {$TagType eq ""} {
        if {$TagDisplayValue eq "True" || $TagDisplayValue eq "False"} {
          set TagType "boolean"
        } else {
          set TagType [InferScalarTypeForHtml $TagValue]
        }
      }

      set TagTypeClass [string tolower $TagType]
      regsub -all {[^a-z0-9_-]} $TagTypeClass "_" TagTypeClass
      set TagTypeHtml "<span class=\"datatype datatype-$TagTypeClass\">$TagType</span>"
      if {$HasTagSummaryVisibility && [dict exists $::osvvm::Report2TestTagSummaryVisibility $TagName]} {
        set ShowValue [dict get $::osvvm::Report2TestTagSummaryVisibility $TagName]
        if {[catch {set ShowText [expr {$ShowValue ? "true" : "false"}]}]} {
          set ShowText "⸻"
        }
        puts $ResultsFile "          <tr><td>$TagName</td><td>$TagDisplayValue</td><td>$TagTypeHtml</td><td>$ShowText</td></tr>"
      } else {
        puts $ResultsFile "          <tr><td>$TagName</td><td>$TagDisplayValue</td><td>$TagTypeHtml</td></tr>"
      }
    }
    puts $ResultsFile "        </tbody>"
    puts $ResultsFile "      </table>"
    puts $ResultsFile "    </details>"
    puts $ResultsFile "  </div>"
  }

  if {${GenericDict} ne ""} {
    puts $ResultsFile "  <div class=\"TestGenerics\">"
    puts $ResultsFile "    <details open><summary class=\"subtitle testcase-section-heading\"><span class=\"tc-name\">[EscapeHtml $TestDisplayName]</span><span class=\"tc-sep\"> — </span><span class=\"tc-suffix\">Generics</span></summary>"
    puts $ResultsFile "      <table class=\"AlertSettings\">"
    puts $ResultsFile "        <thead><tr><th>Name</th><th>Value</th><th>Type</th><th>ShowInSummary</th></tr></thead>"
    puts $ResultsFile "        <tbody>"

    # Determine whether generics are configured to show in the suite summary.
    # Note: These controls are not stored in YAML today; they reflect the current
    # script settings (set by SetTestCaseSummaryGenerics/HideTestCaseSummaryGenerics).
    set ShowGenericsInSummary 1
    if {[info exists ::osvvm::TestCaseSummaryShowGenerics]} {
      set ShowGenericsInSummary $::osvvm::TestCaseSummaryShowGenerics
    }
    set GenericWhitelist {}
    if {[info exists ::osvvm::TestCaseSummaryGenericNames]} {
      set GenericWhitelist $::osvvm::TestCaseSummaryGenericNames
    }

    foreach {GenericName GenericValue} $GenericDict {
      set GenericDisplayValue [FormatGenericValueForHtml $GenericName $GenericValue $::osvvm::Report2GenericNames]

      # Infer scalar type (consistent with tag typing).
      if {$GenericDisplayValue eq "True" || $GenericDisplayValue eq "False"} {
        set GenericType "boolean"
      } else {
        set GenericType [InferScalarTypeForHtml $GenericValue]
      }

      set GenericTypeClass [string tolower $GenericType]
      regsub -all {[^a-z0-9_-]} $GenericTypeClass "_" GenericTypeClass
      set GenericTypeHtml "<span class=\"datatype datatype-$GenericTypeClass\">$GenericType</span>"

      # Compute whether this generic would be shown in the Test Case Summary.
      if {!$ShowGenericsInSummary} {
        set GenericShowText "false"
      } elseif {[llength $GenericWhitelist] == 0} {
        set GenericShowText "true"
      } else {
        if {[lsearch -exact $GenericWhitelist $GenericName] >= 0} {
          set GenericShowText "true"
        } else {
          set GenericShowText "false"
        }
      }

      puts $ResultsFile "          <tr><td>$GenericName</td><td>$GenericDisplayValue</td><td>$GenericTypeHtml</td><td>$GenericShowText</td></tr>"
    }
    puts $ResultsFile "        </tbody>"
    puts $ResultsFile "      </table>"
    puts $ResultsFile "    </details>"
    puts $ResultsFile "  </div>"
  }
}

proc FinalizeSimulationReportFile {} {
  variable ResultsFile

  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]
  
  CreateOsvvmReportFooter $ResultsFile  
  
  close $ResultsFile
}
