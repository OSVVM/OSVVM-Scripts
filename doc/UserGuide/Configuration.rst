.. _UG/Configuration:

Configuration
#############

.. _UG/Config/Override:

Settings Files
**************

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM's default settings are in :file:`Scripts/OsvvmSettingsDefault.tcl`. Don't change that file; it's replaced
      with every OSVVM release. Put your settings into your own files instead, which OSVVM loads after the defaults:

      #. :file:`OsvvmSettingsLocal.tcl`: settings for all simulators.
      #. :file:`OsvvmSettingsLocal_<ScriptBaseName>.tcl`: settings for one simulator. ``<ScriptBaseName>`` is the name
         of the vendor script, :file:`VendorScripts_<ScriptBaseName>.tcl`, for example ``NVC``, ``GHDL``, ``Siemens``,
         ``Questa`` or ``RivieraPro``.

      :file:`Scripts/OsvvmSettingsLocal_example.tcl` lists all settings with their defaults; copy it to start.

      Like the defaults, the files set variables inside ``namespace eval ::osvvm``; they may also call ``Set*``
      commands.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: OsvvmSettings/OsvvmSettingsLocal.tcl
         namespace eval ::osvvm {
           variable DefaultVHDLVersion     "2019"
           variable AnalyzeErrorStopCount  1
           variable SimulateErrorStopCount 1
         }

      .. code-block:: tcl

         # File: OsvvmSettings/OsvvmSettingsLocal_Siemens.tcl
         namespace eval ::osvvm {
           SetExtendedAnalyzeOptions  "-quiet"
           SetExtendedSimulateOptions "-quiet"
         }

.. _UG/Config/SettingsDirectory:

Settings Directory
==================

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM looks for the settings files in the first of these directories:

      #. the directory named by the environment variable ``OSVVM_SETTINGS_DIR``;
      #. :file:`OsvvmSettings` next to :file:`OsvvmLibraries`, if it exists;
      #. :file:`OsvvmLibraries/Scripts`.

      A directory outside :file:`OsvvmLibraries` keeps the settings out of OSVVM's repositories and survives updates.

      The former names :file:`LocalScriptDefaults.tcl` and :file:`LocalScriptDefaults_<ScriptBaseName>.tcl` in
      :file:`Scripts` are still read, but deprecated.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`OsvvmLibraries`
           - :file:`Scripts`
             - :file:`OsvvmSettingsDefault.tcl` | OSVVM's defaults
             - :file:`OsvvmSettingsLocal_example.tcl`
         - :file:`OsvvmSettings`
           - :file:`OsvvmSettingsLocal.tcl` | yours
           - :file:`OsvvmSettingsLocal_NVC.tcl`
           - :file:`LocalCallbacks.tcl`

.. _UG/Config/Callbacks:

Callbacks
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM calls callback procedures before and after its main commands (``CallbackBefore_Build``,
      ``CallbackAfter_Analyze``, ...) and when an error occurs (``CallbackOnError_Build``, ...). Their defaults are in
      :file:`Scripts/CallbackDefaults.tcl`; don't change that file.

      To change a callback, define a procedure of the same name in :file:`LocalCallbacks.tcl` (all simulators) or
      :file:`LocalCallbacks_<ScriptBaseName>.tcl` (one simulator), in the settings directory. They are loaded after the
      defaults and replace them.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: OsvvmSettings/LocalCallbacks.tcl
         namespace eval ::osvvm {
           proc CallbackAfter_Build {Path_Or_File args} {
             puts "Build of $Path_Or_File finished."
           }
         }

.. _UG/Config/HookFiles:

Scripts that Run with Each Simulation
*************************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Often a simulation needs custom steps: a waveform file for all designs or one design, or settings for one
      simulator. When :ref:`RUFF/osvvm/simulate` (or :ref:`RUFF/osvvm/RunTest`) starts a simulation, it runs these
      files, if they exist, in this order:

      #. :file:`<ToolVendor>.tcl`
      #. :file:`<ToolName>.tcl`
      #. :file:`wave.do` (not in batch mode, for example ``vsim -c``)
      #. :file:`<LibraryUnit>.tcl`
      #. :file:`<LibraryUnit>_<ToolName>.tcl`
      #. :file:`<TestCaseName>.tcl`, if the test case name differs from the design unit
      #. :file:`<TestCaseName>_<ToolName>.tcl`, ditto

      ``<LibraryUnit>`` is the design unit given to :ref:`RUFF/osvvm/simulate`, ``<TestCaseName>`` the name set by
      :ref:`RUFF/osvvm/TestName`; for ``<ToolVendor>`` and ``<ToolName>`` see :ref:`UG/Variables`.

      OSVVM looks for them in the working directory, then in the simulation directory, then in
      :file:`OsvvmLibraries/Scripts`.

      Only the simulators with a Tcl console run them: the Aldec and Siemens simulators.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`testbench`
           - :file:`TbAxi4.pro`
           - :file:`TbAxi4.vhd`
           - :file:`TbAxi4.tcl` | with every simulation of TbAxi4
           - :file:`TbAxi4_QuestaSim.tcl` | only with QuestaSim
           - :file:`wave.do` | with every simulation started here

      .. code-block:: tcl

         # File: TbAxi4_QuestaSim.tcl
         add wave -r /TbAxi4/*

.. _UG/Variables:

Tool Variables
**************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Every vendor script sets these variables, to adapt scripts to a tool:

      ``ToolVendor``
        The tool's vendor, for example ``Aldec``, ``Siemens``, ``Cadence``, ``Synopsys``, ``Xilinx``, ``GHDL``,
        ``NVC``.
      ``ToolName``
        The tool, for example ``ActiveHDL``, ``RivieraPRO``, ``VSimSA``, ``ModelSim``, ``QuestaSim``, ``Visualizer``,
        ``VCS``, ``Xcelium``, ``XSIM``, ``GHDL``, ``NVC``.
      ``ToolType``
        ``simulator``, or ``synthesis`` for Vivado.
      ``ToolNameVersion``
        ``<ToolName>-<Version>``, for example ``NVC-1.23.0``; also the name of the library subdirectory.

      The variable ``simulator`` is the former name of ``ToolName``; it's deprecated.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         if {$::osvvm::ToolName eq "GHDL"} {
           # GHDL specific steps
         }

         if {$::osvvm::ToolVendor eq "Siemens"} {
           SetExtendedAnalyzeOptions  "-quiet"
           SetExtendedSimulateOptions "-quiet"
         }
