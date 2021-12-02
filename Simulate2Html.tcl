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
#    10/2021   Initial    Initial Revision
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

proc Simulate2Html {TestCaseName TestSuiteName} {
  variable ResultsFile

  CreateSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  if {[file exists reports/${TestCaseName}_alerts.yml]} {
    Alert2Html ${TestCaseName} ${TestSuiteName}
  }
  
  if {[file exists reports/${TestCaseName}_cov.yml]} {
    Cov2Html ${TestCaseName} ${TestSuiteName}
    set Coverage [GetCov ${TestCaseName}]
  } else {
    set Coverage 0.0
  }
  
  FinalizeSimulationReportFile ${TestCaseName} ${TestSuiteName}
  return $Coverage
}

proc OpenSimulationReportFile {TestCaseName TestSuiteName {initialize 0}} {
  variable ResultsFile

  set ReportDir reports/${TestSuiteName}
	if {![file exists ${ReportDir}]} {
    puts "Creating Reports directory for $TestSuiteName"
    file mkdir ${ReportDir}
  }

  set FileName ${ReportDir}/${TestCaseName}.html
  if { $initialize } {
    file copy -force ${::osvvm::SCRIPT_DIR}/header_report.html ${FileName}
  }
  set ResultsFile [open ${FileName} a]
}

proc CreateSimulationReportFile {TestCaseName TestSuiteName} {
  variable ResultsFile

  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName} 1
  
#  set FileName reports/${TestCaseName}].html
#  file copy -force ${::osvvm::SCRIPT_DIR}/header_report.html ${FileName}
#  set ResultsFile [open ${FileName} a]

  puts $ResultsFile "<title>$TestCaseName Test Case Detailed Report</title>"
  puts $ResultsFile "</head>"
  puts $ResultsFile "<body>"

  puts $ResultsFile "<br>"
  puts $ResultsFile "<h2>$TestCaseName Test Case Detailed Report</h2>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"

  puts $ResultsFile "<br>"
  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr style=\"height:40px\"><th>Available Reports</th></tr>"

  if {[file exists reports/${TestCaseName}_alerts.yml]} {
    puts $ResultsFile "  <tr><td><a href=\"#AlertSummary\">Alert Report</a></td></tr>"
  }
  if {[file exists reports/${TestCaseName}_cov.yml]} {
    puts $ResultsFile "  <tr><td><a href=\"#FunctionalCoverage\">Functional Coverage Report(s)</a></td></tr>"
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



