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
#    04/2024   2024.05    Replaced CssSubdirectory with HtmlThemeSubdirectory
#    04/2024   2024.05    Updated report formatting
#    07/2023   2023.07    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2023-2024 by SynthWorks Design Inc.
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

proc Requirements2Html {RequirementsYamlFile {AdditionalPath ""} } {
  variable ResultsFile

  if {[file exists $RequirementsYamlFile]} {
    # Extract HTML file name and ReportName from YamlFile
    set FileRoot [file rootname $RequirementsYamlFile]
    set HtmlFileName ${FileRoot}.html
    set ReportName [regsub {_req} [file tail $FileRoot] ""] 
    
    set ResultsFile [open ${HtmlFileName} w]
    
    # Convert requirements YAML to HTML and catch errors
    set ErrorCode [catch {LocalRequirements2Html $RequirementsYamlFile $ReportName $AdditionalPath} errmsg]
    close $ResultsFile

    if {$ErrorCode} {
      CallbackOnError_AnyReport "Requirements2Html" "RequirementsYamlFile: $RequirementsYamlFile" $errmsg
    }
  }
}


proc LocalRequirements2Html { RequirementsYamlFile ReportName AdditionalPath } {
  variable ResultsFile

  set UnsortedRequirements2Dict [::yaml::yaml2dict -file ${RequirementsYamlFile}]
  
  set Requirements2Dict [lsort -index 1 $UnsortedRequirements2Dict]
  
  RequirementsTableHeader $ReportName $AdditionalPath
  
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
  RequirementsTableFooter
}

proc RequirementsTableHeader { ReportName AdditionalPath } {
  variable ResultsFile

  puts $ResultsFile "<!DOCTYPE html>"
  puts $ResultsFile "<html lang=\"en\">"
  puts $ResultsFile "<head>"
  puts $ResultsFile "  <link rel=\"stylesheet\" href=\"${AdditionalPath}../${::osvvm::HtmlThemeSubdirectory}/CssOsvvmStyle.css\">"
  puts $ResultsFile "  <link rel=\"stylesheet\" href=\"${AdditionalPath}../${::osvvm::HtmlThemeSubdirectory}/Custom-Style.css\">"
  puts $ResultsFile "  <title>$ReportName Requirement Results</title>"
  puts $ResultsFile "</head>"
  puts $ResultsFile "<body>"
  puts $ResultsFile "<header>"
  puts $ResultsFile "  <div class=\"summary-parent\">"
  puts $ResultsFile "    <div class=\"summary-table\">"
  puts $ResultsFile "      <h1>$ReportName Requirement Results</h1>"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "    <div class=\"requirements-logo\">"
  puts $ResultsFile "      <img src=\"${AdditionalPath}../${::osvvm::HtmlThemeSubdirectory}/OsvvmLogo.png\" alt=\"OSVVM logo\">"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "  </div>"
  puts $ResultsFile "</header>"
  puts $ResultsFile "<main>"
  puts $ResultsFile "  <div class=\"RequirementsResults\">"
  puts $ResultsFile "    <table class=\"RequirementsResults\">"
  puts $ResultsFile "      <thead>"
  puts $ResultsFile "        <tr>"
  puts $ResultsFile "          <th rowspan=\"2\">Requirement</th>"
  puts $ResultsFile "          <th rowspan=\"2\">TestName</th>"
  puts $ResultsFile "          <th rowspan=\"2\">Status</th>"
  puts $ResultsFile "          <th colspan=\"2\">Requirements</th>"
  puts $ResultsFile "          <th colspan=\"3\">Checks</th>"
  puts $ResultsFile "          <th colspan=\"3\">Alert Counts</th>"
  puts $ResultsFile "          <th colspan=\"3\">Disabled Alert Counts</th>"
  puts $ResultsFile "        </tr>"
  puts $ResultsFile "        <tr>"
  puts $ResultsFile "          <th>Goal</th>"
  puts $ResultsFile "          <th>Passed</th>"
  puts $ResultsFile "          <th>Total</th>"
  puts $ResultsFile "          <th>Passed</th>"
  puts $ResultsFile "          <th>Failed</th>"
  puts $ResultsFile "          <th>Failures</th>"
  puts $ResultsFile "          <th>Errors</th>"
  puts $ResultsFile "          <th>Warnings</th>"
  puts $ResultsFile "          <th>Failures</th>"
  puts $ResultsFile "          <th>Errors</th>"
  puts $ResultsFile "          <th>Warnings</th>"
  puts $ResultsFile "        </tr>"
  puts $ResultsFile "      </thead>"
  puts $ResultsFile "      <tbody>"
}

