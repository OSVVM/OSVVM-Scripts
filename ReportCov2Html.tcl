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
#    07/2024   2024.07    Updated handling of Coverage models with 0 weight
#    05/2024   2024.05    Minor updates during Simulate2Html refactoring
#    04/2024   2024.04    Updated report formatting
#    06/2022   2022.06    Print PASSED/FAILED with Coverage HTML
#    02/2022   2022.02    Updated YAML file handling
#    01/2022   2022.01    Handling for All Range
#    10/2021   Initial    Initial Revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2021-2024 by SynthWorks Design Inc.  
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

proc Cov2Html {TestCaseName TestSuiteName CovYamlFile} {
  variable ResultsFile
    
  OpenSimulationReportFile [file join $::osvvm::Report2TestCaseHtml]
  
  set ErrorCode [catch {LocalCov2Html $TestCaseName $TestSuiteName $CovYamlFile} errmsg]
  
  close $ResultsFile

  if {$ErrorCode} {
    CallbackOnError_Cov2Html $TestSuiteName $TestCaseName $errmsg
  }
}

proc LocalCov2Html {TestCaseName TestSuiteName CovYamlFile} {
  variable ResultsFile

  puts $ResultsFile "  <hr />"
  puts $ResultsFile "  <div class=\"FunctionalCoverage\">"
  puts $ResultsFile "    <h2 id=\"FunctionalCoverage\">$TestCaseName Coverage Report</h2>"

  set TestDict [::yaml::yaml2dict -file ${CovYamlFile}]
  set VersionNum    [dict get $TestDict Version]
  set CovSettings   [dict get $TestDict Settings]
  set WritePassFail [dict get $CovSettings WritePassFail]
  set Coverage      [dict get $TestDict Coverage]
  puts $ResultsFile "    <p>Total Coverage: $Coverage</p>"
  set FoundZeroWeight FALSE
  
  foreach ModelDict [dict get $TestDict Models] {
    set ModelName [dict get $ModelDict Name]
    set CovModelSettings [dict get $ModelDict Settings] 
    set CovWeight        [dict get $CovModelSettings CovWeight] 
    if {$CovWeight < 1} {
      if {!$FoundZeroWeight} {
        puts $ResultsFile "    <details><summary class=\"subtitle\">Coverage Models with CovWeight = 0.  Ignored in GetCov calculations.  Used for OSVVM DelayCoverage. </summary>"
        set FoundZeroWeight TRUE
      }
    }
    puts $ResultsFile "    <details open><summary class=\"subtitle\">$ModelName Coverage Model &emsp; &emsp; Coverage: [format %.1f [dict get $ModelDict Coverage]]</summary>"
    OsvvmCovInfo2Html $ModelName $CovModelSettings
    OsvvmCovBins2Html $ModelName $ModelDict $WritePassFail $CovWeight
    puts $ResultsFile "    </details>"
  }
  if {$FoundZeroWeight} {
    puts $ResultsFile "    </details>"
  }
  puts $ResultsFile "  </div>"
}

proc OsvvmCovInfo2Html {ModelName CovModelSettings} {
  variable ResultsFile
  
  puts $ResultsFile "      <div class=\"CoverageSettings\">"
  puts $ResultsFile "        <details><summary class=\"subindented\">$ModelName Coverage Settings</summary>"
  puts $ResultsFile "          <table class=\"CoverageSettings\">"
  puts $ResultsFile "            <thead>"
  puts $ResultsFile "              <tr>"
  puts $ResultsFile "                  <th>Settings</th>"
  puts $ResultsFile "                  <th>Value</th>"
  puts $ResultsFile "              </tr>"
  puts $ResultsFile "            </thead>"
  puts $ResultsFile "            <tbody>"

  dict for {key val} ${CovModelSettings} {
    if {$key ne "Seeds"} {
      puts $ResultsFile "              <tr><td>${key}</td><td>${val}</td></tr>"
    } else {
      puts $ResultsFile "              <tr><td>${key}</td><td>[lindex ${val} 0], &nbsp;[lindex ${val} 1]</td></tr>"
    }
  }
  
  puts $ResultsFile "            </tbody>"
  puts $ResultsFile "          </table>"
  puts $ResultsFile "        </details>"
  puts $ResultsFile "      </div>"
}

