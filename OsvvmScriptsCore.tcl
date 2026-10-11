#  File Name:         OsvvmScriptsCore.tcl
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
#     6/2025   2025.06    Moved SimulateRunScripts to OsvvmScriptsSimulateSupport.tcl.
#     1/2025   2025.01    Added GetTimeString.
#                         Moved CreateOsvvmScriptSettingsPkg and FindOsvvmSettingsDirectory to OsvvmScriptsFileCreate.tcl
#     7/2024   2024.07    Updated LocalInclude to better restore state if the include fails
#                         Fixed settings in SetLogSignals.
#     5/2024   2024.05    Updated for refactor of Simulate2Html.   Renamed in prep for breaking file into smaller chunks.
#     3/2024   2024.03    Updated CreateOsvvmScriptSettingsPkg and added FindOsvvmSettingsDirectory
#     9/2023   2023.09    Updated messaging for file not found by build/include
#                         Made UnsetLibraryVars visible
#     7/2023   2023.07    Added calls to MergeRequirements and Requirements2Html
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
#  Copyright (c) 2018 - 2025 by SynthWorks Design Inc.
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
  # Run the OSVVM start-up script `StartUpShared.tcl` again.
  #
  # Sources `StartUpShared.tcl` from `$::osvvm::OsvvmScriptDirectory` in the global namespace. This reloads all OSVVM
  # scripts and settings.
  puts "source $::osvvm::OsvvmScriptDirectory/StartUpShared.tcl"
  eval "source $::osvvm::OsvvmScriptDirectory/StartUpShared.tcl"
}


