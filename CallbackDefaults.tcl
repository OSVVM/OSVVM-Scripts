#  File Name:         CallbackDefaults.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Defines a default set of Callbacks for OSVVM
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
#    05/2024   2024.05    Updated for refactoring Report2Html/Junit to ReportBuildYaml2Dict/Dict2Html/Dict2Junit
#    09/2022   2022.09    Initial
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2022-2024 by SynthWorks Design Inc.
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


#
# DO NOT CHANGE THIS FILE
#   This file is overwritten with each new release.
#   Instead, create
#     LocalCallBacks.tcl - if your adaptations apply to all vendors
#     CallBacks_${::osvvm::ScriptBaseName}.tcl - for a specific vendor adaptations
#   In these files create a proc with the same calling parameters as defined here
#   and it will replace the one defined here.
#


# Callbacks to be added as they are defined
namespace eval ::osvvm {


#
# CallbackBefore_Xxx, CallbackAfter_Xxx
#
  proc CallbackBefore_Build {Path_Or_File args} {
    # Run user actions before a build includes its script.
    #  Path_Or_File - Script file or directory given to [build].
    #  args         - Not used: OSVVM passes no further arguments.
    #
    # Called by [build] after the build's YAML file is started and before the script is included.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#   puts "Build Before ${Path_Or_File}"
  }
  proc CallbackAfter_Build {Path_Or_File args} {
    # Run user actions after a build included its script.
    #  Path_Or_File - Script file or directory given to [build].
    #  args         - Not used: OSVVM passes no further arguments.
    #
    # Called by [build] after the script was included without error and before the reports are created.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Build After ${Path_Or_File}"
  }
  proc CallbackBefore_Include {Path_Or_File args} {
    # Run user actions before a script is included.
    #  Path_Or_File - Script file or directory given to [include].
    #  args         - Not used: OSVVM passes no further arguments.
    #
    # Called by [include] before it looks for the script.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Include Before ${Path_Or_File}"
  }
  proc CallbackAfter_Include {Path_Or_File args} {
    # Run user actions after a script was included.
    #  Path_Or_File - Script file or directory given to [include].
    #  args         - Not used: OSVVM passes no further arguments.
    #
    # Called by [include] after the script was sourced without error.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Include After ${Path_Or_File}"
  }
  proc CallbackBefore_Library {LibraryName PathToLib} {
    # Run user actions before a library is created or made the working library.
    #  LibraryName - Library name given to [library].
    #  PathToLib   - Library directory given to [library]; empty if none was given.
    #
    # Called by [library] before the simulator creates or maps the library (`vendor_library`).
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Library Before ${PathToLib} ${LibraryName}"
  }
  proc CallbackAfter_Library {LibraryName PathToLib} {
    # Run user actions after a library was created or made the working library.
    #  LibraryName - Library name given to [library].
    #  PathToLib   - Library directory given to [library]; empty if none was given.
    #
    # Called by [library] after `vendor_library` succeeded. If it failed, [library] calls
    # `CallbackOnError_Library` instead.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Library Before ${PathToLib} ${LibraryName}"
  }
  proc CallbackBefore_Analyze {FileName args} {
    # Run user actions before a source file is analyzed.
    #  FileName - Source file given to [analyze].
    #  args     - One element: the list of options given to [analyze] after the file name.
    #
    # Called by [analyze] for VHDL and Verilog files, after the analyze options are put together in the variable
    # `::osvvm::AnalyzeOptions` and before the simulator analyzes the file (`vendor_analyze_vhdl` or
    # `vendor_analyze_verilog`).
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    variable AnalyzeOptions
#    puts "Analyze Before ${FileName} ${args}"
  }
  proc CallbackAfter_Analyze {FileName args} {
    # Run user actions after a source file was analyzed.
    #  FileName - Source file given to [analyze].
    #  args     - One element: the list of options given to [analyze] after the file name.
    #
    # Called by [analyze] for VHDL and Verilog files after the simulator analyzed the file without error.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Analyze After ${FileName} ${args}"
  }
  proc CallbackBefore_Simulate {LibraryUnit args} {
    # Run user actions before a simulation starts.
    #  LibraryUnit - Design unit given to [simulate].
    #  args        - One element: the list of options given to [simulate] after the design unit.
    #
    # Called by [simulate] after the simulate options are put together in the variable `::osvvm::SimulateOptions`
    # and before the simulator starts (`vendor_simulate`).
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    variable SimulateOptions
#    puts "Simulate Before ${LibraryUnit} ${args}"
  }
  proc CallbackAfter_Simulate {LibraryUnit args} {
    # Run user actions after a simulation ended.
    #  LibraryUnit - Design unit given to [simulate].
    #  args        - One element: the list of options given to [simulate] after the design unit.
    #
    # Called by [simulate] after `vendor_simulate` returned without error and before the test case reports are
    # created.
    # The default does nothing.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    puts "Simulate After ${LibraryUnit} ${args}"
  }

#
# CallbackOnError_Xxx
#   Defines how all OSVVM functionality handles errors
#
#  proc PrintErrorInfo {MessagePtr} {
#    if {$::osvvm::Debug} {
#      return [set $MessagePtr]
#    } else {
#      return "puts \${$MessagePtr}"
#    }
#  }

