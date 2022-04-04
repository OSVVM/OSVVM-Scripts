#  File Name:         OsvvmProjectScripts.tcl
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
#    02/2022   2022.02    Added Analyze and Simulate Coverage and Extended Options
#                         Added support to run code coverage
#    01/2022   2022.01    Library directory to lower case.  Added OptionalCommands to Verilog analyze.
#                         Writing of FC summary now in VHDL.  Added DirectoryExists
#    12/2021   2021.12    Refactored for library handling.  Changed to relative paths.
#    10/2021   2021.10    Added calls to Report2Html, Report2JUnit, and Simulate2Html
#     3/2021   2021.03    Updated printing of start/finish times
#     2/2021   2021.02    Updated initialization of libraries
#                         Analyze allows ".vhdl" extensions as well as ".vhd"
#                         Include/Build signal error if nothing to run
#                         Added SetVHDLVersion / GetVHDLVersion to support 2019 work
#                         Added SetSimulatorResolution / GetSimulatorResolution to support GHDL
#                         Added beta of LinkLibrary to support linking in project libraries
#                         Added beta of SetLibraryDirectory / GetLibraryDirectory
#                         Added beta of ResetRunLibrary
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
# StartUp
#   re-run the startup scripts, this program included
#
proc StartUp {} {
  puts "source $::osvvm::SCRIPT_DIR/StartUp.tcl"
  eval "source $::osvvm::SCRIPT_DIR/StartUp.tcl"
}


