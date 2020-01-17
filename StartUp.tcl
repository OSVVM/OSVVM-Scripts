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
#    11/2018   Alpha      Project descriptors in .files and .dirs files
#     2/2019   Beta       Project descriptors in .pro which execute 
#                         as TCL scripts in conjunction with the library 
#                         procedures
#     1/2020   2020.01    Updated Licenses to Apache
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

# VHDL Simulation time units - Simulator is started with this value
set SIMULATE_TIME_UNITS        ps

# Only Set library location if it is different from the simulation directory
set LIB_BASE_DIR C:/tools/sim_temp

# Initialize flag
set OSVVM_SCRIPTS_INITIALIZED 0

# Set location for scripts
# if you use TCL "source" the following is sufficient:
set SCRIPT_DIR  [file normalize [file dirname [info script]]]
#
# If you use Mentor or Aldec "do" the following is required
# if {[info exists aldec]} {
#   set SCRIPT_DIR [file normalize [file dirname $::argv0]]
# } elseif {[string match [file rootname [file tail [info nameofexecutable]]] "vish"]} {
#   set SCRIPT_DIR [file normalize [file dirname [status file]]] 
# } else {
#   set SCRIPT_DIR  [file normalize [file dirname [info script]]]
# #  set SCRIPT_DIR  [file normalize ../Scripts]
# }


# Run Tool configuration script - detects simulator
source ${SCRIPT_DIR}/ToolConfiguration.tcl

# Run OSVVM Project build library 
source ${SCRIPT_DIR}/OsvvmProjectScripts.tcl
