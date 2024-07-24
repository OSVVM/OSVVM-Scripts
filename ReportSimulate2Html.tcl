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


#--------------------------------------------------------------
proc Simulate2Html {SettingsFileWithPath} {
  variable ResultsFile
  
  variable Report2AlertYamlFile              
#  variable Report2RequirementsYamlFile 
  variable Report2CovYamlFile          
  
    
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
proc CreateTestCaseSummaryTable {TestCaseName TestSuiteName BuildName GenericDict} {
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
}

proc FinalizeSimulationReportFile {} {
  variable ResultsFile

  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]
  
  CreateOsvvmReportFooter $ResultsFile  
  
  close $ResultsFile
}
