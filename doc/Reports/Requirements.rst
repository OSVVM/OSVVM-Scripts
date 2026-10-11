.. _RPT/REQ:

Requirements Reports
####################

.. grid:: 2

   .. grid-item::
      :columns: 6

      When a test case tracks requirements, ``EndOfTestReports`` writes them into :file:`<TestCase>_req.yml`. The
      scripts merge and report them automatically:

      * At the end of each test suite, the requirements of its test cases are merged
        (:ref:`RUFF/osvvm/MergeRequirements`) into :file:`reports/<BuildName>/<TestSuite>_req.yml`, and
        :ref:`RUFF/osvvm/Requirements2Html` writes the HTML report next to it.
      * At the end of the build, the requirements of all test suites are merged into
        :file:`reports/<BuildName>_req.yml`, with an HTML (:ref:`RUFF/osvvm/Requirements2Html`) and a CSV
        (:ref:`RUFF/osvvm/Requirements2Csv`) report.

      Without requirements in a build, no requirements report is created.

      A requirement is tracked once it has a goal: from ``GetReqID`` with ``PassedGoal``, or from a specification
      (see :ref:`RPT/REQ/Specification`). A check that only names a requirement, like
      ``AffirmIf("UART_REQ_3", ...)``, creates no goal, and the requirement isn't reported.

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         TestProc : process
           variable ReqID, ReqID2 : AlertLogIDType ;
         begin
           SetTestName("TbUart_SendGet1") ;
           -- requirement with a goal of 2 passed checks
           ReqID := GetReqID("UART_REQ_1", PassedGoal => 2) ;
           . . .
           AffirmIf(ReqID, RxData = ExpData, "Received data") ;
           ReqID2 := GetReqID("UART_REQ_2", PassedGoal => 1) ;
           AffirmIf(ReqID2, Parity = '0', "Parity") ;
           . . .
           EndOfTestReports ;  -- writes TbUart_SendGet1_req.yml
           std.env.stop ;
         end process TestProc ;


.. _RPT/REQ/Settings:

Settings
********

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetRequirementUseSumOfGoals`
         How the goals of a requirement in several test cases combine: their sum, or - by default - their maximum.

      :ref:`RUFF/osvvm/SetRequirementTestCaseFailsIfLessThanGoal`
         Whether a test case that doesn't reach a requirement's goal fails. Default: ``true``.

      :ref:`RUFF/osvvm/SetRequirementDoesNotExceedGoal`
         Whether the passed count of a requirement is limited to its goal. Default: ``true``.

      :ref:`RUFF/osvvm/SetRequirementCsvPrintStatus`
         Whether the CSV report has a status column. Default: ``false``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # in OsvvmSettingsLocal.tcl or a build script
         SetRequirementUseSumOfGoals               true
         SetRequirementTestCaseFailsIfLessThanGoal false
         SetRequirementCsvPrintStatus              true


.. _RPT/REQ/Specification:

Requirements Specification
**************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      A requirements specification lists the requirements and their goals, including those no test case checks yet.
      :ref:`RUFF/osvvm/RequirementsCsv2Yaml` converts a specification in CSV into a requirements YAML file: each
      requirement gets an entry marked as coming from the specification, so it shows up in the reports even without a
      test case. The columns are ``Requirement``, ``Description``, ``Status``, ``Goal``, ``Passed``, ``Errors`` and
      ``Checked``; missing ones get defaults.

      In VHDL, ``ReadSpecification`` reads a specification into the test case.

   .. grid-item::
      :columns: 6

      .. code-block:: text

         Requirement,Description,Goal
         UART_REQ_1,Data is received,2
         UART_REQ_2,Parity is checked,1

      .. code-block:: tcl

         RequirementsCsv2Yaml UartSpec.csv UartSpec_req.yml
