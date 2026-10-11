.. _RPT:

Reports
#######

Good reports simplify debug and help find problems quickly. This is important, as according to the
`2020 Wilson Research Group Functional Verification Study`_ verification engineers spend 46 % of their time debugging.

.. _2020 Wilson Research Group Functional Verification Study: https://blogs.sw.siemens.com/verificationhorizons/2020/12/02/part-4-the-2020-wilson-research-group-functional-verification-study/

OSVVM creates its reports automatically, while a build runs. The VHDL side - OSVVM's utility library - writes the
results of each test case as YAML files; the Tcl side - OSVVM-Scripts - adds what it knows about the build and converts
everything into reports:

.. grid:: 2

   .. grid-item::
      :columns: 6

      * :ref:`HTML Build Summary Report <RPT/HTML/BuildSummary>` - for humans: did the build pass, which test cases
        failed?
      * :ref:`JUnit XML Build Summary Report <RPT/XML>` - for continuous integration (CI/CD) tools.
      * :ref:`HTML Test Case Detailed Report <RPT/HTML/TestCase>` - per test case: alerts, functional coverage,
        scoreboards.
      * :ref:`HTML simulator transcript <RPT/HTML/SimTranscript>` - the simulator output of the whole build.
      * :ref:`Test case transcript <RPT/HTML/TestCaseTranscript>` - what a test case wrote with ``TranscriptOpen``.
      * :ref:`Requirements reports <RPT/REQ>` - HTML and CSV, if test cases track requirements.
      * :ref:`Code coverage report <RPT/HTML/CodeCoverage>` - from the simulator, if code coverage is enabled.
      * :ref:`Build index <RPT/HTML/Index>` - all builds of a simulation directory.

   .. grid-item::
      :columns: 6

      The best way to see the reports is to look at the ones of the demo. Run it in your simulation directory:

      .. code-block:: tcl

         build ../OsvvmLibraries/OsvvmLibraries.pro
         build ../OsvvmLibraries/RunDemoTests.pro
         OpenBuildHtml

      :ref:`RUFF/osvvm/build` runs the build and creates the reports; :ref:`RUFF/osvvm/OpenBuildHtml` opens its
      build summary report in a browser.


.. _RPT/Generate:

Generating Reports
******************

.. _RPT/Generate/VHDL:

VHDL Side
=========

