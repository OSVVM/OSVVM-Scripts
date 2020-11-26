#  File Name:         ToolConfiguration.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
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
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#     1/2020   2020.01    Updated Licenses to Apache
#     7/2020   2020.07    Refactored tool execution for simpler vendor customization
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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


  if {$ToolExecutableName eq "riviera" || $ToolExecutableName eq "vsimsa"} {
    # RivieraPro or its console
#    echo RivieraPRO
    set simulator              "RivieraPRO"
    set ToolNameVersion ${simulator}-[asimVersion]
    echo $ToolNameVersion
    source ${SCRIPT_DIR}/VendorScripts_RivieraPro.tcl
    
  } elseif {[string match $ToolExecutableName "VSimSA"]} {
    set simulator              "VSimSA"
    set ToolNameVersion ${simulator}-[lindex [split $version] [llength $version]-1]
    echo $ToolNameVersion
    source ${SCRIPT_DIR}/VendorScripts_VSimSA.tcl
    
  } else {
    # ActiveHDL or its console 
    set simulator              "ActiveHDL"
    set ToolNameVersion ${simulator}-${version}
    echo $ToolNameVersion
    source ${SCRIPT_DIR}/VendorScripts_ActiveHDL.tcl
    
  }
} elseif {[string match $ToolExecutableName "vish"]} {
  # Mentor settings
  # echo Mentor
  quietly set ToolType    "simulator"
  quietly set ToolVendor  "Mentor"
  #  set ToolVersion $vish_version
  if {[lindex [split [vsim -version]] 0] eq "Questa"} {
    quietly set simulator   "QuestaSim"
  } else {
    quietly set simulator   "ModelSim"
  }
  quietly set ToolNameVersion ${simulator}-[vsimVersion]
  echo $ToolNameVersion
  source ${SCRIPT_DIR}/VendorScripts_Mentor.tcl
  
} else {
  puts GHDL 
  set simulator  "GHDL"
  set ToolVendor "GHDL"
#  set ghdl "C:/Tools/ghdl/bin/ghdl.exe"
  set ghdl "ghdl"
  # required for mintty
  set console "/dev/pty0"
  set ToolNameVersion "GHDL-v0.37.0-1063-gc5b094bb-2020-1023"
  source ${SCRIPT_DIR}/VendorScripts_GHDL.tcl
  
}




