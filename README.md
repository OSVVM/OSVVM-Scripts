# The OSVVM Simulator Script Library

The OSVVM Simulator Script Library provides a simple way to create and
activate libraries, compile designs, and run simulations.

The intent of this scripting approach is to:

-   Run the same scripts on any simulator
-   Be as easy to read as a compile order list.
-   Know the directory the script is in, so it does not have to be
    passed.
-   Simplify integration of other libraries that use the same approach

This is an evolving approach. So it may change in the future. Input is
welcome.

## Clone the OSVVM-Libraries directory

Lets start by doing. The library
[OSVVM-Libraries](https://opensource.ieee.org/osvvm/OsvvmLibraries) 
contains all of the OSVVM libraries as submodules.
Download the entire OSVVM model library using git clone with the `--recursive` flag:  
``` {.bash}
$ git clone --recursive https://opensource.ieee.org/osvvm/OsvvmLibraries
```

## The Script Files

-   Startup.tcl
    -   Initializes the OSVVM simulator scripts. Sets up locations for
        scripts, libraries, and logs. It calls the other scripts to set
        up the entire environment.
-   ToolConfiguration.tcl
    -   Detects the simulator running and sets variables to specialize
        the scripts for that simulator.
-   OsvvmProjectScripts.tcl
    -   TCL procedures that do common simulator and project build tasks.
-   OsvvmCreateLibraryMapOverrideScripts.tcl
    -   Used to create a library mapping in an alternate directory
    -   Used as a means to deal with long file path names

## Create a Sim directory

Create a simulation directory. Generally I name this \"sim\" or
\"sim\_\<simulator name\>\". Creating a simulation directory means that
cleanup before running regressions is just a matter of deleting the sim
directory and recreating a new one.

The following assumes you have created a directory named \"sim\" in the
OsvvmLibraries directory.

Alternately, you can run simulations out of the Scripts, but cleanup is
a mess as a simulator tends to create numerous temporaries.

## Preparation

Edit StartUp.tcl and adjust LIB_BASE_DIR to be appropriate for your
project. LIB_BASE_DIR determines where libraries are created -- note
that OSVVM uses a separate named library for different families of
verification components. This directory can be your sim directory you
created in the previous step, however, I prefer that it goes into a
directory that is not backed up. Such as:

``` {.tcl}
set LIB_BASE_DIR C:/tools/sim_temp
```

## Initialization

The scripts need to be initialized. You can do this each time you start
a simulation by doing:

``` {.tcl}
source StartUp.tcl
```

Want to avoid doing this every time? In Aldec RivieraPro, set the
environment variable, ALDEC_STARTUPTCL to StartUp.tcl (including the
path information). Similarly in Mentor QuestaSim/ModelSim, set the
environment variable, MODELSIM_TCL to StartUp.tcl (including the path
information).

## Project Files

A project file is a script that allows the specification of basic tasks
to run a simulation:

-   library - Make this library the active library. Create it if it does
    not exist.
-   analyze - Compile the design into the active library.
-   Simulate - Simulate the design using the active library.
-   include -- include another project script
-   build -- include + start a new log file for this task

The above tasks are TCL procedures. Hence, a project file is actually a
TCL file, and when necessary, TCL can be used, however, the intent is to
keep it simple. The naming of the project file is of the form
\<Name\>.pro.

The following is an excerpt from OsvvmLibraries/AXI4/Axi4/Axi4.pro. It
first activates the library osvvm_axi4. Next it compiles all of the
files in the src directory.

``` {.tcl}
library osvvm_axi4
analyze ./src/Axi4MasterComponentPkg.vhd
analyze ./src/Axi4ResponderComponentPkg.vhd
analyze ./src/Axi4MemoryComponentPkg.vhd
analyze ./src/Axi4MonitorComponentPkg.vhd
analyze ./src/Axi4Context.vhd
analyze ./src/Axi4Master.vhd
analyze ./src/Axi4Monitor_dummy.vhd
analyze ./src/Axi4Responder_Transactor.vhd
analyze ./src/Axi4Memory.vhd
```

The following is an excerpt from
OsvvmLibraries/AXI4/Axi4/testbench/testbench.pro. It first activates the
library osvvm_TbAxi4. Next it compiles the entity for the testbench
sequencer (TestCtrl_e.vhd), the test harness (TbAxi4.vhd), and the test
architectures (TbAxi4_RandomReadWrite.vhd and TbAxi4_MemoryBurst.vhd).
Finally it simulates the test TbAxi4_MemoryBurst by calling its
configuration (which follows the test architecture in the same file).

``` {.tcl}
library osvvm_TbAxi4
analyze TestCtrl_e.vhd
analyze TbAxi4.vhd
analyze TbAxi4_RandomReadWrite.vhd
analyze TbAxi4_MemoryBurst.vhd

# simulate TbAxi4_RandomReadWrite
simulate TbAxi4_MemoryBurst
```

## Building and Running OSVVM Testbenches

To build all of the OSVVM Libraries, run the script, OsvvmLibraries.pro.
In your simulator do the following. This will make you ready to run any
of the testbenches.

``` {.tcl}
cd <OsvvmLibraries directory>/sim
build ../OsvvmLibraries.pro
```

Now lets run the AXI4 testbench by doing the following in your
simulator. You might note that the \".pro\" extension was left off. When
this is done and the last name is a directory, it looks for a file in
that directory of the form \<directory-name\>.pro -- hence here
testbench.pro.

``` {.tcl}
build ../AXI4/Axi4/testbench
```

Note in the AXI4 testbench.pro script, the test, TbAxi4_RandomreadWrite,
was not run. Lets run it now. After running the testbench.pro script,
the active library is still osvvm_TbAxi4. From the simulator command
line, you can run the TbAxi4_RandomreadWrite test by typing the
following:

``` {.tcl}
simulate TbAxi4_RandomReadWrite
```

All OSVVM verification components include a testbench. You can learn
much about how to use a model in a test by reading the testbenches. Run
the other OSVVM verification components by doing the following. ..
code-block:: tcl

``` {.tcl}
build ../AXI4/Axi4/testbench 
build ../AXI4/Axi4Lite/testbench 
build ../AXI4/AxiStream/testbench 
build ../UART/testbench
```

## Commands

| **Command**                    | **Description**                            | 
|:-------------------------------|:-------------------------------------------| 
| library \<library\>            | Make the library the active library. If    | 
|                                | the library does not exist, create it and  | 
|                                | create a mapping to it. Libraries are      | 
|                                | created either in the path specified by    | 
|                                | LIB_BASE_DIR in Scripts/StartUp.tcl.       |
|<br>||                      
| analyze \<file\>               | Compile the file. A path name specified is | 
|                                | relative to the location of the current    | 
|                                | \<file\>.pro directory location. Library   | 
|                                | is the one specified in the previous       | 
|                                | library command.                           | 
|<br>||                      
| simulate \<design-unit\>       | Start a simulation on the design unit.     | 
|                                | Often best if this is a configuration      | 
|                                | name. Library is the one specified in the  | 
|                                | previous library command.                  | 
|<br>||                      
| include \<directory\>          | Include accepts either a file or a         | 
|                                | directory.                                 | 
|<br>|| 
| include \<path\>/\<file\>      | If it is a file and its extension is .pro, | 
|                                | .tcl, or .do, the file will be sourced. If | 
|                                | it is a file and its extension is .files   | 
|                                | or .dirs it will be handled in a manner    | 
|                                | consistent with revision 1 of the scripts. | 
|<br>||                          
|                                | If it is a directory, then files whose     | 
|                                | base name matches the directory name and   | 
|                                | that have the extensions .pro, .dirs,      | 
|                                | .files, .tcl, and .do are searched for (in | 
|                                | this order) and any found will be          | 
|                                | processed as above if they exist.          | 
|<br>||                          
|                                | A path name specified is relative to the   | 
|                                | location of the current \<file\>.pro       | 
|                                | directory location.                        | 
|<br>||                      
| build \<directory\>            | Re-initializes the working directory to    | 
|                                | the script directory, opens a transcript   | 
| build \<path\>/\<file\>        | file, and calls include. A path name       | 
|                                | specified is relative to the location of   | 
|                                | the current \<file\>.pro directory         | 
|                                | location.                                  | 
|<br>||                      
| map \<library\> \[\<path\>\]   | Create a mapping to a library              | 
|<br>|| 
| RemoveAllLibraries             | Delete all of the working libraries.       | 
|<br>||                      
| MapLibraries                   | Create a mapping to libraries              | 
|<br>|| 

## Deprecated Descriptor Files

The scripts still have support for older forms of the scripts. These are
intended to be deprecated.

If you run your scripts using by just specifying the
\<DirectoryPathName\>, then you want to avoid having files of the form
\<DirectoryName\>.tcl, \<DirectoryName\>.dirs, \<DirectoryName\>.files,
and \<DirectoryName\>.sim.

\<DirectoryName\>.tcl is a tcl script file name. We abandoned pure TCL
scripting because different simulators did not provide a convenient way
to dealing with path names when the scripts were located.

\<DirectoryName\>.dirs is a directory descriptor file and and contains a
list of directories to search for other descriptor files.

\<DirectoryName\>.files is a file descriptor file and contains a list of
names that are either .vhd for vhdl, .v for Verilog or .lib for current
working library. If the file descriptor file contains a .lib, it sets
the current working library to that name without the .lib extension and
that library will be used until it is changed or the end of file is
reached. The .vhd and .v files will simply be compiled.

\<DirectoryName\>.sim is a simulation descriptor file and it contains a
list of names that are either .lib, .vhd, or no extension. The .lib and
.vhd extensions are handled in the same fashion as in a file descriptor.
If a name does not contain an extension, it is assumed to be a library
unit for simulation. Currently any text following the library unit is
passed to the simulator.

## Release History
For the release history see, [CHANGELOG.md](CHANGELOG.md)

## Participating and Project Organization 

The OSVVM project welcomes your participation with either 
issue reports or pull requests.
For details on [how to participate see](https://opensource.ieee.org/osvvm/OsvvmLibraries/-/blob/master/CONTRIBUTING.md)

You can find the project [Authors here](https://opensource.ieee.org/osvvm/OsvvmLibraries/-/blob/master/AUTHORS.md) and
[Contributors here](https://opensource.ieee.org/osvvm/OsvvmLibraries/-/blob/master/CONTRIBUTORS.md).

## More Information on OSVVM

**OSVVM Forums and Blog:**     [http://www.osvvm.org/](http://www.osvvm.org/)   
**SynthWorks OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/](http://www.synthworks.com/blog/osvvm/)    
**Gitter:** [https://gitter.im/OSVVM/Lobby](https://gitter.im/OSVVM/Lobby)  
**Documentation:** [Documentation for the OSVVM libraries can be found here](https://github.com/OSVVM/Documentation)

## Copyright and License
Copyright (C) 2006-2020 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2020 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
