#  File Name:         OsvvmProjectScripts.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#     Markus Ferringer    Patterns for error handling and callbacks, ...
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
#     1/2023   2023.01    Added options for CoSim 
#    12/2022   2022.12    Minor update to StartUp
#    09/2022   2022.09    Added RemoveLibrary, RemoveLibraryDirectory, OsvvmLibraryPath
#                         Added SetVhdlAnalyzeOptions, SetExtendedAnalyzeOptions, SetExtendedSimulateOptions
#                         Added (for GHDL) SetSaveWaves, SetExtendedElaborateOptions, SetExtendedRunOptions
#                         Added SetInteractiveMode, SetDebugMode, SetLogSignals
#    08/2022   2022.08    Added handling for Analyze with Verilog Libraries.  
#                         Added SetSecondSimulationTopLevel, GetSecondSimulationTopLevel
#    06/2022   2022.06    Generic handling.  Fixed spaces in library path.
#    05/2022   2022.05    Refactored to move variable settings to OsvvmDefaultSettings
#                         Added Error Handling
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
  puts "source $::osvvm::OsvvmScriptDirectory/StartUpShared.tcl"
  eval "source $::osvvm::OsvvmScriptDirectory/StartUpShared.tcl"
}


namespace eval ::osvvm {



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

proc PrintWithPrefix {Prefix RawMessageList} {
  foreach Message [split $RawMessageList \n] {
    # Remove Prefix if already exists
#    set NoPrefixMessage [regsub -nocase "^$Prefix " $Message ""]
#    puts "$Prefix $NoPrefixMessage"
    if {[regexp -nocase "$Prefix" $Message]} {
      puts "$Message"
    } else {
      puts "$Prefix $Message"
    }
  }
}


# -------------------------------------------------
# include
#   finds and sources a project file
#
proc include {Path_Or_File} {
  variable CurrentWorkingDirectory

  CallbackBefore_Include $Path_Or_File
  puts "include $Path_Or_File"                    ; # EchoOsvvmCmd

# probably remove.  Redundant with analyze and simulate
#  puts "set StartingPath ${CurrentWorkingDirectory} Starting Include"
  # If a library does not exist, then create the default
  CheckLibraryExists

  set StartingPath ${CurrentWorkingDirectory}

  set JoinName [file join ${StartingPath} ${Path_Or_File}]
  set NormName [ReducePath $JoinName]
  set RootDir  [file dirname $NormName]
  # Normalize to handle ".." and "."
  set NameToHandle [file tail [file normalize $NormName]]
  set FileExtension [file extension $NameToHandle]

  if {[file isfile $NormName]} {
    # Path_Or_File is <name>.pro, <name>.tcl, <name>.do, <name>.dirs, <name>.files
    puts "set CurrentWorkingDirectory ${RootDir}"
    set CurrentWorkingDirectory ${RootDir}
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
      puts "set CurrentWorkingDirectory ${NormName}"
      set CurrentWorkingDirectory ${NormName}
      set FileBaseName ${NormName}/[file rootname ${NameToHandle}]
    } else {
      # Path_Or_File is file name without an extension
      puts "set CurrentWorkingDirectory ${RootDir}"
      set CurrentWorkingDirectory ${RootDir}
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
      puts "do ${FileTclName} ${CurrentWorkingDirectory}"
      eval do ${FileTclName} ${CurrentWorkingDirectory}
      set FoundActivity 1
    }
    # .do intended for extended capability
    if {[file isfile ${FileDoName}]} {
      puts "do ${FileDoName} ${CurrentWorkingDirectory}"
      eval do ${FileDoName} ${CurrentWorkingDirectory}
      set FoundActivity 1
    }
    if {$FoundActivity == 0} {
      CallbackOnError_Include $Path_Or_File
    } else {
      CallbackAfter_Include $Path_Or_File
    }
  }
#  puts "set CurrentWorkingDirectory ${StartingPath} Ending Include"
  set CurrentWorkingDirectory ${StartingPath}
}


# -------------------------------------------------
# BeforeBuildCleanUp 
#
proc BeforeBuildCleanUp {} {
  variable RanSimulationWithCoverage "false"
  variable vendor_simulate_started
  variable TestCaseName
  variable TestSuiteName
  variable TranscriptYamlFile 
  variable AnalyzeErrorCount  0
  variable ConsecutiveAnalyzeErrors  0
  variable SimulateErrorCount 0
  variable ConsecutiveSimulateErrors 0
  variable ScriptErrorCount 0 
  
  # Close any previous build information
  if {[info exists TestCaseName]} {
    unset TestCaseName
  }
  if {[info exists TestSuiteName]} {
    unset TestSuiteName
  }
  # If Files Open, then Close them
  # CloseAllFiles  ; # oddly Questa has a number of files open already

  # End simulation if one was started - only set by simulate - closes any open files
  if {[info exists vendor_simulate_started]} {
    puts "Ending Previous Simulation"
    EndSimulation
    unset vendor_simulate_started
  }
  
  # Remove old files if they were left lying around
  if {[file exists ${TranscriptYamlFile}]} {
    file delete -force -- ${TranscriptYamlFile}
  }
  
  set ::osvvm::CurrentWorkingDirectory ""
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
  variable AnalyzeErrorCount 
  variable SimulateErrorCount
  variable ScriptErrorCount 
  variable BuildErrorInfo
  variable Log2ErrorInfo
  variable BuildStarted
  variable BuildName
  variable BuildErrorCode 0
  
  if {$BuildStarted} {
    include $Path_Or_File
  } else {
  
    BeforeBuildCleanUp   
    
    set BuildStarted "true"
    set BuildName [SetBuildName $Path_Or_File]

    StartTranscript ${BuildName}

    #  Catch any errors from the build and handle them below
    set BuildErrorCode [catch {LocalBuild $BuildName $Path_Or_File} BuildErrMsg]
    set LocalBuildErrorInfo $::errorInfo
    set BuildStarted "false"
    
    # Try to create reports, even if the build failed
    set ReportErrorCode [catch {AfterBuildReports $BuildName} ReportsErrMsg]
    set LocalReportErrorInfo $::errorInfo

    if {($ReportErrorCode != 0) || ($ScriptErrorCount != 0)} {  
      CallbackOnError_AfterBuildReports $LocalReportErrorInfo
    } 

#    StopTranscript ${LogFileName}
    StopTranscript ${BuildName}
    
    set BuildName ""

    # Cannot generate html log files until transcript is closed - previous step
    set Log2ErrorCode [catch {Log2Osvvm $::osvvm::TranscriptFileName} ReportsErrMsg]
    set Log2ErrorInfo $::errorInfo

    if {$BuildErrorCode != 0 || $AnalyzeErrorCount > 0 || $SimulateErrorCount > 0} {   
      CallbackOnError_Build $Path_Or_File $BuildErrorCode $LocalBuildErrorInfo 
    } 
    # Fail on Test Case Errors
    if {($::osvvm::BuildStatus eq "FAILED") && ($::osvvm::FailOnTestCaseErrors)} {
        error "Test finished with Test Case Errors"
    }
    # Fail on Report / Script Errors?
    if {($ReportErrorCode != 0) || ($Log2ErrorCode != 0) || ($ScriptErrorCount != 0)} {  
      # End Simulation with errors
      if {$::osvvm::FailOnReportErrors} {
        error "Test finished with either Report or Script (wave.do) errors."
      }
    } 
  }
}

