#  File Name:         Cov2Html.tcl
#  Purpose:           Convert OSVVM coverage in YAML to HTML
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

proc Cov2Html {TestCaseName} {
  variable ResultsFile
  
#  set FileName  [file rootname ${CovFile}].html
#  file copy -force ${::osvvm::SCRIPT_DIR}/header_cov.html ${FileName}
#  set ResultsFile [open ${FileName} a]
  
  OpenSimulationReportFile $TestCaseName
  set CovFile reports/${TestCaseName}_cov.yml

  puts $ResultsFile "<hr>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "<h2 id=\"FunctionalCoverage\">OSVVM Coverage Report for $TestCaseName</h2>"

  set TestDict [::yaml::yaml2dict -file ${CovFile}]
  set VersionNum  [dict get $TestDict Version]
  
  foreach ModelDict [dict get $TestDict Models] {
    puts $ResultsFile "  <details open><summary style=\"font-size: 16px;\"><strong>Coverage Model: [dict get $ModelDict Name]</strong></summary>"
    puts $ResultsFile "  <div  style=\"margin: 5px 30px;\">"
    OsvvmCovInfo2Html $ModelDict
    OsvvmCovBins2Html $ModelDict
    puts $ResultsFile "  <br>"
    puts $ResultsFile "  </div>"
    puts $ResultsFile "  </details>"
  }
  close $ResultsFile
}

proc OsvvmCovInfo2Html {ModelDict} {
  variable ResultsFile
  
  set CovInformation [dict get $ModelDict Settings] 
  
  puts $ResultsFile "    <DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "    <details><summary>Coverage Settings for [dict get $ModelDict Name]</summary>"
  puts $ResultsFile "    <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "    <div  style=\"margin: 0px 30px;\">"
  puts $ResultsFile "    <table>"

  dict for {key val} ${CovInformation} {
      puts $ResultsFile "      <tr><td>${key}</td><td>${val}</td></tr>"
  }
  
  puts $ResultsFile "    </table>"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "    <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "    </details>"
}

proc OsvvmCovBins2Html {ModelDict} {
  variable ResultsFile
  
  set BinInfoDict [dict get $ModelDict BinInfo] 
  set BinsArray   [dict get $ModelDict Bins]

  puts $ResultsFile "      <DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "      <details open><summary>Coverage Bins for [dict get $ModelDict Name]</summary>"
  puts $ResultsFile "      <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "      <div  style=\"margin: 0px 30px;\">"
  puts $ResultsFile "      <table>"
  puts $ResultsFile "      <tr>"
  puts $ResultsFile "        <th rowspan=\"2\">Name</th>"
  puts $ResultsFile "        <th rowspan=\"2\">Type</th>"
  foreach Heading [dict get $BinInfoDict FieldNames] {
    puts $ResultsFile "        <th rowspan=\"2\">${Heading}</th>"
  }
  puts $ResultsFile "        <th rowspan=\"2\">Count</th>"
  puts $ResultsFile "        <th rowspan=\"2\">AtLeast</th>"
  puts $ResultsFile "        <th rowspan=\"2\">Percent<br>Coverage</th>"
  puts $ResultsFile "      </tr>"
  puts $ResultsFile "      <tr></tr>"

  foreach BinDict $BinsArray {
    puts $ResultsFile "      <tr>"
    puts $ResultsFile "        <td>[dict get $BinDict Name]</td>"
    puts $ResultsFile "        <td>[dict get $BinDict Type]</td>"
    set RangeArray [dict get $BinDict Range]
    foreach RangeDict $RangeArray {
      puts $ResultsFile "        <td>[dict get $RangeDict Min] to [dict get $RangeDict Max]</td>"
    }
    puts $ResultsFile "        <td>[dict get $BinDict Count]</td>"
    puts $ResultsFile "        <td>[dict get $BinDict AtLeast]</td>"
    puts $ResultsFile "        <td>[format %.1f [dict get $BinDict PercentCov]]</td>"
    puts $ResultsFile "      </tr>"
  }
  set NumBinsLessOne [expr 3 + [llength $RangeArray]]
  puts $ResultsFile "      <tr>"
  puts $ResultsFile "        <th style=\"text-align: left\" colspan=\"$NumBinsLessOne\">Total Percent Coverage</th>"
  puts $ResultsFile "        <td style=\"text-align: center\" colspan=\"2\">[format %.1f [dict get $ModelDict Coverage]]</td>"
  puts $ResultsFile "      </tr>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "      </div>"
  puts $ResultsFile "      <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "      </details>"
}
