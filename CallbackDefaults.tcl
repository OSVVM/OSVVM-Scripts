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
#    puts "Build Before ${Path_Or_File}"
  }
  proc CallbackAfter_Build {Path_Or_File args} {
#    puts "Build After ${Path_Or_File}"
  }
  proc CallbackBefore_Include {Path_Or_File args} {
#    puts "Include Before ${Path_Or_File}"
  }
  proc CallbackAfter_Include {Path_Or_File args} {
#    puts "Include After ${Path_Or_File}"
  }
  proc CallbackBefore_Library {LibraryName PathToLib} {
#    puts "Library Before ${PathToLib} ${LibraryName}"
  }
  proc CallbackAfter_Library {LibraryName PathToLib} {
#    puts "Library Before ${PathToLib} ${LibraryName}"
  }
  proc CallbackBefore_Analyze {FileName args} {
#    variable AnalyzeOptions
#    puts "Analyze Before ${FileName} ${args}"
  }
  proc CallbackAfter_Analyze {FileName args} {
#    puts "Analyze After ${FileName} ${args}"
  }
  proc CallbackBefore_Simulate {LibraryUnit args} {
#    variable SimulateOptions
#    puts "Simulate Before ${LibraryUnit} ${args}"
  }
  proc CallbackAfter_Simulate {LibraryUnit args} {
#    puts "Simulate After ${LibraryUnit} ${args}"
  }

