#  File Name:         StartUpShared.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    StartUp scripts that are shared by any simulator
#    Called by StartUp and StartVCS, StartXcelium, ...
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
#    05/2024   2024.05    Updated for renaming during refactoring
#    05/2022   2022.05    Refactored StartUp.tcl to remove items
#                         shared by all StartUp scripts
#    10/2021   2021.10    Loads OsvvmYamlSupport.tcl when YAML library available
#                         Loads LocalScriptDefaults.tcl if it is in the OsvvmScriptDirectory
#                            This is a optional user settings file.
#                         LocalScriptsDefaults.tcl is not provided by OSVVM so your local settings will not be overwritten.
#     2/2021   2021.02    Refactored.
#                         - Initial tool settings now in VendorScripts_*.tcl (was in ToolConfiguration.tcl)
#                         - Added: Default settings now in OsvvmScriptDefaults.tcl (was here)
#                         - Removed: ToolConfiguration.tcl (now in StartUp.tcl and VendorScripts_*.tcl)
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#     1/2020   2020.01    Updated Licenses to Apache
#     2/2019   Beta       Project descriptors in .pro which execute
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#                         as TCL scripts in conjunction with the library
#                         procedures
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

  # --------------------------------
  # Set OsvvmScriptDirectory if it is not already set
  # --------------------------------
  # Usage of SCRIPT_DIR is deprecated.
  if {![info exists OsvvmScriptDirectory]} {
    # if a calling script uses SCRIPT_DIR, this supports backward compatibility
    variable OsvvmScriptDirectory ${SCRIPT_DIR}
  } else {
    # if a user add on script uses SCRIPT_DIR, this supports backward compatibility
    variable SCRIPT_DIR ${OsvvmScriptDirectory}
  }
  variable OsvvmHomeDirectory   [file normalize ${OsvvmScriptDirectory}/..]

  # Documentation of the script files, rendered by Ruff! (doc/build.sh)
  variable _ruff_preamble {
    ### Script files

    OSVVM-Scripts is started by sourcing one start-up script in the Tcl console of the simulator, or in `tclsh` for
    simulators without a Tcl console. The start-up script selects a vendor script and sources `StartUpShared.tcl`,
    which loads the other files in the order of the groups below. All commands are defined in the namespace `::osvvm`
    and imported into the global namespace, so scripts call them without a namespace qualifier.

    #### Start-up scripts

    `StartUp.tcl` - Start-up script for Riviera-PRO, Active-HDL, VSimSA, ModelSim, Questa, Visualizer, Vivado and
    GHDL. It detects the tool from the running executable and selects its vendor script; GHDL is selected when no
    other tool is detected. The environment variable `OSVVM_TOOL` names the vendor script and skips the detection.
    `StartGHDL.tcl` - Start-up script for GHDL, run in `tclsh`.
    `StartNVC.tcl` - Start-up script for NVC, run in `tclsh`.
    `StartDSim.tcl` - Start-up script for DSim.
    `StartVCS.tcl` - Start-up script for Synopsys VCS, run in `tclsh`.
    `StartXcelium.tcl` - Start-up script for Cadence Xcelium, run in `tclsh`.
    `StartXSIM.tcl` - Start-up script for Xilinx XSIM, run in Vivado.
    `StartQuesta.tcl` - Start-up script for QuestaSim; selects `VendorScripts_Siemens.tcl`.
    `StartVisualizer.tcl` - Start-up script for Siemens Visualizer; selects `VendorScripts_Questa.tcl`.
    `StartActiveVSimSA.tcl` - Start-up script for VSimSA, the command line simulator of Active-HDL.
    `StartReports.tcl` - Start-up script without a simulator, to generate reports only; selects
    `VendorScripts_Reports.tcl`.
    `StartUpShared.tcl` - Shared part of all start-up scripts. Loads the core, the vendor script, the report generators,
    the settings and the callbacks, and prints the OSVVM and tool versions.

    #### Core

    `OsvvmScriptsCreateYamlReports.tcl` - Writes the YAML files of a build and of its test cases, which the report
    generators read.
    `OsvvmScriptsCore.tcl` - The tool independent commands: libraries, [analyze], [simulate], [build], [include],
    test suites and test cases, transcripts and code coverage.
    `OsvvmScriptsSetGetOptions.tcl` - The `Set*` and `Get*` commands of the options for analyze and simulate, for
    example [SetVHDLVersion] and [GetVHDLVersion].
    `OsvvmScriptsSimulateSupport.tcl` - Support procedures of [simulate]: create and run the scripts named after the
    library, the design unit or the test case, and the wave files, if they exist.
    `OsvvmScriptsFileCreate.tcl` - Creates files: finds the settings directory, writes the VHDL settings packages,
    for example `OsvvmScriptSettingsPkg`, and generates VHDL files from templates.
    `OsvvmScriptsTranslate.tcl` - Translates a build script into files for other tools: `vhdl_ls.toml`, an analyze
    order as CSV, YAML and JSON.
    `OsvvmScriptsIgnoreVhdlComments.tcl` - Defines the command `--`, so a VHDL comment in a script is ignored. Not
    loaded for Active-HDL and VSimSA.

    #### Vendor scripts

    `OsvvmSettingsVendorScriptsDefault.tcl` - Default values of the settings a vendor script may change, for example
    the VHDL-2019 features the tool supports. Loaded before the vendor script.

    A vendor script `VendorScripts_<Name>.tcl` adapts the core to one tool: it sets `ToolVendor`, `ToolName`,
    `ToolType` and `ToolNameVersion` and defines the `vendor_*` procedures the core calls. Exactly one is loaded; its
    name is the variable `ScriptBaseName` set by the start-up script.

    `VendorScripts_ActiveHDL.tcl` - Aldec Active-HDL.
    `VendorScripts_ASim.tcl` - Aldec Active-HDL run from a Tcl shell. Selected with `OSVVM_TOOL` only.
    `VendorScripts_VSimSA.tcl` - Aldec VSimSA, the command line simulator of Active-HDL.
    `VendorScripts_RivieraPro.tcl` - Aldec Riviera-PRO.
    `VendorScripts_Siemens.tcl` - Siemens ModelSim and QuestaSim.
    `VendorScripts_Questa.tcl` - Siemens Questa with the command `qsim`, and Siemens Visualizer. Derived from
    `VendorScripts_Siemens.tcl`.
    `VendorScripts_VSim.tcl` - Siemens ModelSim and QuestaSim, a variant of `VendorScripts_Siemens.tcl`. Selected with
    `OSVVM_TOOL` only.
    `VendorScripts_Visualizer.tcl` - Siemens Visualizer. Selected with `OSVVM_TOOL` only.
    `VendorScripts_GHDL.tcl` - GHDL.
    `VendorScripts_NVC.tcl` - NVC.
    `VendorScripts_DSim.tcl` - DSim.
    `VendorScripts_VCS.tcl` - Synopsys VCS.
    `VendorScripts_Xcelium.tcl` - Cadence Xcelium.
    `VendorScripts_Xsim.tcl` - Xilinx XSIM.
    `VendorScripts_Vivado.tcl` - Xilinx Vivado synthesis; analyze only.
    `VendorScripts_Sigasi.tcl` - Sigasi Visual HDL. Analyzes with the `vcom` of Sigasi and writes the simulate
    commands to a log file.
    `VendorScripts_Reports.tcl` - No tool: analyze and simulate do nothing, reports are generated from existing YAML
    files.
    `VendorScripts_CompileList.tcl` - No tool: writes the analyzed files to a list of files per library and to
    `OneList.files`. Selected with `OSVVM_TOOL` only.
    `VendorScripts_DryRunDict.tcl` - No tool: records the analyzed files and the simulated design units. Loaded by the
    commands of `OsvvmScriptsTranslate.tcl`.

    #### Report generators

    `StartUpYamlLoadReports.tcl` - Loads the report generators below, if the Tcl package `yaml` is available.
    `StartUpYamlMockReports.tcl` - Loaded instead, if the package `yaml` is missing. Its report commands print an
    error with instructions to install the package.
    `ReportBuildYaml2Dict.tcl` - Reads the YAML file of a build into a Tcl dictionary.
    `ReportBuildDict2Html.tcl` - Writes the HTML build summary report from that dictionary.
    `ReportBuildDict2Junit.tcl` - Writes the JUnit XML build summary report from that dictionary.
    `ReportIndex2Html.tcl` - Writes the HTML index of all builds.
    `ReportSimulate2Html.tcl` - Writes the HTML report of a test case: its alerts, functional coverage and scoreboards.
    `ReportAlert2Html.tcl` - Writes the alert section of a test case report.
    `ReportCov2Html.tcl` - Writes the functional coverage section of a test case report.
    `ReportScoreboard2Html.tcl` - Writes the scoreboard section of a test case report.
    `ReportSupport.tcl` - Helper procedures shared by the HTML report generators.
    `RequirementsMerge.tcl` - Merges the requirement results of test cases.
    `Requirements2HtmlCsv.tcl` - Writes the requirements report as HTML and as CSV.
    `RequirementsCsv2Yaml.tcl` - Converts a requirements specification from CSV into YAML.
    `Log2Osvvm.tcl` - Converts the transcript of a build into HTML and other outputs.

    #### Settings

    `OsvvmSettingsDefault.tcl` - Default values of all settings. Don't change this file.
    `OsvvmSettingsLocal.tcl` - Optional, the settings of the user or project; overrides the defaults. Searched in the
    settings directory: the environment variable `OSVVM_SETTINGS_DIR`, else the directory `OsvvmSettings` next to
    `OsvvmLibraries`, else the directory `Scripts`. The former name `LocalScriptDefaults.tcl` is deprecated.
    `OsvvmSettingsLocal_<ScriptBaseName>.tcl` - Optional, the settings of the user or project for one tool. The former
    name `LocalScriptDefaults_<ScriptBaseName>.tcl` is deprecated.
    `OsvvmSettingsLocal_example.tcl` - Example of a `OsvvmSettingsLocal.tcl` with all settings; copy it to start. Not
    loaded.
    `OsvvmSettingsRequired.tcl` - Required settings of OSVVM and settings derived from the settings above. Loaded
    last; don't change this file.

    #### Callbacks

    `CallbackDefaults.tcl` - Default callbacks: the procedures OSVVM calls on errors and around analyze, simulate and
    build. Don't change this file.
    `LocalCallbacks.tcl` - Optional, callbacks of the user or project; overrides the defaults. Searched in the settings
    directory.
    `LocalCallbacks_<ScriptBaseName>.tcl` - Optional, callbacks of the user or project for one tool.

    #### Others

    `tee.tcl` - The command `tee`, which copies the output of a channel into a file; copies `stdout` and `stderr` into
    the transcript. Defines the namespace `::tee`.
    `../CoSim/Scripts/MakeVproc.tcl` - Commands of OSVVM co-simulation; loaded if `OsvvmLibraries` contains `CoSim`.
  }
}

