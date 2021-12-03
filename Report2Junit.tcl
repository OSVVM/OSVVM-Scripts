#  File Name:         Report2Junit.tcl
#  Purpose:           Convert OSVVM YAML build reports to JUnit XML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM YAML build reports to JUnit XML
#    Visible externally:  Report2Junit
#
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

proc Report2Junit {ReportFile} {
  variable ResultsFile
  variable ReportTestSuiteSummary
  variable HaveTestSuites

  set FileName  [file rootname ${ReportFile}].xml
  set TestDict [::yaml::yaml2dict -file ${ReportFile}]
  set VersionNum  [dict get $TestDict Version]

  set HaveTestSuites [dict exists $TestDict TestSuites]
  if { $HaveTestSuites } {

    set ResultsFile [open ${FileName} w]

    JunitCreateSummary $TestDict 
  
    JunitTestSuites $TestDict $ReportTestSuiteSummary 
    
    puts $ResultsFile "</testsuites>"
    close $ResultsFile
  }
}

proc JunitCreateSummary {TestDict} {
  variable ResultsFile
  variable ReportTestSuiteSummary

  if {[info exists ReportTestSuiteSummary]} {
    unset ReportTestSuiteSummary
  }
  if {[info exists BuildSummary]} {
    unset BuildSummary
  }

  set BuildStatus "PASSED"
  set TestCasesPassed 0
  set TestCasesFailed 0
  set TestCasesSkipped 0
  set TestCasesRun 0
  

  foreach TestSuite [dict get $TestDict TestSuites] {
    set SuitePassed 0
    set SuiteFailed 0
    set SuiteSkipped 0
    set SuiteReqPassed 0
    set SuiteReqGoal 0
    set SuiteDisabledAlerts 0
    set SuiteName [dict get $TestSuite Name]
    foreach TestCase [dict get $TestSuite TestCases] {
      set TestName    [dict get $TestCase TestCaseName]
      if { [dict exists $TestCase Results] } { 
        set TestStatus  [dict get $TestCase Status]
        set TestResults [dict get $TestCase Results]
        if { $TestStatus ne "SKIPPED" } {
          set TestReqGoal   [dict get $TestResults RequirementsGoal]
          set TestReqPassed [dict get $TestResults RequirementsPassed]
#            set SuiteDisabledAlerts [expr $SuiteDisabledAlerts + [SumAlertCount [dict get $TestResults DisabledAlertCount]]]
        } else {
          set TestReqGoal   0
          set TestReqPassed 0
        }
        set VhdlName [dict get $TestCase Name]
      } else {
        set TestStatus  "FAILED"
        set TestReqGoal   0
        set TestReqPassed 0
        set VhdlName $TestName
      }
      if { $TestStatus eq "SKIPPED" } {
        incr SuiteSkipped
        incr TestCasesSkipped
      } else {
        incr TestCasesRun
        if { ${TestName} ne ${VhdlName} } {
          incr SuiteFailed
          incr TestCasesFailed
        } elseif { $TestStatus eq "PASSED" } {
          incr SuitePassed
          incr TestCasesPassed
          if { $TestReqGoal > 0 } {
            incr SuiteReqGoal
            if { $TestReqPassed >= $TestReqGoal } {
              incr SuiteReqPassed
            }
          }
        } else {
          incr SuiteFailed
          incr TestCasesFailed
        }
      }
    }
    if {[dict exists $TestSuite ElapsedTime]} {
      set SuiteElapsedTime [dict get $TestSuite ElapsedTime]
    } else {
      set SuiteElapsedTime 0
    }
    if { $SuitePassed > 0 && $SuiteFailed == 0 } {
      set SuiteStatus "PASSED"
    } else {
      set SuiteStatus "FAILED"
      set BuildStatus "FAILED"
    }
    set SuiteDict [dict create Name       $SuiteName]
    dict append SuiteDict Status          $SuiteStatus
    dict append SuiteDict PASSED          $SuitePassed
    dict append SuiteDict FAILED          $SuiteFailed
    dict append SuiteDict SKIPPED         $SuiteSkipped
    dict append SuiteDict ReqPassed       $SuiteReqPassed
    dict append SuiteDict ReqGoal         $SuiteReqGoal
    dict append SuiteDict DisabledAlerts  $SuiteDisabledAlerts
    dict append SuiteDict ElapsedTime     $SuiteElapsedTime
#    lappend ReportTestSuiteSummary [dict create Name $SuiteName Status $SuiteStatus Passed $SuitePassed Failed $SuiteFailed Skipped $SuiteSkipped ReqPassed $SuiteReqPassed ReqGoal $SuiteReqGoal]
    lappend ReportTestSuiteSummary $SuiteDict
  }
  # Print Initial Build Summary
  #  <testsuites name="Build" time="25.0" tests="20" failures="5" errors="0" skipped="2">
  set BuildInfo [dict get $TestDict Build]
  set BuildRun [dict get $TestDict Run]
  puts $ResultsFile "<testsuites "
  puts $ResultsFile "   name=\"[dict get $BuildInfo Name]\""
  puts $ResultsFile "   timestamp=\"[dict get $BuildInfo Date]\""
  puts $ResultsFile "   id=\"[dict get $BuildInfo Version]\""
  puts $ResultsFile "   time=\"[dict get $BuildRun Elapsed]\""
  puts $ResultsFile "   tests=\"$TestCasesRun\""
  puts $ResultsFile "   failures=\"$TestCasesFailed\""
  puts $ResultsFile "   errors=\"0\""
  puts $ResultsFile "   skipped=\"$TestCasesSkipped\""
  puts $ResultsFile ">"
}


