#  File Name:         ReportBuildDict2Junit.tcl
#  Purpose:           Convert OSVVM YAML build reports to JUnit XML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM Build Dictionary into JUnit XML
#    Visible externally:  ReportBuildDict2Junit
#    Must call ReportBuildYaml2Dict first.
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
#    07/2024   2024.07    Reporting for Affirm Counts and Generics
#    05/2024   2024.05    Refactored. 
#    04/2024   2024.04    Updated report formatting
#    12/2022   2022.12    Refactored to only use static OSVVM information
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

# -------------------------------------------------
# ReportBuildDict2Junit
#
proc ReportBuildDict2Junit {} {
  variable ResultsFile
  variable ReportFileRoot

  set ResultsFile [open ${ReportFileRoot}.xml w]

  set ErrorCode [catch {LocalReportBuildDict2Junit} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_ReportBuildDict2Junit ${ReportFileRoot}.xml $errmsg
  }
}

# -------------------------------------------------
# LocalReportBuildDict2Junit
#
proc LocalReportBuildDict2Junit {} {
  variable ResultsFile
  variable BuildDict
  variable TestSuiteSummaryArrayOfDictionaries
  variable HaveTestSuites
  
  CreateJunitSummary $BuildDict 

  if { $HaveTestSuites } {
    CreateJunitTestSuiteSummaries $BuildDict $TestSuiteSummaryArrayOfDictionaries 
  }
  puts $ResultsFile "</testsuites>"
}

# -------------------------------------------------
# CreateJunitSummary
#
proc CreateJunitSummary {TestDict} {
  variable ResultsFile
  variable ReportBuildName

  variable ReportStartTime
  variable ReportIsoStartTime
  variable ElapsedTimeSeconds
  variable OsvvmVersion
  variable ReportSimulator
  variable ReportSimulatorVersion

  variable TestCasesPassed 
  variable TestCasesFailed 
  variable TestCasesSkipped 
  variable TestCasesRun 

  # Print Initial Build Summary
  #  <testsuites name="Build" time="25.0" tests="20" failures="5" errors="0" skipped="2">
  puts $ResultsFile "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
  puts $ResultsFile "<testsuites "
  puts $ResultsFile "   name=\"$ReportBuildName\""
#  puts $ResultsFile "   timestamp=\"[dict get $BuildInfo Date]\""
  puts $ResultsFile "   timestamp=\"$ReportIsoStartTime\""
#  puts $ResultsFile "   id=\"[dict get $BuildInfo Version]\""
  puts $ResultsFile "   time=\"$ElapsedTimeSeconds\""
  puts $ResultsFile "   tests=\"$TestCasesRun\""
  puts $ResultsFile "   failures=\"$TestCasesFailed\""
  puts $ResultsFile "   errors=\"0\""
  puts $ResultsFile "   skipped=\"$TestCasesSkipped\""
  puts $ResultsFile ">"
  puts $ResultsFile "<properties> "
  puts $ResultsFile "  <property name=\"OsvvmVersion\" value=\"$OsvvmVersion\" /> "
  puts $ResultsFile "  <property name=\"Simulator\" value=\"$ReportSimulator\" /> "
  puts $ResultsFile "  <property name=\"SimulatorVersion\" value=\"$ReportSimulatorVersion\" /> "

  puts $ResultsFile "</properties> "
  
}