  proc CallbackOnError_Build {Path_Or_File BuildErrorMessage LocalBuildErrorInfo} {
    # Handle a failed build.
    #  Path_Or_File        - Script file or directory given to [build].
    #  BuildErrorMessage   - Error message of the build script, or the number of analyze and simulate errors.
    #  LocalBuildErrorInfo - Tcl `errorInfo` of the build script's error.
    #
    # Called by [build] after all reports are created, if an analyze or simulate error occurred or the build
    # script raised an error.
    #
    # Prints an error message and stores $LocalBuildErrorInfo in `::osvvm::BuildErrorInfo`. For the first build
    # error, it prints the `errorInfo` too, if `TclDebug` or `Debug` is set. If `FailOnBuildErrors` is set, it raises
    # an error with $BuildErrorMessage, otherwise it prints $BuildErrorMessage.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    if {$::osvvm::BuildErrorInfo eq ""} {
      set NewBuildError TRUE
    } else {
      set NewBuildError FALSE
    }
    puts "Build Error: build $Path_Or_File failed"
    set ::osvvm::BuildErrorInfo $LocalBuildErrorInfo
    if {($::osvvm::TclDebug || $::osvvm::Debug)&& $NewBuildError } {
      puts "Build Error:  Info from \$::osvvm::BuildErrorInfo "
      puts "$::osvvm::BuildErrorInfo"
    } else {
      puts "Build Error:  For tcl errorInfo, puts \$::osvvm::BuildErrorInfo."
    }
    if {$::osvvm::FailOnBuildErrors} {
      error $BuildErrorMessage
    } else {
      puts $BuildErrorMessage
    }
  }

  proc CallbackOnError_FindIncludeFile {Path_Or_File CommandName} {
    # Handle a script file or directory that doesn't exist.
    #  Path_Or_File - Script file or directory given to the command.
    #  CommandName  - Name of the calling command: `include` or `Build`.
    #
    # Called by [include] and [build] if they can't find a script for $Path_Or_File. Prints an error message and
    # raises an error with the normalized path.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    puts "Error: $CommandName ${Path_Or_File} is not a file or path"
    error "$CommandName [file normalize ${Path_Or_File}] is not a file or path"
  }

  proc CallbackOnError_Library {ErrMsg LibraryName PathToLib ErrInProc} {
    # Handle a failure to create a library or make it the working library.
    #  ErrMsg      - Error message of the failed procedure.
    #  LibraryName - Library name given to [library].
    #  PathToLib   - Library directory the library was looked for in.
    #  ErrInProc   - Name of the failed procedure: `vendor_library`.
    #
    # Called by [library] if `vendor_library` fails. Stores the Tcl `errorInfo` in `::osvvm::LibraryErrorInfo`,
    # prints error messages and, if `TclDebug` or `Debug` is set, the `errorInfo`. Then raises an error with
    # $ErrMsg.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: $ErrMsg"
    puts "LibraryError: library $LibraryName $PathToLib failed in $ErrInProc  See messages above"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts  "LibraryError:  Info from  \$::osvvm::LibraryErrorInfo"
      puts  "$::osvvm::LibraryErrorInfo"
    } else {
      puts  "LibraryError: For Tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    }
    error "LibraryError: $ErrMsg"
  }

  proc CallbackOnError_LinkLibrary {Message} {
    # Handle a failure to link a library.
    #  Message - Description of the failure: library name, directory and cause.
    #
    # Called by [LinkLibrary] if the library directory doesn't exist or `vendor_LinkLibrary` fails. Stores the Tcl
    # `errorInfo` in `::osvvm::LibraryErrorInfo`, prints error messages and, if `TclDebug` or `Debug` is set, the
    # `errorInfo`. Then raises an error with $Message.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: LinkLibrary $Message   See messages above"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts  "LibraryError:  Info from  \$::osvvm::LibraryErrorInfo"
      puts  "$::osvvm::LibraryErrorInfo"
    } else {
      puts  "LibraryError: For Tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    }
    error "$Message"
  }

  proc CallbackOnError_RemoveLibraryDirectory {Message} {
    # Handle a failure to remove a library directory.
    #  Message - Description of the failure: directory and cause.
    #
    # Called by [RemoveLibraryDirectory] if the directory isn't a library directory known to OSVVM. Stores the Tcl
    # `errorInfo` in `::osvvm::LibraryErrorInfo`, prints error messages and, if `TclDebug` or `Debug` is set, the
    # `errorInfo`. Then raises an error with $Message.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: RemoveLibraryDirectory $Message   See messages above"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts  "LibraryError:  Info from  \$::osvvm::LibraryErrorInfo"
      puts  "$::osvvm::LibraryErrorInfo"
    } else {
      puts  "LibraryError: For Tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    }
    error "$Message"
  }

  proc CallbackOnError_Analyze {ErrMsg args} {
    # Handle a failed analyze.
    #  ErrMsg - Error message of the analyze.
    #  args   - One element: the list of the file name and the options given to [analyze].
    #
    # Called by [analyze] if the analysis of a file fails. Stores the Tcl `errorInfo` in
    # `::osvvm::AnalyzeErrorInfo`, increments `AnalyzeErrorCount` and prints an error message.
    #
    # If `AnalyzeErrorStopCount` isn't 0 and `AnalyzeErrorCount` reached it, it raises an error, which stops the
    # build. Otherwise the build continues; the next [simulate] is skipped.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    variable AnalyzeErrorCount
    variable AnalyzeErrorStopCount
#    variable ConsecutiveAnalyzeErrors

    # errorInfo has the TCL stack to the failure
    set ::osvvm::AnalyzeErrorInfo $::errorInfo

    set AnalyzeErrorCount            [expr $AnalyzeErrorCount+1]
#    set ConsecutiveAnalyzeErrors [expr $ConsecutiveAnalyzeErrors+1]

    puts  "AnalyzeError: See messages above in \"analyze $args\""
#!    if {$::osvvm::TclDebug || $::osvvm::Debug} {
#!      puts  "AnalyzeError:  Info from  \$::osvvm::AnalyzeErrorInfo"
#!      puts  "$::osvvm::AnalyzeErrorInfo"
#!    } else {
      puts  "AnalyzeError: For Tcl errorInfo, puts \$::osvvm::AnalyzeErrorInfo"
#!    }

    # These settings are in OsvvmDefaultSettings.  Override them in LocalScriptDefaults.tcl
    if {$AnalyzeErrorStopCount != 0 && $AnalyzeErrorCount >= $AnalyzeErrorStopCount } {
      error "AnalyzeError: analyze $args"
    }
  }

  proc CallbackOnError_Simulate {ErrMsg LocalSimulateErrorInfo args} {
    # Handle a failed simulation.
    #  ErrMsg                 - Error message of the simulation.
    #  LocalSimulateErrorInfo - Tcl `errorInfo` of the simulation's error.
    #  args                   - One element: the list of the design unit and the options given to [simulate].
    #
    # Called by [simulate] if the simulation fails, or if it's skipped because the previous analyze failed. Stores
    # $LocalSimulateErrorInfo in `::osvvm::SimulateErrorInfo`, increments `SimulateErrorCount` and prints an
    # error message.
    #
    # If `SimulateErrorStopCount` isn't 0 and `SimulateErrorCount` reached it, it raises an error, which stops the
    # build. Otherwise the build continues.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    variable SimulateErrorCount
    variable SimulateErrorStopCount
#    variable ConsecutiveSimulateErrors

    set ::osvvm::SimulateErrorInfo    $LocalSimulateErrorInfo
    set SimulateErrorCount            [expr $SimulateErrorCount+1]
#    set ConsecutiveSimulateErrors     [expr $ConsecutiveSimulateErrors+1]
    puts  "SimulateError: See messages above in \"simulate $args\""
#    if {$::osvvm::TclDebug || $::osvvm::Debug} {
#      puts  "SimulateError:  Info from  \$::osvvm::SimulateErrorInfo"
#      puts  "$::osvvm::SimulateErrorInfo"
#    } else {
      puts  "SimulateError: For Tcl errorInfo, puts \$::osvvm::SimulateErrorInfo"
#    }

    # These settings are in OsvvmDefaultSettings.  Override them in LocalScriptDefaults.tcl
    if {$SimulateErrorStopCount != 0 && $SimulateErrorCount >= $SimulateErrorStopCount } {
      # This stops the build
      error "SimulateError: simulate $args"
    }
  }

  proc CallbackOnError_WaveDo {ErrMsg LocalErrorInfo Directory LibraryUnit} {
    # Handle an error in a `wave.do` script.
    #  ErrMsg         - Error message of the script.
    #  LocalErrorInfo - Tcl `errorInfo` of the script's error.
    #  Directory      - Directory of the `wave.do` script.
    #  LibraryUnit    - Design unit being simulated.
    #
    # Called during [simulate] if sourcing a `wave.do` script fails. Increments `ScriptErrorCount`, stores
    # $LocalErrorInfo in `::osvvm::WaveErrorInfo` and prints an error message and, if `TclDebug` or `Debug` is set,
    # the `errorInfo`. Raises no error: the simulation continues.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]

    set ::osvvm::WaveErrorInfo    $LocalErrorInfo

    puts "WaveError: Error while doing source $Directory/wave.do during simulate $LibraryUnit: $ErrMsg"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts  "WaveError:  Info from  \$::osvvm::WaveErrorInfo"
      puts  "$::osvvm::WaveErrorInfo"
    } else {
      puts  "WaveError: For Tcl errorInfo, puts \$::osvvm::WaveErrorInfo"
    }

    # No errors are signaled here
  }

  #
  #  Handling errors in generating Build Reports
  #
  proc CallbackOnError_AfterBuildReports {LocalReportErrorInfo} {
    # Handle errors while creating the build reports.
    #  LocalReportErrorInfo - Tcl `errorInfo` of the report error.
    #
    # Called by [build] at its end if creating the build reports failed or `ScriptErrorCount` isn't 0. Stores
    # $LocalReportErrorInfo in `::osvvm::BuildReportErrorInfo` and prints error messages and, if `TclDebug` or
    # `Debug` is set, the `errorInfo`. Raises no error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::BuildReportErrorInfo $LocalReportErrorInfo

# Todo: Is this extra?  Already printing info below

    # Continue current build
    puts  "ScriptError: during build.  See previous messages for details."
    puts  "Please include your simulator version in any issue reports"
    puts  "For tcl errorInfo, puts \$::osvvm::BuildReportErrorInfo"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts  "ScriptError:  Info from  \$::osvvm::BuildReportErrorInfo"
      puts  "$::osvvm::BuildReportErrorInfo"
    } else {
      puts  "ScriptError: For Tcl errorInfo, puts \$::osvvm::BuildReportErrorInfo"
    }
    # Errors are signaled later in the build
  }

  proc LocalOnError_BuildReports {ProcName FileName errmsg} {
    # Report an error of a build report procedure and raise it.
    #  ProcName - Name of the failed report procedure.
    #  FileName - File the procedure read or wrote.
    #  errmsg   - Error message of the procedure.
    #
    # Shared by the `CallbackOnError_*` procedures of the build reports. Increments `ScriptErrorCount`, prints an
    # error message and the Tcl `errorInfo`, and raises an error with $ProcName, $FileName and $errmsg.
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]

    puts "ReportError: during $ProcName 'File Name: $FileName ' failed: $errmsg"

    # For no traceback information use this
