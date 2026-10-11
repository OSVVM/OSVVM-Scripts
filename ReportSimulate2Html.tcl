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
proc Simulate2Html {SettingsFileWithPath BaseDirectory} {
  # Create the HTML test case report from the YAML files written by a simulation.
  #  SettingsFileWithPath - Test case settings file `<TestCaseFileName>_run.yml`, including its path.
  #  BaseDirectory        - Build output directory. The paths in the test case settings file are relative to it.
  #
  # Reads the test case settings (`GetTestCaseSettings`) and writes the report `<TestCaseFileName>.html` into the test
  # suite's report directory. `<TestCaseFileName>` is the test case name, followed by `_<GenericValue>` for each generic
  # of the simulation. The report integrates:
  #
  # `<TestCaseFileName>_run.yml`   - test case settings: a summary table with the generics and links
  # `<TestCaseName>_alerts.yml`    - alert results of `AlertLogPkg` ([Alert2Html])
  # `<TestCaseName>_cov.yml`       - functional coverage of `CoveragePkg` ([Cov2Html])
  # `<TestCaseName>_sb_<Name>.yml` - results of each `ScoreboardGenericPkg` instance ([Scoreboard2Html])
  #
  # The summary table links to the test case's VHDL file - the last file analyzed before `simulate` -, to the transcript
  # files opened with `TranscriptOpen`, to the test case's results in the HTML simulator transcript, and to the build
  # summary report.
  #
  # Called after each simulation.
  #
  # See also: [Alert2Html] [Cov2Html] [Scoreboard2Html]
  variable ResultsFile

  variable Report2AlertYamlFile
#  variable Report2RequirementsYamlFile
  variable Report2CovYamlFile
  variable Report2BaseDirectory

  # Report2BaseDirectory - Path to report files.
  # Cannot be derived from $SettingsFileWithPath as too much freedom with directories
  # Set before GetOsvvmPathSettings
  set Report2BaseDirectory   $BaseDirectory
  GetTestCaseSettings $SettingsFileWithPath

  set TestCaseFileName $::osvvm::Report2TestCaseFileName
  set TestCaseName     $::osvvm::Report2TestCaseName
  set TestSuiteName    $::osvvm::Report2TestSuiteName
  set BuildName        $::osvvm::Report2BuildName
  set GenericDict      $::osvvm::Report2GenericDict

  CreateTestCaseSummaryTable ${TestCaseName} ${TestSuiteName} ${BuildName} ${GenericDict}

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
    foreach {SbName SbFileYaml} ${::osvvm::Report2ScoreboardDict} {
      Scoreboard2Html ${TestCaseName} ${TestSuiteName} [file join ${Report2BaseDirectory} ${SbFileYaml}] Scoreboard_${SbName}
    }
  }

  FinalizeSimulationReportFile
}

#--------------------------------------------------------------
proc OpenSimulationReportFile {FileName {initialize 0}} {
  # Open the HTML test case report as `ResultsFile`.
  #  FileName   - Path of the report.
  #  initialize - If true, create or truncate the file. Otherwise append to it.
  variable ResultsFile

  if { $initialize } {
    set ResultsFile [open ${FileName} w]
  } else {
    set ResultsFile [open ${FileName} a]
  }
}

#--------------------------------------------------------------
proc CreateTestCaseSummaryTable {TestCaseName TestSuiteName BuildName GenericDict} {
  # Create the HTML test case report with its header and summary table.
  #  TestCaseName  - Name of the test case.
  #  TestSuiteName - Name of the test suite.
  #  BuildName     - Name of the build, linked to its build summary report. Empty: no link.
  #  GenericDict   - Generics of the simulation, as a list of names and values.
  #
  # Creates `Report2TestCaseHtml`, overwriting an existing file, and writes it with `LocalCreateTestCaseSummaryTable`.
  # On an error, the report is closed and `CallbackOnError_Simulate2HtmlHeader` is called.
  variable ResultsFile

  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml] 1

  set ErrorCode [catch {LocalCreateTestCaseSummaryTable $TestCaseName $TestSuiteName $BuildName $GenericDict} errmsg]

  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }
}

#--------------------------------------------------------------
proc LocalCreateTestCaseSummaryTable {TestCaseName TestSuiteName BuildName GenericDict} {
  # Write the HTML header and the summary table of a test case report.
  #  TestCaseName  - Name of the test case.
  #  TestSuiteName - Name of the test suite.
  #  BuildName     - Name of the build. Empty: no link to the build summary report.
  #  GenericDict   - Generics of the simulation, as a list of names and values.
  #
  # Writes the header with the title `<TestCaseName> Test Case Report` and a table of the available reports: one line
  # per generic, links to the alert, functional coverage and scoreboard sections that exist, to the test case's results
  # in the HTML simulator transcript, to the test case's VHDL file (prefixed with `VhdlFileViewerPrefix`), to the HTML
  # version of each transcript file and to the build summary report, followed by the OSVVM logo. Links are relative to
  # the report's directory.
  variable ResultsFile


  if {$::osvvm::Report2ReportsSubdirectory eq ""} {
    set ReportsPrefix ".."
  } else {
    set ReportsPrefix "../.."
  }

  CreateOsvvmReportHeader $ResultsFile "$TestCaseName Test Case Report" $ReportsPrefix


  puts $ResultsFile "  <div class=\"summary-parent\">"
  puts $ResultsFile "    <div  class=\"summary-table\">"
  puts $ResultsFile "      <table  class=\"summary-table\">"
  puts $ResultsFile "        <thead>"
  puts $ResultsFile "          <tr class=\"column-header\"><th>Available Reports</th></tr>"
  puts $ResultsFile "        </thead>"
  puts $ResultsFile "        <tbody>"

  # Print the Generics
  if {${GenericDict} ne ""} {
    foreach {GenericName GenericValue} $GenericDict {
      puts $ResultsFile "          <tr><td>Generic: $GenericName = $GenericValue</td></tr>"
    }
  }

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
#  set TestCaseFile [::fileutil::relative $::osvvm::Report2ReportsDirectory $::osvvm::Report2TestCaseFile]
  # Already relative path
  set TestCaseFile $::osvvm::Report2TestCaseFile
  set TestCaseFileTail [file tail $TestCaseFile]
  if {$::osvvm::Report2TestCaseFile ne ""} {
    puts $ResultsFile "          <tr><td><a href=\"${::osvvm::VhdlFileViewerPrefix}${TestCaseFile}\">$TestCaseFileTail</a></td></tr>"
  }

  # Add Transcript Filess to Table
  if {$::osvvm::Report2TranscriptFiles ne ""} {
    foreach TranscriptFile ${::osvvm::Report2TranscriptFiles} {
      set TranscriptFileHtml [file rootname $TranscriptFile].html
      set TranscriptFileName [file tail $TranscriptFileHtml]
      puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${TranscriptFileHtml}\">${TranscriptFileName}</a></td></tr>"
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
}

proc FinalizeSimulationReportFile {} {
  # Append the footer to the HTML test case report and close it.
  variable ResultsFile

  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]

  CreateOsvvmReportFooter $ResultsFile

  close $ResultsFile
}
