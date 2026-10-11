.. _SIM:

Simulator Specifics
###################

OSVVM-Scripts runs the same :term:`build scripts <build script>` on many simulators. A :term:`vendor script`
translates OSVVM's commands into each simulator's commands; this page shows what differs between them. How to start
OSVVM in each simulator is shown in the :ref:`Quick Start Guide <QSG/Start>`.

.. rubric:: Supported simulators, by vendor (alphabetical)

.. grid:: 6

   .. grid-item-card:: Aldec
      :columns: 2

      * :ref:`SIM/Aldec/ActiveHDL`
      * :ref:`SIM/Aldec/RivieraPRO`

   .. grid-item-card:: AMD (Xilinx)
      :columns: 2

      * :ref:`SIM/AMD/XSIM`

   .. grid-item-card:: Cadence
      :columns: 2

      * :ref:`SIM/Cadence/Xcelium`

   .. grid-item-card:: Metrics
      :columns: 2

      * :ref:`SIM/Metrics/DSim`

   .. grid-item-card:: Open-Source
      :columns: 2

      * :ref:`SIM/OpenSource/GHDL`
      * :ref:`SIM/OpenSource/NVC`

   .. grid-item-card:: Siemens EDA
      :columns: 2

      * :ref:`SIM/Siemens/ModelSim`
      * :ref:`SIM/Siemens/Questa`
      * :ref:`SIM/Siemens/Visualizer`

   .. grid-item-card:: Synopsys
      :columns: 2

      * :ref:`SIM/Synopsys/VCS`


.. _SIM/Overview:

Overview
********

The vendor script's name, :file:`VendorScripts_<ScriptBaseName>.tcl`, also names the simulator's
:term:`settings file` :file:`OsvvmSettingsLocal_<ScriptBaseName>.tcl` (see :ref:`UG/Configuration`).

.. list-table::
   :header-rows: 1
   :widths: 16 18 14 14 14 12 12

   * - Simulator
     - Start-up script
     - ``ScriptBaseName``
     - :term:`Code coverage`
     - Wave files (:ref:`RUFF/osvvm/DoWaves`)
     - Save waves (:ref:`RUFF/osvvm/SetSaveWaves`)
     - Elaborate and run options
   * - Active-HDL
     - :file:`StartUp.tcl`
     - ``ActiveHDL``
     - yes, export UCDB XML
     - yes
     - -
     - -
   * - DSim
     - :file:`StartDSim.tcl`
     - ``DSim``
     - -
     - -
     - -
     - -
   * - GHDL
     - :file:`StartGHDL.tcl`
     - ``GHDL``
     - -
     - -
     - yes
     - yes
   * - ModelSim
     - :file:`StartUp.tcl`
     - ``Siemens``
     - yes, export coverage report XML
     - yes
     - -
     - -
   * - NVC
     - :file:`StartNVC.tcl`
     - ``NVC``
     - yes, export Cobertura XML
     - -
     - yes
     - yes
   * - Questa
     - :file:`StartUp.tcl`
     - ``Questa`` or ``Siemens``
     - yes, export coverage report XML
     - yes
     - -
     - -
   * - Riviera-PRO
     - :file:`StartUp.tcl`
     - ``RivieraPro``
     - yes, export UCDB XML
     - yes
     - -
     - -
   * - VCS
     - :file:`StartVCS.tcl`
     - ``VCS``
     - -
     - -
     - -
     - yes
   * - Visualizer
     - :file:`StartUp.tcl`
     - ``Questa``
     - yes, export coverage report XML
     - yes
     - -
     - -
   * - Xcelium
     - :file:`StartXcelium.tcl`
     - ``Xcelium``
     - -
     - -
     - -
     - yes
   * - XSIM
     - :file:`StartXSIM.tcl`
     - ``Xsim``
     - -
     - -
     - -
     - -

* Code coverage: :ref:`UG/CodeCoverage`; the export: :ref:`UG/CodeCoverage/Export`.
* Wave files and saving waves: :ref:`UG/Waveform`.
* Elaborate and run options (:ref:`RUFF/osvvm/SetExtendedElaborateOptions`, :ref:`RUFF/osvvm/SetExtendedRunOptions`):
  only simulators, which elaborate and run in separate steps, use them (see :ref:`UG/Options`).
* A second top-level design unit (:ref:`UG/Simulation/SecondTopLevel`) is supported by the Aldec and Siemens simulators,
  DSim and XSIM.


.. _SIM/Aldec:

Aldec
*****

.. _SIM/Aldec/ActiveHDL:

Active-HDL
==========

* Vendor script :file:`VendorScripts_ActiveHDL.tcl`; Active-HDL's console runs macros by default, switch it to Tcl
  first (see :ref:`QSG/Start`).
