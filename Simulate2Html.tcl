#  File Name:         Simulate2Html.tcl
#  Purpose:           Convert OSVVM Alert and Coverage results to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM Alert and Coverage results to HTML
#    Calls Alert2Html and Cov2Html
#    Visible externally:  GenerateSimulationReports
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
#    05/2022   2022.05    Updated directory handling
#    03/2022   2022.03    Added Transcript File reporting.
#    02/2022   2022.02    Added Scoreboard Reports. Updated YAML file handling.
#    10/2021   Initial    Initial Revision
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021 - 2022 by SynthWorks Design Inc.
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

proc Simulate2Html {TestCaseName TestSuiteName TestCaseFileName} {
  variable ResultsFile
  variable VhdlReportsDirectory
  variable AlertYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_alerts.yml]
  variable CovYamlFile   [file join $VhdlReportsDirectory ${TestCaseName}_cov.yml]
  variable SbBaseYamlFile ${TestCaseName}_sb_
  variable SbSlvYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_sb_slv.yml]
  variable SbIntYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_sb_int.yml]

  set TestSuiteDirectory [file join ${::osvvm::ReportsDirectory} ${TestSuiteName}]
  CreateDirectory $TestSuiteDirectory
  
  Simulate2HtmlHeader ${TestCaseName} ${TestSuiteName}
  
  if {[file exists ${AlertYamlFile}]} {
    Alert2Html ${TestCaseName} ${TestSuiteName} ${AlertYamlFile}
    file rename -force ${AlertYamlFile}   [file join ${TestSuiteDirectory} ${TestCaseFileName}_alerts.yml]
  }
  
  if {[file exists ${CovYamlFile}]} {
    Cov2Html ${TestCaseName} ${TestSuiteName} ${CovYamlFile}
    file rename -force ${CovYamlFile}     [file join ${TestSuiteDirectory} ${TestCaseFileName}_cov.yml]
  }
  
  set SbFiles [glob -nocomplain ${SbBaseYamlFile}*.yml]
  if {$SbFiles ne ""} {
    foreach SbFile ${SbFiles} {
      set SbName [regsub ${SbBaseYamlFile} [file rootname $SbFile] ""]
      Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbFile} Scoreboard_${SbName}
      # TestCaseFileName includes generics, where SbFile does not
      file rename -force ${SbFile}   [file join ${TestSuiteDirectory} ${TestCaseFileName}_sb_${SbName}.yml]
    }
  }

# Only handles slv and int, not custom named SB
#  if {[file exists ${SbSlvYamlFile}]} {
#    Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbSlvYamlFile} Scoreboard_slv
#    file rename -force ${SbSlvYamlFile}   [file join ${TestSuiteDirectory} ${TestCaseFileName}_sb_slv.yml]
#  }
#  
#  if {[file exists ${SbIntYamlFile}]} {
#    Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbIntYamlFile} Scoreboard_int
#    file rename -force ${SbIntYamlFile}   [file join ${TestSuiteDirectory} ${TestCaseFileName}_sb_int.yml]
#  }
  
  FinalizeSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  file rename -force ${TestCaseName}.html [file join ${TestSuiteDirectory} ${TestCaseFileName}.html]
}

proc OpenSimulationReportFile {TestCaseName TestSuiteName {initialize 0}} {
  variable ResultsFile

  # Create the TestCase file in the simulation directory
  set FileName ${TestCaseName}.html
  if { $initialize } {
    file copy -force ${::osvvm::SCRIPT_DIR}/header_report.html ${FileName}
  }
  set ResultsFile [open ${FileName} a]
}

proc Simulate2HtmlHeader {TestCaseName TestSuiteName} {
  variable ResultsFile

  OpenSimulationReportFile   ${TestCaseName} ${TestSuiteName} 1

  set ErrorCode [catch {LocalSimulate2HtmlHeader $TestCaseName $TestSuiteName} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }
}

