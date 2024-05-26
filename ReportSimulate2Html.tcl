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
#    05/2024   2024.05    Refactored.  Separating file copy from creating HTML.
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


#--------------------------------------------------------------
proc Simulate2Html {TestCaseName {TestSuiteName "Default"} {BuildName ""} {GenericList ""}} {
  variable ResultsFile
  variable AlertYamlFile              
  variable RequirementsYamlFile 
  variable CovYamlFile          
  variable Sim2SbFiles        
  variable TestSuiteDirectory
     
  
  set SimGenericNames  [ToGenericNames $GenericList]
  set TestCaseFileName ${TestCaseName}${SimGenericNames}
  
  
#!! TODO - move this to be called after simulate finishes and before Simulate2Html
#!! TODO - add something that acquires or creates required information from parameter list
  
  CreateTestCaseSummaryTable ${TestCaseFileName} ${TestSuiteName} ${BuildName} ${GenericList}
  
  if {[file exists ${AlertYamlFile}]} {
    Alert2Html ${TestCaseFileName} ${TestSuiteName} ${AlertYamlFile}
  }

#  if {[file exists ${RequirementsYamlFile}]} {
#    # Generate Test Case requirements file - redundant as reported as alerts too. 
#    Requirements2Html ${RequirementsYamlFile} $TestCaseFileName $TestSuiteName ;# this form deprecated
#  }

  if {[file exists ${CovYamlFile}]} {
    Cov2Html ${TestCaseFileName} ${TestSuiteName} ${CovYamlFile}
  }
  
  if {$::osvvm::Sim2SbNames ne ""} {
    foreach SbName ${::osvvm::Sim2SbNames} SbFile ${::osvvm::Sim2SbFiles} {
      Scoreboard2Html ${TestCaseFileName} ${TestSuiteName} ${SbFile} Scoreboard_${SbName}
    }
  }
  
  FinalizeSimulationReportFile [file join ${TestSuiteDirectory} ${TestCaseFileName}.html]
  
#  file rename -force ${TestCaseName}.html [file join ${TestSuiteDirectory} ${TestCaseFileName}.html]
}

#--------------------------------------------------------------
proc ToGenericNames {GenericList} {

  set Names ""
  if {${GenericList} ne ""} {
    foreach GenericName $GenericList {
      set Names ${Names}_[lindex $GenericName 0]_[lindex $GenericName 1]
    }
  }
  return $Names
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
proc CreateTestCaseSummaryTable {TestCaseName TestSuiteName BuildName GenericList} {
  variable ResultsFile

  set FilePath [file dirname $::osvvm::AlertYamlFile]
  OpenSimulationReportFile [file join $FilePath ${TestCaseName}.html] 1

  set ErrorCode [catch {LocalCreateTestCaseSummaryTable $TestCaseName $TestSuiteName $BuildName $GenericList} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }
}

#--------------------------------------------------------------
proc LocalCreateTestCaseSummaryTable {TestCaseName TestSuiteName BuildName GenericList} {
  variable ResultsFile
  variable AlertYamlFile 
  variable CovYamlFile   
  variable SimGenericNames

  if {$::osvvm::ReportsSubdirectory eq ""} {
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

  if {[file exists ${AlertYamlFile}]} {
    puts $ResultsFile "          <tr><td><a href=\"#AlertSummary\">Alert Report</a></td></tr>"
  }
  if {[file exists ${CovYamlFile}]} {
    puts $ResultsFile "          <tr><td><a href=\"#FunctionalCoverage\">Functional Coverage Report(s)</a></td></tr>"
  }
  
  if {$::osvvm::Sim2SbNames ne ""} {
    foreach SbName ${::osvvm::Sim2SbNames} {
      puts $ResultsFile "          <tr><td><a href=\"#Scoreboard_${SbName}\">ScoreboardPkg_${SbName} Report(s)</a></td></tr>"
    }
  }
  
  # Add link to simulation results in HTML Log File
  if {$::osvvm::SimulationHtmlLogFile ne ""} {
#    set TestCaseLink "#${TestSuiteName}_${TestCaseName}${SimGenericNames}"
    set TestCaseLink "#${TestSuiteName}_${TestCaseName}"
    puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${::osvvm::SimulationHtmlLogFile}${TestCaseLink}\">Link to Simulation Results</a></td></tr>"
  }
  # Add Transcript Filess to Table
  if {$::osvvm::TranscriptFiles ne ""} {
    foreach TranscriptFile ${::osvvm::TranscriptFiles} {
      set TranscriptFileName [file tail $TranscriptFile]
      puts $ResultsFile "          <tr><td><a href=\"${ReportsPrefix}/${TranscriptFile}\">${TranscriptFileName}</a></td></tr>"
    }
  }
  # Print the Generics
  if {${GenericList} ne ""} {
    foreach GenericName $GenericList {
      puts $ResultsFile "          <tr><td>Generic: [lindex $GenericName 0] = [lindex $GenericName 1]</td></tr>"
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

proc FinalizeSimulationReportFile {FileName} {
  variable ResultsFile

  OpenSimulationReportFile $FileName
  
  CreateOsvvmReportFooter $ResultsFile  
  
  close $ResultsFile
}
