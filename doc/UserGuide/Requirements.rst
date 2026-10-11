.. _UG/Requirements:

Requirements Tracking
#####################

.. grid:: 2

   .. grid-item::
      :columns: 6

      When a test case tracks requirements - in VHDL, a requirement ID from OSVVM's ``NewReqID`` used in ``AffirmIf`` -,
      it writes a requirements file next to its report, and a requirements report is created for it.

      When a test suite completes, the requirements of its test cases are merged into a test suite requirements report;
      when the build completes, all of them are merged into a build requirements report, as HTML and CSV. No script
      command is needed; see :ref:`RPT` for the reports.

      :ref:`RUFF/osvvm/RequirementsCsv2Yaml` converts a requirements specification from CSV into OSVVM's YAML format.

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         -- In the testbench (VHDL)
         Req1 := NewReqID("Req1", 2);
         AffirmIf(Req1, Data = Expected, "Read data");

.. _UG/Requirements/Settings:

Settings
********

.. grid:: 2

   .. grid-item::
      :columns: 6

      Four settings decide how requirements are counted:

      * :ref:`RUFF/osvvm/SetRequirementUseSumOfGoals`: ``true`` sums up the goals of the test cases of a requirement,
        ``false`` (default) uses the maximum goal. The maximum fits a merged specification whose goal is divided across
        the test cases.
      * :ref:`RUFF/osvvm/SetRequirementDoesNotExceedGoal`: ``true`` (default) counts a requirement at most up to its
        goal.
      * :ref:`RUFF/osvvm/SetRequirementTestCaseFailsIfLessThanGoal`: ``true`` (default) fails a test case whose
        requirements didn't reach their goal.
      * :ref:`RUFF/osvvm/SetRequirementCsvPrintStatus`: ``true`` adds the status column to the CSV report; the default
        is ``false``.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetRequirementUseSumOfGoals true
         SetRequirementCsvPrintStatus