namespace eval ::osvvm {

variable OsvvmYamlResultsFile    "./OsvvmRun.yml"  ; # WARNING:  OSVVM VHDL code also uses this name. If change directory, make sure directory exists
variable ExtendedAnalyzeOptions  ""
variable ExtendedSimulateOptions ""
variable CoverageAnalyzeOptions  [vendor_SetCoverageAnalyzeDefaults]
variable CoverageSimulateOptions [vendor_SetCoverageSimulateDefaults]
variable VhdlAnalyzeOptions       ""
variable VerilogAnalyzeOptions    ""
variable CoverageEnable           "true"

variable TranscriptExtension      "html"     ; # Set Transcripts to be html by default

variable LogDirectory             "logs/${ToolNameVersion}"
variable VhdlReportsDirectory     ""         ; # WARNING: OSVVM reporting requires this directory to be named reports
variable ReportsDirectory         "reports"  ; # Directory scripts put reports into.
variable OsvvmResultsDirectory    "results"  ; # WARNING: OSVVM regression tests expects this directory to be named results
variable ResultsDirectory         "results"  ; # A place for user code to write if "." or $OsvvmResultsDirectory not ok
variable CoverageDirectory        "CodeCoverage"
# variable LIB_BASE_DIR           ; # Default: $CURRENT_SIMULATION_DIRECTORY.  set by SetLibraryDirectoy
variable VhdlLibraryDirectory     "VHDL_LIBS"
variable VhdlLibrarySubdirectory  "${ToolNameVersion}"

variable TranscriptYamlFile OSVVM_transcript.yml


# -------------------------------------------------
# IterateFile
#   do an operation on a list of items
#
proc IterateFile {FileWithNames ActionForName} {
#  puts "$FileWithNames"
  set FileHandle [open $FileWithNames]
  set ListOfNames [split [read $FileHandle] \n]
  close $FileHandle

  foreach OneName $ListOfNames {
    # skip blank lines
    if {[string length $OneName] > 0} {
      # use # as comment character
      if {[string index $OneName 0] ne "#"} {
        puts "$ActionForName ${OneName}"
        # will break $OneName into individual pieces for handling
        eval $ActionForName ${OneName}
        # leaves $OneName as a single string
#        $ActionForName ${OneName}
      } else {
        # handle other file formats
        if {[lindex $OneName 1] eq "library"} {
          eval library [lindex $OneName 2]
        }
      }
    }
  }
}

# -------------------------------------------------
# include
#   finds and sources a project file
#
proc include {Path_Or_File} {
  variable CURRENT_WORKING_DIRECTORY
  variable VHDL_WORKING_LIBRARY

  EchoOsvvmCmd "include $Path_Or_File"

# probably remove.  Redundant with analyze and simulate
#  puts "set StartingPath ${CURRENT_WORKING_DIRECTORY} Starting Include"
  # If a library does not exist, then create the default
  if {![info exists VHDL_WORKING_LIBRARY]} {
    library default
  }
  set StartingPath ${CURRENT_WORKING_DIRECTORY}

#  if {[file pathtype $Path_Or_File] eq "absolute"} {
#    set NormName [file normalize $Path_Or_File]
#  } else {
#    set NormName [file normalize ${StartingPath}/${Path_Or_File}]
#  }
  set JoinName [file join ${StartingPath} ${Path_Or_File}]
  set NormName [ReducePath $JoinName]
  set RootDir  [file dirname $NormName]
  # Normalize to handle ".." and "."
  set NameToHandle [file tail [file normalize $NormName]]
  set FileExtension [file extension $NameToHandle]

  if {[file isfile $NormName]} {
    # Path_Or_File is <name>.pro, <name>.tcl, <name>.do, <name>.dirs, <name>.files
    puts "set CURRENT_WORKING_DIRECTORY ${RootDir}"
    set CURRENT_WORKING_DIRECTORY ${RootDir}
    if {$FileExtension eq ".pro" || $FileExtension eq ".tcl" || $FileExtension eq ".do"} {
      # Path_Or_File is <name>.pro, <name>.tcl, or <name>.do
      puts "source ${NormName}"
      source ${NormName}
    } elseif {$FileExtension eq ".dirs"} {
      # Path_Or_File is <name>.dirs
      puts "IterateFile ${NormName} include"
      IterateFile ${NormName} "include"
    } else {
    #  was elseif {$FileExtension eq ".files"}
      # Path_Or_File is <name>.files or other extension
      puts "IterateFile ${NormName} analyze"
      IterateFile ${NormName} "analyze"
    }
  } else {
    if {[file isdirectory $NormName]} {
      # Path_Or_File is directory name
      puts "set CURRENT_WORKING_DIRECTORY ${NormName}"
      set CURRENT_WORKING_DIRECTORY ${NormName}
      set FileBaseName ${NormName}/[file rootname ${NameToHandle}]
    } else {
      # Path_Or_File is file name without an extension
      puts "set CURRENT_WORKING_DIRECTORY ${RootDir}"
      set CURRENT_WORKING_DIRECTORY ${RootDir}
      set FileBaseName ${NormName}
    }
    # Determine which if any project files exist
    set FileProName    ${FileBaseName}.pro
    set FileDirsName   ${FileBaseName}.dirs
    set FileFilesName  ${FileBaseName}.files
    set FileTclName    ${FileBaseName}.tcl
    set FileDoName     ${FileBaseName}.do

    set FoundActivity 0
    if {[file isfile ${FileProName}]} {
      puts "source ${FileProName}"
      source ${FileProName}
      set FoundActivity 1
    }
    # .dirs is intended to be deprecated in favor of .pro
    if {[file isfile ${FileDirsName}]} {
      IterateFile ${FileDirsName} "include"
      set FoundActivity 1
    }
    # .files is intended to be deprecated in favor of .pro
    if {[file isfile ${FileFilesName}]} {
      IterateFile ${FileFilesName} "analyze"
      set FoundActivity 1
    }
    # .tcl intended for extended capability
    if {[file isfile ${FileTclName}]} {
      puts "do ${FileTclName} ${CURRENT_WORKING_DIRECTORY}"
      eval do ${FileTclName} ${CURRENT_WORKING_DIRECTORY}
      set FoundActivity 1
    }
    # .do intended for extended capability
    if {[file isfile ${FileDoName}]} {
      puts "do ${FileDoName} ${CURRENT_WORKING_DIRECTORY}"
      eval do ${FileDoName} ${CURRENT_WORKING_DIRECTORY}
      set FoundActivity 1
    }
    if {$FoundActivity == 0} {
      error "Build / Include did not find anything to execute for ${Path_Or_File}"
    }
  }
#  puts "set CURRENT_WORKING_DIRECTORY ${StartingPath} Ending Include"
  set CURRENT_WORKING_DIRECTORY ${StartingPath}
}

# -------------------------------------------------
proc SetBuildName {Path_Or_File} {
  # Create the Log File Name
  # Normalize to elaborate names, especially when Path_Or_File is "."
  set NormPathOrFile [file normalize ${Path_Or_File}]
  set NormDir        [file dirname $NormPathOrFile]
  set NormDirName    [file tail $NormDir]
  set NormTail       [file tail $NormPathOrFile]
  set NormTailRoot   [file rootname $NormTail]

  if {$NormDirName eq $NormTailRoot} {
    # <Parent Dir>_<Script Name>.log
#    set BuildName [file tail [file dirname $NormDir]]_${NormTailRoot}
    # <Script Name>.log
    set BuildName ${NormTailRoot}
  } else {
    # <Dir Name>_<Script Name>.log
    set BuildName ${NormDirName}_${NormTailRoot}
  }
  return $BuildName
}

# -------------------------------------------------
# build
#
proc build {{Path_Or_File "."}} {
  variable CURRENT_WORKING_DIRECTORY
  variable TestSuiteStartTimeMs
  variable TranscriptExtension
  variable RanSimulationWithCoverage 
  variable TestSuiteName

  BeforeBuildCleanUp   

  # Current Build Setup
#  set CURRENT_WORKING_DIRECTORY [pwd]
  set CURRENT_WORKING_DIRECTORY ""
  CheckWorkingDir
#  CheckSimulationDirs

  set BuildName [SetBuildName $Path_Or_File]
  set LogFileName ${BuildName}.${TranscriptExtension}

  StartTranscript ${LogFileName}

  EchoOsvvmCmd "build $Path_Or_File"

  set  BuildStartTime    [clock seconds]
  set  BuildStartTimeMs  [clock milliseconds]
  puts "Build Start time [clock format $BuildStartTime -format %T]"

  set   RunFile  [open ${::osvvm::OsvvmYamlResultsFile} w]
  puts  $RunFile "Version: 1.0"
  puts  $RunFile "Build:"
  puts  $RunFile "  Name: $BuildName"
  puts  $RunFile "  Date: [clock format $BuildStartTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Simulator: $::osvvm::simulator"
  puts  $RunFile "  Version: $::osvvm::ToolNameVersion"
#  puts  $RunFile "  Date: [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  close $RunFile

  include ${Path_Or_File}

  # Print Elapsed time for last TestSuite (if any ran) and the entire build
  set   RunFile  [open ${::osvvm::OsvvmYamlResultsFile} a]

  if {[info exists TestSuiteName]} {
    puts  $RunFile "    ElapsedTime: [ElapsedTimeMs $TestSuiteStartTimeMs]"
    FinalizeTestSuite $TestSuiteName
    unset TestSuiteName
  }

  if {$RanSimulationWithCoverage eq "true"} {
    vendor_MergeCodeCoverage  $BuildName $::osvvm::CoverageDirectory ""
    vendor_ReportCodeCoverage $BuildName $::osvvm::CoverageDirectory
  }

  set   BuildFinishTime     [clock seconds]
  set   BuildElapsedTime    [expr ($BuildFinishTime - $BuildStartTime)]
  puts  $RunFile "Run:"
  puts  $RunFile "  Start:    [clock format $BuildStartTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Finish:   [clock format $BuildFinishTime -format {%Y-%m-%dT%H:%M%z}]"
  puts  $RunFile "  Elapsed:  [ElapsedTimeMs $BuildStartTimeMs]"
  close $RunFile

  puts "Build Start time  [clock format $BuildStartTime -format {%T %Z %a %b %d %Y }]"
  puts "Build Finish time [clock format $BuildFinishTime -format %T], Elasped time: [format %d:%02d:%02d [expr ($BuildElapsedTime/(60*60))] [expr (($BuildElapsedTime/60)%60)] [expr (${BuildElapsedTime}%60)]] "
  StopTranscript ${LogFileName}

  # short sleep to allow the file to close
  after 1000
  file rename -force ${::osvvm::OsvvmYamlResultsFile} ${BuildName}.yml
  Report2Html  ${BuildName}.yml
  Report2Junit ${BuildName}.yml
}


# -------------------------------------------------
# CreateDirectory - Create directory if does not exist
#
proc BeforeBuildCleanUp {} {
  variable RanSimulationWithCoverage "false"
  variable vendor_simulate_started
  variable TestSuiteName
  variable TranscriptYamlFile 
  
  # Close any previous build information
  if {[info exists TestSuiteName]} {
    unset TestSuiteName
  }
  # If Transcript Open, then Close it
  TerminateTranscript

  # End simulations if started - only set by simulate
  if {[info exists vendor_simulate_started]} {
    puts "Ending Previous Simulation"
    EndSimulation
    unset vendor_simulate_started
  }
  
  # Remove old files if they were left lying around
  if {[file exists ${TranscriptYamlFile}]} {
    file delete -force -- ${TranscriptYamlFile}
  }
}

# -------------------------------------------------
# CreateDirectory - Create directory if does not exist
#
proc CreateDirectory {Directory} {
  if {![file isdirectory $Directory]} {
    puts "creating directory $Directory"
    file mkdir $Directory
  }
}

# -------------------------------------------------
# CheckWorkingDir
#   Used by library, analyze, and simulate
#
proc CheckWorkingDir {} {
  variable CURRENT_WORKING_DIRECTORY
  variable CURRENT_SIMULATION_DIRECTORY
  variable VHDL_WORKING_LIBRARY
  variable LibraryList
  variable LibraryDirectoryList

  set CurrentDir [pwd]
  if {![info exists CURRENT_WORKING_DIRECTORY]} {
#    set CURRENT_WORKING_DIRECTORY $CurrentDir
    set CURRENT_WORKING_DIRECTORY ""
  }
#  if {![info exists CURRENT_SIMULATION_DIRECTORY]} {
#    set CURRENT_SIMULATION_DIRECTORY ""
#  }
  if {![info exists CURRENT_SIMULATION_DIRECTORY] || $CURRENT_SIMULATION_DIRECTORY ne [file normalize $CurrentDir] } {
    # Simulation Directory Moved, Libraries are invalid
    puts "set CURRENT_SIMULATION_DIRECTORY $CurrentDir"
    set CURRENT_SIMULATION_DIRECTORY $CurrentDir
    if {[info exists LIB_BASE_DIR]} {
      unset LIB_BASE_DIR
      unset DIR_LIB
    }
    if {[info exists VHDL_WORKING_LIBRARY]} {
      unset VHDL_WORKING_LIBRARY
    }
    if {[info exists LibraryList]} {
      unset LibraryList
      unset LibraryDirectoryList
    }
  }
}

# -------------------------------------------------
# CheckLibraryInit
#   Used by library
#
proc CheckLibraryInit {} {
  variable LIB_BASE_DIR
  variable DIR_LIB
  variable CURRENT_SIMULATION_DIRECTORY

  if {![info exists LIB_BASE_DIR]} {
    set LIB_BASE_DIR $CURRENT_SIMULATION_DIRECTORY
    set DIR_LIB [file join ${LIB_BASE_DIR} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
  }

#  CreateDirectory $DIR_LIB          ; # Make Library Directory
}

# -------------------------------------------------
# CheckLibraryExists
#   Used by analyze, and simulate
#
proc CheckLibraryExists {} {
  variable VHDL_WORKING_LIBRARY

  if {![info exists VHDL_WORKING_LIBRARY]} {
    library default
  }
}

# -------------------------------------------------
# CheckSimulationDirs
#   Used by simulate
#
proc CheckSimulationDirs {} {
  variable CURRENT_SIMULATION_DIRECTORY
  CreateDirectory [file join ${CURRENT_SIMULATION_DIRECTORY} ${::osvvm::OsvvmResultsDirectory}]
  CreateDirectory [file join ${CURRENT_SIMULATION_DIRECTORY} ${::osvvm::ResultsDirectory}]
  CreateDirectory [file join ${CURRENT_SIMULATION_DIRECTORY} ${::osvvm::ReportsDirectory}]
  CreateDirectory [file join ${CURRENT_SIMULATION_DIRECTORY} ${::osvvm::VhdlReportsDirectory}]
  if {[info exists ::osvvm::CoverageSimulateEnable]} {
    CreateDirectory [file join $CURRENT_SIMULATION_DIRECTORY $::osvvm::CoverageDirectory $::osvvm::TestSuiteName]
  }
}

# -------------------------------------------------
# ReducePath
#   Remove "." and ".." from path
#
proc ReducePath {PathIn} {

  set CharCount 0
  set NewPath {}
  foreach item [file split $PathIn] {
    if {$item ne ".."}  {
      if {$item ne "."}  {
        lappend NewPath $item
        incr CharCount 1
      }
    } else {
      if {$CharCount >= 1} {
        set NewPath [lreplace $NewPath end end]
        incr CharCount -1
      } else {
        lappend NewPath $item
      }
    }
  }
  if {$NewPath eq ""} {
    set NewPath "."
  }
  return [eval file join $NewPath]
}

# -------------------------------------------------
# EchoOsvvmCmd
#
proc EchoOsvvmCmd {CmdInfoToPrint} {
  variable FirstEchoCmd
  variable TranscriptExtension
  variable CompoundCommand

  if {[info exists CompoundCommand] || ($TranscriptExtension eq "log")} {
    puts "${CmdInfoToPrint}"
  } elseif {[info exists FirstEchoCmd]} {
    puts "</details><details>"
    puts "<summary>${CmdInfoToPrint}</summary>"

#    puts "</details><details><summary>${CmdInfoToPrint}</summary>"
  } else {
    puts "<pre><details>"
    puts "<summary>${CmdInfoToPrint}</summary>"
#    puts "<pre><details><summary>${CmdInfoToPrint}</summary>"
    set FirstEchoCmd TRUE
  }
}

# -------------------------------------------------
# StartTranscript
#   Used by build
#
proc StartTranscript {FileBaseName} {
  variable CurrentTranscript
  variable DIR_LOGS
  variable CURRENT_SIMULATION_DIRECTORY
  variable FirstEchoCmd

  CheckWorkingDir

  if {($FileBaseName ne "NONE.log") && (![info exists CurrentTranscript])} {
    set DIR_LOGS   [file join ${CURRENT_SIMULATION_DIRECTORY} ${::osvvm::LogDirectory}]
    # Create directories if they do not exist
    set FileName [file join $DIR_LOGS $FileBaseName]
    CreateDirectory [file dirname $FileName]
    set CurrentTranscript $FileBaseName
    vendor_StartTranscript $FileName
    if {[info exists FirstEchoCmd]} {
      # nothing in transcript yet.
      unset FirstEchoCmd
    }
  }
}

# -------------------------------------------------
# StopTranscript
#   Used by build
#
proc StopTranscript {{FileBaseName ""}} {
  variable CurrentTranscript
  variable DIR_LOGS

  # Stop only if it is the transcript that is open
  if {($FileBaseName eq $CurrentTranscript)} {
    # FileName used within the STOP_TRANSCRIPT variable if required
    set FileName [file join $DIR_LOGS $FileBaseName]
    vendor_StopTranscript $FileName
    unset CurrentTranscript
    if {[info exists FirstEchoCmd]} {
      unset FirstEchoCmd
    }
  }
}

# -------------------------------------------------
# TerminateTranscript
#   Used by build
#
proc TerminateTranscript {} {
  variable CurrentTranscript
  if {[info exists CurrentTranscript]} {
    unset CurrentTranscript
  }
}

# -------------------------------------------------
# TerminateTranscript
#   Used by build
#
proc EndSimulation {} {

  vendor_end_previous_simulation
}


# -------------------------------------------------
# Library Commands
#

# -------------------------------------------------
proc FindLibraryPath {PathToLib} {
  variable DIR_LIB

  set ResolvedPathToLib ""
  if {$PathToLib eq ""} {
    # Use existing library directory
    set ResolvedPathToLib ${DIR_LIB}
  } else {
    set FullName [file join $PathToLib ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
    set LibsName [file join $PathToLib ${::osvvm::VhdlLibrarySubdirectory}]
    if      {[file isdirectory $FullName]} {
      set ResolvedPathToLib [file normalize $FullName]
    } elseif {[file isdirectory $LibsName]} {
      set ResolvedPathToLib [file normalize $LibsName]
    } elseif {[file isdirectory $PathToLib]} {
      set ResolvedPathToLib [file normalize $PathToLib]
    }
  }
  return $ResolvedPathToLib
}

# -------------------------------------------------
proc AddLibraryToList {LibraryName PathToLib} {
  variable LibraryList
  variable LibraryDirectoryList

  if {![info exists LibraryList]} {
    # Create Initial empty list
    set LibraryList ""
    set LibraryDirectoryList ""
  }
#  set LowerLibraryName [string tolower $LibraryName]
  set found [lsearch $LibraryList "${LibraryName} *"]
  if {$found < 0} {
    lappend LibraryList "$LibraryName $PathToLib"
    if {[lsearch $LibraryDirectoryList "${PathToLib}"] < 0} {
      lappend LibraryDirectoryList "$PathToLib"
    }
  }
  return $found
}

# -------------------------------------------------
proc ListLibraries {} {
  variable LibraryList

  if {[info exists LibraryList]} {
    foreach LibraryName $LibraryList {
      puts $LibraryName
    }
  }
}

# -------------------------------------------------
# Library
#
proc library {LibraryName {PathToLib ""}} {
  variable VHDL_WORKING_LIBRARY
  variable LibraryList
  variable DIR_LIB

  CheckWorkingDir
  CheckLibraryInit
  CreateDirectory $DIR_LIB    ; # Make library directory if it does not exist

  set ResolvedPathToLib [FindLibraryPath $PathToLib]
  set LowerLibraryName [string tolower $LibraryName]

  if  {![file isdirectory $ResolvedPathToLib]} {
    error "library $LibraryName ${PathToLib} : Library directory does not exist."
  }
  # Needs to be here to activate library (ActiveHDL)
  set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
  if {$found >= 0} {
    # Lookup Existing Library Directory
    set item [lindex $LibraryList $found]
    set ResolvedPathToLib [lindex $item 1]
  }
  EchoOsvvmCmd  "library $LibraryName $ResolvedPathToLib"
  vendor_library $LowerLibraryName $ResolvedPathToLib

  set VHDL_WORKING_LIBRARY  $LibraryName
}

# -------------------------------------------------
# LinkLibrary - aka map in some vendor tools
#
proc LocalLinkLibrary {LibraryName {PathToLib ""}} {
  variable VHDL_WORKING_LIBRARY
  variable DIR_LIB

  CheckWorkingDir
  CheckLibraryInit
  CreateDirectory $DIR_LIB    ; # Make library directory if it does not exist

  set ResolvedPathToLib [FindLibraryPath $PathToLib]
  set LowerLibraryName [string tolower $LibraryName]

  if  {[file isdirectory $ResolvedPathToLib]} {
    if {[AddLibraryToList $LowerLibraryName $ResolvedPathToLib] < 0} {
      vendor_LinkLibrary $LowerLibraryName $ResolvedPathToLib
    }
  } else {
    error "LinkLibrary $LibraryName ${PathToLib} : Library directory does not exist."
  }
}

proc LinkLibrary {LibraryName {PathToLib ""}} {

  EchoOsvvmCmd "LinkLibrary $LibraryName $PathToLib"
  LocalLInkLibrary $LibraryName $PathToLib 
}

# -------------------------------------------------
#  LinkLibraryDirectory
#
proc LinkLibraryDirectory {{LibraryDirectory ""}} {
  variable DIR_LIB
  variable CURRENT_SIMULATION_DIRECTORY
  variable ToolNameVersion

  CheckWorkingDir
  CheckLibraryInit

  set ResolvedLibraryDirectory [FindLibraryPath $LibraryDirectory]
  if  {[file isdirectory $ResolvedLibraryDirectory]} {
    if {![catch {glob -directory $ResolvedLibraryDirectory *} ErrNum]} {
      foreach item [glob -directory $ResolvedLibraryDirectory *] {
        if {[file isdirectory $item]} {
          set LibraryName [file rootname [file tail $item]]
          LocalLinkLibrary $LibraryName $ResolvedLibraryDirectory
        }
      }
    }
  } else {
    if {[string tolower $::osvvm::OsvvmInitialized] eq "true"} {
      puts "LinkLibraryDirectory $LibraryDirectory : $ResolvedLibraryDirectory does not exist"
    }
  }
}

# -------------------------------------------------
# LinkCurrentLibraries
#   EDA tools are centric to the current directory
#   If you change directory, they loose all of their library information
#   LinkCurrentLibraries reestablishes the library information
#
proc LinkCurrentLibraries {} {
  variable LibraryList
  set OldLibraryList $LibraryList

  # If directory changed, update CURRENT_SIMULATION_DIRECTORY, LibraryList
  CheckWorkingDir

  foreach item $OldLibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lindex $item 1]
    LinkLibrary ${LibraryName} ${PathToLib}
  }
}

# -------------------------------------------------
# analyze
#
proc analyze {FileName {OptionalCommands ""}} {
  variable VHDL_WORKING_LIBRARY
  variable CURRENT_WORKING_DIRECTORY
  variable CoverageAnalyzeEnable
  variable VhdlAnalyzeOptions
  variable VerilogAnalyzeOptions
  variable CoverageAnalyzeOptions
  variable ExtendedAnalyzeOptions

  CheckWorkingDir
  CheckLibraryExists

  EchoOsvvmCmd "analyze $FileName"

#  set NormFileName  [file normalize ${CURRENT_WORKING_DIRECTORY}/${FileName}]
  set NormFileName  [ReducePath [file join ${CURRENT_WORKING_DIRECTORY} ${FileName}]]
  set FileExtension [file extension $FileName]

  if {$FileExtension eq ".vhd" || $FileExtension eq ".vhdl"} {
    if {[info exists CoverageAnalyzeEnable]} {
      set AllOptionalCommands [concat {*}$VhdlAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$CoverageAnalyzeOptions {*}$OptionalCommands]
    } else {
      set AllOptionalCommands [concat {*}$VhdlAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$OptionalCommands]
    }
    vendor_analyze_vhdl ${VHDL_WORKING_LIBRARY} ${NormFileName} ${AllOptionalCommands}
  } elseif {$FileExtension eq ".v" || $FileExtension eq ".sv"} {
    if {[info exists CoverageAnalyzeEnable]} {
      set AllOptionalCommands [concat {*}$VerilogAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$CoverageAnalyzeOptions {*}$OptionalCommands]
    } else {
      set AllOptionalCommands [concat {*}$VerilogAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$OptionalCommands]
    }
    vendor_analyze_verilog ${VHDL_WORKING_LIBRARY} ${NormFileName} ${AllOptionalCommands}
  } elseif {$FileExtension eq ".lib"} {
    #  for handling older deprecated file format
    library [file rootname $FileName]
  }
}

# -------------------------------------------------
# Simulate
#
proc simulate {LibraryUnit {OptionalCommands ""}} {
  variable VHDL_WORKING_LIBRARY
  variable vendor_simulate_started
  variable TestCaseName
  variable TestSuiteName
  variable TranscriptExtension
  variable CoverageSimulateEnable
  variable CoverageSimulateOptions
  variable ExtendedSimulateOptions
  variable RanSimulationWithCoverage

  if {![info exists TestCaseName]} {
    TestCase $LibraryUnit
  }

  CheckWorkingDir
  CheckLibraryExists
  CheckSimulationDirs  

  if {[info exists vendor_simulate_started]} {
    EndSimulation
  }
  set vendor_simulate_started 1

#  StartTranscript ${LibraryUnit}.log


  set SimulateStartTime   [clock seconds]
  set SimulateStartTimeMs [clock milliseconds]

  EchoOsvvmCmd "simulate $LibraryUnit $OptionalCommands"


  if {[info exists CoverageSimulateEnable]} {
    set RanSimulationWithCoverage "true"
    set AllOptionalCommands [concat {*}$OptionalCommands {*}$ExtendedSimulateOptions {*}$CoverageSimulateOptions]
  } else {
    set AllOptionalCommands [concat {*}$OptionalCommands {*}$ExtendedSimulateOptions]
  }

  if {$TranscriptExtension eq "html"} {
    puts "<div id=\"${TestSuiteName}_${LibraryUnit}\" />"
  }

  puts "Simulate Start time [clock format $SimulateStartTime -format %T]"

  vendor_simulate ${VHDL_WORKING_LIBRARY} ${LibraryUnit} ${AllOptionalCommands}

  #puts "Start time  [clock format $SimulateStartTime -format %T]"
  set  SimulateFinishTime    [clock seconds]
  set  SimulateElapsedTime   [expr ($SimulateFinishTime - $SimulateStartTime)]
  set  SimulateFinishTimeMs  [clock milliseconds]
  set  SimulateElapsedTimeMs [expr ($SimulateFinishTimeMs - $SimulateStartTimeMs)]

  puts "Simulate Finish time [clock format $SimulateFinishTime -format %T], Elasped time: [format %d:%02d:%02d [expr ($SimulateElapsedTime/(60*60))] [expr (($SimulateElapsedTime/60)%60)] [expr (${SimulateElapsedTime}%60)]] "

  Simulate2Html $TestCaseName $TestSuiteName

  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
    puts  $RunFile "      ElapsedTime: [format %.3f [expr ${SimulateElapsedTimeMs}/1000.0]]"
    close $RunFile
  }

