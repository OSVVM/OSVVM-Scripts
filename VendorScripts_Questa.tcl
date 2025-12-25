#  File Name:         VendorScripts_Visualizer.tcl
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
#     7/2024   2024.07    Initial.   Derived from VendorScripts_Siemens
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

package require fileutil

# -------------------------------------------------
# Tool Settings
#
  variable ToolType    "simulator"
  variable ToolVendor  "Siemens"

  set VersionString [exec vsim -version &2>1]
  regexp {(\S+)\s+\S+\s+\S+\s+(\d+\.\d+\S*)} $VersionString FullMatch Name Version

  if {![catch {vsimId} msg]} {
    variable ToolVersion [vsimId]
  } else {
    variable ToolVersion $Version
  }
  
  if {[info exists ::ToolName]} {
    variable ToolName $::ToolName
  } else {
    variable ToolName $Name
  }

  variable ToolNameVersion ${ToolName}-${ToolVersion}
  variable simulator   $ToolName ; # Variable simulator is deprecated.  Use ToolName instead 
  
  # How was the simulator started?  
  #     Tool interface vs. TCLSH shell   
  #     Batch (-c -batch) vs. -gui
  #     Assumption:  If batch or shell focus on running fast as it is a regression
  variable shell ""
  if {![catch {batch_mode} msg]} {
    if {[batch_mode]} {
      variable NoGui "true"
      if {[regexp {\-batch} $argv]} {
        variable EnableTranscriptInBatchMode "false"
#        variable SiemensSimulateOptions -batch  
        variable SiemensSimulateOptions -c  
      } else {
        variable EnableTranscriptInBatchMode "true"
        variable SiemensSimulateOptions -c  
      }
    } else {
      variable NoGui "false"
      variable EnableTranscriptInBatchMode "true"  ; # not relevant
      variable SiemensSimulateOptions "-c"
    }
  } else {
    # Started from Shell
    variable shell "exec"
    variable NoGui "true"
    variable EnableTranscriptInBatchMode "true"
#    variable SiemensSimulateOptions "-c"
    variable SiemensSimulateOptions "-batch"
  }

  if {[expr [string compare $ToolVersion "2026.1"] >= 0]} {
    SetVHDLVersion 2019
    variable Supports2019Interface             "true"
    # variable Supports2019ImpureFunctions     "true"
    # variable Supports2019FilePath            "true"
    # variable Supports2019AssertApi           "true"
  }

  # Set if not set
  if {![info exists ::VoptArgs]} {
    set ::VoptArgs " "
  } else {
    puts "::VoptArgs = $::VoptArgs"
  }
  if {![info exists ::VsimArgs]} {
    set ::VsimArgs " "
  } else {
    puts "::VsimArgs = $::VsimArgs"
  }

  
# -------------------------------------------------
# StartTranscript / StopTranscxript
#
proc vendor_StartTranscript {FileName} {
  variable NoGui
  
#  puts "NoGui: $NoGui"

  if {$NoGui} {
    # if started as vsim -batch, do not do logging here
    # instead use vsim -batch -do "..." | tee OsvvmBuild.log
    if {$::osvvm::EnableTranscriptInBatchMode} {
      DefaultVendor_StartTranscript $FileName
    }
  } else {
    transcript file ""
    echo transcript file $FileName
    transcript file $FileName
  }
}

proc vendor_StopTranscript {FileName} {
  variable NoGui

  if {$NoGui} {
    if {$::osvvm::EnableTranscriptInBatchMode} {
      DefaultVendor_StopTranscript $FileName
    }
  } else {
    transcript file ""
  }
}

