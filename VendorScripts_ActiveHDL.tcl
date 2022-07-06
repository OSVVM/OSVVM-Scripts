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
  variable ToolNameVersion ${ToolName}-${version}
  puts $ToolNameVersion
  # Allow variable OSVVM library to be updated
  setlibrarymode -rw osvvm

  if {[batch_mode]} {
    variable NoGui true
  } else {
    variable NoGui false
  }
  variable FailOnBuildErrors        "false"


# -------------------------------------------------
# StartTranscript / StopTranscript
#
proc vendor_StartTranscript {FileName} {
  transcript off
  echo transcript to $FileName
  transcript to $FileName
}

proc vendor_StopTranscript {FileName} {
  transcript off
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {vlib|vmap|vcom|vlog|vsim|run|acdb} $LineOfText] 
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

  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  set PathToLib [file normalize $RelativePathToLib]
  set PathAndLib ${PathToLib}/${LibraryName}

  if {![file exists ${PathAndLib}]} {
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

  if {[info exists vendor_simulate_started]} {
    endsim
  }  
  set sim_working_folder $::osvvm::CurrentSimulationDirectory
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

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName RelativePathToFile OptionalCommands} {
  variable VhdlVersion
  variable VhdlLibraryFullPath
  variable CoverageAnalyzeEnable
  variable CoverageSimulateEnable
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  set FileName [file normalize $RelativePathToFile]
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  set FileBaseName [file rootname [file tail $FileName]]
  
  # Check src to see if it has been added
  if {![file isfile ${VhdlLibraryFullPath}/$LibraryName/src/${FileBaseName}.vcom]} {
    echo addfile ${FileName}
    addfile ${FileName}
    filevhdloptions -${VhdlVersion} ${FileName}
  }
  # Compile it.
  echo vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName} > ${VhdlLibraryFullPath}/$LibraryName/src/${FileBaseName}.vcom
  if {[info exists CoverageAnalyzeEnable] || [info exists CoverageSimulateEnable]} {
    puts "vcom -${VhdlVersion} -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}"
         vcom -${VhdlVersion} -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
  } else {
    puts "vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}"
         vcom -${VhdlVersion} -dbg -relax -work ${LibraryName} {*}${OptionalCommands} ${FileName}
  }

  cd $MY_START_DIR
}

proc vendor_analyze_verilog {LibraryName File_Relative_Path OptionalCommands} {
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  
  set FileName [file normalize $File_Relative_Path]

#  Untested branch for Verilog - will need adjustment
#  Untested branch for Verilog - will need adjustment
    echo vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}
         vlog -work ${LibraryName} {*}${OptionalCommands} ${FileName}
  cd $MY_START_DIR
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
proc vendor_simulate {LibraryName LibraryUnit OptionalCommands} {
  variable SCRIPT_DIR
  variable SimulateTimeUnits
  variable ToolVendor
  variable CoverageSimulateEnable
  variable TestSuiteName
  variable TestCaseFileName
  global sim_working_folder

  set sim_working_folder $::osvvm::CurrentSimulationDirectory

  # With sim_working_folder setting should no longer need MY_START_DIR
  set MY_START_DIR $::osvvm::CurrentSimulationDirectory
  
  puts "asim {*}${OptionalCommands} -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}" 
        asim {*}${OptionalCommands} -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}  
  
  # ActiveHDL changes the directory, so change it back to the OSVVM run directory
  cd $MY_START_DIR
  
  SimulateRunScripts ${LibraryUnit}


  log -rec [env]/*
  cd $MY_START_DIR
  run -all 
  cd $MY_START_DIR
  
  # Save Coverage Information 
  if {[info exists CoverageSimulateEnable]} {
    acdb save -o ${::osvvm::CoverageDirectory}/${TestSuiteName}/${TestCaseFileName}.acdb -testname ${TestCaseFileName}
  }
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
  acdb merge -o ${CoverageFileBaseName}.acdb -i {*}[join [glob ${CoverageDirectory}/${TestSuiteName}/*.acdb] " -i "]
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
