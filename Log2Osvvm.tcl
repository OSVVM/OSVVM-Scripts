#  File Name:         Log2Osvvm.tcl
#  Purpose:           Extract information from OSVVM Log Files
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Log2Osvvm - Create HTML, Simulation Scripts, and osvvm logs
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
#    07/2024   2024.07    Minor name updates
#    06/2022   2022.06    Initial Revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2022 by SynthWorks Design Inc.  
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

namespace eval ::osvvm {

  proc Log2Osvvm {LogFile} {
    variable LogFileHandle
    variable HtmlFileHandle
    variable SimFileHandle
    variable OsvvmFileHandle
    variable LocalLogType           "html"
    variable LocalCreateSimScripts  "false"
    variable LocalCreateOsvvmOutput "false"
    
    if {[info exists ::osvvm::TranscriptExtension]} {
      set LocalLogType $::osvvm::TranscriptExtension
    }
    if {[info exists ::osvvm::CreateSimScripts]} {
      set LocalCreateSimScripts $::osvvm::CreateSimScripts
    }
    if {[info exists ::osvvm::CreateOsvvmOutput]} {
      set LocalCreateOsvvmOutput $::osvvm::CreateOsvvmOutput
    }
    
    set LogFileHandle [open $LogFile r]
    set LogDir  [file dirname $LogFile]
    set LogName [file rootname [file tail $LogFile]]
    
    if {$LocalLogType eq "html"} {
      set HtmlFile [file join ${LogDir} ${LogName}_log.html]
      set HtmlFileHandle [open $HtmlFile w]
      puts $HtmlFileHandle "<html>"
      puts $HtmlFileHandle "<style>"
      puts $HtmlFileHandle "details > summary {"
      puts $HtmlFileHandle "  position: sticky; "
      puts $HtmlFileHandle "  top: 0; "
      puts $HtmlFileHandle "}"
      puts $HtmlFileHandle "details\[open\] > summary {"
      puts $HtmlFileHandle "  color: white; "
      puts $HtmlFileHandle "  background: black; "
      puts $HtmlFileHandle "}"
      puts $HtmlFileHandle ".SummaryEnd {"
      puts $HtmlFileHandle "  color: white; "
      puts $HtmlFileHandle "  background: gray; "
      puts $HtmlFileHandle "}"
      puts $HtmlFileHandle "</style>"
      puts $HtmlFileHandle "<body>"
      puts $HtmlFileHandle "<pre>"
    }   
    if {$LocalCreateSimScripts} {
      set SimFile [file join ${LogDir} ${LogName}_sim.tcl]
      set SimFileHandle [open $SimFile w]
    }
    if {$LocalCreateOsvvmOutput} {
      set OsvvmFile [file join ${LogDir} ${LogName}_osvvm.log]
      set OsvvmFileHandle [open $OsvvmFile w]
    }
    
    set ErrorCode [catch {LocalLog2Osvvm $LogFile $LocalLogType $LocalCreateSimScripts $LocalCreateOsvvmOutput} errmsg]
    
    close $LogFileHandle 
    
    if {$LocalLogType eq "html"} {
      puts $HtmlFileHandle "</body>"
      close $HtmlFileHandle 
    }
    if {$LocalCreateSimScripts} {
      close $SimFileHandle 
    }
    if {$LocalCreateOsvvmOutput} {
      close $OsvvmFileHandle 
    }
    
    if {$ErrorCode} {
      CallbackOnError_Log2Osvvm $LogFile $errmsg
    }
  }

