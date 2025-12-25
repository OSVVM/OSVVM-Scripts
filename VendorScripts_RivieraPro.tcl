#  File Name:         VendorScripts_RivieraPro.tcl
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
#     7/2024   2024.07    Added DoWaves capability 
#     5/2024   2024.05    Added CloseAllFiles to vendor_end_previous_simulation.  Added ToolVersion variable 
#     5/2022   2022.05    Coverage report name based on TestCaseName rather than LibraryUnit
#                         Updated variable naming 
#     2/2022   2022.02    Added Coverage Collection
#    12/2021   2021.12    Updated to use relative paths.
#     3/2021   2021.03    In Simulate, added optional scripts to run as part of simulate
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#    11/2018   Alpha      Project descriptors in .files and .dirs files
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
  variable ToolVendor  "Aldec"
  variable ToolName    "RivieraPRO"
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 
  #  Could differentiate between RivieraPRO and VSimSA
  variable ToolVersion [asimVersion]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#   puts $ToolNameVersion

  if {[expr [string compare $ToolVersion "2021.04"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019Interface           "false"
    variable Supports2019ImpureFunctions     "true"
    variable Supports2019FilePath            "true"
    variable Supports2019AssertApi           "true"
  }
  if {[expr [string compare $ToolVersion "2025.07"] >= 0]} {
    variable Supports2019Integer64Bits       "true"
  }

  variable FunctionalCoverageIntegratedInSimulator "Aldec"
  
  if {[batch_mode]} {
    variable NoGui "true"
  } else {
    variable NoGui "false"
  }

# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  transcript file ""
  puts "transcript file $FileName"
  transcript file $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript file -close $FileName
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^alib |^amap |^acom |^alog |^asim |^vlib |^vmap |^vcom |^vlog |^vsim |^run |^acdb } $LineOfText] 
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#  set CoverageAnalyzeOptions "-coverage sbmec"
  set CoverageAnalyzeOptions "-coverage sbm"
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
#  set CoverageSimulateOptions "-acdb -acdb_cov sbmec -cc_all"
#  set CoverageSimulateOptions "-acdb -acdb_cov sbm -cc_all"
  set CoverageSimulateOptions "-acdb_cov sbm -cc_all"
}

# -------------------------------------------------
# Library
#
proc vendor_vlib {PathAndLib} {
    # after 1000
    puts "vlib    ${PathAndLib}"
          vlib    ${PathAndLib}
}

proc vendor_library {LibraryName PathToLib} {
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
    if {[catch {vendor_vlib $PathAndLib} LibraryErrMsg]} {
      # if fails first try, wait and try again
      after 10000
      vendor_vlib $PathAndLib
    }
  } else {
    vendor_LinkLibrary  $LibraryName  ${PathToLib}
  }
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
    puts "vmap    $LibraryName  ${ResolvedLib}"
          vmap    $LibraryName  ${ResolvedLib}
  }
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  vmap -del -re ${LibraryName}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  
  set EffectiveCoverageAnalyzeEnable    [expr $::osvvm::CoverageEnable && $::osvvm::CoverageAnalyzeEnable]
  set EffectiveCoverageSimulateEnable   [expr $::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable]

  if {$::osvvm::NoGui || !($::osvvm::Debug) || $EffectiveCoverageAnalyzeEnable || $EffectiveCoverageSimulateEnable} {
    set DebugOptions ""
  } else {
    set DebugOptions "-dbg"
  }
  
# at least with RP 2024.10, relax mode is not needed, looks like it was there in the first version of this file
#  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -work ${LibraryName} {*}${args} ${FileName}]
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -relax -work ${LibraryName} {*}${args} ${FileName}]
  puts "vcom $AnalyzeOptions"
        vcom {*}$AnalyzeOptions
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-l "] -work ${LibraryName} {*}${args} ${FileName}]
  puts "vlog $AnalyzeOptions"
        vlog {*}$AnalyzeOptions
}

# -------------------------------------------------
proc NoNullRangeWarning  {} {
  return "-nowarn COMP96_0119"
}



# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  catch {quit -sim}                    ;# catch suppresses the simulator messages
  framework.documents.closeall -vhdl
  ::osvvm::CloseAllFiles
  puts ""
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable SimulateTimeUnits
  variable TestSuiteName
  variable TestCaseFileName
  variable SimulateOptions
  variable WaveFiles
  global aldec            ; #  required for matlab cosim

  if {($::osvvm::Debug)} {
    set DebugOptions "+access +r"
  } else {
    set DebugOptions ""
  }

#  puts "vendor_simulate  LibraryName: $LibraryName    LibraryUnit:  $LibraryUnit   args:  $args"
  set SimulateOptions [concat $DebugOptions -interceptcoutput -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}${::osvvm::GenericOptions}]

  puts "vsim ${SimulateOptions}"
        vsim {*}${SimulateOptions}
        
  SimulateRunScripts ${LibraryUnit}

  if {$::osvvm::LogSignals} {
    log -rec [env]/*
  }
  if {$WaveFiles ne ""} {
    foreach wave $WaveFiles {
      do $wave
    }
  }
  set WaveFiles ""
  run -all 
  
  # Save Coverage Information 
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    acdb save -o ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseFileName}.acdb -testname ${TestCaseFileName}
  }
}

# -------------------------------------------------
proc vendor_DoWaves {args} {
  variable WaveFiles
  
  if {$args ne ""} {
    foreach wave {*}$args {
      lappend WaveFiles $wave 
    }
  }
  return ""
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
  
  return "-g${Name}=${Value}"
}


# -------------------------------------------------
# Merge Coverage
#
proc vendor_MergeCodeCoverage {TestSuiteName CoverageDirectory BuildName} { 
  set CoverageFileBaseName [file join ${CoverageDirectory} ${BuildName} ${TestSuiteName}]
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.acdb]
  if {$CovFiles ne ""} {
    acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join $CovFiles " -i "]
  }
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} { 
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists ${CodeCovResultsDir}.html]} {
    file delete -force -- ${CodeCovResultsDir}.html
  }
  if {[file exists ${CodeCovResultsDir}_files]} {
    file delete -force -- ${CodeCovResultsDir}_files
  }
  acdb report -html -i ${CodeCoverageDirectory}/${TestSuiteName}.acdb -o ${CodeCovResultsDir}.html
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov.html
  return $CoverageFileName
}

# proc vendor_OpenBuildHtml {BuildHtmlFile BuildName} {
#   catch {framework.window.close -window $BuildName} Msg
#   system.open "$BuildHtmlFile" -title $BuildName
# }
