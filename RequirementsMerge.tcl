#  File Name:         MergeRequirements.tcl
#  Purpose:           Merge OSVVM YAML requirements
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Visible externally:  MergeRequirements
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

proc MergeRequirements {SourceDirectory ResultsFileName} {
  # Merge the requirements YAML files of a directory into one file.
  #  SourceDirectory - Directory with the requirements files `*_req.yml`.
  #  ResultsFileName - Merged requirements YAML file to write.
  #
  # Does nothing if the directory has no requirements file. The merged file lists each requirement once, with the test
  # cases of all files (`LocalMergeRequirements`). On an error, the file is closed and `CallbackOnError_AnyReport` is
  # called.
  #
  # Called for each test suite, merging its test cases, and at the end of a [build], merging the test suites.
  #
  # See also: [Requirements2Html] [Requirements2Csv] [RequirementsCsv2Yaml]
  variable ResultsFile

  set ReqFiles [glob -nocomplain [file join ${SourceDirectory} *_req.yml]]
  if {$ReqFiles ne ""} {
    set ResultsFile  [open $ResultsFileName w]
    set ErrorCode [catch {LocalMergeRequirements $ReqFiles} errmsg]
    close $ResultsFile
    if {$ErrorCode} {
      CallbackOnError_AnyReport "MergeRequirements" "SourceDirectory: $SourceDirectory, ResultsFileName: $ResultsFileName" $errmsg
    }
  }
}

proc LocalMergeRequirements {ReqFiles} {
  # Write the requirements of several files, sorted and grouped by requirement.
  #  ReqFiles - Requirements YAML files to merge.
  #
  # Errors are handled by [MergeRequirements].
  variable ResultsFile

  set ReqDict ""
  foreach ReqFile ${ReqFiles} {
    set ReqDict [concat $ReqDict [::yaml::yaml2dict -file ${ReqFile}]]
  }

  # Sort based on test name - must sort here so can combine TestCases
  set SortedReqDict [lsort -index 1 $ReqDict]

  set PreviousReq ""
  foreach item $SortedReqDict {
    set CurrentReq [dict get $item Requirement]
    if {$CurrentReq ne $PreviousReq} {
      puts $ResultsFile "- Requirement: $CurrentReq"
      puts $ResultsFile "  TestCases:"
    }
    set PreviousReq $CurrentReq
    set TestCases [dict get $item TestCases]
    foreach TestCase $TestCases {
      puts $ResultsFile "  - TestName: [dict get $TestCase TestName]"
      puts $ResultsFile "    Status: [dict get $TestCase Status]"
      if {[dict exists $TestCase FromSpecification] } {
        puts $ResultsFile "    FromSpecification: \"true\""
      }
      set Results [dict get $TestCase Results]
      puts $ResultsFile "    Results: {\
        Goal: [dict get $Results Goal],\
        Passed: [dict get $Results Passed],\
        Errors: [dict get $Results Errors],\
        Checked: [dict get $Results Checked],\
        AlertCount: [WriteYamlAlertCount [dict get $Results AlertCount]],\
        DisabledAlertCount: [WriteYamlAlertCount [dict get $Results DisabledAlertCount]]}"
    }
  }
}

proc WriteYamlAlertCount {AlertCount} {
  # Format alert counts as YAML flow mapping.
  #  AlertCount - Alert counts with `Failure`, `Error` and `Warning`.
  #
  # Returns the counts as `Failure: <n>, Error: <n>, Warning: <n>` in a YAML flow mapping.
  return "{Failure: [dict get $AlertCount Failure], \
           Error: [dict get $AlertCount Error], \
           Warning: [dict get $AlertCount Warning]}"
}
