#  File Name:         StartUp.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Tcl procedures to configure and adapt the OSVVM simulator 
#    scripting methodology for a particular project.
#    As part of its tasks, it runs OSVVM scripts that define
#    procedures use in the OSVVM scripting methodology.
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
#    10/2021   Alpha      Cov2Html: Convert OSVVM coverage results to HTML
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

package require yaml

proc Cov2Html {CovFile} {
  variable ResultsFile
  
  set FileName  [file rootname ${CovFile}].html
  file copy -force ${::osvvm::SCRIPT_DIR}/header_cov.html ${FileName}
  set ResultsFile [open ${FileName} a]

  set TestData [::yaml::yaml2dict -file ${CovFile}]
  set VersionNum  [dict get $TestData Version]
  
#  puts "Version: $VersionNum"
  foreach TestDict [dict get $TestData Tests] {
#    puts [dict keys $TestDict]
    
    puts $ResultsFile "  <li>Test: [dict get $TestDict Name]"
    puts $ResultsFile "  <ul>"
    puts $ResultsFile "    <li>Coverage: [dict get $TestDict Coverage]</li>"
    
#    OsvvmCovInfo2Html [dict get $TestDict Information] "    "
    OsvvmCovModels2Html [dict get $TestDict Models] 
    puts $ResultsFile "  </ul>"
    puts $ResultsFile "  </li>"
  } 
  puts $ResultsFile "  </ul>"
  puts $ResultsFile "  </body>"
  close $ResultsFile
}

proc OsvvmCovInfo2Html {CovInformation Prefix} {
  variable ResultsFile

  dict for {key val} ${CovInformation} {
      puts $ResultsFile "${Prefix}<li>${key}: ${val}</li>"
  }
}

proc OsvvmCovModels2Html {CovModelArray} {
  variable ResultsFile

  foreach ModelDict ${CovModelArray} {
    puts $ResultsFile "  <li><details><summary>Coverage Model: [dict get $ModelDict Name]</summary>"
    puts $ResultsFile "  <ul>"
    puts $ResultsFile "    <li>Coverage: [dict get $ModelDict Coverage]</li>"
    puts $ResultsFile "    <li><details><summary>Settings</summary>"
    puts $ResultsFile "    <ul>"
    OsvvmCovInfo2Html [dict get $ModelDict Settings] "      "
    puts $ResultsFile "    </ul>"
    puts $ResultsFile "    </details></li>"
    OsvvmCovBins2Html [dict get $ModelDict BinInfo] [dict get $ModelDict Bins]
    puts $ResultsFile "  </ul>"
    puts $ResultsFile "  <br>"
    puts $ResultsFile "  </details></li>"
  }
}

proc OsvvmCovBins2Html {BinInfoDict BinsArray} {
  variable ResultsFile

  puts $ResultsFile "    <li><details open><summary>Bins</summary>"
  puts $ResultsFile "      <table>"
  puts $ResultsFile "      <tr>"
  puts $ResultsFile "        <td>Name</td>"
  puts $ResultsFile "        <td>Type</td>"
  foreach Heading [dict get $BinInfoDict FieldNames] {
    puts $ResultsFile "        <td>${Heading}</td>"
  }
  puts $ResultsFile "        <td>Count</td>"
  puts $ResultsFile "        <td>AtLeast</td>"
  puts $ResultsFile "        <td>Percent Coverage</td>"
  puts $ResultsFile "      </tr>"

  foreach BinDict $BinsArray {
    puts $ResultsFile "      <tr>"
    puts $ResultsFile "        <td>[dict get $BinDict Name]</td>"
    puts $ResultsFile "        <td>[dict get $BinDict Type]</td>"
    foreach RangeDict [dict get $BinDict Range] {
      puts $ResultsFile "        <td>[dict get $RangeDict From] to [dict get $RangeDict To]</td>"
    }
    puts $ResultsFile "        <td>[dict get $BinDict Count]</td>"
    puts $ResultsFile "        <td>[dict get $BinDict AtLeast]</td>"
    puts $ResultsFile "        <td>[dict get $BinDict PercentCov]</td>"
  }
  puts $ResultsFile "      </tr>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "      </details></li>"
}