# -------------------------------------------------
# IsVendorCommand
#
proc IsVendorCommand {LineOfText} {

  return [regexp {^vlib |^vmap |^vcom |^vlog |^vopt |^vsim |^run |^coverage |^vcover } $LineOfText] 
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions
# SetCoverageCoverageOptions
#
proc vendor_SetCoverageAnalyzeDefaults {} {
  variable CoverageAnalyzeOptions
#  set CoverageAnalyzeOptions "+cover=bcesft"
  set CoverageAnalyzeOptions "+cover=bsf"
}

proc vendor_SetCoverageSimulateDefaults {} {
  variable CoverageSimulateOptions
  set CoverageSimulateOptions "-coverage"
}

# -------------------------------------------------
# Library
#
proc vendor_library {LibraryName PathToLib} {
  set PathAndLib [::fileutil::relative [pwd] ${PathToLib}/${LibraryName}]

  if {![file exists ${PathAndLib}]} {
    puts "vlib   ${PathAndLib} "
    eval $::osvvm::shell  vlib   ${PathAndLib}
  }
  puts                 "vmap   $LibraryName  ${PathAndLib}"
  eval $::osvvm::shell  vmap   $LibraryName  ${PathAndLib}
}

proc vendor_LinkLibrary {LibraryName PathToLib} {
  set PathAndLib [::fileutil::relative [pwd] ${PathToLib}/${LibraryName}]

  if {[file exists ${PathAndLib}]} {
    set ResolvedLib ${PathAndLib}
  } else {
    set ResolvedLib ${PathToLib}
  }
  puts                "vmap    $LibraryName  ${ResolvedLib}"
  eval $::osvvm::shell vmap    $LibraryName  ${ResolvedLib}
}

proc vendor_UnlinkLibrary {LibraryName PathToLib} {
  eval $::osvvm::shell vmap -del ${LibraryName}
}

# -------------------------------------------------
# analyze
#
proc vendor_analyze_vhdl {LibraryName FileName args} {
  variable VhdlVersion
  
  set  AnalyzeOptions [concat -${VhdlVersion} -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vcom $AnalyzeOptions"
  eval $::osvvm::shell vcom {*}$AnalyzeOptions
}

proc vendor_analyze_verilog {LibraryName FileName args} {
  set  AnalyzeOptions [concat [CreateVerilogLibraryParams "-L "] -work ${LibraryName} {*}${args} ${FileName}]
#  puts "vlog $AnalyzeOptions"
  eval $::osvvm::shell vlog {*}$AnalyzeOptions
}

# -------------------------------------------------
# End Previous Simulation
#
proc vendor_end_previous_simulation {} {
  global SourceMap
  variable NoGui

  # close junk in source window
  if {! $NoGui} {
    catch {noview source}
    catch {noview source}
  }  
  if {$::osvvm::shell ne "exec"} {
    puts "quit -sim"
    quit -sim
  }
}

# -------------------------------------------------
# vendor_simulate
#
# Note about ignored vsim warnings:
# During simulation OSVVM suppresses QuestaSim/ModelSim messages 8683 and 8684.
# These are warnings about potential issues with port drivers due to QuestaSim/ModelSim 
# using non-VHDL compliant optimizations.  The potential issues these warn about 
# do not occur with OSVVM interfaces.   As a result, these warnings are suppressed 
# because they consume significant time at the startup of simulations. 
#  
# You can learn more about these messages by doing “verror 8683” or “verror 8684” 
# from within the tool GUI.   
# 
# verror 8683
# ------------------------------------------ 
# 
# An output port has no default expression in its declaration and has no drivers.  
# The VHDL LRM-compliant value it propagates to higher-level connected signals may 
# not be what is desired.  In particular, this behavior might not correspond to 
# the synthesis view of initialization.  The vsim switch "-defaultstdlogicinittoz" 
# or "-forcestdlogicinittoz" may be useful in this situation.
# 
# OSVVM Analysis of Message # 8683
# ------------------------------------------ 
# 
# OSVVM interfaces that is used to connect VC to the test sequencer (TestCtrl) use 
# minimum as a resolution function.  Driving the default value (type'left) on a 
# signal has no negative impact.  Hence, OSVVM disables this warning since it does 
# not apply.
# 
# verror 8684
# ------------------------------------------ 
# 
# An output port having no drivers has been combined with a higher-level connected 
# signal.  The port will get its initial value from this higher-level connected 
# signal; this is not compliant with the behavior required by the VHDL LRM.  
# 
# LRM compliant behavior would require the port's initial value come from its 
# declaration, however, since it was combined or collapsed with the port or signal 
# higher in the hierarchy, the initial value came from that port or signal.
# 
# LRM compliant behavior can be obtained by preventing the collapsing of these ports 
# with the vsim switch -donotcollapsepartiallydriven. If the port is collapsed to a 
# port or signal with the same initialization (as is often the case of default 
# initializations being applied), there is no problem and the proper initialization 
# is done and the simulation is LRM compliant.
# 
# OSVVM Analysis of Message # 8684
# ------------------------------------------ 
# 
# Older OSVVM VC use records whose elements are std_logic_vector.   These VC 
# initialize port values to 'Z'.  QuestaSim non-VHDL compliant optimizations, such as 
# port collapsing, remove these values.  If you are using older OSVVM verification 
# components, you can avoid any impact of this non compliant behavior if you initialize 
# the transaction interface signal in the test harness to all 'Z'.  
#  
# Hence, OSVVM disables this warning since it does not apply if you use the due 
# care recommended above.
# 
# OSVVM recommends that you migrate older interfaces to the newer that uses types 
# and resolution functions defined in ResolutionPkg such as std_logic_max, 
# std_logic_vector_max, or std_logic_vector_max_c rather than std_logic or 
# std_logic_vector.   ResolutionPkg supports a richer set of types, such as 
# integer_max, real_max, ...
#
proc vendor_simulate {LibraryName LibraryUnit args} {
  variable OsvvmScriptDirectory
  variable SimulateTimeUnits
  variable TestSuiteName
  variable TestCaseFileName
  variable ExtendedOptimizeOptions
  variable ExtendedSimulateOptions

#  set SimTempDirectory $::osvvm::ReportsTestSuiteDirectory 
  set SimTempDirectory [file join $::osvvm::VhdlLibraryFullPath SimTemp $::osvvm::TestSuiteName] 
  CreateDirectory $SimTempDirectory
  
  # Create the script files
  set ErrorCode [catch {vendor_CreateSimulateDoFile $LibraryUnit OsvvmSimRun.tcl} CatchMessage]
  if {$ErrorCode != 0} {
    PrintWithPrefix "Error:" $CatchMessage
    puts $::errorInfo
    error "Failed: vendor_CreateSimulateDoFile $LibraryUnit"
  } 

  set OptimizeOptions ""
  set WaveOptions   ""

  if {$::osvvm::SaveWaves} {
	  set OptimizeOptions "-debug"
    set WaveOptions "-qwavedb=+signals+wavefile=[file join ${SimTempDirectory} ${TestCaseFileName}_qwave.db]"
  }

  if {$::osvvm::SimulateInteractive} {
	  set OptimizeOptions "-debug"
  }

  if {$::osvvm::Debug} {
	  set OptimizeOptions "-debug,livesim"
  }

  set OptimizeOptions [concat $::VoptArgs $OptimizeOptions {*}$ExtendedOptimizeOptions  -work ${LibraryName} -L ${LibraryName} ${LibraryUnit} ${::osvvm::SecondSimulationTopLevel} -o ${LibraryUnit}_opt {*}${::osvvm::GenericOptions}]
  
  puts "vopt {*}${OptimizeOptions} -designfile [file join ${SimTempDirectory} ${TestCaseFileName}_design.bin]"
  eval $::osvvm::shell vopt {*}${OptimizeOptions} -designfile [file join ${SimTempDirectory} ${TestCaseFileName}_design.bin] 
  
  # Set generics during opt rather than sim
  set SimulateOptions [concat $::VsimArgs -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}_opt ${::osvvm::SecondSimulationTopLevel} {*}${args} -suppress 8683 -suppress 8684]
#  set SimulateOptions [concat $::osvvm::SiemensSimulateOptions $::VsimArgs -t $SimulateTimeUnits -lib ${LibraryName} ${LibraryUnit}_opt ${::osvvm::SecondSimulationTopLevel} {*}${args} {*}${::osvvm::GenericOptions} -suppress 8683 -suppress 8684]
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    set RanSimulationWithCoverage "true"
    set SimulateOptions [concat $::osvvm::SiemensSimulateOptions {*}$ExtendedSimulateOptions {*}$CoverageSimulateOptions {*}$SimulateOptions]
  } else {
    set SimulateOptions [concat $::osvvm::SiemensSimulateOptions {*}$ExtendedSimulateOptions {*}$SimulateOptions]
  }

  if {$::osvvm::shell eq ""} {
    puts "vsim ${SimulateOptions} ${WaveOptions}"
    vsim {*}${SimulateOptions}  {*}${WaveOptions} 
    source OsvvmSimRun.tcl
  } else {
    puts "vsim {*}${SimulateOptions} {*}${WaveOptions} -do \"exit -code \[catch {source OsvvmSimRun.tcl}\]\""
    set ErrorCode [catch {exec vsim {*}${SimulateOptions}  {*}${WaveOptions} -do "exit -code \[catch {source OsvvmSimRun.tcl}\]"} CatchMessage] 
    if {$ErrorCode != 0} {
      PrintWithPrefix "Error:" $CatchMessage
      puts $::errorInfo
      error "Failed: simulate $LibraryUnit"
    } else {
      puts $CatchMessage
    }
  }
}

