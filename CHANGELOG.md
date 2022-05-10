# The OSVVM Verification Script Library Change Log

| **Revision**  | **Revision Date**  |  **Release Summary**                                                  | 
|---------------|--------------------|-----------------------------------------------------------------------| 
| 2022.05       | May 2022           | Coverage report name now based on TestCaseName rather than LibraryUnit|
| 2022.03       | March 2022         | Added link to test transcript files (TranscriptOpen)                  |
|               |                    | Report links to Code Coverage and Transcripts now use relative paths  |
| 2022.02       | February 2022      | Added Transcripts in HTML, Scoreboard Reports, and Code Coverage Integration  |
| 2022.01       | January 2022       | Minor changes.  Lib dir lower case.  OptionalCommands for analyzing Verilog.  |
|               |                    | Writing FC now in VHDL.  Added DirectoryExists                        |
| 2021.12       | December 2021      | Changed Paths to Relative Paths.  Added better library support.       |
| 2021.11       | November 2021      | Updated scripting to fine tune HTML and XML reporting.                |
| 2021.10       | October 2021       | Added support to convert build YAML files to HTML and XML (JUnit)     |
|               |                    |    Added support to convert Alert and coverage YAML to HTML reports   |
|               |                    |    Added support to convert Alert and coverage YAML to HTML reports   |
| 2021.09       | September 2021     | Added support for Synopsys VCS and Cadence Xcelium.                   |
|               |                    | Added support for creation of YAML files.                             |
| 2021.06       | June 2021          | Updated VendorScripts_GHDL to better handle GHDL return values        |
| 2021.05       | May 2021           | Updates related to adding namespace for osvvm                         |
|               |                    |    Added VendorScripts_Vivado.tcl - thanks Rob Gaddi                  |
| 2021.03       | March 2021         | Minor work around for vendor tool issues                              |
| 2021.03       | March 2021         | Minor work around for vendor tool issues                              |
| 2021.02       | February 2021      | Refactored.                                                           |
|               |                    |    - Tool now determined in StartUp.tcl. Simplifies ActiveHDL startup |
|               |                    |    - Initial tool settings now in VendorScripts_*.tcl                 |
|               |                    |       - In ActiveHDL, set global OSVVM library to read/write          |
|               |                    |    - Added: Default settings now in OsvvmScriptDefaults.tcl           |
|               |                    |    - Removed: ToolConfiguration.tcl                                   |
|               |                    | In VendorScripts_GHDL.tcl, fixed log file generation in GHDL          |
|               |                    | In OsvvmProjectScripts.tcl                                            |
|               |                    |    - Updated initialization of libraries                              |
|               |                    |    - Analyze allows ".vhdl" extensions as well as ".vhd"              |
|               |                    |    - Include/Build signal error if nothing to run                          |
|               |                    |    - Added SetVHDLVersion / GetVHDLVersion to support 2019 work            |
|               |                    |    - Added SetSimulatorResolution / GetSimulatorResolution to support GHDL |
|               |                    |    - Added beta of LinkLibrary to support linking in project libraries     |
|               |                    |    - Added beta of SetLibraryDirectory / GetLibraryDirectory               |
|               |                    |    - Added beta of ResetRunLibrary                                         |
| 2020.10       | October 2020       | Added eval before vendor commands to properly handle arguments.       |
| 2020.07       | July 2020          | Added README.md with documentation.                                   |
|               |                    | Refactored tool execution for simpler vendor customization            |
| 2020.01       | January 2020       | Updated to Apache Licenses                                            |
| 2019.02       | February 2019      | Refactored so that *.pro scripts are executable TCL scripts           |
|               |                    | that call procedures.                                                 |
| 2018.11       | November 2018      | Initial release                                                       |

 
## Copyright and License
Copyright (C) 2006-2022 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2022 by [OSVVM contributors](CONTRIBUTOR.md)   

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
