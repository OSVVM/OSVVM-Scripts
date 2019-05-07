#  File Name:         ToolConfiguration.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    ToolConfiguration.tcl provides custom settings for  
#    the different simulators supported by the OSVVM  
#    simulator scripting methodology.
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
#    11/2019   Alpha      Project descriptors in .files and .dirs files
#    2/2019:   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
# 
# 
#  Copyright (c) 2018-2019 by SynthWorks Design Inc.  All rights reserved.
# 
#  Verbatim copies of this source file may be used and 
#  distributed without restriction.   
# 								 
#  This source file is free software; you can redistribute it  
#  and/or modify it under the terms of the ARTISTIC License 
#  as published by The Perl Foundation; either version 2.0 of 
#  the License, or (at your option) any later version. 						 
# 								 
#  This source is distributed in the hope that it will be 	 
#  useful, but WITHOUT ANY WARRANTY; without even the implied  
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	 
#  PURPOSE. See the Artistic License for details. 							 
# 								 
#  You should have received a copy of the license with this source.
#  If not download it from, 
#     http://www.perlfoundation.org/artistic_license_2_0
# 

# ToolNames.tcl
# variables to allow setup of tool commands

# Set time units if project settings file did not
if {![info exists SIMULATE_TIME_UNITS]} {
  set SIMULATE_TIME_UNITS ps
}

set ToolExecutable [info nameofexecutable]
# C:/Tools/questasim64_10.7/win64/vish.exe
# C:/Tools/Aldec/Active-HDL-10.5-x64/BIN/avhdl_core.exe
# C:/Tools/Aldec/Active-HDL-10.5-x64/BIN/VSimSA.exe
# C:/Tools/Aldec/Riviera-PRO-2018.02-x64/bin/riviera.exe
# C:/Tools/Aldec/Riviera-PRO-2018.02-x64/bin/vsimsa.exe - console
set ToolExecutableName [file rootname [file tail $ToolExecutable]]
set ToolBaseDir [file tail [file dirname [file dirname $ToolExecutable]]]

if {[info exists aldec]} {
  # found either RivieraPro or ActiveHDL
  
  set ToolType    "simulator"
  set ToolVendor  "Aldec"
  set ToolNameVersion [file tail $aldec]
  # C:\Tools\Aldec\Active-HDL-10.5-x64       # Both Console and Interactive
  # C:/Tools/Aldec/Riviera-PRO-2018.02-x64   # Both Console and Interactive

  set VHDL_ANALYZE_COMMAND      "vcom"
  set VHDL_ANALYZE_OPTIONS      "-2008 -dbg -relax"      
  set VHDL_ANALYZE_COVERAGE     ""
  set VHDL_ANALYZE_LIBRARY      "-work"

  set VERILOG_ANALYZE_COMMAND   "vlog"
  set VERILOG_ANALYZE_OPTIONS   ""      
  set VERILOG_ANALYZE_COVERAGE  ""
  set VERILOG_ANALYZE_LIBRARY   "-work"

  set SIMULATE_COMMAND          "vsim"
  set SIMULATE_OPTIONS_FIRST    [concat "-t " $SIMULATE_TIME_UNITS]           
  set SIMULATE_OPTIONS_LAST     ""             
  set SIMULATE_LIBRARY          "-lib"             
  set SIMULATE_COVERAGE         ""       

# Update this  
  set SIMULATE_RUN              "run -all"
  if {[string match [string index $ToolNameVersion 0] "R"]} {
    # RivieraPro or its console
    echo RivieraPRO
    set simulator              "RivieraPRO"
# Update this so it closes the old file at stop transcript    
    set START_TRANSCRIPT          "transcript file \"\" ; transcript file"
    set STOP_TRANSCRIPT           "transcript file -close \$FileName"
  
  } else {
    # ActiveHDL or its console 
    echo ActiveHDL
    set simulator              "ActiveHDL"
  }
} elseif {[string match $ToolExecutableName "vish"]} {
  # Mentor settings
  # echo Mentor
  quietly set ToolType    "simulator"
  quietly set ToolVendor  "Mentor"
  #  set ToolVersion $vish_version
  quietly set ToolNameVersion $ToolBaseDir
  
  quietly set START_TRANSCRIPT          "transcript file \"\" ; transcript file"
  quietly set STOP_TRANSCRIPT           "transcript file \"\" "
  
  quietly set VHDL_ANALYZE_COMMAND      "vcom"
  quietly set VHDL_ANALYZE_OPTIONS      "-2008"      
  quietly set VHDL_ANALYZE_COVERAGE     ""
  quietly set VHDL_ANALYZE_LIBRARY      "-work"

  quietly set VERILOG_ANALYZE_COMMAND   "vlog"
  quietly set VERILOG_ANALYZE_OPTIONS   ""      
  quietly set VERILOG_ANALYZE_COVERAGE  ""
  quietly set VERILOG_ANALYZE_LIBRARY   "-work"

  quietly set SIMULATE_COMMAND          "vsim"
  quietly set SIMULATE_OPTIONS_FIRST    [concat "-t " $SIMULATE_TIME_UNITS]             
  quietly set SIMULATE_OPTIONS_LAST     "-suppress 8683 -suppress 8684 -suppress 8617"             
  quietly set SIMULATE_LIBRARY          "-lib"             
  quietly set SIMULATE_COVERAGE         ""     
  
  quietly set SIMULATE_RUN              "do Mentor.do ; add log -r /* ; run -all"
  quietly set simulator                 "Mentor"
} else {
  error "Tool Not Determined"
}




