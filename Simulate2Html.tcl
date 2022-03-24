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
#    03/2022   2022.03    Added Transcript File reporting.
#    02/2022   2022.02    Added Scoreboard Reports. Updated YAML file handling.
#    10/2021   Initial    Initial Revision
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021-2022 by SynthWorks Design Inc.
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

proc Simulate2Html {TestCaseName TestSuiteName} {
  variable ResultsFile
  variable VhdlReportsDirectory
  variable AlertYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_alerts.yml]
  variable CovYamlFile   [file join $VhdlReportsDirectory ${TestCaseName}_cov.yml]
  variable SbSlvYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_sb_slv.yml]
  variable SbIntYamlFile [file join $VhdlReportsDirectory ${TestCaseName}_sb_int.yml]


  CreateSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  if {[file exists ${AlertYamlFile}]} {
    Alert2Html ${TestCaseName} ${TestSuiteName} ${AlertYamlFile}
    file rename -force ${AlertYamlFile}  ${::osvvm::ReportsDirectory}/${TestSuiteName}
  }
  
  if {[file exists ${CovYamlFile}]} {
    Cov2Html ${TestCaseName} ${TestSuiteName} ${CovYamlFile}
    file rename -force ${CovYamlFile}  ${::osvvm::ReportsDirectory}/${TestSuiteName}
  }
  
  if {[file exists ${SbSlvYamlFile}]} {
    Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbSlvYamlFile} Scoreboard_slv
    file rename -force ${SbSlvYamlFile}  ${::osvvm::ReportsDirectory}/${TestSuiteName}
  }
  
  if {[file exists ${SbIntYamlFile}]} {
    Scoreboard2Html ${TestCaseName} ${TestSuiteName} ${SbIntYamlFile} Scoreboard_int
    file rename -force ${SbIntYamlFile}  ${::osvvm::ReportsDirectory}/${TestSuiteName}
  }
  
  FinalizeSimulationReportFile ${TestCaseName} ${TestSuiteName}
}

proc OpenSimulationReportFile {TestCaseName TestSuiteName {initialize 0}} {
  variable ResultsFile

  set ReportDir [file join ${::osvvm::ReportsDirectory} ${TestSuiteName}]
  CreateDirectory $ReportDir 

  set FileName [file join ${ReportDir} ${TestCaseName}.html]
  if { $initialize } {
    file copy -force ${::osvvm::SCRIPT_DIR}/header_report.html ${FileName}
  }
  set ResultsFile [open ${FileName} a]
}

proc CreateSimulationReportFile {TestCaseName TestSuiteName} {
  variable ResultsFile
  variable CurrentTranscript
  variable AlertYamlFile 
  variable CovYamlFile   
  variable SbSlvYamlFile 
  variable SbIntYamlFile 
  variable TranscriptYamlFile
  
  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName} 1
  
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
  if {[file exists ${SbSlvYamlFile}]} {
    puts $ResultsFile "  <tr><td><a href=\"#Scoreboard_slv\">ScoreboardPkg_slv Report(s)</a></td></tr>"
  }
  if {[file exists ${SbIntYamlFile}]} {
    puts $ResultsFile "  <tr><td><a href=\"#Scoreboard_int\">ScoreboardPkg_int Report(s)</a></td></tr>"
  }
  if {([info exists CurrentTranscript]) && ([file extension $CurrentTranscript] eq ".html")} {
#    set resolvedLogDirectory [file join ${::osvvm::CURRENT_SIMULATION_DIRECTORY} ${::osvvm::LogDirectory}]
#    puts $ResultsFile "  <tr><td><a href=\"${resolvedLogDirectory}/${CurrentTranscript}#${TestSuiteName}_${TestCaseName}\">Link to Simulation Results</a></td></tr>"
    puts $ResultsFile "  <tr><td><a href=\"../../${::osvvm::LogDirectory}/${CurrentTranscript}#${TestSuiteName}_${TestCaseName}\">Link to Simulation Results</a></td></tr>"
  }
  if {[file exists ${TranscriptYamlFile}]} {
    set TranscriptFileArray [::yaml::yaml2dict -file ${TranscriptYamlFile}]
    foreach TranscriptFile $TranscriptFileArray {
      puts $ResultsFile "  <tr><td><a href=\"../../${TranscriptFile}\">${TranscriptFile}</a></td></tr>"
    }
    # Remove file so it does not impact any following simulation
    file delete -force -- ${TranscriptYamlFile}
  }
  
  puts $ResultsFile "</table>"
  puts $ResultsFile "<br><br>"
  close $ResultsFile
}

proc FinalizeSimulationReportFile {TestCaseName TestSuiteName} {
  variable ResultsFile

  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  puts $ResultsFile "</body>"
  puts $ResultsFile "</html>"
  close $ResultsFile
}