proc LocalBuild {BuildName Path_Or_File} {
  variable TestSuiteStartTimeMs
  variable RanSimulationWithCoverage 
  variable TestSuiteName
  variable OutputBaseDirectory

  puts "build $Path_Or_File"                      ; # EchoOsvvmCmd

  StartBuildYaml $BuildName
  
  CallbackBefore_Build ${Path_Or_File}
  include ${Path_Or_File}
  CallbackAfter_Build ${Path_Or_File}

  if {[info exists TestSuiteName]} {
    FinalizeTestSuite $TestSuiteName
    FinishTestSuiteBuildYaml
    unset TestSuiteName
  }

  if {$RanSimulationWithCoverage eq "true"} {
    vendor_MergeCodeCoverage  $BuildName $::osvvm::CoverageDirectory ""
    vendor_ReportCodeCoverage $BuildName $::osvvm::CoverageDirectory
  }

  FinishBuildYaml $BuildName
}

proc AfterBuildReports {BuildName} {

  # short sleep to allow the file to close
  after 1000
  set BuildYamlFile [file join ${::osvvm::OutputBaseDirectory} ${BuildName}.yml]
  file rename -force ${::osvvm::OsvvmBuildYamlFile} ${BuildYamlFile}
  Report2Html  ${BuildYamlFile}
  Report2Junit ${BuildYamlFile}
  
  ReportBuildStatus  
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
  variable CurrentSimulationDirectory
  variable VhdlLibraryParentDirectory
  variable VhdlWorkingLibrary
  variable LibraryList
  variable LibraryDirectoryList

  set CurrentDir [pwd]
  if {$CurrentSimulationDirectory ne $CurrentDir } {
    if {$VhdlLibraryParentDirectory eq $CurrentSimulationDirectory} {
      # Simulation Directory Moved, Set Library to current directory
      SetLibraryDirectory $CurrentDir
      
      if {[info exists VhdlWorkingLibrary]} {
        unset VhdlWorkingLibrary
      }
      if {[info exists LibraryList]} {
        unset LibraryList
        unset LibraryDirectoryList
      }
    }
    puts "set CurrentSimulationDirectory $CurrentDir"
    set CurrentSimulationDirectory $CurrentDir
    if {${::osvvm::OutputBaseDirectory} ne ""} {
      CreateDirectory ${::osvvm::OutputBaseDirectory}
    }
  }
}

# -------------------------------------------------
# CheckLibraryInit
#   Used by library
#
proc CheckLibraryInit {} {
  variable VhdlLibraryParentDirectory
  variable VhdlLibraryFullPath
  
  if { ${VhdlLibraryParentDirectory} eq [pwd]} {
    # Local Library Directory - use OutputBaseDirectory
    set VhdlLibraryFullPath [file join ${VhdlLibraryParentDirectory} ${::osvvm::OutputBaseDirectory} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
  } else {
    # Global Library Directory - do not use OutputBaseDirectory
    set VhdlLibraryFullPath [file join ${VhdlLibraryParentDirectory} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
  }
}

# -------------------------------------------------
# CheckLibraryExists
#   Used by analyze, and simulate
#
proc CheckLibraryExists {} {
  variable VhdlWorkingLibrary

  if {![info exists VhdlWorkingLibrary]} {
    library $::osvvm::DefaultLibraryName
  }
}

# -------------------------------------------------
# CheckSimulationDirs
#   Used by simulate
#
proc CheckSimulationDirs {} {
  variable CurrentSimulationDirectory

  CreateDirectory [file join ${CurrentSimulationDirectory} ${::osvvm::ResultsDirectory}]
  CreateDirectory [file join ${CurrentSimulationDirectory} ${::osvvm::ReportsDirectory}]
  CreateDirectory [file join ${CurrentSimulationDirectory} ${::osvvm::OsvvmTemporaryOutputDirectory}]
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    CreateDirectory [file join $CurrentSimulationDirectory $::osvvm::CoverageDirectory $::osvvm::TestSuiteName]
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
# StartTranscript
#   Used by build
#
proc StartTranscript {FileBaseName} {

  CheckWorkingDir
  
  set TempTranscriptName [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::OsvvmBuildLogFile}]
  
  if {![catch {info body vendor_StartTranscript} err]} {
    vendor_StartTranscript $TempTranscriptName
  } else {
    DefaultVendor_StartTranscript $TempTranscriptName
  }
}

proc DefaultVendor_StartTranscript {FileName} { 

  if {$::osvvm::GotTee} {
    set LogFile  [open ${FileName} w]
    tee channel stderr $LogFile
    tee channel stdout $LogFile
  }
}

# -------------------------------------------------
# StopTranscript
#   Used by build
#
proc StopTranscript {{FileBaseName ""}} {
  variable TranscriptFileName

  flush stdout
  
  set FullPathLogDirectory [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::OutputBaseDirectory} ${::osvvm::LogSubdirectory}]
  CreateDirectory          $FullPathLogDirectory

  set TempTranscriptName [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::OsvvmBuildLogFile}]
  set TranscriptFileName [file join ${FullPathLogDirectory} ${FileBaseName}.log]
  if {![catch {info body vendor_StopTranscript} err]} {
    vendor_StopTranscript $TempTranscriptName
    file rename -force ${TempTranscriptName} ${TranscriptFileName}

  } else {
    DefaultVendor_StopTranscript $TempTranscriptName
    if {$::osvvm::GotTee} {
      file rename -force ${TempTranscriptName} ${TranscriptFileName}
    } else {
      file copy   -force ${TempTranscriptName} ${TranscriptFileName}
    }
  }
}


proc DefaultVendor_StopTranscript {{FileBaseName ""}} {

  if {$::osvvm::GotTee} {
    # Restore stdout 
    chan pop stdout
    chan pop stderr
  }
}

# -------------------------------------------------
# CloseAllFiles
#   Used by build
#
proc CloseAllFiles {} {
  foreach channel [file channels "file*"] {
      close $channel
  }
}

# -------------------------------------------------
# EndSimulation
#   Used by build
#
proc EndSimulation {} {

  vendor_end_previous_simulation
}


# -------------------------------------------------
# Library Commands
#

