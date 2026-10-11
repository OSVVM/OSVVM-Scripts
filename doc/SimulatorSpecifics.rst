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

      * Active-HDL
      * Riviera-PRO

   .. grid-item-card:: AMD (Xilinx)
      :columns: 2

      * XSIM

   .. grid-item-card:: Cadence
      :columns: 2

      * Xcelium

   .. grid-item-card:: Metrics
      :columns: 2

      * DSim

   .. grid-item-card:: Open-Source
      :columns: 2

      * GHDL
      * NVC

   .. grid-item-card:: Siemens EDA
      :columns: 2

      * ModelSim
      * Questa
      * Visualizer

   .. grid-item-card:: Synopsys
      :columns: 2

      * VCS


.. _SIM/Overview:

Overview
********

The vendor script's name, :file:`VendorScripts_<ScriptBaseName>.tcl`, also names the simulator's
:term:`settings file` :file:`OsvvmSettingsLocal_<ScriptBaseName>.tcl` (see :ref:`UG/Configuration`).

.. list-table::
   :header-rows: 1
   :widths: 11 13 11 13 9 9 9 25

   * - Simulator
     - Start-up script
     - ``ScriptBaseName``
     - :term:`Code coverage`
     - Wave files (:ref:`RUFF/osvvm/DoWaves`)
     - Save waves (:ref:`RUFF/osvvm/SetSaveWaves`)
     - Elaborate and run options
     - Notes
   * - Active-HDL
     - :file:`StartUp.tcl`
     - ``ActiveHDL``
     - yes, export UCDB XML
     - yes
     - -
     - -
     - also VSimSA (:file:`StartActiveVSimSA.tcl`)
   * - DSim
     - :file:`StartDSim.tcl`
     - ``DSim``
     - -
     - -
     - -
     - -
     - analysis fails in the vendor script
   * - GHDL
     - :file:`StartGHDL.tcl`
     - ``GHDL``
     - -
     - -
     - yes
     - yes
     - Windows: in an MSYS2 shell
   * - ModelSim
     - :file:`StartUp.tcl`
     - ``Siemens``
     - yes, export coverage report XML
     - yes
     - -
     - -
     -
   * - NVC
     - :file:`StartNVC.tcl`
     - ``NVC``
     - yes, export Cobertura XML
     - -
     - yes
     - yes
     - run options default to ``--exit-severity=failure``
   * - Questa
     - :file:`StartUp.tcl`
     - ``Questa`` or ``Siemens``
     - yes, export coverage report XML
     - yes
     - -
     - -
     - :file:`StartUp.tcl` takes ``Questa``, if ``qsim`` exists; separate optimize step
       (:ref:`RUFF/osvvm/SetExtendedOptimizeOptions`)
   * - Riviera-PRO
     - :file:`StartUp.tcl`
     - ``RivieraPro``
     - yes, export UCDB XML
     - yes
     - -
     - -
     -
   * - VCS
     - :file:`StartVCS.tcl`
     - ``VCS``
     - -
     - -
     - -
     - yes
     -
   * - Visualizer
     - :file:`StartUp.tcl`
     - ``Questa``
     - yes, export coverage report XML
     - yes
     - -
     - -
     -
   * - Xcelium
     - :file:`StartXcelium.tcl`
     - ``Xcelium``
     - -
     - -
     - -
     - yes
     -
   * - XSIM
     - :file:`StartXSIM.tcl`
     - ``Xsim``
     - -
     - -
     - -
     - -
     - under development: OSVVM's own test cases don't pass yet

* Code coverage: :ref:`UG/CodeCoverage`; the export: :ref:`UG/CodeCoverage/Export`.
* Wave files and saving waves: :ref:`UG/Waveform`.
* Elaborate and run options (:ref:`RUFF/osvvm/SetExtendedElaborateOptions`, :ref:`RUFF/osvvm/SetExtendedRunOptions`):
  only simulators, which elaborate and run in separate steps, use them (see :ref:`UG/Options`).
* A second top-level design unit (:ref:`UG/Simulation/SecondTopLevel`) is supported by the Aldec and Siemens simulators,
  DSim and XSIM.
* Start-up per simulator: :ref:`QSG/Start`.
