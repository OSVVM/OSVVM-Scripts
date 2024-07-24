#  File Name:         ReportBuildYaml2Dict.tcl
#  Purpose:           Convert OSVVM YAML build reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Convert OSVVM YAML build reports to TCL Dictionary
#    Visible externally:  ReportBuildYaml2Dict
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
#    07/2024   2024.07    Handling NOCHECKS as FAIL or PASS.  Naming updates
#    05/2024   2024.05    Refactored. Decoupled.  Yaml = source of information.
#    04/2024   2024.04    Updated report formatting
#    07/2023   2023.07    Updated file handler to search for user defined HTML headers
#    12/2022   2022.12    Refactored to only use static OSVVM information
#    05/2022   2022.05    Updated directory handling
#    02/2022   2022.02    Added links for code coverage.
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021 - 2024 by SynthWorks Design Inc.
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

#  Notes:  
#  The following variables are set by GetPathSettings that read the YAML file
#      Report2HtmlThemeDirectory 
#      Report2BaseDirectory
#      Report2ReportsSubdirectory
#      Report2LogSubdirectory
#      Report2HtmlThemeSourceDirectory
#      Report2RequirementsSubdirectory - value is "" if requirements not used
#      Report2CoverageSubdirectory - value is "" if coverage not used
#

# -------------------------------------------------
# CreateBuildReports
#
proc CreateBuildReports {ReportFile} {
  ReportBuildYaml2Dict ${ReportFile}
  ReportBuildDict2Html
  ReportBuildDict2Junit
}

# -------------------------------------------------
# ReportBuildYaml2Dict
#
proc ReportBuildYaml2Dict {ReportFile} {
  variable ReportFileRoot
  variable ReportBuildName
  variable BuildDict

  # Extract BuildName and HtmlFileName from ReportFile
  set ReportFileRoot  [file rootname $ReportFile]
  set ReportBuildName [file tail $ReportFileRoot]
  
  
  # Read the YAML file into a dictionary
  set BuildDict [::yaml::yaml2dict -file ${ReportFile}]

  # Convert YAML file to HTML & catch results
  set ErrorCode [catch {LocalReportBuildYaml2Dict $BuildDict} errmsg]
  
  if {$ErrorCode} {
    CallbackOnError_ReportBuildYaml2Dict $ReportFile $errmsg
  }
}

# -------------------------------------------------
# LocalReportBuildYaml2Dict
#
proc LocalReportBuildYaml2Dict {BuildDict} {
  variable ReportBuildName
  
  GetOsvvmPathSettings $BuildDict 
  
  ElaborateTestSuites $BuildDict

  GetBuildStatus $BuildDict
  
}

# -------------------------------------------------
# ReportBuildStatus
#
proc ReportBuildStatus {} {
  variable ReportBuildName
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus 
  variable TestCasesPassed 
  variable TestCasesFailed 
  variable TestCasesSkipped 
  variable TestCasesRun 
  
  if {$BuildStatus eq "PASSED"} {
    puts "Build: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount}"
  } else {
    puts "BuildError: ${ReportBuildName} ${BuildStatus},  Passed: ${TestCasesPassed},  Failed: ${TestCasesFailed},  Skipped: ${TestCasesSkipped},  Analyze Errors: ${ReportAnalyzeErrorCount},  Simulate Errors: ${ReportSimulateErrorCount},  Build Error Code: $ReportBuildErrorCode"
  }
}


# -------------------------------------------------
# ElaborateTestSuites
#
proc ElaborateTestSuites {TestDict} {
  # Summary dictionaries
  variable TestSuiteSummaryArrayOfDictionaries ""
  variable HaveTestSuites
  # Detailed Build Status
  variable BuildStatus "PASSED"
  variable TestCasesPassed 0
  variable TestCasesFailed 0
  variable TestCasesSkipped 0
  variable TestCasesRun 0
  
  set HaveTestSuites [dict exists $TestDict TestSuites]

  if { $HaveTestSuites } {
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
            set SuiteDisabledAlerts [expr $SuiteDisabledAlerts + [SumAlertCount [dict get $TestResults DisabledAlertCount]]]
            set VhdlName [dict get $TestCase Name]
          } else {
            set TestReqGoal   0
            set TestReqPassed 0
            set VhdlName $TestName
          }
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
          if { ${TestName} ne ${VhdlName}  } {
            incr SuiteFailed
            incr TestCasesFailed
          } elseif { ($TestStatus eq "PASSED") || (($TestStatus eq "NOCHECKS") && !($::osvvm::FailOnNoChecks)) } {
            incr SuitePassed
            incr TestCasesPassed
            if { $TestReqGoal > 0 } {
              incr SuiteReqGoal
              if { $TestReqPassed >= $TestReqGoal } {
                incr SuiteReqPassed
              }
            }
          } else {
            # TestStatus = FAILED or TIMEOUT
            # TestStatus = NOCHECKS if OsvvmVersionCompatibility is 2024.07 (or later) or
            #    FailOnNoChecks is set to TRUE in OsvvmSettingsLocal.tcl
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
      lappend TestSuiteSummaryArrayOfDictionaries $SuiteDict
    }
  }
}