# -------------------------------------------------
proc OsvvmLibraryPath {PathToLib} {
  # Make sure $PathToLib ends with VhdlLibraryDirectory/VhdlLibrarySubdirectory
  # If it does not, fix it so it does.
  set AddPathSuffix "" 
  set TailPathToLib [file tail $PathToLib]
  if {$TailPathToLib ne $::osvvm::VhdlLibrarySubdirectory} {
    set AddPathSuffix $::osvvm::VhdlLibrarySubdirectory
  } else {
    set $TailPathToLib [file tail [file dirname $PathToLib]
  }
  if {$TailPathToLib ne $::osvvm::VhdlLibraryDirectory} {
    set AddPathSuffix [file join $::osvvm::VhdlLibraryDirectory $AddPathSuffix]
  }
  set ResolvedPathToLib [file normalize [file join $PathToLib $AddPathSuffix]]    
  return $ResolvedPathToLib
}

proc CreateLibraryPath {PathToLib} {
  variable VhdlLibraryFullPath

  set ResolvedPathToLib ""
  if {$PathToLib eq ""} {
    # Use existing library directory
    set ResolvedPathToLib ${VhdlLibraryFullPath}
  } else {
    # Use specified path directly
    # User can call library LibName [OsvvmLibraryPath LibPath]
    set ResolvedPathToLib [file normalize $PathToLib]
#    set ResolvedPathToLib [OsvvmLibraryPath $PathToLib]
  }
  return $ResolvedPathToLib
}

proc FindLibraryPath {PathToLib} {
  variable VhdlLibraryFullPath

  set ResolvedPathToLib ""
  if {$PathToLib eq ""} {
    # Use existing library directory
    set ResolvedPathToLib ${VhdlLibraryFullPath}
  } else {
    set FullName [file join $PathToLib ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
    set LibsName [file join $PathToLib ${::osvvm::VhdlLibrarySubdirectory}]
    if      {[file isdirectory $FullName]} {
      set ResolvedPathToLib [file normalize $FullName]
    } elseif {[file isdirectory $LibsName]} {
      set ResolvedPathToLib [file normalize $LibsName]
    } elseif {[file isdirectory $PathToLib]} {
      set ResolvedPathToLib [file normalize $PathToLib]
    } else {
      set ResolvedPathToLib [file normalize $FullName]
    }
  }
  return $ResolvedPathToLib
}

proc FindExistingLibraryPath {PathToLib} {
  variable VhdlLibraryFullPath
  variable LibraryDirectoryList
  
  if {$PathToLib eq ""} {
    # Use existing library directory
    return ${VhdlLibraryFullPath}
  } elseif {[info exists LibraryDirectoryList]} {
    # Sorting so shorter paths are first 
    set SortedLibraryDirectoryList [lsort -increasing $LibraryDirectoryList]
    set NormalizedPathToLib [file normalize $PathToLib]
    foreach LibraryDir $SortedLibraryDirectoryList {
      if {[regexp $NormalizedPathToLib $LibraryDir]} {
        return $LibraryDir
      }
    }
    return ""
  }
}

proc FindLibraryPathByName {LibraryName} {
  variable LibraryList

  set PathToLib ""
  
  if {[info exists LibraryList]} {
    # Find Library in list
    set found [lsearch $LibraryList "[string tolower $LibraryName] *"]
    if {$found >= 0} {
      # Lookup Existing Library Directory
      set item [lindex $LibraryList $found]
      set PathToLib [lreplace $item 0 0]
    } 
  }
  
  return $PathToLib
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
  variable VhdlWorkingLibrary
  variable LibraryList
  variable VhdlLibraryFullPath

  CheckWorkingDir
  CheckLibraryInit
# Now created after ResolvedPathToLib is set
#  CreateDirectory $VhdlLibraryFullPath    ; # Create library directory if it does not exist

  set ResolvedPathToLib [CreateLibraryPath $PathToLib]
  set LowerLibraryName [string tolower $LibraryName]

  # Create library directory if it does not exist
  CreateDirectory $ResolvedPathToLib 

  # Needs to be here to activate library (ActiveHDL)
  set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
  # Policy:  If library is already in library list, then use that directory
  if {$found >= 0} {
    # Lookup Existing Library Directory
    set item [lindex $LibraryList $found]
    set ResolvedPathToLib [lreplace $item 0 0]
  }
  puts "library $LibraryName $ResolvedPathToLib"  ; # EchoOsvvmCmd
  CallbackBefore_Library ${LibraryName} ${PathToLib}
  
  if {[catch {vendor_library $LowerLibraryName $ResolvedPathToLib} LibraryErrMsg]} {
    CallbackOnError_Library "library ${LibraryName} path to lib ${ResolvedPathToLib} failed in call to vendor_library"
  } else {
    CallbackAfter_Library ${LibraryName} ${PathToLib}
  }

  set VhdlWorkingLibrary  $LibraryName
}

# -------------------------------------------------
# LinkLibrary - aka map in some vendor tools
#
proc LocalLinkLibrary {LibraryName {PathToLib ""}} {
  variable VhdlWorkingLibrary
  variable VhdlLibraryFullPath
  variable LibraryList

  CheckWorkingDir
  CheckLibraryInit
#  CreateDirectory $VhdlLibraryFullPath    ; # Make library directory if it does not exist

  set ResolvedPathToLib [FindLibraryPath $PathToLib]
  set LowerLibraryName [string tolower $LibraryName]

  if  {[file isdirectory $ResolvedPathToLib]} {
    set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
    # Policy:  If library is already in library list, then use that directory
    if {$found >= 0} {
      # Lookup Existing Library Directory
      set item [lindex $LibraryList $found]
      set ResolvedPathToLib [lreplace $item 0 0]
    }
    if {[catch {vendor_LinkLibrary $LowerLibraryName $ResolvedPathToLib} LibraryErrMsg]} {
      CallbackOnError_Library "LinkLibrary ${LibraryName} ${PathToLib} failed in call to vendor_LinkLibrary"
    }
  } else {
    CallbackOnError_Library "LinkLibrary ${LibraryName} ${PathToLib} failed.  $ResolvedPathToLib is not a directory."
  }
}

proc LinkLibrary {LibraryName {PathToLib ""}} {

  puts "LinkLibrary $LibraryName $PathToLib"      ; # EchoOsvvmCmd
  LocalLinkLibrary $LibraryName $PathToLib 
}

# -------------------------------------------------
#  LinkLibraryDirectory
#
proc LinkLibraryDirectory {{LibraryDirectory ""}} {
  variable CurrentSimulationDirectory
  variable ToolNameVersion

  CheckWorkingDir
  CheckLibraryInit

  set ResolvedLibraryDirectory [FindLibraryPath $LibraryDirectory]
  if  {[file isdirectory $ResolvedLibraryDirectory]} {
    foreach item [glob -nocomplain -directory $ResolvedLibraryDirectory *] {
      if {[file isdirectory $item]} {
        set LibraryName [file rootname [file tail $item]]
        LocalLinkLibrary $LibraryName $ResolvedLibraryDirectory
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

  # If directory changed, update CurrentSimulationDirectory, LibraryList
  CheckWorkingDir

  foreach item $OldLibraryList {
    set LibraryName [lindex $item 0]
    set PathToLib   [lreplace $item 0 0]    ; # handles spaces in path
    LinkLibrary ${LibraryName} ${PathToLib}
  }
}

# -------------------------------------------------
# analyze
#
proc analyze {FileName args} {
  variable AnalyzeErrorCount 
  variable AnalyzeErrorStopCount
  variable ConsecutiveAnalyzeErrors 
   
  if {[catch {LocalAnalyze $FileName {*}$args} errmsg]} {
    CallbackOnError_Analyze $errmsg [concat $FileName $args]
  } else {
    set ConsecutiveAnalyzeErrors 0 
  }
}

proc LocalAnalyze {FileName args} {
  variable VhdlWorkingLibrary
  variable CurrentWorkingDirectory
  variable VhdlAnalyzeOptions
  variable VerilogAnalyzeOptions
  variable CoverageAnalyzeOptions
  variable ExtendedAnalyzeOptions
  variable AnalyzeOptions

  CheckWorkingDir
  CheckLibraryExists
  
  set EffectiveCoverageAnalyzeEnable [expr $::osvvm::CoverageEnable && $::osvvm::CoverageAnalyzeEnable]

  puts "analyze $FileName"                        ; # EchoOsvvmCmd

#  set NormFileName  [file normalize ${CurrentWorkingDirectory}/${FileName}]
  set NormFileName  [ReducePath [file join ${CurrentWorkingDirectory} ${FileName}]]
  set FileExtension [file extension $FileName]

  if {$FileExtension eq ".vhd" || $FileExtension eq ".vhdl"} {
    if {$EffectiveCoverageAnalyzeEnable} {
      set AnalyzeOptions [concat {*}$VhdlAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$CoverageAnalyzeOptions {*}$args]
    } else {
      set AnalyzeOptions [concat {*}$VhdlAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$args]
    }
    CallbackBefore_Analyze $FileName $args
    vendor_analyze_vhdl ${VhdlWorkingLibrary} ${NormFileName} ${AnalyzeOptions}
    CallbackAfter_Analyze $FileName $args
  } elseif {$FileExtension eq ".v" || $FileExtension eq ".sv"} {
    if {$EffectiveCoverageAnalyzeEnable} {
      set AnalyzeOptions [concat {*}$VerilogAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$CoverageAnalyzeOptions {*}$args]
    } else {
      set AnalyzeOptions [concat {*}$VerilogAnalyzeOptions {*}$ExtendedAnalyzeOptions {*}$args]
    }
    CallbackBefore_Analyze $FileName $args
    vendor_analyze_verilog ${VhdlWorkingLibrary} ${NormFileName} ${AnalyzeOptions}
    CallbackAfter_Analyze $FileName $args
  } elseif {$FileExtension eq ".lib"} {
    #  for handling older deprecated file format
    library [file rootname $FileName]
  } else {
    puts "Error: $FileName has unknown extension"
    error "Analyze $FileName unknown extension" 
  }
}

# -------------------------------------------------
# Simulate
#
proc simulate {LibraryUnit args} {
  variable vendor_simulate_started

  set SavedInteractive [GetInteractiveMode] 
  if {!($::osvvm::BuildStarted)} {
    SetInteractiveMode "true"
  }

  set SimulateErrorCode [catch {LocalSimulate $LibraryUnit {*}$args} SimErrMsg]
  set LocalSimulateErrorInfo $::errorInfo
  SetInteractiveMode $SavedInteractive  ; # Restore original value
  
  if {$SimulateErrorCode != 0} {
    # if simulate ended in error, EndSimulation to close open files.
    EndSimulation
    unset vendor_simulate_started
  }
  
  set ReportErrorCode [catch {AfterSimulateReports} ReportErrMsg]
  set LocalReportErrorInfo $::errorInfo

  # Reset Temporary Settings
  if {[info exists ::osvvm::TestCaseName]} {
    unset ::osvvm::TestCaseName
  }
  set ::osvvm::GenericList           ""
  set ::osvvm::GenericNames          ""
  set ::osvvm::GenericOptions        ""
  set ::osvvm::RunningCoSim          "false"
  
  if {$SimulateErrorCode != 0} {
    CallbackOnError_Simulate $SimErrMsg $LocalSimulateErrorInfo [concat $LibraryUnit $args]
  } else {
    set ::osvvm::ConsecutiveSimulateErrors 0 
  }

  if {$ReportErrorCode != 0} {  
    CallbackOnError_AfterSimulateReports $ReportErrMsg $LocalReportErrorInfo
  } 
}

proc LocalSimulate {LibraryUnit args} {
  variable VhdlWorkingLibrary
  variable vendor_simulate_started
  variable TestCaseName
  variable TestCaseFileName
  variable CoverageSimulateOptions
  variable ExtendedSimulateOptions
  variable RanSimulationWithCoverage
  variable SimulateStartTime
  variable SimulateStartTimeMs
  variable SimulateOptions


  if {![info exists TestCaseName]} {
    TestName $LibraryUnit
  }
  # Generics are not finalized until the call to Simulate.  TestCaseName may be set before.
  set TestCaseFileName ${TestCaseName}${::osvvm::GenericNames}

  CheckWorkingDir
  CheckLibraryExists
  CheckSimulationDirs  

  if {[info exists vendor_simulate_started]} {
    EndSimulation
  }
  set vendor_simulate_started 1

  StartSimulateBuildYaml $TestCaseName
  set SimArgs [concat $LibraryUnit {*}$args]
  if {$::osvvm::GenericList ne ""} {
    set SimArgs "$SimArgs [ToGenericCommand $::osvvm::GenericList]"
  }
  puts "simulate $SimArgs"              ; # EchoOsvvmCmd

  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    set RanSimulationWithCoverage "true"
    set SimulateOptions [concat {*}$args {*}$ExtendedSimulateOptions {*}$CoverageSimulateOptions]
  } else {
    set SimulateOptions [concat {*}$args {*}$ExtendedSimulateOptions]
  }

  CallbackBefore_Simulate $LibraryUnit $args
  vendor_simulate ${VhdlWorkingLibrary} ${LibraryUnit} {*}${SimulateOptions}
  CallbackAfter_Simulate  $LibraryUnit $args
}

proc AfterSimulateReports {} {

  Simulate2Html ${::osvvm::TestCaseName} ${::osvvm::TestSuiteName} ${::osvvm::BuildName} ${::osvvm::GenericList}
  
  FinishSimulateBuildYaml 
}

proc RunIfFileExists {ScriptToRun} {
  if {[file exists $ScriptToRun]} {
    source ${ScriptToRun}
  }
}

proc SimulateRunDesignScripts {TestName Directory} {
  variable ToolName
  
  RunIfFileExists [file join ${Directory} ${TestName}.tcl]
  RunIfFileExists [file join ${Directory} ${TestName}_${ToolName}.tcl]
}

proc SimulateRunSubScripts {LibraryUnit Directory} {
  variable TestCaseName 
  variable ToolVendor 
  variable ToolName 
  variable NoGui 
  
  RunIfFileExists [file join ${Directory} ${ToolVendor}.tcl]
  RunIfFileExists [file join ${Directory} ${ToolName}.tcl]
  if {! $NoGui} {
    if {[catch {RunIfFileExists [file join ${Directory} wave.do]} errorMsg]} {
      CallbackOnError_WaveDo $errorMsg $::errorInfo $Directory $LibraryUnit  
    }
  }
  SimulateRunDesignScripts ${LibraryUnit} ${Directory}
  if {$TestCaseName ne $LibraryUnit} {
    SimulateRunDesignScripts ${TestCaseName} ${Directory}
  }
}

proc SimulateRunScripts {LibraryUnit} {
  variable  OsvvmScriptDirectory
  variable  CurrentSimulationDirectory
  variable  CurrentWorkingDirectory
  
  set NormalizedSimulationDirectory [file normalize $CurrentSimulationDirectory]
  set NormalizedWorkingDirectory    [file normalize $CurrentWorkingDirectory]
  set NormalizedScriptDirectory     [file normalize $OsvvmScriptDirectory]
  
  SimulateRunSubScripts ${LibraryUnit} ${CurrentWorkingDirectory}
  if {${NormalizedSimulationDirectory} ne ${NormalizedWorkingDirectory}} {
    SimulateRunSubScripts ${LibraryUnit} ${CurrentSimulationDirectory}
  }
  if {(${NormalizedScriptDirectory} ne ${NormalizedWorkingDirectory}) && (${NormalizedScriptDirectory} ne ${NormalizedSimulationDirectory})} {
    SimulateRunSubScripts ${LibraryUnit} ${OsvvmScriptDirectory}
  }
}

# -------------------------------------------------
proc CoSim {} {

  set ::osvvm::RunningCoSim "true"
  return ""
}

# -------------------------------------------------
proc generic {Name Value} {
  variable GenericList
  variable GenericNames
  variable GenericOptions
  
  lappend GenericList "$Name $Value"
  set GenericNames ${GenericNames}_${Name}_${Value}
  lappend GenericOptions [vendor_generic ${Name} ${Value}]
  
#   return "-g${Name}=${Value}"
#  return [vendor_generic ${Name} ${Value}]
  return ""
}

#--------------------------------------------------------------
proc ToGenericCommand {GenericList} {

  set Commands ""
  if {${GenericList} ne ""} {
    foreach GenericName $GenericList {
      set NewCommand "\[generic [lindex $GenericName 0] [lindex $GenericName 1]\]"
      if {$Commands eq ""} {
        set Commands "$NewCommand"
      } else {
        set Commands "$Commands $NewCommand"
      }
    }
  }
  return $Commands
}

# -------------------------------------------------
proc DoWaves {args} {
  if {![catch {info body vendor_DoWaves} err]} {
    return [vendor_DoWaves {*}$args]
  } else {
    set WaveOptions ""
    if {$args ne ""} {
      foreach wave {*}$args {
        append WaveOptions "-do $wave " 
      }
    }
    return $WaveOptions
  } 
}

# -------------------------------------------------
proc CreateVerilogLibraryParams {prefix} {
  variable LibraryList
  
  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    append VerilogLibraryParams ${prefix} ${LibraryName} " "
  }
  return $VerilogLibraryParams
}

# -------------------------------------------------
proc MergeCoverage {SuiteName MergeName} {
  CreateDirectory [file join $::osvvm::CurrentSimulationDirectory $::osvvm::CoverageDirectory $MergeName]
  vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${MergeName}
}

# -------------------------------------------------
proc FinalizeTestSuite {SuiteName} {
  
  # Merge Code Coverage for the Test Suite if it exists
  if {$::osvvm::RanSimulationWithCoverage eq "true"} {
    CreateDirectory ${::osvvm::CoverageDirectory}/${::osvvm::BuildName}
    CreateDirectory ${::osvvm::CoverageDirectory}/${SuiteName}
    vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${::osvvm::BuildName}
  }
}

# -------------------------------------------------
proc TestSuite {SuiteName} {
  variable TestSuiteName

  puts "TestSuite $SuiteName"                     ; # EchoOsvvmCmd
  

  set FirstRun [expr ![info exists TestSuiteName]]
  if {! $FirstRun} {
    # Finish previous test suite before ending current one
    FinalizeTestSuite $TestSuiteName
    FinishTestSuiteBuildYaml
  }
  StartTestSuiteBuildYaml $SuiteName $FirstRun
  
  set   TestSuiteName $SuiteName

  CheckSimulationDirs
  CreateDirectory [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::ReportsDirectory} ${TestSuiteName}]
  CreateDirectory [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::ResultsDirectory} ${TestSuiteName}]

}

# -------------------------------------------------
proc TestName {Name} {
  variable TestCaseName
  variable TestSuiteName

  if {![info exists TestSuiteName]} {
    if {[info exists VhdlWorkingLibrary]} {
      TestSuite $::osvvm::VhdlWorkingLibrary
    } else {
      TestSuite $::osvvm::DefaultLibraryName
    }
  }

  puts "TestName $Name"
  set TestCaseName $Name
}

# Maintain backward compatibility
proc TestCase {Name} {
  TestName $Name
}


# -------------------------------------------------
# RunTest
#
proc RunTest {FileName {SimName ""} args} {
  variable CompoundCommand

  set RunArgs [concat $FileName $SimName]
  if {$::osvvm::GenericList ne ""} {
    set RunArgs "$RunArgs [ToGenericCommand $::osvvm::GenericList]"
  }
  puts "RunTest $RunArgs"               ; # EchoOsvvmCmd
  set CompoundCommand TRUE

	if {$SimName eq ""} {
    set SimName [file rootname [file tail $FileName]]
    TestName $SimName
  } else {
    set ShortFileName [file rootname [file tail $FileName]]
    TestName "${SimName}(${ShortFileName})"
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
  
  SkipTestBuildYaml $SimName $Reason
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

  set TranscriptExtension $lowerTranscriptType
  if {($lowerTranscriptType ne "html") && ($lowerTranscriptType ne "none")} {
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
  set      VhdlAnalyzeOptions $Options
}
proc GetVhdlAnalyzeOptions {} {
  variable VhdlAnalyzeOptions
  return  $VhdlAnalyzeOptions
}

proc SetVerilogAnalyzeOptions {{Options ""}} {
  variable VerilogAnalyzeOptions
  set      VerilogAnalyzeOptions $Options
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
  set ExtendedAnalyzeOptions $Options
}
proc GetExtendedAnalyzeOptions {} {
  variable ExtendedAnalyzeOptions
  return $ExtendedAnalyzeOptions
}

proc SetExtendedSimulateOptions {{Options ""}} {
  variable ExtendedSimulateOptions
  set ExtendedSimulateOptions $Options
}
proc GetExtendedSimulateOptions {} {
  variable ExtendedSimulateOptions
  return $ExtendedSimulateOptions
}

# -------------------------------------------------
# SetExtendedElaborateOptions, SetExtendedRunOptions
#    Only for simulators that elaborate and run separately - like GHDL
#    Currently only implemented for GHDL
#
proc SetExtendedElaborateOptions {{Options ""}} {
  variable ExtendedElaborateOptions
  set ExtendedElaborateOptions $Options
}
proc GetExtendedElaborateOptions {} {
  variable ExtendedElaborateOptions
  return $ExtendedElaborateOptions
}

proc SetExtendedRunOptions {{Options ""}} {
  variable ExtendedRunOptions
  set ExtendedRunOptions $Options
}
proc GetExtendedRunOptions {} {
  variable ExtendedRunOptions
  return $ExtendedRunOptions
}

# -------------------------------------------------
# SetSaveWaves
#    Important for simulators that do everything from the command line
#    Currently only implemented for GHDL
#
proc SetSaveWaves {{Options "true"}} {
  variable SaveWaves
  set SaveWaves $Options
}
proc GetSaveWaves {} {
  variable SaveWaves
  return $SaveWaves
}

# -------------------------------------------------
# SetInteractiveMode, SetDebugMode, SetLogSignals
#
proc SetInteractiveMode {{Options "true"}} {
  variable SimulateInteractive
  variable AnalyzeErrorStopCount 
  variable SimulateErrorStopCount
  variable SavedAnalyzeErrorStopCount 
  variable SavedSimulateErrorStopCount

  set PreviousSimulateInteractive $SimulateInteractive
  set SimulateInteractive $Options
  
  if {($SimulateInteractive) && !($PreviousSimulateInteractive)} {
    # Only save ErrorStopCounts when options change from FALSE to TRUE
    set SavedAnalyzeErrorStopCount  $AnalyzeErrorStopCount
    set SavedSimulateErrorStopCount $SimulateErrorStopCount
  }

  if {($SimulateInteractive)} {
    # When running interactive, set ErrorStopCounts to 1
    set AnalyzeErrorStopCount  1
    set SimulateErrorStopCount 1
  } else {
    set AnalyzeErrorStopCount  $SavedAnalyzeErrorStopCount 
    set SimulateErrorStopCount $SavedSimulateErrorStopCount
  }
  if {! $::osvvm::DebugIsSet} {
    set ::osvvm::Debug $Options
  }
  if {! $::osvvm::LogSignalsIsSet} {
    set ::osvvm::LogSignals $Options
  }
}
# SetInteractive is deprecated.   
proc SetInteractive {{Options "true"}} {
  puts "SetInteractive is deprecated.  Use SetInteractiveMode instead"
  SetInteractiveMode $Options 
}

proc GetInteractiveMode {} {
  variable SimulateInteractive
  return $SimulateInteractive
}

proc SetDebugMode {{Options "true"}} {
  set ::osvvm::DebugIsSet "true"
  set ::osvvm::Debug $Options
}
proc GetDebugMode {} {
  return $::osvvm::Debug
}

proc SetLogSignals {{Options "true"}} {
  variable LogSignals
  set LogSignalsIsSet "true"
  set LogSignals $Options
}
proc GetLogSignals {} {
  variable LogSignals
  return $LogSignals
}

# -------------------------------------------------
# SetSecondSimulationTopLevel, GetSecondSimulationTopLevel
#
proc SetSecondSimulationTopLevel {{LibraryDotDesignUnit ""}} {  ; # Specify as Libary.DesignUnit 
  variable SecondSimulationTopLevel
  set      SecondSimulationTopLevel $LibraryDotDesignUnit 
}
proc GetSecondSimulationTopLevel {} {
  variable SecondSimulationTopLevel
  return  $SecondSimulationTopLevel
}

# -------------------------------------------------
# SetCoverageEnable, GetCoverageEnable
#
proc SetCoverageEnable {{Enable "true"}} {
  variable CoverageEnable
  if {[string tolower $Enable] eq "true"} {
    set CoverageEnable "true"
  } else {
    set CoverageEnable "false"
  }
  puts "SetCoverageEnable $CoverageEnable"
}
proc GetCoverageEnable {} {
  variable CoverageEnable
  return $CoverageEnable
}

# -------------------------------------------------
# SetCoverageAnalyzeOptions, SetCoverageAnalyzeEnable
#
proc SetCoverageAnalyzeOptions {{Options ""}} {
  set ::osvvm::CoverageAnalyzeOptions $Options
}
proc GetCoverageAnalyzeOptions {} {
  return $::osvvm::CoverageAnalyzeOptions
}

proc SetCoverageAnalyzeEnable {{Enable "true"}} {
  variable CoverageAnalyzeEnable
  if {[string tolower $Enable] eq "true"} {
    set CoverageAnalyzeEnable "true" 
  } else {
    set CoverageAnalyzeEnable "false" 
  }
  puts "SetCoverageAnalyzeEnable $CoverageAnalyzeEnable"
}

proc GetCoverageAnalyzeEnable {} {
  return $::osvvm::CoverageAnalyzeEnable
}

# -------------------------------------------------
# SetCoverageSimulateOptions, SetCoverageSimulateEnable
#
proc SetCoverageSimulateOptions {{Options ""}} {
  set ::osvvm::CoverageSimulateOptions $Options
}
proc GetCoverageSimulateOptions {} {
  return $::osvvm::CoverageSimulateOptions
}

proc SetCoverageSimulateEnable {{Enable "true"}} {
  variable CoverageSimulateEnable
  if {[string tolower $Enable] eq "true"} {
    set CoverageSimulateEnable "true" ;
  } else {
    set CoverageSimulateEnable "false" ;
  }
  puts "SetCoverageSimulateEnable $CoverageSimulateEnable"
}
proc GetCoverageSimulateEnable {} {
  return $::osvvm::CoverageSimulateEnable
}

# -------------------------------------------------
# SetSimulatorResolution, GetSimulatorResolution
#
proc SetSimulatorResolution {SimulatorResolution} {
  variable SimulateTimeUnits
  set SimulateTimeUnits $SimulatorResolution
}

proc GetSimulatorResolution {} {
  variable SimulateTimeUnits
  return $SimulateTimeUnits
}

# -------------------------------------------------
# SetLibraryDirectory
#
proc SetLibraryDirectory {{LibraryDirectory "."}} {
  variable VhdlLibraryParentDirectory
  
  set VhdlLibraryParentDirectory [file normalize $LibraryDirectory]
  
}

proc GetLibraryDirectory {} {
  variable VhdlLibraryParentDirectory

  if {[info exists VhdlLibraryParentDirectory]} {
    return "${VhdlLibraryParentDirectory}"
  } else {
    puts "WARNING:  GetLibraryDirectory VhdlLibraryParentDirectory not defined"
    return ""
  }
}

# -------------------------------------------------
# RemoveLibrary
#   Find name in LibraryList, remove corresponding directory and library mapping
# 
proc UnlinkAndDeleteLibrary {LowerLibraryName ResolvedPathToLib} {

  # Unlink Library from Vendor mapping
  if {[catch {vendor_UnlinkLibrary $LowerLibraryName $ResolvedPathToLib} UnlinkErrMsg]} {
    puts "LibraryError: Unable to unlink $LowerLibraryName $UnlinkErrMsg"
  }
  
  if {$::osvvm::RemoveLibraryDirectoryDeletesDirectory} {
    # All tools except ActiveHDL
    set LibraryPathAndName [file join $ResolvedPathToLib $LowerLibraryName]
    if {[catch {file delete -force $LibraryPathAndName} ErrMsg]} {
      puts "LibraryError: Unable to remove $LibraryPathAndName"
    }
  }
}

proc LocalRemoveLibrary {LowerLibraryName ResolvedPathToLib} {
  variable VhdlWorkingLibrary
  variable LibraryList
  variable LibraryDirectoryList
  variable VhdlLibraryFullPath
  variable RemoveUnmappedLibraries

  
  # Remove Library from OSVVM list if it exists
  if {[info exists LibraryList]} {
    # Remove Library from Osvvm List
    set found [lsearch $LibraryList "${LowerLibraryName} *"]
    if {$found >= 0} {
      # Lookup Existing Library Directory
      set item [lindex $LibraryList $found]
      set ResolvedPathToLib [lreplace $item 0 0]
      # Remove it
      set LibraryList [lreplace $LibraryList $found $found]
    }
  } else {
    set found -1
  }

  # if it is the current working library, unset VhdlWorkingLibrary
  if {[info exists VhdlWorkingLibrary] && $VhdlWorkingLibrary eq $LowerLibraryName} {
    unset VhdlWorkingLibrary
  }

  if {($found >= 0) || $RemoveUnmappedLibraries} {
    # handles case where $ResolvedPathToLib does not exist
    UnlinkAndDeleteLibrary $LowerLibraryName $ResolvedPathToLib
  }
}

proc RemoveLibrary {LibraryName {PathToLib ""}} {
  variable VhdlWorkingLibrary
  variable LibraryList
  variable LibraryDirectoryList
  variable VhdlLibraryFullPath
  variable RemoveUnmappedLibraries

  CheckWorkingDir
  CheckLibraryInit

  set ResolvedPathToLib  [FindLibraryPath $PathToLib]
  set LowerLibraryName   [string tolower $LibraryName]
  
  LocalRemoveLibrary $LowerLibraryName $ResolvedPathToLib
}

# -------------------------------------------------
# RemoveLibraryDirectory
#
proc LocalRemoveLibraryDirectory {ResolvedPathToLib} {
  variable VhdlLibraryParentDirectory
  variable LibraryList
  variable LibraryDirectoryList
  
  # Remove Libraries OSVVM knows about in $ResolvedPathToLib
  if {[info exists LibraryList]} {
    foreach LibraryName $LibraryList {
      set CurrentPathToLib [lreplace $LibraryName 0 0]
      if {$ResolvedPathToLib eq $CurrentPathToLib} {
        LocalRemoveLibrary [lindex $LibraryName 0] $ResolvedPathToLib
      }
    }
  }
    
  # Remove directory from LibraryDirectoryList 
  if {[info exists LibraryDirectoryList] && $LibraryDirectoryList ne ""} {
    set FoundDir [lsearch $LibraryDirectoryList "${ResolvedPathToLib}"]
    if {$FoundDir >= 0} {
      set LibraryDirectoryList [lreplace $LibraryDirectoryList $FoundDir $FoundDir]
    
      if {$::osvvm::RemoveLibraryDirectoryDeletesDirectory} {
        # Policy, do not delete library directory if it still has stuff in it.
        #   Concern, a library parent directory can be anywhere, and hence have source in it.
        set RemainingFiles [glob -nocomplain -directory $ResolvedPathToLib *]
        if {$RemainingFiles eq ""} {
          # Remove Library Directory - All tools except ActiveHDL
          if {[catch {file delete -force $ResolvedPathToLib} ErrMsg]} {
            puts "LibraryError: RemoveLibraryDirectory unable to remove $ResolvedPathToLib"
          }
        } else {
          puts "Warning: RemoveLibraryDirectory $ResolvedPathToLib directory not empty.  Did not delete."
        }
      }
    } else {
      puts "Warning: RemoveLibraryDirectory $ResolvedPathToLib is not in \$::osvvm::LibraryDirectoryList."
    }
  } else {
    puts "Warning: RemoveLibraryDirectory No library directories currently defined."
  }
}

proc RemoveLibraryDirectory {{PathToLib ""}} {
  CheckWorkingDir
  CheckLibraryInit

  set ResolvedPathToLib [FindExistingLibraryPath $PathToLib]
  
  if  {$ResolvedPathToLib ne ""} {
    LocalRemoveLibraryDirectory $ResolvedPathToLib
  } else {
    CallbackOnError_Library "RemoveLibraryDirectory ${PathToLib} failed.  $PathToLib is not in \$::osvvm::LibraryDirectoryList."
  }
}

# RemoveLocalLibraries deprecated and replaced by RemoveLibraryDirectory 
proc RemoveLocalLibraries {} {
  RemoveLibraryDirectory
}

# -------------------------------------------------
# RemoveAllLibraries
#
proc RemoveAllLibraries {} {
  variable LibraryDirectoryList
  variable LibraryList
  variable VhdlWorkingLibrary

  # Remove Library Directories
  if {[info exists LibraryDirectoryList]} {
    # Sorting the list addresses library nesting issues
    set SortedLibraryDirectoryList [lsort -decreasing $LibraryDirectoryList]
    foreach LibraryDir $SortedLibraryDirectoryList {
      LocalRemoveLibraryDirectory $LibraryDir 
    }
  }
  if {[info exists VhdlWorkingLibrary]} {
    unset VhdlWorkingLibrary
  }
  if {[info exists LibraryList]} {
    unset LibraryList
  }
  if {[info exists LibraryDirectoryList]} {
    unset LibraryDirectoryList
  }
}

proc DirectoryExists {DirInQuestion} {
  variable CurrentWorkingDirectory

  if {[info exists CurrentWorkingDirectory]} {
    set LocalWorkingDirectory $CurrentWorkingDirectory
  } else {
    set LocalWorkingDirectory "."
  }
  return [file exists [file join ${LocalWorkingDirectory} ${DirInQuestion}]]
}

proc FileExists {FileName} {
  variable CurrentWorkingDirectory

  if {[info exists CurrentWorkingDirectory]} {
    set LocalWorkingDirectory $CurrentWorkingDirectory
  } else {
    set LocalWorkingDirectory "."
  }
  return [file exists [file join ${LocalWorkingDirectory} ${FileName}]]
}

proc JoinWorkingDirectory {RelativePath} {
  variable CurrentWorkingDirectory
  return [file join $CurrentWorkingDirectory $RelativePath]
}

proc ChangeWorkingDirectory {RelativePath} {
  variable CurrentWorkingDirectory
  set CurrentWorkingDirectory [file join $CurrentWorkingDirectory $RelativePath]
}

proc TimeIt {args} {

  set StartTimeMs [clock milliseconds]
  eval $args
  puts  "Time:  [ElapsedTimeMs $StartTimeMs]"
}

# -------------------------------------------------
# CreateOsvvmScriptSettingsPkg
#   do an operation on a list of items
#
proc CreateOsvvmScriptSettingsPkg {} {
  set FileName [file join ${::osvvm::OsvvmHomeDirectory} "osvvm/OsvvmScriptSettingsPkg_generated.vhd"]
  set NewFileName [file join ${::osvvm::OsvvmHomeDirectory} "osvvm/OsvvmScriptSettingsPkg_new.vhd"]
  set WriteCode [catch {set FileHandle  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} { 
    puts "Not able to open OsvvmScriptSettingsPkg_generated.vhd. Using defaults instead" 
    return 
  }
  puts $FileHandle "-- This file is autogenerated by CreateOsvvmScriptSettingsPkg" 
  puts $FileHandle "package body OsvvmScriptSettingsPkg is" 
  puts $FileHandle "  constant OSVVM_HOME_DIRECTORY        : string := \"[file normalize ${::osvvm::OsvvmHomeDirectory}]\" ;"
  if {${::osvvm::OsvvmTemporaryOutputDirectory} eq ""} {
    puts $FileHandle "  constant OSVVM_OUTPUT_DIRECTORY      : string := \"\" ;"
  } else {
    puts $FileHandle "  constant OSVVM_OUTPUT_DIRECTORY      : string := \"${::osvvm::OsvvmTemporaryOutputDirectory}/\" ;"
  }
  puts $FileHandle "  constant OSVVM_BUILD_YAML_FILE       : string := \"${::osvvm::OsvvmBuildYamlFile}\" ;"
  puts $FileHandle "  constant OSVVM_TRANSCRIPT_YAML_FILE  : string := \"${::osvvm::TranscriptYamlFile}\" ;"
  puts $FileHandle "end package body OsvvmScriptSettingsPkg ;" 
  close $FileHandle
  if {[FileDiff $FileName $NewFileName]} {
    file rename -force $NewFileName $FileName
  } else {
    file delete -force $NewFileName
  }
}

# AutoGenerateFile 
#    Extract from FileName everything up to and including the pattern in the string
#    Write Extracted contents to NewFileName
#    Example call: set ErrorCode [catch {AutoGenerateFile $FileName $NewFileName "--!! Autogenerated:"} errmsg]
proc AutoGenerateFile {FileName NewFileName AutoGenerateMarker} {
  set ReadCode [catch {set ReadFile [open $FileName r]} ReadErrMsg]
  if {$ReadCode} { return }
  set LinesOfFile [split [read $ReadFile] \n]
  close $ReadFile
  
  set WriteCode [catch {set WriteFile  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} { return }
  foreach OneLine $LinesOfFile {
    puts $WriteFile $OneLine
    if { [regexp ${AutoGenerateMarker} $OneLine] } {
      break
    }
  }
  close $WriteFile
}

proc FileDiff {File1 File2} {
  set ReadFile1Code [catch {set FileHandle1 [open $File1 r]} ReadErrMsg]
  if {$ReadFile1Code} {return "true"}
  set LinesOfFile1   [split [read $FileHandle1] \n]
  close $FileHandle1
  set LengthOfFile1  [llength $$LinesOfFile1]
  
  set ReadFile2Code [catch {set FileHandle2 [open $File2 r]} ReadErrMsg]
  if {$ReadFile2Code} {return "true"}
  set LinesOfFile2   [split [read $FileHandle2] \n]
  close $FileHandle2
  set LengthOfFile2  [llength $$LinesOfFile2]

  if {$LengthOfFile1 != $LengthOfFile2} {return "true"}
  
  for {set i 0} {$i < $LengthOfFile1} {incr i} {
    if {[lindex $LinesOfFile1 $i] ne [lindex $LinesOfFile2 $i]} {return "true"}
  }
  return "false"
}



# Don't export the following due to conflicts with Tcl built-ins
# map

namespace export analyze simulate build include library RunTest SkipTest TestSuite TestName TestCase
namespace export generic DoWaves
namespace export IterateFile StartTranscript StopTranscript 
namespace export RemoveLibrary RemoveLibraryDirectory RemoveAllLibraries RemoveLocalLibraries 
namespace export CreateDirectory
namespace export SetVHDLVersion GetVHDLVersion SetSimulatorResolution GetSimulatorResolution
namespace export SetLibraryDirectory GetLibraryDirectory SetTranscriptType GetTranscriptType
namespace export LinkLibrary ListLibraries LinkLibraryDirectory LinkCurrentLibraries
namespace export FileExists DirectoryExists
namespace export SetExtendedAnalyzeOptions GetExtendedAnalyzeOptions
namespace export SetExtendedSimulateOptions GetExtendedSimulateOptions
namespace export SetVhdlAnalyzeOptions GetVhdlAnalyzeOptions SetVerilogAnalyzeOptions GetVerilogAnalyzeOptions 
namespace export SetCoverageEnable GetCoverageEnable
namespace export SetCoverageAnalyzeOptions GetCoverageAnalyzeOptions
namespace export SetCoverageAnalyzeEnable GetCoverageAnalyzeEnable
namespace export SetCoverageSimulateOptions GetCoverageSimulateOptions
namespace export SetCoverageSimulateEnable GetCoverageSimulateEnable
namespace export SetExtendedElaborateOptions GetExtendedElaborateOptions
namespace export SetExtendedRunOptions GetExtendedRunOptions
namespace export SetSaveWaves GetSaveWaves
namespace export SetInteractiveMode GetInteractiveMode
namespace export SetDebugMode GetDebugMode
namespace export SetLogSignals GetLogSignals
namespace export SetSecondSimulationTopLevel GetSecondSimulationTopLevel
namespace export MergeCoverage
namespace export OsvvmLibraryPath
namespace export JoinWorkingDirectory ChangeWorkingDirectory
namespace export EndSimulation 
namespace export CreateOsvvmScriptSettingsPkg 
namespace export FindLibraryPathByName CoSim

# Exported only for tesing purposes
namespace export FindLibraryPath CreateLibraryPath FindExistingLibraryPath TimeIt


# end namespace ::osvvm
}
