#  File Name:         ReportSupport.tcl
#  Purpose:           Convert OSVVM YAML build reports to HTML
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      email:  jim@synthworks.com
#
#  Description
#    HTML Report Helpers
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
#    07/2024   2024.07    Updated variable naming.  Changed GenericList to Report2GenericDict
#    05/2024   2024.05    Initial Revision
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2024 by SynthWorks Design Inc.
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

# -------------------------------------------------
# FormatGenericValueForHtml
#
# YAML boolean scalars may load into Tcl as 0/1. For generics, prefer showing
# True/False in HTML (matching VHDL/OSVVM conventions) when we can infer the
# original boolean value from the encoded GenericNames/TestCaseFileName string.
#
proc FormatGenericValueForHtml {GenericName GenericValue {GenericNames ""}} {
  set EncodedGenericName $GenericName
  if {[string match "G_*" $EncodedGenericName]} {
    set EncodedGenericName [string range $EncodedGenericName 2 end]
  }

  if {$GenericNames ne ""} {
    if {[string first "_G_${EncodedGenericName}_TRUE"  $GenericNames] >= 0} { return "True" }
    if {[string first "_G_${EncodedGenericName}_FALSE" $GenericNames] >= 0} { return "False" }
  }

  if {[string equal -nocase $GenericValue "true"]}  { return "True" }
  if {[string equal -nocase $GenericValue "false"]} { return "False" }

  return $GenericValue
}

# -------------------------------------------------
# FormatScalarForHtml
#
# YAML booleans commonly load into Tcl as 0/1. For HTML reports, render
# booleans as True/False.
#
proc FormatScalarForHtml {Value} {
  if {[string equal -nocase $Value "true"]}  { return "True" }
  if {[string equal -nocase $Value "false"]} { return "False" }

  # Heuristic: yaml::yaml2dict represents YAML booleans as Tcl 0/1
  if {$Value eq 1 || $Value eq "1"} { return "True" }
  if {$Value eq 0 || $Value eq "0"} { return "False" }

  return $Value
}

# -------------------------------------------------
# InferScalarTypeForHtml
#
# Best-effort type inference for scalar values loaded from YAML.
# Used by the per-test HTML page to display a "Type" column for tags.
#
proc InferScalarTypeForHtml {Value} {
  # Normalize to string for regex checks.
  set S "${Value}"

  # Boolean
  if {[string equal -nocase $S "true"] || [string equal -nocase $S "false"]} {
    return "boolean"
  }

  # Heuristic: yaml::yaml2dict commonly maps YAML booleans to Tcl 0/1
  if {$S eq "0" || $S eq "1"} {
    return "boolean"
  }

  # Time: number + unit (common VHDL time units)
  # Examples: 100 ns, 5ps, 1.25 us
  if {[regexp -nocase {^\s*[-+]?\d+(?:\.\d+)?\s*(fs|ps|ns|us|ms|s|sec|secs|second|seconds|min|mins|minute|minutes|hr|hrs|hour|hours)\s*$} $S]} {
    return "time"
  }

  # Integer
  if {[string is integer -strict $S]} {
    return "integer"
  }

  # Real
  if {[string is double -strict $S]} {
    return "real"
  }

  return "string"
}

# -------------------------------------------------
# EscapeHtml
#
proc EscapeHtml {Text} {
  # Strip ASCII control chars that can break HTML rendering.
  regsub -all {[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]} $Text { } Escaped
  set Escaped [string map [list "&" "&amp;" "<" "&lt;" ">" "&gt;" "\"" "&quot;" "'" "&#39;"] $Escaped]
  return $Escaped
}

# -------------------------------------------------
# FormatInlineMarkdownSubset
#
# Minimal inline Markdown subset:
#   - Escapes for literals using backslash: \*, \#, \[, \], \(, \), \`, \-, \\
#   - Inline code using backticks: `code`
#   - Links: [text](url)
#       - Allowed URL schemes/targets: https://, http://, #anchors, /absolute, ./relative, ../relative
#       - Other URLs are rendered as plain text (not a link)
#   - Emphasis: **bold** and *italic*
#
# Input must already be HTML-escaped.

