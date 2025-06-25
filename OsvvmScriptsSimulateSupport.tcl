#  File Name:         OsvvmScriptsSimulateSupport.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#
#  Description
#    Tcl procedures that support the OSVVM "simulate" command
#    A slow migragation of procedures from OsvvmScriptsCore (which is way to big)
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
#     6/2025   2025.06    Refactored Simulate Support Scripts from OsvvmScriptsCore.tcl
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2025 by SynthWorks Design Inc.
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


namespace eval ::osvvm {

  variable ScriptFile

# -------------------------------------------------
# SimulateCreateDoFile
#   called in vendor_simulate in "-do file.tcl" simulators
#   Creates a script file that includes files that are found here 
#
proc SimulateCreateDoFile {LibraryUnit} {
  variable  OsvvmScriptDirectory
  variable  CurrentSimulationDirectory
  variable  CurrentWorkingDirectory
  
  set NormalizedSimulationDirectory [file normalize $CurrentSimulationDirectory]
  set NormalizedWorkingDirectory    [file normalize $CurrentWorkingDirectory]
  set NormalizedScriptDirectory     [file normalize $OsvvmScriptDirectory]
  
  SimulateCreateSubScripts ${LibraryUnit} ${CurrentWorkingDirectory}
  if {${NormalizedSimulationDirectory} ne ${NormalizedWorkingDirectory}} {
    SimulateCreateSubScripts ${LibraryUnit} ${CurrentSimulationDirectory}
  }
  if {(${NormalizedScriptDirectory} ne ${NormalizedWorkingDirectory}) && (${NormalizedScriptDirectory} ne ${NormalizedSimulationDirectory})} {
    SimulateCreateSubScripts ${LibraryUnit} ${OsvvmScriptDirectory}
  }
}

proc SimulateCreateSubScripts {LibraryUnit Directory} {
  variable TestCaseName 
  variable ToolVendor 
  variable ToolName 
  variable NoGui 
  
  ScriptCreateIfFileExists [file join ${Directory} ${ToolVendor}.tcl]
  ScriptCreateIfFileExists [file join ${Directory} ${ToolName}.tcl]
  if {! $NoGui} {
    ScriptCreateIfWaveDoExists [file join ${Directory} wave.do] $LibraryUnit
  }
  ScriptCreateIfFileExists [file join ${Directory} ${LibraryUnit}.tcl]
  ScriptCreateIfFileExists [file join ${Directory} ${LibraryUnit}_${ToolName}.tcl]
  if {$TestCaseName ne $LibraryUnit} {
    ScriptCreateIfFileExists [file join ${Directory} ${TestCaseName}.tcl]
    ScriptCreateIfFileExists [file join ${Directory} ${TestCaseName}_${ToolName}.tcl]
  }
}

proc ScriptCreateIfWaveDoExists {ScriptToRun LibraryUnit} {
  variable ScriptFile
  
  if {[file exists $ScriptToRun]} {
    puts $ScriptFile  "  if {[catch {source $ScriptToRun} errorMsg]} {"
    puts $ScriptFile  "    CallbackOnError_WaveDo \$errorMsg \$::errorInfo [file dirname $ScriptToRun] $LibraryUnit" 
    puts $ScriptFile  "  }"
  }
}

proc ScriptCreateIfFileExists {ScriptToRun} {
  variable ScriptFile

  if {[file exists $ScriptToRun]} {
    puts $ScriptFile  "  source ${ScriptToRun}"
  }
}


# -------------------------------------------------
# SimulateRunScripts - 
#   called from vendor_simulate of command line based simulators
#   Runs the script files that are found here as simulate is running
#
proc SimulateRunScripts {LibraryUnit} {
  variable  OsvvmScriptDirectory
  variable  CurrentSimulationDirectory
  variable  CurrentWorkingDirectory
  
  set NormalizedSimulationDirectory [file normalize $CurrentSimulationDirectory]
  set NormalizedWorkingDirectory    [file normalize $CurrentWorkingDirectory]
  set NormalizedScriptDirectory     [file normalize $OsvvmScriptDirectory]
  
  SimulateRunSubScripts ${LibraryUnit} ${CurrentWorkingDirectory}
  if {${NormalizedSimulationDirectory} ne ${NormalizedWorkingDirectory}} {
    SimulateRunSubScripts ${LibraryUnit} ${CurrentSimulationDirectory}
  }
  if {(${NormalizedScriptDirectory} ne ${NormalizedWorkingDirectory}) && (${NormalizedScriptDirectory} ne ${NormalizedSimulationDirectory})} {
    SimulateRunSubScripts ${LibraryUnit} ${OsvvmScriptDirectory}
  }
}

proc SimulateRunSubScripts {LibraryUnit Directory} {
  variable TestCaseName 
  variable ToolVendor 
  variable ToolName 
  variable NoGui 
  
  RunIfFileExists [file join ${Directory} ${ToolVendor}.tcl]
  RunIfFileExists [file join ${Directory} ${ToolName}.tcl]
  if {! $NoGui} {
    if {[catch {RunIfFileExists [file join ${Directory} wave.do]} errorMsg]} {
      CallbackOnError_WaveDo $errorMsg $::errorInfo $Directory $LibraryUnit  
    }
  }
  SimulateRunDesignScripts ${LibraryUnit} ${Directory}
  if {$TestCaseName ne $LibraryUnit} {
    SimulateRunDesignScripts ${TestCaseName} ${Directory}
  }
}

proc SimulateRunDesignScripts {TestName Directory} {
  variable ToolName
  
  RunIfFileExists [file join ${Directory} ${TestName}.tcl]
  RunIfFileExists [file join ${Directory} ${TestName}_${ToolName}.tcl]
}

proc RunIfFileExists {ScriptToRun} {
  if {[file exists $ScriptToRun]} {
    source ${ScriptToRun}
  }
}




# Exports - here mainly it is for testing only
namespace export CreateSimulateDoFile


# end namespace ::osvvm
}