# -------------------------------------------------
# CreateJunitTestSuiteSummaries
#
proc CreateJunitTestSuiteSummaries {TestDict TestSuiteSummary } {
  variable ResultsFile
  variable TestSuiteName
  
  set Index 0
  foreach TestSuite [dict get $TestDict TestSuites] {
    CreateJunitTestCaseSummary [lindex $TestSuiteSummary $Index]
    incr Index 
    
    foreach TestCase [dict get $TestSuite TestCases] {
    # <testcase classname="S3.T1" name="S3.T1" time="0.3"><failure message="Failed" /></testcase>
    # <testcase classname="S3.T2" name="S3.T2" time="0.3"></testcase>
    # <testcase classname="S3.T3" name="S3.T3" time="0.3"><skipped message="We don't do this either" /></testcase>

      set TestName    [dict get $TestCase TestCaseName]
      
      if { [dict exists $TestCase Results] } { 
        set TestResults [dict get $TestCase Results]
        if { [dict exists $TestResults AffirmCount] } {
          set AffirmCount [dict get $TestResults AffirmCount]
        } else {
          set AffirmCount 0
        }
        set TestStatus  [dict get $TestCase Status]
        set VhdlName    [dict get $TestCase Name]
        if { $TestStatus ne "SKIPPED" } {
          if {[dict exists $TestCase ElapsedTime]} {
            set ElapsedTime [dict get $TestCase ElapsedTime]
          } else {
            set ElapsedTime missing
          }
        } else {
          set ElapsedTime 0
        } 
        set Reason "Test Case Error"
      } else {
        set TestStatus  "FAILED"
        set VhdlName    $TestName
        set ElapsedTime 0
        set AffirmCount 0
        set Reason "Test did not run"
      }
      
      if { ${TestName} ne ${VhdlName} } {
        set TestStatus "FAILED"
        set Reason "Name mismatch"
      }
      if { [dict exists $TestCase TestCaseFileName] } { 
        set ResolvedTestName [dict get $TestCase TestCaseFileName]
      } else {
        set ResolvedTestName $TestName
      }

      puts $ResultsFile "<testcase "
      puts $ResultsFile "   name=\"$ResolvedTestName\""
#      puts $ResultsFile "   classname=\"$VhdlName\""
      puts $ResultsFile "   classname=\"$TestSuiteName\""
      puts $ResultsFile "   assertions=\"$AffirmCount\""
      puts $ResultsFile "   time=\"$ElapsedTime\""
      puts $ResultsFile ">"
      
      if { $TestStatus eq "FAILED" } {
        puts $ResultsFile "<failure message=\"$Reason\">$Reason</failure>"
      
      } elseif { $TestStatus eq "SKIPPED" } {
        set Reason [dict get $TestResults Reason]
        puts $ResultsFile "<skipped message=\"$Reason\">$Reason</skipped>"
      }
      
      if { [dict exists $TestCase Generics] } { 
        set TestCaseGenerics [dict get $TestCase Generics]
        if {${TestCaseGenerics} ne ""} {
          puts $ResultsFile "<properties> "
          foreach {GenericName GenericValue} $TestCaseGenerics {
            puts $ResultsFile "  <property name=\"generic\" value=\"${GenericName}=${GenericValue}\" /> "
          }
          puts $ResultsFile "</properties> "
        }
      }
      puts $ResultsFile "</testcase>"
    }
    puts $ResultsFile "</testsuite>"
  }
}

# -------------------------------------------------
# CreateJunitTestCaseSummary
#
proc CreateJunitTestCaseSummary { TestSuiteSummaryDict } {
  variable ResultsFile
  variable TestSuiteName

  # Print testsuite information
  #  <testsuite name="Suite1" errors="0" failures="3" skipped="0" tests="10" hostname="seven">
  set SuitePassed   [dict get $TestSuiteSummaryDict PASSED]
  set SuiteFailed   [dict get $TestSuiteSummaryDict FAILED]
  set SuiteSkipped  [dict get $TestSuiteSummaryDict SKIPPED]
  set TestSuiteName [dict get $TestSuiteSummaryDict Name]
  puts $ResultsFile "<testsuite "
  puts $ResultsFile "   name=\"$TestSuiteName\""
  puts $ResultsFile "   time=\"[dict get $TestSuiteSummaryDict ElapsedTime]\""
  puts $ResultsFile "   tests=\"[expr {$SuitePassed + $SuiteFailed + $SuiteSkipped}]\""
  puts $ResultsFile "   failures=\"$SuiteFailed\""
  puts $ResultsFile "   errors=\"0\""
  puts $ResultsFile "   skipped=\"$SuiteSkipped\""
#  puts $ResultsFile "   hostname=\"$env(HOSTNAME)\""
  puts $ResultsFile ">"
}

# -------------------------------------------------
# Report2Junit - provided for backward compatibility
#
proc Report2Junit {BuildYamlFile} {
  ReportBuildYaml2Dict ${BuildYamlFile}
  ReportBuildDict2Junit
}