proc OsvvmCovBins2Html {ModelName ModelDict WritePassFail CovWeight} {
  variable ResultsFile
  
  set BinInfoDict      [dict get $ModelDict BinInfo] 
  set BinsArray        [dict get $ModelDict Bins]

  puts $ResultsFile "      <div class=\"CoverageTable\">"
  puts $ResultsFile "        <details open><summary class=\"subindented\">$ModelName Coverage Bins</summary>"
  puts $ResultsFile "          <table class=\"CoverageTable\">"
  puts $ResultsFile "            <thead>"
  puts $ResultsFile "              <tr>"
  puts $ResultsFile "                <th rowspan=\"2\">Name</th>"
  puts $ResultsFile "                <th rowspan=\"2\">Type</th>"
  foreach Heading [dict get $BinInfoDict FieldNames] {
    puts $ResultsFile "                <th rowspan=\"2\">${Heading}</th>"
  }
  puts $ResultsFile "                <th rowspan=\"2\">Count</th>"
  puts $ResultsFile "                <th rowspan=\"2\">AtLeast</th>"
  puts $ResultsFile "                <th rowspan=\"2\">Percent<br>Coverage</th>"
  if {$WritePassFail} {
    puts $ResultsFile "              <th rowspan=\"2\">Status</th>"
  }
  puts $ResultsFile "              </tr>"
  puts $ResultsFile "            </thead>"
  puts $ResultsFile "            <tbody>"

  foreach BinDict $BinsArray {
    puts $ResultsFile "              <tr>"
    puts $ResultsFile "                <td>[dict get $BinDict Name]</td>"
    set CovType [dict get $BinDict Type]
    puts $ResultsFile "                <td>$CovType</td>"
    set RangeArray [dict get $BinDict Range]
    foreach RangeDict $RangeArray {
      set MinRange [dict get $RangeDict Min]
      set MaxRange [dict get $RangeDict Max]
      if {${MinRange} == ${MaxRange}} {
        puts $ResultsFile "                <td>${MinRange}</td>"
      } elseif {${MinRange} > -2147483647 && ${MaxRange} < 2147483647} {
        puts $ResultsFile "                <td>${MinRange} to ${MaxRange}</td>"
      } else {
        puts $ResultsFile "                <td>ALL</td>"
      }
    }
    set CovCount   [dict get $BinDict Count]
    set CovAtLeast [dict get $BinDict AtLeast]
    puts $ResultsFile "                <td>$CovCount</td>"
    puts $ResultsFile "                <td>$CovAtLeast</td>"
    puts $ResultsFile "                <td>[format %.1f [dict get $BinDict PercentCov]]</td>"
    if {$WritePassFail} {
      if {$CovWeight > 0} {
        if {$CovType eq "COUNT"} {
          set CovPassed [expr {$CovCount >= $CovAtLeast}]
        } elseif {$CovType eq "ILLEGAL"} {
          set CovPassed [expr {$CovCount == 0}]
        }
        if {$CovType ne "IGNORE"} {
          if {$CovPassed} {
            puts $ResultsFile "                <td class=\"passed\">PASSED</td>"
          } else {
            puts $ResultsFile "                <td class=\"failed\">FAILED</td>"
          }
        } else {
          puts $ResultsFile "                <td>IGNORED</td>"
        }
      } else {
          puts $ResultsFile "                <td>-</td>"
      }
    }
    puts $ResultsFile "              </tr>"
  }
  set NumBins [expr 5 + [llength $RangeArray]]
  puts $ResultsFile "              <tr>"
  puts $ResultsFile "                <td style=\"text-align: left\" colspan=\"$NumBins\"><strong>Total Percent Coverage:</strong> &emsp; [format %.1f [dict get $ModelDict Coverage]]</td>"
  puts $ResultsFile "              </tr>"
  puts $ResultsFile "            </tbody>"
  puts $ResultsFile "          </table>"
  puts $ResultsFile "        </details>"
  puts $ResultsFile "      </div>"
}
