.. _UG:

User Guide
##########

Overview
********

.. todo::

   anaylze
   simulate

   build
     testsuite
       testcase

   context

Concepts
========

.. _UG/Concepts/CurrentSimulationDirectory:

CurrentSimulationDirectory
--------------------------

.. todo:: explain :file:`CurrentSimulationDirectory`


.. admonition:: Naming Style

   Commands are case sensitive. |br|
   Single word names are all lower case. |br|
   Multiple word names are CamelCase.


Basic Commands
**************

* build
* TestSuite
* library
* analyze
* simulate
* TestName
* RunTest

build
=====

Build is a layer on top of include (it calls include) that creates a logging point.
In general, build is called from the simulator API (when we run something)
and include is called from scripts.

By default, OSVVM creates collects all tool output for a build into
an html based log file in ./logs/<tool_name>-<version>/<script-name>.html.

To compile all of the OSVVM libraries, use build as shown below.

.. code-block:: tcl

   build ../OsvvmLibraries/OsvvmLibraries.pro

 Build sets the tcl variables $::ARGC and $::ARGV (an array).

VHDL Library Handling
*********************

:ref:`RUFF/osvvm/SetLibraryDirectory`
:ref:`RUFF/osvvm/SetLibraryDirectory`
  sdbsbfs dfvdfvggdy
:tclcode:`SetLibraryDirectory [LibraryDirectory]`
  - Set the directory in which the libraries will be created to ``LibraryDirectory``.
  - If ``LibraryDirectory`` is not specified, use the ``CurrentSimulationDirectory``.
  - By default, libraries are created in :file:`<LibraryDirectory>/VHDL_LIBS/<tool version>/`.
:tclcode:`GetLibraryDirectory`
   - Get the Library Directory.
:tclcode:`library <LibraryName> [<path>]`
   - Make LibraryName found in library directory specified by path the active library.
   - Create the LibraryName if it does not exist.
   - If path is not specified, use the library directory specified by SetLibraryDirectory.
:tclcode:`LinkLibrary <library> [<path>]`
   - Create a mapping to a library that is in the library directory specified by path.
   - If path is not specified, use the library directory specified by SetLibraryDirectory.
:tclcode:`LinkLibraryDirectory [LibraryDirectory]`
   - Map all of the libraries in the specified ``LibraryDirectory``.
     If ``LibraryDirectory`` is not specified, use the library directory specified by SetLibraryDirectory.
:tclcode:`LinkCurrentLibraries`
   - If you use ``cd``, then use LinkCurrentLibraries immediately after
     to map all current visible libraries to the new CurrentSimulationDirectory.
:tclcode:`RemoveLibrary LibraryName [<path>]`
   - Remove the named library.
     Path is only used to find and delete libraries that have not been mapped in OSVVM.
:tclcode:`RemoveLibraryDirectory [<path>]`
   - Remove the Library specified in path.
   - If path is not specified, the library directory specified by SetLibraryDirectory is used.
:tclcode:`RemoveAllLibraries`
   - Call RemoveLibraryDirectory on all library directories known to OSVVM.

Discouraged Tcl Commands
************************

Tcl's **source** / EDA Tool's **do**
====================================

.. caution::

   Do not use Tcl's ``source``!
   Do not use Tcl's EDA tool's ``do``!