#     puts "For tcl errorInfo, puts \$::osvvm::${ProcName}ErrorInfo"

    # For traceback information use the following two lines
    puts "tcl errorInfo follows"
    puts $::errorInfo

    # Pass the error information up to Build - recommended
    error "$ProcName 'File Name: $FileName ' failed: $errmsg"
  }

  proc CallbackOnError_ReportBuildYaml2Dict {FileName errmsg} {
    # Handle an error while reading the build's YAML file.
    #  FileName - Build YAML file.
    #  errmsg   - Error message of [ReportBuildYaml2Dict].
    #
    # Called by [ReportBuildYaml2Dict] if it fails. Stores the Tcl `errorInfo` in `::osvvm::Report2HtmlErrorInfo`
    # and calls `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::Report2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildYaml2Dict $FileName $errmsg
  }

  proc CallbackOnError_Index2Html {FileName errmsg} {
    # Handle an error while writing the HTML index of all builds.
    #  FileName - HTML index file.
    #  errmsg   - Error message of [Index2Html].
    #
    # Called by [Index2Html] if it fails. Stores the Tcl `errorInfo` in `::osvvm::Report2HtmlErrorInfo` and calls
    # `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::Report2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports Index2Html $FileName $errmsg
  }

  proc CallbackOnError_ReportBuildDict2Html {FileName errmsg} {
    # Handle an error while writing the HTML build summary report.
    #  FileName - HTML build summary report file.
    #  errmsg   - Error message of [ReportBuildDict2Html].
    #
    # Called by [ReportBuildDict2Html] if it fails. Stores the Tcl `errorInfo` in `::osvvm::Report2HtmlErrorInfo`
    # and calls `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::Report2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildDict2Html $FileName $errmsg
  }

  proc CallbackOnError_ReportBuildDict2Junit {FileName errmsg} {
    # Handle an error while writing the JUnit XML build report.
    #  FileName - JUnit XML report file.
    #  errmsg   - Error message of [ReportBuildDict2Junit].
    #
    # Called by [ReportBuildDict2Junit] if it fails. Stores the Tcl `errorInfo` in `::osvvm::Report2JunitErrorInfo`
    # and calls `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::Report2JunitErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildDict2Junit $FileName $errmsg
  }

  proc CallbackOnError_Log2Osvvm {FileName errmsg} {
    # Handle an error while converting the build's transcript.
    #  FileName - Transcript log file.
    #  errmsg   - Error message of [Log2Osvvm].
    #
    # Called by [Log2Osvvm] if it fails. Stores the Tcl `errorInfo` in `::osvvm::Log2OsvvmErrorInfo` and calls
    # `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::Log2OsvvmErrorInfo $::errorInfo
    LocalOnError_BuildReports Log2Osvvm $FileName $errmsg
  }

  proc CallbackOnError_Transcript2Html {FileName errmsg} {
    # Handle an error while converting a transcript to HTML.
    #  FileName - Transcript file.
    #  errmsg   - Error message of [Transcript2Html].
    #
    # Called by [Transcript2Html] if it fails. Stores the Tcl `errorInfo` in `::osvvm::ReportErrorInfo` and
    # `::osvvm::Transcript2HtmlErrorInfo` and calls `LocalOnError_BuildReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::ReportErrorInfo $::errorInfo
    set ::osvvm::Transcript2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports Transcript2Html $FileName $errmsg
  }


  #
  #  Handling errors in generating Simulate Reports
  #
  proc CallbackOnError_AfterSimulateReports {ErrMsg LocalReportErrorInfo} {
    # Handle errors while creating the test case reports.
    #  ErrMsg               - Error message of the report procedure. Not used.
    #  LocalReportErrorInfo - Tcl `errorInfo` of the report error.
    #
    # Called by [simulate] if creating the reports of the test case failed. Stores $LocalReportErrorInfo in
    # `::osvvm::SimulateReportErrorInfo` and prints an error message and, if `TclDebug` or `Debug` is set, the
    # `errorInfo`. Raises no error: the build continues.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    set ::osvvm::SimulateReportErrorInfo $LocalReportErrorInfo
    # Continue current build
    puts "ReportError: Simulate2Html failed.  See previous messages for details"
    if {$::osvvm::TclDebug || $::osvvm::Debug} {
      puts "errorInfo:  $::osvvm::SimulateReportErrorInfo"
    }

    # end current build
    # error "ReportError: Simulate2Html failed.  See previous messages"
  }

  proc LocalOnError_SimulateReports {ProcName TestSuiteName TestCaseName errmsg} {
    # Report an error of a test case report procedure and raise it.
    #  ProcName      - Name of the failed report procedure.
    #  TestSuiteName - Name of the test suite.
    #  TestCaseName  - Name of the test case.
    #  errmsg        - Error message of the procedure.
    #
    # Shared by the `CallbackOnError_*` procedures of the test case reports. Stores the Tcl `errorInfo` in
    # `::osvvm::Simulate2HtmlErrorInfo`, increments `ScriptErrorCount`, prints an error message and the
    # `errorInfo`, and raises an error with $ProcName, the test suite and test case names and $errmsg.
    set ::osvvm::Simulate2HtmlErrorInfo $::errorInfo
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]

    puts "ReportError: during $ProcName 'Test Suite: $TestSuiteName,  TestCase: $TestCaseName ' failed: $errmsg"

    # For no traceback information use this
