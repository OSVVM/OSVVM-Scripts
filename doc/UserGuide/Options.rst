.. _UG/Options:

Analyze and Simulate Options
############################

Options are set with ``Set*`` commands and read with the matching ``Get*`` commands. A setting stays until it's set
again, so options for a whole project are best set once, at a high level: in a top-level script or in the settings
files (:ref:`UG/Config/Override`). Most option values are simulator specific; keep them out of the scripts that should
run on every simulator.

.. _UG/Options/Language:

Language and Time
*****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      * :ref:`RUFF/osvvm/SetVHDLVersion` sets the VHDL version for :ref:`RUFF/osvvm/analyze`: ``2008`` (default),
        ``2019``, ``2002`` or ``1993`` (also as ``08``, ``19``, ``02``, ``93``). OSVVM's libraries require 2008 or
        newer. :ref:`RUFF/osvvm/GetVHDLVersion` returns it.
      * :ref:`RUFF/osvvm/SetSimulatorResolution` sets the simulator's time resolution, in the simulator's format
        (default ``ps``). :ref:`RUFF/osvvm/GetSimulatorResolution` returns it.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetVHDLVersion 2019
         SetSimulatorResolution ps

         puts "VHDL-[GetVHDLVersion]"

.. _UG/Options/Analyze:

Analyze Options
***************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Options passed to the simulator when it analyzes a file:

      * :ref:`RUFF/osvvm/SetVhdlAnalyzeOptions` for VHDL files only, :ref:`RUFF/osvvm/SetVerilogAnalyzeOptions` for
        Verilog files only.
      * :ref:`RUFF/osvvm/SetExtendedAnalyzeOptions` for both.

      All three are empty by default.

      Options given to a single :ref:`RUFF/osvvm/analyze` call apply to that file only.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         if {$::osvvm::ToolVendor eq "Siemens"} {
           SetExtendedAnalyzeOptions "-quiet"
         }

.. _UG/Options/Simulate:

Simulate Options
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetExtendedSimulateOptions` sets additional options of the user for every
      :ref:`RUFF/osvvm/simulate`. Options given to a single :ref:`RUFF/osvvm/simulate` call apply to that simulation
      only.

      Simulators with separate steps have options per step:

      * :ref:`RUFF/osvvm/SetExtendedOptimizeOptions`: the optimization step of Questa.
      * :ref:`RUFF/osvvm/SetExtendedElaborateOptions` and :ref:`RUFF/osvvm/SetExtendedRunOptions`: the elaboration and
        run steps of GHDL, NVC, VCS and Xcelium.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         if {$::osvvm::ToolVendor eq "Siemens"} {
           SetExtendedSimulateOptions "-quiet"
         }

      .. tab-set::

         .. tab-item:: GHDL
            :sync: GHDL

            .. code-block:: tcl

               SetExtendedRunOptions "--ieee-asserts=disable-at-0"

         .. tab-item:: NVC
            :sync: NVC

            .. code-block:: tcl

               SetExtendedElaborateOptions "-O1"
               SetExtendedRunOptions       "--exit-severity=error"

            NVC's vendor script presets the run options to ``--exit-severity=failure``; a new value replaces it.

.. _UG/Options/Transcript:

Transcript
**********

.. grid:: 2

   .. grid-item::
      :columns: 6

      A build always writes a text log file. :ref:`RUFF/osvvm/SetTranscriptType` selects whether an HTML version is
      created too: ``html`` (default) or ``log``. :ref:`RUFF/osvvm/GetTranscriptType` returns the setting.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetTranscriptType log
