#  File Name:         OsvvmYamlSupport.tcl
#  Purpose:           Utilities to convert OSVVM YAML files to HTML and JUnit XML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    Utilities to convert OSVVM YAML files to HTML and JUnit XML
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
#    02/2022   2022.02    Added Scoreboard reports
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2021-2022 by SynthWorks Design Inc.
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

  source ${::osvvm::SCRIPT_DIR}/Simulate2Html.tcl
  source ${::osvvm::SCRIPT_DIR}/Alert2Html.tcl
  source ${::osvvm::SCRIPT_DIR}/Cov2Html.tcl
  source ${::osvvm::SCRIPT_DIR}/Scoreboard2Html.tcl
  source ${::osvvm::SCRIPT_DIR}/Report2Html.tcl
  source ${::osvvm::SCRIPT_DIR}/Report2Junit.tcl
  
namespace export Simulate2Html Cov2Html Alert2Html Scoreboard2Html Report2Html Report2Junit
# end namespace ::osvvm
}
