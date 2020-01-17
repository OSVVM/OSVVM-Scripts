#  File Name:         OsvvmCreateLibraryMapOverrideScripts.tcl
#  Purpose:           Scripts for running simulations
#  Revision:          OSVVM MODELS STANDARD VERSION
# 
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
#  Contributor(s):            
#     Jim Lewis      email:  jim@synthworks.com   
# 
#  Description
#  Used by MapLibraries to create a tool library mapping in a  
#  directory different from the initial/normal simulation 
#  directory.  
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

proc map {LibraryName {PathToLib ""}} {
  global DIR_LIB
  global VHDL_WORKING_LIBRARY

  if {![string match $PathToLib ""]} {
    # only for mapping to external existing library
    set ResolvedPathToLib $PathToLib
  } else {
    # naming pattern for project libraries
    set ResolvedPathToLib ${DIR_LIB}/${LibraryName}.lib
  }
  
  # Only map libraries that exist, 
  # if they don't exist, then they are not used by these components
  if {[file exists ${ResolvedPathToLib}]} {
    echo vmap    $LibraryName  ${ResolvedPathToLib}
    vmap         $LibraryName  ${ResolvedPathToLib}
    set VHDL_WORKING_LIBRARY  $LibraryName
  }
}


# -------------------------------------------------
# Library
#
proc library {LibraryName} {
  # only doing mapping
  map $LibraryName  
}


# -------------------------------------------------
# analyze
#
proc analyze {FileName} { 
  if {[file extension $FileName] eq ".lib"} {
    #  for handling older deprecated file format
    library [file rootname $FileName]
  }
}

# -------------------------------------------------
# Simulate
#
proc simulate {LibraryUnit {OptionalCommands ""}} {
# do nothing
}

# -------------------------------------------------
# include 
#   finds and sources a project file
#
proc include {Path_Or_File} {
  global CURRENT_WORKING_DIRECTORY
  
  echo set StartingPath ${CURRENT_WORKING_DIRECTORY} Starting Include
  set StartingPath ${CURRENT_WORKING_DIRECTORY}
  
#  set NormName [file normalize ${StartingPath}/${Path_Or_File}]
  set NormName [file join ${StartingPath} ${Path_Or_File}]
  set RootDir [file dirname $NormName]
  set NameToHandle [file tail $NormName]
  set FileExtension [file extension $NameToHandle]
  
  # Path_Of_File is a File with extension .pro, .tcl, .do, .files, .dirs
  if {[file exists $NormName] && ![file isdirectory $NormName]} {
    echo set CURRENT_WORKING_DIRECTORY ${RootDir}
    set CURRENT_WORKING_DIRECTORY ${RootDir}
    if {$FileExtension eq ".pro" || $FileExtension eq ".tcl" || $FileExtension eq ".do"} {
      echo source ${NormName} 
#      source ${NormName} 
    } elseif {$FileExtension eq ".dirs"} {
      echo Do_List ${NormName} "include"
      Do_List ${NormName} "include"
    } else { 
    #  was elseif {$FileExtension eq ".files"} 
      echo Do_List ${NormName} "analyze"
      Do_List ${NormName} "analyze"
    }
  } else {
    # Path_Of_File is directory name
    if {[file isdirectory $NormName]} {
      echo set CURRENT_WORKING_DIRECTORY ${NormName}
      set CURRENT_WORKING_DIRECTORY ${NormName}
      set FileBaseName ${NormName}/[file rootname ${NameToHandle}] 
    } else {
    # Path_Of_File is name that specifies the rootname of the file(s)
      echo set CURRENT_WORKING_DIRECTORY ${RootDir}
      set CURRENT_WORKING_DIRECTORY ${RootDir}
      set FileBaseName ${NormName}
    } 
    # Determine which if any project files exist
    set FileProName    ${FileBaseName}.pro
    set FileDirsName   ${FileBaseName}.dirs
    set FileFilesName  ${FileBaseName}.files
    set FileTclName    ${FileBaseName}.tcl
    set FileDoName     ${FileBaseName}.do

    if {[file exists ${FileProName}]} {
      echo source ${FileProName} 
      source ${FileProName} 
    } 
    # .dirs is intended to be deprecated in favor of .pro
    if {[file exists ${FileDirsName}]} {
      Do_List ${FileDirsName} "include"
    }
    # .files is intended to be deprecated in favor of .pro
    if {[file exists ${FileFilesName}]} {
      Do_List ${FileFilesName} "analyze"
    }
#    # .tcl intended for extended capability
#    if {[file exists ${FileTclName}]} {
#      echo do ${FileTclName} ${CURRENT_WORKING_DIRECTORY}
#      eval do ${FileTclName} ${CURRENT_WORKING_DIRECTORY}
#    }
#    # .do intended for extended capability
#    if {[file exists ${FileDoName}]} {
#      echo do ${FileDoName} ${CURRENT_WORKING_DIRECTORY}
#      eval do ${FileDoName} ${CURRENT_WORKING_DIRECTORY}
#    }
  } 
  echo set CURRENT_WORKING_DIRECTORY ${StartingPath} Ending Include
  set CURRENT_WORKING_DIRECTORY ${StartingPath}
}

proc build {{Path_Or_File "."}} {
  include ${Path_Or_File}
}

