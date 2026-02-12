#  File Name:         VendorScripts_GenerateVhdlLsToml.tcl
#  Purpose:           Script for adding language support in VS Code via VHDL LS
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email: jim@synthworks.com
#  Contributor(s):
#     Jim Lewis       email: jim@synthworks.com
#
#  Description:
#     Tcl procedures for autonomous integration of new VHDL libraries
#     in VS Code using the VHDL LS extension, following OSVVM methodology.
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
#    02/2026   2026.01    Script created.
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2018 - 2026 by SynthWorks Design Inc.
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
  # -------------------------------------------------------------------------
  # Namespace Variables
  # -------------------------------------------------------------------------
  variable firstTimeTomlOpened 0
  variable tomlFilePath [file join [pwd] ".vhdl_ls.toml"]

  # -------------------------------------------------------------------------
  # Helper Procedure: Remove Last Bracket in .toml file
  # -------------------------------------------------------------------------
  proc toml_rmLastBracket {filePath} {
    if {![file exists $filePath]} {
      return 0
    }

    set file [open $filePath r]
    set lines [split [read $file] "\n"]
    close $file

    # Remove last two lines (closing bracket)
    set lines [lrange $lines 0 end-2]
    set file [open $filePath w]
    puts $file [join $lines "\n"]

    close $file
  }
  # -------------------------------------------------------------------------
  # Helper Procedure: Check if current library is same as last library in .toml
  # -------------------------------------------------------------------------
  proc toml_isCurrentLibrary {libraryName} {
    variable tomlFilePath

    if {![file exists $tomlFilePath]} {
      return 0
    }

    set currentLibrary ""
    set file [open $tomlFilePath r]

    while {[gets $file line] >= 0} {
      if {[regexp {\[libraries\.([a-zA-Z0-9_]+)\]} $line -> lib]} {
        set currentLibrary $lib
      }
    }

    close $file

    return [expr {[string compare $currentLibrary $libraryName] == 0}]
  }
  # -------------------------------------------------------------------------
  # Main Procedure: Generate VHDL LS .toml entry for a library
  # -------------------------------------------------------------------------
  proc vendor_analyze_vhdl {LibraryName FileName args} {
    variable firstTimeTomlOpened
    variable tomlFilePath

    set normalizedFile [file normalize $FileName]
    set formattedFilePath [format "\t'%s'," $normalizedFile]

    if {$firstTimeTomlOpened == 0} {
      # First time creating the file
      set file [open $tomlFilePath w]

      puts $file "\[libraries.$LibraryName\]"
      puts $file "files = \["
      puts $file $formattedFilePath
      puts $file "\]"

      close $file

      set firstTimeTomlOpened 1
    } else {
      set isSameLibrary [toml_isCurrentLibrary $LibraryName]

      # Remove closing bracket to append new files
      toml_rmLastBracket $tomlFilePath
      set file [open $tomlFilePath a]

      if {!$isSameLibrary} {
        # Start new library section
        puts $file "\]"
        puts $file "\[libraries.$LibraryName\]"
        puts $file "files = \["
      }

      # Add file entry
      puts $file $formattedFilePath
      puts $file "\]"
      close $file
    }
  }
  # -------------------------------------------------------------------------
  # Placeholder for Verilog (Not needed yet)
  # -------------------------------------------------------------------------
  proc vendor_analyze_verilog {libraryName fileName args} {
    # No implementation required
  }
# end namespace ::osvvm
}
# =============================================================================