variable OsvvmLibraries $::osvvm::OsvvmHomeDirectory

# --------------------------------
# Load OSVVM Core API
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsCreateYamlReports.tcl   ;#  Helpers for creating YAML files
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsCore.tcl                ;#  OSVVM Core API
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsSetGetOptions.tcl       ;#  OSVVM Set and Get Options API
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsSimulateSupport.tcl     ;#  OSVVM Simulate Support Scripts - should this be called by OsvvmScriptsCore after proc simulate?
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsFileCreate.tcl          ;#  OSVVM API for file creation
source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsTranslate.tcl           ;#  OSVVM Create Project files for other tools


# --------------------------------
# Load Vendor Script Default settings
#   These are updated by VendorScripts_vvv.tcl
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsVendorScriptsDefault.tcl

# --------------------------------
# Vendor personalization of OSVVM API
# --------------------------------
namespace eval ::osvvm {
  source ${::osvvm::OsvvmScriptDirectory}/VendorScripts_${::osvvm::ScriptBaseName}.tcl
}

# --------------------------------
# Define a procedure for "--" so VHDL comments are ignored
# --------------------------------
if {($::osvvm::ToolName ne "ActiveHDL") && ($::osvvm::ToolName ne "VSimSA")} {
  source ${::osvvm::OsvvmScriptDirectory}/OsvvmScriptsIgnoreVhdlComments.tcl
}

