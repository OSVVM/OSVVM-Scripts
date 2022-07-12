#  File Name:         Log2Html.tcl
#  Purpose:           Extract information from OSVVM Log Files
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Log2Osvvm - find lines in an OSVVM log file that start with %%
#    Log2Html  - convert an OSVVM log file to HtmlFile
#    Log2Sim   - convert an OSVVM log file to a simulation script
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

  proc Log2OsvvmOutput {LogFile} {

    set LogFileHandle [open $LogFile r]
    set LogDir  [file dirname $LogFile]
    set LogName [file rootname [file tail $LogFile]]
    
    set OsvvmFile [file join ${LogDir} ${LogName}_osvvm.log]
    set OsvvmFileHandle [open $OsvvmFile w]

    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {
      set LineOfLogFile [regsub {^KERNEL: %%} [regsub {^# } $RawLineOfLogFile ""] "%%"]
      if {[regexp {^%%|^simulate } $LineOfLogFile] } {
        puts $OsvvmFileHandle $LineOfLogFile
      }
    }
    close $LogFileHandle 
    close $OsvvmFileHandle 
  }

  proc Log2Html {LogFile} {
    set LogFileHandle [open $LogFile r]
    set LogDir  [file dirname $LogFile]
    set LogName [file rootname [file tail $LogFile]]
    
    set HtmlFile [file join ${LogDir} ${LogName}_log.html]
    set HtmlFileHandle [open $HtmlFile w]
    
    set InRunTest 0
    set FirstFind 1
    set TestSuiteName Default
    set PrintPrefix "<pre><details>"
    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {
      set LineOfLogFile [regsub {^KERNEL: %%} [regsub {^# } $RawLineOfLogFile ""] "%%"]
      if {[regexp {^Build Start} $LineOfLogFile] } {
        puts $HtmlFileHandle "</details>"
        puts $HtmlFileHandle $LineOfLogFile
      } elseif {[regexp {^build|^include} $LineOfLogFile] } {
        puts $HtmlFileHandle "${PrintPrefix}<summary>${LineOfLogFile}</summary>"
        if {$FirstFind} {
          set PrintPrefix "</details><details>"
          set FirstFind 0
        } 
      } elseif {[regexp {^TestSuite} $LineOfLogFile] } {
        set TestSuiteName [lindex $LineOfLogFile 1]
        puts $HtmlFileHandle "</details><details><summary>$LineOfLogFile</summary>"
      } elseif {[regexp {^RunTest} $LineOfLogFile] } {
        set InRunTest 1
        puts $HtmlFileHandle "</details><details><summary>$LineOfLogFile</summary>"
      } elseif {[regexp {^AnalyzeError:|^SimulateError:} $LineOfLogFile] } {
          puts $HtmlFileHandle "</details><details><summary style=color:#FF0000>$LineOfLogFile</summary>"
      } elseif {[regexp {^analyze} $LineOfLogFile] } {
        if {! $InRunTest} {
          puts $HtmlFileHandle "</details><details><summary>$LineOfLogFile</summary>"
        } else {
          puts $HtmlFileHandle $LineOfLogFile
        }
      } elseif {[regexp {^simulate} $LineOfLogFile] } {
        if {! $InRunTest} {
          puts $HtmlFileHandle "</details><details><summary>$LineOfLogFile</summary> <div id=\"${TestSuiteName}_${TestCaseName}\" />"
        } else {
          puts $HtmlFileHandle "$LineOfLogFile <div id=\"${TestSuiteName}_[lindex $LineOfLogFile 1]\" />"
        }
  #      puts $HtmlFileHandle "<div id=\"[lindex $LineOfLogFile 1]\" />"
        set InRunTest 0
      } else {
        if {[regexp {^TestCase} $LineOfLogFile] } {
          set TestCaseName [lindex $LineOfLogFile 1]
        }
        puts $HtmlFileHandle $LineOfLogFile
      }
    }
    close $LogFileHandle 
    close $HtmlFileHandle 
  }

  proc Log2Sim {LogFile} {
    set LogFileHandle [open $LogFile r]
    set LogDir  [file dirname $LogFile]
    set LogName [file rootname [file tail $LogFile]]
    
    set SimFile [file join ${LogDir} ${LogName}_sim.tcl]
    set SimFileHandle [open $SimFile w]
    
    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {
      set LineOfLogFile [regsub {^# } $RawLineOfLogFile ""]
      if {[IsVendorCommand $LineOfLogFile]} {
        puts $SimFileHandle [regsub {\{\*\}} $LineOfLogFile ""]
      }
    }
    close $LogFileHandle 
    close $SimFileHandle 
  }

namespace export Log2Sim Log2Html GrepOsvvm

}

