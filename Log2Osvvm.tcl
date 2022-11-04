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
    
    set LogFileHandle [open $LogFile r]
    set LogDir  [file dirname $LogFile]
    set LogName [file rootname [file tail $LogFile]]
    
    if {$::osvvm::TranscriptExtension eq "html"} {
      set HtmlFile [file join ${LogDir} ${LogName}_log.html]
      set HtmlFileHandle [open $HtmlFile w]
    }
    if {$::osvvm::CreateSimScripts} {
      set SimFile [file join ${LogDir} ${LogName}_sim.tcl]
      set SimFileHandle [open $SimFile w]
    }
    if {$::osvvm::CreateOsvvmOutput} {
      set OsvvmFile [file join ${LogDir} ${LogName}_osvvm.log]
      set OsvvmFileHandle [open $OsvvmFile w]
    }
    
    set ErrorCode [catch {LocalLog2Osvvm $LogFile} errmsg]
    
    close $LogFileHandle 
    
    if {$::osvvm::TranscriptExtension eq "html"} {
      close $HtmlFileHandle 
    }
    if {$::osvvm::CreateSimScripts} {
      close $SimFileHandle 
    }
    if {$::osvvm::CreateOsvvmOutput} {
      close $OsvvmFileHandle 
    }
    
    if {$ErrorCode} {
      CallbackOnError_Log2Osvvm $LogFile $errmsg
    }
  }

  proc LocalLog2Osvvm {LogFile} {
    variable LogFileHandle
    variable LineOfLogFile
    variable InRunTest 0
    variable TestSuiteName Default
    variable PrintPrefix "<pre>"

    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {
#      set LineOfLogFile [regsub {^KERNEL: %%} [regsub {^# } $RawLineOfLogFile ""] "%%"]
      set LineOfLogFile [regsub {^KERNEL: } [regsub {^# } $RawLineOfLogFile ""] ""]
        
      if {$::osvvm::TranscriptExtension eq "html"} {
        Log2Html  
      }
      if {$::osvvm::CreateSimScripts} {
        Log2Sim 
      }
      if {$::osvvm::CreateOsvvmOutput} {
        Log2OsvvmOutput  
      }
    }
  }

  proc Log2Html {} {
    variable HtmlFileHandle
    variable LineOfLogFile
    variable InRunTest
    variable TestSuiteName 
    variable TestCaseName 
    variable PrintPrefix 
    
    if {[regexp {^Build Start} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}$LineOfLogFile"
      set PrintPrefix ""
    } elseif {[regexp {^build|^include} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>${LineOfLogFile}</summary>"
      set PrintPrefix "</details>"
    } elseif {[regexp {^TestSuite} $LineOfLogFile] } {
      set TestSuiteName [lindex $LineOfLogFile 1]
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "</details>"
    } elseif {[regexp {^RunTest} $LineOfLogFile] } {
      set InRunTest 1
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "</details>"
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
      if {! $InRunTest} {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary><span id=\"${TestSuiteName}_${TestCaseName}\" />"
        set PrintPrefix "</details>"
      } else {
        puts $HtmlFileHandle "$LineOfLogFile <span id=\"${TestSuiteName}_${TestCaseName}\" />"
      }
      set InRunTest 0
    } else {
      if {[regexp {^TestCase} $LineOfLogFile] } {
        set TestCaseName [lindex $LineOfLogFile 1]
      }
      if {[regexp {DONE   FAILED} $LineOfLogFile]} {
        set PrintPrefix "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
        puts $HtmlFileHandle "<span style=color:#FF0000>$LineOfLogFile</span>"
      } elseif {[regexp {^WaveError:} $LineOfLogFile] } {
        puts $HtmlFileHandle "<span style=color:#FF0000>$LineOfLogFile</span>"
      } elseif {[regexp {^Error:|^error:} $LineOfLogFile] } {
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

}

