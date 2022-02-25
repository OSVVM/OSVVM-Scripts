#  File Name:         Alert2Html.tcl
#  Purpose:           Convert OSVVM YAML Alert reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM YAML Alert reports to HTML
#    Visible externally:  Alert2Html
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
#    02/2022   2022.02    Updated YAML file handling
#    10/2021   Initial    Initial Revision
#
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

proc Alert2Html {TestCaseName TestSuiteName AlertYamlFile} {
  variable ResultsFile

  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  set Alert2HtmlDict [::yaml::yaml2dict -file ${AlertYamlFile}]
  
  AlertSettings $Alert2HtmlDict

  puts $ResultsFile "<DIV STYLE=\"font-size:25px\"><BR></DIV>"
  puts $ResultsFile "<details open><summary style=\"font-size: 16px;\"><strong>$TestCaseName Alert Results</strong></summary>"
  puts $ResultsFile "<DIV STYLE=\"font-size:10px\"><BR></DIV>"

  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <th rowspan=\"2\">Name</th>"
  puts $ResultsFile "      <th rowspan=\"2\">Status</th>"
  puts $ResultsFile "      <th colspan=\"2\">Checks</th>"
  puts $ResultsFile "      <th rowspan=\"2\">Total<br>Errors</th>"
  puts $ResultsFile "      <th colspan=\"3\">Alert Counts</th>"
  puts $ResultsFile "      <th colspan=\"2\">Requirements</th>"
  puts $ResultsFile "      <th colspan=\"3\">Disabled Alert Counts</th>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <th>Passed</th>"
  puts $ResultsFile "      <th>Total</th>"
  puts $ResultsFile "      <th>Failures</th>"
  puts $ResultsFile "      <th>Errors</th>"
  puts $ResultsFile "      <th>Warnings</th>"
  puts $ResultsFile "      <th>Passed</th>"
  puts $ResultsFile "      <th>Checked</th>"
  puts $ResultsFile "      <th>Failures</th>"
  puts $ResultsFile "      <th>Errors</th>"
  puts $ResultsFile "      <th>Warnings</th>"
  puts $ResultsFile "  </tr>"
  
  AlertWrite $Alert2HtmlDict
  
  puts $ResultsFile "</table>"
  puts $ResultsFile "<br>"
#   puts $ResultsFile "<details><summary>Notes</summary>"
#   puts $ResultsFile "<ul>"
#   puts $ResultsFile "<li>AlertCounts include failed checks.</li>"
#   puts $ResultsFile "<li>AlertCounts are adjusted by External and Expected (failures, errors, warnings)</li>"
#   puts $ResultsFile "<li>Warnings are a test error if FailOnWarnings is true</li>"
#   puts $ResultsFile "<li>Disabled Alerts are a test error if FailOnDisabledErrors is true</li>"
#   puts $ResultsFile "<li>Requirements that do not achieve their goal are a test error if FailOnRequirementErrors is true</li>"
#   puts $ResultsFile "</ul>"
#   puts $ResultsFile "</details>"
  puts $ResultsFile "</details>"
  puts $ResultsFile "<br><br>"
  close $ResultsFile
}

proc AlertSettings {AlertDict} {
  variable ResultsFile
  
  set Name     [dict get $AlertDict Name]
  set Settings [dict get $AlertDict Settings]
  set External [dict get $Settings ExternalErrors]
  set Failure [dict get $External Failure]
  set Error   [dict get $External Error]
  set Warning [dict get $External Warning]
  set ExpectedFailure [expr {$Failure > 0 ? 0 : -$Failure}  ]
  set ExpectedError   [expr {$Error   > 0 ? 0 : -$Error}    ]
  set ExpectedWarning [expr {$Warning > 0 ? 0 : -$Warning}  ]
  set ExternalFailure [expr {$Failure > 0 ? $Failure : 0}   ]
  set ExternalError   [expr {$Error   > 0 ? $Error   : 0}   ]
  set ExternalWarning [expr {$Warning > 0 ? $Warning : 0}   ]

  puts $ResultsFile "<hr>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "<h3 id=\"AlertSummary\">$Name Alert Report</h3>"

#  puts $ResultsFile "<DIV STYLE=\"font-size:25px\"><BR></DIV>"
  puts $ResultsFile "<details open><summary style=\"font-size: 16px;\"><strong>$Name Alert Settings</strong></summary>"
  puts $ResultsFile "<DIV STYLE=\"font-size:10px\"><BR></DIV>"

  puts $ResultsFile "<div  style=\"margin: 5px 40px;\">"
  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <th colspan=\"2\">Setting</th>"
  puts $ResultsFile "      <th>Value</th>"
  puts $ResultsFile "      <th>Description</th>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td colspan=\"2\">FailOnWarning</td>"
  puts $ResultsFile "      <td>[dict get $Settings FailOnWarning]</td>"
  puts $ResultsFile "      <td>If true, warnings are a test error</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td colspan=\"2\">FailOnDisabledErrors</td>"
  puts $ResultsFile "      <td>[dict get $Settings FailOnDisabledErrors]</td>"
  puts $ResultsFile "      <td>If true, Disabled Alert Counts are a test error</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td colspan=\"2\">FailOnRequirementErrors</td>"
  puts $ResultsFile "      <td>[dict get $Settings FailOnRequirementErrors]</td>"
  puts $ResultsFile "      <td>If true, Requirements Errors are a test error</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td rowspan=\"3\">External</td>"
  puts $ResultsFile "      <td>Failures</td>"
  puts $ResultsFile "      <td>$ExternalFailure</td>"
  puts $ResultsFile "      <td rowspan=\"3\">Added to Alert Counts in determine total errors</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td>Errors</td>"
  puts $ResultsFile "      <td>$ExternalError</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td>Warnings</td>"
  puts $ResultsFile "      <td>$ExternalWarning</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td rowspan=\"3\">Expected</td>"
  puts $ResultsFile "      <td>Failures</td>"
  puts $ResultsFile "      <td>$ExpectedFailure</td>"
  puts $ResultsFile "      <td rowspan=\"3\">Subtracted from Alert Counts in determine total errors</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td>Errors</td>"
  puts $ResultsFile "      <td>$ExpectedError</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td>Warnings</td>"
  puts $ResultsFile "      <td>$ExpectedWarning</td>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "</table>"
  puts $ResultsFile "</div>"
  puts $ResultsFile "</details>"
}