OSVVM uses :ref:`RUFF/osvvm/include` since it helps manage the path of where the script files are located. Include uses
Tcl's ``source`` internally. However, if you use Tcl's ``source`` (or EDA tool's ``do``) instead, you will not get
include's directory management features and your scripts will need to manage the directory paths themselves.

Tcl's **cd**
============

.. caution::

   Do not use Tcl's ``cd``

Simulators create files containing library mappings and other information in the simulation directory. If you use ``cd``
you lose all of this information. OSVVM tracks the simulation directory in the ``::osvvm::CurrentSimulationDirectory``
variable.

OSVVM tracks the directory in which scripts run as ``CurrentWorkingDirectory``. All OSVVM API commands run relative to
``CurrentWorkingDirectory``. When you call a script in another directory using :ref:`RUFF/osvvm/include`,
``CurrentWorkingDirectory`` is automatically updated to be the directory that contains the script. When
:ref:`RUFF/osvvm/include` finishes it restores ``CurrentWorkingDirectory`` to be its value before
:ref:`RUFF/osvvm/include` was called.

If while running a script, you need to adjust the ``CurrentWorkingDirectory``, use :ref:`RUFF/osvvm/ChangeWorkingDirectory`.
Like ``cd``, :ref:`RUFF/osvvm/ChangeWorkingDirectory` allows either relative or absolute paths.

.. code-block:: tcl

   ChangeWorkingDirectory src
   analyze Axi4Manager.vhd

If you need to determine a path relative to the ``CurrentWorkingDirectory``, use :ref:`RUFF/osvvm/JoinWorkingDirectory`.
In the following, the relative path used by :ref:`RUFF/osvvm/LinkLibraryDirectory` is:

.. code-block:: tcl

   LinkLibraryDirectory [JoinWorkingDirectory RelativePath]


Structuring Project Files
*************************

Including Scripts
=================

We build our designs hierarchically.
Therefore our scripts need to be build hierarchically.
When one script calls another script, such as OsvvmLibraries.pro does, we use include.
The code for OsvvmLibraries.pro is as follows.
The ``if`` is Tcl and is only building the UART, AXI4, and DpRam if
their corresponding directories exist.

.. code-block:: tcl

   include ./osvvm/osvvm.pro
   include ./Common

   if {[DirectoryExists UART]} {
     include ./UART
   }
   if {[DirectoryExists AXI4]} {
     include ./AXI4
   }
   if {[DirectoryExists DpRam]} {
     include ./DpRam
   }

Note the paths specified to include are relative to OsvvmLibriaries
directory since that is where OsvvmLibraries.pro is located.  Note
that the includes above only specify directory names.   When this
happens, include looks for a file of the name build.pro or naming
pattern <DirectoryName>.pro.

Include sets the tcl variables $::ARGC and $::ARGV (an array).
Rather than using these it is recommended to use tcl procedures.


Conditions in Project Files
***************************

.. _UG/Variables:

Prefedined Variables
********************

.. _UG/HelperFunctions:

Helper Functions
****************

.. _UG/Generics:

Simulating with Generics
************************

To specify generics in a :ref:`RUFF/osvvm/simulate` or :ref:`RUFF/osvvm/RunTest` call, use the OSVVM's
:ref:`RUFF/osvvm/generic` function. Generic takes two parameters: the name of the generic and its value. It is applied
as shown below:

.. code-block:: tcl

   simulate Tb_xMii1 [generic MII_INTERFACE MII]  [generic MII_BPS BPS_10M]
   RunTest Tb_xMii1.vhd [generic MII_INTERFACE RGMII] [generic MII_BPS BPS_1G]

Calling generic this way allows OSVVM to set generics using the method required by each simulator.

.. hint::

   Note the square brackets are required and tell Tcl to call the function to create the arguments for
   :ref:`RUFF/osvvm/simulate` or :ref:`RUFF/osvvm/RunTest`.

.. versionchanged:: Release 2022.09 removed the necessity to put quotes around the options specified with simulate.

.. _UG/Waveform:

Waveforms
*********

Adding other Wave Files
=======================

To include wave files with names different from above, use the :ref:`RUFF/osvvm/DoWaves` function. DoWaves is called in
the call to :ref:`RUFF/osvvm/simulate` as shown below.

.. code-block:: tcl

   library  default
   simulate Tb [DoWaves wave1.do]
   simulate Tb [DoWaves wave1.do wave2.do]

If the :file:`wave1.do` file is not in :file:`CurrentSimulationDirectory`, then it will need path information.

In Aldec and Siemens, these are run via the simulator command line (via ``-do``).

.. caution::

   The method of running them may change in the future (and may use ``source``).

.. hint::

   Note the square brackets are required and tell Tcl to call the function to create the arguments for
   :ref:`RUFF/osvvm/simulate` or :ref:`RUFF/osvvm/RunTest`.

Saving Waveforms with GHDL and NVC
==================================

The open source simulators GHDL and NVC run in a batch mode, but can save waveforms to see with a separate waveform
viewer like :term:`Gtkwave` or :term:`Surfer`. To save waveforms for GHDL and NVC, call :ref:`RUFF/osvvm/SetSaveWaves`.

If you do not call :ref:`RUFF/osvvm/SetSaveWaves`, the *debug mode* is false. If you call :ref:`RUFF/osvvm/SetSaveWaves`
without a ``true`` or ``false`` value, the default is ``true``.

.. code-block:: tcl

   SetSaveWaves
   SetSaveWaves true


.. _UG/CodeCoverage:

Code Coverage
*************

Code coverage is a metric that tells us if certain parts of our design
have been exercised or not.  Turning on code coverage with OSVVM is simple.
In the following example, we enable coverage options during analysis and
simulation separately.

.. code-block:: tcl

   # File name:  Dut.pro
   SetCoverageAnalyzeEnable true
   analyze   Dut.vhd
   SetCoverageAnalyzeEnable false
   SetCoverageSimulateEnable true
   analyze   TbDut.vhd
   simulate  TbDut
   SetCoverageSimulateEnable false

Note that CoverageAnalyzeEnable is specifically turned off
before compiling the testbench so that the testbench is not
included in the coverage metrics.

You can also set specific options by using SetCoverageAnalyzeOptions
and SetCoverageSimulateOptions.  By default, OSVVM sets these options
so that statement, branch, and statemachine coverage is collected.

When coverage is turned on for a build, coverage is collected for each test.
If there are multiple test suites in the build,
when a test suite completes execution,
the coverage for each test in the test suite is merged.
When a build completes the coverage from each test suite
is merged and an html coverage report is produced.


.. _UG/Debugging:

Debugging
*********

By default, OSVVM's scripting focuses on running regressions fast. Adding debugging information, logging signals, and/or
displaying waveforms will slow things down. In addition, by default, if one simulation crashes, the scripts will
continue and run the next simulation.

Debug Mode
==========

To add debugging information to your simulation, call :ref:`RUFF/osvvm/SetDebugMode`. If you do not call
:ref:`RUFF/osvvm/SetDebugMode`, the debug mode is false. If you call :ref:`RUFF/osvvm/SetDebugMode` without a ``true``
or ``false`` value, the default is true.

.. code-block:: tcl

   SetDebugMode true

Stop on Error
=============

Whether :ref:`RUFF/osvvm/analyze` or :ref:`RUFF/osvvm/simulate` (also :ref:`RUFF/osvvm/RunTest`) stop on a failure or
not is controlled by the internal variables ``AnalyzeErrorStopCount`` and ``SimulateErrorStopCount``. By default, these
variables are set to 0, which means do not stop. Setting them to a non-zero value, causes either
:ref:`RUFF/osvvm/analyze` or :ref:`RUFF/osvvm/simulate` to stop when the specified number of errors occur. Hence, to
stop after one error, set them as follows:

 .. code-block:: tcl

   set ::osvvm::AnalyzeErrorStopCount  1
   set ::osvvm::SimulateErrorStopCount 1

Logging Signal Values (for later display)
=========================================

To log signals so they can be displayed after the simulation finishes, call :ref:`RUFF/osvvm/SetLogSignals`. If you do
not call :ref:`RUFF/osvvm/SetLogSignals`, the log signals mode is false. If you call :ref:`RUFF/osvvm/SetLogSignals`
without a ``true`` or ``false`` value, the default is true.

.. code-block:: tcl

   SetLogSignals true


Interactive Mode
================

To do all of the above in one step, call :ref:`RUFF/osvvm/SetInteractiveMode`. If you call
:ref:`RUFF/osvvm/SetInteractiveMode` without a ``true`` or ``false`` value, the default is true.

.. seealso::

   :ref:`UG/Config/Override`
     If you do not like the OSVVM default settings, you can add any of these to your :file:`LocalScriptDefaults.tcl`.
   :ref:`UG/Config/HookFiles`
     Also note that there are scripts that automatically run when you call a :ref:`RUFF/osvvm/simulate` or
     :ref:`RUFF/osvvm/RunTest` command. |br|
     You can use these scripts to display waveforms.


.. _UG/Configuration:

Configuration
*************

.. _UG/Config/Override:

Override OSVVM Script Defaults
==============================




.. _UG/Config/HookFiles:

Hook Files
==========

.. #Scripts that Run during Simulate if they exist
   ----------------------------------------------------

Often with simulations, we want to add a custom waveform file. This may be for all designs or just one particular
design. We may also need specific actions to be done when running on a particular simulator.

When :ref:`RUFF/osvvm/simulate` (or :ref:`RUFF/osvvm/RunTest`) is called, it will source the following files in order,
if they exist:

1.  :file:`\<ToolVendor\>.tcl`
2.  :file:`\<ToolName\>.tcl`
3.  :file:`wave.do`
4.  :file:`\<LibraryUnit\>.tcl`
5.  :file:`\<LibraryUnit\>_\<ToolName\>.tcl`
6.  :file:`\<TestCaseName\>.tcl`
7.  :file:`\<TestCaseName\>_\<ToolName\>.tcl`

:ToolVendor:   is e.g. ``Aldec``, ``Cadence``, ``Siemens``, ``Synopsys``, ...
:ToolName:     is e.g. ``ActiveHDL``, ``ModelSim``, ``QuestaSim``, ``RivieraPRO``, ``VCS``, ``Xcelium``, ...
:LibraryUnit:  is the name specified to simulate.
:TestCaseName: is the name specified to :ref:`RUFF/osvvm/TestName`.

.. seealso::

   * :ref:`UG/Variables`

.. attention::

   Note that :file:`wave.do` will not run if you are running in a batch environment (such as ``vsim -c`` in QuestaSim).

It will search for these files in the following directories:

- :file:`OsvvmLibraries/Scripts`
- :file:`CurrentSimulationDirectory`
- :file:`CurrentWorkingDirectory`

:CurrentSimulationDirectory: is the normalized path for the directory in which the simulator is running.
:CurrentWorkingDirectory:    is the relative path to the directory of the script that is currently running.

.. note::

   Currently NVC and GHDL do not run any extra scripts since they are batch simulators.

   .. todo:: Recheck NVC, as it has an embedded TCL environment.

.. _UG/Regression:

Regression Testing OSVVM
************************

All OSVVM verification components (VCs) are delivered with their own regression test suite. There is also a
script, named :file:`RunAllTests.pro`, that runs all of the tests for that specific VC.

To run the AXI4 Full verification component regression suite, use the :ref:`RUFF/osvvm/build` shown below.

.. code-block:: tcl

   cd <path-to-OsvvmLibraries>/temp
   build ../OsvvmLibraries/AXI4/Axi4/RunAllTests.pro

Everything in OSVVM is composed hierarchically. If you want to run all AXI4 (Axi4 Full, Axi4Lite, and AxiStream),
use the :ref:`RUFF/osvvm/build` shown below.

.. code-block:: tcl

   cd <path-to-OsvvmLibraries>/temp
   build ../OsvvmLibraries/AXI4/RunAllTests.pro

Similarly to run the tests for all VC in :file:`OsvvmLibraries` use the build shown below.

.. code-block:: tcl

   cd <path-to-OsvvmLibraries>/temp
   build ../OsvvmLibraries/RunAllTests.pro

.. hint::

   For most VC and OsvvmLibraries, there is a :file:`RunDemoTests.pro` that runs a small selection of the VC test cases.

   .. code-block:: tcl

      cd <path-to-OsvvmLibraries>/temp
      build ../OsvvmLibraries/RunDemoTests.pro
