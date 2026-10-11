#  File Name:         Scoreboard2Html.tcl
#  Purpose:           Convert OSVVM YAML Scoreboard information to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Convert OSVVM YAML Scoreboard information to HTML
#    Visible externally:  Scoreboard2Html
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
#    05/2024   2024.05    Minor updates during Simulate2Html refactoring
#    04/2024   2024.04    Updated report formatting
#    02/2022   2022.02    Initial Revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 - 2024 by SynthWorks Design Inc.  
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

proc Scoreboard2Html {TestCaseName TestSuiteName SbYamlFile SbName} {
  # Append a scoreboard report to the HTML test case report.
  #  TestCaseName  - Name of the test case.
  #  TestSuiteName - Name of the test suite, used in error messages.
  #  SbYamlFile    - Scoreboard results file, written by an instance of `ScoreboardGenericPkg`.
  #  SbName        - ID and name of the report section, `Scoreboard_<Name>`.
  #
  # Opens the HTML test case report `Report2TestCaseHtml` for appending and writes a table with one row per scoreboard
  # of `SbYamlFile` (`LocalScoreboard2Html`). On an error, the report is closed and `CallbackOnError_Scoreboard2Html` is
  # called.
  #
  # Called by [Simulate2Html] for each scoreboard results file of the test case.
  #
  # See also: [Simulate2Html]
  variable ResultsFile
  
  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]
  
  set ErrorCode [catch {LocalScoreboard2Html $TestCaseName $TestSuiteName $SbYamlFile $SbName} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Scoreboard2Html $TestSuiteName $TestCaseName $errmsg
  }  
}

proc LocalScoreboard2Html {TestCaseName TestSuiteName SbYamlFile SbName} {
  # Write a scoreboard section of an HTML test case report.
  #  TestCaseName  - Name of the test case.
  #  TestSuiteName - Name of the test suite. Not used.
  #  SbYamlFile    - Scoreboard results file.
  #  SbName        - ID and name of the report section.
  #
  # Writes the heading `<TestCaseName> Scoreboard Report for <SbName>` and a table of the `Scoreboards` of `SbYamlFile`
  # (`ScoreboardHeader2Html`, `ScoreboardBody2Html`). Errors are handled by [Scoreboard2Html].
  variable ResultsFile
  
  puts $ResultsFile "  <hr />"
  puts $ResultsFile "  <div class=\"ScoreboardSummary\">"
  puts $ResultsFile "    <h2 id=\"${SbName}\">$TestCaseName Scoreboard Report for ${SbName}</h2>"
  puts $ResultsFile "    <div class=\"${SbName}\">"
  puts $ResultsFile "      <table class=\"ScoreboardSummary\">"

  set TestDict [::yaml::yaml2dict -file ${SbYamlFile}]
  set VersionNum  [dict get $TestDict Version]
  
  set ScoreboardDictArray [dict get $TestDict Scoreboards]
  ScoreboardHeader2Html $ScoreboardDictArray
  ScoreboardBody2Html   $ScoreboardDictArray

  puts $ResultsFile "      </table>"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "  </div>"
}

proc ScoreboardHeader2Html {ScoreboardDictArray} {
  # Write the column headings of a scoreboard table.
  #  ScoreboardDictArray - List of scoreboard results. The keys of the first one are the headings.
  variable ResultsFile
  
  set FirstScoreboardDict [lindex $ScoreboardDictArray 0]
  puts $ResultsFile "          <thead>"
  puts $ResultsFile "            <tr>"
  foreach key [dict keys $FirstScoreboardDict] {
    puts $ResultsFile "              <th>${key}</th>"
  }
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "          </thead>"
}

proc ScoreboardBody2Html {ScoreboardDictArray} {
  # Write one row per scoreboard, with its values in key order.
  #  ScoreboardDictArray - List of scoreboard results.
  variable ResultsFile
    
  puts $ResultsFile "          <tbody>"
  foreach ScoreboardDict $ScoreboardDictArray {
    puts $ResultsFile "            <tr>"
    dict for {key val} ${ScoreboardDict} {
      puts $ResultsFile "              <td>${val}</td>"
    }
    puts $ResultsFile "            </tr>"
  }
  puts $ResultsFile "          </tbody>"
}