proc _IsSafeMarkdownUrl {Url} {
  set U [string trim $Url]
  if {$U eq ""} {
    return 0
  }
  if {[regexp {\s} $U]} {
    return 0
  }
  if {[regexp -nocase {^https?://} $U]} {
    return 1
  }
  if {[string match "#*" $U]} {
    return 1
  }
  if {[string match "/*" $U]} {
    return 1
  }
  if {[string match "./*" $U] || [string match "../*" $U]} {
    return 1
  }
  return 0
}

proc _ProtectInlineCodeSpans {S CodeMapVar} {
  upvar 1 $CodeMapVar CodeMap
  set Out ""
  set Remainder $S
  set I 0
  while {[regexp -indices {`([^`]+)`} $Remainder MatchIdx CodeIdx]} {
    lassign $MatchIdx M0 M1
    lassign $CodeIdx C0 C1

    if {$M0 > 0} {
      append Out [string range $Remainder 0 [expr {$M0 - 1}]]
    }

    set CodeText [string range $Remainder $C0 $C1]
    set Token "\uE000${I}\uE001"
    set CodeMap($Token) $CodeText
    append Out $Token
    incr I

    set Remainder [string range $Remainder [expr {$M1 + 1}] end]
  }
  append Out $Remainder
  return $Out
}

proc _RestoreInlineCodeSpans {S CodeMapVar} {
  upvar 1 $CodeMapVar CodeMap
  set Out $S
  foreach Token [lsort -dictionary [array names CodeMap]] {
    set Out [string map [list $Token "<code>$CodeMap($Token)</code>"] $Out]
  }
  return $Out
}

proc FormatInlineMarkdownSubset {EscapedText} {
  set S $EscapedText

  # Handle backslash escapes first so escaped markup is treated as literal.
  # Use control characters as placeholders to avoid interacting with later regex.
  set TOK_BSLASH "\u0001"
  set TOK_STAR   "\u0002"
  set TOK_HASH   "\u0003"
  set TOK_LB     "\u0004"
  set TOK_RB     "\u0005"
  set TOK_LP     "\u0006"
  set TOK_RP     "\u0007"
  set TOK_BT     "\u0008"
  set TOK_DASH   "\u0009"
  set S [string map [list {\\} $TOK_BSLASH {\*} $TOK_STAR {\#} $TOK_HASH {\[} $TOK_LB {\]} $TOK_RB {\(} $TOK_LP {\)} $TOK_RP {\`} $TOK_BT {\-} $TOK_DASH] $S]

  # Protect inline code spans so other formatting does not apply inside them.
  array set CodeMap {}
  set S [_ProtectInlineCodeSpans $S CodeMap]

  # Links: [text](url)
  # Note: Both text and url are already HTML-escaped here.
  set Out ""
  set Remainder $S
  while {[regexp -indices {\[([^\]]+)\]\(([^\)]+)\)} $Remainder MatchIdx TextIdx UrlIdx]} {
    lassign $MatchIdx M0 M1
    lassign $TextIdx T0 T1
    lassign $UrlIdx U0 U1

    if {$M0 > 0} {
      append Out [string range $Remainder 0 [expr {$M0 - 1}]]
    }

    set LinkText [string range $Remainder $T0 $T1]
    set LinkUrl  [string range $Remainder $U0 $U1]
    if {[_IsSafeMarkdownUrl $LinkUrl]} {
      append Out "<a href=\"$LinkUrl\">$LinkText</a>"
    } else {
      append Out "$LinkText ($LinkUrl)"
    }

    set Remainder [string range $Remainder [expr {$M1 + 1}] end]
  }
  append Out $Remainder
  set S $Out

  # Emphasis
  regsub -all {\*\*([^*]+)\*\*} $S {<strong>\1</strong>} S
  regsub -all {\*([^*]+)\*} $S {<em>\1</em>} S

  # Restore inline code spans
  set S [_RestoreInlineCodeSpans $S CodeMap]

  # Restore escaped literals
  set S [string map [list \
    $TOK_BSLASH "\\" \
    $TOK_STAR {*} \
    $TOK_HASH {#} \
    $TOK_LB {[} \
    $TOK_RB {]} \
    $TOK_LP {(} \
    $TOK_RP {)} \
    $TOK_BT {`} \
    $TOK_DASH {-} \
  ] $S]
  return $S
}

