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
#    06/2025   2025.06    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2025 by SynthWorks Design Inc.
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



# -------------------------------------------------
# Index2Html
#
proc Index2Html {} {
  variable ResultsFile
  variable IndexDict

  # Read the YAML file into a dictionary
  set IndexDict [dict get [::yaml::yaml2dict -file index.yml] Builds]

  # Open results file  
  set ResultsFile [open index.html w]
  
  # Convert YAML file to HTML & catch results
  set ErrorCode [catch {LocalIndex2Html} errmsg]
  
  # Close Results file - done here s.t. it is closed even if it fails
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Index2Html index.html $errmsg
  }
}

# -------------------------------------------------
# LocalIndex2Html
#
proc LocalIndex2Html {} {
  variable ResultsFile
  variable IndexDict
  variable FirstBuildName
  
  set FirstBuildName [dict get [lindex $IndexDict 0] Name]
  CreateOsvvmReportHeader $ResultsFile "Index of Builds" [file join $::osvvm::OutputBaseDirectory $FirstBuildName] 1
  
  CreateBuildIndexHeader 
  
  CreateBuildIndexSummary 
  
  CreateOsvvmReportFooter $ResultsFile
}


# -------------------------------------------------
# CreateBuildIndexHeader
#
proc CreateBuildIndexHeader {} {
  variable ResultsFile

  puts $ResultsFile "    <div class=\"RequirementsResults\">"
  puts $ResultsFile "      <table class=\"RequirementsResults\">"
  puts $ResultsFile "        <thead>"
  puts $ResultsFile "          <tr><th rowspan=\"2\">Build</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
  puts $ResultsFile "              <th colspan=\"3\">Test Cases</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Elapsed<br>Time</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Analyze<br>Errors</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Simulate<br>Errors</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Simulator</th>"
  puts $ResultsFile "              <th rowspan=\"2\">OSVVM<br>Version</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Date</th>"
  puts $ResultsFile "          </tr>"
  puts $ResultsFile "          <tr>"
  puts $ResultsFile "              <th>PASSED </th>"
  puts $ResultsFile "              <th>FAILED </th>"
  puts $ResultsFile "              <th>SKIPPED</th>"
  puts $ResultsFile "          </tr>"
  puts $ResultsFile "        </thead>"
  
}


# -------------------------------------------------
# CreateBuildIndexSummary
#
proc CreateBuildIndexSummary  {} {
  variable ResultsFile
  variable IndexDict
  variable FirstBuildName

  puts $ResultsFile "        <tbody>"

  foreach BuildItem  $IndexDict {
    set BuildItemName    [dict get $BuildItem Name]
    set BuildStatus      [dict get $BuildItem Status]

    set PassedClass  "" 
    set FailedClass  "" 
    if { ${BuildStatus} eq "PASSED" } {
      set StatusClass  "class=\"passed\"" 
      set PassedClass  "class=\"passed\"" 
    } elseif { ${BuildStatus} eq "FAILED" } {
      set StatusClass  "class=\"failed\"" 
      set FailedClass  "class=\"failed\"" 
    } else {
      set StatusClass  "class=\"skipped\"" 
    }

    puts $ResultsFile "          <tr>"
    puts $ResultsFile "            <td><a href=\"[file join $::osvvm::OutputBaseDirectory ${BuildItemName}/${BuildItemName}.html]\">${BuildItemName}</a></td>"
    puts $ResultsFile "            <td ${StatusClass}>$BuildStatus</td>"
    puts $ResultsFile "            <td ${PassedClass}>[dict get $BuildItem Passed] </td>"
    puts $ResultsFile "            <td ${FailedClass}>[dict get $BuildItem Failed] </td>"
    puts $ResultsFile "            <td>[dict get $BuildItem Skipped]</td>"
    set  BuildElapsedTime [dict get $BuildItem Elapsed]
    puts $ResultsFile "            <td>[format %d:%02d:%02d [expr ($BuildElapsedTime/(60*60))] [expr (($BuildElapsedTime/60)%60)] [expr (${BuildElapsedTime}%60)]] </td>"
    puts $ResultsFile "            <td>[dict get $BuildItem AnalyzeErrorCount]</td>"
    puts $ResultsFile "            <td>[dict get $BuildItem SimulateErrorCount]</td>"
    puts $ResultsFile "            <td>[dict get $BuildItem ToolName]-[dict get $BuildItem ToolVersion]</td>"
    puts $ResultsFile "            <td>[dict get $BuildItem OsvvmVersion]</td>"
    puts $ResultsFile "            <td>[dict get $BuildItem FinishTime]</td>"
    puts $ResultsFile "        </tr>"
  }
  puts $ResultsFile "        </tbody>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "    </div>"
  
    
}




