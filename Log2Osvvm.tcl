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
    # Convert the build's simulator transcript to its HTML version and further outputs.
    #  LogFile - Transcript of the build, `<BuildName>.log`.
    #
    # Writes, next to `LogFile`, from the line starting with `build` on (`LocalLog2Osvvm`):
    #
    # `<BuildName>_log.html`  - HTML transcript, if `TranscriptExtension` is `html` ([SetTranscriptType])
    # `<BuildName>_sim.tcl`   - the simulator commands, if `CreateSimScripts` is set
    # `<BuildName>_osvvm.log` - OSVVM's output lines, if `CreateOsvvmOutput` is set
    #
    # On an error, the files are closed and `CallbackOnError_Log2Osvvm` is called. Called at the end of a [build].
    #
    # See also: [Transcript2Html] [SetTranscriptType]
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
    # Write the start of an HTML transcript.
    #
    # Writes the styles for the sticky, collapsible sections and opens the preformatted body.
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
    # Convert the transcript line by line.
    #  LogFile                - Transcript of the build. Not used; the open channel `LogFileHandle` is read.
    #  LocalLogType           - `html`: write the HTML transcript (`Log2Html`).
    #  LocalCreateSimScripts  - If true, write the simulator commands (`Log2Sim`).
    #  LocalCreateOsvvmOutput - If true, write OSVVM's output lines (`Log2OsvvmOutput`).
    #
    # Removes the prefixes `# KERNEL: ` and `# ` that simulators put before the lines. Lines before the first line
    # starting with `build` are skipped (`FindBuildInLog`). Errors are handled by [Log2Osvvm].
    variable LogFileHandle
    variable LineOfLogFile
    variable InRunTest 0
    variable LogTestSuiteName Default
    variable LogTestCaseName  Default
    variable PrintPrefix ""
    variable FoundBuild "false"
    variable FirstLine  "true"
    variable Log2HtmlTextColor
    variable RelativePathToResults

    # Read whole file and split it into lines
    # foreach RawLineOfLogFile [split [read $LogFileHandle] \n] {  } ;

    # Read line by line - Recommended
    while { [gets $LogFileHandle RawLineOfLogFile] >= 0 } {

# replace with a single regsub by detecting Aldec
      # set LineOfLogFile [regsub {^KERNEL: } [regsub {^# } $RawLineOfLogFile ""] ""]
      #!! set LineOfLogFile [regsub {^(# KERNEL: |# )} $RawLineOfLogFile ""]
      if {[string match "# KERNEL: *" $RawLineOfLogFile]} {
        set LineOfLogFile [string range $RawLineOfLogFile 10 end]
      } elseif {[string match "# *" $RawLineOfLogFile]} {
        set LineOfLogFile [string range $RawLineOfLogFile 2 end]
      } else {
        set LineOfLogFile $RawLineOfLogFile
      }

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
    # Check whether the current transcript line starts a build.
    #
    # Returns 1 if `LineOfLogFile` starts with `build`, else 0.
    variable HtmlFileHandle
    variable LineOfLogFile
    variable FirstLine
    variable PrintPrefix

    #!! return [regexp {^build} $LineOfLogFile]
    return [string match "build*" $LineOfLogFile]
  }

