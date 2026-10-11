.. _RPT/HTML:

HTML Reports
############

The HTML reports are for humans. They are linked to each other: the build summary report links each test case's
detailed report, and each detailed report links its transcripts.

Wherever a triangle precedes a text in a report, a click on it hides or reveals further information.


.. _RPT/HTML/BuildSummary:

Build Summary Report
********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The build summary report shows at a glance whether a build passed, and which test cases did not pass. It has
      three parts:

      * :ref:`RPT/HTML/BuildSummary/Status`
      * :ref:`RPT/HTML/BuildSummary/TestSuites`
      * :ref:`RPT/HTML/BuildSummary/TestCases`

      Test suites and test cases show further information, such as functional coverage and the count of disabled
      alerts.

      The report is :file:`<BuildName>/<BuildName>.html`, created by :ref:`RUFF/osvvm/CreateBuildReports` at the end of
      a :ref:`RUFF/osvvm/build`. :ref:`RUFF/osvvm/OpenBuildHtml` opens it.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         build ../OsvvmLibraries/RunDemoTests.pro
         # creates OsvvmRunDemoTests/OsvvmRunDemoTests.html
         OpenBuildHtml

.. figure:: ../../images/DemoBuildSummaryReport.png
   :name: RPT/HTML/BuildSummaryFig
   :scale: 25 %
   :align: center

   Build Summary Report


.. _RPT/HTML/BuildSummary/Status:

Build Status
============

The build status is the table at the top of the build summary report: the build's result, the counts of passed,
failed and skipped test cases, the analyze and simulate failures, the elapsed time and date, the simulator and its
version, and links to the plain text and the :ref:`HTML simulator transcript <RPT/HTML/SimTranscript>`. If code coverage
was collected, its last row links the :ref:`code coverage report <RPT/HTML/CodeCoverage>`.

.. figure:: ../../images/DemoBuildStatus.png
   :name: RPT/HTML/BuildStatusFig
   :scale: 50 %
   :align: center

   Build Status


.. _RPT/HTML/BuildSummary/TestSuites:

Test Suite Summary
==================

.. grid:: 2

   .. grid-item::
      :columns: 6

      Test cases are grouped into test suites, and a build can contain several test suites. The test suite summary
      has one row per test suite. The figure shows a build with the test suites ``Axi4Full``, ``AxiStream`` and
      ``UART``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         TestSuite Axi4Full
         ...
         TestSuite AxiStream
         ...
         TestSuite UART
         ...

      :ref:`RUFF/osvvm/TestSuite` starts a test suite.

.. figure:: ../../images/DemoTestSuiteSummary.png
   :name: RPT/HTML/TestSuiteSummaryFig
   :scale: 50 %
   :align: center

   Test Suite Summary


.. _RPT/HTML/BuildSummary/TestCases:

Test Case Summary
=================

The rest of the build summary report is a test case summary per test suite: one row per test case, with its result,
its checks and alerts, its functional coverage and a link to its :ref:`detailed report <RPT/HTML/TestCase>`. Test cases
skipped with :ref:`RUFF/osvvm/SkipTest` are listed with their reason.

.. figure:: ../../images/DemoTestCaseSummaries.png
   :name: RPT/HTML/TestCaseSummaryFig
   :scale: 50 %
   :align: center

   Test Case Summary


.. _RPT/HTML/TestCase:

Test Case Detailed Report
*************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each simulated test case gets a detailed report with:

      * :ref:`RPT/HTML/TestCase/Links`
      * :ref:`RPT/HTML/TestCase/Alerts`
      * :ref:`RPT/HTML/TestCase/Coverage`, one per coverage model
      * :ref:`RPT/HTML/TestCase/Scoreboards`
      * links to the :ref:`test case transcripts <RPT/HTML/TestCaseTranscript>` and to the test case in the
        :ref:`HTML simulator transcript <RPT/HTML/SimTranscript>`

      The report is :file:`<BuildName>/reports/<TestSuite>/<TestCaseFileName>.html`, created by
      :ref:`RUFF/osvvm/Simulate2Html` after the simulation, from the YAML files the test case wrote with
      ``EndOfTestReports``. ``<TestCaseFileName>`` is the test case name, followed by ``_<Generic>_<Value>`` for each
      generic set with :ref:`RUFF/osvvm/generic`, so each generic variant of a test case has its own report.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         TestSuite UART
         RunTest   TbUart_SendGet1.vhd
         # creates
         #   reports/UART/TbUart_SendGet1.html

         simulate  TbUart [generic Baud 115200]
         # creates
         #   reports/UART/TbUart_Baud_115200.html

.. figure:: ../../images/DemoTestCaseDetailedReport.png
   :name: RPT/HTML/TestCaseDetailedFig
   :scale: 50 %
   :align: center

   Test Case Detailed Report


.. _RPT/HTML/TestCase/Links:

Test Information Link Table
===========================

The table at the top of the detailed report links to the alert report, the functional coverage reports and the
scoreboard reports in the same file, to the test case's results in the HTML simulator transcript, and to the transcript
files the test case opened with ``TranscriptOpen``. It also lists the generics of the simulation.

.. figure:: ../../images/DemoTestCaseLinks.png
   :name: RPT/HTML/TestInfoFig
   :scale: 50 %
   :align: center

   Test Information Link Table


.. _RPT/HTML/TestCase/Alerts:

Alert Report
============

The alert report shows each ``AlertLogID`` used in the test case, with its checks and its counts of errors, failures
and warnings. Expected errors still show as ``FAILED`` in the alert report; the total error count accounts for them.
:ref:`RUFF/osvvm/Alert2Html` writes this part of the report.

