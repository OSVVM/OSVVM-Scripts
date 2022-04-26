namespace eval ::osvvm {

  set BUILD_ONCE 0
  set BUILD_ONCE_FORCE 0
  set coverFiles {}

  proc tee { outfile msg } {
    puts $outfile $msg
    echo $msg
  }

  proc start_build_once {} {
    variable BUILD_ONCE_FORCE
    variable BUILD_ONCE
    set BUILD_ONCE_FORCE 0
    set BUILD_ONCE 0
  }

  proc build_once { {Path_Or_File "."} } {
    variable BUILD_ONCE_FORCE
    variable BUILD_ONCE
    if {![info exists BUILD_ONCE_FORCE]} {
      echo "WARNING: If you use build_once, make sure to call start_build_once before EACH run!"
      start_build_once
    }
    set build_once_dmy $BUILD_ONCE
    set BUILD_ONCE 1
    build_internal $Path_Or_File
    set BUILD_ONCE $build_once_dmy
  }

  proc build {{Path_Or_File "."}} {
    variable BUILD_ONCE
    set build_once_dmy $BUILD_ONCE
    set BUILD_ONCE 0
    if {[catch {build_internal $Path_Or_File} errmsg]} {
      echo "# ** Error: $errmsg"
      echo "%% *** {\"DbAccess\": {\"Type\": \"EndTestbench\", \"Result\": \"Error\", \"Message\": \"(build_internal failed) $errmsg\"}} "
    } else {
      echo "%% *** {\"DbAccess\": {\"Type\": \"EndTestbench\", \"Result\": \"Finished\"}} "
    }
    set BUILD_ONCE $build_once_dmy
  }

  proc simulate {LibraryUnit {OptionalCommands ""}} {
    global SKIP_SIMULATION
    global TESTCASE_NAME
    if {[info exists SKIP_SIMULATION] && $SKIP_SIMULATION eq "true"} {
      echo "Skipping simulation as SKIP_SIMULATION is true."
      return
    }
    if {![info exists TESTCASE_NAME] || $TESTCASE_NAME == "" || $TESTCASE_NAME == ${LibraryUnit} } {
      set version [string trim [eval "vsim -version"]]
      set transcriptFile [transcript file]
      echo "%% *** {\"DbAccess\": {\"Type\": \"StartTestcase\", \"Name\": \"${LibraryUnit}\", \"Modelsim\": \"$version\", \"Transcript\": \"$transcriptFile\"}} "
      if {[catch {simulate_internal $LibraryUnit $OptionalCommands} errmsg]} {
        echo "'simulate_internal' failed with error. Continuing with next testcase... ($errmsg)"
        echo "%% *** {\"DbAccess\": {\"Type\": \"EndTestcase\", \"Result\": \"Error\", \"Name\": \"${LibraryUnit}\"}} "
      }
    } else {
      echo "Skipping simulate command for '$LibraryUnit' because testcase '$TESTCASE_NAME' is specified"
    }
  }

  proc simulate_simStartedCallback {LibraryUnit } {
    set logfile ${LibraryUnit}.log
    set logfile [format "%-256s" $logfile]
    change "sim:/rsim_logging/myLogfile" \"$logfile\"
    # causes crash if no signals exist, but it's so nice to have
    add log -r [env]/*
  }

  proc MustBeCompiled {library file} {
    variable BUILD_ONCE_FORCE
    variable DIR_LIB
    set lib1 ${DIR_LIB}/${library}/_vmake
    set lib2 ${DIR_LIB}/[string tolower ${library}]/_vmake
    set lib_time 0
    # Notice: It is possible that ModelSim uses all lowercase for library names. We thus simply check both variants
    if {[file exists $lib1]} {
      set lib_time  [file mtime $lib1]
    } elseif {[file exists $lib2]} {
      set lib_time  [file mtime $lib2]
    }
    set file_time [file mtime $file]
    if {[expr $lib_time < $file_time]} {
      set BUILD_ONCE_FORCE 1
    }
    return [expr ($lib_time < $file_time) || $BUILD_ONCE_FORCE]
  }

  proc analyze {FileName {OptionalCommands ""}} {
    variable BUILD_ONCE
    variable VHDL_WORKING_LIBRARY
    variable CURRENT_WORKING_DIRECTORY
    set NormFileName  [ReducePath [file join ${CURRENT_WORKING_DIRECTORY} ${FileName}]]
    if {$BUILD_ONCE && ![MustBeCompiled $VHDL_WORKING_LIBRARY ${NormFileName}]} {
      echo "$NormFileName does not need a recompile"
      return
    }
    analyze_internal $FileName $OptionalCommands
  }

  # args is a list of filenames for which output shall be generated
  # just save a dictionary of [name => {files}] for later use
  proc cover { args } {
    variable coverFiles
    foreach f $args {
      lappend coverFiles $f
    }
  }

  proc get_cover_files { ucdb files } {
    package require struct::set
    set output [vcover report -code s -details $ucdb]
    set matches [regexp -all -inline {File ([^\s]*)} $output]
    set ret ""
    foreach {g0 g1} $matches {
      set f [file normalize $g1]
      foreach x $files {
        if { [string match *$x $f] == 1} {
          struct::set include ret $f
        } 
      }
    }
    return $ret
  }

  proc cover_reportCallback { ucdb } {
    variable coverFiles
    set vcover_help [eval vcover report -help]
    if {[string first "-annotate" $vcover_help] == -1} {
      # Version 10.7b: Does support "-file", does not support "-annotate, -output"
      set vcover_version old
    } else {
      # Version 2021.2: Does NOT support "-file", DOES support "-annotate, -output"
      set vcover_version new
    }

    set files [get_cover_files $ucdb $coverFiles]
    if {[llength $files] == 0} {
      return
    }
        
    echo "%% "
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo "%%       CODE-COVERAGE        %%"
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    foreach f $files {
      set fname [file tail $f]
      set reportFile ${::osvvm::CoverageDirectory}/$fname.annotated.cov 
      echo "mfe: $reportFile for $f"
      if {$vcover_version eq "old"} {
        echo "vcover report -file $reportFile -source $f -details $ucdb"
              vcover report -file $reportFile -source $f -details $ucdb
      } else {
        echo "vcover report -annotate -output $reportFile -source $f -details $ucdb"
              vcover report -annotate -output $reportFile -source $f -details $ucdb
      }

      set line [exec awk "c&&!--c;/\\/$fname\$/{c=5}" $reportFile]
      # remove empty entries from the splitted fields
      set fields [lsearch -all -inline -not -exact [split $line " "] {} ] 
      set active  [lindex $fields 1]
      set hits    [lindex $fields 2]
      set misses  [lindex $fields 3]
      set covered [lindex $fields 4]
      set result [format "%50s:   %7s%% (covered)     %5s (active)     %5s (hits)     %5s (misses)" $fname $covered $active $hits $misses]
      echo "%% $result"
      echo "%% *** {\"DbAccess\": {\"Type\": \"Cover\", \"Name\": \"$fname\", \"Hits\": $hits, \"Misses\": $misses, \"Target\": \"tb\", \"Annotated\": \"$reportFile\"}} "
    }
  }

  proc analyze_ip {FileName} {
    # This is the full path to the quartus binary. Set by make.sh
    global QUARTUS_PATH
    # Set by make.sh
    global RECREATE_IP
    # This variable is needed by the ip-file compile scripts
    global QSYS_SIMDIR
    # We need to store all IP releated libraries, because we need to refresh them before simulation...
    global ALL_IP_LIBS
    # <path>/bin/quartus. We want <path>
    set qsys [file dirname [file dirname $QUARTUS_PATH] ]
    set qsys [append qsys "/sopc_builder/bin/qsys-generate"]
    set ip_root [file rootname $FileName]
    if {![file exists $qsys]} {
      error "** Error: Cannot find $qsys, which is needed to (re-)generate IP files"
    }
    if {![file exists $FileName]} {
      error "** Error: Cannot find $FileName"
    }
    echo "Found $qsys for generating IP files."

    # Generate the IP if necessary.
    set noCompile 0
    if {![file exists $ip_root] || ![file exists "$ip_root/sim/mentor"] || $RECREATE_IP == "true"} {
      # Re-Generate the IP if the corresponding folder does not exist.
      # If we don't redirect stderr, the command execution throws an exception, even though everything works fine...
      set cmd "$qsys $FileName --simulation=VHDL --simulator=MODELSIM 2>/dev/null"
      echo "<vsim-cmd>: $cmd"
      if {[catch {exec {*}$cmd} errmsg]} {
        echo "# ** Error: $qsys failed: $errmsg"
        error "IP generation failed."
      } else {
        echo "# ** Info: Successfully generated $FileName"
      }
    } else {
      echo "# ** Info: Folder $ip_root\[/sim/mentor\] exists. Skipping GENERATION and COMPILATION of $FileName"
      set noCompile 1
    }

    # Now call the respective scripts and compile everything
    echo "# ** Compiling $FileName **"
    if {[info exists QSYS_SIMDIR]} {
      set QSYS_SIMDIR_OLD $QSYS_SIMDIR
    } else {
      set QSYS_SIMDIR_OLD ""
    }
    set FORCE_MODELSIM_AE_SELECTION "true"
    set QSYS_SIMDIR [file normalize "$ip_root/sim"]
    source "$ip_root/sim/mentor/msim_setup.tcl"
    # $design_libraries is defined in the msim_setup.tcl file and contains all relevant libs
    set ALL_IP_LIBS [dict merge $ALL_IP_LIBS $design_libraries]
    if {$noCompile == 0} {
      com
      echo "# ** Done compiling $FileName **"
    }
    set QSYS_SIMDIR $QSYS_SIMDIR_OLD
  }

  proc simulate_beforeSimStartedCallback {LibraryUnit} {
    global ALL_IP_LIBS
    echo "harr"
    if {[dict size $ALL_IP_LIBS] > 0} {
      echo "# ** Info: Found IP-Generated libraries. Refreshing them to avoid '(vsim-13) recompile A because B has changed' errors"
      foreach item [dict keys $ALL_IP_LIBS] {
        set cmd "vlog -work ./libraries/$item/ -refresh -force_refresh"
        eval $cmd
        set cmd "vcom -work ./libraries/$item/ -refresh -force_refresh"
        eval $cmd
      }
    }
  }

  proc simulate_getCustomSimArgs {LibraryUnit} {
    # 3155: The FLI is not enabled in this version of ModelSim
    # 8617: Vopt is not able to fully evaluate one or more expressions involving conditional generate statements in the design [...]
    # 151: The function ieee.TO_INTEGER[unsigned RETURN natural] in the packages ieee.numeric_bit and ieee.numeric_std internally accumulates its result in a NATURAL variable. [...]
    set suppress "-suppress 3155,8617,151"
    set libs "-libverbose -L altera_ver -L fourteennm_ver -L fourteennm_hssi_ver -L fourteennm -L fourteennm_hssi"
    set others "-accessobjdebug"
    set wlf "-wlf ${::osvvm::OutputDirectory}vsim.wlf"
    return " $suppress $libs $others $wlf "
  }

  namespace export start_build_once
  namespace export build_once
  namespace export analyze
  namespace export simulate
  namespace export analyze_ip
  
}