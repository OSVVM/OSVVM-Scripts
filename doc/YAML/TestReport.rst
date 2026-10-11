.. _YAML/TestReport:

Build Report
############

.. grid:: 2

   .. grid-item::
      :columns: 6

      The build report :file:`<BuildName>/<BuildName>.yml` records one :ref:`RUFF/osvvm/build`: its test suites, each
      test case with its status and alert counts, the build's timing, the tools and the paths of the other reports.
      It is the source of the build summary reports - HTML, JUnit XML - and of the build's entry in
      :ref:`index.yml <YAML/Index>`.

      Two writers share the file while a build runs:

      * OSVVM-Scripts writes the build, test suite and test case frame, and the build information at the end.
      * OSVVM's utility library writes each test case's results from VHDL, in ``EndOfTestReports``.

      The file starts as :file:`OsvvmRun.yml` in the temporary output directory (:file:`OsvvmTemp_<ToolName>/`); both
      writers append to it. At the end of the build, it is copied to :file:`<BuildName>/<BuildName>.yml` and deleted.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`sim`
           - :file:`OsvvmTemp_NVC`
             - :file:`OsvvmRun.yml` | while the build runs
           - :file:`OsvvmRunDemoTests`
             - :file:`OsvvmRunDemoTests.yml` | after the build
             - :file:`OsvvmRunDemoTests.html` | created from it
             - :file:`OsvvmRunDemoTests.xml` | created from it


.. _YAML/TestReport/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      The keys in the order they appear. Keys written by VHDL are marked *VHDL*, all others are written by
      OSVVM-Scripts.

      .. tree::

         - ``Version`` | format version, string; ``"0.1"`` (``OsvvmBuildYamlVersion``)
         - ``Date`` | start of the build, ISO 8601 with time zone
         - ``TestSuites`` | list; missing if the build ran no simulation
           - ``Name`` | test suite name (:ref:`RUFF/osvvm/TestSuite`)
           - ``TestCases`` | list, see :ref:`YAML/TestReport/TestCases`
           - ``ElapsedTime`` | seconds, 3 decimals
         - ``Name`` | build name (:ref:`RUFF/osvvm/BuildName`)
         - ``BuildInfo`` | mapping
           - ``StartTime`` | ISO 8601 with time zone
           - ``FinishTime`` | ISO 8601 with time zone
           - ``ElapsedTime`` | seconds, 3 decimals
           - ``Simulator`` | ``ToolName``, followed by ``ToolArgs`` if set
           - ``SimulatorVersion`` | ``ToolVersion``
           - ``OsvvmVersion`` | ``OsvvmVersion``, like ``"2026.09"``
           - ``BuildErrorCode`` | ``0``, or the error code of a failed build
           - ``AnalyzeErrorCount`` | number of failed analyze steps
           - ``SimulateErrorCount`` | number of failed simulate steps
         - ``OsvvmSettingsInfo`` | paths relative to the build directory, see :ref:`YAML/TestReport/Settings`

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version: "0.1"
         Date: 2026-10-10T16:50:50+00:00
         TestSuites:
           - Name: StreamTransactionPkg
             TestCases:
               - TestCaseName: "TbStream_SendGet1"
                 # ... see Test Cases
             ElapsedTime: 1.608
         Name:     "Osvvm-Libraries_RunAllTests"
         BuildInfo:
           StartTime:            2026-10-10T16:50:50+00:00
           FinishTime:           2026-10-10T16:52:30+00:00
           ElapsedTime:              99.883
           Simulator:            "NVC"
           SimulatorVersion:     "1.23.0"
           OsvvmVersion:         "2026.09"
           BuildErrorCode:       0
           AnalyzeErrorCount:    0
           SimulateErrorCount:   0
         OsvvmSettingsInfo:
           # ... see Settings

      The order follows the build: ``Version`` and ``Date`` come from ``StartBuildYaml`` at its start, the test
      suites while it runs, ``Name``, ``BuildInfo`` and ``OsvvmSettingsInfo`` from ``FinishBuildYaml`` at its end.


.. _YAML/TestReport/TestCases:

Test Cases
**********

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each :ref:`RUFF/osvvm/simulate` adds one entry to its test suite's ``TestCases``. OSVVM-Scripts writes
      ``TestCaseName`` before the simulation starts (``StartSimulateBuildYaml``); during the simulation,
      ``EndOfTestReports`` appends the results from VHDL; after it, OSVVM-Scripts appends the file name, generics and
      time (``FinishSimulateBuildYaml``).

      .. tree::

         - ``TestCaseName`` | test case name: :ref:`RUFF/osvvm/TestName`, else the simulated design unit
         - ``FunctionalCoverage`` | *VHDL*; percentage with 2 decimals, or ``""`` without functional coverage
         - ``SimulationTime`` | *VHDL*; simulation time at the end, like ``"2690000000 fs"``
         - ``Name`` | *VHDL*; name of the test given to ``SetTestName``
         - ``Status`` | *VHDL*; see :ref:`YAML/TestReport/Status`
         - ``Results`` | *VHDL*; flow mapping
           - ``TotalErrors`` | errors that fail the test
           - ``AlertCount`` | ``Failure``, ``Error``, ``Warning``
           - ``PassedCount`` | passed affirmations
           - ``AffirmCount`` | all affirmations
           - ``RequirementsPassed`` | requirements that reached their goal
           - ``RequirementsGoal`` | requirements with a goal
           - ``DisabledAlertCount`` | ``Failure``, ``Error``, ``Warning`` of disabled alerts
           - ``ExpectedCount`` | ``Failure``, ``Error``, ``Warning`` that were expected
           - ``ExternalErrors`` | ``Failure``, ``Error``, ``Warning`` given to ``EndOfTestReports``
         - ``TestCaseFileName`` | base name of the test case's files: ``TestCaseName`` plus the generics
         - ``Generics`` | mapping name → value (:ref:`RUFF/osvvm/generic`), or ``null``
         - ``ElapsedTime`` | seconds, 3 decimals
         - ``ExpectedResults`` | optional, :ref:`RUFF/osvvm/ExpectedStatus`
           - ``Status`` | expected status
           - ``TotalErrors`` | sum of the expected alert counts
           - ``AlertCount`` | ``Failure``, ``Error``, ``Warning``
         - ``KnownStatus`` | optional, :ref:`RUFF/osvvm/KnownStatus`
         - ``Reason`` | with ``ExpectedResults``, ``KnownStatus``, or a skipped or failed analysis

      ``Name`` and ``TestCaseName`` should be equal; if they differ, the test case fails, unless
      ``FailOnVhdlNameNotMatchTestName`` is ``false``.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         - TestCaseName: "TbStream_SendGet1"
           FunctionalCoverage: 100.00
           SimulationTime: "2690000000 fs"
           Name: "TbStream_SendGet1"
           Status: "PASSED"
           Results: {TotalErrors: 0, AlertCount: {Failure: 0, Error: 0, Warning: 0},
             PassedCount: 1294, AffirmCount: 1296, RequirementsPassed: 0, RequirementsGoal: 0,
             DisabledAlertCount: {Failure: 0, Error: 0, Warning: 0},
             ExpectedCount: {Failure: 0, Error: 2, Warning: 0},
             ExternalErrors: {Failure: 0, Error: 0, Warning: 0}}
           TestCaseFileName: "TbStream_SendGet1"
           Generics:           null
           ElapsedTime: 0.317

      With generics, ``TestCaseFileName`` gets their names and values:

      .. code-block:: yaml

         - TestCaseName: "Tb_xMii1"
           # ...
           TestCaseFileName: "Tb_xMii1_MII_INTERFACE_RGMII_MII_BPS_BPS_1G"
           Generics:
             MII_INTERFACE: "RGMII"
             MII_BPS: "BPS_1G"
           ElapsedTime: 0.193

      A test case skipped with :ref:`RUFF/osvvm/SkipTest`, or whose analysis failed, has no VHDL part:

      .. code-block:: yaml

         - TestCaseName: TbUart_Scoreboard1
           Name: TbUart_Scoreboard1
           Status: "SKIPPED"
           Results: null
           Reason: "Not supported by this simulator"
           ElapsedTime: 0

      The VHDL ``Results`` are written in one line; they are wrapped here.