#!!  proc Log2Html {} {
#!!    variable HtmlFileHandle
#!!    variable LineOfLogFile
#!!    variable InRunTest
#!!    variable LogTestSuiteName
#!!    variable LogTestCaseName
#!!    variable PrintPrefix
#!!    variable Log2HtmlTextColor
#!!    variable RelativePathToResults
#!!    variable ResultsDirectory
#!!
#!!    #
#!!    # Check for things that happen more in the log file
#!!    #
#!!
#!!#  Add GT after switching the continuation line character
#!!#    set LineOfLogFile [string map {& &amp; < &lt;} $LineOfLogFile]
#!!    set LineOfLogFile [string map {& &amp; < &lt; > &gt;} $LineOfLogFile]
#!!
#!!    if {[regexp {Log *(PASSED)} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #00A000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {Log *(INFO|ALWAYS|DEBUG|FINAL)} $LineOfLogFile] } {
#!!      puts $HtmlFileHandle $LineOfLogFile
#!!
#!!    } elseif {[regexp {Alert *(ERROR|FAILURE)} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #FF0000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {Alert *WARNING} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #FF8000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {%%:} $LineOfLogFile]} {
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {%%x} $LineOfLogFile]} {
#!!      if {[file exists [file join $ResultsDirectory ${LogTestSuiteName} ${LogTestCaseName}.html]]} {
#!!        puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults ${LogTestSuiteName} ${LogTestCaseName}.html]\"  style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
#!!      }
#!!
#!!    } elseif {[regexp {DONE *(FAILED|STOPLIMIT|TIMEOUT|NOCHECKS)} $LineOfLogFile]} {
#!!      set Log2HtmlTextColor #FF0000
#!!      set PrintPrefix "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {DONE *MANUALCHECK} $LineOfLogFile]} {
#!!      set Log2HtmlTextColor #FF8000
#!!      set PrintPrefix "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {DONE *PASSED} $LineOfLogFile]} {
#!!      set Log2HtmlTextColor #00A000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {^analyze} $LineOfLogFile] } {
#!!      if {! $InRunTest} {
#!!        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
#!!        set PrintPrefix "</details>"
#!!      } else {
#!!        puts $HtmlFileHandle $LineOfLogFile
#!!      }
#!!
#!!    } elseif {[regexp {^RunTest} $LineOfLogFile] } {
#!!      set InRunTest 1
#!!      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
#!!      set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"
#!!
#!!    } elseif {[regexp {^TestName} $LineOfLogFile] } {
#!!        set LogTestCaseName [lindex $LineOfLogFile 1]
#!!        puts $HtmlFileHandle $LineOfLogFile
#!!
#!!    } elseif {[regexp {^simulate} $LineOfLogFile] } {
#!!      set GenericNames ""
#!!      if {[regexp {generic} $LineOfLogFile] } {
#!!        set GenericDict [regsub {\].*} [regsub -all {[^\[]*\[generic ([^\]]*)} $LineOfLogFile {\1 }] ""]
#!!        set GenericNames [ToGenericNames $GenericDict]
#!!      }
#!!      if {! $InRunTest} {
#!!        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary><span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
#!!        set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}<\span></details>"
#!!      } else {
#!!        puts $HtmlFileHandle "$LineOfLogFile <span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
#!!      }
#!!      set InRunTest 0
#!!
#!!    } elseif {[regexp {^build|^include|^library|^MkVproc|^MkVprocNoClean|^MkVprocSkt|^MkVprocGhdlMain} $LineOfLogFile] } {
#!!      puts $HtmlFileHandle "${PrintPrefix}<details><summary>${LineOfLogFile}</summary>"
#!!      set PrintPrefix "</details>"
#!!
#!!    } elseif {[regexp {^TestSuite} $LineOfLogFile] } {
#!!      set LogTestSuiteName [lindex $LineOfLogFile 1]
#!!      puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
#!!      set PrintPrefix "</details>"
#!!
#!!    } elseif {[regexp {^Build Start} $LineOfLogFile] } {
#!!      if {[regexp {</details>} ${PrintPrefix}]}  {
#!!        puts $HtmlFileHandle "${PrintPrefix}${LineOfLogFile}"
#!!      } else {
#!!        puts $HtmlFileHandle "${PrintPrefix}\n${LineOfLogFile}"
#!!      }
#!!      set PrintPrefix ""
#!!
#!!    } elseif {[regexp {^AnalyzeError:|^SimulateError:|^ScriptError:|^ReportError:|^LibraryError:|^BuildError:} $LineOfLogFile] } {
#!!      puts $HtmlFileHandle "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
#!!      set PrintPrefix ""
#!!
#!!    } elseif {[regexp {^Build:} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #00A000
#!!      puts $HtmlFileHandle "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!      set PrintPrefix ""
#!!
#!!    } elseif {[regexp {^WaveError:} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #FF0000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } elseif {[regexp {^(E|e)rror:} $LineOfLogFile] } {
#!!      set Log2HtmlTextColor #FF0000
#!!      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!    } else {
#!!      set Log2HtmlTextColor #000000
#!!      puts $HtmlFileHandle $LineOfLogFile
#!!    }
#!!  }
  proc Log2Html {} {
    # Write the current transcript line to the HTML transcript.
    #
    # Encodes HTML special characters. Colors passed checks and test cases green, errors and failures red and warnings
    # orange; lines starting with `%%:` keep the previous color. A line with `%%x` embeds the HTML test case report.
    # Each `build`, `include`, `library`, `TestSuite`, `RunTest`, `analyze` and `simulate` line opens a collapsible
    # section, closed by the next one. `simulate` lines get an anchor `<TestSuite>_<TestCase><GenericNames>`, the target
    # of the test case report's link.
    variable HtmlFileHandle
    variable LineOfLogFile
    variable InRunTest
    variable LogTestSuiteName
    variable LogTestCaseName
    variable PrintPrefix
    variable Log2HtmlTextColor
    variable RelativePathToResults
    variable ResultsDirectory

    # HTML entity encoding
    set LineOfLogFile [string map {& &amp; < &lt; > &gt;} $LineOfLogFile]

    # Fast glob matching for common log patterns
    switch -glob -- $LineOfLogFile {
      "*Log *PASSED*" -
      "*DONE *PASSED*" {
        set Log2HtmlTextColor "#00A000"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "*Log *INFO*" -
      "*Log *ALWAYS*" -
      "*Log *DEBUG*" -
      "*Log *FINAL*" {
        puts $HtmlFileHandle $LineOfLogFile
      }
      "*Alert *ERROR*" -
      "*Alert *FAILURE*" {
        set Log2HtmlTextColor "#FF0000"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "*Alert *WARNING*" {
        set Log2HtmlTextColor "#FF8000"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "%%:*" {
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "%%x*" {
        if {[file exists [file join $ResultsDirectory $LogTestSuiteName ${LogTestCaseName}.html]]} {
          puts $HtmlFileHandle "<iframe src=\"[file join $RelativePathToResults $LogTestSuiteName ${LogTestCaseName}.html]\" style=\"border: none; margin: 0; padding: 0; display: block;\" width=\"100%\" height=\"60%\" title=\"Embedded Page\"></iframe>"
        }
      }
      "*DONE *FAILED*" -
      "*DONE *STOPLIMIT*" -
      "*DONE *TIMEOUT*" -
      "*DONE *NOCHECKS*" {
        set Log2HtmlTextColor "#FF0000"
        append PrintPrefix "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "*DONE *MANUALCHECK*" {
        set Log2HtmlTextColor "#FF8000"
        append PrintPrefix "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile\n</span>"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      "analyze*" {
        if {!$InRunTest} {
          puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
          set PrintPrefix "</details>"
        } else {
          puts $HtmlFileHandle $LineOfLogFile
        }
      }
      "RunTest*" {
        set InRunTest 1
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
        set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}</span></details>"
      }
      "*TestName*" {
        set LogTestCaseName [lindex $LineOfLogFile 1]
        puts $HtmlFileHandle $LineOfLogFile
      }
      "simulate*" {
        set GenericNames ""
        if {[string match "*generic*" $LineOfLogFile]} {
          set GenericDict [regsub {\].*} [regsub -all {[^\[]*\[generic ([^\]]*)} $LineOfLogFile {\1 }] ""]
          set GenericNames [ToGenericNames $GenericDict]
        }
        if {!$InRunTest} {
          puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary><span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
          set PrintPrefix "<span class=\"SummaryEnd\">&#9650; ${LineOfLogFile}</span></details>"
        } else {
          puts $HtmlFileHandle "$LineOfLogFile <span id=\"${LogTestSuiteName}_${LogTestCaseName}${GenericNames}\" />"
        }
        set InRunTest 0
      }
      "build*" -
      "include*" -
      "library*" -
      "MkVproc*" -
      "MkVprocNoClean*" -
      "MkVprocSkt*" -
      "MkVprocGhdlMain*" {
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>${LineOfLogFile}</summary>"
        set PrintPrefix "</details>"
      }
      "TestSuite*" {
        set LogTestSuiteName [lindex $LineOfLogFile 1]
        puts $HtmlFileHandle "${PrintPrefix}<details><summary>$LineOfLogFile</summary>"
        set PrintPrefix "</details>"
      }
      "Build Start*" {
        if {[string match "*</details>*" $PrintPrefix]} {
          puts $HtmlFileHandle "${PrintPrefix}${LineOfLogFile}"
        } else {
          puts $HtmlFileHandle "${PrintPrefix}\n${LineOfLogFile}"
        }
        set PrintPrefix ""
      }
      "AnalyzeError:*" -
      "SimulateError:*" -
      "ScriptError:*" -
      "ReportError:*" -
      "LibraryError:*" -
      "BuildError:*" {
        puts $HtmlFileHandle "${PrintPrefix}<span style=color:#FF0000>$LineOfLogFile</span>"
        set PrintPrefix ""
      }
      "Build:*" {
        set Log2HtmlTextColor "#00A000"
        puts $HtmlFileHandle "${PrintPrefix}<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
        set PrintPrefix ""
      }
      "WaveError:*" -
      "[Ee]rror:*" {
        set Log2HtmlTextColor "#FF0000"
        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
      }
      default {
        set Log2HtmlTextColor "#000000"
        puts $HtmlFileHandle $LineOfLogFile
      }
    }
  }

  proc Log2Sim {} {
    # Write the current transcript line to the simulator script, if it's a simulator command.
    #
    # Uses the vendor script's `IsVendorCommand`. Removes Tcl's argument expansion from the line.
    variable SimFileHandle
    variable LineOfLogFile

    if {[IsVendorCommand $LineOfLogFile]} {
#!!      puts $SimFileHandle [regsub {\{\*\}} $LineOfLogFile ""]
      puts $SimFileHandle [string map {\{*\} ""} $LineOfLogFile]
    }
  }

  proc Log2OsvvmOutput {} {
    # Write the current transcript line to the OSVVM output, if it's an OSVVM line.
    #
    # OSVVM lines start with `%%`, `simulate ` or `TestCase `.
    variable OsvvmFileHandle
    variable LineOfLogFile

    switch -glob -- $LineOfLogFile {
      "%%*" -
      "simulate *" -
      "TestCase *" {
        puts $OsvvmFileHandle $LineOfLogFile
      }
    }

#!!    if {[regexp {^%%|^simulate |^TestCase } $LineOfLogFile] } {
#!!      puts $OsvvmFileHandle $LineOfLogFile
#!!    }
  }

  proc Transcript2Html {TranscriptFile} {
    # Convert a test case transcript to HTML.
    #  TranscriptFile - Transcript file, opened in VHDL with `TranscriptOpen`.
    #
    # Writes `<Name>.html` next to the transcript (`LocalTranscript2Html`). On an error, the files are closed and
    # `CallbackOnError_Transcript2Html` is called.
    #
    # Called when the transcript files of a test case are moved into the results directory.
    #
    # See also: [Log2Osvvm]
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


#!!  proc LocalTranscript2Html {} {
#!!    variable TranscriptFileHandle
#!!    variable HtmlFileHandle
#!!    variable Log2HtmlTextColor
#!!
#!!    # Read whole file and split it into lines
#!!    foreach LineOfLogFile [split [read $TranscriptFileHandle] \n] {
#!!      # Simple subset of checks done by Log2Html
#!!      if {[regexp {Alert *(ERROR|FAILURE)} $LineOfLogFile] } {
#!!        set Log2HtmlTextColor #FF0000
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } elseif {[regexp {Alert *WARNING} $LineOfLogFile] } {
#!!        set Log2HtmlTextColor #FF8000
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } elseif {[regexp {%%:} $LineOfLogFile]} {
#!!          # uses previous Log2HtmlTextColor
#!!          puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } elseif {[regexp {DONE *(FAILED|STOPLIMIT|TIMEOUT|NOCHECKS)} $LineOfLogFile]} {
#!!        set Log2HtmlTextColor #FF0000
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } elseif {[regexp {DONE *MANUALCHECK} $LineOfLogFile]} {
#!!        set Log2HtmlTextColor #FF8000
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } elseif {[regexp {DONE *PASSED} $LineOfLogFile]} {
#!!        set Log2HtmlTextColor #00A000
#!!        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#!!
#!!      } else {
#!!        set Log2HtmlTextColor #000000
#!!        puts $HtmlFileHandle $LineOfLogFile
#!!      }
#!!    }
#!!  }

#Rev1:  proc LocalTranscript2Html {} {
#Rev1:    variable TranscriptFileHandle
#Rev1:    variable HtmlFileHandle
#Rev1:    variable Log2HtmlTextColor "#000000"
#Rev1:
#Rev1:    while {[gets $TranscriptFileHandle LineOfLogFile] >= 0} {
#Rev1:      switch -glob -- $LineOfLogFile {
#Rev1:        "Alert *ERROR*" -
#Rev1:        "Alert *FAILURE*" -
#Rev1:        "DONE *FAILED*" -
#Rev1:        "DONE *STOPLIMIT*" -
#Rev1:        "DONE *TIMEOUT*" -
#Rev1:        "DONE *NOCHECKS*" {
#Rev1:          set Log2HtmlTextColor "#FF0000"
#Rev1:        }
#Rev1:        "Alert *WARNING*" -
#Rev1:        "DONE *MANUALCHECK*" {
#Rev1:          set Log2HtmlTextColor "#FF8000"
#Rev1:        }
#Rev1:        "DONE *PASSED*" {
#Rev1:          set Log2HtmlTextColor "#00A000"
#Rev1:        }
#Rev1:        "*%%:*" {
#Rev1:          # Keeps current Log2HtmlTextColor
#Rev1:        }
#Rev1:        default {
#Rev1:          set Log2HtmlTextColor ""
#Rev1:        }
#Rev1:      }
#Rev1:
#Rev1:      if {$Log2HtmlTextColor ne ""} {
#Rev1:        puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
#Rev1:      } else {
#Rev1:        puts $HtmlFileHandle $LineOfLogFile
#Rev1:      }
#Rev1:    }
#Rev1:  }

  proc LocalTranscript2Html {} {
    # Write the lines of a test case transcript to its HTML version.
    #
    # Colors errors, failures and failed test cases red, warnings orange and passed checks and test cases green; lines
    # starting with `%%:` keep the previous color. Errors are handled by [Transcript2Html].
    variable TranscriptFileHandle
    variable HtmlFileHandle
    variable Log2HtmlTextColor

    # Initialize default color if variable isn't set yet
    if {![info exists Log2HtmlTextColor]} {
      set Log2HtmlTextColor "#000000"
    }

    while {[gets $TranscriptFileHandle LineOfLogFile] >= 0} {

      switch -glob -- $LineOfLogFile {
        "*Alert *ERROR*" -
        "*Alert *FAILURE*" -
        "*DONE *FAILED*" -
        "*DONE *STOPLIMIT*" -
        "*DONE *TIMEOUT*" -
        "*DONE *NOCHECKS*" {
          set Log2HtmlTextColor "#FF0000"
        }
        "*Alert *WARNING*" -
        "*DONE *MANUALCHECK*" {
          set Log2HtmlTextColor "#FF8000"
        }
        "*Log *PASSED*" -
        "*DONE *PASSED*" {
          set Log2HtmlTextColor "#00A000"
        }
        "%%:*" {
          # Preserves current Log2HtmlTextColor
        }
        default {
          set Log2HtmlTextColor #000000
        }
      }

      puts $HtmlFileHandle "<span style=color:${Log2HtmlTextColor}>$LineOfLogFile</span>"
    }
  }

namespace export Log2Osvvm Transcript2Html

# end namespace ::osvvm
}

