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

  package require fileutil

  proc Log2Osvvm {LogFile} {
    variable LogFileHandle
    variable HtmlFileHandle
    variable SimFileHandle
    variable OsvvmFileHandle
    variable LocalLogType           "html"
    variable LocalCreateSimScripts  "false"
    variable LocalCreateOsvvmOutput "false"
    variable ResultsDirectory
    variable RelativePathToResults

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

    set RelativePathToResults [::fileutil::relative ${LogDir} ${ResultsDirectory}]

    if {$LocalLogType eq "html"} {
      set HtmlFile [file join ${LogDir} ${LogName}_log.html]
      set HtmlFileHandle [open $HtmlFile w]
      CreateHeaderLog2Html
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

  proc CreateHeaderLog2Html {} {
    variable HtmlFileHandle
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

  proc LocalLog2Osvvm {LogFile LocalLogType LocalCreateSimScripts LocalCreateOsvvmOutput} {
    variable LogFileHandle
    variable LineOfLogFile
    variable InRunTest 0
    variable LogTestSuiteName Default
    variable LogTestCaseName  Default
    variable PrintPrefix ""
    variable FoundBuild "false"
    variable FirstLine  "true"
    variable Log2HtmlTextColor
#!!    variable InSimulate FALSE
#!!    variable FoundTranscript FALSE
    variable RelativePathToResults

    # Read whole file and split it into lines
    # foreach RawLineOfLogFile [split [read $LogFileHandle] \n] {  } ;

    # Read line by line - Recommended
    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {

# replace with a single regsub by detecting Aldec
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
    variable Log2HtmlTextColor
#!!    variable InSimulate
#!!    variable FoundTranscript
    variable RelativePathToResults
    variable ResultsDirectory

    #
    # Check for things that happen more in the log file
    #
    if {[regexp {Log *(PASSED)} $LineOfLogFile] } {
#!!      set FoundTranscript TRUE
      set Log2HtmlTextColor #00A000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {Log *(INFO|ALWAYS|DEBUG|FINAL)} $LineOfLogFile] } {
#!!      set FoundTranscript TRUE
      puts $HtmlFileHandle $LineOfLogFile

    } elseif {[regexp {Alert *(ERROR|FAILURE)} $LineOfLogFile] } {
#!!      set FoundTranscript TRUE
      set Log2HtmlTextColor #FF0000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {Alert *WARNING} $LineOfLogFile] } {
#!!      set FoundTranscript TRUE
      set Log2HtmlTextColor #FF8000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {%%>} $LineOfLogFile]} {
#!! May need to set Log2HtmlTextColor in other branches too.
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {%%x} $LineOfLogFile]} {
      if {[file exists [file join $ResultsDirectory ${LogTestSuiteName} ${LogTestCaseName}.html]]} {
        puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults ${LogTestSuiteName} ${LogTestCaseName}.html]\"  style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
      }

    } elseif {[regexp {DONE *(FAILED|STOPLIMIT|TIMEOUT|NOCHECKS)} $LineOfLogFile]} {
#!!      if {$InSimulate && !($FoundTranscript)} {
#!!        # Link in transcript html if transcript matches test case name
#!!        if {[file exists [file join $ResultsDirectory ${LogTestSuiteName} ${LogTestCaseName}.html]]} {
#!!          puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults ${LogTestSuiteName} ${LogTestCaseName}.html]\"  style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
#!!        }
#!!        set InSimulate FALSE
#!!      }
      set Log2HtmlTextColor #FF0000
      set PrintPrefix "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {DONE *MANUALCHECK} $LineOfLogFile]} {
#!!      if {$InSimulate && !($FoundTranscript)} {
#!!        # Link in transcript html if transcript matches test case name
#!!        if {[file exists [file join $ResultsDirectory ${LogTestSuiteName} ${LogTestCaseName}.html]]} {
#!!          puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults ${LogTestSuiteName} ${LogTestCaseName}.html]\"  style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
#!!        }
#!!        set InSimulate FALSE
#!!      }
      set Log2HtmlTextColor #FF8000
      set PrintPrefix "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {DONE *PASSED} $LineOfLogFile]} {
#!!      if {$InSimulate && !($FoundTranscript)} {
#!!        # Link in transcript
#!!        if {[file exists [file join $ResultsDirectory ${LogTestSuiteName} ${LogTestCaseName}.html]]} {
#!!          puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults ${LogTestSuiteName} ${LogTestCaseName}.html]\"  style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
#!!        }
#!!        set InSimulate FALSE
#!!      }
      set Log2HtmlTextColor #00A000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {^analyze} $LineOfLogFile] } {
      if {! $InRunTest} {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
        set PrintPrefix "</details>"
      } else {
        puts $HtmlFileHandle $LineOfLogFile
      }

    } elseif {[regexp {^RunTest} $LineOfLogFile] } {
      set InRunTest 1
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"

    } elseif {[regexp {^TestName} $LineOfLogFile] } {
        set LogTestCaseName [lindex $LineOfLogFile 1]
        puts $HtmlFileHandle $LineOfLogFile

    } elseif {[regexp {^simulate} $LineOfLogFile] } {
#!!      set InSimulate TRUE
#!!      set FoundTranscript FALSE
      set GenericNames ""
      if {[regexp {generic} $LineOfLogFile] } {
        set GenericDict [regsub {\].*} [regsub -all {[^\[]*\[generic ([^\]]*)} $LineOfLogFile {\1 }] ""]
        set GenericNames [ToGenericNames $GenericDict]
#        foreach {name val} $GenericDict {
#          set GenericNames ${GenericNames}_${name}_${val}
#        }
      }
      if {! $InRunTest} {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary><span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
        set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"
      } else {
        puts $HtmlFileHandle "$LineOfLogFile <span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
      }
      set InRunTest 0

    } elseif {[regexp {^build|^include|^library|^MkVproc|^MkVprocNoClean|^MkVprocSkt|^MkVprocGhdlMain} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>${LineOfLogFile}</summary>"
      set PrintPrefix "</details>"

    } elseif {[regexp {^TestSuite} $LineOfLogFile] } {
      set LogTestSuiteName [lindex $LineOfLogFile 1]
      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
      set PrintPrefix "</details>"

    } elseif {[regexp {^Build Start} $LineOfLogFile] } {
      if {[regexp {</details>} ${PrintPrefix}]}  {
        puts $HtmlFileHandle "${PrintPrefix}${LineOfLogFile}"
      } else {
        puts $HtmlFileHandle "${PrintPrefix}\n${LineOfLogFile}"
      }
      set PrintPrefix ""

    } elseif {[regexp {^AnalyzeError:|^SimulateError:|^ScriptError:|^ReportError:|^LibraryError:|^BuildError:} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
      set PrintPrefix ""

    } elseif {[regexp {^Build:} $LineOfLogFile] } {
      puts $HtmlFileHandle "${PrintPrefix}<span style=color:#00A000>$LineOfLogFile</span>"
      set PrintPrefix ""

    } elseif {[regexp {^WaveError:} $LineOfLogFile] } {
      set Log2HtmlTextColor #FF0000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } elseif {[regexp {^(E|e)rror:} $LineOfLogFile] } {
      set Log2HtmlTextColor #FF0000
      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

    } else {
      set Log2HtmlTextColor #000000
      puts $HtmlFileHandle $LineOfLogFile
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

  proc Transcript2Html {TranscriptFile} {
    variable HtmlFileHandle
    variable TranscriptFileHandle

    # Open Transcript File to Read
    set TranscriptFileHandle [open $TranscriptFile r]
    set TranscriptDir  [file dirname $TranscriptFile]
    set TranscriptName [file rootname [file tail $TranscriptFile]]

    # Open HTML File to Write
    set HtmlFile [file join ${TranscriptDir} ${TranscriptName}.html]
    set HtmlFileHandle [open $HtmlFile w]

    # Header for HTML file
    CreateHeaderLog2Html

    set ErrorCode [catch {LocalTranscript2Html} errmsg]

    close $TranscriptFileHandle

    puts $HtmlFileHandle "</body>"
    close $HtmlFileHandle

    if {$ErrorCode} {
      CallbackOnError_Transcript2Html $TranscriptFile $errmsg
    }
  }


  proc LocalTranscript2Html {} {
    variable TranscriptFileHandle
    variable HtmlFileHandle
    variable Log2HtmlTextColor

    # Read whole file and split it into lines
    foreach LineOfLogFile [split [read $TranscriptFileHandle] \n] {
      # Simple subset of checks done by Log2Html
      if {[regexp {Alert *(ERROR|FAILURE)} $LineOfLogFile] } {
        set Log2HtmlTextColor #FF0000
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } elseif {[regexp {Alert *WARNING} $LineOfLogFile] } {
        set Log2HtmlTextColor #FF8000
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } elseif {[regexp {%%>} $LineOfLogFile]} {
          # uses previous Log2HtmlTextColor
          puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } elseif {[regexp {DONE *(FAILED|STOPLIMIT|TIMEOUT|NOCHECKS)} $LineOfLogFile]} {
        set Log2HtmlTextColor #FF0000
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } elseif {[regexp {DONE *MANUALCHECK} $LineOfLogFile]} {
        set Log2HtmlTextColor #FF8000
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } elseif {[regexp {DONE *PASSED} $LineOfLogFile]} {
        set Log2HtmlTextColor #00A000
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"

      } else {
        set Log2HtmlTextColor #000000
        puts $HtmlFileHandle $LineOfLogFile
      }
    }
  }

namespace export Log2Osvvm Transcript2Html

# end namespace ::osvvm
}