.. _YAML/TestReport/Status:

Status
======

.. grid:: 2

   .. grid-item::
      :columns: 6

      .. list-table::
         :header-rows: 1
         :widths: 30 20 50

         * - ``Status``
           - Written by
           - Meaning
         * - ``PASSED``
           - VHDL
           - no errors, at least one check
         * - ``FAILED``
           - VHDL
           - errors (``TotalErrors`` > 0)
         * - ``NOCHECKS``
           - VHDL
           - no errors, but no affirmation was checked
         * - ``MANUALCHECKS``
           - VHDL
           - no errors, manual checks are required
         * - ``TIMEOUT``
           - VHDL
           - ``EndOfTestReports`` was called with ``TimeOut``
         * - ``STOPLIMIT``
           - VHDL
           - the test stopped at the alert stop count
         * - ``SKIPPED``
           - Scripts
           - :ref:`RUFF/osvvm/SkipTest`
         * - ``ANALYZE_FAILED``
           - Scripts
           - the test case's analysis failed

   .. grid-item::
      :columns: 6

      The build summary report counts a test case as passed, if

      * ``ExpectedResults`` exist and match the status and alert counts, or
      * otherwise its status is ``PASSED``, or ``NOCHECKS`` while ``FailOnNoChecks`` is ``false``.

      A test case without ``Results`` - the simulation ended before ``EndOfTestReports`` - is shown as
      ``NOREPORTS``; this status never appears in the file.

      ``PASSED`` and ``FAILED`` are the defaults of ``OSVVM_PASS_NAME`` and ``OSVVM_FAIL_NAME`` in
      ``OsvvmSettingsPkg``.


.. _YAML/TestReport/Settings:

Settings
********

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``OsvvmSettingsInfo`` tells the report generators where the build's files are. All paths are relative to the
      build directory. The same mapping ends each :ref:`test case settings file <YAML/TestCaseSettings>`.

      .. tree::

         - ``ReportsSubdirectory`` | directory of the test case reports, ``ReportsSubdirectory``
         - ``SimulationLogFile`` | transcript of the build, or ``""`` without transcript
         - ``SimulationHtmlLogFile`` | its HTML version, or ``""`` if the transcript type isn't ``html``
         - ``RequirementsSubdirectory`` | directory of the merged requirements, or ``""`` without requirements
         - ``CoverageSubdirectory`` | the simulator's code coverage report, or ``""`` without code coverage
         - ``Report2CssFiles`` | list of style sheets of the HTML reports
         - ``Report2PngFile`` | logo of the HTML reports

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         OsvvmSettingsInfo:
           ReportsSubdirectory:  "reports"
           SimulationLogFile: "logs/Osvvm-Libraries_RunAllTests.log"
           SimulationHtmlLogFile: "logs/Osvvm-Libraries_RunAllTests_log.html"
           RequirementsSubdirectory: ""
           CoverageSubdirectory: ""
           Report2CssFiles:
             - "reports/CssOsvvmStyle.css"
           Report2PngFile:  "reports/OsvvmLogo.png"

      With code coverage, ``CoverageSubdirectory`` names the simulator's report (NVC):

      .. code-block:: yaml

         CoverageSubdirectory:    "CodeCoverage/Osvvm-Libraries_RunDemoTestsWithCoverage_code_cov/index.html"


.. _YAML/TestReport/Readers:

Readers
*******

.. grid:: 2

   .. grid-item::
      :columns: 6

      * :ref:`RUFF/osvvm/CreateBuildReports` reads the file with :ref:`RUFF/osvvm/ReportBuildYaml2Dict` and writes
        the HTML (:ref:`RUFF/osvvm/ReportBuildDict2Html`) and JUnit XML (:ref:`RUFF/osvvm/ReportBuildDict2Junit`)
        build summary reports - see :ref:`RPT/HTML/BuildSummary` and :ref:`RPT/XML`.
      * `pyEDAA.OSVVM <https://github.com/edaa-org/pyEDAA.OSVVM>`__ reads it in Python (``pyEDAA.OSVVM.Build``).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # create the build summary reports again
         CreateBuildReports OsvvmRunDemoTests/OsvvmRunDemoTests.yml