namespace eval ::osvvm {

proc LoadVendorScripts {ScriptFile} {
  # Source a script file from the OSVVM script directory.
  #  ScriptFile - Name of the script file, relative to `$::osvvm::OsvvmScriptDirectory`.
  #
  # Prints the `source` command before running it.
  puts "source $::osvvm::OsvvmScriptDirectory/${ScriptFile}"
  source $::osvvm::OsvvmScriptDirectory/${ScriptFile}
}


# -------------------------------------------------
# IterateFile
#   do an operation on a list of items
#
proc ReadListFromFile {RawFileWithNames} {
  # Read a file and return its lines.
  #  RawFileWithNames - Path to the file, relative to the current working directory.
  #
  # Returns the list of lines of the file, including empty lines.
  #
  # See also: [IterateFile]
  set FileWithNames [file join $::osvvm::CurrentWorkingDirectory $RawFileWithNames]
  set FileHandle [open $FileWithNames]
  set ListOfNames [split [read $FileHandle] \n]
  close $FileHandle
  return $ListOfNames
}



proc IterateFile {RawActionForName RawFileWithNames} {
  # Run a command for each line of a file.
  #  RawActionForName - Command to run for each line, e.g. `analyze` or `include`.
  #  RawFileWithNames - Path to the file with one name per line, relative to the current working directory.
  #
  # Each non-empty line is appended to $RawActionForName and evaluated, so a line may contain further arguments. A line
  # starting with `#` is a comment. A comment line whose second word is `library` calls [library] with its third word.
  #
  # If $RawFileWithNames doesn't exist, the two arguments are tried in reversed order (deprecated form).
  #
  # `include` uses it for `*.dirs` and `*.files` files.

#  puts "$FileWithNames"
  set FileWithNames [file join $::osvvm::CurrentWorkingDirectory $RawFileWithNames]
  set ActionForName $RawActionForName
  if {![file exists ${FileWithNames}]} {
    # Deprecated format with action and file name reversed
    set FileWithNames [file join $::osvvm::CurrentWorkingDirectory $RawActionForName]
    set ActionForName $RawFileWithNames
  }

  set FileHandle [open $FileWithNames]
  set ListOfNames [split [read $FileHandle] \n]
  close $FileHandle

  foreach OneName $ListOfNames {
    # skip blank lines
    if {[string length $OneName] > 0} {
      # use # as comment character
      if {[string index $OneName 0] ne "#"} {
        # puts "$ActionForName ${OneName}"  ; # already printed by Action
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
  # Print a message line by line with a prefix.
  #  Prefix         - Text put in front of each line, e.g. `Error:`.
  #  RawMessageList - Message; several lines are separated by newlines.
  #
  # A line matching $Prefix as a whole (glob pattern, case-insensitive) is printed unchanged.
  #
  # The vendor scripts use it to print error messages of a tool.
  foreach Message [split $RawMessageList \n] {
#!!    if {[regexp -nocase "$Prefix" $Message]} { }
    if {[string match -nocase "$Prefix" $Message]} {
      # Only add prefix if message does not already have it
      puts "$Message"
    } else {
      puts "$Prefix $Message"
    }
  }
}

# -------------------------------------------------
# FindIncludeFile
#   finds an include file using directory, file base name, or file with extension to locate the file
#
proc FindIncludeFile {Path_Or_File} {
  # Find the script file for a name given to [include] or [build].
  #  Path_Or_File - File, directory, or file name without extension, relative to the current working directory.
  #
  # `.` and `..` in the path are resolved. If $Path_Or_File is a file, it's returned. Otherwise the first existing file
  # of the following list is returned:
  #
  # 1. `<Path_Or_File>.pro`; for a directory `<Directory>/<DirectoryName>.pro`
  # 1. `<Directory>/build.pro`
  # 1. the same base name with extension `.tcl`, `.do`, `.dirs`, `.files` and `.vhd`
  #
  # An error with $Path_Or_File as message is raised if no file is found.
  #
  # Returns the path of the script file.

  set JoinName [file join ${::osvvm::CurrentWorkingDirectory} ${Path_Or_File}]
  set NormName [ReducePath $JoinName]
  # Normalize to handle ".." and "."
  set NameToHandle [file tail [file normalize $NormName]]

  if {[file isfile $NormName]} {
    return $NormName
  } else {
    if {[file isdirectory $NormName]} {
      # Path_Or_File is directory name
      set FileBaseName ${NormName}/[file rootname ${NameToHandle}]
    } else {
      # Path_Or_File is file name without an extension
      set FileBaseName ${NormName}
    }
    # Determine which if any project files exist
    set FileProName    ${FileBaseName}.pro
    set BuildProName   [file join $NormName build.pro]
    set FileTclName    ${FileBaseName}.tcl
    set FileDoName     ${FileBaseName}.do
    set FileDirsName   ${FileBaseName}.dirs
    set FileFilesName  ${FileBaseName}.files
    set FileVhdlName   ${FileBaseName}.vhd

    if {[file isfile ${FileProName}]} {
      return ${FileProName}

    } elseif {[file isfile ${BuildProName}]} {
      return ${BuildProName}

    } elseif {[file isfile ${FileTclName}]} {
      return ${FileTclName}

    } elseif {[file isfile ${FileDoName}]} {
      return ${FileDoName}

    } elseif {[file isfile ${FileDirsName}]} {
      return ${FileDirsName}

    } elseif {[file isfile ${FileFilesName}]} {
      return ${FileFilesName}

    } elseif {[file isfile ${FileVhdlName}]} {
      return ${FileVhdlName}

    } else {
      error $Path_Or_File

    }
  }
}


# -------------------------------------------------
# include
#   finds and sources a project file
#
proc include {Path_Or_File args} {
  # Include a project script.
  #  Path_Or_File - Script file, directory, or file name without extension, relative to the current working directory.
  #  args         - Arguments passed to the script in `argv`.
  #
  # [FindIncludeFile] locates the file. A `*.pro` or `*.tcl` file is sourced, a `*.do` file is run with the simulator's
  # `do` command, a `*.vhd` or `*.vhdl` file is run with [RunTest], a `*.dirs` file includes each listed name, any other
  # file analyzes each listed name. While the script runs, the current working directory is the script's directory;
  # afterwards it is restored.
  #
  # Calls `CallbackBefore_Include` and `CallbackAfter_Include`; if no file is found, `CallbackOnError_FindIncludeFile`.
  #
  # See also: [build]
  variable CurrentWorkingDirectory

  CallbackBefore_Include $Path_Or_File
  puts "include $Path_Or_File $args"                    ; # EchoOsvvmCmd

  set FindFileErrorCode [catch {set IncludeFile [FindIncludeFile $Path_Or_File]} FindErrMsg]
  if {$FindFileErrorCode != 0} {
    CallbackOnError_FindIncludeFile $Path_Or_File include
  } else {
    LocalInclude $IncludeFile {*}$args
  }
  CallbackAfter_Include $Path_Or_File
}

proc LocalInclude {PathAndFile args} {
  # Run a script file with its own working directory and arguments.
  #  PathAndFile - Path of the script file, as found by [FindIncludeFile].
  #  args        - Arguments passed to the script.
  #
  # Creates the default library if no library is active. Saves the current working directory, `argv0`, `argv`, `argc`,
  # `ARGC` and `ARGV`, sets them for the script, runs `LocalRunInclude` and restores them. An error of the script is
  # raised again after restoring.
  variable CurrentWorkingDirectory

# probably remove.  Redundant with analyze and simulate
  # If a library does not exist, then create the default
  CheckLibraryExists

  #  Save CurrentWorkingDirectory, $::argv0, $::argv, $::argc
  set SaveCurrentWorkingDirectory ${CurrentWorkingDirectory}
  if {[info exists ::argv]} {
    set SaveArgv0 $::argv0
    set SaveArgv  $::argv
    set SaveArgc  $::argc
  } else {
    set SaveArgv0  0
    set SaveArgv   0
    set SaveArgc   0
  }

  set ::argv0   [file tail $PathAndFile]
  set ::argv    $args
  set ::argc    [llength $args]
  set ::ARGC    $::argc
  set ::ARGV(0) $::argv0
  set index  1
  foreach arg $::argv {set ::ARGV($index) $arg ; incr index 1}

  set IncludeErrorCode [catch {LocalRunInclude $PathAndFile {*}$args} IncludeErrMsg]
  set IncludeErrorInfo $::errorInfo

  #  Restore CurrentWorkingDirectory, $::argv0, $::argv, $::argc
  set CurrentWorkingDirectory ${SaveCurrentWorkingDirectory}
  set ::argv0   $SaveArgv0
  set ::argv    $SaveArgv
  set ::argc    $SaveArgc
  set ::ARGC    $::argc
  set ::ARGV(0) $::argv0
  set index  1
  foreach arg $::argv {set ::ARGV($index) $arg ; incr index 1}

  # Re-signal error after restoring CurrentWorkingDirectory and argv ...
  if {$IncludeErrorCode != 0} {
    error $IncludeErrMsg $IncludeErrorInfo
  }
}

proc LocalRunInclude {PathAndFile args} {
  # Run a script file depending on its extension.
  #  PathAndFile - Path of the script file.
  #  args        - Arguments of the script; already set in `argv` by `LocalInclude`.
  #
  # Sets the current working directory to the directory of $PathAndFile, then:
  #
  # `.pro`, `.tcl` - `source` the file.
  # `.do` - run the file with the simulator's `do` command.
  # `.vhd`, `.vhdl` - [RunTest] the file.
  # `.dirs` - [include] each name listed in the file.
  # any other - [analyze] each name listed in the file.
  variable CurrentWorkingDirectory

  # Use the RootDir of PathAndFile as the CurrentWorkingDirectory
  set RootDir  [file dirname $PathAndFile]
  puts "set CurrentWorkingDirectory ${RootDir}"
  set CurrentWorkingDirectory ${RootDir}

  # Handle the file based on its extension
  set FileExtension [file extension $PathAndFile]

  if {$FileExtension eq ".pro" || $FileExtension eq ".tcl"} {
    puts "source ${PathAndFile}"
    source ${PathAndFile}
  } elseif {$FileExtension eq ".do"} {
    # Do files can be simulator specific and require the simulator "do" to run them
    puts "do ${PathAndFile}"
    do ${PathAndFile}
  } elseif {$FileExtension eq ".vhd" | $FileExtension eq ".vhdl" } {
    puts "RunTest ${PathAndFile}"
    RunTest ${PathAndFile}
  } elseif {$FileExtension eq ".dirs"} {
    # Path_Or_File is <name>.dirs
    puts "IterateFile ${PathAndFile} include"
    IterateFile ${PathAndFile} "include"
  } else {
  #  was elseif {$FileExtension eq ".files"}
    # Path_Or_File is <name>.files or other extension
    puts "IterateFile ${PathAndFile} analyze"
    IterateFile ${PathAndFile} "analyze"
  }
}


# -------------------------------------------------
# BeforeBuildCleanUp
#
proc BeforeBuildCleanUp {} {
  # Reset the state of a previous build before a new build starts.
  #
  # Resets the analyze, simulate and script error counters and `RanSimulationWithCoverage`, unsets the test case and
  # test suite names, ends a simulation that is still running, deletes a left-over temporary transcript YAML file and
  # clears the current working directory.
  variable RanSimulationWithCoverage "false"
  variable vendor_simulate_started
  variable TestCaseName
  variable TestSuiteName
  variable TempTranscriptYamlFile
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
  if {[file exists ${TempTranscriptYamlFile}]} {
    file delete -force -- ${TempTranscriptYamlFile}
  }

  set ::osvvm::CurrentWorkingDirectory ""
}

# -------------------------------------------------
# First time BuildName called sets the BuildName - later calls are ignored
proc BuildName {ParamBuildName} {
  # Set the name of the current build.
  #  ParamBuildName - Name of the build.
  #
  # Overrides the default build name, which is derived from the script name. The name is used for the build's output
  # directory, log file and reports. Only the first call in a build counts; a call after the first simulation started is
  # ignored with a message.
  #
  # Returns an empty string, so it can be used as an argument, e.g. `build Script.pro [BuildName Nightly]`.
  LocalSetBuildName $ParamBuildName
  set ::osvvm::BuildNameCalled "true"
}

proc LocalSetBuildName {ParamBuildName} {
  # Set the build name and the build output directory, unless they're already fixed.
  #  ParamBuildName - Name of the build.
  #
  # Sets `BuildName`, `LastBuildName` and `OsvvmBuildOutputDirectory` to
  # `<CurrentSimulationDirectory>/<OutputBaseDirectory>/<ParamBuildName>`, if the build output directory wasn't created
  # yet and [BuildName] wasn't called. After the output directory was created, a message says the name is ignored.
  if {$::osvvm::HaveNotCreatedBuildOutputDirectory && !$::osvvm::BuildNameCalled} {
    variable BuildName      $ParamBuildName
    variable LastBuildName  $ParamBuildName
    variable OsvvmBuildOutputDirectory [file join $::osvvm::CurrentSimulationDirectory $::osvvm::OutputBaseDirectory $ParamBuildName]
  } elseif {!$::osvvm::HaveNotCreatedBuildOutputDirectory} {
    puts "BuildName $ParamBuildName Ignored.  Called after starting simulate."
  }
#  else { puts "BuildName $ParamBuildName Ignored.  BuildName already called."}
}

# -------------------------------------------------
proc CreateDefaultBuildName {Path_Or_File} {
  # Derive the default build name from a script path.
  #  Path_Or_File - Path of the build script.
  #
  # Returns the script's base name, if the script's directory has the same name, else
  # `<DirectoryName>_<ScriptBaseName>`.

  # Create the Log File Name
  # Normalize to elaborate names, especiallyStartUp when Path_Or_File is "."
  set NormPathOrFile [file normalize ${Path_Or_File}]
  set NormDir        [file dirname $NormPathOrFile]
  set NormDirName    [file tail $NormDir]
  set NormTail       [file tail $NormPathOrFile]
  set NormTailRoot   [file rootname $NormTail]

  if {$NormDirName eq $NormTailRoot} {
    # <Parent Dir>_<Script Name>.log
#    set LocalBuildName [file tail [file dirname $NormDir]]_${NormTailRoot}
    # <Script Name>.log
    set LocalBuildName ${NormTailRoot}
  } else {
    # <Dir Name>_<Script Name>.log
    set LocalBuildName ${NormDirName}_${NormTailRoot}
  }
  return $LocalBuildName
}

# -------------------------------------------------
# build
#
proc build {{Path_Or_File "."} args} {
  # Run a project script as a build: include it with a new log file and reports.
  #  Path_Or_File - Script file, directory, or file name without extension, relative to the current working directory.
  #  args         - Arguments passed to the script in `argv`.
  #
  # If a build is already running, it does the same as [include]. Otherwise it:
  #
  # - locates the script with [FindIncludeFile],
  # - resets the state of the previous build and derives the build name from the script, unless [BuildName] set it,
  # - starts the transcript, includes the script and finishes the last test suite,
  # - merges requirements and, if a simulation ran with code coverage, merges and reports the code coverage,
  # - writes the build's YAML file, the HTML, JUnit XML and index reports and the log file, if `GenerateOsvvmReports` is
  #   true.
  #
  # Errors are reported through `CallbackOnError_Build` and `CallbackOnError_AfterBuildReports` after the reports were
  # written. If `ExitOnBuildDone` is true and the session is neither interactive nor in debug mode, the tool is exited:
  # with exit code 1 if the build failed and `FailOnTestCaseErrors` is true, or if report errors occurred and
  # `FailOnReportErrors` is true; otherwise with exit code 0.
  #
  # See also: [include] [BuildName] [TestSuite]
  variable AnalyzeErrorCount
  variable SimulateErrorCount
  variable ScriptErrorCount
  variable BuildErrorInfo ""
  variable Log2ErrorInfo
  variable BuildStarted
  variable BuildName
  variable BuildErrorCode 0

  if {$BuildStarted} {
    include $Path_Or_File $args
  } else {
    set FindFileErrorCode [catch {set IncludeFile [FindIncludeFile $Path_Or_File]} FindErrMsg]
    if {$FindFileErrorCode != 0} {
      # With error handling here, directories do not get created if cannot find Path_Or_File
      CallbackOnError_FindIncludeFile $Path_Or_File Build
    } else {
      BeforeBuildCleanUp

      set BuildStarted "true"
      CheckWorkingDir

      if {$BuildName eq ""} {
        # default setting
        LocalSetBuildName [CreateDefaultBuildName $IncludeFile]
      }

      StartTranscript  ;# uses temporary name rather than BuildName - allows script to change BuildName

      #  Catch any errors from the build and handle them below
      set BuildErrorCode [catch {LocalBuild $IncludeFile {*}$args} BuildErrMsg]
      set LocalBuildErrorInfo $::errorInfo
      if {$BuildErrorCode != 0} {
        CheckSimulationDirs  ; ##?? Creates ReportsDirectory for builds that fail.  Refactor later.
      }

      # reset setting back after build finishes
      set ::osvvm::BuildNameCalled "false"

      if {$::osvvm::GenerateOsvvmReports} {
        set ReportYamlErrorCode [catch {FinishBuildYaml $BuildName} BuildYamlErrMsg]
        set LocalBuildYamlErrorInfo $::errorInfo
        if {($ReportYamlErrorCode != 0) && ($::osvvm::TclDebug || $::osvvm::Debug)} {
          # No prior call back, only depends on opening file that has already been opened
          puts "FinishBuildYaml \$LocalBuildYamlErrorInfo: $::errorInfo"
        }

        # Try to create reports, even if the build failed
        set ReportErrorCode [catch {AfterBuildReports $BuildName} ReportsErrMsg]
        set LocalReportErrorInfo $::errorInfo
      } else {
        set ReportYamlErrorCode 0
        set ReportErrorCode 0
      }

      StopTranscript ${BuildName}

      set BuildStarted "false"

      if {$::osvvm::GenerateOsvvmReports} {
        # Cannot generate html log files until transcript is closed - previous step
        set Log2ErrorCode [catch {Log2Osvvm $::osvvm::TranscriptFileName} ReportsErrMsg]
        set Log2ErrorInfo $::errorInfo

        WriteIndexYaml $BuildName
        Index2Html
      } else {
        set Log2ErrorCode 0
      }

      set BuildName ""
      set ::osvvm::HaveNotCreatedBuildOutputDirectory "true"

      #
      #  Wrap up with error handling via call backs
      #
      # Run Callbacks on Error after trying to produce all reports
      if {$AnalyzeErrorCount > 0 || $SimulateErrorCount > 0} {
        CallbackOnError_Build $Path_Or_File "Failed with Analyze Errors: $AnalyzeErrorCount and/or Simulate Errors: $SimulateErrorCount" $LocalBuildErrorInfo
      } elseif {$BuildErrorCode != 0} {
        CallbackOnError_Build $Path_Or_File $BuildErrMsg $LocalBuildErrorInfo
      }

      if {($ReportErrorCode != 0) || ($ScriptErrorCount != 0)} {
        CallbackOnError_AfterBuildReports $LocalReportErrorInfo
      }
      # Exit on Test Case Errors
      if {$::osvvm::ExitOnBuildDone && !($::osvvm::SimulateInteractive || $::osvvm::Debug)} {
        if {($::osvvm::BuildStatus ne "PASSED") && ($::osvvm::FailOnTestCaseErrors)} {
          ExitCode 1 "Test finished with Test Case Errors."
        }
        # Exit on Report / Script Errors?
        if {($ReportYamlErrorCode != 0) || ($ReportErrorCode != 0)} {
          # End Simulation with errors
          if {$::osvvm::FailOnReportErrors} {
              EndSimulation
            ExitCode 1 "Test finished with either Report or Script (wave.do) errors."
          }
        }
        ExitCode 0
      }
    }
  }
}

proc ExitCode {Code {Message ""}} {
  # Print a message and exit the tool.
  #  Code    - Exit code.
  #  Message - Message printed before exiting.
  puts $Message
  exit $Code
}

proc LocalBuild {Path_Or_File args} {
  # Run the body of a build.
  #  Path_Or_File - Path of the build script, as found by [FindIncludeFile].
  #  args         - Arguments passed to the script.
  #
  # Starts the build YAML file (if `GenerateOsvvmReports` is true), includes the script between `CallbackBefore_Build`
  # and `CallbackAfter_Build`, creates the build's output directories and finishes the last test suite. Then merges the
  # requirements of the build into `<ReportsDirectory>/<BuildName>_req.yml` and writes their HTML and CSV reports. If a
  # simulation ran with code coverage, the code coverage of the build is merged (`vendor_MergeCodeCoverage`) and
  # reported (`vendor_ReportCodeCoverage`).
  variable TestSuiteStartTimeMs
  variable RanSimulationWithCoverage
  variable TestSuiteName
  variable BuildName  ; # required to allow script to change BuildName

  puts "" ; # ensure that the next print is at the start of a line
  puts "build $Path_Or_File"                      ; # EchoOsvvmCmd

  if {$::osvvm::GenerateOsvvmReports} {
    StartBuildYaml
  }

  CallbackBefore_Build ${Path_Or_File}
  LocalInclude ${Path_Or_File} {*}$args
  CallbackAfter_Build ${Path_Or_File}

##?? Needed to create ReportsDirectory since it is created dynamically
##?? Test and then refactor so it only creates ReportsDirectory
  CheckSimulationDirs

  if {[info exists TestSuiteName]} {
    FinalizeTestSuite $TestSuiteName
    FinishTestSuiteBuildYaml
    unset TestSuiteName
  }

  # Build is done
  # Merge Requirements for Build
  set RequirementsSourceDir   [file join ${::osvvm::ReportsDirectory} ${BuildName}]
  set RequirementsResultsFile [file join ${::osvvm::ReportsDirectory} ${BuildName}_req.yml]
  MergeRequirements $RequirementsSourceDir $RequirementsResultsFile
  Requirements2Html $RequirementsResultsFile
  Requirements2Csv  $RequirementsResultsFile

  if {$RanSimulationWithCoverage eq "true"} {
    vendor_MergeCodeCoverage  $BuildName $::osvvm::CoverageDirectory ""
    vendor_ReportCodeCoverage $BuildName $::osvvm::CoverageDirectory

    # Remembered for ExportCodeCoverage after the build
    set ::osvvm::CoverageExportBuildName $BuildName
    set ::osvvm::CoverageExportDirectory $::osvvm::CoverageDirectory
    if {$::osvvm::CoverageExportEnable} {
      vendor_ExportCodeCoverage $BuildName $::osvvm::CoverageDirectory "" $::osvvm::CoverageExportOptions
    }
  }

}

proc AfterBuildReports {ParamBuildName} {
  # Create the reports of a finished build.
  #  ParamBuildName - Name of the build.
  #
  # Copies the temporary build YAML file to `<OsvvmBuildOutputDirectory>/<ParamBuildName>.yml`, deletes the temporary
  # file and creates the HTML and JUnit XML build reports with [CreateBuildReports]. In interactive mode with
  # `OpenBuildHtmlFile` true, the build report is opened. Finally the build status is printed.

  # short sleep to allow the file to close
  after 1000
  set BuildYamlFile [file join ${::osvvm::OsvvmBuildOutputDirectory} ${ParamBuildName}.yml]
#  file rename -force ${::osvvm::OsvvmTempYamlFile} ${BuildYamlFile}
  file copy -force ${::osvvm::OsvvmTempYamlFile} ${BuildYamlFile}
  catch [file delete -force ${::osvvm::OsvvmTempYamlFile}]
  CreateBuildReports ${BuildYamlFile}
  if {($::osvvm::SimulateInteractive) && ($::osvvm::OpenBuildHtmlFile)} {
    OpenBuildHtml ${ParamBuildName}
  }

  ReportBuildStatus
}

proc OpenIndex {} {
  # Open the index of all builds (`index.html`) in a browser.
  #
  # See also: [OpenBuildHtml]
  LocalOpenHtml $::osvvm::OsvvmIndexHtmlFile
}

proc OpenBuildHtml {{ParamBuildName ""}} {
  # Open the HTML report of a build in a browser.
  #  ParamBuildName - Name of the build. Empty: the last build.
  #
  # Opens `<OutputBaseDirectory>/<ParamBuildName>/<ParamBuildName>.html`. The vendor procedure `vendor_OpenBuildHtml`
  # opens it, if the tool defines one, else the default (Windows only).
  #
  # See also: [OpenIndex]
  if {$ParamBuildName eq ""} {
      set ParamBuildName $::osvvm::LastBuildName
  }
#  set BuildHtmlFile [file join ${::osvvm::OsvvmBuildOutputDirectory} ${ParamBuildName}.html]
  set BuildHtmlFile [file join ${::osvvm::OutputBaseDirectory} ${ParamBuildName} ${ParamBuildName}.html]
  LocalOpenHtml $BuildHtmlFile $ParamBuildName
}

proc LocalOpenHtml {HtmlFile {ParamBuildName ""}} {
  # Open an HTML file with the tool's or the default viewer.
  #  HtmlFile       - Path of the HTML file.
  #  ParamBuildName - Name of the build, passed to `vendor_OpenBuildHtml`.
  #
  # Calls `vendor_OpenBuildHtml`, if the tool defines it, else `DefaultVendor_OpenBuildHtml`.
  if {[llength [info procs vendor_OpenBuildHtml]] > 0} {
    vendor_OpenBuildHtml $HtmlFile $ParamBuildName
  } else {
    DefaultVendor_OpenBuildHtml $HtmlFile
  }
}

proc DefaultVendor_OpenBuildHtml {BuildHtmlFile} {
  # Open an HTML file with the operating system's default program.
  #  BuildHtmlFile - Path of the HTML file.
  #
  # Works on Windows only (`start`); on other operating systems nothing happens.
  if {[info exists ::env(OS)]} {
    if {[regexp {[Ww]indows} $::env(OS)]} {
      exec {*}[auto_execok start] "$BuildHtmlFile"
    }
  }
}

# -------------------------------------------------
# CreateDirectory - Create directory if does not exist
#
proc CreateDirectory {Directory} {
  # Create a directory, if it doesn't exist.
  #  Directory - Path of the directory.
  #
  # Prints a message when the directory is created. Missing parent directories are created as well.
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
  # Track a change of the simulator's current directory.
  #
  # If the current directory (`pwd`) differs from `CurrentSimulationDirectory`, the simulation directory is updated. If
  # libraries were created in the old simulation directory, the library directory moves to the new directory and the
  # active library and the library lists are forgotten. Creates the temporary output directory in the simulation
  # directory.
  #
  # Used by [library], [analyze], [simulate] and [build].
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
  }
  CreateDirectory [file join ${CurrentSimulationDirectory} ${::osvvm::OsvvmTempOutputDirectory}]
}

# -------------------------------------------------
# CheckLibraryInit
#   Used by library
#
proc CheckLibraryInit {} {
  # Initialize the library directory, if it wasn't set.
  #
  # If the library parent directory is still the invalid default, it is set to the current directory. Sets
  # `VhdlLibraryFullPath` to `<VhdlLibraryParentDirectory>/<VhdlLibraryDirectory>/<VhdlLibrarySubdirectory>`.
  variable VhdlLibraryParentDirectory
  variable VhdlLibraryFullPath

  if { [file tail ${VhdlLibraryParentDirectory}] eq $::osvvm::InvalidLibraryDirectory} {
    set VhdlLibraryParentDirectory [pwd]
  }
  if { ${VhdlLibraryParentDirectory} eq [pwd]} {
#    # Local Library Directory - use OutputBaseDirectory
#    set VhdlLibraryFullPath [file join ${VhdlLibraryParentDirectory} ${::osvvm::OutputBaseDirectory} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
    # Local Library Directory - use CurrentSimulationDirectory
    set VhdlLibraryFullPath [file join ${VhdlLibraryParentDirectory} ${::osvvm::VhdlLibraryDirectory} ${::osvvm::VhdlLibrarySubdirectory}]
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
  # Make sure a library is active.
  #
  # If no library is active, the default library (`DefaultLibraryName`, `DefaultLib`) is created and activated with
  # [library].
  variable VhdlWorkingLibrary

  if {![info exists VhdlWorkingLibrary]} {
    library $::osvvm::DefaultLibraryName
  }
}

# -------------------------------------------------
# SetAndCreateBuildOutputDirectory
#
proc SetAndCreateBuildOutputDirectory {} {
  # Set and create the output directory of the current build.
  #
  # During a build, the directory is `<CurrentSimulationDirectory>/<OutputBaseDirectory>/<BuildName>`. It's created once
  # per build; an existing directory of the same name is deleted first. Outside a build, the temporary output directory
  # is used. In both cases the HTML theme files are copied into it.
variable HaveNotCreatedBuildOutputDirectory
variable OsvvmBuildOutputDirectory
variable BuildName

#  if {$::osvvm::BuildName ne ""} {}
  if {$::osvvm::BuildStarted} {
    if {$HaveNotCreatedBuildOutputDirectory} {
      # When run as part of a build, use the BuildName
      set OsvvmBuildOutputDirectory [file join $::osvvm::CurrentSimulationDirectory $::osvvm::OutputBaseDirectory $::osvvm::BuildName]
      if {[file exists $OsvvmBuildOutputDirectory]} {
        puts "New OsvvmBuildOutputDirectory matches old one. Deleting old $OsvvmBuildOutputDirectory "
        file delete -force $OsvvmBuildOutputDirectory
      }
      CreateDirectory $OsvvmBuildOutputDirectory
      CopyHtmlThemeFiles ${::osvvm::OsvvmScriptDirectory} ${OsvvmBuildOutputDirectory} $::osvvm::HtmlThemeSubdirectory
      # Only run this code once per build
      set HaveNotCreatedBuildOutputDirectory "false"
    }
  } else {
    # When run simulate runs stand-alone, put output in temporary directory
    set OsvvmBuildOutputDirectory [file join $::osvvm::CurrentSimulationDirectory $::osvvm::OsvvmTempOutputDirectory]
    CopyHtmlThemeFiles ${::osvvm::OsvvmScriptDirectory} ${::osvvm::OsvvmBuildOutputDirectory} $::osvvm::HtmlThemeSubdirectory
  }
}


# -------------------------------------------------
# CheckSimulationDirs
#   Used by simulate
#
proc CheckSimulationDirs {} {
  # Create the output directories of a simulation.
  #
  # Creates the temporary output directory and the build output directory, and sets and creates:
  #
  # `ReportsDirectory` - `<OsvvmBuildOutputDirectory>/<ReportsSubdirectory>`, with a subdirectory per test suite
  #   (`ReportsTestSuiteDirectory`) and per build.
  # `ResultsDirectory` - `<OsvvmBuildOutputDirectory>/<ResultsSubdirectory>`, with a subdirectory per test suite.
  # `CoverageDirectory` - `<OsvvmBuildOutputDirectory>/<CoverageSubdirectory>`; its test suite subdirectory only if code
  #   coverage is enabled for simulation.
  variable OsvvmBuildOutputDirectory
  variable CurrentSimulationDirectory
  variable BuildName
  variable TestSuiteName
  variable ReportsDirectory
  variable ReportsTestSuiteDirectory
  variable ResultsDirectory
  variable CoverageDirectory

  # Temporary directory used by VHDL simulations and scripts in collaboration with VHDL simulations
  # Also must be created before ?StartTranscript?
  CreateDirectory [file join ${CurrentSimulationDirectory} ${::osvvm::OsvvmTempOutputDirectory}]

  SetAndCreateBuildOutputDirectory

  set ReportsDirectory     [file join ${OsvvmBuildOutputDirectory} ${::osvvm::ReportsSubdirectory}]
  if {[info exists TestSuiteName]} {
    set ReportsTestSuiteDirectory [file join ${::osvvm::ReportsDirectory} ${TestSuiteName}]
    CreateDirectory $ReportsTestSuiteDirectory
  }
  CreateDirectory [file join $ReportsDirectory $BuildName]

  set ResultsDirectory     [file join ${OsvvmBuildOutputDirectory} ${::osvvm::ResultsSubdirectory}]
  if {[info exists TestSuiteName]} {
    CreateDirectory [file join $ResultsDirectory $TestSuiteName]
  } else {
    CreateDirectory [file join $ResultsDirectory]
  }

  set CoverageDirectory    [file join ${OsvvmBuildOutputDirectory} ${::osvvm::CoverageSubdirectory}]
  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    CreateDirectory [file join $CoverageDirectory $::osvvm::TestSuiteName]
  }
}

# -------------------------------------------------
# ReducePath
#   Remove "." and ".." from path
#
proc ReducePath {PathIn} {
  # Remove `.` and resolvable `..` elements from a path.
  #  PathIn - Path to reduce.
  #
  # The path is reduced as text; the file system isn't accessed. A leading `..` that can't be resolved is kept.
  #
  # Returns the reduced path, or `.` if nothing remains.

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
proc StartTranscript {} {
  # Start writing the transcript (log) of a build.
  #
  # The transcript is written to a temporary file in the simulation directory, as the build name may still change. Calls
  # `vendor_StartTranscript`, if the tool defines it, else `DefaultVendor_StartTranscript`. [build] calls it.
  #
  # See also: [StopTranscript]

  set TempTranscriptName [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::OsvvmTempLogFile}]

#  if {[llength [info procs vendor_StartTranscript]] > 0} {}
  if {[info procs vendor_StartTranscript] ne ""} {
    vendor_StartTranscript $TempTranscriptName
  } else {
    DefaultVendor_StartTranscript $TempTranscriptName
  }
}

proc DefaultVendor_StartTranscript {FileName} {
  # Start a transcript file for tools without their own transcript command.
  #  FileName - Path of the transcript file.
  #
  # If the `tee` package is available (`GotTee`), stdout and stderr are copied into the file. Otherwise the file only
  # gets a note that log files don't work in this tool.

  if {$::osvvm::GotTee} {
    set LogFile  [open ${FileName} w]
    tee channel stderr $LogFile
    tee channel stdout $LogFile
  } else {
    set LogFile  [open ${FileName} w]
    puts  $LogFile "Log files do not currently work in these tools"
    close $LogFile
  }
}

# -------------------------------------------------
# StopTranscript
#   Used by build
#
proc StopTranscript {{FileBaseName ""}} {
  # Stop writing the transcript (log) and move it into the build's log directory.
  #  FileBaseName - Base name of the log file, usually the build name.
  #
  # Creates the build output directory and its log directory `<OsvvmBuildOutputDirectory>/<LogSubdirectory>`, stops the
  # transcript (`vendor_StopTranscript`, if the tool defines it, else `DefaultVendor_StopTranscript`) and moves the
  # temporary transcript to `<LogDirectory>/<FileBaseName>.log`. Sets `TranscriptFileName`. [build] calls it.
  #
  # See also: [StartTranscript]
  variable TranscriptFileName
  variable OsvvmBuildOutputDirectory
  variable LogDirectory

  flush stdout
  SetAndCreateBuildOutputDirectory     ; # and delete old one if it exists
  set LogDirectory         [file join ${::osvvm::OsvvmBuildOutputDirectory} ${::osvvm::LogSubdirectory}]
  CreateDirectory          $LogDirectory

  set TempTranscriptName [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::OsvvmTempLogFile}]
  set TranscriptFileName [file join ${LogDirectory} ${FileBaseName}.log]
  # if {[llength [info procs vendor_StopTranscript]] > 0} {}
  if {[info procs vendor_StopTranscript] ne ""} {
    vendor_StopTranscript $TempTranscriptName
    if {[file exists $TempTranscriptName]} {
      file copy   -force ${TempTranscriptName} ${TranscriptFileName}
      file delete -force ${TempTranscriptName}
    }
  } else {
    DefaultVendor_StopTranscript $TempTranscriptName
    if {[file exists $TempTranscriptName]} {
      if {$::osvvm::GotTee} {
  #       file rename -force ${TempTranscriptName} ${TranscriptFileName}
        file copy   -force ${TempTranscriptName} ${TranscriptFileName}
        file delete -force ${TempTranscriptName}
      } else {
        file copy   -force ${TempTranscriptName} ${TranscriptFileName}
      }
    }
  }
}


proc DefaultVendor_StopTranscript {{FileBaseName ""}} {
  # Stop a transcript started by `DefaultVendor_StartTranscript`.
  #  FileBaseName - Not used.
  #
  # If the `tee` package is available (`GotTee`), the copying of stdout and stderr ends.

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
  # Close all open file channels.
  #
  # Closes every channel whose name starts with `file`. Used by vendor scripts when a simulation ends.
  foreach channel [file channels "file*"] {
      close $channel
  }
}

# -------------------------------------------------
# EndSimulation
#   Used by build
#
proc EndSimulation {} {
  # End the running simulation.
  #
  # Calls `vendor_end_previous_simulation`, which quits the simulation in the tool and closes its files.

  vendor_end_previous_simulation
}


# -------------------------------------------------
# Library Commands
#

# -------------------------------------------------
proc OsvvmLibraryPath {PathToLib} {
  # Extend a path with the library directory and subdirectory.
  #  PathToLib - Path to a library parent directory.
  #
  # Appends `<VhdlLibraryDirectory>/<VhdlLibrarySubdirectory>` (by default `VHDL_LIBS/<tool version>`) to $PathToLib,
  # leaving out the parts it already ends with.
  #
  # Returns the normalized path.
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
  # Resolve the directory in which a library is created.
  #  PathToLib - Library directory. Empty: the current library directory.
  #
  # Returns `VhdlLibraryFullPath` for an empty $PathToLib, else the normalized $PathToLib.
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
  # Resolve the directory of existing libraries.
  #  PathToLib - Library directory or one of its parents. Empty: the current library directory.
  #
  # For a non-empty $PathToLib, the first existing directory of the following list is used:
  #
  # 1. `<PathToLib>/<VhdlLibraryDirectory>/<VhdlLibrarySubdirectory>`
  # 1. `<PathToLib>/<VhdlLibrarySubdirectory>`
  # 1. `<PathToLib>`
  #
  # If none exists, the first is used.
  #
  # Returns the normalized library directory; `VhdlLibraryFullPath` for an empty $PathToLib.
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
  # Find a library directory known to OSVVM.
  #  PathToLib - Library directory or a part of its path. Empty: the current library directory.
  #
  # Searches the known library directories (`LibraryDirectoryList`), shortest first, for one matching the normalized
  # $PathToLib as regular expression.
  #
  # Returns the matching library directory, `VhdlLibraryFullPath` for an empty $PathToLib, or an empty string if none
  # matches.
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
  # Find the directory of a library known to OSVVM.
  #  LibraryName - Name of the library; case-insensitive.
  #
  # Returns the library's directory, or an empty string if OSVVM doesn't know the library.
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
proc IsLibraryInList {LibraryName} {
  # Look up a library in the list of libraries known to OSVVM.
  #  LibraryName - Name of the library, in lower case.
  #
  # Creates empty library lists, if they don't exist.
  #
  # Returns the library's index in `LibraryList`, or `-1` if it isn't in the list.
  variable LibraryList
  variable LibraryDirectoryList

  if {![info exists LibraryList]} {
    # Create Initial empty list
    set LibraryList ""
    set LibraryDirectoryList ""
  }
#  set LowerLibraryName [string tolower $LibraryName]
  set found [lsearch $LibraryList "${LibraryName} *"]
  return $found
}

proc AddLibraryToList {LibraryName PathToLib} {
  # Add a library to the list of libraries known to OSVVM.
  #  LibraryName - Name of the library, in lower case.
  #  PathToLib   - Directory of the library.
  #
  # Adds `<LibraryName> <PathToLib>` to `LibraryList` and $PathToLib to `LibraryDirectoryList`, unless already present.
  #
  # Returns the library's previous index in `LibraryList`, or `-1` if it was added.
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
  # Print the libraries known to OSVVM.
  #
  # Prints one line per library: its name (lower case) and its directory.
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
  # Make a library the active (working) library; create it, if it doesn't exist.
  #  LibraryName - Name of the library.
  #  PathToLib   - Directory in which the library is created. Empty: the directory set by [SetLibraryDirectory].
  #
  # If OSVVM already knows the library, its known directory is used. The tool's library is created or mapped by
  # `vendor_library` with the name in lower case. [analyze] and [simulate] use the active library.
  #
  # Calls `CallbackBefore_Library` and `CallbackAfter_Library`; on an error, `CallbackOnError_Library`.
  #
  # See also: [LinkLibrary] [SetLibraryDirectory] [ListLibraries] [RemoveLibrary]
  variable VhdlWorkingLibrary
  variable LibraryList
  variable VhdlLibraryFullPath

  CheckWorkingDir
  CheckLibraryInit

  set ResolvedPathToLib [CreateLibraryPath $PathToLib]
  set LowerLibraryName  [string tolower $LibraryName]

  # Create library directory if it does not exist
  CreateDirectory $ResolvedPathToLib

  # Needs to be here to activate library (ActiveHDL)
#  set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
  set found [IsLibraryInList $LowerLibraryName]
  # Policy:  If library is already in library list, then use that directory
  if {$found >= 0} {
    # Lookup Existing Library Directory
    set item [lindex $LibraryList $found]
    set ResolvedPathToLib [lreplace $item 0 0]
  }
  puts "library $LibraryName $ResolvedPathToLib"  ; # EchoOsvvmCmd
  CallbackBefore_Library ${LibraryName} ${PathToLib}

  if {[catch {vendor_library $LowerLibraryName $ResolvedPathToLib} LibraryErrMsg]} {
    CallbackOnError_Library $LibraryErrMsg ${LibraryName} ${ResolvedPathToLib} vendor_library
  } else {
    CallbackAfter_Library ${LibraryName} ${PathToLib}
  }
  if {$found < 0} {
    set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
    # Could check found here or remove the return value from AddLibraryToList
  }

  set VhdlWorkingLibrary  $LibraryName
}

# -------------------------------------------------
# LinkLibrary - aka map in some vendor tools
#
proc LocalLinkLibrary {LibraryName {PathToLib ""}} {
  # Map an existing library into the tool.
  #  LibraryName - Name of the library.
  #  PathToLib   - Library directory or one of its parents, see [FindLibraryPath]. Empty: the current library directory.
  #
  # If OSVVM already knows the library, its known directory is used. Calls `vendor_LinkLibrary` with the name in lower
  # case and adds the library to the known libraries. Calls `CallbackOnError_LinkLibrary`, if the directory doesn't
  # exist or `vendor_LinkLibrary` fails. The active library doesn't change.
  variable VhdlWorkingLibrary
  variable VhdlLibraryFullPath
  variable LibraryList

  CheckWorkingDir
  CheckLibraryInit
#  CreateDirectory $VhdlLibraryFullPath    ; # Make library directory if it does not exist

  set ResolvedPathToLib [FindLibraryPath $PathToLib]
  set LowerLibraryName [string tolower $LibraryName]

  if  {[file isdirectory $ResolvedPathToLib]} {
#    set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
    set found [IsLibraryInList $LowerLibraryName]
    # Policy:  If library is already in library list, then use that directory
    if {$found >= 0} {
      # Lookup Existing Library Directory
      set item [lindex $LibraryList $found]
      set ResolvedPathToLib [lreplace $item 0 0]
    }
    if {[catch {vendor_LinkLibrary $LowerLibraryName $ResolvedPathToLib} LibraryErrMsg]} {
      CallbackOnError_LinkLibrary "${LibraryName} ${PathToLib} failed in call to vendor_LinkLibrary"
    }
    if {$found < 0} {
      set found [AddLibraryToList $LowerLibraryName $ResolvedPathToLib]
      # Could check found here or remove the return value from AddLibraryToList
    }
  } else {
    CallbackOnError_LinkLibrary  "${LibraryName} ${PathToLib} failed.  $ResolvedPathToLib is not a directory."
  }
}

proc LinkLibrary {LibraryName {PathToLib ""}} {
  # Map an existing library into the tool, without making it the active library.
  #  LibraryName - Name of the library.
  #  PathToLib   - Library directory or one of its parents. Empty: the directory set by [SetLibraryDirectory].
  #
  # Use it for libraries created elsewhere, e.g. by another project.
  #
  # See also: [LinkLibraryDirectory] [library]

  puts "LinkLibrary $LibraryName $PathToLib"      ; # EchoOsvvmCmd
  LocalLinkLibrary $LibraryName $PathToLib
}

# -------------------------------------------------
#  LinkLibraryDirectory
#
proc LinkLibraryDirectory {{LibraryDirectory ""}} {
  # Map all libraries in a library directory into the tool.
  #  LibraryDirectory - Library directory or one of its parents. Empty: the directory set by [SetLibraryDirectory].
  #
  # Each subdirectory of the resolved library directory is linked as a library named after the subdirectory. If the
  # directory doesn't exist, a message is printed once OSVVM is initialized.
  #
  # See also: [LinkLibrary]
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
  # Map all libraries known to OSVVM again, after the current directory changed.
  #
  # Tools keep library mappings per directory. After `cd`, call it to update the simulation directory and link all known
  # libraries again.
  #
  # See also: [LinkLibrary]
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
  # Analyze (compile) an HDL source file into the active library.
  #  FileName - Path of the source file, relative to the current working directory.
  #  args     - Further analyze options for this file.
  #
  # The language follows from the file extension:
  #
  # `.vhd`, `.vhdl` - VHDL, analyzed by `vendor_analyze_vhdl`.
  # `.v`, `.sv`, `.vh` - Verilog or SystemVerilog, analyzed by `vendor_analyze_verilog`.
  # `.lib` - deprecated: activates the library named like the file.
  #
  # The options are the VHDL or Verilog analyze options ([SetVhdlAnalyzeOptions], [SetVerilogAnalyzeOptions]), the
  # extended analyze options ([SetExtendedAnalyzeOptions]), the code coverage analyze options (only if
  # [SetCoverageEnable] and [SetCoverageAnalyzeEnable] are true) and $args. If no library is active, the default library
  # is created.
  #
  # An error is reported through `CallbackOnError_Analyze`; the following [simulate] is then skipped.
  #
  # See also: [library] [SetVHDLVersion] [RunTest]
  variable AnalyzeErrorCount
  variable AnalyzeErrorStopCount
  variable ConsecutiveAnalyzeErrors

  if {[catch {LocalAnalyze $FileName {*}$args} errmsg]} {
    set ::osvvm::LastAnalyzeHasError TRUE
    CallbackOnError_Analyze $errmsg [concat $FileName $args]
  } else {
    set ::osvvm::LastAnalyzeHasError FALSE
    set ConsecutiveAnalyzeErrors 0
  }
}

proc LocalAnalyze {FileName args} {
  # Analyze a source file; [analyze] without the error handling.
  #  FileName - Path of the source file, relative to the current working directory.
  #  args     - Further analyze options for this file.
  #
  # Computes the analyze options (stored in `AnalyzeOptions`), records the file in `LastAnalyzedFile` and calls
  # `vendor_analyze_vhdl` or `vendor_analyze_verilog` between `CallbackBefore_Analyze` and `CallbackAfter_Analyze`. The
  # file is passed relative to the current directory. An unknown extension raises an error.
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

#  set NormFileName  [ReducePath [file join ${CurrentWorkingDirectory} ${FileName}]]  ;# 2024.09 implementation
  set BaseNormFileName  [file normalize [file join ${CurrentWorkingDirectory} ${FileName}]]
  # Questa requires paths without spaces.   Triming down to relative paths helps.
  set NormFileName  [::fileutil::relative [pwd] $BaseNormFileName]
  set ::osvvm::LastAnalyzedFile $BaseNormFileName

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
  } elseif {$FileExtension eq ".v" || $FileExtension eq ".sv" || $FileExtension eq ".vh"} {
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
proc NoNullRangeWarning  {} {
  # Return the option that suppresses null range warnings.
  #
  # The Aldec vendor scripts redefine it to return their `-nowarn` option; for other tools it returns nothing.
  #
  # Returns an empty string.
  return ""
  # -- -nowarn COMP96_0119
}


# -------------------------------------------------
# Simulate
#
proc simulate {LibraryUnit args} {
  # Simulate (elaborate and run) a design unit of the active library.
  #  LibraryUnit - Name of the top-level entity or configuration.
  #  args        - Further simulate options; `[generic Name Value]`, `[DoWaves File]` and `[CoSim]` can be used here.
  #
  # The test case name is $LibraryUnit, unless [TestName] set it before; generics set with [generic] are appended to the
  # name of its result files. The options are $args, the extended simulate options ([SetExtendedSimulateOptions]) and
  # the code coverage simulate options. The elaboration additionally gets the code coverage elaborate options
  # ([SetCoverageElaborateOptions]); each simulator passes the options to the step that needs them. Code coverage
  # options are used only if [SetCoverageEnable] and [SetCoverageSimulateEnable] are true. A simulation still running is
  # ended first. `vendor_simulate` runs the simulation.
  #
  # After the simulation, the test case's reports are created (if `GenerateOsvvmReports` is true), and the test case
  # name, generics and co-simulation setting are reset.
  #
  # If the last [analyze] failed, the simulation is skipped and recorded as failed. Called outside a build, the
  # simulation runs as a build of its own in interactive mode.
  #
  # Errors are reported through `CallbackOnError_Simulate` and `CallbackOnError_AfterSimulateReports`.
  #
  # See also: [RunTest] [TestName] [generic]
  variable vendor_simulate_started
  variable TestCaseName
  variable TestCaseStatus  "FAILED"

  if {$::osvvm::LastAnalyzeHasError} {
    AnalyzeFailed $LibraryUnit "Previous analyze failed.  Skipping simulate."
    ClearGenericSettings
    if {[info exists TestCaseName]} {
      unset TestCaseName
    }
    set ::osvvm::LastAnalyzeHasError "false"

    CallbackOnError_Simulate "Last analyze failed" " " [concat $LibraryUnit $args]

  } elseif {!($::osvvm::BuildStarted)} {
    # called simulate from console - run as a build with just simulate in it.
    set SavedInteractive [GetInteractiveMode]
    set SavedCurrentWorkingDirectory $::osvvm::CurrentWorkingDirectory
    CheckWorkingDir
    SetInteractiveMode "true"
    set  SimProFileName [file join $::osvvm::CurrentSimulationDirectory $::osvvm::OsvvmTempOutputDirectory OsvvmSimulateBuild.pro]
    set  SimProFile     [open ${SimProFileName} w]
    puts $SimProFile "simulate $LibraryUnit $args"
    close $SimProFile

    catch [build $SimProFileName [BuildName $LibraryUnit]]  ;# Errors to std_output, but interactive and stopping anyway

    SetInteractiveMode $SavedInteractive  ; # Restore original value
    set ::osvvm::CurrentWorkingDirectory $SavedCurrentWorkingDirectory   ;#Restore original value
    catch [file delete -force $SimProFile]

  } else {
    set SimulateErrorCode [catch {LocalSimulate $LibraryUnit {*}$args} SimErrMsg]
    set LocalSimulateErrorInfo $::errorInfo

    if {($SimulateErrorCode != 0) && (!$::osvvm::SimulateInteractive)} {
      # if simulate ended in error, EndSimulation to close open files.
      # $osvvm_testbench/AlertLogPkg tests require extra run after simulate
      # so checking only SimulateInteractive not sufficient
      EndSimulation
      unset vendor_simulate_started
    }

    if {$::osvvm::GenerateOsvvmReports} {
      set ReportErrorCode [catch {AfterSimulateReports} ReportErrMsg]
      set LocalReportErrorInfo $::errorInfo
    } else {
      set ReportErrorCode 0
    }

    # Reset Temporary Settings
    if {[info exists ::osvvm::TestCaseName]} {
      unset ::osvvm::TestCaseName
    }
    set ::osvvm::GenericDict           ""
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
}

proc LocalSimulate {LibraryUnit args} {
  # Start a simulation; [simulate] without the error handling and reports.
  #  LibraryUnit - Name of the top-level entity or configuration.
  #  args        - Further simulate options.
  #
  # Sets the test case name, if not set, creates the output directories, ends a running simulation, starts the test
  # case's entry in the build YAML file and calls `vendor_simulate` between `CallbackBefore_Simulate` and
  # `CallbackAfter_Simulate`. It sets the effective options `vendor_simulate` uses:
  #
  # - `ElaborateOptions`: with code coverage enabled for simulation, the code coverage elaborate options
  #   ([SetCoverageElaborateOptions]). The user's extended elaborate options ([SetExtendedElaborateOptions]) aren't
  #   part of them; the vendor adds them.
  # - `SimulateOptions`: *args*, the extended simulate options and, with code coverage enabled for simulation, the
  #   code coverage simulate options ([SetCoverageSimulateOptions]).
  #
  # With code coverage enabled for simulation, `RanSimulationWithCoverage` is set.
  variable VhdlWorkingLibrary
  variable vendor_simulate_started
  variable TestCaseName
  variable TestCaseFileName
  variable CoverageElaborateOptions
  variable CoverageSimulateOptions
  variable ExtendedSimulateOptions
  variable RanSimulationWithCoverage
  variable ElaborateOptions
  variable SimulateOptions


  if {![info exists TestCaseName]} {
    SetTestName $LibraryUnit
    # Incorporate generics (if any) into TestCaseFileName
    set TestCaseFileName ${TestCaseName}${::osvvm::GenericNames}
  }

  CheckWorkingDir
  CheckLibraryExists
  CheckSimulationDirs

  if {[info exists vendor_simulate_started]} {
    EndSimulation
  }
  set vendor_simulate_started 1

  StartSimulateBuildYaml $TestCaseName
  set SimArgs [concat $LibraryUnit {*}$args]
  if {$::osvvm::GenericDict ne ""} {
    set SimArgs "$SimArgs [ToGenericCommand $::osvvm::GenericDict]"
  }
  puts "simulate $SimArgs"              ; # EchoOsvvmCmd

  if {$::osvvm::CoverageEnable && $::osvvm::CoverageSimulateEnable} {
    set RanSimulationWithCoverage "true"
    set ElaborateOptions [concat {*}$CoverageElaborateOptions]
    set SimulateOptions  [concat {*}$args {*}$ExtendedSimulateOptions {*}$CoverageSimulateOptions]
  } else {
    set ElaborateOptions ""
    set SimulateOptions  [concat {*}$args {*}$ExtendedSimulateOptions]
  }

    CallbackBefore_Simulate $LibraryUnit $args
    vendor_simulate ${VhdlWorkingLibrary} ${LibraryUnit} {*}${SimulateOptions}
    CallbackAfter_Simulate  $LibraryUnit $args
}

proc AfterSimulateReports {} {
  # Create the reports of a finished test case.
  #
  # Moves the test case's YAML and transcript files into the build's reports and results directories, writes
  # `<TestCaseFileName>_run.yml` with the test case settings, creates the test case's HTML report and finishes its entry
  # in the build YAML file.

  SimulateDoneMoveTestCaseFiles
  set TestCaseSettingsFile [file join ${::osvvm::ReportsTestSuiteDirectory} ${::osvvm::TestCaseFileName}_run.yml]

  WriteTestCaseSettingsYaml $TestCaseSettingsFile

  Simulate2Html $TestCaseSettingsFile $::osvvm::OsvvmBuildOutputDirectory

  FinishSimulateBuildYaml
}


proc FindProjectFile { ProjectFile } {
  # Find a file in the simulation directory or the OSVVM script directory.
  #  ProjectFile - Name of the file.
  #
  # Returns the path in `CurrentSimulationDirectory` if the file exists there, else in `OsvvmScriptDirectory`, else an
  # empty string.
  variable  OsvvmScriptDirectory
  variable  CurrentSimulationDirectory

  if { [file exists       [file join $CurrentSimulationDirectory $ProjectFile]] } {
    set PathToProjectFile [file join $CurrentSimulationDirectory $ProjectFile]
  } elseif { [file exists [file join $OsvvmScriptDirectory       $ProjectFile]] } {
    set PathToProjectFile [file join $OsvvmScriptDirectory       $ProjectFile]
  } else {
    set PathToProjectFile ""
  }
  return $PathToProjectFile
}

# -------------------------------------------------
proc CoSim {} {
  # Mark the next simulation as a co-simulation.
  #
  # Use it in the options of [simulate]: `simulate Tb [CoSim]`. Sets `RunningCoSim` until the simulation ends.
  #
  # Returns an empty string.

  set ::osvvm::RunningCoSim "true"
  return ""
}

#--------------------------------------------------------------
proc RemoveFilePathChars {PathString} {
  # Make a value usable in a file name.
  #  PathString - Value, e.g. a generic's value.
  #
  # Returns $PathString with each `/` replaced by `_` and the first `:` removed.
  return [regsub {:} [regsub -all {\/} ${PathString} "_"] ""]
}

# -------------------------------------------------
proc ExportOptions {args} {
  # Add options for the next [ExportCodeCoverage].
  #  args - Options of the simulator's export command, `--relative=.` for NVC.
  #
  # Appends the options to `ExportOptionsList`, which the next [ExportCodeCoverage] uses and clears. Written as an
  # argument of [ExportCodeCoverage], like [generic] for [simulate].
  #
  # Returns an empty string, so it can be written as an argument: `ExportCodeCoverage [ExportOptions ...]`.
  #
  # See also: [SetCoverageExportOptions]
  variable ExportOptionsList
  append ExportOptionsList " " $args
  return ""
}

proc ExportCodeCoverage {{FileName ""} args} {
  # Export the code coverage of the last build that collected code coverage into a well-known data format.
  #  FileName - The file to write. Empty: the simulator's default name in the code coverage directory, for NVC
  #             `<BuildName>_code_cov.cobertura.xml`.
  #  args     - `[ExportOptions ...]`.
  #
  # The options are those of [SetCoverageExportOptions] followed by those of [ExportOptions], which are cleared
  # afterwards. `vendor_ExportCodeCoverage` writes the file:
  #
  # |Simulator|Format|Default file|
  # |---|---|---|
  # |NVC|Cobertura XML (`nvc --cover-export`)|`<BuildName>_code_cov.cobertura.xml`|
  # |Siemens tools|coverage report XML (`vcover report -xml`)|`<BuildName>_code_cov.questa.xml`|
  # |Aldec tools|UCDB XML (`acdb2xml`)|`<BuildName>_code_cov.ucdb.xml`|
  #
  # Siemens tools: Questa, Siemens, VSim, Visualizer. Aldec tools: Riviera-PRO, Active-HDL, ASim, VSimSA. Other
  # simulators print that the export isn't supported yet. Without a build that collected code coverage, it's an
  # error. With [SetCoverageExportEnable], every build that collected code coverage exports it this way at its end.
  #
  # See also: [SetCoverageExportEnable]
  variable ExportOptionsList

  set Options [concat {*}$::osvvm::CoverageExportOptions {*}$ExportOptionsList]
  set ExportOptionsList ""
  if {$::osvvm::CoverageExportBuildName eq ""} {
    error "ExportCodeCoverage: No build collected code coverage yet."
  }
  puts "ExportCodeCoverage $FileName"           ; # EchoOsvvmCmd
  vendor_ExportCodeCoverage $::osvvm::CoverageExportBuildName $::osvvm::CoverageExportDirectory $FileName $Options
}

proc generic {Name Value} {
  # Set a generic of the top-level design unit for the next simulation.
  #  Name  - Name of the generic.
  #  Value - Value of the generic.
  #
  # Use it in the options of [simulate] or [RunTest]: `simulate Tb [generic Width 8]`. The generic is recorded in
  # `GenericDict`, appended as `_<Name>_<Value>` to the names of the test case's result files, and translated into the
  # tool's option by `vendor_generic`. The settings are cleared after the simulation.
  #
  # Returns an empty string.
  variable GenericDict
  variable GenericNames
  variable GenericOptions

  dict append GenericDict $Name $Value
  set GenericNames ${GenericNames}_${Name}_[RemoveFilePathChars ${Value}]
#x  lappend GenericOptions [vendor_generic ${Name} ${Value}]
  append GenericOptions " " [vendor_generic ${Name} ${Value}]
  return ""
}

# -------------------------------------------------
proc ClearGenericSettings {} {
  # Forget all generics set with [generic].
  set ::osvvm::GenericDict ""
  set ::osvvm::GenericNames ""
  set ::osvvm::GenericOptions ""
}

#--------------------------------------------------------------
proc ToGenericCommand {GenericDict} {
  # Convert generics into [generic] commands.
  #  GenericDict - Generic names and values.
  #
  # Returns `[generic Name Value]` per generic, separated by spaces; used to echo a [simulate] or [RunTest] call.

  set Commands ""
  if {${GenericDict} ne ""} {
    foreach {GenericName GenericValue} $GenericDict {
      set NewCommand "\[generic $GenericName $GenericValue\]"
      if {$Commands eq ""} {
        set Commands "$NewCommand"
      } else {
        set Commands "$Commands $NewCommand"
      }
    }
  }
  return $Commands
}

#--------------------------------------------------------------
proc ToGenericNames {GenericDict} {
  # Convert generics into a file name suffix.
  #  GenericDict - Generic names and values.
  #
  # Returns `_<Name>_<Value>` per generic, concatenated.

  set Names ""
  if {${GenericDict} ne ""} {
    foreach {GenericName GenericValue} $GenericDict {
      set Names ${Names}_${GenericName}_[RemoveFilePathChars ${GenericValue}]
    }
  }
  return $Names
}

# -------------------------------------------------
proc DoWaves {args} {
  # Add wave scripts to a simulation.
  #  args - Wave script files, relative to the simulation directory.
  #
  # Use it in the options of [simulate]: `simulate Tb [DoWaves wave.do]`. Calls `vendor_DoWaves`, if the tool defines
  # it.
  #
  # Returns the tool's options; without `vendor_DoWaves`, `-do <File>` per file.
  if {[llength [info procs vendor_DoWaves]] > 0} {
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
  # Create the library options of a Verilog analyze command.
  #  prefix - Option for one library, e.g. `-L `.
  #
  # Returns $prefix followed by the library name, for each library known to OSVVM.
  variable LibraryList

  foreach item $LibraryList {
    set LibraryName [lindex $item 0]
    append VerilogLibraryParams ${prefix} ${LibraryName} " "
  }
  return $VerilogLibraryParams
}

# -------------------------------------------------
proc MergeCoverage {SuiteName MergeName} {
  # Merge code coverage databases.
  #  SuiteName - Name of the test suite whose code coverage is merged.
  #  MergeName - Name of the merged result.
  #
  # Creates `<CoverageDirectory>/<MergeName>` and calls `vendor_MergeCodeCoverage`.
  CreateDirectory [file join $::osvvm::CurrentSimulationDirectory $::osvvm::CoverageDirectory $MergeName]
  vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${MergeName}
}


# -------------------------------------------------
proc FinalizeTestSuite {SuiteName} {
  # Finish a test suite: merge its requirements and code coverage.
  #  SuiteName - Name of the test suite.
  #
  # Merges the requirements of the test suite's test cases into `<ReportsDirectory>/<BuildName>/<SuiteName>_req.yml` and
  # writes its HTML report. If a simulation ran with code coverage, the test suite's code coverage is merged.

  # Merge Requirements for each test case into TestSuite Requirements
  set RequirementsSourceDir   [file join ${::osvvm::ReportsDirectory} ${SuiteName}]
  set RequirementsResultsFile [file join ${::osvvm::ReportsDirectory} ${::osvvm::BuildName} ${SuiteName}_req.yml]
  MergeRequirements $RequirementsSourceDir $RequirementsResultsFile
  Requirements2Html $RequirementsResultsFile "../"

  # Merge Code Coverage for the Test Suite if it exists
  if {$::osvvm::RanSimulationWithCoverage eq "true"} {
    CreateDirectory ${::osvvm::CoverageDirectory}/${::osvvm::BuildName}
    CreateDirectory ${::osvvm::CoverageDirectory}/${SuiteName}
    vendor_MergeCodeCoverage $SuiteName ${::osvvm::CoverageDirectory} ${::osvvm::BuildName}
  }
}

# -------------------------------------------------
proc TestSuite {SuiteName} {
  # Start a test suite.
  #  SuiteName - Name of the test suite.
  #
  # Finishes the previous test suite, if any. A repeated call with the active name is ignored with a warning. Test cases
  # simulated without a test suite go into a test suite named after the active library.
  #
  # See also: [TestName] [build]
  variable TestSuiteName

  puts "TestSuite $SuiteName"                     ; # EchoOsvvmCmd

  set FirstRun [expr ![info exists TestSuiteName]]
  if {! $FirstRun} {
    if {$SuiteName eq $TestSuiteName} {
      # Do nothing if test suite already set
      puts "Warning:  Redundant TestSuite $SuiteName - name already set to $TestSuiteName - Command Ignored"
      return ""
    }
    # Finish previous test suite before ending current one
    FinalizeTestSuite $TestSuiteName
    FinishTestSuiteBuildYaml
  }
  StartTestSuiteBuildYaml $SuiteName $FirstRun

  set   TestSuiteName $SuiteName

#  CheckWorkingDir
#  CheckSimulationDirs
#  CreateDirectory [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::ReportsDirectory} ${TestSuiteName}]
#  CreateDirectory [file join ${::osvvm::CurrentSimulationDirectory} ${::osvvm::ResultsDirectory} ${TestSuiteName}]
}

# -------------------------------------------------
proc SetTestName {Name} {
  # Set the name of the next test case.
  #  Name - Name of the test case.
  #
  # Starts a test suite named after the active library (or the default library), if none is active.
  variable TestCaseName
  variable TestSuiteName

  if {![info exists TestSuiteName]} {
    if {[info exists ::osvvm::VhdlWorkingLibrary]} {
      TestSuite $::osvvm::VhdlWorkingLibrary
    } else {
      TestSuite $::osvvm::DefaultLibraryName
    }
  }

  puts "TestName $Name"
  set TestCaseName $Name
  puts -nonewline ""
}

proc TestName {Name} {
  # Set the name of the next test case.
  #  Name - Name of the test case; must match the name the testbench sets with `SetTestName`.
  #
  # Call it before [simulate], if the test case name differs from the simulated design unit. Generics aren't appended to
  # the name of the result files, unlike for names set by [simulate] or [RunTest].
  #
  # See also: [TestSuite]
  SetTestName $Name
  # if called directly, then do not use generics in the name
  # if set by RunTest or Simulate incorporate generics in TestCaseFileName
  set ::osvvm::TestCaseFileName $Name
  puts -nonewline ""
}

# Maintain backward compatibility
proc TestCase {Name} {
  # Set the name of the next test case; deprecated, use [TestName].
  #  Name - Name of the test case.
  TestName $Name
}


# -------------------------------------------------
# RunTest
#
proc RunTest {FileName {SimName ""} args} {
  # Analyze a file and simulate the design unit named like it.
  #  FileName - Path of the source file, relative to the current working directory.
  #  SimName  - Design unit to simulate. Empty: the file's base name.
  #  args     - Further words; not used. A `[generic Name Value]` here only records the generic.
  #
  # Combines [TestName], [analyze] and [simulate]. The test case name is the simulated design unit, or
  # `<SimName>(<FileBaseName>)` if $SimName is given; [TestName] called before takes precedence.
  #
  # See also: [RunAllTests]
  variable CompoundCommand
  variable TestCaseName
  variable TestCaseFileName

  set RunArgs [concat $FileName $SimName]
  if {$::osvvm::GenericDict ne ""} {
    set RunArgs "$RunArgs [ToGenericCommand $::osvvm::GenericDict]"
  }
  puts "RunTest $RunArgs"               ; # EchoOsvvmCmd
  set CompoundCommand TRUE

	if {$SimName eq ""} {
    set SimName [file rootname [file tail $FileName]]
    set DerivedTestName $SimName
#    if {![info exists TestCaseName]} {
#      SetTestName $SimName
#    }
  } else {
    set ShortFileName [file rootname [file tail $FileName]]
    set DerivedTestName "${SimName}(${ShortFileName})"
#    if {![info exists TestCaseName]} {
#      SetTestName "${SimName}(${ShortFileName})"
#    }
  }

  if {![info exists TestCaseName]} {
    SetTestName "$DerivedTestName"
    # Incorporate generics (if any) into TestCaseFileName
    set TestCaseFileName ${TestCaseName}${::osvvm::GenericNames}
  }

  analyze   ${FileName}
  simulate  ${SimName}
  unset CompoundCommand
}

# -------------------------------------------------
# RunAllTests
#
proc RunAllTests {{TestFilePrefix ""} args} {
  # Run all VHDL files of the current working directory as tests (experimental).
  #  TestFilePrefix - Only files whose names start with it.
  #  args           - Not used.
  #
  # Calls [RunTest] for each `<TestFilePrefix>*.vhd` and `<TestFilePrefix>*.vhdl` file.
  foreach Test [glob [file join $::osvvm::CurrentWorkingDirectory ${TestFilePrefix}*.vhd]] {
    RunTest $Test
  }
  foreach Test [glob [file join $::osvvm::CurrentWorkingDirectory ${TestFilePrefix}*.vhdl]] {
    RunTest $Test
  }
}

# -------------------------------------------------
# SkipTest
#
proc SkipTest { {FileName "NotProvided.vhd"} {Reason "Not Provided"} } {
  # Record a test case as skipped in the build reports.
  #  FileName - File or name of the test case; its base name is the test case name.
  #  Reason   - Reason, shown in the reports.
  #
  # See also: [RunTest]

  set SimName [file rootname [file tail $FileName]]

  puts "SkipTest $FileName $Reason"

  SkipTestBuildYaml $SimName $Reason
}


# -------------------------------------------------
# AnalyzeFailed
#
proc AnalyzeFailed { {LibraryUnit "NotProvided"} {Reason "Not Provided"} } {
  # Record a test case as failed, because its analyze failed.
  #  LibraryUnit - Name of the test case.
  #  Reason      - Reason, shown in the reports.

  puts "SimulateError: simulate $LibraryUnit $Reason"

  AnalyzeFailedBuildYaml $LibraryUnit $Reason
}

# -------------------------------------------------
# RemoveLibrary
#   Find name in LibraryList, remove corresponding directory and library mapping
#
proc UnlinkAndDeleteLibrary {LowerLibraryName ResolvedPathToLib} {
  # Remove a library from the tool and delete its directory.
  #  LowerLibraryName  - Name of the library, in lower case.
  #  ResolvedPathToLib - Directory containing the library.
  #
  # Calls `vendor_UnlinkLibrary`. If `RemoveLibraryDirectoryDeletesDirectory` is true, deletes
  # `<ResolvedPathToLib>/<LowerLibraryName>`. Failures are printed, not raised.

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
  # Remove a library from OSVVM's list, the tool and the file system.
  #  LowerLibraryName  - Name of the library, in lower case.
  #  ResolvedPathToLib - Directory containing the library; overridden by the directory OSVVM knows.
  #
  # Removes the library from `LibraryList` and deactivates it if it's the active library. The library is unlinked and
  # deleted, if OSVVM knew it or `RemoveUnmappedLibraries` is true.
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
  # Remove a library.
  #  LibraryName - Name of the library.
  #  PathToLib   - Library directory or one of its parents; only used for libraries OSVVM doesn't know. Empty: the
  #    current library directory.
  #
  # The library is removed from OSVVM's list and from the tool, and its directory is deleted (tool dependent).
  #
  # See also: [RemoveLibraryDirectory] [RemoveAllLibraries]
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
  # Remove all libraries in a library directory and the directory.
  #  ResolvedPathToLib - Library directory known to OSVVM.
  #
  # Removes each known library in the directory and the directory from `LibraryDirectoryList`. If
  # `RemoveLibraryDirectoryDeletesDirectory` is true, the directory is deleted when it's empty. Problems are printed as
  # warnings.
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
  # Remove a library directory and all libraries in it.
  #  PathToLib - Library directory or a part of its path. Empty: the directory set by [SetLibraryDirectory].
  #
  # Calls `CallbackOnError_RemoveLibraryDirectory`, if OSVVM doesn't know the directory.
  #
  # See also: [RemoveAllLibraries] [RemoveLibrary]
  CheckWorkingDir
  CheckLibraryInit

  set ResolvedPathToLib [FindExistingLibraryPath $PathToLib]

  if  {$ResolvedPathToLib ne ""} {
    LocalRemoveLibraryDirectory $ResolvedPathToLib
  } else {
    CallbackOnError_RemoveLibraryDirectory "${PathToLib} failed.  $PathToLib is not in \$::osvvm::LibraryDirectoryList."
  }
}

# RemoveLocalLibraries deprecated and replaced by RemoveLibraryDirectory
proc RemoveLocalLibraries {} {
  # Remove the current library directory; deprecated, use [RemoveLibraryDirectory].
  RemoveLibraryDirectory
}

# -------------------------------------------------
# RemoveAllLibraries
#
proc RemoveAllLibraries {} {
  # Remove all library directories known to OSVVM and their libraries.
  #
  # Nested directories are removed first. Afterwards no library is active and OSVVM knows no libraries.
  #
  # See also: [RemoveLibraryDirectory]
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

# -------------------------------------------------
# UnsetLibraryVars
#
proc UnsetLibraryVars {} {
  # Forget the active library and all known libraries, without removing them.
  variable VhdlWorkingLibrary
  variable LibraryList
  variable LibraryDirectoryList

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


# -------------------------------------------------
# InstallProject
#
proc InstallProject { {ProjectDir $OsvvmLibraries} {ProjectBuildScript $ProjectDir/OsvvmLibraries.pro} } {
  # Build a project in its own directory, with its libraries there.
  #  ProjectDir         - Directory of the project.
  #  ProjectBuildScript - Build script of the project.
  #
  # Changes into $ProjectDir, sets the library directory to it, creates and changes into `sim/<ToolNameVersion>` and
  # runs [build] with the log files in `logs`. Restores the directory, library directory and log settings afterwards.

  # Record current SimulationDirectory and LibraryDirectory
  set StartingDirectory             [pwd]
  set StartingLibraryDirectory      [GetLibraryDirectory]
#  set StartingVhdlLibraryDirectory  $::osvvm::VhdlLibraryDirectory


  # Goto ProjectDir and Set that as the current Library Directory
  cd $ProjectDir
#  SetLibraryDirectory [pwd]/VHDL_LIBS
  SetLibraryDirectory [pwd]

  # Create a tool specific sim directory for logs and tool temporaries in ProjectDir
  file mkdir sim/${::osvvm::ToolNameVersion}
  cd   sim/${::osvvm::ToolNameVersion}

  # Save current log file settings and temporarily override it
  set      CurLogSubDirectory           $::osvvm::LogSubdirectory
  variable ::osvvm::LogSubdirectory     "logs"                 ;# default value is "logs/${ToolNameVersion}"
  variable ::osvvm::LogDirectory        [file join ${::osvvm::OsvvmBuildOutputDirectory} ${::osvvm::LogSubdirectory}]
#  variable ::osvvm::VhdlLibraryDirectory       "VHDL_LIBS"

#  build ../../OsvvmLibraries.pro
  build $ProjectBuildScript

  # Restore log file settings
  variable ::osvvm::LogSubdirectory     $CurLogSubDirectory
  variable ::osvvm::LogDirectory        [file join ${::osvvm::OsvvmBuildOutputDirectory} ${::osvvm::LogSubdirectory}]

  # Restore SimulationDirectory and LibraryDirectory
  cd $StartingDirectory
  SetLibraryDirectory $StartingLibraryDirectory
#  variable ::osvvm::VhdlLibraryDirectory $StartingVhdlLibraryDirectory
}

#--------------------------------------------------------------
# SimulateDoneMoveTestCaseFiles
#
proc SimulateDoneMoveTestCaseFiles {} {
  # Move the result files of a finished test case into the build's directories.
  #
  # Moves the requirements (`_req.yml`), alert (`_alerts.yml`), functional coverage (`_cov.yml`) and scoreboard
  # (`_sb_<Name>.yml`) files of the test case from the temporary output directory into the test suite's reports
  # directory, named after `TestCaseFileName`. Sets `RequirementsYamlFile`, `AlertYamlFile` and `CovYamlFile` (empty if
  # absent) and `ScoreboardDict`.
  #
  # The transcripts the test case opened (listed in the temporary transcript YAML file) are moved into the test suite's
  # results directory, with the generics appended to their names, and converted to HTML; sets `TranscriptFiles`. A
  # transcript that's still open ends the simulation, unless in interactive mode.

  # Inputs
  variable TestCaseName
  variable TestCaseFileName
  variable TestSuiteName   ;# uses name Default if not set
  variable OsvvmTempOutputDirectory
  variable ReportsTestSuiteDirectory
# ::osvvm::GenericNames
# ::osvvm::ReportsSubdirectory
# ::osvvm::TempTranscriptYamlFile
# ::osvvm::ResultsDirectory
# ::osvvm::ResultsSubdirectory
# ::osvvm::SimulateInteractive

  #Outputs
  variable RequirementsYamlFile
  variable AlertYamlFile
  variable CovYamlFile
  variable ScoreboardDict
  variable TranscriptFiles

  set RequirementsYamlSourceFile [file join $OsvvmTempOutputDirectory ${TestCaseName}_req.yml]
  if {[file exists ${RequirementsYamlSourceFile}]} {
    set RequirementsYamlFile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_req.yml]
    file rename -force $RequirementsYamlSourceFile  $RequirementsYamlFile
  } else { set RequirementsYamlFile "" }

  set AlertYamlSourceFile        [file join $OsvvmTempOutputDirectory ${TestCaseName}_alerts.yml]
  if {[file exists ${AlertYamlSourceFile}]} {
    set AlertYamlFile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_alerts.yml]
    file rename -force $AlertYamlSourceFile $AlertYamlFile
  } else { set AlertYamlFile "" }

  set CovYamlSourceFile          [file join $OsvvmTempOutputDirectory ${TestCaseName}_cov.yml]
  if {[file exists ${CovYamlSourceFile}]} {
    set CovYamlFile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_cov.yml]
    file rename -force $CovYamlSourceFile  $CovYamlFile
  } else { set CovYamlFile "" }

  set SbBaseYamlFile            ${TestCaseName}_sb_
  set SbSourceFiles [glob -nocomplain [file join $OsvvmTempOutputDirectory ${SbBaseYamlFile}*.yml] ]
  set ScoreboardDict ""
  if {$SbSourceFiles ne ""} {
    foreach SbSourceFile ${SbSourceFiles} {
      set SbName [regsub ${SbBaseYamlFile} [file rootname [file tail $SbSourceFile]] ""]
      set SbDestFile [file join ${ReportsTestSuiteDirectory} ${TestCaseFileName}_sb_${SbName}.yml]
      file rename -force $SbSourceFile  $SbDestFile
      dict append ScoreboardDict $SbName [file join ${::osvvm::ReportsSubdirectory} ${TestSuiteName} ${TestCaseFileName}_sb_${SbName}.yml]
    }
  }

  set TranscriptFiles ""
  if {[file exists ${::osvvm::TempTranscriptYamlFile}]} {
    set TranscriptFileArray [::yaml::yaml2dict -file ${::osvvm::TempTranscriptYamlFile}]
    foreach TranscriptFile $TranscriptFileArray {
      if {[file exists ${TranscriptFile}]} {
        # If file is in list more than once (transcriptOpen ; transcriptClose ; TranscriptOpen)
        # It will not exist as it has already been moved.
        set TranscriptBaseName  [file tail $TranscriptFile]
        set TranscriptRootBaseName  [file rootname $TranscriptBaseName]
        set TranscriptExtension     [file extension $TranscriptBaseName]
        if {$TestCaseName ne $TestCaseFileName} {
          set ResultTranscriptName   ${TranscriptRootBaseName}${::osvvm::GenericNames}${TranscriptExtension}
        } else {
          set ResultTranscriptName   ${TranscriptBaseName}
        }
        set TranscriptDestFile  [file join ${::osvvm::ResultsDirectory} ${TestSuiteName} ${ResultTranscriptName}]
        lappend TranscriptFiles [file join ${::osvvm::ResultsSubdirectory} ${TestSuiteName} ${ResultTranscriptName}]
        if {[file normalize ${TranscriptFile}] ne [file normalize ${TranscriptDestFile}]} {
          # Move transcript if it is not already in destination location
# Done by CheckSimulationDirs          CreateDirectory [file join ${::osvvm::ResultsDirectory} ${TestSuiteName}]
#          file rename -force ${TranscriptFile}  ${TranscriptDestFile}
          file copy -force ${TranscriptFile}  ${TranscriptDestFile}
          # Create
          if {[catch {file delete -force ${TranscriptFile}} err]} {
            puts "ScriptWarning: Simulation did not close ${TranscriptFile}.  Will EndSimulation to close it if SimulationInteractive is false.   SimulationInteractive = $::osvvm::SimulateInteractive"
            # end simulation to try to free locks on the file, and try to delete again - in the event the test case forgot TranscriptClose
            if {!$::osvvm::SimulateInteractive} {
              EndSimulation
              file delete -force ${TranscriptFile}
            } else {
              puts "ScriptError:  Transcript file ${TranscriptFile} is open and cannot be deleted by scripts."
              puts "ScriptError:  Either test case did not run to completion or it is missing TranscriptClose at the end of the test case."
            }
          }
        }
        # Done after moving file (if necessary)
        Transcript2Html ${TranscriptDestFile}
      }
    }
    # Remove file so it does not impact any following simulation
    file delete -force -- ${::osvvm::TempTranscriptYamlFile}
  }
}

# -------------------------------------------------
# CopyHtmlThemeFiles
#
proc CopyHtmlThemeFiles {HtmlThemeSourceDirectory BaseDirectory HtmlThemeTargetSubdirectory} {
  # Copy the CSS and logo files of the HTML reports.
  #  HtmlThemeSourceDirectory    - Directory with the `*.css` files and one `*.png` file.
  #  BaseDirectory               - Directory of the HTML reports.
  #  HtmlThemeTargetSubdirectory - Subdirectory of $BaseDirectory to copy the files into.
  #
  # Sets `Report2CssFiles` and `Report2PngFile` to the copied files, relative to $BaseDirectory. Of several `*.png`
  # files, the last one is copied.
  variable Report2CssFiles
  variable Report2PngFile

  CreateDirectory [file join $BaseDirectory  $HtmlThemeTargetSubdirectory]

  # Note files are linked into the HTML in glob order (alphabetical but may be OS dependent WRT upper case)
  set CssFiles [glob -nocomplain [file join ${HtmlThemeSourceDirectory} *.css]]
  set Report2CssFiles ""
  if {$CssFiles ne ""} {
    foreach CssFileWithPath ${CssFiles} {
      set CssFile [file join $HtmlThemeTargetSubdirectory [file tail $CssFileWithPath]]
      file copy -force ${CssFileWithPath}  [file join $BaseDirectory  $CssFile]
      # HTML file is relative to the BaseDirectory
      lappend Report2CssFiles $CssFile
    }
  }

  # There should only be one *.png file.
  set PngFiles [glob -nocomplain [file join ${HtmlThemeSourceDirectory} *.png]]
  set LastPngFile ""
  if {$PngFiles ne ""} {
    foreach PngFileWithPath ${PngFiles} {
      set LastPngFile $PngFileWithPath
    }
  }
  # There should be only one PNG file, so only copy the last one we find.
  set PngDestFile [file join $HtmlThemeTargetSubdirectory [file tail $LastPngFile]]
  file copy -force ${LastPngFile} [file join $BaseDirectory $PngDestFile]
  set Report2PngFile $PngDestFile
}

# -------------------------------------------------
# DirectoryExists - use OSVVM
proc DirectoryExists {DirInQuestion} {
  # Check whether a directory exists.
  #  DirInQuestion - Path, relative to the current working directory.
  #
  # Returns `1` if $DirInQuestion exists (directory or file), else `0`.
  #
  # See also: [FileExists]
  variable CurrentWorkingDirectory

  if {[info exists CurrentWorkingDirectory]} {
    set LocalWorkingDirectory $CurrentWorkingDirectory
  } else {
    set LocalWorkingDirectory "."
  }
  return [file exists [file join ${LocalWorkingDirectory} ${DirInQuestion}]]
}

# -------------------------------------------------
proc FileExists {FileName} {
  # Check whether a file exists.
  #  FileName - Path, relative to the current working directory.
  #
  # Returns `1` if $FileName exists (file or directory), else `0`.
  #
  # See also: [DirectoryExists] [FileModified]
  variable CurrentWorkingDirectory

  if {[info exists CurrentWorkingDirectory]} {
    set LocalWorkingDirectory $CurrentWorkingDirectory
  } else {
    set LocalWorkingDirectory "."
  }
  return [file exists [file join ${LocalWorkingDirectory} ${FileName}]]
}

# -------------------------------------------------
proc FileModified {FileName} {
  # Return the modification time of a file.
  #  FileName - Path, relative to the current working directory.
  #
  # Returns the modification time in seconds since the epoch.
  #
  # See also: [FileExists]
  variable CurrentWorkingDirectory

  if {[info exists CurrentWorkingDirectory]} {
    set LocalWorkingDirectory $CurrentWorkingDirectory
  } else {
    set LocalWorkingDirectory "."
  }
  return [file mtime [file join ${LocalWorkingDirectory} ${FileName}]]
}


# -------------------------------------------------
proc JoinWorkingDirectory {RelativePath} {
  # Join a path to the current working directory.
  #  RelativePath - Path relative to the current working directory.
  #
  # Returns the joined path.
  #
  # See also: [ChangeWorkingDirectory]
  variable CurrentWorkingDirectory
  return [file join $CurrentWorkingDirectory $RelativePath]
}

# -------------------------------------------------
proc ChangeWorkingDirectory {RelativePath} {
  # Change the current working directory of the running script.
  #  RelativePath - Path relative to the current working directory.
  #
  # Paths of later commands of the script, e.g. [analyze], are relative to the new directory. The simulator's directory
  # doesn't change.
  #
  # See also: [JoinWorkingDirectory]
  variable CurrentWorkingDirectory
  set CurrentWorkingDirectory [file join $CurrentWorkingDirectory $RelativePath]
}

# -------------------------------------------------
proc TimeIt {args} {
  # Run a command and print how long it took.
  #  args - Command and its arguments.
  #
  # See also: [GetTimeString]
  set StartTimeMs [clock milliseconds]
  eval $args
  puts  "Time:  [ElapsedTimeMs $StartTimeMs]"
}

# -------------------------------------------------
proc SetArgv {} {
  # Set `argv0`, `argv` and `argc` to `0`.
  set ::argv0   0
  set ::argv    0
  set ::argc    0
}

# -------------------------------------------------
proc GetTimeString {} {
  # Return the current time as ISO 8601 string.
  #
  # Returns the time as `YYYY-MM-DDThh:mm:ss` followed by the time zone offset.
  return [GetIsoTime [clock seconds]]
}

# Don't export the following due to conflicts with Tcl built-ins
# map

namespace export analyze simulate build include library RunTest SkipTest TestSuite TestName TestCase BuildName
namespace export generic DoWaves NoNullRangeWarning
namespace export ExportCodeCoverage ExportOptions
namespace export IterateFile ReadListFromFile
namespace export StartTranscript StopTranscript
namespace export LinkLibrary ListLibraries LinkLibraryDirectory LinkCurrentLibraries
namespace export RemoveLibrary RemoveLibraryDirectory RemoveAllLibraries RemoveLocalLibraries
namespace export CreateDirectory
namespace export MergeCoverage
namespace export OsvvmLibraryPath
namespace export EndSimulation
namespace export FindLibraryPathByName CoSim
namespace export OpenBuildHtml OpenIndex
namespace export DirectoryExists FileExists FileModified
namespace export JoinWorkingDirectory ChangeWorkingDirectory
namespace export GetTimeString
namespace export LoadVendorScripts

# Experimental
namespace export RunAllTests

# Exported only for tesing purposes
namespace export FindLibraryPath CreateLibraryPath FindExistingLibraryPath TimeIt FindIncludeFile UnsetLibraryVars


# end namespace ::osvvm
}

