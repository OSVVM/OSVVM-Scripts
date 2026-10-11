.. _YAML/Requirements:

Requirements
############

.. grid:: 2

   .. grid-item::
      :columns: 6

      Requirements are tracked in YAML files of one format, written at three levels:

      * per test case, by AlertLogPkg: :file:`<TestCaseFileName>_req.yml`;
      * per test suite, merged by the scripts: :file:`<BuildName>/<TestSuite>_req.yml`;
      * per build, merged by the scripts: :file:`<BuildName>_req.yml`.

      A fourth source is a requirements specification, converted from CSV (:ref:`YAML/Requirements/Specification`).

      The merged files are the input of the requirements reports: :ref:`RUFF/osvvm/Requirements2Html` and
      :ref:`RUFF/osvvm/Requirements2Csv` (see :ref:`RPT/REQ`). Without requirements in a test case, no file is
      written; without any in a build, there are no merged files and no requirements report.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`<BuildName>`
           - :file:`reports`
             - :file:`<TestSuite>`
               - :file:`<TestCaseFileName>_req.yml` | per test case
             - :file:`<BuildName>`
               - :file:`<TestSuite>_req.yml` | per test suite
               - :file:`<TestSuite>_req.html`
             - :file:`<BuildName>_req.yml` | per build
             - :file:`<BuildName>_req.html`
             - :file:`<BuildName>_req.csv`


.. _YAML/Requirements/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      A requirements file is a list with one entry per requirement. Each requirement lists the test cases that check
      it, with their result for this requirement. In a test case's file, every requirement has one test case; a merged
      file has all test cases that check it.

      ``Results`` and its count objects are YAML flow mappings, written on one line. ``AlertCount`` and
      ``DisabledAlertCount`` have the keys ``Failure``, ``Error`` and ``Warning``.

      The file has no ``Version`` key; the version setting ``OsvvmRequirementsYamlVersion`` isn't written.

   .. grid-item::
      :columns: 6

      .. tree::

         - ``Requirement`` | requirement name
         - ``Description`` | only from a specification
         - ``TestCases`` | list of the test cases checking it
           - ``TestName`` | test case name, set by ``SetTestName``
           - ``Status`` | ``PASSED`` or ``FAILED``
           - ``FromSpecification`` | ``"true"``, only from a specification
           - ``Results`` | the test case's counts for this requirement
             - ``Goal`` | passed checks needed
             - ``Passed`` | passed checks
             - ``Errors`` | alerts, enabled and disabled
             - ``Checked`` | all checks
             - ``AlertCount`` | alerts, enabled
             - ``DisabledAlertCount`` | alerts while disabled


.. _YAML/Requirements/TestCase:

Per Test Case
*************

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``EndOfTestReports`` (ReportPkg) calls ``WriteRequirementsYaml`` (AlertLogPkg), if the test case has
      requirements. It writes :file:`<TestName>_req.yml` into OSVVM's temporary directory; after the simulation, the
      scripts move it into the test suite's reports directory as :file:`<TestCaseFileName>_req.yml`, like the
      :ref:`alerts file <YAML/AlertLog>`.

      Every AlertLog ID with a goal is a requirement - created with ``GetReqID(..., PassedGoal => <n>)`` or given a
      goal with ``SetPassedGoal`` - wherever it is in the hierarchy. A check by name, ``AffirmIf("UART_REQ_3", ...)``,
      creates an ID below ``Requirements`` without a goal: it shows in the :ref:`alerts file <YAML/AlertLog>`, but not
      here. A test case with only such IDs writes an empty file.

      ``Status`` is ``PASSED`` if ``Errors`` is 0 and ``Passed`` reached ``Goal``, else ``FAILED``. ``Errors`` counts
      all alerts of the requirement, enabled and disabled, including warnings, whatever the ``FailOn...`` settings
      are.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # TbReq2_req.yml
         - Requirement: "UART_REQ_1"
           TestCases:
           - TestName: "TbReq2"
             Status: FAILED
             Results: {Goal: 2, Passed: 1, Errors: 0, Checked: 1,
               AlertCount: {Failure: 0, Error: 0, Warning: 0},
               DisabledAlertCount: {Failure: 0, Error: 0, Warning: 0}}
         - Requirement: "UART_REQ_2"
           TestCases:
           - TestName: "TbReq2"
             Status: FAILED
             Results: {Goal: 1, Passed: 0, Errors: 1, Checked: 1,
               AlertCount: {Failure: 0, Error: 1, Warning: 0},
               DisabledAlertCount: {Failure: 0, Error: 0, Warning: 0}}

      ``UART_REQ_1`` has 1 of 2 passed checks, ``UART_REQ_2`` a failed check: both are ``FAILED``. (The flow mappings
      are wrapped for the page; the file has one line per ``Results``.)


