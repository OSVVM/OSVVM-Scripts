.. _RPT/YAML:

YAML Files
##########

.. grid:: 2

   .. grid-item::
      :columns: 6

      YAML files are the data the reports are created from. OSVVM's utility library writes the results of a test case
      from VHDL; OSVVM-Scripts writes what it knows about the build. The HTML and XML reports are created from these
      files, so they can be :ref:`created again <RPT/Errors>` at any time.

      The formats are described in :ref:`YAML`.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`OsvvmRunDemoTests`
           - :file:`OsvvmRunDemoTests.yml`
           - :file:`reports`
             - :file:`UART`
               - :file:`TbUart_SendGet1_run.yml`
               - :file:`TbUart_SendGet1_alerts.yml`
               - :file:`TbUart_SendGet1_sb_Uart.yml`
               - …


.. _RPT/YAML/Files:

Files
*****

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - File
     - Written by
     - Content
   * - :file:`<BuildName>/<BuildName>.yml`
     - Scripts; VHDL (``EndOfTestReports``) adds each test case's results
     - The build: its test suites and test cases with their results, settings and timing. Source of the build summary
       reports (:ref:`RUFF/osvvm/CreateBuildReports`).
   * - :file:`reports/<TestSuite>/<TestCaseFileName>_run.yml`
     - Scripts
     - Settings of one simulation: test case and test suite name, generics, the test case's VHDL file, and the paths
       of its other YAML files and transcripts. Source of :ref:`RUFF/osvvm/Simulate2Html`.
   * - :file:`reports/<TestSuite>/<TestCase>_alerts.yml`
     - VHDL (``EndOfTestReports``)
     - Alerts and checks of each ``AlertLogID`` (:ref:`RPT/HTML/TestCase/Alerts`).
   * - :file:`reports/<TestSuite>/<TestCase>_cov.yml`
     - VHDL (``EndOfTestReports``)
     - Functional coverage models (:ref:`RPT/HTML/TestCase/Coverage`).
   * - :file:`reports/<TestSuite>/<TestCase>_sb_<Name>.yml`
     - VHDL (``EndOfTestReports``)
     - One scoreboard (:ref:`RPT/HTML/TestCase/Scoreboards`).
   * - :file:`reports/<TestSuite>/<TestCase>_req.yml`
     - VHDL (``EndOfTestReports``)
     - Requirements of the test case (:ref:`RPT/REQ`).
   * - :file:`index.yml`
     - Scripts
     - One entry per build of the simulation directory (:ref:`RPT/HTML/Index`).
