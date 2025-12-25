#  File Name:         VendorScripts_GHDL.tcl
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
#     7/2024   2024.07    Added ability to find nvc on the search path
#     5/2024   2024.05    Added ToolVersion variable 
#     1/2023   2023.01    Added options for CoSim 
#     5/2022   2022.05    Updated variable naming 
#     2/2022   2022.02    Added template of procedures needed for coverage support
#    12/2021   2021.12    Updated to use relative paths.
#     6/2021   2021.06    Updated to better handle return values from GHDL
#     2/2021   2021.02    Refactored variable settings to here from ToolConfiguration.tcl
#     9/2020   2020.09    Initial Version
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2020 - 2022 by SynthWorks Design Inc.  
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

package require fileutil

# -------------------------------------------------
# Tool Settings
#
  variable ToolType   "simulator"
  variable ToolVendor "GHDL"
  variable ToolName   "GHDL"
  variable simulator   $ToolName ; # Deprecated 
##  variable ghdl "ghdl"
  
  # required for mintty
  if {[file writable "/dev/pty0" ]} {
    variable console "/dev/pty0"
  } else {
    variable console {}
  }
  
#  set ghdl {*}[auto_execok ghdl]
  if { [info exists ::env(MSYSTEM)] } {
    # running on MSYS2 - convert which with cygpath
    set ghdl [exec cygpath -m [exec which ghdl]]
  } else {
    set ghdl [exec which ghdl]
  }
   
  regexp {GHDL\s+\d+\.\d+\S*} [exec $ghdl --version] VersionString
  variable ToolVersion [regsub {GHDL\s+} $VersionString ""]
  variable ToolNameVersion ${ToolName}-${ToolVersion}
#  variable ToolNameVersion [regsub {\s+} $VersionString -]
#   puts $ToolNameVersion

#  variable GhdlRunOptions ""


# -------------------------------------------------
# StartTranscript / StopTranscript
#

# 
#  Uses DefaultVendor_StartTranscript and DefaultVendor_StopTranscript
#

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
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^ghdl } $LineOfText] 
}

# -------------------------------------------------
# Library
#
proc GhdlLibraryPath {LibraryName PathToLib} {
  set PathAndLib "[::fileutil::relative [pwd] ${PathToLib}/[string tolower ${LibraryName}]/v${::osvvm::VhdlShortVersion}]"
  return $PathAndLib
}

proc vendor_library {LibraryName PathToLib} {
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_TRANSCRIPT_FILE
  variable GHDL_WORKING_LIBRARY_PATH
   
  set PathAndLib [GhdlLibraryPath $LibraryName $PathToLib]

  CreateDirectory ${PathAndLib}
  
  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"
  }
  set GHDL_WORKING_LIBRARY_PATH $PathAndLib
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  variable VHDL_RESOURCE_LIBRARY_PATHS

  if {![info exists VHDL_RESOURCE_LIBRARY_PATHS]} {
    # Create Initial empty list
    set VHDL_RESOURCE_LIBRARY_PATHS ""
  }
  if {[lsearch $VHDL_RESOURCE_LIBRARY_PATHS "*${PathToLib}"] < 0} {
    lappend VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"
  }
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable LibraryList
  
  # Was last library in directory deleted?
  if {[lsearch $LibraryList "* ${PathToLib}"] < 0} {
    # Remove it from GHDL Library Paths
    set found [lsearch $VHDL_RESOURCE_LIBRARY_PATHS "-P$PathToLib"]
    if {$found >= 0} {
      set VHDL_RESOURCE_LIBRARY_PATHS [lreplace $VHDL_RESOURCE_LIBRARY_PATHS $found $found]
    }
  }
}


# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlShortVersion
  variable ghdl 
##  variable console
##  variable GHDL_TRANSCRIPT_FILE
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable VhdlLibraryFullPath
  variable GHDL_WORKING_LIBRARY_PATH

  set  AnalyzeOptions [concat --std=${VhdlShortVersion} -Wno-library -Wno-hide --work=${LibraryName} --workdir=${GHDL_WORKING_LIBRARY_PATH} {*}${VHDL_RESOURCE_LIBRARY_PATHS} {*}${args} ${FileName}]
  puts "ghdl -a $AnalyzeOptions"
