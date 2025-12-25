#  File Name:         VendorScripts_ActiveHDL.tcl
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
#     5/2024   2024.05    Added ToolVersion variable 
#     5/2022   2022.05    Coverage report name based on TestCaseName rather than LibraryUnit
#                         Updated variable naming 
#     2/2022   2022.02    Added Coverage Collection
#    12/2021   2021.12    Updated since OsvvmProjectScripts uses relative paths.
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
  variable ToolVendor  "Aldec"
  variable ToolName    "ActiveHDL"
  variable simulator   $ToolName ; # Deprecated  
  variable ToolVersion $version
  variable ToolNameVersion ${ToolName}-${version}
#   puts $ToolNameVersion
  # Allow variable OSVVM library to be updated
  setlibrarymode -rw osvvm
  setlibrarymode -rw osvvm_common

  if {[expr [string compare $ToolVersion "12.0"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019Interface           "false"
    variable Supports2019ImpureFunctions     "true"
    variable Supports2019FilePath            "true"
    variable Supports2019AssertApi           "true"
  }

  variable FunctionalCoverageIntegratedInSimulator "Aldec"
  
  if {[batch_mode]} {
    variable NoGui "true"
  } else {
    variable NoGui "false"
  }
  variable RemoveUnmappedLibraries                "false"
  variable RemoveLibraryDirectoryDeletesDirectory "false"


# -------------------------------------------------
# StartTranscript / StopTranscript
#
proc vendor_StartTranscript {FileName} {
  transcript off
  echo transcript to $FileName
  transcript to $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript to -off
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^design |^alib |^amap |^acom |^alog |^asim |^vlib |^vmap |^vcom |^vlog |^vsim |^run |^acdb } $LineOfText] 
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
  set CoverageSimulateOptions "-acdb -acdb_cov sbm -cc_all"
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName RelativePathToLib} {
  variable vendor_simulate_started
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory ; # ActiveHDL Global variable

  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  set PathToLib [file normalize $RelativePathToLib]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
#    if {[glob -nocomplain -directory $PathToLib *] eq ""} {
#      echo design create -a  project ${PathToLib}
#      design create -a  project ${PathToLib}
#    }
#    if {![file exists ${::osvvm::CurrentSimulationDirectory}/project]} {
#      CreateDirectory ${::osvvm::CurrentSimulationDirectory}/project
#      echo "workspace create  ${::osvvm::CurrentSimulationDirectory}/project/project"
#      workspace create  ${::osvvm::CurrentSimulationDirectory}/project/project
##      design create -a do_not_use ${::osvvm::CurrentSimulationDirectory}/project
#    }
#    if {[glob -nocomplain -directory $PathToLib *] eq ""} {
#      echo "workspace create  ${PathToLib}/project/project"
#      workspace create  ${PathToLib}/project/project
##      design create -a do_not_use ${PathToLib}/project
#    }
    echo design create -a  $LibraryName ${PathToLib}
    design create -a  $LibraryName ${PathToLib}
  }
  puts "design open -a  ${PathAndLib}"
  design open -a  ${PathAndLib}
  puts "design activate $LibraryName"
  design activate $LibraryName
  
  cd $MY_START_DIR
}

proc vendor_LinkLibrary {LibraryName RelativePathToLib} {
  variable vendor_simulate_started
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory

  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  set PathToLib [file normalize $RelativePathToLib]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {[file exists ${PathAndLib}]} {
    # Library created by ActiveHDL
    vendor_library $LibraryName $PathToLib
  } else {
    # Library created separately
    echo vmap    $LibraryName  ${PathToLib}
         vmap    $LibraryName  ${PathToLib}
  }
  cd $MY_START_DIR
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
# Does the design also need to be closed?
# The intent is to delete the library so it can be recreated
# so it should be ok not closing the design
#  vmap -del -re ${LibraryName}
#  design detach ${LibraryName}
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  puts "vdel -lib ${LibraryName} -all"
  vdel -lib ${LibraryName} -all
}


# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName RelativePathToFile args} {
  variable VhdlVersion
  variable VhdlLibraryFullPath
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  set FileName [file normalize $RelativePathToFile]
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  set FileBaseName [file rootname [file tail $FileName]]
  
  # Check src to see if it has been added
  set FileAlreadyAdded ${VhdlLibraryFullPath}/$LibraryName/src/${FileBaseName}.vcom
  if {![file isfile ${FileAlreadyAdded}]} {
    echo addfile ${FileName}
    addfile ${FileName}
    filevhdloptions -${VhdlVersion} ${FileName}
  }
  
  set EffectiveCoverageAnalyzeEnable    [expr $::osvvm::CoverageEnable && $::osvvm::CoverageAnalyzeEnable]
  set EffectiveCoverageSimulateEnable   [expr $::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable]

  if {$::osvvm::NoGui || !($::osvvm::Debug) || $EffectiveCoverageAnalyzeEnable || $EffectiveCoverageSimulateEnable} {
    set DebugOptions ""
  } else {
    set DebugOptions "-dbg"
  }
  
  set  AnalyzeOptions [concat -${VhdlVersion} {*}${DebugOptions} -relax -work ${LibraryName} {*}${args}]
  
  echo "vcom {*}$AnalyzeOptions  ${FileName}" > ${FileAlreadyAdded}
#  puts "vcom {*}$AnalyzeOptions"
        vcom {*}$AnalyzeOptions ${FileName}
  
  cd $MY_START_DIR
}

proc vendor_analyze_verilog {LibraryName File_Relative_Path args} {
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  
  set FileName [file normalize $File_Relative_Path]

  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-l "] -work ${LibraryName} {*}${args}]
  puts "vlog $AnalyzeOptions  ${FileName}"
        vlog {*}$AnalyzeOptions  ${FileName}
  cd $MY_START_DIR
}

# -------------------------------------------------
proc NoNullRangeWarning  {} {
  return "-nowarn COMP96_0119"
}


# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  endsim
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable ToolVendor
  variable TestSuiteName
  variable TestCaseFileName
  variable WaveFiles
  global sim_working_folder
  global aldec            ; #  required for matlab cosim

  set sim_working_folder $::osvvm::CurrentSimulationDirectory

  # With sim_working_folder setting should no longer need MY_START_DIR
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  
  set SimulateOptions [concat {*}${args} {*}${::osvvm::GenericOptions} -interceptcoutput -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel}]

  puts "asim ${SimulateOptions}"
        asim {*}${SimulateOptions}

  # ActiveHDL changes the directory, so change it back to the OSVVM run directory
  cd $MY_START_DIR
  
  SimulateRunScripts ${LibraryUnit}
  cd $MY_START_DIR

  if {$::osvvm::LogSignals} {
    puts "log -rec [env]/*"
    log -rec [env]/*
    cd $MY_START_DIR
  }
  if {$WaveFiles ne ""} {
    foreach wave $WaveFiles {
      do $wave
    }
  }
  set WaveFiles ""
  run -all
  cd $MY_START_DIR
  
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
