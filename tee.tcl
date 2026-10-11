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
    # Map an unknown subcommand of `tee` to `tee replace`.
    #  command    - The ensemble command, `tee`.
    #  subcommand - The unknown subcommand: the channel to duplicate.
    #  args       - The remaining arguments: the file.
    #
    # Makes `tee <channel> <file>` a short form of `tee replace <channel> <file>`.
    #
    # Returns the command prefix to call instead.
    return [list $command replace $subcommand]
}

proc tee::channel {chan fd} {
    # Duplicate the output written to a channel into another channel.
    #  chan - Channel to duplicate, for example `stdout`.
    #  fd   - Open channel receiving a copy of the output.
    #
    # Pushes the channel transformation `transchan` onto $chan.
    #
    # Returns $fd.
    chan push $chan [list [namespace which transchan] $fd]
    return $fd
}

proc tee::replace {chan file} {
    # Duplicate the output written to a channel into a file, replacing the file.
    #  chan - Channel to duplicate, for example `stdout`.
    #  file - Path of the file; overwritten.
    #
    # Returns the channel of the opened file.
    return [channel $chan [open $file w]]
}

proc tee::append {chan file} {
    # Duplicate the output written to a channel into a file, appending to the file.
    #  chan - Channel to duplicate, for example `stdout`.
    #  file - Path of the file; appended to.
    #
    # Returns the channel of the opened file.
    return [channel $chan [open $file a]]
}

proc tee::initialize {fd handle mode} {
    # Initialize the channel transformation.
    #  fd     - Channel receiving the copy.
    #  handle - Handle of the transformed channel.
    #  mode   - Access mode of the transformed channel.
    #
    # Returns the subcommands the transformation implements.
    variable methods
    return $methods
}

proc tee::finalize {fd handle} {
    # Close the channel receiving the copy when the transformation is removed.
    #  fd     - Channel receiving the copy.
    #  handle - Handle of the transformed channel.
    if {$fd in [chan names]} {
        close $fd
    }
}

proc tee::write {fd handle buffer} {
    # Copy written data into the receiving channel.
    #  fd     - Channel receiving the copy.
    #  handle - Handle of the transformed channel.
    #  buffer - Data written to the transformed channel.
    #
    # The copy has NUL characters removed and carriage-return line-feed pairs replaced by line feeds.
    #
    # Returns $buffer unchanged, so the transformed channel receives the original data.

#    puts -nonewline $fd $buffer
    # Remove Null and change crcrlf to crlf
    puts -nonewline $fd [regsub -all \r\n [regsub -all \x00 $buffer ""] \n]
#    return [regsub -all {<[^>]*>} $buffer ""]  ;# this works for ModelSim batch but not GHDL
    return $buffer
}