# --------------------------------
# Scripts to convert OSVVM Yaml outputs to HTML and XML files
# --------------------------------
if {[catch {package require yaml}]} {
  source ${::osvvm::OsvvmScriptDirectory}/StartUpYamlMockReports.tcl
} else {
  source ${::osvvm::OsvvmScriptDirectory}/StartUpYamlLoadReports.tcl
}

# --------------------------------
# Convert tool generated log files to HTML, ...
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/Log2Osvvm.tcl

# --------------------------------
# CoSim API additions
# --------------------------------
if {[file exists ${::osvvm::OsvvmScriptDirectory}/../CoSim]} {
  source ${::osvvm::OsvvmScriptDirectory}/../CoSim/Scripts/MakeVproc.tcl
}


# Import any procedure exported by previous OSVVM scripts
namespace import ::osvvm::*

# --------------------------------
# Load OSVVM Default settings
# --------------------------------
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsDefault.tcl


# --------------------------------
# Load User settings
# --------------------------------
# Get Directory for User settings
variable ::osvvm::OsvvmUserSettingsDirectory [FindOsvvmSettingsDirectory "Scripts"]

# Settings Second:  OSVVM User/Project Customizations - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults.tcl]} {
  # Deprecated:  Uses old name - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults.tcl
}

# --------------------------------
# Load User Tool specific settings
# Settings Third   OSVVM User Simulator specific defaults - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsLocal_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated:  Uses old name - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalScriptDefaults_${::osvvm::ScriptBaseName}.tcl
}

# Settings Final   OSVVM Finalize Settings - builds names that are dependent on other names
source ${::osvvm::OsvvmScriptDirectory}/OsvvmSettingsRequired.tcl


# --------------------------------
# CallBacks & Error Handlers:  Callback*.tcl
# --------------------------------
# Callbacks First:  OSVVM Default CallBacks
source ${::osvvm::OsvvmScriptDirectory}/CallbackDefaults.tcl

# Callbacks Second:   OSVVM User/Project Customizations - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks.tcl
}


# Callback Third:      OSVVM User Simulator specific defaults - not required
if {[file exists ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl]} {
  # Found in OSVVM_SETTINGS_DIR
  source ${::osvvm::OsvvmUserSettingsDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl
} elseif {[file exists ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl]} {
  # Deprecated.  Found in Scripts Directory - backward compatible
  source ${::osvvm::OsvvmScriptDirectory}/LocalCallbacks_${::osvvm::ScriptBaseName}.tcl
}


# --------------------------------
# If the tee scripts load, mark them as available
# --------------------------------
if {[catch {source ${::osvvm::OsvvmScriptDirectory}/tee.tcl}]} {
   variable ::osvvm::GotTee false
} else {
   variable ::osvvm::GotTee true
}

puts "OSVVM Script Version:  $::osvvm::OsvvmVersion"
puts "Simulator Version:     $::osvvm::ToolNameVersion"