# -------------------------------------------------
# GetBuildStatus
#
proc GetBuildStatus {TestDict} {
  variable ReportBuildName
  
  variable ReportBuildErrorCode
  variable ReportAnalyzeErrorCount
  variable ReportSimulateErrorCount
  variable BuildStatus 
  variable ReportStartTime
  variable ReportIsoStartTime
  variable ReportFinishTime
  variable ElapsedTimeSeconds
  variable ElapsedTimeSecondsInt
  variable ElapsedTimeHms
  variable ReportSimulator
  variable ReportSimulatorVersion
  variable OsvvmVersion
  variable RequirementsRelativeHtml


  if { [dict exists $TestDict BuildInfo] } {
    set RunInfo   [dict get $TestDict BuildInfo] 
  } else {
    set RunInfo   [dict create BuildErrorCode 1]
  }
  if {[dict exists $RunInfo BuildErrorCode]} {
    set ReportBuildErrorCode [dict get $RunInfo BuildErrorCode]
  } else {
    set ReportBuildErrorCode 1
  }
  if {[dict exists $RunInfo AnalyzeErrorCount]} {
    set ReportAnalyzeErrorCount [dict get $RunInfo AnalyzeErrorCount]
  } else {
    set ReportAnalyzeErrorCount 0
  }
  if {[dict exists $RunInfo SimulateErrorCount]} {
    set ReportSimulateErrorCount [dict get $RunInfo SimulateErrorCount]
  } else {
    set ReportSimulateErrorCount 0
  }
  if {($ReportBuildErrorCode != 0) || $ReportAnalyzeErrorCount || $ReportSimulateErrorCount} {
    set BuildStatus "FAILED"
  }
  
  # Print BuildInfo
  set BuildInfo $RunInfo
  if {[dict exists $RunInfo StartTime]} {
    set ReportIsoStartTime [dict get $RunInfo StartTime]
    set ReportStartTime [IsoToOsvvmTime $ReportIsoStartTime]
  } else {
    set ReportIsoStartTime ""
    set ReportStartTime ""
  } 
  if {[dict exists $RunInfo FinishTime]} {
    set ReportFinishTime [IsoToOsvvmTime [dict get $RunInfo FinishTime]]
  } else {
    set ReportFinishTime ""
  } 

  if {[dict exists $RunInfo Elapsed]} {
    set ElapsedTimeSeconds [dict get $RunInfo Elapsed]
  } else {
    set ElapsedTimeSeconds 0.0
  }
  set ElapsedTimeSecondsInt [expr {round($ElapsedTimeSeconds)}]
  set ElapsedTimeHms     [format %d:%02d:%02d [expr ($ElapsedTimeSecondsInt/(60*60))] [expr (($ElapsedTimeSecondsInt/60)%60)] [expr (${ElapsedTimeSecondsInt}%60)]]

  if {[dict exists $RunInfo Simulator]} {
    set ReportSimulator [dict get $RunInfo Simulator]
  } else {
    set ReportSimulator "Unknown"
  } 
  
  if {[dict exists $RunInfo SimulatorVersion]} {
    set ReportSimulatorVersion [dict get $RunInfo SimulatorVersion]
  } else {
    set ReportSimulatorVersion "Unknown"
  } 

  if {[dict exists $RunInfo OsvvmVersion]} {
    set OsvvmVersion [dict get $RunInfo OsvvmVersion]
  } else {
    set OsvvmVersion ""
  } 

  if {$::osvvm::Report2RequirementsSubdirectory ne ""} {
    set RequirementsRelativeHtml [file join $::osvvm::Report2RequirementsSubdirectory ${ReportBuildName}_req.html]
  } else {
    set RequirementsRelativeHtml ""
  }  
}


# -------------------------------------------------
# IsoToOsvvmTime
#
proc IsoToOsvvmTime {IsoTime} {
  set TimeInSec [clock scan $IsoTime -format {%Y-%m-%dT%H:%M:%S%z} ]
  return [clock format $TimeInSec -format {%Y-%m-%d - %H:%M:%S (%Z)}]
}




