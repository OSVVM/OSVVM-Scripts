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
#    05/2024   2024.05    Minor updates during Simulate2Html refactoring
#    04/2024   2024.04    Updated report formatting
#    02/2022   2022.02    Updated YAML file handling
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021-2024 by SynthWorks Design Inc.
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

  set FilePath [file dirname $AlertYamlFile]
  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]
  
  set ErrorCode [catch {LocalAlert2Html $TestCaseName $TestSuiteName $AlertYamlFile} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Alert2Html $TestSuiteName $TestCaseName $errmsg
  }
}

proc LocalAlert2Html {TestCaseName TestSuiteName AlertYamlFile} {
  variable ResultsFile

  set Alert2HtmlDict [::yaml::yaml2dict -file ${AlertYamlFile}]
  
  AlertSettings $Alert2HtmlDict
  
  CreateAlertResultsHeader $TestCaseName
  
  AlertWrite $Alert2HtmlDict
  
  CreateAlertResultsFooter
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

  puts $ResultsFile "  <hr />"
  puts $ResultsFile "  <div class=\"AlertSummary\">"
  puts $ResultsFile "    <h2 id=\"AlertSummary\">$Name Alert Report</h2>"
  puts $ResultsFile "    <div class=\"AlertSettings\">"
  puts $ResultsFile "      <details open><summary class=\"subtitle\">$Name Alert Settings</summary>"
  puts $ResultsFile "        <table class=\"AlertSettings\">"
  puts $ResultsFile "          <thead>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <th colspan=\"2\">Setting</th>"
  puts $ResultsFile "                <th>Value</th>"
  puts $ResultsFile "                <th>Description</th>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "          </thead>"
  puts $ResultsFile "          <tbody>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td colspan=\"2\">FailOnWarning</td>"
  puts $ResultsFile "                <td>[dict get $Settings FailOnWarning]</td>"
  puts $ResultsFile "                <td>If true, warnings are a test error</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td colspan=\"2\">FailOnDisabledErrors</td>"
  puts $ResultsFile "                <td>[dict get $Settings FailOnDisabledErrors]</td>"
  puts $ResultsFile "                <td>If true, Disabled Alert Counts are a test error</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td colspan=\"2\">FailOnRequirementErrors</td>"
  puts $ResultsFile "                <td>[dict get $Settings FailOnRequirementErrors]</td>"
  puts $ResultsFile "                <td>If true, Requirements Errors are a test error</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td rowspan=\"3\">External</td>"
  puts $ResultsFile "                <td>Failures</td>"
  puts $ResultsFile "                <td>$ExternalFailure</td>"
  puts $ResultsFile "                <td rowspan=\"3\">Added to Alert Counts in determine total errors</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td>Errors</td>"
  puts $ResultsFile "                <td>$ExternalError</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td>Warnings</td>"
  puts $ResultsFile "                <td>$ExternalWarning</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td rowspan=\"3\">Expected</td>"
  puts $ResultsFile "                <td>Failures</td>"
  puts $ResultsFile "                <td>$ExpectedFailure</td>"
  puts $ResultsFile "                <td rowspan=\"3\">Subtracted from Alert Counts in determine total errors</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td>Errors</td>"
  puts $ResultsFile "                <td>$ExpectedError</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "                <td>Warnings</td>"
  puts $ResultsFile "                <td>$ExpectedWarning</td>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "          </tbody>"
  puts $ResultsFile "        </table>"
  puts $ResultsFile "      </details>"
  puts $ResultsFile "    </div>"
}

