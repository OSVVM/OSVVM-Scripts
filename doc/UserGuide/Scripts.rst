.. _UG/Scripts:

Writing Scripts
###############

OSVVM scripts are Tcl files named :file:`<script-name>.pro`, augmented by the OSVVM commands. The examples below come
from the scripts of OSVVM's own verification components.

.. _UG/Scripts/SimpleTest:

Running a Simple Test
*********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Running a simulation means: select the library, analyze the files, start the simulation.

      * :ref:`RUFF/osvvm/library` activates a library, like VHDL's working library. Every following
        :ref:`RUFF/osvvm/analyze` and :ref:`RUFF/osvvm/simulate` uses it.
      * :ref:`RUFF/osvvm/analyze` compiles a file. The extension selects the language: :file:`*.vhd` and
        :file:`*.vhdl` are VHDL; :file:`*.v`, :file:`*.sv` and :file:`*.vh` are Verilog / SystemVerilog.
      * :ref:`RUFF/osvvm/TestName` names the test case; :ref:`RUFF/osvvm/simulate` runs it.

      The files have no paths: relative paths are relative to the directory of the script
      (:ref:`UG/Concepts/CurrentWorkingDirectory`).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: testbench_MultipleMemory.pro
         library  osvvm_TbAxi4_MultipleMemory
         analyze  TestCtrl_e.vhd
         analyze  TbAxi4_MultipleMemory.vhd
         analyze  TbAxi4_Shared1.vhd
         TestName TbAxi4_Shared1
         simulate TbAxi4_Shared1

      .. code-block:: tcl

         build ../OsvvmLibraries/AXI4/Axi4/testbench_MultipleMemory/testbench_MultipleMemory.pro

.. _UG/Scripts/RunTest:

RunTest
=======

.. grid:: 2

   .. grid-item::
      :columns: 6

      When a test case's file, design unit and test name are the same, :ref:`RUFF/osvvm/RunTest` does
      :ref:`RUFF/osvvm/analyze`, :ref:`RUFF/osvvm/TestName` and :ref:`RUFF/osvvm/simulate` in one command.

      An optional second argument names the design unit to simulate, if it differs from the file name; the test case
      is then named ``<DesignUnit>(<FileName>)``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # Same as: analyze TbAxi4_Shared1.vhd
         #          TestName TbAxi4_Shared1
         #          simulate TbAxi4_Shared1
         RunTest TbAxi4_Shared1.vhd

.. _UG/Scripts/Including:

Including Scripts
*****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Designs are built hierarchically, and so are scripts: a script calls the scripts of its parts with
      :ref:`RUFF/osvvm/include`. Paths are relative to the including script; :file:`OsvvmLibraries.pro` names
      directories in :file:`OsvvmLibraries`.

      :ref:`RUFF/osvvm/include` accepts a file or a name without extension. For a directory or a name without
      extension, it takes the first file that exists of:

      #. :file:`<Name>.pro`
      #. :file:`build.pro` (in the directory)
      #. :file:`<Name>.tcl`
      #. :file:`<Name>.do`
      #. :file:`<Name>.dirs`, :file:`<Name>.files` (deprecated, see below)

      :file:`*.pro` and :file:`*.tcl` files are sourced, :file:`*.do` files are run with the simulator's ``do``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: OsvvmLibraries.pro
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

.. _UG/Scripts/Arguments:

Script Arguments
================

.. grid:: 2

   .. grid-item::
      :columns: 6

      Arguments after the script name of :ref:`RUFF/osvvm/include` or :ref:`RUFF/osvvm/build` are passed to the
      script in Tcl's ``argv`` / ``argc`` and in the Tcl variables ``ARGC`` (number of arguments) and ``ARGV`` (an
      array; ``ARGV(0)`` is the script name, ``ARGV(1)`` the first argument). They are restored when the script
      returns.

      Instead of arguments, consider Tcl procedures or variables set before the call.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         include ./TestCases.pro Smoke

      .. code-block:: tcl

         # File: TestCases.pro
         if {$::ARGC > 0 && $::ARGV(1) eq "Smoke"} {
           RunTest TbSmoke.vhd
         }

.. _UG/HelperFunctions:

Conditions
**********

.. grid:: 2

   .. grid-item::
      :columns: 6

      A script is Tcl, so ``if`` selects what to run. Helper commands keep the conditions short:

      * :ref:`RUFF/osvvm/DirectoryExists` and :ref:`RUFF/osvvm/FileExists` test a path relative to the working
        directory.
      * The tool variables, ``$::osvvm::ToolName`` and others, select tool specific steps (see :ref:`UG/Variables`).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         if {[FileExists TbAxi4_Optional.vhd]} {
           RunTest TbAxi4_Optional.vhd
         }

         if {$::osvvm::ToolName eq "GHDL"} {
           SkipTest TbAxi4_Verilog.vhd "Needs mixed-language simulation"
         } else {
           RunTest TbAxi4_Verilog.vhd
         }

.. _UG/Scripts/BuildingOsvvm:

Building the OSVVM Libraries
****************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :file:`OsvvmLibraries.pro` analyzes OSVVM's utility library and all verification components that are present.
      Run it with :ref:`RUFF/osvvm/build` from the simulation directory.

      The log of the build is in :file:`<BuildName>/logs/` of the simulation directory (see
      :ref:`UG/Concepts/BuildName`).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         build ../OsvvmLibraries/OsvvmLibraries.pro

.. _UG/Regression:

Running OSVVM's Test Cases
**************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Every OSVVM verification component (VC) comes with its regression tests. :file:`RunAllTests.pro` runs all tests
      of a VC, and since scripts are hierarchical, the one of a directory runs all tests below it.

      Most VCs and :file:`OsvvmLibraries` also have :file:`RunDemoTests.pro`, which runs a small selection.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # AXI4 Full
         build ../OsvvmLibraries/AXI4/Axi4/RunAllTests.pro

         # AXI4 Full, AXI4 Lite and AXI Stream
         build ../OsvvmLibraries/AXI4/RunAllTests.pro

         # All verification components
         build ../OsvvmLibraries/RunAllTests.pro

         # A selection
         build ../OsvvmLibraries/RunDemoTests.pro

.. _UG/Scripts/Deprecated:

Deprecated Descriptor Files
***************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/include` still accepts descriptor files for backward compatibility; new scripts should use
      :file:`*.pro` files.

      * :file:`<Name>.dirs` lists directories; each is passed to :ref:`RUFF/osvvm/include`.
      * :file:`<Name>.files` lists files; each is passed to :ref:`RUFF/osvvm/analyze` (VHDL or Verilog by extension).
        A line ``# library <Name>`` calls :ref:`RUFF/osvvm/library`.

      Other lines starting with ``#`` and empty lines are ignored.

   .. grid-item::
      :columns: 6

      .. code-block:: text

         # File: Axi4.dirs
         src
         testbench