# -------------------------------------------------
# vendor_CreateSimulateDoFile
#
proc vendor_CreateSimulateDoFile {LibraryUnit ScriptFileName} {
  variable ScriptFile 
  
  # Open File
  set ScriptFile [open $ScriptFileName w]
  
  # Do Vendor Simulate pre-run stuff here
  
  # Historical name.  Must be run with "do" for actions to work
  if {[file exists ${::osvvm::OsvvmScriptDirectory}/Siemens.do]} {
    puts  $ScriptFile  "do ${::osvvm::OsvvmScriptDirectory}/Siemens.do"
#    puts  $ScriptFile  "source ${::osvvm::OsvvmScriptDirectory}/Siemens.do"
  }

  SimulateCreateDoFile $LibraryUnit

  if {$::osvvm::LogSignals} {
    puts $ScriptFile "catch {add log -r \[env\]/*}"
  }

  puts  $ScriptFile "run -all" 
  
  # Save Coverage Information
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    puts $ScriptFile "coverage save ${::osvvm::CoverageDirectory}/${::osvvm::TestSuiteName}/${::osvvm::TestCaseFileName}.ucdb"
  }
  
#  puts  $ScriptFile "quit" 
  close $ScriptFile
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
  set CovFiles [glob -nocomplain ${CoverageDirectory}/${TestSuiteName}/*.ucdb]
  if {$CovFiles ne ""} {
    eval $::osvvm::shell vcover merge ${CoverageFileBaseName}.ucdb {*}$CovFiles
  }
}

proc vendor_ReportCodeCoverage {TestSuiteName CodeCoverageDirectory} { 
  set CodeCovResultsDir ${CodeCoverageDirectory}/${TestSuiteName}_code_cov
  if {[file exists $CodeCovResultsDir]} {
    file delete -force -- $CodeCovResultsDir
  }
  eval $::osvvm::shell vcover report -html -annotate -details -verbose -output ${CodeCovResultsDir} ${CodeCoverageDirectory}/${TestSuiteName}.ucdb 
}

proc vendor_GetCoverageFileName {TestName} { 
  set CoverageFileName ${TestName}_code_cov/index.html
  return $CoverageFileName
}
