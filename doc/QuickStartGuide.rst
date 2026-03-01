.. _QSG:

Quick Start Guide
#################

.. important::

   If you haven't installed OsvvmLibraries yet, please get OSVVM using one of the described methods in :ref:`INSTALL`

Create a Simulation directory
*****************************

Create a simulation directory. Generally I name this :file:`sim` or :file:`sim_vendor-name`. Creating a simulation
directory means that cleanup before running regressions is just a matter of deleting the sim directory and recreating a
new one.

The following assumes you have created a directory named :file:`sim` in the :file:`OsvvmLibraries` directory.

Alternately, you can run simulations out of the Scripts, but cleanup is a mess as a simulator tends to create numerous
temporaries.

.. todo::

   Is :file:`sim_vendor-name` still valid?

   What about :file:`temp`?


Start the Script environment in the Simulator
*********************************************

Do the actions appropriate for your simulator.

.. tab-set::

   .. tab-item:: Aldec Active-HDL
      :sync: ActiveHDL

      tbd

   .. tab-item:: Aldec Riviera-PRO
      :sync: ActiveHDL

      tbd

   .. tab-item:: GHDL
      :sync: GHDL

      tbd

   .. tab-item:: NVC
      :sync: NVC

      tbd

   .. tab-item:: Siemens EDA ModelSim
      :sync: ModelSim

      tbd

   .. tab-item:: Siemens EDA QuestaSim
      :sync: QuestaSim

      tbd



Run the Demos
*************

Run the following commands in your simulator's command line:

.. code-block::

   # analyze OSVVM's packages and verification components
   build  ../OsvvmLibraries
   # analyze and run demo tests
   build  ../OsvvmLibraries/RunDemoTests.pro

These will produce some reports, such as :file:`OsvvmLibraries_RunDemoTests.html`.

.. todo:: We will discuss these in the next section, OSVVM Reports.


Writing Scripts by Example
**************************

OSVVM Scripts are an API layer that is build on top of :term:`Tcl`. The API layer simplifies the
steps of analyzing and running simulations. For most applications you will not need any Tcl, however, it is there if you
need more capabilities.

Scripts are named in the form :file:`\<script-name\>.pro`. The scripts are Tcl code that is augmented with the OSVVM script
API. The script API is created using Tcl procedures.

.. rubric:: Basic Script Commands

:tclcode:`library <library-name>`
 Make this library the active library. Create it if it does not exist.
:tclcode:`analyze <VHDL-file>`
 Compile (aka analyze) the design into the active library.
:tclcode:`simulate <test-name>`
 Simulate (aka elaborate + run) the design using the active library.
:tclcode:`include <script-name>.pro`
 Include another project script.
:tclcode:`build <script-name>.pro`
 Start a script from the simulator. It is ``include`` + start a new log file and report for this script.

.. todo:: For more details, see Command Summary later in this document.

.. topic:: First Script

   At the heart of running a simulation is setting the library, compiling files, and starting the simulation.
   To do this, we use ``library``, ``analyze``, and vsimulate``.

   The following is an excerpt from the scripts used to run OSVVM verification component library regressions.

   .. admonition:: ``testbench_MultipleMemory.pro``

      .. code-block:: tcl

         library  osvvm_TbAxi4_MultipleMemory
         analyze  TestCtrl_e.vhd
         analyze  TbAxi4_MultipleMemory.vhd
         analyze  TbAxi4_Shared1.vhd
         TestName TbAxi4_Shared1
         simulate TbAxi4_Shared1

   In OSVVM scripting, calling ``library`` activates the library. An ``analyze`` or ``simulate`` that follows
   ``library`` uses the specified library. This is consistent with VHDL’s sense of the *working library*.

   .. note::

      Note that there are no directories to the files. For OSVVM commands that use paths, the path is always relative to
      the directory the script is located in unless an absolute path is specified.

   The above script is in :file:`testbench_MultipleMemory.pro`. It can be run by specifying:

   .. code-block:: tcl

      build ../OsvvmLibraries/AXI4/Axi4/testbench_MultipleMemory/testbench_MultipleMemory.pro

   .. hint::

      If you were to open :file:`testbench_MultipleMemory.pro`, you would find that ``RunTest`` is used instead as it is
      an abbreviation for the ``analyze``, ``TestName`` and ``simulate`` when the names are the same.


Regression.tcl
**************

.. todo::

   Show how a regression.tcl could look like assuming OSVVM is a git submodule.


