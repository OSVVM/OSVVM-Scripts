#  File Name:         NoYamlPackage.tcl
#  Purpose:           Provides handling when YAML packages are not available
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Called when YAML packages are missing.   
#    Provides implementations of Report2Html, Report2Junit, 
#    GenerateSimulationReports, Cov2Html, Alert2Html
#    that generate error messages and provide information on 
#    how to load the tcl library.
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
#    12/2021   2021.12    Fixed name for Simulate2Html
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2021 by SynthWorks Design Inc.  
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

proc Report2Html {ReportFile} {
  puts "To generate OSVVM Test Suite Report HTML files, please install TCL yaml package from Tcllib"
  puts "See https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_sources.md"
}

proc Report2Junit {ReportFile} {
  puts "To generate OSVVM Test Suite Report JUnit XML CI Results files, please install TCL yaml package from Tcllib"
  puts "See https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_sources.md"
}


proc Simulate2Html {TestCaseName TestSuiteName} {
  puts "To generate OSVVM simulation HTML files, please install TCL yaml package from Tcllib"
  puts "See https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_sources.md"
}

proc Cov2Html {TestCaseName} {
  puts "To generate OSVVM coverage HTML files, please install TCL yaml package from Tcllib"
  puts "See https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_sources.md"
}

proc Alert2Html {TestCaseName} {
  puts "To generate OSVVM coverage HTML files, please install TCL yaml package from Tcllib"
  puts "See https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_sources.md"
}
