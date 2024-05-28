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
#     5/2024   2024.05    Added ToolVersion variable 
#    12/2023   2024.01    Updated as 2023.02's OSVVM support is looking good.
#    05/2022   2022.05    Updated variable naming 
#     2/2022   2022.02    Added template of procedures needed for coverage support
#     9/2021   2021.09    Created from VendorScripts_xxx.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2023 by SynthWorks Design Inc.  
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
  variable ToolName    "XSIM"
  variable ToolVersion [version -short]
  variable ToolNameVersion ${ToolName}-${ToolVersion}  
#   puts $ToolNameVersion

  # Make this version dependent when Xilinx starts supporting it
  variable ToolSupportsDeferredConstants "false"
  
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 


# -------------------------------------------------
# StartTranscript / StopTranscript
#

# 
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

# With this commented out, it will run the DefaultVendor_StartTranscript
proc vendor_StartTranscript {FileName} {
#  Do nothing - for now
}
# 
proc vendor_StopTranscript {FileName} {
  # This will have everything from a session rather than just the current build.
  # OK for bring up
  file copy   -force vivado.log ${FileName}
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^xvhdl|^xelab|^xsim} $LineOfText] 
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
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  variable VhdlLibraryFullPath
  
  set DebugOptions ""
  
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -work ${LibraryName} {*}${args} ${FileName}]
  puts "xvhdl {*}$AnalyzeOptions"
#  exec  xvhdl {*}$AnalyzeOptions
  if {[catch {exec xvhdl {*}$AnalyzeOptions  2>@1} AnalyzeMessage]} {
    PrintWithPrefix "Error:" $AnalyzeMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeMessage
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {
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
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor

  set  ElaborateOptions [concat -timeprecision_vhdl 1${SimulateTimeUnits} -mt auto  ${LibraryName}.${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}$::osvvm::GenericOptions -runall]
  puts "xelab {*}$ElaborateOptions"
  if {[catch {exec xelab {*}$ElaborateOptions 2>@1} ElaborateMessage]} { 
    PrintWithPrefix "Elaborate Error:"  $ElaborateMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $ElaborateMessage
  }
  
## This Works## # Patrick suggests that we do this one rather than the above 12/9/2022  
## This Works## #  set  ElaborateOptions "-timeprecision_vhdl 1${SimulateTimeUnits} -mt off  ${LibraryName}.${LibraryUnit} -snapshot ${LibraryName}_${LibraryUnit}"
## This Works##   set  ElaborateOptions "-timeprecision_vhdl 1${SimulateTimeUnits} -mt auto  ${LibraryName}.${LibraryUnit} -snapshot ${LibraryName}_${LibraryUnit}"
## This Works##   puts "xelab {*}$ElaborateOptions"
## This Works## #  exec  xelab {*}$ElaborateOptions
## This Works##   if {[catch {exec xelab {*}$ElaborateOptions 2>@1} ElaborateMessage]} { 
## This Works##     PrintWithPrefix "Elaborate Error:"  $ElaborateMessage
## This Works##     error "Failed: simulate $LibraryUnit"
## This Works##   } else {
## This Works##     puts $ElaborateMessage
## This Works##   }
## This Works##   
## This Works##   set  SimulateOptions "-runall ${LibraryName}_${LibraryUnit}"
## This Works##   puts "xsim {*}$SimulateOptions"
## This Works## #  exec  xsim {*}$SimulateOptions
## This Works##   if { [catch {exec xsim {*}$SimulateOptions 2>@1} SimulateMessage]} {
## This Works## #    error "Failed: simulate $LibraryUnit"
## This Works##     PrintWithPrefix "Error:" $SimulateMessage
## This Works##     error "Failed: simulate $LibraryUnit"
## This Works##   } else {
## This Works##     puts $SimulateMessage
## This Works##   }
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
