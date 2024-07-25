#  File Name:         VendorScripts_VCS.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Tcl procedures with the intent of making running 
#    compiling and simulations tool independent
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
#     7/2024   2024.07    Updated ToolVersion to run vhdlan 
#     5/2024   2024.05    Added ToolVersion variable 
#    12/2022   2022.12    Updated StartTranscript, StopTranscript, Analyze, Simulate
#    05/2022   2022.05    Updated naming
#     2/2022   2022.02    Added template of procedures needed for coverage support
#    12/2021   2021.12    Updated to use relative paths.
#     9/2021   2021.09    Created from VendorScripts_xxx.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2022 by SynthWorks Design Inc.  
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


# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "simulator"
  variable ToolVendor  "Synopsys"
  variable ToolName    "VCS"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 
#  variable ToolNameVersion "${ToolName}-T2022.06"
#  variable ToolVersion "T2022.06"
  variable ToolVersion [regsub {vhdlan.*: } [exec vhdlan -V] ""]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscript
#

# #
# #  Comment out these if TCL version is >= 8.6
# #
# proc vendor_StartTranscript {FileName} {
# }
# 
# proc vendor_StopTranscript {FileName} {
# }

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {vhdlan|vcs|simv} $LineOfText] 
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#    set defaults here
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
#    set defaults here
}


# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    puts "file mkdir    ${PathAndLib}"
          file mkdir    ${PathAndLib}/64
  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
}

# -------------------------------------------------
proc CreateToolSetup {} {
  variable LibraryList
  
  set SetupFile [open "synopsys_sim.setup" w]
  puts $SetupFile "ASSERT_STOP=FAILURE" 
  
  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lreplace $item 0 0]
    puts $SetupFile "${LibraryName} : ${PathToLib}/${LibraryName}"
  }
  close $SetupFile
}


# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlShortVersion
  variable VhdlLibraryFullPath
#  variable VENDOR_TRANSCRIPT_FILE

  CreateToolSetup

#  set  AnalyzeOptions [concat -full64 -vhdl${VhdlShortVersion} -verbose -nc -work ${LibraryName} {*}${args} ${FileName}]
  set  AnalyzeOptions [concat -full64 -vhdl${VhdlShortVersion} -nc -work ${LibraryName} {*}${args} ${FileName}]
  puts "vhdlan $AnalyzeOptions"
  set AnalyzeErrorCode [catch {exec vhdlan {*}$AnalyzeOptions} AnalyzeErrorMessage]
##    puts "AnalyzeErrorCode $AnalyzeErrorCode" ;# returns 1 on success
  puts "$AnalyzeErrorMessage"
##!! TODO:  Need vhdlan error codes for proper handling
#  if {[catch {exec vhdlan {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
#    PrintWithPrefix "Error:" $AnalyzeErrorMessage
#    error "Failed: analyze $FileName"
#  } else {
#    puts $AnalyzeErrorMessage
#  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
#  Untested branch for Verilog - will need adjustment
   puts "Verilog is not supported for now"
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
#  quit -sim
#  framework.documents.closeall -vhdl
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor
  variable ToolName
#  variable VENDOR_TRANSCRIPT_FILE
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions

#!!TODO:   Where do generics get applied:   {*}${::osvvm::GenericOptions}

  CreateToolSetup

  # Building the Synopsys_run.tcl Script
  set SynFile [open "temp_Synopsys_run.tcl" w]

  # Project Vendor script
  if {[file exists ${OsvvmScriptDirectory}/${ToolVendor}.tcl]} {
    puts  $SynFile "source ${OsvvmScriptDirectory}/${ToolVendor}.tcl"
  }
# Project Simulator Script
  if {[file exists ${OsvvmScriptDirectory}/${ToolName}.tcl]} {
    puts  $SynFile "source ${OsvvmScriptDirectory}/${ToolName}.tcl"
  }
 