.. figure:: ../../images/DemoAlertReport.png
   :name: RPT/HTML/AlertFig
   :scale: 50 %
   :align: center

   Alert Report


.. _RPT/HTML/TestCase/Coverage:

Functional Coverage Reports
===========================

The detailed report contains a functional coverage report for each coverage model of ``CoveragePkg`` used in the test
case: its bins, their goals and counts, and the coverage reached. :ref:`RUFF/osvvm/Cov2Html` writes this part. The
figure is not from the demo.

.. figure:: ../../images/CoverageReport.png
   :name: RPT/HTML/FunctionalCoverageFig
   :scale: 50 %
   :align: center

   Functional Coverage Report


.. _RPT/HTML/TestCase/Scoreboards:

Scoreboard Reports
==================

The scoreboard report has one row for each scoreboard of ``ScoreboardGenericPkg`` used in the test case: its item count,
the items checked, popped and dropped, the items still in its FIFO, and the errors found.
:ref:`RUFF/osvvm/Scoreboard2Html` writes this part.

.. figure:: ../../images/DemoScoreboardReport.png
   :name: RPT/HTML/ScoreboardFig
   :scale: 50 %
   :align: center

   Scoreboard Report


.. _RPT/HTML/TestCaseTranscript:

Test Case Transcript
********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM's transcript utility collects the output of a test case - its own messages and those of
      OSVVM's utility library - into one file. ``TranscriptOpen`` opens it; without a file name, it is
      :file:`<TestName>.log`.

      After the simulation, the scripts move the file into :file:`<BuildName>/results/<TestSuite>/` and create an HTML
      version of it with :ref:`RUFF/osvvm/Transcript2Html`. The detailed report links both.

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         TestProc : process
         begin
           SetTestName("TbUart_SendGet1") ;
           TranscriptOpen ;  -- TbUart_SendGet1.log
           . . .
           EndOfTestReports ;
           TranscriptClose ;
           std.env.stop ;
         end process TestProc ;

.. figure:: ../../images/DemoVHDLTranscript.png
   :name: RPT/HTML/TestCaseTranscriptFig
   :scale: 50 %
   :align: center

   Test Case Transcript


.. _RPT/HTML/SimTranscript:

HTML Simulator Transcript
*************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The simulator transcript of a build can be long: the OSVVM regression ``RunAllTests.pro`` writes a log file of
      84,000 lines. As plain text, it isn't browsable; as HTML, it is: each test case's output can be collapsed and
      expanded.

      The scripts always write the plain text transcript :file:`logs/<BuildName>.log`. With the transcript type ``html``
      (default), :ref:`RUFF/osvvm/Log2Osvvm` converts it into :file:`logs/<BuildName>_log.html` at the end of the
      build. :ref:`RUFF/osvvm/SetTranscriptType` selects ``html``, ``log`` (plain text only) or ``none``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # in OsvvmSettingsLocal.tcl or a script
         SetTranscriptType html    ;# default
         SetTranscriptType log     ;# plain text only
         GetTranscriptType

.. figure:: ../../images/DemoSimTranscript.png
   :name: RPT/HTML/SimTranscriptFig
   :scale: 50 %
   :align: center

   HTML Simulator Transcript


.. _RPT/HTML/CodeCoverage:

Code Coverage Report
********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      With code coverage enabled, the simulator collects code coverage for each test case. The coverage of the test
      cases is merged at the end of each test suite, and the coverage of the test suites at the end of the build.
      The simulator then writes its own HTML code coverage report, which the
      :ref:`build status <RPT/HTML/BuildSummary/Status>` links.

      Code coverage is enabled for analyze and for simulate separately, so the testbench can be left out:
      :ref:`RUFF/osvvm/SetCoverageAnalyzeEnable`, :ref:`RUFF/osvvm/SetCoverageSimulateEnable`. By default, statement,
      branch and state machine coverage is collected; :ref:`RUFF/osvvm/SetCoverageKinds` selects other kinds (see
      :ref:`UG/CodeCoverage`).

      The databases and the report are in :file:`<BuildName>/CodeCoverage/`. Their format depends on the simulator;
      NVC writes :file:`<BuildName>_code_cov/index.html`.

      Besides the HTML report, the code coverage can be exported into a well-known data format for CI tools:
      Cobertura XML for NVC, the simulator's XML for the Siemens and Aldec tools. :ref:`RUFF/osvvm/ExportCodeCoverage`
      exports the last build; :ref:`RUFF/osvvm/SetCoverageExportEnable` exports at the end of every build (see
      :ref:`UG/CodeCoverage/Export`).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File name: Dut.pro
         SetCoverageAnalyzeEnable  true
         analyze   Dut.vhd
         SetCoverageAnalyzeEnable  false

         SetCoverageSimulateEnable true
         analyze   TbDut.vhd
         simulate  TbDut
         SetCoverageSimulateEnable false

         # after the build: Cobertura XML (NVC)
         ExportCodeCoverage

.. figure:: ../../images/BuildReportWithCov.png
   :name: RPT/HTML/BuildReportWithCovFig
   :scale: 25 %
   :align: center

   Build Summary Report with a link to the code coverage report


.. _RPT/HTML/Index:

Build Index
***********

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each build is also recorded in :file:`index.yml`, in the directory that contains the build directories.
      :ref:`RUFF/osvvm/Index2Html` writes :file:`index.html` from it at the end of each build: one row per build,
      newest first, with its result and counts, linked to its build summary report.

      :ref:`RUFF/osvvm/OpenIndex` opens it.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version:    "0.1"
         Builds:
           - Name:     "OsvvmRunDemoTests"
             Directory:           "OsvvmRunDemoTests"
             Status:              "PASSED"
             Passed:              11
             Failed:              0
             Skipped:             0
             ...
