#  File Name:         VendorScripts_Xsim.tcl
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
#    05/2022   2022.05    Updated variable naming 
#     2/2022   2022.02    Added template of procedures needed for coverage support
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
  variable ToolVendor  "Xilinx"
  variable ToolName   "XSIM"
  variable simulator   $ToolName ; # Deprecated 
  variable ToolNameVersion "xsim_22_1"
#   puts $ToolNameVersion


# -------------------------------------------------
# StartTranscript / StopTranscxript
#

# 
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

# With this commented out, it will run the DefaultVendor_StartTranscript
proc vendor_StartTranscript {FileName} {
#  Do nothing
}

proc vendor_StopTranscript {FileName} {
#  Do nothing
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {xvhdl|xelab|xsim} $LineOfText] 
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
#  set PathAndLib ${PathToLib}/${LibraryName}
#
#  if {![file exists ${PathAndLib}]} {
#    puts "file mkdir    ${PathAndLib}"
#    puts "" > ${PathAndLib}
#    eval file mkdir    ${PathAndLib}
#  }
#  if {![file exists ./compile/${LibraryName}.epr]} {
#    puts vmap    $LibraryName  ${PathAndLib}
#    eval vmap    $LibraryName  ${PathAndLib}
#  }
}

proc vendor_LinkLibrary {LibraryName PathToLib} {}
proc vendor_UnlinkLibrary {LibraryName PathToLib} {}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName OptionalCommands} {
  variable VhdlVersion
  variable VhdlLibraryFullPath
  
  set DebugOptions ""
  
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -work ${LibraryName} {*}${OptionalCommands} ${FileName}]
  puts "xvhdl {*}$AnalyzeOptions"
  exec  xvhdl {*}$AnalyzeOptions
}

proc vendor_analyze_verilog {LibraryName FileName OptionalCommands} {
#  Untested branch for Verilog - will need adjustment
   puts "Verilog is not supported for now"
#   eval vlog -work ${LibraryName} ${FileName}
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
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable SCRIPT_DIR
  variable SimulateTimeUnits
  variable ToolVendor

  set  ElaborateOptions "-timeprecision_vhdl 1${SimulateTimeUnits} -mt off  ${LibraryName}.${LibraryUnit} -runall"
  puts "xelab {*}$ElaborateOptions"
  exec  xelab {*}$ElaborateOptions
  
#  set  ElaborateOptions "-timeprecision_vhdl 1${SimulateTimeUnits} -mt off  ${LibraryName}.${LibraryUnit} -snapshot ${LibraryName}_${LibraryUnit}"
#  puts "xelab {*}$ElaborateOptions"
#  exec  xelab {*}$ElaborateOptions
#  
#  set  SimulateOptions "-runall ${LibraryName}_${LibraryUnit}"
#  puts "xsim {*}$SimulateOptions"
#  exec  xsim {*}$SimulateOptions
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  
#  return "-generic_top \"${Name}=${Value}\""
  return "-generic_top ${Name}=${Value}"
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