  unset TestCaseName
}

# -------------------------------------------------
proc MergeCoverage {SuiteName MergeName} {
  CreateDirectory [file join $::osvvm::CURRENT_SIMULATION_DIRECTORY $::osvvm::CoverageDirectory $MergeName]
  vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${MergeName}
}

# -------------------------------------------------
proc  ElapsedTimeMs {StartTimeMs} {
  set   FinishTimeMs  [clock milliseconds]
  set   ElapsedTimeMs [expr ($FinishTimeMs - $StartTimeMs)]
  return [format %.3f [expr ${ElapsedTimeMs}/1000.0]]
}

# -------------------------------------------------
proc FinalizeTestSuite {SuiteName} {

# Now done in Simulate2Html
#  # Move Alert and Functional Coverage YAML files to the TestSuite Directory
#  file rename -force {*}[glob ${::osvvm::ReportsDirectory}/*.yml]  ${::osvvm::ReportsDirectory}/${SuiteName}
  
  # Merge Code Coverage for the Test Suite if it exists
  if {$::osvvm::RanSimulationWithCoverage eq "true"} {
    set BuildName [file rootname ${::osvvm::CurrentTranscript}]
    CreateDirectory ${::osvvm::CoverageDirectory}/${BuildName}
    CreateDirectory ${::osvvm::CoverageDirectory}/${SuiteName}
    vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${BuildName}
  }
}

