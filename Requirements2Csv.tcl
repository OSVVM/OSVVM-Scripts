#  File Name:         Requirements2Csv.tcl
#  Purpose:           Create HTML for Requirements
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Visible externally:  Requirements2Csv
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

proc Requirements2Csv {RequirementsYamlFile} {
  variable ResultsFile

  if {[file exists $RequirementsYamlFile]} {
    set FileRoot [file rootname $RequirementsYamlFile]
    set CsvFileName ${FileRoot}.csv
    set ResultsFile [open ${CsvFileName} w]
    set ReportName [regsub {_req} [file tail $FileRoot] ""] 
    set ErrorCode [catch {LocalRequirements2Csv $RequirementsYamlFile $ReportName} errmsg]
    close $ResultsFile

    if {$ErrorCode} {
      CallbackOnError_AnyReport "Requirements2Csv" "RequirementsYamlFile: $RequirementsYamlFile" $errmsg
    }
  }
}


proc LocalRequirements2Csv {RequirementsYamlFile ReportName} {
  variable ResultsFile

  set Requirements2Dict [::yaml::yaml2dict -file ${RequirementsYamlFile}]

#  CSV only for merged Requirements which are already sorted  
#  set Requirements2Dict [lsort -index 1 $UnsortedRequirements2Dict]
    
  foreach item $Requirements2Dict {
    set Requirement [dict get $item Requirement]
    set TestCases [dict get $item TestCases]
    set NumTestCases [llength $TestCases]
    if {$NumTestCases == 1} {
      set TestCase [lindex $TestCases 0]
      WriteOneRequirementCsv $TestCase $Requirement
    } else {
      WriteMergeTestCaseCsv $TestCases $Requirement
    }
  }  
  
}


proc WriteOneRequirementCsv {TestCase {Requirement ""}} {
  variable ResultsFile
 
  set TestName             [dict get $TestCase  TestName]
  set Status               [dict get $TestCase  Status]
  set ResultsDict          [dict get $TestCase  Results]
  set Goal                 [dict get $ResultsDict  Goal]
  set Passed               [dict get $ResultsDict  Passed]
  set TotalErrors          [dict get $ResultsDict  Errors]
  set Checked              [dict get $ResultsDict  Checked]
  
  set AlertCount           [dict get $ResultsDict        AlertCount]
  set AlertFailure         [dict get $AlertCount         Failure]
  set AlertError           [dict get $AlertCount         Error]
  set AlertWarning         [dict get $AlertCount         Warning]
  set DisabledAlertCount   [dict get $ResultsDict        DisabledAlertCount]
  set DisabledAlertFailure [dict get $DisabledAlertCount Failure]
  set DisabledAlertError   [dict get $DisabledAlertCount Error]
  set DisabledAlertWarning [dict get $DisabledAlertCount Warning]   

  set Failures         [expr {$AlertFailure   +  $DisabledAlertFailure}] 
  set Errors           [expr {$AlertError     +  $DisabledAlertError  }] 
  set Warnings         [expr {$AlertWarning   +  $DisabledAlertWarning}] 
  
  puts $ResultsFile "$Requirement, $Goal, $Passed, $TotalErrors, $Failures, $Errors, $Warnings, $Checked"
}

proc WriteMergeTestCaseCsv { TestCases {Requirement ""}} {
  variable ResultsFile

  set TestName             Merged
  set Status               PASSED
  set Goal                 0
  set Passed               0
  set TotalErrors          0
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
    set TotalErrors          [expr {$TotalErrors  + $CurErrors}]
    set Checked              [expr {$Checked + $CurChecked}]

    set AlertFailure         [expr {$AlertFailure + $CurAlertFailure}]
    set AlertError           [expr {$AlertError   + $CurAlertError}]
    set AlertWarning         [expr {$AlertWarning + $CurAlertWarning}]
    set DisabledAlertFailure [expr {$DisabledAlertFailure + $CurDisabledAlertFailure}]
    set DisabledAlertError   [expr {$DisabledAlertError   + $CurDisabledAlertError}]
    set DisabledAlertWarning [expr {$DisabledAlertWarning + $CurDisabledAlertWarning}]
  }
  
  set Failures         [expr {$AlertFailure   +  $DisabledAlertFailure}] 
  set Errors           [expr {$AlertError     +  $DisabledAlertError  }] 
  set Warnings         [expr {$AlertWarning   +  $DisabledAlertWarning}] 
  
  puts $ResultsFile "$Requirement, $Goal, $Passed, $TotalErrors, $Failures, $Errors, $Warnings, $Checked"
}
