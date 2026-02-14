.. _UG:

User Guide
##########


Structuring Project Files
*************************




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

Adding Other Wave Files
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

Saving Waveforms With GHDL and NVC
==================================

The open source simulators GHDL and NVC run in a batch mode, but can save waveforms to see with a separate waveform
viewer like :term:`Gtkwave` or :term:`Surfer`. To save waveforms for GHDL and NVC, call :ref:`RUFF/osvvm/SetSaveWaves`.

If you do not call :ref:`RUFF/osvvm/SetSaveWaves`, the *debug mode* is false. If you call :ref:`RUFF/osvvm/SetSaveWaves`
without a ``true`` or ``false`` value, the default is ``true``.

.. code-block:: tcl

   SetSaveWaves
   SetSaveWaves true


.. _UG/Debugging:

Debugging
*********






.. _UG/Configuration:

Configuration
*************






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