# -------------------------------------------------
proc TestSuite {SuiteName} {
  variable TestSuiteName
  variable TestSuiteStartTimeMs

  EchoOsvvmCmd "TestSuite $SuiteName"
  
  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
  } else {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} w]
  }
  if {![info exists TestSuiteName]} {
    puts  $RunFile "TestSuites: "
  } else {
    puts  $RunFile "    ElapsedTime: [ElapsedTimeMs $TestSuiteStartTimeMs]"
    FinalizeTestSuite $TestSuiteName
  }
  set   TestSuiteName $SuiteName
  puts  $RunFile "  - Name: $TestSuiteName"
  puts  $RunFile "    TestCases:"
  close $RunFile

  CreateDirectory [file join ${::osvvm::CURRENT_SIMULATION_DIRECTORY} ${::osvvm::ReportsDirectory} ${TestSuiteName}]
  CreateDirectory [file join ${::osvvm::CURRENT_SIMULATION_DIRECTORY} ${::osvvm::ResultsDirectory} ${TestSuiteName}]

  # Starting a Test Suite here
  set TestSuiteStartTimeMs   [clock milliseconds]
}


# -------------------------------------------------
proc TestCase {TestName} {
  variable TestCaseName
  variable TestSuiteName

  if {![info exists TestSuiteName]} {
    TestSuite Default
  }

  set TestCaseName $TestName

  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
  } else {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} w]
  }
  puts  $RunFile "    - TestCaseName: $TestName"
  close $RunFile
}