### User level settings for simulator in the simulation run directory
# User Vendor script
  if {[file exists ${ToolVendor}.tcl]} {
    puts  $SynFile "source ${ToolVendor}.tcl"
  }
# User Simulator Script
  if {[file exists ${ToolName}.tcl]} {
    puts  $SynFile "source ${ToolName}.tcl"
  }
# User wave.do
  if {[file exists wave.do]} {
    puts  $SynFile "do wave.do"
  }
# User Testbench Script
  if {[file exists ${LibraryUnit}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}.tcl"
  }
# User Testbench + Simulator Script
  if {[file exists ${LibraryUnit}_${ToolName}.tcl]} {
    puts  $SynFile "source ${LibraryUnit}_${ToolName}.tcl"
  }
  puts  $SynFile "run" 
  
  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
#   puts $RunFile "Save Coverage Information Command Goes here"
  }
  
  puts  $SynFile "quit" 
  close $SynFile

  if {$::osvvm::NoGui || !($::osvvm::Debug)} {
    set DebugOptions ""
  } else {
    set DebugOptions "-debug_access+all"
  }

  set ElaborateOptions [concat -full64 -time $SimulateTimeUnits ${DebugOptions} {*}${ExtendedElaborateOptions} ${LibraryName}.${LibraryUnit}]
  puts "vcs ${ElaborateOptions}" 
  set VcsErrorCode [catch {exec vcs {*}${ElaborateOptions}} SimulateErrorMessage]
#  puts "VcsErrorCode $VcsErrorCode" ;# returns 1 on success
  puts "$SimulateErrorMessage" 
##!! TODO:  Need vcs error codes for proper handling
#  if { [catch {exec vcs {*}${ElaborateOptions}} SimulateErrorMessage]} { 
#    PrintWithPrefix "Error:" $SimulateErrorMessage
#    error "Failed: simulate $LibraryUnit during vcs"
#  } else {
#    puts $SimulateErrorMessage
#  }

  if {$::osvvm::GenericDict ne ""} {
    set SynopsysGenericOptions "-lca -g synopsys_generics.txt"
    CreateGenericFile ${::osvvm::GenericDict}
  } else {
    set SynopsysGenericOptions ""
  }
  
  set SimulateOptions [concat {*}${ExtendedRunOptions} {*}${SynopsysGenericOptions} -ucli -do temp_Synopsys_run.tcl]
  puts "./simv ${SimulateOptions}" 
  set SimVErrorCode [catch {exec ./simv {*}${SimulateOptions}} SimulateErrorMessage]
#  puts "SimVErrorCode $SimVErrorCode" ; # returns 0 on success
  puts "$SimulateErrorMessage" 

##!! TODO:  Need simv error codes
#  if { [catch {exec ./simv {*}${SimulateOptions}} SimulateErrorMessage]} { 
#    PrintWithPrefix "Error:" $SimulateErrorMessage
#    error "Failed: simulate $LibraryUnit during simv"
#  } else {
#    puts $SimulateErrorMessage
#  }
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  # Not used.  gvalue requires integer and real number values
  return "-gv ${Name}=${Value} "
}

# -------------------------------------------------
proc CreateGenericFile {GenericDict} {

  set GenericsFile [open "synopsys_generics.txt" w]
  foreach {GenericName GenericValue} $GenericDict {
    # cannot do /$LibraryUnit/$GenericName as LibraryUnit may be a configuration name
    puts $GenericsFile "assign ${GenericValue} ${GenericName}"
  }
  close $GenericsFile
}



# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
#  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
#  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
#  if {$CovFiles ne ""} {
#    acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]
#  }
}

proc vendor_ReportCodeCoverage {TestSuiteName ResultsDirectory} { 
#  acdb report -html -i ${ResultsDirectory}/${TestSuiteName}.acdb -o ${ResultsDirectory}/${TestSuiteName}_code_cov.html
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}