.. grid:: 2

   .. grid-item::
      :columns: 6

      To generate reports, the VHDL testbench needs:

      * A test case name, set with ``SetTestName("TestName")``. It must match the test case name the script uses (see
        :ref:`below <RPT/Generate/Tcl>`); otherwise the build summary reports a ``NAME_MISMATCH`` failure.
      * Some self-checking, with ``AffirmIf``, ``AffirmIfEqual`` or ``AffirmIfNotDiff``.
      * ``EndOfTestReports`` at the end of the test case. It writes the YAML files of the test case: alerts, functional
        coverage, scoreboards, requirements.

      ``TranscriptOpen`` collects the test case's own output into a :ref:`test case transcript
      <RPT/HTML/TestCaseTranscript>`.

      Details are in the `OSVVM Test Writers User Guide`_.

      .. _OSVVM Test Writers User Guide: https://github.com/OSVVM/Documentation/blob/main/OSVVM_test_writers_user_guide.pdf

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         -- Reference to OSVVM Utility Library
         library OSVVM ;
         context OSVVM.OsvvmContext ;
         . . .
         TestProc : process
         begin
           -- Name the test
           SetTestName("TbDut") ;
           TranscriptOpen ;
           . . .
           -- Do some checks
           AffirmIfEqual(Data, X"A025", "Check Data") ;
           . . .
           -- Generate reports (replaces ReportAlerts)
           EndOfTestReports ;
           std.env.stop(GetAlertCount) ;
         end process TestProc ;


.. _RPT/Generate/Tcl:

Tcl Side
========

.. grid:: 2

   .. grid-item::
      :columns: 6

      A build script ``*.pro`` started with :ref:`RUFF/osvvm/build` creates all reports; there is nothing to call.

      * :ref:`RUFF/osvvm/simulate` names the test case after the design unit it simulates, unless
        :ref:`RUFF/osvvm/TestName` set the name before.
      * :ref:`RUFF/osvvm/TestSuite` groups the following test cases into a test suite; without it, the test suite is
        named ``Default``.
      * :ref:`RUFF/osvvm/RunTest` combines :ref:`RUFF/osvvm/analyze`, :ref:`RUFF/osvvm/TestName` and
        :ref:`RUFF/osvvm/simulate` for a test case in its own file, typically with a configuration of the same name.

      Every test case named with :ref:`RUFF/osvvm/TestName` is recorded in the build's YAML file before it runs. If its
      simulation doesn't run at all - it crashed, or its file didn't analyze -, the build summary still lists it, as
      failed.

      If a test case's file fails to analyze, the previously analyzed test case may run instead. Its
      ``SetTestName`` name then differs from the script's name, and the build summary reports a ``NAME_MISMATCH``.

   .. grid-item::
      :columns: 6

      .. tab-set::

         .. tab-item:: Simple test

            .. code-block:: tcl

               # File name: Dut.pro
               analyze   Dut.vhd
               analyze   TbDut.vhd
               simulate  TbDut

            ``build Dut.pro``: test suite ``Default``, test case ``TbDut``.

         .. tab-item:: Test names

            .. code-block:: tcl

               TestSuite Uart
               library   osvvm_TbUart
               analyze   TestCtrl_e.vhd
               analyze   TbUart.vhd

               TestName  TbUart_SendGet1
               analyze   TestCtrl_SendGet1.vhd
               simulate  TbUart

               TestName  TbUart_SendGet2
               analyze   TestCtrl_SendGet2.vhd
               simulate  TbUart

         .. tab-item:: RunTest

            .. code-block:: tcl

               TestSuite Uart
               library   osvvm_TbUart
               analyze   TestCtrl_e.vhd
               analyze   TbUart.vhd

               RunTest   TbUart_SendGet1.vhd
               RunTest   TbUart_SendGet2.vhd
               RunTest   TbUart_Scoreboard1.vhd


.. _RPT/Generate/When:

When Reports Are Created
========================

.. grid:: 2

   .. grid-item::
      :columns: 6

      **After each simulation**, :ref:`RUFF/osvvm/Simulate2Html` creates the test case's detailed report, and the
      transcript files the test case opened are converted with :ref:`RUFF/osvvm/Transcript2Html`.

      **At the end of a test suite**, the requirements of its test cases are merged
      (:ref:`RUFF/osvvm/MergeRequirements`, :ref:`RUFF/osvvm/Requirements2Html`) and, with code coverage, the test
      cases' coverage is merged.

      **At the end of a build**:

      #. the requirements of all test suites are merged and reported (:ref:`RUFF/osvvm/Requirements2Html`,
         :ref:`RUFF/osvvm/Requirements2Csv`);
      #. with code coverage, the coverage is merged and its report is created;
      #. :ref:`RUFF/osvvm/CreateBuildReports` writes the HTML and JUnit XML build summary reports from the build's
         YAML file;
      #. :ref:`RUFF/osvvm/Log2Osvvm` converts the simulator transcript into HTML;
      #. :ref:`RUFF/osvvm/Index2Html` updates the build index.

   .. grid-item::
      :columns: 6

      Settings that control the reports, in ``OsvvmSettingsLocal.tcl`` or by command:

      .. code-block:: tcl

         # HTML (default), log or none
         SetTranscriptType html

         # open the build summary report after an
         # interactive build
         variable OpenBuildHtmlFile "true"

         # create no reports and no YAML files at all
         variable GenerateOsvvmReports "false"

      See :ref:`RUFF/osvvm/SetTranscriptType`. Requirements settings: :ref:`RPT/REQ`.


.. _RPT/Layout:

Where the Files Go
******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each build gets a directory named after the build, in the directory where the simulator runs. The build name is
      the script's name, prefixed with its directory's name, if they differ:
      ``build ../OsvvmLibraries/RunAllTests.pro`` creates ``OsvvmLibraries_RunAllTests``.
      :ref:`RUFF/osvvm/BuildName` sets another name: :file:`RunDemoTests.pro` names its build ``OsvvmRunDemoTests``.

      :file:`<BuildName>.html`, :file:`.xml`, :file:`.yml`
         Build summary reports and the build's YAML file.

      :file:`reports/<TestSuite>/`
         Per test case: the detailed report :file:`<TestCase>.html` and its YAML sources (:file:`_run.yml`,
         :file:`_alerts.yml`, :file:`_cov.yml`, :file:`_sb_<Name>.yml`, :file:`_req.yml`). Merged requirements:
         :file:`reports/<BuildName>/<TestSuite>_req.*` and :file:`reports/<BuildName>_req.*`.

      :file:`results/<TestSuite>/`
         Test case transcripts opened with ``TranscriptOpen`` (:file:`.log`) and their HTML version.

      :file:`logs/`
         Simulator transcript of the build (:file:`<BuildName>.log`) and its HTML version
         (:file:`<BuildName>_log.html`).

      :file:`CodeCoverage/`
         Code coverage databases and the simulator's code coverage report, if code coverage was collected.

      Next to the build directories, :file:`index.html` and :file:`index.yml` list all builds.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`sim`
           - :file:`index.html`
           - :file:`index.yml`
           - :file:`OsvvmRunDemoTests`
             - :file:`OsvvmRunDemoTests.html`
             - :file:`OsvvmRunDemoTests.xml`
             - :file:`OsvvmRunDemoTests.yml`
             - :file:`reports`
               - :file:`CssOsvvmStyle.css`
               - :file:`OsvvmLogo.png`
               - :file:`UART`
                 - :file:`TbUart_SendGet1.html`
                 - :file:`TbUart_SendGet1_alerts.yml`
                 - :file:`TbUart_SendGet1_run.yml`
                 - :file:`TbUart_SendGet1_sb_Uart.yml`
                 - …
             - :file:`results`
               - :file:`UART`
                 - :file:`TbUart_SendGet1.html`
                 - :file:`TbUart_SendGet1.log`
             - :file:`logs`
               - :file:`OsvvmRunDemoTests.log`
               - :file:`OsvvmRunDemoTests_log.html`
             - :file:`CodeCoverage`
               - …


.. _RPT/Open:

Opening the Reports
*******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/OpenBuildHtml` opens the build summary report of the last build, or of the named one, in a
      browser. :ref:`RUFF/osvvm/OpenIndex` opens the build index.

      All other reports are linked from the build summary report.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         OpenBuildHtml
         OpenBuildHtml OsvvmRunDemoTests
         OpenIndex


