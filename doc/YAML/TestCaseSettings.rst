.. _YAML/TestCaseSettings:

Test Case Settings
##################

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each :ref:`RUFF/osvvm/simulate` writes a test case settings file
      :file:`reports/<TestSuite>/<TestCaseFileName>_run.yml`. It tells the test case report which test case it
      describes and where the test case's other YAML files and transcripts are.

      OSVVM-Scripts writes it after the simulation (``WriteTestCaseSettingsYaml`` in ``AfterSimulateReports``), once
      the test case's files have been moved from the temporary output directory into the build. Right after,
      :ref:`RUFF/osvvm/Simulate2Html` reads it and writes the test case report
      :file:`reports/<TestSuite>/<TestCaseFileName>.html` (see :ref:`RPT/HTML/TestCase`).

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`OsvvmRunDemoTests`
           - :file:`reports`
             - :file:`UART`
               - :file:`TbUart_SendGet1_run.yml` | test case settings
               - :file:`TbUart_SendGet1_alerts.yml` | named by it
               - :file:`TbUart_SendGet1_sb_Uart.yml` | named by it
               - :file:`TbUart_SendGet1.html` | created from it
           - :file:`results`
             - :file:`UART`
               - :file:`TbUart_SendGet1.log` | named by it


.. _YAML/TestCaseSettings/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      Paths are relative to the build directory, except ``TestCaseFile``, which is relative to the test suite's
      reports directory, where the HTML report links it.

      .. tree::

         - ``Version`` | format version, string; ``"0.1"`` (``OsvvmTestCaseYamlVersion``)
         - ``TestCaseName`` | test case name: :ref:`RUFF/osvvm/TestName`, else the simulated design unit
         - ``TestCaseFile`` | the last file analyzed before the simulation, usually the test case's VHDL file
         - ``TestSuiteName`` | test suite name (:ref:`RUFF/osvvm/TestSuite`), ``"Default"`` without one
         - ``BuildName`` | build name
         - ``Generics`` | mapping name → value (:ref:`RUFF/osvvm/generic`), or ``null``
         - ``ReportsTestSuiteDirectory`` | the test suite's reports directory
         - ``RequirementsYamlFile`` | :ref:`requirements <YAML/Requirements>` of the test case, or ``""``
         - ``AlertYamlFile`` | :ref:`alerts <YAML/AlertLog>` of the test case, or ``""``
         - ``CovYamlFile`` | :ref:`functional coverage <YAML/FunctionalCoverage>` of the test case, or ``""``
         - ``ScoreboardDict`` | mapping scoreboard name → :ref:`scoreboard file <YAML/ScoreBoard>`, or ``null``
         - ``TranscriptFiles`` | the test case's transcripts, see :ref:`YAML/TestCaseSettings/Transcripts`
         - ``TestCaseFileName`` | base name of the test case's files: ``TestCaseName`` plus the generics
         - ``GenericNames`` | the generics' part of ``TestCaseFileName``, or ``""``
         - ``OsvvmSettingsInfo`` | as in the build report, see :ref:`YAML/TestReport/Settings`

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version: "0.1"
         TestCaseName: "TbStream_AxiSetOptionsBurstAsync3"
         TestCaseFile:  "../../../../AXI4/AxiStream/TestCases/TbStream_AxiSetOptionsBurstAsync3.vhd"
         TestSuiteName: "AxiStream_VTI"
         BuildName: "Osvvm-Libraries_RunAllTestsVti"
         Generics:           null
         ReportsTestSuiteDirectory:  "reports/AxiStream_VTI"
         RequirementsYamlFile: ""
         AlertYamlFile:  "reports/AxiStream_VTI/TbStream_AxiSetOptionsBurstAsync3_alerts.yml"
         CovYamlFile:  "reports/AxiStream_VTI/TbStream_AxiSetOptionsBurstAsync3_cov.yml"
         ScoreboardDict:
           slv: "reports/AxiStream_VTI/TbStream_AxiSetOptionsBurstAsync3_sb_slv.yml"
         TranscriptFiles: "results/AxiStream_VTI/TbStream_AxiSetOptionsBurstAsync3.log"
         TestCaseFileName: "TbStream_AxiSetOptionsBurstAsync3"
         GenericNames: ""
         OsvvmSettingsInfo:
           ReportsSubdirectory:  "reports"
           SimulationLogFile: "logs/Osvvm-Libraries_RunAllTestsVti.log"
           SimulationHtmlLogFile: "logs/Osvvm-Libraries_RunAllTestsVti_log.html"
           RequirementsSubdirectory: ""
           CoverageSubdirectory: ""
           Report2CssFiles:
             - "reports/CssOsvvmStyle.css"
           Report2PngFile:  "reports/OsvvmLogo.png"

      With generics (:file:`Tb_xMii1_MII_INTERFACE_MII_MII_BPS_BPS_10M_run.yml`):

      .. code-block:: yaml

         Generics:
           MII_INTERFACE: "MII"
           MII_BPS: "BPS_10M"
         # ...
         GenericNames: "_MII_INTERFACE_MII_MII_BPS_BPS_10M"


.. _YAML/TestCaseSettings/Files:

The Test Case's Files
=====================

.. grid:: 2

   .. grid-item::
      :columns: 6

      During the simulation, OSVVM's utility library writes the test case's YAML files into the temporary output
      directory, named after ``TestCaseName``. After the simulation, OSVVM-Scripts moves each file that exists into
      the test suite's reports directory, renamed after ``TestCaseFileName`` - so a test case simulated with
      different generics gets files of its own. The settings file names the moved files; a file the test case didn't
      write is ``""``.

   .. grid-item::
      :columns: 6

      .. list-table::
         :header-rows: 1

         * - Temporary file
           - Key
         * - :file:`<TestCaseName>_alerts.yml`
           - ``AlertYamlFile``
         * - :file:`<TestCaseName>_cov.yml`
           - ``CovYamlFile``
         * - :file:`<TestCaseName>_req.yml`
           - ``RequirementsYamlFile``
         * - :file:`<TestCaseName>_sb_<Name>.yml`
           - ``ScoreboardDict``, key ``<Name>``


.. _YAML/TestCaseSettings/Transcripts:

Transcript List
***************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each ``TranscriptOpen`` of a test case appends the transcript's file name to the temporary list
      :file:`OSVVM_transcript.yml` in the temporary output directory (``CreateTranscriptYamlLog`` in
      ``TranscriptBasePkg``); the first one in a simulation creates the list. Its name comes from
      ``OSVVM_TRANSCRIPT_YAML_FILE`` in ``OsvvmScriptSettingsPkg``.

      After the simulation, OSVVM-Scripts reads the list, copies each transcript into
      :file:`results/<TestSuite>/` - with the generics' names added - writes its HTML version
      (:ref:`RUFF/osvvm/Transcript2Html`) and deletes the list. ``TranscriptFiles`` names the copies. The list is also
      deleted at the start of each build.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # OsvvmTemp_NVC/OSVVM_transcript.yml (temporary)
           - OsvvmTemp_NVC/TbUart_Checkers1.log

      A list of plain file names, without a key. With several transcripts, ``TranscriptFiles`` holds them as one
      string, separated by spaces.
