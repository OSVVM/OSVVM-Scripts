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
#    04/2024   2024.04    Created from VendorScripts_xxx.tcl
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.  
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
  variable ToolName    "DSim"
  variable ToolVersion 2024.04
  variable ToolNameVersion ${ToolName}-2024.04   ;# produces "DSim-2024.04" 
#  variable ToolNameVersion ${ToolName}-${ToolVersion}   ;# produces "DSim-2023.2" 
#   puts $ToolNameVersion

  
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 


# -------------------------------------------------
# StartTranscript / StopTranscript
#

# 
#  With these commented out, it uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

# # # With this commented out, it will run the DefaultVendor_StartTranscript
# # proc vendor_StartTranscript {FileName} {
# # #  Do nothing - for now
# # }
# # # 
# # proc vendor_StopTranscript {FileName} {
# #   # This will have everything from a session rather than just the current build.
# #   # OK for bring up
# #   file copy   -force vivado.log ${FileName}
# # }

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^dlib|^dvhcom|^dsim} $LineOfText] 
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
  CreateDirectory $PathAndLib
  vendor_LinkLibrary  $LibraryName  ${PathToLib}
}


proc vendor_LinkLibrary {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  # Policy:  If library is already in library list, then skip this for Riviera
  if {[IsLibraryInList $LibraryName] < 0} {
    if {[file exists ${PathAndLib}]} {
      set ResolvedLib ${PathAndLib}
    } else {
      set ResolvedLib ${PathToLib}
    }
    puts "dlib map -lib $LibraryName $PathAndLib"
          dlib map -lib $LibraryName $PathAndLib
  }
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  # Do something here to unmap the library
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  variable VhdlLibraryFullPath
  
  set DebugOptions ""
  
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -lib ${LibraryName} {*}${args} ${FileName}]
  puts "dvhcom  {*}$AnalyzeOptions"
  if {[catch {exec dvhcom {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
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

  set  ElaborateOptions [concat -timescale 1${SimulateTimeUnits} -top ${LibraryName}.${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}$::osvvm::GenericOptions]
  puts "dsim {*}$ElaborateOptions"
  if {[catch {exec dsim {*}$ElaborateOptions} ElaborateMessage]} { 
    PrintWithPrefix "Elaborate Error:"  $ElaborateMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $ElaborateMessage
  }
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  
#  return "-generic_top \"${Name}=${Value}\""
  return "-defparams  ${Name}=${Value}"
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