#
# CallbackOnError_Xxx
#   Defines how all OSVVM functionality handles errors
#
  proc CallbackOnError_Build {Path_Or_File BuildErrorMessage LocalBuildErrorInfo} {    
    set ::osvvm::BuildErrorInfo $LocalBuildErrorInfo
    if {$::osvvm::FailOnBuildErrors} {
#      error "For tcl errorInfo, puts \$::osvvm::BuildErrorInfo"
      puts "Error:  For tcl errorInfo, puts \$::osvvm::BuildErrorInfo"
      error $BuildErrorMessage
    } else {
      puts "Error:  For tcl errorInfo, puts \$::osvvm::BuildErrorInfo"
    }
  }
  
  proc CallbackOnError_FindIncludeFile {Path_Or_File CommandName} {
    puts "Error: $CommandName ${Path_Or_File} is not a file or path"
    error "$CommandName [file normalize ${Path_Or_File}] is not a file or path"
  }
  
  proc CallbackOnError_Library {ErrMsg LibraryName PathToLib ErrInProc} {
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: $ErrMsg"
    puts "LibraryError: library $LibraryName $PathToLib failed in $ErrInProc  See messages above"
    puts "For tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    error "LibraryError: $ErrMsg"
  }
  
  proc CallbackOnError_LinkLibrary {Message} {
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: $Message   See messages above"
    puts "For tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    error "$Message"
  }
  
  proc CallbackOnError_RemoveLibraryDirectory {Message} {
    set ::osvvm::LibraryErrorInfo $::errorInfo
    puts "LibraryError: $Message   See messages above"
    puts "For tcl errorInfo, puts \$::osvvm::LibraryErrorInfo"
    error "$Message"
  }
  
  proc CallbackOnError_Analyze {ErrMsg args} {
    variable AnalyzeErrorCount 
    variable AnalyzeErrorStopCount
#    variable ConsecutiveAnalyzeErrors 
    
    # errorInfo has the TCL stack to the failure
    set ::osvvm::AnalyzeErrorInfo $::errorInfo
    
    set AnalyzeErrorCount            [expr $AnalyzeErrorCount+1]
#    set ConsecutiveAnalyzeErrors [expr $ConsecutiveAnalyzeErrors+1]
    puts  "AnalyzeError: See messages above in \"analyze $args\""
    puts  "For tcl errorInfo, puts \$::osvvm::AnalyzeErrorInfo"
    
    # These settings are in OsvvmDefaultSettings.  Override them in LocalScriptDefaults.tcl
    if {$AnalyzeErrorStopCount != 0 && $AnalyzeErrorCount >= $AnalyzeErrorStopCount } {
      error "AnalyzeError: analyze $args"
    }
  }
  
  proc CallbackOnError_Simulate {ErrMsg LocalSimulateErrorInfo args} {
    variable SimulateErrorCount 
    variable SimulateErrorStopCount
#    variable ConsecutiveSimulateErrors 
    
    set ::osvvm::SimulateErrorInfo    $LocalSimulateErrorInfo
    set SimulateErrorCount            [expr $SimulateErrorCount+1]
#    set ConsecutiveSimulateErrors     [expr $ConsecutiveSimulateErrors+1]
    puts  "SimulateError: See messages above in \"simulate $args\""
    puts  "For tcl errorInfo, puts \$::osvvm::SimulateErrorInfo"

    # These settings are in OsvvmDefaultSettings.  Override them in LocalScriptDefaults.tcl
    if {$SimulateErrorStopCount != 0 && $SimulateErrorCount >= $SimulateErrorStopCount } {
      # This stops the build
      error "SimulateError: simulate $args"
    }
  }

  proc CallbackOnError_WaveDo {ErrMsg LocalErrorInfo Directory LibraryUnit} {
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]
    
    set ::osvvm::WaveErrorInfo    $LocalErrorInfo

    puts "WaveError: Error while doing source $Directory/wave.do during simulate $LibraryUnit: $ErrMsg"
    puts "For tcl errorInfo, puts \$::osvvm::WaveErrorInfo"
    
    # No errors are signaled here
  }
  
  #
  #  Handling errors in generating Build Reports
  #
  proc CallbackOnError_AfterBuildReports {LocalReportErrorInfo} {
    set ::osvvm::BuildReportErrorInfo $LocalReportErrorInfo 
    
# Todo: Is this extra?  Already printing info below

    # Continue current build
    puts  "ScriptError: during build.  See previous messages for details."
    puts  "Please include your simulator version in any issue reports"
    puts  "For tcl errorInfo, puts \$::osvvm::BuildReportErrorInfo"
    
    # Errors are signaled later in the build
  }  

  proc LocalOnError_BuildReports {ProcName FileName errmsg} {
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
    set ::osvvm::Report2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildYaml2Dict $FileName $errmsg
  }  

  proc CallbackOnError_ReportBuildDict2Html {FileName errmsg} {
    set ::osvvm::Report2HtmlErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildDict2Html $FileName $errmsg
  }  
  
  proc CallbackOnError_ReportBuildDict2Junit {FileName errmsg} {
    set ::osvvm::Report2JunitErrorInfo $::errorInfo
    LocalOnError_BuildReports ReportBuildDict2Junit $FileName $errmsg
  }  
  
  proc CallbackOnError_Log2Osvvm {FileName errmsg} {
    set ::osvvm::Log2OsvvmErrorInfo $::errorInfo
    LocalOnError_BuildReports Log2Osvvm $FileName $errmsg
  }  
  
  #
  #  Handling errors in generating Simulate Reports
  #
  proc CallbackOnError_AfterSimulateReports {ErrMsg LocalReportErrorInfo} {
    set ::osvvm::SimulateReportErrorInfo $LocalReportErrorInfo 
    # Continue current build
    puts "ReportError: Simulate2Html failed.  See previous messages for details"
    
    # end current build
    # error "ReportError: Simulate2Html failed.  See previous messages"
  }  
  
  proc LocalOnError_SimulateReports {ProcName TestSuiteName TestCaseName errmsg} {
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
    LocalOnError_SimulateReports Simulate2HtmlHeader $TestSuiteName $TestCaseName $errmsg
  }  
  proc CallbackOnError_Alert2Html {TestSuiteName TestCaseName errmsg} {
    LocalOnError_SimulateReports Alert2Html $TestSuiteName $TestCaseName $errmsg
  }  
  
  proc CallbackOnError_Cov2Html {TestSuiteName TestCaseName errmsg} {
    LocalOnError_SimulateReports Cov2Html $TestSuiteName $TestCaseName $errmsg
  }  
  proc CallbackOnError_Scoreboard2Html {TestSuiteName TestCaseName errmsg} {
    LocalOnError_SimulateReports Scoreboard2Html $TestSuiteName $TestCaseName $errmsg
  }  

  proc CallbackOnError_AnyReport {ProcName Message errmsg} {
#    set ::osvvm::${ProcName}ErrorInfo $::errorInfo
    set ::osvvm::ReportErrorInfo $::errorInfo
    set ::osvvm::ScriptErrorCount    [expr $::osvvm::ScriptErrorCount+1]

    # Report Error
    puts "ReportError: during $ProcName $Message failed: $errmsg"
    
        # Reference or print ErrorInfo for this error 
    if {$::osvvm::ScriptDebug} {
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