proc LocalSimulate2HtmlHeader {TestCaseName TestSuiteName} {
  variable ResultsFile
  variable CurrentTranscript
  variable AlertYamlFile 
  variable CovYamlFile   
  variable SbBaseYamlFile 
#  variable SbSlvYamlFile 
#  variable SbIntYamlFile 
  variable TranscriptYamlFile
  variable BuildName
    

  puts $ResultsFile "<title>$TestCaseName Test Case Detailed Report</title>"
  puts $ResultsFile "</head>"
  puts $ResultsFile "<body>"

  puts $ResultsFile "<br>"
  puts $ResultsFile "<h2>$TestCaseName Test Case Detailed Report</h2>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"

  puts $ResultsFile "<br>"
  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr style=\"height:40px\"><th>Available Reports</th></tr>"

  if {[file exists ${AlertYamlFile}]} {
    puts $ResultsFile "  <tr><td><a href=\"#AlertSummary\">Alert Report</a></td></tr>"
  }
  if {[file exists ${CovYamlFile}]} {
    puts $ResultsFile "  <tr><td><a href=\"#FunctionalCoverage\">Functional Coverage Report(s)</a></td></tr>"
  }
  
  set SbFiles [glob -nocomplain ${SbBaseYamlFile}*.yml]
  if {$SbFiles ne ""} {
    foreach SbFile ${SbFiles} {
      set SbName [regsub ${SbBaseYamlFile} [file rootname $SbFile] ""]
      puts $ResultsFile "  <tr><td><a href=\"#Scoreboard_${SbName}\">ScoreboardPkg_${SbName} Report(s)</a></td></tr>"
    }
  }
  
#  if {[file exists ${SbSlvYamlFile}]} {
#    puts $ResultsFile "  <tr><td><a href=\"#Scoreboard_slv\">ScoreboardPkg_slv Report(s)</a></td></tr>"
#  }
#  if {[file exists ${SbIntYamlFile}]} {
#    puts $ResultsFile "  <tr><td><a href=\"#Scoreboard_int\">ScoreboardPkg_int Report(s)</a></td></tr>"
#  }
  
  if {${::osvvm::ReportsSubdirectory} eq ""} {
    set ReportsPrefix ".."
  } else {
    set ReportsPrefix "../.."
  }
#  if {([info exists CurrentTranscript]) && ([file extension $CurrentTranscript] eq ".html")} {
#    set SimulationResultsLink [file join ${::osvvm::LogSubdirectory} ${CurrentTranscript}#${TestSuiteName}_${TestCaseName}]
#    puts $ResultsFile "  <tr><td><a href=\"${ReportsPrefix}/${SimulationResultsLink}\">Link to Simulation Results</a></td></tr>"
#  }
  if {([GetTranscriptType] eq "html") && ([info exists CurrentTranscript])} {
    set HtmlTranscript [file rootname ${CurrentTranscript}]_log.html
    set SimulationResultsLink [file join ${::osvvm::LogSubdirectory} ${HtmlTranscript}#${TestSuiteName}_${TestCaseName}]
    puts $ResultsFile "  <tr><td><a href=\"${ReportsPrefix}/${SimulationResultsLink}\">Link to Simulation Results</a></td></tr>"
  }
  if {[file exists ${TranscriptYamlFile}]} {
    set TranscriptFileArray [::yaml::yaml2dict -file ${TranscriptYamlFile}]
    foreach TranscriptFile $TranscriptFileArray {
      set TranscriptBaseName [file tail $TranscriptFile]
      set CopyTargetFile [file join ${::osvvm::ResultsDirectory} ${TestSuiteName} ${TranscriptBaseName}]
      if {[file normalize ${TranscriptFile}] ne [file normalize ${CopyTargetFile}]} {
        if {[file exists ${TranscriptFile}]} {
          # Check required since if file is open, closed, then re-opened, 
          # it will be in the file more than once
          file rename -force ${TranscriptFile}  ${CopyTargetFile}
        }
      }
      set HtmlTargetFile [file join ${::osvvm::ResultsSubdirectory} ${TestSuiteName} ${TranscriptBaseName}]
      puts $ResultsFile "  <tr><td><a href=\"${ReportsPrefix}/${HtmlTargetFile}\">${TranscriptBaseName}</a></td></tr>"
    }
    # Remove file so it does not impact any following simulation
    file delete -force -- ${TranscriptYamlFile}
  }
  # Print the Generics
  if {${::osvvm::GenericList} ne ""} {
    foreach GenericName $::osvvm::GenericList {
      puts $ResultsFile "  <tr><td>Generic: [lindex $GenericName 0] = [lindex $GenericName 1]</td></tr>"
    }
  }
  # Print link back to Build Summary Report
  if {([info exists BuildName])} {
    set BuildLink ${ReportsPrefix}/${BuildName}.html
    puts $ResultsFile "  <tr><td><a href=\"${ReportsPrefix}/${BuildName}.html\">${BuildName} Build Summary</a></td></tr>"
  }
    
  puts $ResultsFile "</table>"
  puts $ResultsFile "<br><br>"
}

proc FinalizeSimulationReportFile {TestCaseName TestSuiteName} {
  variable ResultsFile

  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  puts $ResultsFile "</body>"
  puts $ResultsFile "</html>"
  close $ResultsFile
}



