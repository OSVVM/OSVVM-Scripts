#  File Name:         Cov2Html.tcl
#  Purpose:           Convert OSVVM YAML coverage information to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Convert OSVVM YAML coverage information to HTML
#    Visible externally:  Cov2Html
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
#    06/2022   2022.06    Print PASSED/FAILED with Coverage HTML
#    02/2022   2022.02    Updated YAML file handling
#    01/2022   2022.01    Handling for All Range
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

package require yaml

#proc GetCov {TestCaseName} {
#  set CovFile ${::osvvm::ReportsDirectory}/${TestCaseName}_cov.yml
#  set TestDict [::yaml::yaml2dict -file ${CovFile}]
#  set Coverage    [dict get $TestDict Coverage]
#  
#  return $Coverage
#}

proc Cov2Html {TestCaseName TestSuiteName CovYamlFile} {
  variable ResultsFile
    
  OpenSimulationReportFile ${TestCaseName} ${TestSuiteName}
  
  set ErrorCode [catch {LocalCov2Html $TestCaseName $TestSuiteName $CovYamlFile} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Cov2Html $TestSuiteName $TestCaseName $errmsg
  }
}

proc LocalCov2Html {TestCaseName TestSuiteName CovYamlFile} {
  variable ResultsFile

  puts $ResultsFile "<hr>"
  puts $ResultsFile "<DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "<h2 id=\"FunctionalCoverage\">$TestCaseName Coverage Report</h2>"

  set TestDict [::yaml::yaml2dict -file ${CovYamlFile}]
  set VersionNum    [dict get $TestDict Version]
  set CovSettings   [dict get $TestDict Settings]
  set WritePassFail [dict get $CovSettings WritePassFail]
  set Coverage      [dict get $TestDict Coverage]
  puts $ResultsFile "<strong>Total Coverage: $Coverage</strong>"
  puts $ResultsFile "<br><br>"
  
  foreach ModelDict [dict get $TestDict Models] {
    puts $ResultsFile "  <details open><summary style=\"font-size: 16px;\"><strong>[dict get $ModelDict Name] Coverage Model &emsp; &emsp; Coverage: [format %.1f [dict get $ModelDict Coverage]]</strong></summary>"
    puts $ResultsFile "  <div  style=\"margin: 5px 30px;\">"
    OsvvmCovInfo2Html $ModelDict
    OsvvmCovBins2Html $ModelDict $WritePassFail
    puts $ResultsFile "  <br>"
    puts $ResultsFile "  </div>"
    puts $ResultsFile "  </details>"
  }
}

proc OsvvmCovInfo2Html {ModelDict} {
  variable ResultsFile
  
  set CovModelSettings [dict get $ModelDict Settings] 
  
  puts $ResultsFile "    <DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "    <details><summary>[dict get $ModelDict Name] Coverage Settings</summary>"
  puts $ResultsFile "    <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "    <div  style=\"margin: 0px 30px;\">"
  puts $ResultsFile "    <table>"

  dict for {key val} ${CovModelSettings} {
    if {$key ne "Seeds"} {
      puts $ResultsFile "      <tr><td>${key}</td><td>${val}</td></tr>"
    } else {
      puts $ResultsFile "      <tr><td>${key}</td><td>[lindex ${val} 0], &nbsp;[lindex ${val} 1]</td></tr>"
    }
  }
  
  puts $ResultsFile "    </table>"
  puts $ResultsFile "    </div>"
  puts $ResultsFile "    <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "    </details>"
}

proc OsvvmCovBins2Html {ModelDict WritePassFail} {
  variable ResultsFile
  
  set CovModelSettings [dict get $ModelDict Settings] 
  set CovWeight        [dict get $CovModelSettings CovWeight] 
  set BinInfoDict      [dict get $ModelDict BinInfo] 
  set BinsArray        [dict get $ModelDict Bins]

  puts $ResultsFile "      <DIV STYLE=\"font-size:5px\"><BR></DIV>"
  puts $ResultsFile "      <details open><summary>[dict get $ModelDict Name] Coverage Bins</summary>"
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
  if {$WritePassFail} {
    puts $ResultsFile "      <th rowspan=\"2\">Status</th>"
  }
  puts $ResultsFile "      </tr>"
  puts $ResultsFile "      <tr></tr>"

  foreach BinDict $BinsArray {
    puts $ResultsFile "      <tr>"
    puts $ResultsFile "        <td>[dict get $BinDict Name]</td>"
    set CovType [dict get $BinDict Type]
    puts $ResultsFile "        <td>$CovType</td>"
    set RangeArray [dict get $BinDict Range]
    foreach RangeDict $RangeArray {
      set MinRange [dict get $RangeDict Min]
      set MaxRange [dict get $RangeDict Max]
      if {${MinRange} == ${MaxRange}} {
        puts $ResultsFile "        <td>${MinRange}</td>"
      } elseif {${MinRange} > -2147483647 && ${MaxRange} < 2147483647} {
        puts $ResultsFile "        <td>${MinRange} to ${MaxRange}</td>"
      } else {
        puts $ResultsFile "        <td>ALL</td>"
      }
    }
    set CovCount   [dict get $BinDict Count]
    set CovAtLeast [dict get $BinDict AtLeast]
    puts $ResultsFile "        <td>$CovCount</td>"
    puts $ResultsFile "        <td>$CovAtLeast</td>"
    puts $ResultsFile "        <td>[format %.1f [dict get $BinDict PercentCov]]</td>"
    if {$WritePassFail} {
      if {$CovWeight > 0} {
        if {$CovType eq "COUNT"} {
          set CovPassed [expr {$CovCount >= $CovAtLeast}]
        } else {
          set CovPassed [expr {$CovCount != 0}]
        }
        if {$CovPassed} {
          puts $ResultsFile "        <td style=color:#00C000>PASSED</td>"
        } else {
          puts $ResultsFile "        <td style=color:#F00000>FAILED</td>"
        }
      } else {
          puts $ResultsFile "        <td>-</td>"
      }
    }
    puts $ResultsFile "      </tr>"
  }
  set NumBins [expr 5 + [llength $RangeArray]]
  puts $ResultsFile "      <tr>"
  puts $ResultsFile "        <td style=\"text-align: left\" colspan=\"$NumBins\"><strong>Total Percent Coverage:</strong> &emsp; [format %.1f [dict get $ModelDict Coverage]]</td>"
  puts $ResultsFile "      </tr>"
  puts $ResultsFile "      </table>"
  puts $ResultsFile "      </div>"
  puts $ResultsFile "      <DIV STYLE=\"font-size:10px\"><BR></DIV>"
  puts $ResultsFile "      </details>"
}