#     puts "For tcl errorInfo, puts \$::osvvm::Simulate2HtmlErrorInfo"

    # For traceback information use the following two lines
    puts "tcl errorInfo follows"
    puts $::osvvm::Simulate2HtmlErrorInfo

    # Pass the error information up to simulate - recommended
    error "$ProcName 'Test Suite: $TestSuiteName,  TestCase: $TestCaseName ' failed: $errmsg"
  }

  proc CallbackOnError_Simulate2HtmlHeader {TestSuiteName TestCaseName errmsg} {
    # Handle an error while writing the summary table of a test case report.
    #  TestSuiteName - Name of the test suite.
    #  TestCaseName  - Name of the test case.
    #  errmsg        - Error message.
    #
    # Called during [Simulate2Html] if writing the test case summary table fails. Calls
    # `LocalOnError_SimulateReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    LocalOnError_SimulateReports Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }
  proc CallbackOnError_Alert2Html {TestSuiteName TestCaseName errmsg} {
    # Handle an error while writing the alert report of a test case.
    #  TestSuiteName - Name of the test suite.
    #  TestCaseName  - Name of the test case.
    #  errmsg        - Error message of [Alert2Html].
    #
    # Called by [Alert2Html] if it fails. Calls `LocalOnError_SimulateReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    LocalOnError_SimulateReports Alert2Html $TestSuiteName $TestCaseName $errmsg
  }

  proc CallbackOnError_Cov2Html {TestSuiteName TestCaseName errmsg} {
    # Handle an error while writing the functional coverage report of a test case.
    #  TestSuiteName - Name of the test suite.
    #  TestCaseName  - Name of the test case.
    #  errmsg        - Error message of [Cov2Html].
    #
    # Called by [Cov2Html] if it fails. Calls `LocalOnError_SimulateReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    LocalOnError_SimulateReports Cov2Html $TestSuiteName $TestCaseName $errmsg
  }
  proc CallbackOnError_Scoreboard2Html {TestSuiteName TestCaseName errmsg} {
    # Handle an error while writing the scoreboard report of a test case.
    #  TestSuiteName - Name of the test suite.
    #  TestCaseName  - Name of the test case.
    #  errmsg        - Error message of [Scoreboard2Html].
    #
    # Called by [Scoreboard2Html] if it fails. Calls `LocalOnError_SimulateReports`, which raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.
    LocalOnError_SimulateReports Scoreboard2Html $TestSuiteName $TestCaseName $errmsg
  }

  proc CallbackOnError_AnyReport {ProcName Message errmsg} {
    # Handle an error of a requirements report procedure.
    #  ProcName - Name of the failed procedure.
    #  Message  - Description of the procedure's input and output files.
    #  errmsg   - Error message of the procedure.
    #
    # Called by [MergeRequirements], [Requirements2Html], [Requirements2Csv] and [RequirementsCsv2Yaml] if they
    # fail. Stores the Tcl `errorInfo` in `::osvvm::ReportErrorInfo`, increments `ScriptErrorCount` and prints an
    # error message. If `ReportDebug` is set, it prints the `errorInfo` too. Then raises an error.
    #
    # To change it, define a procedure with the same name and parameters in `LocalCallbacks.tcl` (all tools) or
    # `LocalCallbacks_<tool>.tcl` (one tool) in the OSVVM settings directory. OSVVM sources these files after this
    # one, so the user's procedure replaces the default.

#    set ::osvvm::${ProcName}ErrorInfo $::errorInfo
    set ::osvvm::ReportErrorInfo $::errorInfo
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]

    # Report Error
    puts "ReportError: during $ProcName $Message failed: $errmsg"

        # Reference or print ErrorInfo for this error
    if {$::osvvm::ReportDebug} {
#      puts ${::osvvm::${ProcName}ErrorInfo}
      puts ${::osvvm::ReportErrorInfo}
    } else {
#      puts  "For tcl errorInfo, puts \$::osvvm::${ProcName}ErrorInfo"
      puts  "For tcl errorInfo, puts \$::osvvm::ReportErrorInfo"
    }

    # Pass the error information up
    error $ProcName $Message failed: $errmsg"
  }

}