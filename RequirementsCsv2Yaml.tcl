#  File Name:         RequirementsCsv2Yaml.tcl
#  Purpose:           Merge OSVVM YAML requirements
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Visible externally:  RequirementsCsv2Yaml
#
#  Developed by:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        OSVVM Methodology and Model Library
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Version    Description
#    2026.07    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2026 by SynthWorks Design Inc.
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

package require csv

proc RequirementsCsv2Yaml {RequirementsCsvFileName TargetYamlFileName {HeaderList {}}} {
  variable RequirementsFile
  variable TargetYamlFile
  variable FileName [file tail $RequirementsCsvFileName]

  set RequirementsFile   [open $RequirementsCsvFileName r]
  set TargetYamlFile     [open $TargetYamlFileName w]
  set ErrorCode [catch {LocalRequirementsCsv2Yaml $HeaderList} errmsg]
  close $RequirementsFile
  close $TargetYamlFile
  if {$ErrorCode} {
    ::osvvm::CallbackOnError_AnyReport "RequirementsCsv2Yaml" "RequirementsCsvFileName: $RequirementsCsvFileName, TargetYamlFileName: $TargetYamlFileName" $errmsg
  }
}

proc LocalRequirementsCsv2Yaml {{HeaderList {}}} {
  variable RequirementsFile
  variable TargetYamlFile

  if {[llength $HeaderList] == 0} {
    gets $RequirementsFile line
    set HeaderList [::csv::split $line]
#    set HeaderList [lmap item $RawHeaderList {string trim $item}]
  }

  set DefaultRequirementsDict {Requirement NotValid Description "" Status PASSED \
      Goal 1 Passed 0 Errors 0 Checked 0}

  while {[gets $RequirementsFile line] >= 0} {
    set RequirementList [::csv::split $line]

    set ReadRequirementsDict [dict create]

    # Map headers to matching values
    foreach header $HeaderList value $RequirementList {
      dict set ReadRequirementsDict $header $value
    }

    set RequirementElementDict [dict merge $DefaultRequirementsDict $ReadRequirementsDict]

    RequirementsWriteOneDict2Yaml $RequirementElementDict
  }
}

proc RequirementsWriteOneDict2Yaml {ReqDict} {
  variable TargetYamlFile
  variable FileName

  puts $TargetYamlFile "- Requirement: [dict get $ReqDict Requirement]"
  puts $TargetYamlFile "  Description: [dict get $ReqDict Description]"
  puts $TargetYamlFile "  TestCases:"
  puts $TargetYamlFile "  - TestName:  $FileName"
  puts $TargetYamlFile "    Status:    [dict get $ReqDict Status]"
  puts $TargetYamlFile "    FromSpecification: \"true\""
  puts $TargetYamlFile "    Results: {\
    Goal:    [dict get $ReqDict Goal],\
    Passed:  [dict get $ReqDict Passed],\
    Errors:  [dict get $ReqDict Errors],\
    Checked: [dict get $ReqDict Checked],\
    AlertCount: {Failure: 0, Error: 0, Warning: 0},\
    DisabledAlertCount: {Failure: 0, Error: 0, Warning: 0}}"
}