  proc LocalLog2Osvvm {LogFile LocalLogType LocalCreateSimScripts LocalCreateOsvvmOutput} {
    variable LogFileHandle
    variable LineOfLogFile
    variable InRunTest 0
    variable LogTestSuiteName Default
    variable LogTestCaseName  Default
    variable PrintPrefix ""
    variable FoundBuild "false" 
    variable FirstLine  "true"

    # Read line by line - For OSVVM regressions, this is 50 to 100 ms slower
    #   while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {  } ; 
    
    # Read whole file and split it into lines
    foreach RawLineOfLogFile [split [read $LogFileHandle] \n] {
      set LineOfLogFile [regsub {^KERNEL: } [regsub {^# } $RawLineOfLogFile ""] ""]
      
      if {!$FoundBuild} {
        set FoundBuild [FindBuildInLog]
      }
      
      if {$FoundBuild} {
        if {$LocalLogType eq "html"} {
          Log2Html  
        }
        if {$LocalCreateSimScripts} {
          Log2Sim 
        }
        if {$LocalCreateOsvvmOutput} {
          Log2OsvvmOutput  
        }
      }
    }
  }

  proc FindBuildInLog {} {
    variable HtmlFileHandle
    variable LineOfLogFile
    variable FirstLine
    variable PrintPrefix 
    
    return [regexp {^build} $LineOfLogFile]
#    if {[regexp {^build} $LineOfLogFile] } {
#      return "true"
#    } else {
#      if {$FirstLine} {
#        puts $HtmlFileHandle "${PrintPrefix}<details><summary>Simulator Startup Stuff</summary>"
#        puts $HtmlFileHandle "<!--"
#        set PrintPrefix "--></details>"
#        set FirstLine "false"
#      }
#      puts $HtmlFileHandle $LineOfLogFile
#      return "false"
#    }
  }

  proc Log2Html {} {
    variable HtmlFileHandle
    variable LineOfLogFile
    variable InRunTest
    variable LogTestSuiteName 
    variable LogTestCaseName 
    variable PrintPrefix 
    
    if {[regexp {^Build Start} $LineOfLogFile] } {
#      if {$PrintPrefix eq "</details>"} { }
      if {[regexp {</details>} ${PrintPrefix}]}  {
        puts $HtmlFileHandle "${PrintPrefix}${LineOfLogFile}"
      } else {
        puts $HtmlFileHandle "${PrintPrefix}\n${LineOfLogFile}"
      }
      set PrintPrefix ""
    } elseif {[regexp {^build|^include|^MkVproc|^MkVprocNoClean|^MkVprocSkt|^MkVprocGhdlMain} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>${LineOfLogFile}</summary>"
      set PrintPrefix "</details>"
    } elseif {[regexp {^TestSuite} $LineOfLogFile] } {
      set LogTestSuiteName [lindex $LineOfLogFile 1]
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "</details>"
    } elseif {[regexp {^RunTest} $LineOfLogFile] } {
      set InRunTest 1
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"
    } elseif {[regexp {^AnalyzeError:|^SimulateError:|^ScriptError:|^ReportError:|^LibraryError:|^BuildError:} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
      set PrintPrefix ""
    } elseif {[regexp {^Build:} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<span style=color:#00C000>$LineOfLogFile</span>"
      set PrintPrefix ""
    } elseif {[regexp {^analyze} $LineOfLogFile] } {
      if {! $InRunTest} {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
        set PrintPrefix "</details>"
      } else {
        puts $HtmlFileHandle $LineOfLogFile
      }
    } elseif {[regexp {^simulate} $LineOfLogFile] } {
      set GenericNames ""
      if {[regexp {generic} $LineOfLogFile] } {
        set GenericDict [regsub {\].*} [regsub -all {[^\[]*\[generic ([^\]]*)} $LineOfLogFile {\1 }] ""]
        foreach {name val} $GenericDict {
          set GenericNames ${GenericNames}_${name}_${val}
        }
      }
      if {! $InRunTest} {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary><span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
        set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"
      } else {
        puts $HtmlFileHandle "$LineOfLogFile <span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
      }
      set InRunTest 0
    } else {
      if {[regexp {^TestName} $LineOfLogFile] } {
        set LogTestCaseName [lindex $LineOfLogFile 1]
      }
      if {[regexp {DONE   FAILED} $LineOfLogFile]} {
        set PrintPrefix "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
        puts $HtmlFileHandle "<span style=color:#FF0000>$LineOfLogFile</span>"
      } elseif {[regexp {^WaveError:} $LineOfLogFile] } {
        puts $HtmlFileHandle "<span style=color:#FF0000>$LineOfLogFile</span>"
      } elseif {[regexp {^Error:|^error:|Alert  ERROR} $LineOfLogFile] } {
        puts $HtmlFileHandle "<span style=color:#FF0000>$LineOfLogFile</span>"
      } else {
        puts $HtmlFileHandle $LineOfLogFile
      }
    }
  }

  proc Log2Sim {} {
    variable SimFileHandle
    variable LineOfLogFile
    
    if {[IsVendorCommand $LineOfLogFile]} {
      puts $SimFileHandle [regsub {\{\*\}} $LineOfLogFile ""]
    }
  }

  proc Log2OsvvmOutput {} {
    variable OsvvmFileHandle
    variable LineOfLogFile

    if {[regexp {^%%|^simulate |^TestCase } $LineOfLogFile] } {
      puts $OsvvmFileHandle $LineOfLogFile
    }
  }
  
namespace export Log2Osvvm

# end namespace ::osvvm
}

