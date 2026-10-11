.. _YAML:

YAML Data Files
###############

OSVVM writes its results as YAML files first; the HTML and JUnit XML reports (see :ref:`RPT`) are generated from them.
The YAML files are machine-readable, so other tools can read OSVVM's results too.

* The **VHDL side** writes one set of files per test case, at the end of the simulation: alerts, functional coverage,
  scoreboards and requirements. ``EndOfTestReports`` (``osvvm.ReportPkg``) calls the writers of the OSVVM packages.
* The **Tcl side** writes the files of a build: the build file, which lists all test suites and test cases, the test
  case settings and the index of all builds.

Each file states its format version (``Version``). All formats are at version ``0.1``: ``OsvvmYamlVersion`` and its
derivatives in :file:`OsvvmSettingsRequired.tcl`, passed to the VHDL side by ``OsvvmScriptSettingsPkg``.

.. _YAML/Files:

Files
*****

.. list-table::
   :header-rows: 1
   :widths: 26 22 26 26

   * - File
     - Written by
     - Read by
     - Format
   * - :file:`<BuildName>.yml`
     - Tcl, during the build; VHDL adds each test case's results
     - :ref:`RUFF/osvvm/CreateBuildReports`
     - :ref:`YAML/TestReport`
   * - :file:`<TestCaseFileName>_run.yml`
     - Tcl, per test case
     - :ref:`RUFF/osvvm/Simulate2Html`
     - :ref:`YAML/TestCaseSettings`
   * - :file:`index.yml`
     - Tcl, at the end of each build
     - :ref:`RUFF/osvvm/Index2Html`
     - :ref:`YAML/Index`
   * - :file:`<TestCaseFileName>_alerts.yml`
     - VHDL, ``WriteAlertYaml`` (``AlertLogPkg``)
     - :ref:`RUFF/osvvm/Simulate2Html`
     - :ref:`YAML/AlertLog`
   * - :file:`<TestCaseFileName>_cov.yml`
     - VHDL, ``WriteCovYaml`` (``CoveragePkg``)
     - :ref:`RUFF/osvvm/Simulate2Html`
     - :ref:`YAML/FunctionalCoverage`
   * - :file:`<TestCaseFileName>_sb_<Package>.yml`
     - VHDL, ``WriteScoreboardYaml`` (``ScoreboardPkg_<Package>``)
     - :ref:`RUFF/osvvm/Simulate2Html`
     - :ref:`YAML/ScoreBoard`
   * - :file:`<TestCaseFileName>_req.yml`
     - VHDL, ``WriteRequirementsYaml`` (``AlertLogPkg``)
     - :ref:`RUFF/osvvm/MergeRequirements`, :ref:`RUFF/osvvm/Requirements2Html`
     - :ref:`YAML/Requirements`

.. _YAML/Location:

Where the Files Are
*******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The VHDL side writes its files into OSVVM's temporary directory, named after the test name. After the
      simulation, the Tcl side moves them into the test suite's reports directory and names them after the test case
      file name, which includes the generics (see :ref:`UG/Generics`).

      The build file is written into the temporary directory during the build and moved into the build directory at
      its end. :file:`index.yml` is next to the build directories, in the simulation directory.

      The YAML files stay next to the HTML reports, so a report can be generated again from them (see
      :ref:`RPT/Errors`).

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`sim`
           - :file:`index.yml` | all builds
           - :file:`<BuildName>`
             - :file:`<BuildName>.yml` | the build
             - :file:`reports`
               - :file:`<TestSuite>`
                 - :file:`<TestCaseFileName>_run.yml` | test case settings
                 - :file:`<TestCaseFileName>_alerts.yml` | alerts and affirmations
                 - :file:`<TestCaseFileName>_cov.yml` | functional coverage
                 - :file:`<TestCaseFileName>_sb_<Package>.yml` | one per scoreboard package
                 - :file:`<TestCaseFileName>_req.yml` | requirements

.. toctree::
   :hidden:

   TestReport
   TestCaseSettings
   Index
   AlertLog
   FunctionalCoverage
   ScoreBoard
   Requirements
