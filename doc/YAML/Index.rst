.. _YAML/Index:

Build Index
###########

.. grid:: 2

   .. grid-item::
      :columns: 6

      The build index :file:`index.yml` lists every build run in a directory: one entry per build, in the order they
      ran. It lies next to the build directories, in the directory where the simulator runs (``OutputBaseDirectory``).

      OSVVM-Scripts appends an entry at the end of each :ref:`RUFF/osvvm/build`, after the build summary reports and
      the HTML transcript are created (``WriteIndexYaml``), if ``GenerateOsvvmReports`` is ``true``; the first build
      creates the file. :ref:`RUFF/osvvm/Index2Html` then writes :file:`index.html` from it - newest build first,
      linked to each build summary report (see :ref:`RPT/HTML/Index`). :ref:`RUFF/osvvm/OpenIndex` opens it.

      Deleting :file:`index.yml` starts a new index.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`sim`
           - :file:`index.yml` | build index
           - :file:`index.html` | created from it
           > :file:`OsvvmLibraries`
           > :file:`OsvvmRunDemoTests`


.. _YAML/Index/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      The values come from the build summary: the counts and the status are computed while the build summary report
      is created from the :ref:`build report <YAML/TestReport>`, not by VHDL.

      .. tree::

         - ``Version`` | format version, string; ``"0.1"`` (``OsvvmIndexYamlVersion``); written once
         - ``Builds`` | list, one entry per build
           - ``Name`` | build name (:ref:`RUFF/osvvm/BuildName`)
           - ``Directory`` | the build's directory, relative to :file:`index.yml`
           - ``Status`` | ``"PASSED"`` or ``"FAILED"``
           - ``Passed`` | passed test cases
           - ``Failed`` | failed test cases
           - ``Skipped`` | skipped test cases
           - ``Tests`` | all test cases: ``Passed`` + ``Failed`` + ``Skipped``
           - ``AnalyzeErrorCount`` | number of failed analyze steps
           - ``SimulateErrorCount`` | number of failed simulate steps
           - ``BuildErrorCode`` | ``0``, or the error code of a failed build
           - ``StartTime`` | ISO 8601 with time zone
           - ``FinishTime`` | ISO 8601 with time zone
           - ``ElapsedTime`` | seconds, 3 decimals
           - ``ToolName`` | ``ToolName``, followed by ``ToolArgs`` if set
           - ``ToolVersion`` | ``ToolVersion``
           - ``OsvvmVersion`` | ``OsvvmVersion``, like ``"2026.09"``

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version:    "0.1"
         Builds:
           - Name:     "Osvvm-Libraries_OsvvmLibraries"
             Directory:           "Osvvm-Libraries_OsvvmLibraries"
             Status:              "PASSED"
             Passed:              0
             Failed:              0
             Skipped:             0
             Tests:               0
             AnalyzeErrorCount:   0
             SimulateErrorCount:  0
             BuildErrorCode:      0
             StartTime:           "2026-10-10T16:50:45+00:00"
             FinishTime:          "2026-10-10T16:50:49+00:00"
             ElapsedTime:             4.225
             ToolName:            "NVC"
             ToolVersion:          "1.23.0"
             OsvvmVersion:         "2026.09"
           - Name:     "Osvvm-Libraries_RunAllTests"
             Directory:           "Osvvm-Libraries_RunAllTests"
             Status:              "PASSED"
             Passed:              314
             Failed:              0
             Skipped:             0
             Tests:               314
             # ...
             ElapsedTime:             99.883

      The build report names the tool ``Simulator`` and ``SimulatorVersion``; the index names it ``ToolName`` and
      ``ToolVersion``. Unlike in the build report, the times are quoted strings here.
