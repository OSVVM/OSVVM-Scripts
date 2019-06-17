#  File Name:         StartUp.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          STANDARD VERSION
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