# -------------------------------------------------
# RunTest
#
proc RunTest {FileName {SimName ""}} {
  variable CompoundCommand

  EchoOsvvmCmd "RunTest $FileName $SimName"
  set CompoundCommand TRUE

	if {$SimName eq ""} {
    set SimName [file rootname [file tail $FileName]]
    TestCase $SimName
  } else {
    set ShortFileName [file rootname [file tail $FileName]]
    TestCase "${SimName}(${ShortFileName})"
  }

  analyze   ${FileName}
  simulate  ${SimName}
  unset CompoundCommand
}

# -------------------------------------------------
# SkipTest
#
proc SkipTest {FileName Reason} {

  set SimName [file rootname [file tail $FileName]]

  puts "SkipTest $FileName $Reason"

  if {[file isfile ${::osvvm::OsvvmYamlResultsFile}]} {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} a]
  } else {
    set RunFile [open ${::osvvm::OsvvmYamlResultsFile} w]
  }
  puts  $RunFile "    - TestCaseName: $SimName"
  puts  $RunFile "      Name: $SimName"
  puts  $RunFile "      Status: SKIPPED"
  puts  $RunFile "      Results: {Reason: \"$Reason\"}"
  close $RunFile
}


# -------------------------------------------------
# SetVHDLVersion, GetVHDLVersion
#
proc SetVHDLVersion {Version} {
  variable VhdlVersion
  variable VhdlShortVersion

  if {$Version eq "2008" || $Version eq "08"} {
    set VhdlVersion 2008
    set VhdlShortVersion 08
  } elseif {$Version eq "2019" || $Version eq "19" } {
    set VhdlVersion 2019
    set VhdlShortVersion 19
  } elseif {$Version eq "2002" || $Version eq "02" } {
    set VhdlVersion 2002
    set VhdlShortVersion 02
    puts "\nWARNING:  VHDL Version set to 2002.  OSVVM Requires 2008 or newer\n"
  } elseif {$Version eq "1993" || $Version eq "93" } {
    set VhdlVersion 93
    set VhdlShortVersion 93
    puts "\nWARNING:  VHDL Version set to 1993.  OSVVM Requires 2008 or newer\n"
  } else {
    set VhdlVersion 2008
    set VhdlShortVersion 08
    puts "\nWARNING:  Input to SetVHDLVersion not recognized.   Using 2008.\n"
  }
}

