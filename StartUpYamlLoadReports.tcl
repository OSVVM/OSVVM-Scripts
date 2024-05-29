#  File Name:         StartUpYamlLoadReports.tcl
#  Purpose:           Utilities to convert OSVVM YAML files to HTML and JUnit XML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Load YAML reporting utilities - sources multiple files
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
#    05/2024   2024.05    Updated name.  Added ReportSupport.  Updated for refactoring.
#    02/2022   2022.02    Added Scoreboard reports
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021 - 2024 by SynthWorks Design Inc.
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

package require yaml

  variable GotYaml 1
  source ${::osvvm::OsvvmScriptDirectory}/ReportSimulate2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportAlert2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportCov2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportScoreboard2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportSupport.tcl
  
  source ${::osvvm::OsvvmScriptDirectory}/ReportBuildYaml2Dict.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportBuildDict2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/ReportBuildDict2Junit.tcl
  
#  source ${::osvvm::OsvvmScriptDirectory}/Report2Html.tcl
#  source ${::osvvm::OsvvmScriptDirectory}/Report2Junit.tcl
  
  source ${::osvvm::OsvvmScriptDirectory}/RequirementsMerge.tcl
  source ${::osvvm::OsvvmScriptDirectory}/Requirements2Html.tcl
  source ${::osvvm::OsvvmScriptDirectory}/Requirements2Csv.tcl
  
namespace export Simulate2Html Cov2Html Alert2Html Scoreboard2Html MergeRequirements Requirements2Html Requirements2Csv
namespace export CreateBuildReports ReportBuildYaml2Dict ReportBuildDict2Html ReportBuildDict2Junit Report2Html Report2Junit
# end namespace ::osvvm
}