.. _YAML/Requirements/Merged:

Merged Files
************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/MergeRequirements` reads all :file:`*_req.yml` files of a directory and writes one file with
      every requirement once, sorted by name; each requirement lists the test cases of all files. The scripts merge
      twice:

      * at the end of each test suite: :file:`reports/<TestSuite>/*_req.yml` into
        :file:`reports/<BuildName>/<TestSuite>_req.yml`, followed by its HTML report;
      * at the end of the build: :file:`reports/<BuildName>/*_req.yml` - the test suites' files - into
        :file:`reports/<BuildName>_req.yml`, followed by its HTML and CSV reports.

      The merged files have the same structure; names are written without quotes. ``FromSpecification`` is kept,
      ``Description`` isn't. The ``SetRequirement...`` settings don't change the files; the reports apply them when
      they read a merged file (:ref:`RPT/REQ/Settings`).

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # src_Req/reports/src_Req_req.yml
         - Requirement: UART_REQ_1
           TestCases:
           - TestName: TbReq2
             Status: FAILED
             Results: { Goal: 2, Passed: 1, Errors: 0, Checked: 1,
               AlertCount: {Failure: 0,  Error: 0,  Warning: 0},
               DisabledAlertCount: {Failure: 0,  Error: 0,  Warning: 0}}
           - TestName: TbReq1
             Status: PASSED
             Results: { Goal: 2, Passed: 2, Errors: 0, Checked: 2,
               AlertCount: {Failure: 0,  Error: 0,  Warning: 0},
               DisabledAlertCount: {Failure: 0,  Error: 0,  Warning: 0}}
         - Requirement: UART_REQ_2
           TestCases:
           - TestName: TbReq2
             . . .


.. _YAML/Requirements/Specification:

From a Specification
********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/RequirementsCsv2Yaml` converts a requirements specification in CSV into a requirements file.
      Each CSV row becomes a requirement with one test case: the CSV file's name, marked ``FromSpecification:
      "true"``. The columns are matched by the header line, or by an explicit list of column names:
      ``Requirement``, ``Description``, ``Status``, ``Goal``, ``Passed``, ``Errors``, ``Checked``. A missing column
      gets a default: ``Status`` ``PASSED``, ``Goal`` 1, the counts 0.

      A specification file joins a merge when it's a :file:`*_req.yml` file in the merged directory. The reports
      then show its requirements, also those no test case checks yet.

   .. grid-item::
      :columns: 6

      .. code-block:: text

         Requirement,Description,Goal
         UART_REQ_1,Data is received,2
         UART_REQ_2,Parity is checked,1

      .. code-block:: tcl

         RequirementsCsv2Yaml UartSpec.csv UartSpec_req.yml

      .. code-block:: yaml

         - Requirement: UART_REQ_1
           Description: Data is received
           TestCases:
           - TestName:  UartSpec.csv
             Status:    PASSED
             FromSpecification: "true"
             Results: { Goal:    2, Passed:  0, Errors:  0, Checked: 0,
               AlertCount: {Failure: 0, Error: 0, Warning: 0},
               DisabledAlertCount: {Failure: 0, Error: 0, Warning: 0}}
         - Requirement: UART_REQ_2
           . . .
