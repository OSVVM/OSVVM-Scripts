#
#  File Name:         tee.tcl
#
#  Description:
#      An easy to use version of tee for TCL
#  
#  Copyright (c) 2022 by Schelte Bron
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

namespace eval tee {
    variable methods {initialize finalize write}
    namespace ensemble create -subcommands {replace append channel} \
      -unknown [namespace current]::default
    namespace ensemble create -command transchan -parameters fd \
      -subcommands $methods
}

proc tee::default {command subcommand args} {
    return [list $command replace $subcommand]
}

proc tee::channel {chan fd} {
    chan push $chan [list [namespace which transchan] $fd]
    return $fd
}

proc tee::replace {chan file} {
    return [channel $chan [open $file w]]
}

proc tee::append {chan file} {
    return [channel $chan [open $file a]]
}

proc tee::initialize {fd handle mode} {
    variable methods
    return $methods
}

proc tee::finalize {fd handle} {
    close $fd
}

proc tee::write {fd handle buffer} {
#    puts -nonewline $fd $buffer
    # Remove Null and change crcrlf to crlf
    puts -nonewline $fd [regsub -all \r\n [regsub -all \x00 $buffer ""] \n]
#    return [regsub -all {<[^>]*>} $buffer ""]  ;# this works for ModelSim batch but not GHDL
    return $buffer
}
