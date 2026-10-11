.. _UG/Debugging:

Debugging
#########

By default, OSVVM scripts are set up to run regressions fast. Debugging information, logged signals and waveforms
slow simulations down, so they are off. And if a simulation fails, the build goes on with the next one.

All settings below are booleans: ``true`` or ``false``. Called without an argument, a ``Set*`` command means ``true``.

.. _UG/Debugging/DebugMode:

Debug Mode
**********

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetDebugMode` adds the simulator's debugging options to analyze and simulate, so signals and
      variables can be inspected. The default is ``false``. :ref:`RUFF/osvvm/GetDebugMode` returns the setting.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetDebugMode true

.. _UG/Debugging/LogSignals:

Logging Signal Values
*********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetLogSignals` logs the values of signals during the simulation, so they can be displayed in the
      simulator's waveform viewer after it finished. The default is ``false``. :ref:`RUFF/osvvm/GetLogSignals` returns
      the setting.

      For GHDL and NVC, which have no waveform viewer, see :ref:`UG/Waveform/SaveWaves`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetLogSignals true

.. _UG/Debugging/StopOnError:

Stop on Errors
**************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The variables ``AnalyzeErrorStopCount`` and ``SimulateErrorStopCount`` decide when a build stops: after that
      many :ref:`RUFF/osvvm/analyze` or :ref:`RUFF/osvvm/simulate` errors. ``0``, the default, means never; the build
      runs to its end.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # Stop at the first error
         set ::osvvm::AnalyzeErrorStopCount  1
         set ::osvvm::SimulateErrorStopCount 1

.. _UG/Debugging/Interactive:

Interactive Mode
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetInteractiveMode` does all of the above in one step:

      * the error stop counts become ``1``; switching back restores their previous values;
      * debug mode and signal logging follow the interactive mode, unless :ref:`RUFF/osvvm/SetDebugMode` or
        :ref:`RUFF/osvvm/SetLogSignals` set them explicitly.

      In interactive mode, a build doesn't exit the simulator even if the setting ``ExitOnBuildDone`` is ``true``, and
      with the setting ``OpenBuildHtmlFile`` it opens the build report when it finishes.
      :ref:`RUFF/osvvm/GetInteractiveMode` returns the setting.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetInteractiveMode
         build ../RunExample.pro

         SetInteractiveMode false

.. seealso::

   :ref:`UG/Config/Override`
     To change OSVVM's defaults for all builds, set them in the settings files.
   :ref:`UG/Config/HookFiles`
     Scripts that run automatically with every simulation, for example to display waveforms.