# -------------------------------------------------
# WriteMarkdownSubsetAsHtml
#
# Minimal Markdown subset:
#   - Paragraphs separated by blank lines
#   - Headings: ##, ###, ####, #####
#   - Bullet list items: - 
#   - Enumerated list items: 1. 
#   - Inline: **bold**, *italic*, `code`, [text](url), and backslash escapes
#
proc WriteMarkdownSubsetAsHtml {ResultsFile Text {Indent ""}} {
  # Normalize newlines
  set Normalized [string map {"\r\n" "\n" "\r" "\n"} $Text]
  set Lines [split $Normalized "\n"]

  # "" | "ul" | "ol"
  set ListKind ""
  set ParaLines {}

  proc _FlushParagraph {ResultsFile Indent ParaLinesVar} {
    upvar 1 $ParaLinesVar ParaLines
    if {[llength $ParaLines] == 0} {
      return
    }
    set Raw [join $ParaLines " "]
    set Escaped [EscapeHtml $Raw]
    set Html [FormatInlineMarkdownSubset $Escaped]
    puts $ResultsFile "${Indent}<p>${Html}</p>"
    set ParaLines {}
  }

  proc _CloseListIfOpen {ResultsFile Indent ListKindVar} {
    upvar 1 $ListKindVar ListKind
    if {$ListKind ne ""} {
      puts $ResultsFile "${Indent}</${ListKind}>"
      set ListKind ""
    }
  }

  foreach Line $Lines {
    set Line [string trimright $Line]
    set Trimmed [string trim $Line]

    if {$Trimmed eq ""} {
      _FlushParagraph $ResultsFile $Indent ParaLines
      _CloseListIfOpen $ResultsFile $Indent ListKind
      continue
    }

    # Support headings written as \##, \###, ... (workaround for YAML parsers
    # that incorrectly treat lines starting with '#' as comments inside | blocks).
    if {[regexp {^\\?(#{2,5})\s+(.+)$} $Trimmed -> Hashes Title]} {
      _FlushParagraph $ResultsFile $Indent ParaLines
      _CloseListIfOpen $ResultsFile $Indent ListKind

      set Level [string length $Hashes]
      if {$Level == 2} {
        set Tag "h3"
      } elseif {$Level == 3} {
        set Tag "h4"
      } elseif {$Level == 4} {
        set Tag "h5"
      } else {
        set Tag "h6"
      }
      set Escaped [EscapeHtml $Title]
      set Html [FormatInlineMarkdownSubset $Escaped]
      puts $ResultsFile "${Indent}<${Tag} class=\"subtitle\">${Html}</${Tag}>"
      continue
    }

    if {[string match "- *" $Trimmed]} {
      _FlushParagraph $ResultsFile $Indent ParaLines
      if {$ListKind ne "ul"} {
        _CloseListIfOpen $ResultsFile $Indent ListKind
        puts $ResultsFile "${Indent}<ul>"
        set ListKind "ul"
      }
      set Item [string range $Trimmed 2 end]
      set Escaped [EscapeHtml $Item]
      set Html [FormatInlineMarkdownSubset $Escaped]
      puts $ResultsFile "${Indent}  <li>${Html}</li>"
      continue
    }

    if {[regexp {^\d+\.\s+(.+)$} $Trimmed -> Item]} {
      _FlushParagraph $ResultsFile $Indent ParaLines
      if {$ListKind ne "ol"} {
        _CloseListIfOpen $ResultsFile $Indent ListKind
        puts $ResultsFile "${Indent}<ol>"
        set ListKind "ol"
      }
      set Escaped [EscapeHtml $Item]
      set Html [FormatInlineMarkdownSubset $Escaped]
      puts $ResultsFile "${Indent}  <li>${Html}</li>"
      continue
    }

    if {$ListKind ne ""} {
      _CloseListIfOpen $ResultsFile $Indent ListKind
    }
    lappend ParaLines $Line
  }

  _FlushParagraph $ResultsFile $Indent ParaLines
  _CloseListIfOpen $ResultsFile $Indent ListKind
}

# -------------------------------------------------
# CreateOsvvmReportHeader
#
proc CreateOsvvmReportHeader {ResultsFile ReportName {RelativePath ""} {IncludeLogo 0} } {
  
  puts $ResultsFile "<!DOCTYPE html>"
  puts $ResultsFile "<html lang=\"en\">"
  puts $ResultsFile "<head>"
  
  LinkCssFiles $ResultsFile $RelativePath
  
  puts $ResultsFile "  <title>$ReportName</title>"
  puts $ResultsFile "</head>"
  puts $ResultsFile "<body>"
  if {$IncludeLogo} {
    puts $ResultsFile "<header>"
    puts $ResultsFile "  <div class=\"summary-parent\">"
    puts $ResultsFile "    <div class=\"summary-table\">"
    puts $ResultsFile "      <h1>$ReportName</h1>"
    puts $ResultsFile "    </div>"
    
    LinkLogoFile $ResultsFile $RelativePath "requirements-logo"

    puts $ResultsFile "  </div>"
    puts $ResultsFile "</header>"
  } else {
    puts $ResultsFile "<header>"
    puts $ResultsFile "  <h1>$ReportName</h1>"
    puts $ResultsFile "</header>"
  }
  puts $ResultsFile "<main>"
}

# -------------------------------------------------
# CreateOsvvmReportFooter
#
proc CreateOsvvmReportFooter {ResultsFile} {
  puts $ResultsFile "</main>"
  puts $ResultsFile "<footer>"
  puts $ResultsFile "  <hr />"
  # ::osvvm::OsvvmVersion is appropriate here.  The two versions should match.
	puts $ResultsFile "  <p class=\"generated-by-osvvm\">Generated by OSVVM-Scripts ${::osvvm::OsvvmVersion} on [clock format [clock seconds] -format {%Y-%m-%d - %H:%M:%S (%Z)}].</p>"
  puts $ResultsFile "</footer>"
  puts $ResultsFile "</body>"
  puts $ResultsFile "</html>"
}

# -------------------------------------------------
# FindHtmlThemeFiles
#
# proc FindHtmlThemeFiles {BaseDirectory CssTargetSubdirectory} {
#   variable Report2CssFiles
#   variable Report2PngFile
#   
#   # Note files are linked into the HTML in glob order (alphabetical but may be OS dependent WRT upper case)
#   set CssFiles [glob -nocomplain [file join ${BaseDirectory} ${CssTargetSubdirectory} *.css]]
#   set Report2CssFiles ""
#   if {$CssFiles ne ""} {
#     foreach CssFileWithPath ${CssFiles} {
#       set CssFile [file join $CssTargetSubdirectory [file tail $CssFileWithPath]]
#       lappend Report2CssFiles $CssFile
#     }
#   }
#   
#   # There should only be one *.png file.
#   set PngFiles [glob -nocomplain [file join ${BaseDirectory} ${CssTargetSubdirectory} *.png]]
#   set Report2PngFile ""
#   if {$PngFiles ne ""} {
#     foreach PngFileWithPath ${PngFiles} {
#       set PngDestFile [file join $CssTargetSubdirectory [file tail $PngFileWithPath]]
#     }
#   }
#   # There should be only one PNG file, so only copy the last one we find.
# #  file copy -force ${PngFileWithPath} [file join $BaseDirectory $CssTargetSubdirectory $PngFile]
#   set Report2PngFile $PngDestFile
# }

# -------------------------------------------------
# LinkCssFiles
#
proc LinkCssFiles {ResultsFile {RelativePath ""}} {
  variable Report2CssFiles
  
  # Note files are linked into the HTML in glob order (alphabetical but may be OS dependent WRT upper case)
  if {$Report2CssFiles ne ""} {
    foreach CssFile ${Report2CssFiles} {
      puts $ResultsFile "  <link rel=\"stylesheet\" href=\"[file join $RelativePath $CssFile]\">"
    }
  }
}

# -------------------------------------------------
# LinkLogoFile
#
proc LinkLogoFile {ResultsFile {RelativePath ""} {LogoClass "summary-logo"}} {
  variable Report2PngFile
  
  puts $ResultsFile "    <div class=\"$LogoClass\">"
	puts $ResultsFile "    	 <img id=\"logo\" src=\"[file join $RelativePath $Report2PngFile]\" alt=\"OSVVM logo\">"
  puts $ResultsFile "    </div>"
}

# -------------------------------------------------
# GetOsvvmPathSettings
#
proc GetOsvvmPathSettings {TestDict} {
  set SettingsInfoDict                         [dict get $TestDict OsvvmSettingsInfo]
  variable ::osvvm::Report2BaseDirectory                [dict get $SettingsInfoDict BaseDirectory]
  variable ::osvvm::Report2ReportsSubdirectory          [dict get $SettingsInfoDict ReportsSubdirectory]
#  variable Report2HtmlThemeSubdirectory              [dict get $SettingsInfoDict HtmlThemeSubdirectory]
  variable ::osvvm::Report2SimulationLogFile            [dict get $SettingsInfoDict SimulationLogFile]
  variable ::osvvm::Report2SimulationHtmlLogFile        [dict get $SettingsInfoDict SimulationHtmlLogFile]
  variable ::osvvm::Report2RequirementsSubdirectory     [dict get $SettingsInfoDict RequirementsSubdirectory]
  variable ::osvvm::Report2CoverageSubdirectory         [dict get $SettingsInfoDict CoverageSubdirectory]
  variable ::osvvm::Report2CssFiles                     [dict get $SettingsInfoDict Report2CssFiles]
  variable ::osvvm::Report2PngFile                      [dict get $SettingsInfoDict Report2PngFile]
}

# -------------------------------------------------
# SumAlertCount
#
# Used by multiple report generators.
if {![llength [info commands SumAlertCount]]} {
  proc SumAlertCount {AlertCountDict} {
    return [expr [dict get $AlertCountDict Failure] + [dict get $AlertCountDict Error] + [dict get $AlertCountDict Warning]]
  }
}

# -------------------------------------------------
# GetTestCaseSettings
#
proc GetTestCaseSettings {SettingsFileName} {
  set TestDict  [::yaml::yaml2dict -file ${SettingsFileName}]
  variable ::osvvm::Report2TestCaseName                 [dict get $TestDict TestCaseName        ]
  variable ::osvvm::Report2TestCaseFile                 [dict get $TestDict TestCaseFile        ]
  variable ::osvvm::Report2TestSuiteName                [dict get $TestDict TestSuiteName       ]
  variable ::osvvm::Report2BuildName                    [dict get $TestDict BuildName           ]
  variable ::osvvm::Report2GenericDict                  [dict get $TestDict Generics            ]
  
  variable ::osvvm::Report2TestCaseFileName             [dict get $TestDict TestCaseFileName    ]
  variable ::osvvm::Report2GenericNames                 [dict get $TestDict GenericNames        ]
  
  variable ::osvvm::Report2TestSuiteDirectory           [dict get $TestDict ReportsTestSuiteDirectory  ]
  variable ::osvvm::Report2RequirementsYamlFile         [dict get $TestDict RequirementsYamlFile]
  variable ::osvvm::Report2AlertYamlFile                [dict get $TestDict AlertYamlFile       ]
  variable ::osvvm::Report2CovYamlFile                  [dict get $TestDict CovYamlFile         ]
  variable ::osvvm::Report2ScoreboardDict               [dict get $TestDict ScoreboardDict      ]
  variable ::osvvm::Report2TranscriptFiles              [dict get $TestDict TranscriptFiles     ]

  variable ::osvvm::Report2TestCaseHtml [file join $Report2TestSuiteDirectory ${Report2TestCaseFileName}.html]

  # Optional fields (older run.yml files may not have these)
  if {[dict exists $TestDict ElapsedTime]} {
    variable ::osvvm::Report2TestCaseElapsedTime [dict get $TestDict ElapsedTime]
  }
  
  GetOsvvmPathSettings $TestDict
  
  variable ::osvvm::Report2ReportsDirectory             [file normalize [file join $::osvvm::Report2BaseDirectory $::osvvm::Report2ReportsSubdirectory $::osvvm::Report2TestSuiteName]]
}