proc CreateAlertResultsHeader {TestCaseName} {
  variable ResultsFile
  
  puts $ResultsFile "    <div class=\"AlertResults\">"
  puts $ResultsFile "      <details open><summary class=\"subtitle\">$TestCaseName Alert Results</summary>"
  puts $ResultsFile "        <table class=\"AlertResults\">"
  puts $ResultsFile "          <thead>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "              <th rowspan=\"2\">Name</th>"
  puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
  puts $ResultsFile "              <th colspan=\"3\">Checks</th>"
  puts $ResultsFile "              <th colspan=\"2\">Requirements</th>"
  puts $ResultsFile "              <th colspan=\"3\">Alert Counts</th>"
  puts $ResultsFile "              <th colspan=\"3\">Disabled Alert Counts</th>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "            <tr>"
  puts $ResultsFile "              <th>Total</th>"
  puts $ResultsFile "              <th>Passed</th>"
  puts $ResultsFile "              <th>Failed</th>"
  puts $ResultsFile "              <th>Goal</th>"
  puts $ResultsFile "              <th>Passed</th>"
  puts $ResultsFile "              <th>Failures</th>"
  puts $ResultsFile "              <th>Errors</th>"
  puts $ResultsFile "              <th>Warnings</th>"
  puts $ResultsFile "              <th>Failures</th>"
  puts $ResultsFile "              <th>Errors</th>"
  puts $ResultsFile "              <th>Warnings</th>"
  puts $ResultsFile "            </tr>"
  puts $ResultsFile "          </thead>"
  puts $ResultsFile "          <tbody>"
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
    
    set StatusClass               "class=\"passed\""
    set PassedCountClass          "class=\"passed\""
    set AlertFailureClass         ""
    set AlertErrorClass           ""
    set AlertWarningClass         ""
    set RequirementsClass         ""
    set DisabledAlertFailureClass ""
    set DisabledAlertErrorClass   ""
    set DisabledAlertWarningClass ""
    if { $Status ne "PASSED" } {
      set StatusClass "class=\"failed\""
# Errors that could have contributed to the root cause error(s)
      if {$PassedCount < $AffirmCount} {
        set PassedCountClass  "class=\"failed\""
      }
      if {$AlertFailure > 0} {
        set AlertFailureClass "class=\"failed\""
      }
      if {$AlertError > 0} {
        set AlertErrorClass   "class=\"failed\""
      }
      if {$AlertWarning > 0} {
        set AlertWarningClass "class=\"failed\""
      }
      if {$RequirementsPassed < $RequirementsGoal} {
        set RequirementsClass "class=\"failed\""
      }
      if {$DisabledAlertFailure > 0} {
        set DisabledAlertFailureClass "class=\"failed\""
      }
      if {$DisabledAlertError > 0} {
        set DisabledAlertErrorClass   "class=\"failed\""
      }
      if {$DisabledAlertWarning > 0} {
        set DisabledAlertWarningClass "class=\"failed\""
      }
    } else {
      # Errors Expected or Disabled, Show as Yellow/Orange
      if {$PassedCount < $AffirmCount} {
        set PassedCountClass  "class=\"warning\""
      }
      if {$AlertFailure > 0} {
        set AlertFailureClass "class=\"warning\""
      }
      if {$AlertError > 0} {
        set AlertErrorClass   "class=\"warning\""
      }
      if {$AlertWarning > 0} {
        set AlertWarningClass "class=\"warning\""
      }
      if {$RequirementsPassed < $RequirementsGoal} {
        set RequirementsClass "class=\"warning\""
      }
      if {$DisabledAlertFailure > 0} {
        set DisabledAlertFailureClass "class=\"warning\""
      }
      if {$DisabledAlertError > 0} {
        set DisabledAlertErrorClass   "class=\"warning\""
      }
      if {$DisabledAlertWarning > 0} {
        set DisabledAlertWarningClass "class=\"warning\""
      }
    }

    puts $ResultsFile "            <tr>"
    puts $ResultsFile "              <td>${Prefix}${Name}</td>"
    puts $ResultsFile "              <td ${StatusClass}>$Status</td>"
    puts $ResultsFile "              <td ${PassedCountClass}>$AffirmCount</td>"
    puts $ResultsFile "              <td ${PassedCountClass}>$PassedCount</td>"
    puts $ResultsFile "              <td ${StatusClass}>$TotalErrors</td>"
    puts $ResultsFile "              <td ${RequirementsClass}>$RequirementsGoal</td>"
    puts $ResultsFile "              <td ${RequirementsClass}>$RequirementsPassed</td>"
    puts $ResultsFile "              <td ${AlertFailureClass}>$AlertFailure</td>"
    puts $ResultsFile "              <td ${AlertErrorClass}>$AlertError</td>"
    puts $ResultsFile "              <td ${AlertWarningClass}>$AlertWarning</td>"
    puts $ResultsFile "              <td ${DisabledAlertErrorClass}>$DisabledAlertFailure</td>"
    puts $ResultsFile "              <td ${DisabledAlertErrorClass}>$DisabledAlertError</td>"
    puts $ResultsFile "              <td ${DisabledAlertWarningClass}>$DisabledAlertWarning</td>"
    puts $ResultsFile "            </tr>"
       
    set Children [dict get $AlertDict Children]
    foreach Child $Children {
      set NewPrefix "&emsp; ${Prefix}"
      AlertWrite $Child ${NewPrefix}
    }
  }
}

proc CreateAlertResultsFooter {} {
  variable ResultsFile
  
  puts $ResultsFile "          <tbody>"
  puts $ResultsFile "        </table>"
  puts $ResultsFile "      </details>"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "  </div>"
}