proc JunitTestSuiteInfo { TestSuiteSummaryDict } {
  variable ResultsFile

  # Print testsuite information
  #  <testsuite name="Suite1" errors="0" failures="3" skipped="0" tests="10" hostname="seven">
  set SuitePassed  [dict get $TestSuiteSummaryDict PASSED]
  set SuiteFailed  [dict get $TestSuiteSummaryDict FAILED]
  set SuiteSkipped [dict get $TestSuiteSummaryDict SKIPPED]
  puts $ResultsFile "<testsuite "
  puts $ResultsFile "   name=\"[dict get $TestSuiteSummaryDict Name]\""
  puts $ResultsFile "   time=\"[dict get $TestSuiteSummaryDict ElapsedTime]\""
  puts $ResultsFile "   tests=\"[expr {$SuitePassed + $SuiteFailed + $SuiteSkipped}]\""
  puts $ResultsFile "   failures=\"$SuiteFailed\""
  puts $ResultsFile "   errors=\"0\""
  puts $ResultsFile "   skipped=\"$SuiteSkipped\""
#  puts $ResultsFile "   hostname=\"$env(HOSTNAME)\""
  puts $ResultsFile ">"
}


proc JunitTestSuites {TestDict TestSuiteSummary } {
  variable ResultsFile
  
  set Index 0
  foreach TestSuite [dict get $TestDict TestSuites] {
    JunitTestSuiteInfo [lindex $TestSuiteSummary $Index]
    incr Index 
    
    foreach TestCase [dict get $TestSuite TestCases] {
    # <testcase classname="S3.T1" name="S3.T1" time="0.3"><failure message="Failed" /></testcase>
    # <testcase classname="S3.T2" name="S3.T2" time="0.3"></testcase>
    # <testcase classname="S3.T3" name="S3.T3" time="0.3"><skipped message="We don't do this either" /></testcase>

      set TestName    [dict get $TestCase TestCaseName]
      
      if { [dict exists $TestCase Results] } { 
        set TestResults [dict get $TestCase Results]
        set TestStatus  [dict get $TestCase Status]
        set VhdlName    [dict get $TestCase Name]
        if { $TestStatus ne "SKIPPED" } {
          set ElapsedTime [dict get $TestCase ElapsedTime]
        } else {
          set ElapsedTime 0
        } 
        set Reason "Test Case Error"
      } else {
        set TestStatus  "FAILED"
        set VhdlName    $TestName
        set ElapsedTime 0
        set Reason "Test did not run"
      }
      
      if { ${TestName} ne ${VhdlName} } {
        set TestStatus "FAILED"
        set Reason "Name mismatch"
      }
      
      
      puts $ResultsFile "<testcase "
      puts $ResultsFile "   name=\"$TestName\""
      puts $ResultsFile "   classname=\"$VhdlName\""
      puts $ResultsFile "   time=\"$ElapsedTime\""
      puts $ResultsFile ">"
      
      if { $TestStatus eq "FAILED" } {
        puts $ResultsFile "<failure message=\"$Reason\">$Reason</failure>"
      
      } elseif { $TestStatus eq "SKIPPED" } {
        set Reason [dict get $TestResults Reason]
        puts $ResultsFile "<skipped message=\"$Reason\">$Reason</skipped>"
      }
      puts $ResultsFile "</testcase>"
    }
    puts $ResultsFile "</testsuite>"
  }
}



