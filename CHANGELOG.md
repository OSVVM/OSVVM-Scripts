# The OSVVM Verification Script Library Change Log

| **Revision**  |   **Release Summary**                                                                         | 
|---------------|-----------------------------------------------------------------------------------------------| 
| 2025.06       |  Move build results to build directory.  BuildName introduced to name it.                     |
|               |  Create Index.html in the sim directory                                                       |
|               |  Updated Siemens (vsim flow) and Questa (vopt + vsim flow) scripts to run in tclsh better.    |
|               |  Added CreateTestCaseCommonPkg.   Added RunAllTests.  Added .vh as a Verilog file.            |
|               |  Support for Questa's vsim -batch                                                             |
| 2025.04       |  Updated handling of generic names to remove / and : from paths in file names                 |
|               |  Updated OsvvmUserSettingsDirectory s.t. scripts and VHDL use same path                       |
|               |  Turned off VHDL-2019 settings for Siemens as 2025.1 release claims they don't support it     |
| 2025.02       |  Use $::env::(OSVVM_SETTINGS_DIR) to set the requirements directory.                          |
|               |  USE_SUM_OF_GOALS requirements uses Sum of Goals (if true) vs Maximum (if false and past default)        |
|               |  Updated requirements handling to handle Functional Coverage.                                 |
|               |  Added variable Supports2019FilePath (based on tool support).                                  |
|               |  Added GetTimeString                                                                          |
| 2024.11       |  Log2Osvvm - Updated how details summary print                                                |
|               |  OsvvmScriptsCore, VendorScripts_Visualizer, VS_Siemens - worked on Space in Path issue       |
|               |  VendorScripts_VsimSA.tcl - turned on VHDL-2019 for appropriate versions                      |
| 2024.09       |  Turned VHDL-2019 on if version is ...                                                        |
|               |  (NVC > 1.13.2), (RivieraPRO > 2021.04), (ActiveHDL > 12.0), (Questa > 2024.2)                |
| 2024.07       |  Yaml output updates. Junit report affirm counts and generics as properties.                  |
|               |  Handling Status NOCHECKS as FAIL (default) or pass) controlled by variagble FailOnNoChecks   |
|               |  Updated handling for coverage models with weight 0                                           |
|               |  Updated LocalInclude for better error handling and restoring state.  Fixed settings in SetLogSignals |
|               |  Control for ClockResetVersion.  Siemens Visualizer support.  Added SaveWaves for Questa      |
|               |  Added DoWaves support for Aldec                                                              |
| 2024.05       |  Updated Report formatting                                                      |
|               |  Refactored Report2Html/Report2Junit to ReportBuildYaml2Dict/ReportBuildDict2Html/ReportBuildDict2Junit    |
| 2024.03       |  OsvvmProjectScripts - OpenBuildHtml                                                      |
|               |  Fixed issue WRT simulator ending in error and not being able to move transcript files    |
|               |  Added variable OsvvmVersionCompatibility to control whether to use new or old OSVVM settings    |
| 2023.09       |  OsvvmProjectScripts - build/include - file search now happens early for better messages  |
|               |  Default library name now DefaultLib rather than default (a VHDL-2008 reserved word)  |
|               |  build/include now support $::ARGC, $::ARGV (a TCL array), as well as, $::argv (a TCL list), $::argv0, and $::argc |
| 2023.05       |  Updated comments in NVC script  |
| 2023.04       |  Updates to cosim  |
|               |  Scripts now create package body OsvvmScriptSettings_generated.vhd.  |
|               |  Added OsvvmScriptSettings_generated.vhd top .gitignore |
| 2023.01       |  Updated scripts to support CoSim.  |
|               |  Creates OsvvmScriptSettingsPkg.vhd                        |
| 2022.12       |  Updates StartUp.tcl to use environment variable OSVVM_TOOL to select default simulator/tool  |
|               |  Updated HTML Report generation: Report2Html, Simulate2Html, Log2Osvvm                        |
|               |  Updated yaml format for <BuildName>.yml                                                      |
|               |  HTML Report generation now only depends on OSVVM static information and can run separately   |
|               |  Updated Generic handling to include both simulate and RunTest                                |
|               |  Updated Xcelium and VCS scripts.                                                             |
| 2022.11       |  TestName deprecated TestCase (supported for backward compatibility)                          |
|               |  Scripts now find all scoreboard YAML reports                                                 |
| 2022.10       |  Added ChangeWorkingDirectory and JoinWorkingDirectory.                                       |
|               |  Fixed GHDL log files. Fixed GHDL Generic Handling.                                           |
|               |  Updated reporting to better flag errors in _log.html - Updated Log2Osvvm                     |
|               |  Initial NVC Support.                                                                         |
| 2022.09       |  Added RemoveLibrary, RemoveLibraryDirectory, OsvvmLibraryPath                                |
|               |  Updated each scoreboard report to be a single line in a table                                |
|               |  Added SetVhdlAnalyzeOptions, SetExtendedAnalyzeOptions, SetExtendedSimulateOptions           |
|               |  Added (for GHDL) SetSaveWaves, SetExtendedElaborateOptions, SetExtendedRunOptions            |
|               |  Added SetInteractiveMode, SetDebugMode, SetLogSignals                                        |
| 2022.08       |  Added handling for Analyze with Verilog Libraries.                                           |
|               |  Added SetSecondSimulationTopLevel, GetSecondSimulationTopLevel                               |
| 2022.06       |  Added Generic handling.                                                                      |
|               |  Support for printing Coverage PASSED/FAILED                                                  |
|               |  Fixed handling of spaces in library path.                                                    |
|               |  Print Text short Build Summary at test completion.                                           |
|               |  Updated HTML file generation.                                                                |
|               |  TestCase detailed report links back to build report.                                         |
|               |  Updated error handling - files now close which fixes file copying issues.                    |
| 2022.05       |  Refactored variables in OsvvmProjectScripts to OsvvmDefaultSettings                          |
|               |  Build, Analyze, Simulate now have error handling                                             |
|               |  Reports now record Analyze and Simulate Failures                                             |
|               |  Coverage report name now based on TestCaseName rather than LibraryUnit                       |
| 2022.03       |  Added link to test transcript files (TranscriptOpen)                                         |
|               |  Report links to Code Coverage and Transcripts now use relative paths                         |
| 2022.02       |  Added Transcripts in HTML, Scoreboard Reports, and Code Coverage Integration                 |
| 2022.01       |  Minor changes.  Lib dir lower case.  OptionalCommands for analyzing Verilog.                 |
|               |  Writing FC now in VHDL.  Added DirectoryExists                                               |
| 2021.12       |  Changed Paths to Relative Paths.  Added better library support.                              |
| 2021.11       |  Updated scripting to fine tune HTML and XML reporting.                                       |
| 2021.10       |  Added support to convert build YAML files to HTML and XML (JUnit)                            |
|               |     Added support to convert Alert and coverage YAML to HTML reports                          |
| 2021.09       |  Added support for Synopsys VCS and Cadence Xcelium.                                          |
|               |  Added support for creation of YAML files.                                                    |
| 2021.06       |  Updated VendorScripts_GHDL to better handle GHDL return values                               |
| 2021.05       |  Updates related to adding namespace for osvvm                                                |
|               |     Added VendorScripts_Vivado.tcl - thanks Rob Gaddi                                         |
| 2021.03       |  Minor work around for vendor tool issues                                                     |
| 2021.03       |  Minor work around for vendor tool issues                                                     |
| 2021.02       |  Refactored.                                                                                  |
|               |     - Tool now determined in StartUp.tcl. Simplifies ActiveHDL startup                        |
|               |     - Initial tool settings now in VendorScripts_*.tcl                                        |
|               |        - In ActiveHDL, set global OSVVM library to read/write                                 |
|               |     - Added: Default settings now in OsvvmScriptDefaults.tcl                                  |
|               |     - Removed: ToolConfiguration.tcl                                                          |
|               |  In VendorScripts_GHDL.tcl, fixed log file generation in GHDL                                 |
|               |  In OsvvmProjectScripts.tcl                                                                   |
|               |     - Updated initialization of libraries                                                     |
|               |     - Analyze allows ".vhdl" extensions as well as ".vhd"                                     |
|               |     - Include/Build signal error if nothing to run                                            |
|               |     - Added SetVHDLVersion / GetVHDLVersion to support 2019 work                              |
|               |     - Added SetSimulatorResolution / GetSimulatorResolution to support GHDL                   |
|               |     - Added beta of LinkLibrary to support linking in project libraries                       |
|               |     - Added beta of SetLibraryDirectory / GetLibraryDirectory                                 |
|               |     - Added beta of ResetRunLibrary                                                           |
| 2020.10       |  Added eval before vendor commands to properly handle arguments.                              |
| 2020.07       |  Added README.md with documentation.                                                          |
|               |  Refactored tool execution for simpler vendor customization                                   |
| 2020.01       |  Updated to Apache Licenses                                                                   |
| 2019.02       |  Refactored so that *.pro scripts are executable TCL scripts                                  |
|               |  that call procedures.                                                                        |
| 2018.11       |  Initial release                                                                              |

 
## Copyright and License
Copyright (C) 2006-2024 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2022-2024 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
