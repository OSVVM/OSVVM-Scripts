#  File Name:         OsvvmScriptsFileCreate.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis           email:  jim@synthworks.com
#     Markus Ferringer    Patterns for error handling and callbacks, ...
#
#  Description
#    Tcl procedures to Autogenerate Files
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
#     1/2025   2025.01    Initial
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2025 by SynthWorks Design Inc.
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

package require fileutil

namespace eval ::osvvm {

# -------------------------------------------------
# FindOsvvmSettingsDirectory
#
proc FindOsvvmSettingsDirectory {{OsvvmSubdirectory "osvvm"}} {
  # Find the OSVVM settings directory and create it if it doesn't exist.
  #  OsvvmSubdirectory - Directory below `OsvvmLibraries` used if no other settings directory is found.
  #
  # The settings directory is the first of:
  #
  # 1. the variable `OsvvmSettingsDirectory`, if it isn't empty,
  # 1. the environment variable `OSVVM_SETTINGS_DIR`,
  # 1. `OsvvmSettings` next to `OsvvmLibraries`, if that directory exists,
  # 1. $OsvvmSubdirectory in `OsvvmLibraries`.
  #
  # A relative path is relative to `OsvvmLibraries` (`OsvvmHomeDirectory`). The deprecated
  # `SettingsAreRelativeToSimulationDirectory` makes it relative to the simulation directory instead and prints a
  # warning. `OsvvmSettingsSubdirectory` is appended to the result.
  #
  # StartUpShared.tcl calls it to set `OsvvmUserSettingsDirectory`, with $OsvvmSubdirectory `Scripts`.
  #
  # Returns the normalized path of the settings directory.
  #
  # See also: [CreateOsvvmScriptSettingsPkg] [FindSettingsPkgBody]

  # When StartUpShared.tcl calls this to determine the value of ::osvvm::OsvvmUserSettingsDirectory,
  # OsvvmSettingsLocal.tcl has not been run yet, as a result,
  #   * OsvvmSettingsSubdirectory will have its default value of "" and
  #   * SettingsAreRelativeToSimulationDirectory will have its default value of false.
  # For OsvvmSettingsSubdirectory, this is ok as it is only needed to differentiate the VHDL code and not the settings.
  # SettingsAreRelativeToSimulationDirectory this is not ok and it usage has been deprecated.
  #    This was used to differentiate VHDL sources for different simulators - use OsvvmSettingsSubdirectory instead
  #

  set SettingsRootDirectory ${::osvvm::OsvvmHomeDirectory}
  if {$::osvvm::SettingsAreRelativeToSimulationDirectory} {
    puts "WARNING:   SettingsAreRelativeToSimulationDirectory is deprecated.  Usage will generate an error in the future"
    set SettingsRootDirectory [file normalize ${::osvvm::CurrentSimulationDirectory}]
  }

  if {$::osvvm::OsvvmSettingsDirectory ne ""} {
    set SettingsDirectory $::osvvm::OsvvmSettingsDirectory
  } elseif {[info exists ::env(OSVVM_SETTINGS_DIR)]} {
    # Note that OSVVM_SETTINGS_DIR may be either an absolute or relative path
    # For relative paths, use OsvvmHomeDirectory (location of OsvvmLibraries) as the base
    set SettingsDirectory $::env(OSVVM_SETTINGS_DIR)
  } elseif {[file isdirectory ${SettingsRootDirectory}/../OsvvmSettings]} {
    set SettingsDirectory ../OsvvmSettings
  } else {
    puts "Note: Putting setting in directory OsvvmLibraries/${OsvvmSubdirectory}"
    set SettingsDirectory ${OsvvmSubdirectory}
  }

  set SettingsDirectoryFullPath [file normalize [file join ${SettingsRootDirectory} ${SettingsDirectory} ${::osvvm::OsvvmSettingsSubdirectory}]]

  CreateDirectory $SettingsDirectoryFullPath
#  set RelativeSettingsDirectory [::fileutil::relative [pwd] $SettingsDirectoryFullPath]
#  return $RelativeSettingsDirectory
  # Needs to be a normalized path
  return $SettingsDirectoryFullPath
}

# -------------------------------------------------
#  CreateOsvvmScriptSettingsPkg
#
proc CreateOsvvmScriptSettingsPkg {SettingsDirectory} {
  # Write the package body `OsvvmScriptSettingsPkg` with the script settings.
  #  SettingsDirectory - Directory to write `OsvvmScriptSettingsPkg_generated.vhd` to.
  #
  # The package body defines the deferred constants of `OsvvmScriptSettingsPkg` from the script variables: the
  # OSVVM home, temporary output and output base directories, the build and transcript YAML files, the OSVVM
  # version, the settings version and the YAML versions of the alert, scoreboard, coverage and requirements
  # reports.
  #
  # The file is only replaced if its content changed, so it's analyzed again only after a change.
  #
  # Returns the path of `OsvvmScriptSettingsPkg_generated.vhd`, or an empty string if the file can't be written.
  #
  # See also: [FindOsvvmSettingsDirectory]
  set OsvvmScriptSettingsPkgFile  [file join ${SettingsDirectory} "OsvvmScriptSettingsPkg_generated.vhd"]
  set NewFileName                 [file join ${SettingsDirectory} "OsvvmScriptSettingsPkg_new.vhd"]

  set WriteCode [catch {set FileHandle  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} {
    puts "Not able to open OsvvmScriptSettingsPkg_generated.vhd. Using defaults instead"
    return ""
  }
  puts $FileHandle "-- This file is autogenerated by CreateOsvvmScriptSettingsPkg"
  puts $FileHandle "package body OsvvmScriptSettingsPkg is"
  puts $FileHandle "  constant OSVVM_HOME_DIRECTORY         : string := \"[file normalize ${::osvvm::OsvvmHomeDirectory}]\" ;"
  if {${::osvvm::OsvvmTempOutputDirectory} eq ""} {
    puts $FileHandle "  constant OSVVM_TEMP_OUTPUT_DIRECTORY   : string := \"\" ;"
  } else {
    puts $FileHandle "  constant OSVVM_TEMP_OUTPUT_DIRECTORY   : string := \"${::osvvm::OsvvmTempOutputDirectory}/\" ;"
  }
  if {${::osvvm::OutputBaseDirectory} eq ""} {
    puts $FileHandle "  constant OSVVM_BASE_DIRECTORY  : string := \"\" ;"
  } else {
    puts $FileHandle "  constant OSVVM_BASE_DIRECTORY  : string := \"${::osvvm::OutputBaseDirectory}/\" ;"
  }
  puts $FileHandle "  constant OSVVM_BUILD_YAML_FILE        : string := \"${::osvvm::OsvvmTempYamlFile}\" ;"
  puts $FileHandle "  constant OSVVM_TRANSCRIPT_YAML_FILE   : string := \"${::osvvm::TempTranscriptYamlFile}\" ;"
  puts $FileHandle "  constant OSVVM_REVISION               : string := \"${::osvvm::OsvvmVersion}\" ;"
  puts $FileHandle "  constant OSVVM_SETTINGS_REVISION      : string := \"${::osvvm::OsvvmVersionCompatibility}\" ; -- For Settings"
  puts $FileHandle "  constant ALERT_YAML_VERSION           : string := \"${::osvvm::OsvvmAlertYamlVersion}\" ;"
  puts $FileHandle "  constant SCOREBOARD_YAML_VERSION      : string := \"${::osvvm::OsvvmScoreboardYamlVersion}\" ;"
  puts $FileHandle "  constant COVERAGE_YAML_VERSION        : string := \"${::osvvm::OsvvmCoverageYamlVersion}\" ;"
  puts $FileHandle "  constant REQUIREMENTS_YAML_VERSION    : string := \"${::osvvm::OsvvmRequirementsYamlVersion}\" ;"
  puts $FileHandle "end package body OsvvmScriptSettingsPkg ;"
  close $FileHandle
  if {[FileDiff $OsvvmScriptSettingsPkgFile $NewFileName]} {
    file rename -force $NewFileName $OsvvmScriptSettingsPkgFile
  } else {
    file delete -force $NewFileName
  }
  return $OsvvmScriptSettingsPkgFile
}

# -------------------------------------------------
#  FindOsvvmScriptSettingsPkg
#
proc FindOsvvmScriptSettingsPkg { } {
  # Select the package body of `OsvvmScriptSettingsPkg` to analyze.
  #
  # Looks in the OSVVM settings directory ([FindOsvvmSettingsDirectory]) for the user's
  # `OsvvmScriptSettingsPkg_local.vhd`. Without it, it generates `OsvvmScriptSettingsPkg_generated.vhd` there
  # ([CreateOsvvmScriptSettingsPkg]). The OSVVM library's `osvvm.pro` analyzes the result.
  #
  # Returns the user's package body if it exists, else the generated one, else
  # `OsvvmScriptSettingsPkg_default.vhd`.

  set SettingsDirectory [FindOsvvmSettingsDirectory]

  if {[FileExists $SettingsDirectory/OsvvmScriptSettingsPkg_local.vhd]} {
    return $SettingsDirectory/OsvvmScriptSettingsPkg_local.vhd

  # If SettingsDirectory is in a subdirectory for a tool and/or vendor it may be appropriate to look above to find a local "default one"
  # elsif {[FileExists $SettingsDirectory/${::osvvm::ToolName}/OsvvmScriptSettingsPkg_local.vhd]} { return $SettingsDirectory/${::osvvm::ToolName}/OsvvmScriptSettingsPkg_local.vhd }

  } else {
    # Generate the file if possible
    set GeneratedPkg [CreateOsvvmScriptSettingsPkg $SettingsDirectory]
#    puts "GeneratedPkg = $GeneratedPkg"
    if {[FileExists $GeneratedPkg]} {
      return   $GeneratedPkg
    } else {
      return OsvvmScriptSettingsPkg_default.vhd
    }
  }
}

# -------------------------------------------------
#  CreatePathPkg
#
proc CreatePathPkg {BaseName {SettingsDirectory ""}} {
  # Write and analyze a package with the path of the current script.
  #  BaseName          - Name prefix of the package and its file.
  #  SettingsDirectory - Directory to write the file to. Empty: the OSVVM settings directory.
  #
  # Writes the package `<BaseName>SettingsPkg` to `<BaseName>PathPkg_generated.vhd`. Its constant
  # `TEST_PATH_DIR` is the current working directory relative to the simulation directory, `TEST_PATH_SET` is
  # `TRUE`. The file is only replaced if its content changed. Then the file is analyzed into the working library.
  #
  # If the file can't be written, it analyzes `<BaseName>SettingsPkg_default.vhd` instead.
  #
  # Returns the path of the generated file, or an empty string if it can't be written.
  if {$SettingsDirectory eq ""} {set SettingsDirectory $::osvvm::OsvvmUserSettingsDirectory}
  set TestSettingsPkgFile     [file join ${SettingsDirectory} "${BaseName}PathPkg_generated.vhd"]
  set NewFileName             [file join ${SettingsDirectory} "${BaseName}PathPkg_new.vhd"]
  set DefaultSettingsPkgFile  [file join ${SettingsDirectory} "${BaseName}PathPkg_default.vhd"]

  set WriteCode [catch {set FileHandle  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} {
    puts "Not able to open ${NewFileName}. Using defaults instead"
    analyze ${BaseName}SettingsPkg_default.vhd
    return ""
  }
  set LocalScriptDir  "[::fileutil::relative ${::osvvm::CurrentSimulationDirectory} [file normalize ${::osvvm::CurrentWorkingDirectory}]]"
  puts $FileHandle "-- This file is autogenerated by CreatePathPkg"
  puts $FileHandle "package ${BaseName}SettingsPkg is"
  puts $FileHandle "  constant TEST_PATH_DIR         : string := \"${LocalScriptDir}\" ;"
  puts $FileHandle "  constant TEST_PATH_SET         : boolean := TRUE ;"
  puts $FileHandle "end package ${BaseName}SettingsPkg ;"
  close $FileHandle
  if {[FileDiff $TestSettingsPkgFile $NewFileName]} {
    file rename -force $NewFileName $TestSettingsPkgFile
  } else {
    file delete -force $NewFileName
  }
  analyze $TestSettingsPkgFile
  return $TestSettingsPkgFile
}

# -------------------------------------------------
#  CreateTestCaseCommonPkg
#
proc CreateTestCaseCommonPkg { {PackageName "TestCaseCommonPkg"} {ValidatedResults "../ValidatedResults"} } {
  # Write a package with the paths and names of the current test suite.
  #  PackageName      - Name of the package and its file.
  #  ValidatedResults - Directory of validated results, relative to the test source directory.
  #
  # The package's constants:
  #
  # `PATH_TO_TEST_SRC` - Current working directory, the directory of the test sources.
  # `PATH_TO_VALIDATED_RESULTS` - $ValidatedResults below `PATH_TO_TEST_SRC`.
  # `CHECK_TRANSCRIPT` - `TRUE` if `PATH_TO_TEST_SRC` isn't empty.
  # `BUILD_NAME` - Name of the current build.
  # `TEST_SUITE_NAME` - Name of the current test suite.
  # `PATH_TO_RESULTS` - Results directory of the test suite in the build's output directory.
  #
  # With VHDL-2019 and a simulator supporting `FILE_PATH` (`Supports2019FilePath`), `PATH_TO_TEST_SRC` is
  # derived from `FILE_PATH` and the file is `<PackageName>.vhd` in the current working directory. Otherwise the
  # path is written as a string and the file is `deprecated/<PackageName>_c.vhd`. If `OutputBaseDirectory` isn't
  # empty, it's appended to the file name. The file is only replaced if its content changed. It isn't analyzed.
  #
  # Raises an error if no test suite is set ([TestSuite]).
  #
  # Returns the path of the package file.

#  set CurrentDir ""
  set CurrentDir [file normalize ${::osvvm::CurrentWorkingDirectory}]
  set NewFileName            [file join ${CurrentDir} "NewCreateTestCaseCommonPkg.vhd"]
  if {${::osvvm::OutputBaseDirectory} eq ""} {
    set FileBaseName ""
  } else {
    set FileBaseName  "_[RemoveFilePathChars ${::osvvm::OutputBaseDirectory}]"
  }
  if {$::osvvm::Supports2019FilePath && $::osvvm::VhdlVersion >= 2019} {
    set TestCaseCommonPkgFile  [file join ${CurrentDir} "${PackageName}${FileBaseName}.vhd"]
  } else {
    CreateDirectory [file join ${CurrentDir} deprecated]
    set TestCaseCommonPkgFile  [file join ${CurrentDir} "deprecated" "${PackageName}${FileBaseName}_c.vhd"]
  }

  if {![info exists ::osvvm::TestSuiteName]} {
    error "Call TestSuite before calling CreateTestCaseCommonPkg"
    return
  }

  set WriteCode [catch {set FileHandle  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} {
    puts "ScriptError:  Not able to create ${TestCaseCommonPkgFile}"
  } else {
    puts $FileHandle "-- This file is autogenerated by CreateTestCaseCommonPkg"
    puts $FileHandle "library osvvm ;"
    puts $FileHandle "context osvvm.OsvvmContext ;"
    puts $FileHandle "package ${PackageName} is"
    if {$::osvvm::Supports2019FilePath && $::osvvm::VhdlVersion >= 2019} {
      puts $FileHandle "  constant PATH_TO_TEST_SRC            : string  := RemoveEndingSeparator(ChangeSeparator(FILE_PATH))  & \"/\";  -- only valid with VHDL-2019"
    } else {
      puts $FileHandle "  constant PATH_TO_TEST_SRC            : string := \"[file normalize [file join $::osvvm::CurrentWorkingDirectory]]/\" ;"
    }
    puts $FileHandle "  constant PATH_TO_VALIDATED_RESULTS   : string  := PATH_TO_TEST_SRC & \"${ValidatedResults}/\" ;"
    puts $FileHandle "  constant CHECK_TRANSCRIPT            : boolean := PATH_TO_TEST_SRC'length > 0 ;  -- TRUE if all went well"
    puts $FileHandle ""
    puts $FileHandle "  -- PATH_TO_RESULTS is for test case generated output other than TranscriptOpen.  If used you must create it"
    puts $FileHandle "  constant BUILD_NAME                  : string  := \"${::osvvm::BuildName}\" ;"
    puts $FileHandle "  constant TEST_SUITE_NAME             : string  := \"${::osvvm::TestSuiteName}\" ;"
    puts $FileHandle "  constant PATH_TO_RESULTS             : string := OSVVM_BASE_DIRECTORY & BUILD_NAME & \"/results/\" & TEST_SUITE_NAME & \"/\" ;"
    puts $FileHandle ""
    puts $FileHandle "  -- Deprecated.  Provided for backward compatibility"
    puts $FileHandle "  constant RESULTS_DIR             : string := PATH_TO_RESULTS ;"
    puts $FileHandle "  constant VALIDATED_RESULTS_DIR   : string := PATH_TO_VALIDATED_RESULTS ;"
    puts $FileHandle "end package ${PackageName} ;"
    close $FileHandle

    if {[FileDiff $TestCaseCommonPkgFile $NewFileName]} {
      puts "Creating $TestCaseCommonPkgFile"
      file rename -force $NewFileName $TestCaseCommonPkgFile
    } else {
      puts "Files $NewFileName $TestCaseCommonPkgFile match.  No updates"
      file delete -force $NewFileName
    }
  }
  return $TestCaseCommonPkgFile
}

# -------------------------------------------------
#  CreateAndAnalyzeBuildSettingsPkg
#
proc CreateBuildSettingsPkg {BaseName {SettingsDirectory ""}} {
  # Write and analyze a package with the settings of the current build.
  #  BaseName          - Name prefix of the package and its file.
  #  SettingsDirectory - Directory to write the file to. Empty: the OSVVM settings directory.
  #
  # Writes the package `<BaseName>SettingsPkg` to `<BaseName>SettingsPkg_generated.vhd`. Its constants are
  # `LOCAL_SCRIPT_DIR` (the current working directory relative to the simulation directory), `TEST_SUITE_NAME`,
  # `RESULTS_DIR` and `MIRROR_ENABLE` (`TRUE` in debug mode). The file is only replaced if its content changed.
  # Then the file is analyzed into the working library.
  #
  # If the file can't be written, it analyzes `<BaseName>SettingsPkg_default.vhd` instead.
  #
  # Returns the path of the generated file, or an empty string if it can't be written.
  if {$SettingsDirectory eq ""} {set SettingsDirectory $::osvvm::OsvvmUserSettingsDirectory}
  set TestSettingsPkgFile     [file join ${SettingsDirectory} "${BaseName}SettingsPkg_generated.vhd"]
  set NewFileName             [file join ${SettingsDirectory} "${BaseName}SettingsPkg_new.vhd"]
  set DefaultSettingsPkgFile  [file join ${SettingsDirectory} "${BaseName}SettingsPkg_default.vhd"]

  set WriteCode [catch {set FileHandle  [open $NewFileName w]} WriteErrMsg]
  if {$WriteCode} {
    puts "Not able to open ${NewFileName}. Using defaults instead"
    analyze ${BaseName}SettingsPkg_default.vhd
    return ""
  }
  set LocalScriptDir  "[::fileutil::relative ${::osvvm::CurrentSimulationDirectory} [file normalize ${::osvvm::CurrentWorkingDirectory}]]"
  puts $FileHandle "-- This file is autogenerated by CreateBuildSettingsPkg"
  puts $FileHandle "package ${BaseName}SettingsPkg is"
  puts $FileHandle "  constant LOCAL_SCRIPT_DIR         : string := \"${LocalScriptDir}\" ;"
  puts $FileHandle "  constant TEST_SUITE_NAME          : string := \"${::osvvm::TestSuiteName}\" ;"
  # Should be in top level OsvvmSettings
  puts $FileHandle "  constant RESULTS_DIR              : string := \"${::osvvm::ResultsDirectory}\" ;"
  if {$::osvvm::Debug} {
    puts $FileHandle "  constant MIRROR_ENABLE            : boolean := TRUE ;"
  } else {
    puts $FileHandle "  constant MIRROR_ENABLE            : boolean := FALSE ;"
  }
  puts $FileHandle "end package ${BaseName}SettingsPkg ;"
  close $FileHandle
  if {[FileDiff $TestSettingsPkgFile $NewFileName]} {
    file rename -force $NewFileName $TestSettingsPkgFile
  } else {
    file delete -force $NewFileName
  }
  analyze $TestSettingsPkgFile
  return $TestSettingsPkgFile
}

# -------------------------------------------------
# AutoGenerateFile
#    Extract from FileName everything up to and including the pattern in the string
#    Write Extracted contents to NewFileName
#    Example call: set ErrorCode [catch {AutoGenerateFile $FileName $NewFileName "--!! Autogenerated:"} errmsg]
proc AutoGenerateFile {FileName NewFileName AutoGenerateMarker} {
  # Copy the beginning of a file up to and including the first line matching a marker.
  #  FileName           - File to read.
  #  NewFileName        - File to write.
  #  AutoGenerateMarker - Regular expression marking the last line to copy.
  #
  # Copies all lines if no line matches. Does nothing if either file can't be opened.
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


# -------------------------------------------------
#  FileDiff
#
proc FileDiff {File1 File2} {
  # Compare two text files line by line.
  #  File1 - First file.
  #  File2 - Second file.
  #
  # Returns `true` if the files differ or one of them can't be read, else `false`.
  set ReadFile1Code [catch {set FileHandle1 [open $File1 r]} ReadErrMsg]
  if {$ReadFile1Code} {return "true"}
  set LinesOfFile1   [split [read $FileHandle1] \n]
  close $FileHandle1
  set LengthOfFile1  [llength $LinesOfFile1]

  set ReadFile2Code [catch {set FileHandle2 [open $File2 r]} ReadErrMsg]
  if {$ReadFile2Code} {return "true"}
  set LinesOfFile2   [split [read $FileHandle2] \n]
  close $FileHandle2
  set LengthOfFile2  [llength $LinesOfFile2]

  if {$LengthOfFile1 != $LengthOfFile2} {return "true"}

  for {set i 0} {$i < $LengthOfFile1} {incr i} {
    if {[lindex $LinesOfFile1 $i] ne [lindex $LinesOfFile2 $i]} {return "true"}
  }
  return "false"
}

# -------------------------------------------------
#  ReadFrom - Open File and read it into the stream
#
proc ReadFrom {filename} {
  # Read a file.
  #  filename - File to read.
  #
  # Returns the content of the file.
  set f [open $filename]; return [read $f][close $f]
}

# -------------------------------------------------
#  PrintTo - Direct a stream of information into a file
#
proc PrintTo {filename str} {
  # Write a string to a file.
  #  filename - File to write. An existing file is overwritten.
  #  str      - String to write, followed by a newline.
  set f [open $filename w]; puts $f $str; close $f
}

# -------------------------------------------------
#  MakeVti - Replace FileName with FileNameVti
#
proc MakeVti {FileName FilePrefix} {
  # Create the virtual transaction interface variant of an architecture.
  #  FileName   - Base name of the architecture file `<FileName>_a.vhd`.
  #  FilePrefix - Directory of the architecture file.
  #
  # Reads `<FileName>_a.vhd`, replaces every occurrence of $FileName by `<FileName>Vti` and writes the result to
  # `Vti/<FileName>Vti_a.vhd` in $FilePrefix.
	PrintTo [file join $FilePrefix Vti ${FileName}Vti_a.vhd] [regsub -all ${FileName} [ReadFrom [file join $FilePrefix ${FileName}_a.vhd]] ${FileName}Vti]
}

# -------------------------------------------------
#  Make2008 - For VHDL-2008 version remove the comment "--%%UncommentFor2008 " from the file
#
proc Make2008 {FileName FilePrefix} {
  # Create the VHDL-2008 variant of an architecture.
  #  FileName   - Base name of the architecture file `<FileName>_a.vhd`.
  #  FilePrefix - Directory of the architecture file.
  #
  # Reads `<FileName>_a.vhd`, removes every `--%%UncommentFor2008` comment marker (followed by a space), which
  # uncomments the lines marked for VHDL-2008, and writes the result to `deprecated/<FileName>_a.vhd` in
  # $FilePrefix.
	PrintTo [file join $FilePrefix deprecated ${FileName}_a.vhd] [regsub -all -- "--%%UncommentFor2008 " [ReadFrom [file join $FilePrefix ${FileName}_a.vhd]] ""]
}

# -------------------------------------------------
#  MakeArch - Create Vti, 2008 and Vti/2008 architectures
#
proc MakeArch {FileName} {
  # Create the virtual transaction interface and VHDL-2008 variants of an architecture.
  #  FileName - Base name of the architecture file `<FileName>_a.vhd` in the current working directory.
  #
  # Calls `MakeVti` and `Make2008` for the architecture, and `Make2008` for its `Vti` variant.
  variable CurrentWorkingDirectory
  MakeVti  $FileName $CurrentWorkingDirectory
  Make2008 $FileName $CurrentWorkingDirectory
  Make2008 ${FileName}Vti [file join $CurrentWorkingDirectory Vti]
}

# -------------------------------------------------
#  GetNewName - local
#  Should be an OSVVM utility as other things do this too
#
proc GetNewName {FileName} {
  # Return a file name with the suffix `_new` before its extension.
  #  FileName - File name, optionally with directory.
  #
  # Returns the file name: `File_new.ext` for `File.ext`.
  set FileExtension [file extension $FileName]
  set FileNameRoot  [file rootname  $FileName]
  return ${FileNameRoot}_new${FileExtension}
}

# -------------------------------------------------
#  CopyFileIfDiffOtherwiseDelete - local
#  Should be an OSVVM utility as other things do this too
#
proc CopyFileIfDiffOtherwiseDelete {NewFileName FileName} {
  # Replace a file with a new one if their contents differ, otherwise delete the new one.
  #  NewFileName - New file.
  #  FileName    - File to replace. It's created if it doesn't exist.
  if {![file exists $FileName] || [FileDiff ${NewFileName} ${FileName}]} {
    file rename -force ${NewFileName} ${FileName}
  } else {
    file delete -force ${NewFileName}
  }
}

# -------------------------------------------------
# MakePkgHeader
#
proc MakePkgHeader {PkgBodyFile PkgHeaderFile} {
  # Create a package declaration from a package body of deferred constants.
  #  PkgBodyFile   - Package body to read, relative to the current working directory, with extension.
  #  PkgHeaderFile - Package declaration to create, relative to the current working directory.
  #
  # Replaces `package body` by `package` and removes each constant's value, so a constant
  #
  #     constant ABC : type := SomeValue ;
  #
  # becomes the declaration
  #
  #     constant ABC : type ;
  #
  # The file is only replaced if its content changed.
  #
  # See also: [MakeSettingsPkg]
  set PkgHeaderFilePath    [file join ${::osvvm::CurrentWorkingDirectory} ${PkgHeaderFile}]
  set NewPkgHeaderFilePath [GetNewName $PkgHeaderFilePath]
  set PkgBodyFilePath      [file join ${::osvvm::CurrentWorkingDirectory} ${PkgBodyFile}]
  #  Write to this file from a stream (sed):  match these patterns                        Read this source file         replace pattern with this
	PrintTo ${NewPkgHeaderFilePath} [regsub -all {:=\s*[^;]+;} [regsub -all {package body} [ReadFrom ${PkgBodyFilePath}] "package"] ";"]
  CopyFileIfDiffOtherwiseDelete $NewPkgHeaderFilePath $PkgHeaderFilePath
}

# -------------------------------------------------
# MakePkgBodyTemplate
#
proc MakePkgBodyTemplate {PkgBodyFile TemplatePkgBodyFile} {
  # Create a package body template from a package body of deferred constants.
  #  PkgBodyFile         - Package body to read, relative to the current working directory, with extension.
  #  TemplatePkgBodyFile - Template to create, relative to the current working directory.
  #
  # Replaces each constant's value by a reference to the Tcl variable named like the constant, so
  # [MakePkgBody] can substitute the values. The file is only replaced if its content changed.
  #
  # See also: [MakeSettingsPkg]
  set PkgBodyFilePath            [file join ${::osvvm::CurrentWorkingDirectory} ${PkgBodyFile}]
  set TemplatePkgBodyFilePath    [file join ${::osvvm::CurrentWorkingDirectory} ${TemplatePkgBodyFile}]
  set NewTemplatePkgBodyFilePath [GetNewName $TemplatePkgBodyFilePath]
  #   Write to this file from a stream (sed):  pattern to match                                           Read this source file         replace pattern with this
#	PrintTo ${NewTemplatePkgBodyFilePath} [regsub -all -nocase {(constant\s+(\w+)\s*:\s*[^:=]+):=\s*[^;]+;} [ReadFrom ${PkgBodyFilePath}] {\1:= ${\2} ;}]
	PrintTo ${NewTemplatePkgBodyFilePath} [regsub -all -linestop -nocase {(constant\s+(\w+)\s*:.*?):=\s*[^;]+;} [ReadFrom ${PkgBodyFilePath}] {\1:= ${\2} ;}]
  CopyFileIfDiffOtherwiseDelete $NewTemplatePkgBodyFilePath $TemplatePkgBodyFilePath
}

# -------------------------------------------------
# MakePkgSettings
#
proc MakePkgSettings {PkgBodyFile SettingsFile} {
  # Create a package settings file from a package body of deferred constants.
  #  PkgBodyFile  - Package body to read, relative to the current working directory, with extension.
  #  SettingsFile - Package settings file to create, relative to the current working directory, with extension.
  #
  # For each line declaring a constant, the package settings file gets a line with the constant's name, a colon and
  # its value. A constant
  #
  #     constant ABC : type := SomeValue ;
  #
  # becomes
  #
  #     ABC: SomeValue
  #
  # Comment lines are skipped. The file is only replaced if its content changed.
  #
  # See also: [MakeSettingsPkg] [MakePkgBody]
  set SettingsFilePath    [file join ${::osvvm::CurrentWorkingDirectory} ${SettingsFile}]
  set NewSettingsFilePath [GetNewName $SettingsFilePath]
  set PkgBodyFilePath     [file join ${::osvvm::CurrentWorkingDirectory} ${PkgBodyFile}]
  set OutputFile [open ${NewSettingsFilePath} w]
  foreach item [ReadListFromFile ${PkgBodyFilePath}] {
    # Only for lines that contain the word constant
    if {![regexp {^\s*--} $item] && [regexp -nocase {constant} $item] } {
      #                       Match this pattern                                     in item  create this in result
      regsub -all -nocase -- {^\s*constant\s+(\w+)\s*:\s*[\w\.\(\)]+\s*:=\s*(.*?);.*$} $item {\1: \2} result
      puts $OutputFile $result
    }
  }
  close $OutputFile
  CopyFileIfDiffOtherwiseDelete $NewSettingsFilePath $SettingsFilePath
}

# # -------------------------------------------------
# # ReadYamlSettings - local - Failed attempt at reading settings
# #
# proc ReadYamlSettings {YamlFile} {
#   # reading as YAML fails since YAML removes "" from string values - these are needed
#   # left here as a reminder to use ReadPkgSettings instead
#   set SettingsDict [::yaml::yaml2dict -file [file join ${::osvvm::CurrentWorkingDirectory} ${YamlFile}]]
#   dict for {VariableName VariableValue} $SettingsDict {
#     uplevel 1 [list set $VariableName $VariableValue]
#   }
# }

# -------------------------------------------------
# ReadPkgSettings - local
#
proc ReadPkgSettings {SettingsFile} {
  # Read a package settings file and set its variables in the calling procedure.
  #  SettingsFile - Package settings file to read, relative to the current working directory.
  #
  # Each line holds a variable name, a colon and the value. The values keep their quotes, which a YAML reader
  # would remove.
  foreach line [ReadListFromFile [file join ${::osvvm::CurrentWorkingDirectory} ${SettingsFile}]] {
    if {[regexp {^\s*([^:]+)\s*:\s*(.*)\s*$} $line -> VariableName VariableValue]} {
      uplevel 1 [list set $VariableName $VariableValue]
    }
  }
}

# -------------------------------------------------
# MakePkgBody
#
proc MakePkgBody {OsvvmSettingsFile UserSettingsFile TemplatePkgBodyFile PkgBodyFile} {
  # Create a package body from a template and package settings files.
  #  OsvvmSettingsFile   - OSVVM package settings file with the default values of all template variables.
  #  UserSettingsFile    - User package settings file. Its values override the defaults.
  #  TemplatePkgBodyFile - Package body template, created by [MakePkgBodyTemplate].
  #  PkgBodyFile         - Package body to create.
  #
  # Reads both package settings files (format of [MakePkgSettings]) and substitutes their values for the Tcl
  # variables in the template. File names are relative to the current working directory. The file is only replaced if
  # its content changed.
  #
  # See also: [FindSettingsPkgBody]

  # Read OSVVM and then User settings (to ensure user settings override OSVVM settings)
  ReadPkgSettings ${OsvvmSettingsFile}   ; # For OSVVM packages, in a subdirectory of OsvvmLibraries
  ReadPkgSettings ${UserSettingsFile}    ; # In a settings directory dedicated to a single project

  # Derive template file name
  set TemplatePkgBodyFilePath [file join ${::osvvm::CurrentWorkingDirectory} ${TemplatePkgBodyFile}]  ; # For OSVVM packages, in a subdirectory of OsvvmLibraries
  set PkgBodyFilePath         [file join ${::osvvm::CurrentWorkingDirectory} ${PkgBodyFile}]          ; # In the settings directory dedicated to a single project
  set NewPkgBodyFilePath      [GetNewName $PkgBodyFilePath]                                           ; # In the settings directory dedicated to a single project

  # Write to NewPkgBodyFilePath and substitute Tcl variables found in TemplatePkgBodyFilePath with their value
	PrintTo ${NewPkgBodyFilePath} [subst [ReadFrom ${TemplatePkgBodyFilePath}]]
  CopyFileIfDiffOtherwiseDelete $NewPkgBodyFilePath $PkgBodyFilePath
}

# -------------------------------------------------
# MakeSettingsPkg
#
proc MakeSettingsPkg {SettingsPkgBaseName} {
  # Create the package declaration, template and default settings of a settings package.
  #  SettingsPkgBaseName - Base name of the package. Its body is `<SettingsPkgBaseName>_default.vhd`.
  #
  # From the package body of deferred constants in the current working directory, it creates:
  #
  # - `<SettingsPkgBaseName>.vhd`, the package declaration ([MakePkgHeader]),
  # - `<SettingsPkgBaseName>_template.vhd`, the package body template ([MakePkgBodyTemplate]),
  # - `<SettingsPkgBaseName>_default.vset`, the default settings ([MakePkgSettings]).
  #
  # See also: [FindSettingsPkgBody]
  MakePkgHeader         ${SettingsPkgBaseName}_default.vhd   ${SettingsPkgBaseName}.vhd
  MakePkgBodyTemplate   ${SettingsPkgBaseName}_default.vhd   ${SettingsPkgBaseName}_template.vhd
  MakePkgSettings       ${SettingsPkgBaseName}_default.vhd   ${SettingsPkgBaseName}_default.vset
}

# -------------------------------------------------
# FindSettingsPkgBody
#
proc FindSettingsPkgBody {SettingsPkgBaseName} {
  # Select the package body of a settings package to analyze.
  #  SettingsPkgBaseName - Base name of the package.
  #
  # Looks in the OSVVM settings directory ([FindOsvvmSettingsDirectory]):
  #
  # 1. With `<SettingsPkgBaseName>_local.vset`, it creates `<SettingsPkgBaseName>_generated.vhd` there from the
  # template and the default and local settings ([MakePkgBody]).
  # 1. Else it uses `<SettingsPkgBaseName>_local.vhd`, if it exists.
  # 1. Else it uses `<SettingsPkgBaseName>_default.vhd` of the current working directory.
  #
  # Returns the path of the package body to analyze.
  #
  # See also: [MakeSettingsPkg]
  set SettingsDirectory [FindOsvvmSettingsDirectory]

  if {[FileExists ${SettingsDirectory}/${SettingsPkgBaseName}_local.vset]} {
    MakePkgBody ${SettingsPkgBaseName}_default.vset \
                ${SettingsDirectory}/${SettingsPkgBaseName}_local.vset \
                ${SettingsPkgBaseName}_template.vhd \
                ${SettingsDirectory}/${SettingsPkgBaseName}_generated.vhd
    return "${SettingsDirectory}/${SettingsPkgBaseName}_generated.vhd"
  } elseif {[FileExists $SettingsDirectory/${SettingsPkgBaseName}_local.vhd]} {
    return "${SettingsDirectory}/${SettingsPkgBaseName}_local.vhd"
  } else {
    return "${SettingsPkgBaseName}_default.vhd"
  }
}

# Don't export the following due to conflicts with Tcl built-ins
# map

namespace export CreateOsvvmScriptSettingsPkg FindOsvvmSettingsDirectory CreateAndAnalyzeTestSettingsPkg
namespace export CreateTestCaseCommonPkg
namespace export MakePkgHeader MakePkgBodyTemplate MakePkgSettings MakePkgBody
namespace export MakeSettingsPkg FindSettingsPkgBody

# end namespace ::osvvm
}