* VSimSA, Active-HDL's command line simulator, uses :file:`StartActiveVSimSA.tcl` and
  :file:`VendorScripts_VSimSA.tcl`. :file:`VendorScripts_ASim.tcl` runs Active-HDL from a Tcl shell; it's selected with
  the environment variable ``OSVVM_TOOL`` only.
* Code coverage is collected at analysis and at simulation; it's exported as UCDB XML (``acdb2xml``).

.. _SIM/Aldec/RivieraPRO:

Riviera-PRO
===========

* Vendor script :file:`VendorScripts_RivieraPro.tcl`.
* Code coverage is collected at analysis and at simulation; it's exported as UCDB XML (``acdb2xml``).


.. _SIM/AMD:

AMD (Xilinx)
************

.. _SIM/AMD/XSIM:

XSIM
====

* Vendor script :file:`VendorScripts_Xsim.tcl`, started in Vivado's Tcl console.
* Support is under development: OSVVM's utility library analyzes, but OSVVM's own test cases don't pass yet.
* :file:`VendorScripts_Vivado.tcl` uses Vivado's synthesis: it analyzes only.


.. _SIM/Cadence:

Cadence
*******

.. _SIM/Cadence/Xcelium:

Xcelium
=======

* Vendor script :file:`VendorScripts_Xcelium.tcl`, run in :program:`tclsh`.
* Elaborates and runs in separate steps: :ref:`RUFF/osvvm/SetExtendedElaborateOptions` and
  :ref:`RUFF/osvvm/SetExtendedRunOptions` apply.


.. _SIM/Metrics:

Metrics
*******

.. _SIM/Metrics/DSim:

DSim
====

* Vendor script :file:`VendorScripts_DSim.tcl`.
* Analysis fails in the current vendor script; the Quick Start Guide shows only how to start OSVVM.


.. _SIM/OpenSource:

Open-Source
***********

.. _SIM/OpenSource/GHDL:

GHDL
====

* Vendor script :file:`VendorScripts_GHDL.tcl`, run in :program:`tclsh`; on Windows in an MSYS2 shell.
* Elaborates and runs in separate steps: :ref:`RUFF/osvvm/SetExtendedElaborateOptions` and
  :ref:`RUFF/osvvm/SetExtendedRunOptions` apply.
* Runs in batch mode; :ref:`RUFF/osvvm/SetSaveWaves` writes a waveform file for a viewer like :term:`GTKWave` or
  :term:`Surfer`.
* No code coverage yet.

.. _SIM/OpenSource/NVC:

NVC
===

* Vendor script :file:`VendorScripts_NVC.tcl`, run in NVC's own Tcl shell or in :program:`tclsh`.
* Elaborates and runs in separate steps: :ref:`RUFF/osvvm/SetExtendedElaborateOptions` and
  :ref:`RUFF/osvvm/SetExtendedRunOptions` apply. The run options default to ``--exit-severity=failure``.
* Runs in batch mode; :ref:`RUFF/osvvm/SetSaveWaves` writes a waveform file for a viewer like :term:`GTKWave` or
  :term:`Surfer`.
* Code coverage is instrumented at elaboration (:ref:`RUFF/osvvm/SetCoverageElaborateOptions`); further NVC options
  via ``NvcExtendedCoverageOptions`` (see :ref:`UG/CodeCoverage/NVC`). It's exported as :term:`Cobertura XML`.


.. _SIM/Siemens:

Siemens EDA
***********

.. _SIM/Siemens/ModelSim:

ModelSim
========

* Vendor script :file:`VendorScripts_Siemens.tcl`.
* Code coverage is collected at analysis and at simulation; it's exported as coverage report XML
  (``vcover report -xml``).

.. _SIM/Siemens/Questa:

Questa
======

* :file:`StartUp.tcl` selects :file:`VendorScripts_Questa.tcl`, if the command ``qsim`` exists, else
  :file:`VendorScripts_Siemens.tcl`; :file:`StartQuesta.tcl` always selects :file:`VendorScripts_Siemens.tcl`.
* Code coverage is collected at analysis and at simulation; it's exported as coverage report XML
  (``vcover report -xml``).
* :ref:`RUFF/osvvm/SetExtendedOptimizeOptions` applies to Questa's separate optimization step.

.. _SIM/Siemens/Visualizer:

Visualizer
==========

* :file:`StartVisualizer.tcl` selects :file:`VendorScripts_Questa.tcl`; :file:`VendorScripts_Visualizer.tcl` is
  selected with the environment variable ``OSVVM_TOOL`` only.
* Code coverage as with Questa.


.. _SIM/Synopsys:

Synopsys
********

.. _SIM/Synopsys/VCS:

VCS
===

* Vendor script :file:`VendorScripts_VCS.tcl`, run in :program:`tclsh`.
* Elaborates and runs in separate steps: :ref:`RUFF/osvvm/SetExtendedElaborateOptions` and
  :ref:`RUFF/osvvm/SetExtendedRunOptions` apply.