proc WriteOneRequirement {TestCase {Requirement ""}} {
  variable ResultsFile
 
  set TestName             [dict get $TestCase  TestName]
  set Status               [dict get $TestCase  Status]
  set ResultsDict          [dict get $TestCase  Results]
  set Goal                 [dict get $ResultsDict  Goal]
  set PassedChecks         [dict get $ResultsDict  Passed]
  set Errors               [dict get $ResultsDict  Errors]
  set Checked              [dict get $ResultsDict  Checked]
  
  if {[dict exists $ResultsDict PassedReq]} {
    set PassedReq         [dict get $ResultsDict  PassedReq]
  } else {
    set PassedReq $PassedChecks
  }
  
  set AlertCount           [dict get $ResultsDict        AlertCount]
  set AlertFailure         [dict get $AlertCount         Failure]
  set AlertError           [dict get $AlertCount         Error]
  set AlertWarning         [dict get $AlertCount         Warning]
  set DisabledAlertCount   [dict get $ResultsDict        DisabledAlertCount]
  set DisabledAlertFailure [dict get $DisabledAlertCount Failure]
  set DisabledAlertError   [dict get $DisabledAlertCount Error]
  set DisabledAlertWarning [dict get $DisabledAlertCount Warning]    
  
  
  if { $Status eq "FAILED" } {
    set StatusClass "class=\"failed\""
  } elseif {$Status eq "PASSED" } {
    set StatusClass "class=\"passed\""
  } else {
    set StatusClass "class=\"skipped\""
  } 
  set RequirementsClass  [expr {$PassedReq    < $Goal     ? "class=\"warning\"" : ""}]
  set PassedChecksClass  [expr {$PassedChecks < $Checked  ? "class=\"warning\"" : ""}]
  set ChecksClass        [expr {$Errors > 0               ? "class=\"failed\"" : ${PassedChecksClass}}]

  set AlertFailureClass         [expr {$AlertFailure > 0         ? "class=\"failed\"" : ""}]
  set AlertErrorClass           [expr {$AlertError   > 0         ? "class=\"failed\"" : ""}]
  set AlertWarningClass         [expr {$AlertWarning > 0         ? "class=\"failed\"" : ""}]
  set DisabledAlertFailureClass [expr {$DisabledAlertFailure > 0 ? "class=\"failed\"" : ""}]
  set DisabledAlertErrorClass   [expr {$DisabledAlertError   > 0 ? "class=\"failed\"" : ""}]
  set DisabledAlertWarningClass [expr {$DisabledAlertWarning > 0 ? "class=\"failed\"" : ""}]

  puts $ResultsFile "        <tr>"
  puts $ResultsFile "            <td>${Requirement}</td>"
  puts $ResultsFile "            <td>${TestName}</td>"
  puts $ResultsFile "            <td ${StatusClass}>$Status</td>"
  puts $ResultsFile "            <td ${RequirementsClass}>$Goal</td>"
  puts $ResultsFile "            <td ${RequirementsClass}>$PassedReq</td>"
  puts $ResultsFile "            <td ${ChecksClass}>$Checked</td>"
  puts $ResultsFile "            <td ${ChecksClass}>$PassedChecks</td>"
  puts $ResultsFile "            <td ${ChecksClass}>$Errors</td>"
  puts $ResultsFile "            <td ${AlertFailureClass}>$AlertFailure</td>"
  puts $ResultsFile "            <td ${AlertErrorClass}>$AlertError</td>"
  puts $ResultsFile "            <td ${AlertWarningClass}>$AlertWarning</td>"
  puts $ResultsFile "            <td ${DisabledAlertErrorClass}>$DisabledAlertFailure</td>"
  puts $ResultsFile "            <td ${DisabledAlertErrorClass}>$DisabledAlertError</td>"
  puts $ResultsFile "            <td ${DisabledAlertWarningClass}>$DisabledAlertWarning</td>"
  puts $ResultsFile "        </tr>"
}

proc MergeTestCaseResults { TestCases } {

  set TestName             Merged
  set Status               PASSED
  set Goal                 0
  set Passed               0
  set PassedReq            0
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
    set CurPassed               [dict get $ResultsDict  Passed]
    set CurPassedReq        [expr {$CurPassed < $CurGoal ? $CurPassed : $CurGoal}]
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
    set PassedReq           [expr {$PassedReq  + $CurPassedReq}]
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
  
  return "TestName Merged Status $Status Results { \
    Goal $Goal PassedReq $PassedReq Passed $Passed Errors $Errors Checked $Checked \
    AlertCount {Failure $AlertFailure Error $AlertError Warning $AlertWarning} \
    DisabledAlertCount {Failure $DisabledAlertFailure Error $DisabledAlertError Warning $DisabledAlertWarning} }"
}

proc RequirementsTableFooter {} {
  variable ResultsFile

  puts $ResultsFile "      </tbody>"
  puts $ResultsFile "    </table>"
  puts $ResultsFile "  </div>"
  puts $ResultsFile "</main>"
  puts $ResultsFile "<footer>"
  puts $ResultsFile "  <hr />"
	puts $ResultsFile "  <p class=\"generated-by-osvvm\">Generated by OSVVM-Scripts ${::osvvm::OsvvmVersion} on [clock format [clock seconds] -format {%Y-%m-%d - %H:%M:%S (%Z)}].</p>"
  puts $ResultsFile "</footer>"
  puts $ResultsFile "</body>"
  puts $ResultsFile "</html>"
}