proc GetVHDLVersion {} {
  variable VhdlVersion
  return $VhdlVersion
}

# -------------------------------------------------
# SetTranscriptType, GetTranscriptType
#
proc SetTranscriptType {{TranscriptType "html"}} {
  variable TranscriptExtension

  set lowerTranscriptType [string tolower $TranscriptType]

  if {$lowerTranscriptType eq "html"} {
    set TranscriptExtension "html"
  } else {
    set TranscriptExtension "log"
  }
}

proc GetTranscriptType {} {
  variable TranscriptExtension
  return $TranscriptExtension
}

# -------------------------------------------------
# SetVhdlAnalyzeOptions, SetVerilogAnalyzeOptions
#
proc SetVhdlAnalyzeOptions {{Options ""}} {
  variable VhdlAnalyzeOptions
  set      VhdlAnalyzeOptions $Options ;
}
proc GetVhdlAnalyzeOptions {} {
  variable VhdlAnalyzeOptions
  return  $VhdlAnalyzeOptions
}

proc SetVerilogAnalyzeOptions {{Options ""}} {
  variable VerilogAnalyzeOptions
  set      VerilogAnalyzeOptions $Options ;
}
proc GetVerilogAnalyzeOptions {} {
  variable VerilogAnalyzeOptions
  return  $VerilogAnalyzeOptions
}

