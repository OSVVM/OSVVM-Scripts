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
#    02/2022   2022.02    Initial Revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 by SynthWorks Design Inc.  
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
  variable ResultsFile
  
  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  set ErrorCode [catch {LocalScoreboard2Html $TestCaseName $TestSuiteName $SbYamlFile $SbName} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Scoreboard2Html $TestSuiteName $TestCaseName $errmsg
  }  
}

proc LocalScoreboard2Html {TestCaseName TestSuiteName SbYamlFile SbName} {
  variable ResultsFile
  
  puts $ResultsFile "<hr>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "<h2 id=\"${SbName}\">$TestCaseName Scoreboard Report for ${SbName}</h2>"

  set TestDict [::yaml::yaml2dict -file ${SbYamlFile}]
  set VersionNum  [dict get $TestDict Version]
  puts $ResultsFile "<br>"
  puts $ResultsFile "  <div  style=\"margin: 10px 20px;\">"
  puts $ResultsFile "    <table>"
  
  set ScoreboardDictArray [dict get $TestDict Scoreboards]
  ScoreboardHeader2Html $ScoreboardDictArray
  ScoreboardBody2Html   $ScoreboardDictArray

  puts $ResultsFile "    </table>"
  puts $ResultsFile "<br>"
}

proc ScoreboardHeader2Html {ScoreboardDictArray} {
  variable ResultsFile
  
  set FirstScoreboardDict [lindex $ScoreboardDictArray 0]
  puts $ResultsFile "    <tr>"
  foreach key [dict keys $FirstScoreboardDict] {
    puts $ResultsFile "      <th>${key}</th>"
  }
  puts $ResultsFile "    </tr>"
}

proc ScoreboardBody2Html {ScoreboardDictArray} {
  variable ResultsFile
    
  foreach ScoreboardDict $ScoreboardDictArray {
    puts $ResultsFile "    <tr>"
    dict for {key val} ${ScoreboardDict} {
      puts $ResultsFile "      <td>${val}</td>"
    }
    puts $ResultsFile "    </tr>"
  }
}
