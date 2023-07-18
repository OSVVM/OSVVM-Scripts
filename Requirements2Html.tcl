#  File Name:         Requirements2Html.tcl
#  Purpose:           Create HTML for Requirements
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Visible externally:  Requirements2Html
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
#    07/2023   2023.07    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2023 by SynthWorks Design Inc.
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

proc Requirements2Html {RequirementsYamlFile {TestCaseName ""} {TestSuiteName ""}} {
  variable ResultsFile

  if {[file exists $RequirementsYamlFile]} {
    if {$TestSuiteName eq ""} {
      set FileRoot [file rootname $RequirementsYamlFile]
      set HtmlFileName ${FileRoot}.html
      file copy -force ${::osvvm::OsvvmScriptDirectory}/header_report.html ${HtmlFileName}
      set ResultsFile [open ${HtmlFileName} a]
      set ReportName [regsub {_req} [file tail $FileRoot] ""] 
    } else {
      OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
      set ReportName $TestCaseName
    }
    set ErrorCode [catch {LocalRequirements2Html $RequirementsYamlFile $ReportName} errmsg]
    close $ResultsFile

    if {$ErrorCode} {
#      CallbackOnError_Requirements2Html $TestSuiteName $TestCaseName $errmsg
       puts "TODO!! CallbackOneError_Requirements2Html"
    }
  }
}


proc LocalRequirements2Html {RequirementsYamlFile ReportName} {
  variable ResultsFile

  set UnsortedRequirements2Dict [::yaml::yaml2dict -file ${RequirementsYamlFile}]
  
  set Requirements2Dict [lsort -index 1 $UnsortedRequirements2Dict]
  
  RequirementsTableHeader $ReportName
  
  foreach item $Requirements2Dict {
    set Requirement [dict get $item Requirement]
    set TestCases [dict get $item TestCases]
    set NumTestCases [llength $TestCases]
    if {$NumTestCases == 1} {
      set TestCase [lindex $TestCases 0]
      WriteOneRequirement $TestCase $Requirement
    } else {
      WriteOneRequirement [MergeTestCaseResults $TestCases] $Requirement
      foreach TestCase $TestCases {
        WriteOneRequirement $TestCase 
      }
    }
  }  
  
  puts $ResultsFile "</table>"
  puts $ResultsFile "<br>"
  puts $ResultsFile "</details>"
  puts $ResultsFile "<br><br>"
}

proc RequirementsTableHeader { ReportName } {
  variable ResultsFile

  puts $ResultsFile "<DIV STYLE=\"font-size:25px\"><BR></DIV>"
  puts $ResultsFile "<details open><summary style=\"font-size: 16px;\"><strong>$ReportName Requirement Results</strong></summary>"
  puts $ResultsFile "<DIV STYLE=\"font-size:10px\"><BR></DIV>"

  puts $ResultsFile "<table>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <th rowspan=\"2\">Requirement</th>"
  puts $ResultsFile "      <th rowspan=\"2\">TestName</th>"
  puts $ResultsFile "      <th rowspan=\"2\">Status</th>"
  puts $ResultsFile "      <th colspan=\"4\">Requirements</th>"
  puts $ResultsFile "      <th colspan=\"3\">Alert Counts</th>"
  puts $ResultsFile "      <th colspan=\"3\">Disabled Alert Counts</th>"
  puts $ResultsFile "  </tr>"
  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <th>Goal</th>"
  puts $ResultsFile "      <th>Passed</th>"
  puts $ResultsFile "      <th>Errors</th>"
  puts $ResultsFile "      <th>Checked</th>"
  puts $ResultsFile "      <th>Failures</th>"
  puts $ResultsFile "      <th>Errors</th>"
  puts $ResultsFile "      <th>Warnings</th>"
  puts $ResultsFile "      <th>Failures</th>"
  puts $ResultsFile "      <th>Errors</th>"
  puts $ResultsFile "      <th>Warnings</th>"
  puts $ResultsFile "  </tr>"
}