.. _RPT/Errors:

Reports After a Simulation or Build Ended in Error
**************************************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The reports are created from YAML files, so they can be created again by hand - for example, after a simulation
      crashed before its report was written, or a build stopped before its end. Run the commands in the simulation
      directory, where the build directory is.

      * :ref:`RUFF/osvvm/Simulate2Html` creates a test case's detailed report from its :file:`_run.yml` file. The
        second argument is the build directory. ``<TestCaseFileName>`` is the test case name, followed by
        ``_<Generic>_<Value>`` for each generic set with :ref:`RUFF/osvvm/generic`.
      * :ref:`RUFF/osvvm/CreateBuildReports` creates the HTML and JUnit XML build summary reports from the build's YAML
        file. :ref:`RUFF/osvvm/Report2Html` and :ref:`RUFF/osvvm/Report2Junit` create only one of them.
      * :ref:`RUFF/osvvm/Log2Osvvm` creates the HTML simulator transcript from the build's log file.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         set Build OsvvmRunDemoTests

         Simulate2Html $Build/reports/UART/TbUart_SendGet1_run.yml $Build
         CreateBuildReports $Build/$Build.yml
         Log2Osvvm $Build/logs/$Build.log


.. toctree::
   :hidden:

   HTML
   XML
   YAML
   Requirements
