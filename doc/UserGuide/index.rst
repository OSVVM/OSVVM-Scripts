.. _UG:

User Guide
##########

OSVVM-Scripts is an API layer on top of Tcl. It runs the same project scripts on many simulators: it compiles
(analyzes) VHDL and Verilog files into libraries, runs simulations, collects the results of test suites and test cases,
and creates reports. For most projects, no Tcl beyond the OSVVM commands is needed; Tcl is there if more is needed.

This guide explains how to write and run OSVVM scripts. Each command used here links to its description in the
:doc:`TCL Command Reference </osvvm-scripts/osvvm>`. To install OSVVM and run the first demo, see :ref:`QSG`; the
reports OSVVM creates are described in :ref:`RPT`.

.. grid:: 2

   .. grid-item::
      :columns: 6

      **A first script**

      Scripts are named :file:`<script-name>.pro`. A script activates a library, analyzes the design and the
      testbench into it, and simulates the testbench:

      * :ref:`RUFF/osvvm/library` makes a library the active library and creates it, if it doesn't exist.
      * :ref:`RUFF/osvvm/analyze` compiles a file into the active library.
      * :ref:`RUFF/osvvm/simulate` elaborates and runs a design unit of the active library.
      * :ref:`RUFF/osvvm/include` runs another script from a script.
      * :ref:`RUFF/osvvm/build` runs a script from the simulator's console and records everything in a log file and
        reports.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: RunExample.pro
         TestSuite Example
         library   ExampleLib
         analyze   Dut.vhd
         analyze   TbExample.vhd
         simulate  TbExample

      Run it from the simulator's console, after starting OSVVM-Scripts:

      .. code-block:: tcl

         build ../RunExample.pro

.. admonition:: Naming style

   Commands are case sensitive. Single word names are all lower case (:ref:`RUFF/osvvm/analyze`); multiple word names
   are CamelCase (:ref:`RUFF/osvvm/SetVHDLVersion`).

   In this guide, ``[...]`` in a code example is Tcl's command substitution and must be written as shown:
   ``simulate Tb [generic WIDTH 8]``.

.. toctree::
   :maxdepth: 2

   Concepts
   Scripts
   Libraries
   Simulation
   Options
   Debugging
   CodeCoverage
   Requirements
   Configuration