# -------------------------------------------------
# SetExtendedAnalyzeOptions, SetExtendedSimulateOptions
#
proc SetExtendedAnalyzeOptions {{Options ""}} {
  variable ExtendedAnalyzeOptions
  set ExtendedAnalyzeOptions $Options ;
}
proc GetExtendedAnalyzeOptions {} {
  variable ExtendedAnalyzeOptions
  return $ExtendedAnalyzeOptions
}

proc SetExtendedSimulateOptions {{Options ""}} {
  variable ExtendedSimulateOptions
  set ExtendedSimulateOptions $Options ;
}
proc GetExtendedSimulateOptions {} {
  variable ExtendedSimulateOptions
  return $ExtendedSimulateOptions
}

# -------------------------------------------------
# SetCoverageEnable, GetCoverageEnable
#
proc SetCoverageEnable {{Enable "true"}} {
  variable CoverageEnable
  if {[string tolower $Enable] eq "true"} {
    set CoverageEnable "true" ;
  } else {
    set CoverageEnable "false" ;
  }
}
proc GetCoverageEnable {} {
  variable CoverageEnable
  return $CoverageEnable
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions, SetCoverageAnalyzeEnable
#
proc SetCoverageAnalyzeOptions {{Options ""}} {
  variable CoverageAnalyzeOptions
  set CoverageAnalyzeOptions $Options ;
}
proc GetCoverageAnalyzeOptions {} {
  variable CoverageAnalyzeOptions
  return $CoverageAnalyzeOptions
}

proc SetCoverageAnalyzeEnable {{Enable ""}} {
  variable CoverageAnalyzeEnable
  variable CoverageEnable
#  if {[llength [info level 0]] < 3} { } ; # does not detect input ""
  if {$Enable eq ""} {
    set Enable $CoverageEnable
  }
  if {[string tolower $Enable] eq "true"} {
    set CoverageAnalyzeEnable "true" ;
  } elseif {[info exists CoverageAnalyzeEnable]} {
    unset CoverageAnalyzeEnable
  }
}
proc GetCoverageAnalyzeEnable {} {
  variable CoverageAnalyzeEnable
  if {[info exists CoverageAnalyzeEnable]} {
    return $CoverageAnalyzeEnable
  } else {
    return "false"
  }
}

# -------------------------------------------------
# SetCoverageSimulateOptions, SetCoverageSimulateEnable
#
proc SetCoverageSimulateOptions {{Options ""}} {
  variable CoverageSimulateOptions
  set CoverageSimulateOptions $Options ;
}
proc GetCoverageSimulateOptions {} {
  variable CoverageSimulateOptions
  return $CoverageSimulateOptions
}

proc SetCoverageSimulateEnable {{Enable ""}} {
  variable CoverageSimulateEnable
  variable CoverageEnable
#  if {[llength [info level 0]] < 3} { } ; # does not detect input ""
  if {$Enable eq ""} {
    set Enable $CoverageEnable
  }
  if {[string tolower $Enable] eq "true"} {
    set CoverageSimulateEnable "true" ;
  } elseif {[info exists CoverageSimulateEnable]} {
    unset CoverageSimulateEnable
  }
}
proc GetCoverageSimulateEnable {} {
  variable CoverageSimulateEnable
  if {[info exists CoverageSimulateEnable]} {
    return $CoverageSimulateEnable
  } else {
    return "false"
  }
}

# -------------------------------------------------
# SetSimulatorResolution, GetSimulatorResolution
#
proc SetSimulatorResolution {SimulatorResolution} {
  variable SIMULATE_TIME_UNITS
  set SIMULATE_TIME_UNITS $SimulatorResolution
}

proc GetSimulatorResolution {} {
  variable SIMULATE_TIME_UNITS
  return $SIMULATE_TIME_UNITS
}

# -------------------------------------------------
# SetLibraryDirectory
#
proc SetLibraryDirectory {{LibraryDirectory "."}} {
  variable LIB_BASE_DIR
  variable DIR_LIB

  if {$LibraryDirectory eq ""} {
    set LIB_BASE_DIR [file normalize "."]
  } else {
    set LIB_BASE_DIR [file normalize $LibraryDirectory]
  }
  CreateDirectory $LIB_BASE_DIR
  set DIR_LIB [file join ${LIB_BASE_DIR} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
}

proc GetLibraryDirectory {} {
  variable LIB_BASE_DIR

  if {[info exists LIB_BASE_DIR]} {
    return "${LIB_BASE_DIR}"
  } else {
    puts "WARNING:  GetLibraryDirectory LIB_BASE_DIR not defined"
    return ""
  }
}

# -------------------------------------------------
# RemoveLocalLibraries
#
proc RemoveLocalLibraries {} {
  variable LibraryDirectoryList
  variable LibraryList
  variable VHDL_WORKING_LIBRARY
  variable DIR_LIB

  if {[info exists DIR_LIB]} {
    file delete -force -- $DIR_LIB
  }
  if {[info exists VHDL_WORKING_LIBRARY]} {
    unset VHDL_WORKING_LIBRARY
  }
##!! TODO:  Remove libraries whose directory is DIR_LIB
  if {[info exists LibraryList]} {
    unset LibraryList
    unset LibraryDirectoryList
  }
}

proc RemoveAllLibraries {} {
  variable LibraryDirectoryList
  variable LibraryList
  variable VHDL_WORKING_LIBRARY

  if {[info exists LibraryDirectoryList]} {
    foreach LibraryDir $LibraryDirectoryList {
      file delete -force -- $LibraryDir
    }
  }
  if {[info exists VHDL_WORKING_LIBRARY]} {
    unset VHDL_WORKING_LIBRARY
  }
  if {[info exists LibraryList]} {
    unset LibraryList
    unset LibraryDirectoryList
  }
}

proc DirectoryExists {DirInQuestion} {
  variable CURRENT_WORKING_DIRECTORY

  if {[info exists CURRENT_WORKING_DIRECTORY]} {
    set LocalWorkingDirectory $CURRENT_WORKING_DIRECTORY
  } else {
    set LocalWorkingDirectory "."
  }
  return [file exists [file join ${LocalWorkingDirectory} ${DirInQuestion}]]
}


# Don't export the following due to conflicts with Tcl built-ins
# map

namespace export analyze simulate build include library RunTest SkipTest TestSuite TestCase
namespace export IterateFile StartTranscript StopTranscript TerminateTranscript
namespace export RemoveAllLibraries RemoveLocalLibraries CreateDirectory
namespace export SetVHDLVersion GetVHDLVersion SetSimulatorResolution GetSimulatorResolution
namespace export SetLibraryDirectory GetLibraryDirectory SetTranscriptType GetTranscriptType
namespace export LinkLibrary ListLibraries LinkLibraryDirectory LinkCurrentLibraries
namespace export FindLibraryPath EndSimulation DirectoryExists
namespace export SetExtendedAnalyzeOptions GetExtendedAnalyzeOptions
namespace export SetExtendedSimulateOptions GetExtendedSimulateOptions
namespace export SetCoverageAnalyzeOptions GetCoverageAnalyzeOptions
namespace export SetCoverageAnalyzeEnable GetCoverageAnalyzeEnable
namespace export SetCoverageSimulateOptions GetCoverageSimulateOptions
namespace export SetCoverageSimulateEnable GetCoverageSimulateEnable
namespace export MergeCoverage


# end namespace ::osvvm
}
