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
  # Write the commands sourcing a simulation's user scripts into the simulator's start-up script.
  #  LibraryUnit - Design unit being simulated.
  #
  # Used by the `vendor_simulate` of simulators that start a simulation with a script file (`-do`). Calls
  # `SimulateCreateSubScripts` for the current working directory, then for the current simulation directory and for
  # OSVVM's script directory, each only if it differs from the directories before. The commands are written to the open
  # channel `ScriptFile`.
  #
  # See also: [simulate]
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
  # Write the commands sourcing a simulation's user scripts found in one directory.
  #  LibraryUnit - Design unit being simulated.
  #  Directory   - Directory to search for the scripts.
  #
  # Writes a `source` command into `ScriptFile` for each of these files that exists in $Directory, in this order:
  #
  # - `<ToolVendor>.tcl`
  # - `<ToolName>.tcl`
  # - `wave.do`, unless the simulator runs without GUI (`NoGui`)
  # - `<LibraryUnit>.tcl`
  # - `<LibraryUnit>_<ToolName>.tcl`
  # - `<TestCaseName>.tcl` and `<TestCaseName>_<ToolName>.tcl`, if the test case name differs from $LibraryUnit
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
  # Write the command sourcing a waveform script into the simulator's start-up script, if the file exists.
  #  ScriptToRun - Path of the waveform script, usually `wave.do`.
  #  LibraryUnit - Design unit being simulated.
  #
  # The written command catches an error of the waveform script and calls `CallbackOnError_WaveDo`, so a broken
  # waveform script doesn't stop the simulation.
  variable ScriptFile
  
  if {[file exists $ScriptToRun]} {
    puts $ScriptFile  "  if {\[catch {source $ScriptToRun} errorMsg\]} {"
    puts $ScriptFile  "    CallbackOnError_WaveDo \$errorMsg \$::errorInfo [file dirname $ScriptToRun] $LibraryUnit" 
    puts $ScriptFile  "  }"
  }
}

proc ScriptCreateIfFileExists {ScriptToRun} {
  # Write the command sourcing a script into the simulator's start-up script, if the file exists.
  #  ScriptToRun - Path of the script.
  #
  # Writes `source <ScriptToRun>` into the open channel `ScriptFile`.
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
  # Source a simulation's user scripts.
  #  LibraryUnit - Design unit being simulated.
  #
  # Used by the `vendor_simulate` of simulators that run the simulation from the OSVVM script environment. Calls
  # `SimulateRunSubScripts` for the current working directory, then for the current simulation directory and for OSVVM's
  # script directory, each only if it differs from the directories before.
  #
  # See also: [simulate]
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
  # Source a simulation's user scripts found in one directory.
  #  LibraryUnit - Design unit being simulated.
  #  Directory   - Directory to search for the scripts.
  #
  # Sources each of these files that exists in $Directory, in this order:
  #
  # - `<ToolVendor>.tcl`
  # - `<ToolName>.tcl`
  # - `wave.do`, unless the simulator runs without GUI (`NoGui`); an error calls `CallbackOnError_WaveDo`
  # - `<LibraryUnit>.tcl` and `<LibraryUnit>_<ToolName>.tcl`
  # - `<TestCaseName>.tcl` and `<TestCaseName>_<ToolName>.tcl`, if the test case name differs from $LibraryUnit
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
  # Source the user scripts of a design unit or test case found in one directory.
  #  TestName  - Name of the design unit or test case.
  #  Directory - Directory to search for the scripts.
  #
  # Sources `<TestName>.tcl`, then `<TestName>_<ToolName>.tcl`, each if it exists in $Directory.
  variable ToolName
  
  RunIfFileExists [file join ${Directory} ${TestName}.tcl]
  RunIfFileExists [file join ${Directory} ${TestName}_${ToolName}.tcl]
}

proc RunIfFileExists {ScriptToRun} {
  # Source a script, if the file exists.
  #  ScriptToRun - Path of the script.
  if {[file exists $ScriptToRun]} {
    source ${ScriptToRun}
  }
}




# Exports - here mainly it is for testing only
namespace export CreateSimulateDoFile


# end namespace ::osvvm
}