proc AlertWrite {AlertDict {Prefix ""}} {
  variable ResultsFile

  if {[dict exists $AlertDict Name]} {
   
    set Results              [dict get $AlertDict    Results]
    set AlertCount           [dict get $Results      AlertCount]
    set DisabledAlertCount   [dict get $Results      DisabledAlertCount]

    set Name                 [dict get $AlertDict          Name]
    set Status               [dict get $AlertDict          Status]
    set PassedCount          [dict get $Results            PassedCount]
    set AffirmCount          [dict get $Results            AffirmCount]
    set TotalErrors          [dict get $Results            TotalErrors]
    set AlertFailure         [dict get $AlertCount         Failure]
    set AlertError           [dict get $AlertCount         Error]
    set AlertWarning         [dict get $AlertCount         Warning]
    set RequirementsPassed   [dict get $Results            RequirementsPassed]
    set RequirementsGoal     [dict get $Results            RequirementsGoal]
    set DisabledAlertFailure [dict get $DisabledAlertCount Failure]
    set DisabledAlertError   [dict get $DisabledAlertCount Error]
    set DisabledAlertWarning [dict get $DisabledAlertCount Warning]    
    
    set StatusColor       "#00C000"
    set PassedCountColor  "#00C000"
    set AlertFailureColor         "#000000"
    set AlertErrorColor           "#000000"
    set AlertWarningColor         "#000000"
    set RequirementsColor         "#000000"
    set DisabledAlertFailureColor "#000000"
    set DisabledAlertErrorColor   "#000000"
    set DisabledAlertWarningColor "#000000"
    if { $Status ne "PASSED" } {
      set StatusColor "#F00000"
# Errors that could have contributed to the root cause error(s)
      if {$PassedCount < $AffirmCount} {
        set PassedCountColor "#F00000"
      }
      if {$AlertFailure > 0} {
        set AlertFailureColor "#F00000"
      }
      if {$AlertError > 0} {
        set AlertErrorColor "#F00000"
      }
      if {$AlertWarning > 0} {
        set AlertWarningColor "#F00000"
      }
      if {$RequirementsPassed < $RequirementsGoal} {
        set RequirementsColor "#F00000"
      }
      if {$DisabledAlertFailure > 0} {
        set DisabledAlertFailureColor "#F00000"
      }
      if {$DisabledAlertError > 0} {
        set DisabledAlertErrorColor "#F00000"
      }
      if {$DisabledAlertWarning > 0} {
        set DisabledAlertWarningColor "#F00000"
      }
    } else {
# Errors Expected or Disabled, Show as Yellow/Orange
      if {$PassedCount < $AffirmCount} {
        set PassedCountColor "#D09000"
      }
      if {$AlertFailure > 0} {
        set AlertFailureColor "#D09000"
      }
      if {$AlertError > 0} {
        set AlertErrorColor "#D09000"
      }
      if {$AlertWarning > 0} {
        set AlertWarningColor "#D09000"
      }
      if {$RequirementsPassed < $RequirementsGoal} {
        set RequirementsColor "#D09000"
      }
      if {$DisabledAlertFailure > 0} {
        set DisabledAlertFailureColor "#D09000"
      }
      if {$DisabledAlertError > 0} {
        set DisabledAlertErrorColor "#D09000"
      }
      if {$DisabledAlertWarning > 0} {
        set DisabledAlertWarningColor "#D09000"
      }

    }

    puts $ResultsFile "  <tr>"
    puts $ResultsFile "      <td>${Prefix}${Name}</td>"
    puts $ResultsFile "      <td style=color:${StatusColor}>$Status</td>"
    puts $ResultsFile "      <td style=color:${PassedCountColor}>$PassedCount</td>"
    puts $ResultsFile "      <td style=color:${PassedCountColor}>$AffirmCount</td>"
    puts $ResultsFile "      <td style=color:${StatusColor}>$TotalErrors</td>"
    puts $ResultsFile "      <td style=color:${AlertFailureColor}>$AlertFailure</td>"
    puts $ResultsFile "      <td style=color:${AlertErrorColor}>$AlertError</td>"
    puts $ResultsFile "      <td style=color:${AlertWarningColor}>$AlertWarning</td>"
    puts $ResultsFile "      <td style=color:${RequirementsColor}>$RequirementsPassed</td>"
    puts $ResultsFile "      <td style=color:${RequirementsColor}>$RequirementsGoal</td>"
    puts $ResultsFile "      <td style=color:${DisabledAlertErrorColor}>$DisabledAlertFailure</td>"
    puts $ResultsFile "      <td style=color:${DisabledAlertErrorColor}>$DisabledAlertError</td>"
    puts $ResultsFile "      <td style=color:${DisabledAlertWarningColor}>$DisabledAlertWarning</td>"
    puts $ResultsFile "  </tr>"
       
    set Children [dict get $AlertDict Children]
    foreach Child $Children {
      set NewPrefix "&emsp; ${Prefix}"
      AlertWrite $Child ${NewPrefix}
    }
  }
}