#  exec $ghdl -a {*}$AnalyzeOptions
  if {[catch {exec $ghdl -a {*}$AnalyzeOptions} AnalyzeErrorMessage]} {
    PrintWithPrefix "Error:" $AnalyzeErrorMessage
    error "Failed: analyze $FileName"
  } else {
    puts $AnalyzeErrorMessage
  }
}

proc vendor_analyze_verilog {LibraryName FileName args} {

  puts "Analyzing verilog files not supported by GHDL" 
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  # Do Nothing
}  

# -------------------------------------------------
# Simulate
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable ghdl
  variable VhdlShortVersion
  variable VHDL_RESOURCE_LIBRARY_PATHS
  variable GHDL_WORKING_LIBRARY_PATH
  variable ExtendedElaborateOptions
  variable ExtendedRunOptions
#  variable GhdlRunOptions
  variable GhdlRunCmd

  if {[info exists GhdlRunCmd]} {
    set runcmd $GhdlRunCmd
  } else {
    set runcmd "--elab-run"
  }

  set CoSimElaborateOptions ""
  if {$::osvvm::RunningCoSim} {
    if {$::osvvm::OperatingSystemName eq "linux"} {
      set CoSimElaborateOptions "-Wl,-lpthread"
    }
  }

  set LocalElaborateOptions [concat --std=${VhdlShortVersion} --syn-binding {*}${ExtendedElaborateOptions} {*}${CoSimElaborateOptions} --work=${LibraryName} --workdir=${GHDL_WORKING_LIBRARY_PATH} ${VHDL_RESOURCE_LIBRARY_PATHS} {*}${args}]

  set SignalSelectionFile [FindFirstFile ${LibraryUnit}.ghdl]
  if {${SignalSelectionFile} ne ""} {
    set SignalSelectionOptions "--read-wave-opt=${SignalSelectionFile}"
  } else {
    set SignalSelectionOptions ""
  }
  
  if {$::osvvm::SaveWaves} {
#    set LocalRunOptions [concat {*}${ExtendedRunOptions} --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw ${SignalSelectionOptions} ${GhdlRunOptions} ]
    set LocalRunOptions [concat {*}${ExtendedRunOptions} --wave=${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw ${SignalSelectionOptions} {*}${::osvvm::GenericOptions} ]
  } else {
#    set LocalRunOptions [concat {*}${ExtendedRunOptions} ${GhdlRunOptions}]
    set LocalRunOptions [concat {*}${ExtendedRunOptions} {*}${::osvvm::GenericOptions}]
  }
#  set GhdlRunOptions ""
  
# format for select file  
  set SimulateOptions [concat {*}${LocalElaborateOptions} ${LibraryUnit} {*}${LocalRunOptions}]
  puts "ghdl $runcmd ${SimulateOptions}" 
  
  set SimulateErrorCode [catch {exec $ghdl $runcmd {*}${SimulateOptions} 2>@1} SimulateErrorMessage] 
#  if {[file exists ${LibraryUnit}.ghw]} {
#    file rename -force ${LibraryUnit}.ghw ${::osvvm::ReportsTestSuiteDirectory}/${LibraryUnit}.ghw
#  }
  if {$SimulateErrorCode != 0} {
    PrintWithPrefix "Error:" $SimulateErrorMessage
    error "Failed: simulate $LibraryUnit"
  } else {
    puts $SimulateErrorMessage
  }
  
  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
#    acdb save -o ${LibraryUnit}.acdb -testname ${LibraryUnit}
  }
}

# -------------------------------------------------
proc FindFirstFile {Name} {
  set LocalPathName [file join ${::osvvm::CurrentWorkingDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  set LocalPathName [file join ${::osvvm::CurrentSimulationDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  set LocalPathName [file join ${::osvvm::OsvvmScriptDirectory} ${Name}]
  if {[file exists $LocalPathName]} {
    return ${LocalPathName}
  }
  return ""
}

# -------------------------------------------------
proc vendor_generic {Name Value} {
#  variable GhdlRunOptions
  
#  append GhdlRunOptions "-g${Name}=${Value} "
  
  return "-g${Name}=${Value}"
#  return ""
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
