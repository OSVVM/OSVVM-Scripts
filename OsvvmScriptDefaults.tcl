#  File Name:         OsvvmScriptDefaults.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#    Sets the defaults for the OSVVM Scripts
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
#    02/2022   2022.02    Added call to SetTranscriptType to make HTML the default transcript
#     2/2021   2021.02    Refactored Default Settings from StartUp.tcl
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

# SetVHDLVersion:   Set compile/simulate version.   
# OSVVM requires 2008 or newer
# Accepted parameters:  1993, 2002, 2008, 2019
# OSVVM Usage:  test 2019 features

SetVHDLVersion [expr {[info exists ::osvvm::DefaultVHDLVersion] ? $::osvvm::DefaultVHDLVersion : 2008 }]

# VHDL Simulation time units - Simulator is started with this value
SetSimulatorResolution  ps

# Setup the Library Directory.  Use one of the following.
# SetLibraryDirectory C:/tools/sim_temp    ; # Create library directory in C:/tools/sim_temp
SetLibraryDirectory                      ; # Create library directory in current run directory
# LinkLibraryDirectory                     ; # Make libraries visible

SetTranscriptType html 