proc WriteOneRequirement {TestCase {Requirement ""}} {
  variable ResultsFile
 
  set TestName             [dict get $TestCase  TestName]
  set Status               [dict get $TestCase  Status]
  set ResultsDict          [dict get $TestCase  Results]
  set Goal                 [dict get $ResultsDict  Goal]
  set Passed               [dict get $ResultsDict  Passed]
  set Errors               [dict get $ResultsDict  Errors]
  set Checked              [dict get $ResultsDict  Checked]
  
  set AlertCount           [dict get $ResultsDict        AlertCount]
  set AlertFailure         [dict get $AlertCount         Failure]
  set AlertError           [dict get $AlertCount         Error]
  set AlertWarning         [dict get $AlertCount         Warning]
  set DisabledAlertCount   [dict get $ResultsDict        DisabledAlertCount]
  set DisabledAlertFailure [dict get $DisabledAlertCount Failure]
  set DisabledAlertError   [dict get $DisabledAlertCount Error]
  set DisabledAlertWarning [dict get $DisabledAlertCount Warning]    
  
  
  if { $Status eq "FAILED" } {
    set StatusColor "#F00000"
  } elseif {$Status eq "PASSED" } {
    set StatusColor "#00C000"
  } else {
    set StatusColor "#D09000"
  } 
  set PassedCountColor   [ expr {$Passed  < $Checked ? "#F00000" : "#000000"}]
  set RequirementsColor  [expr {$Passed < $Goal     ? "#F00000" : "#000000"}]

  set AlertFailureColor         [expr {$AlertFailure > 0         ? "#F00000" : "#000000"}]
  set AlertErrorColor           [expr {$AlertError   > 0         ? "#F00000" : "#000000"}]
  set AlertWarningColor         [expr {$AlertWarning > 0         ? "#F00000" : "#000000"}]
  set DisabledAlertFailureColor [expr {$DisabledAlertFailure > 0 ? "#F00000" : "#000000"}]
  set DisabledAlertErrorColor   [expr {$DisabledAlertError   > 0 ? "#F00000" : "#000000"}]
  set DisabledAlertWarningColor [expr {$DisabledAlertWarning > 0 ? "#F00000" : "#000000"}]

  puts $ResultsFile "  <tr>"
  puts $ResultsFile "      <td>${Requirement}</td>"
  puts $ResultsFile "      <td>${TestName}</td>"
  puts $ResultsFile "      <td style=color:${StatusColor}>$Status</td>"
  
  puts $ResultsFile "      <td style=color:${RequirementsColor}>$Goal</td>"
  puts $ResultsFile "      <td style=color:${RequirementsColor}>$Passed</td>"

  puts $ResultsFile "      <td style=color:${StatusColor}>$Errors</td>"
  puts $ResultsFile "      <td style=color:${PassedCountColor}>$Checked</td>"
  
  puts $ResultsFile "      <td style=color:${AlertFailureColor}>$AlertFailure</td>"
  puts $ResultsFile "      <td style=color:${AlertErrorColor}>$AlertError</td>"
  puts $ResultsFile "      <td style=color:${AlertWarningColor}>$AlertWarning</td>"
  
  puts $ResultsFile "      <td style=color:${DisabledAlertErrorColor}>$DisabledAlertFailure</td>"
  puts $ResultsFile "      <td style=color:${DisabledAlertErrorColor}>$DisabledAlertError</td>"
  puts $ResultsFile "      <td style=color:${DisabledAlertWarningColor}>$DisabledAlertWarning</td>"
  puts $ResultsFile "  </tr>"
}

proc MergeTestCaseResults { TestCases } {

  set TestName             Merged
  set Status               PASSED
  set Goal                 0
  set Passed               0
  set Errors               0
  set Checked              0

  set AlertFailure         0
  set AlertError           0
  set AlertWarning         0
  set DisabledAlertFailure 0
  set DisabledAlertError   0
  set DisabledAlertWarning 0

  foreach TestCase $TestCases {
    set CurStatus               [dict get $TestCase  Status]
    set ResultsDict             [dict get $TestCase  Results]
    set CurGoal                 [dict get $ResultsDict  Goal]
    set DictPassed              [dict get $ResultsDict  Passed]
    set CurPassed           [expr {$DictPassed < $CurGoal ? $DictPassed : $CurGoal}]
    set CurErrors               [dict get $ResultsDict  Errors]
    set CurChecked              [dict get $ResultsDict  Checked]
    set AlertCount              [dict get $ResultsDict        AlertCount]
    set CurAlertFailure         [dict get $AlertCount         Failure]
    set CurAlertError           [dict get $AlertCount         Error]
    set CurAlertWarning         [dict get $AlertCount         Warning]
    set DisabledAlertCount      [dict get $ResultsDict        DisabledAlertCount]
    set CurDisabledAlertFailure [dict get $DisabledAlertCount Failure]
    set CurDisabledAlertError   [dict get $DisabledAlertCount Error]
    set CurDisabledAlertWarning [dict get $DisabledAlertCount Warning]   
    
    if {$CurStatus eq "FAILED"} {
      set Status "FAILED"
    }
    set Goal                 [expr {$Goal > $CurGoal ? $Goal : $CurGoal}]
    set Passed               [expr {$Passed  + $CurPassed}]
    set Errors               [expr {$Errors  + $CurErrors}]
    set Checked              [expr {$Checked + $CurChecked}]

    set AlertFailure         [expr {$AlertFailure + $CurAlertFailure}]
    set AlertError           [expr {$AlertError   + $CurAlertError}]
    set AlertWarning         [expr {$AlertWarning + $CurAlertWarning}]
    set DisabledAlertFailure [expr {$DisabledAlertFailure + $CurDisabledAlertFailure}]
    set DisabledAlertError   [expr {$DisabledAlertError   + $CurDisabledAlertError}]
    set DisabledAlertWarning [expr {$DisabledAlertWarning + $CurDisabledAlertWarning}]
  }
  
  set TestName Merged
  
#  dict set NewDict TestName Merged Status $Status Results { \
#    Goal $Goal Passed $Passed Errors $Errors Checked $Checked \
#    AlertCount {Failure $AlertFailure Error $AlertError Warning $AlertWarning} \
#    DisabledAlertCount {Failure $DisabledAlertFailure Error $DisabledAlertError Warning $DisabledAlertWarning} }

#  return $NewDict
  return "TestName Merged Status $Status Results { \
    Goal $Goal Passed $Passed Errors $Errors Checked $Checked \
    AlertCount {Failure $AlertFailure Error $AlertError Warning $AlertWarning} \
    DisabledAlertCount {Failure $DisabledAlertFailure Error $DisabledAlertError Warning $DisabledAlertWarning} }"
}
