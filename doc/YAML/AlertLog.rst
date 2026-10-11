.. _YAML/AlertLog:

AlertLog Report
###############

.. grid:: 2

   .. grid-item::
      :columns: 6

      At the end of a test case, OSVVM's AlertLogPkg writes the test case's alert hierarchy with all its counts into
      :file:`<TestCaseFileName>_alerts.yml`: the test case's result, the settings that decide it, and one entry per
      AlertLog ID with its alerts, checks and requirements.

      The simulation writes the file into OSVVM's temporary directory, named after the test case. After the
      simulation, the scripts move it into the test suite's reports directory and rename it after the test case file,
      which includes the generics.

      :ref:`RUFF/osvvm/Simulate2Html` reads it with :ref:`RUFF/osvvm/Alert2Html` into the alert section of the test
      case report (:ref:`RPT/HTML/TestCase/Alerts`). The test case's summary goes into the build's YAML file separately
      (:ref:`YAML/TestReport`).

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`<SimulationDirectory>`
           - :file:`OsvvmTemp_<ToolName>`
             - :file:`<TestName>_alerts.yml` | written by the simulation
           - :file:`<BuildName>`
             - :file:`reports`
               - :file:`<TestSuite>`
                 - :file:`<TestCaseFileName>_alerts.yml` | moved here after the simulation


.. _YAML/AlertLog/Writing:

Writing the File
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``EndOfTestReports`` (ReportPkg) calls ``WriteAlertYaml`` (AlertLogPkg) with the file name
      :file:`<TestName>_alerts.yml` in the temporary directory ``OSVVM_TEMP_OUTPUT_DIRECTORY``. Its arguments
      ``ExternalErrors`` and ``TimeOut`` are passed on.

      When an alert reaches its stop count, AlertLogPkg writes the file itself before it stops the simulation; the
      test case's status is then ``STOPLIMIT``.

      A testbench can call ``WriteAlertYaml`` directly. ``PrintSettings`` controls whether ``Version`` and
      ``Settings`` are written, ``PrintChildren`` whether the hierarchy is written.

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         TestProc : process
           variable UartID, RxID, ReqID : AlertLogIDType ;
         begin
           SetTestName("TbReq1") ;
           UartID := NewID("Uart") ;
           RxID   := NewID("Rx", UartID) ;
           ReqID  := GetReqID("UART_REQ_1", PassedGoal => 2) ;
           . . .
           AffirmIf(RxID, RxData = ExpData, "Rx check") ;
           AffirmIf(ReqID, Parity = '0', "Parity") ;
           . . .
           EndOfTestReports ;  -- writes TbReq1_alerts.yml
           std.env.stop ;
         end process TestProc ;


.. _YAML/AlertLog/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      The top level describes the test case; ``Children`` holds the AlertLog hierarchy. ``Results``, ``Settings`` and
      the count objects are YAML flow mappings, written on one line.

      An entry of ``Children`` has the same structure as the top level, without ``Version`` and ``Settings`` and with
      fewer ``Results``. Each entry has a ``Children`` list, which is empty (``[]``) for a leaf.

      Every count object - ``AlertCount``, ``DisabledAlertCount``, ``ExpectedCount``, ``ExternalErrors`` - has the keys
      ``Failure``, ``Error`` and ``Warning``.

   .. grid-item::
      :columns: 6

      .. tree::

         - ``Version`` | format version: ``"0.1"`` (``ALERT_YAML_VERSION``)
         - ``Name`` | test case name, set by ``SetTestName``
         - ``Status`` | test case result, see :ref:`YAML/AlertLog/Status`
         - ``Results`` | counts of the whole test case
           - ``TotalErrors`` | errors that decide the result
           - ``AlertCount`` | alerts, enabled
           - ``PassedCount`` | passed checks
           - ``AffirmCount`` | all checks
           - ``RequirementsPassed`` | requirements that reached their goal
           - ``RequirementsGoal`` | requirements
           - ``DisabledAlertCount`` | alerts while disabled
           - ``ExpectedCount`` | expected alerts
           - ``ExternalErrors`` | errors from outside AlertLogPkg
         - ``Settings`` | settings that decide the result
           - ``ExternalErrors`` | external minus expected errors, can be negative
           - ``FailOnDisabledErrors`` | ``"true"`` or ``"false"``
           - ``FailOnRequirementErrors`` | ``"true"`` or ``"false"``
           - ``FailOnWarning`` | ``"true"`` or ``"false"``
         - ``Children`` | list of the AlertLog IDs below the top
           - ``Name`` | AlertLog ID name
           - ``Status`` | ``PASSED`` or ``FAILED``
           - ``Results`` | counts of this ID
             - ``TotalErrors``
             - ``AlertCount``
             - ``PassedCount``
             - ``AffirmCount``
             - ``RequirementsPassed`` | passed checks, if the ID has a goal
             - ``RequirementsGoal`` | the ID's goal, else ``0``
             - ``DisabledAlertCount``
           - ``Children`` | the IDs below, same structure


.. _YAML/AlertLog/Counts:

Counts
******

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``TotalErrors``
         The alerts of the entry and the IDs below it, plus:

         * warnings only if ``FailOnWarning`` is ``true``;
         * the disabled alerts, if ``FailOnDisabledErrors`` is ``true``;
         * one per requirement below the entry that didn't reach its goal, if ``FailOnRequirementErrors`` is
           ``true``.

         At the top level also the external errors, and the VHDL assertion errors, if AlertLogPkg counts them
         (``FailOnVhdlAssertErrors``).

      ``AlertCount``
         Counts the entry's alerts and those of the IDs below it: an alert counts for its ID and every parent.

      ``DisabledAlertCount``, ``PassedCount``, ``AffirmCount``
         At the top level for the whole test case; in ``Children`` for the entry's own ID only.

      ``RequirementsPassed``, ``RequirementsGoal``
         At the top level the number of requirements that reached their goal, and the number of requirements. In
         ``Children``, an ID with a goal (``GetReqID``, ``SetPassedGoal``) has its passed checks and its goal; every
         other ID has ``0`` and ``0``.

      ``ExpectedCount``, ``ExternalErrors``
         ``EndOfTestReports`` takes ``ExternalErrors``: positive counts are added as errors, negative counts are
         expected alerts. ``ExpectedCount`` adds the counts set with ``SetExpectedAlertCount``; ``Results``'
         ``ExternalErrors`` has the positive counts only.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Name: "TbReq2"
         Status: "FAILED"
         Results: {TotalErrors: 4,
           AlertCount: {Failure: 0, Error: 1, Warning: 0},
           PassedCount: 3, AffirmCount: 4,
           RequirementsPassed: 0, RequirementsGoal: 2,
           DisabledAlertCount: {Failure: 0, Error: 0, Warning: 1}, ...}
         Children:
           - Name: "Requirements"
             Status: "FAILED"
             Results: {TotalErrors: 3,
               AlertCount: {Failure: 0, Error: 1, Warning: 0}, ...}
             Children:
               - Name: "UART_REQ_1"
                 Status: "FAILED"
                 Results: {TotalErrors: 1,
                   PassedCount: 1, AffirmCount: 1,
                   RequirementsPassed: 1, RequirementsGoal: 2, ...}

      ``TbReq2`` has one failed check (an error), one disabled warning and two requirements that didn't reach their
      goal: ``TotalErrors`` is 1 + 1 + 2 = 4. The ``Requirements`` entry counts the error of its child and the two
      requirements: 3. (The example's flow mappings are wrapped for the page; the file has one line per
      ``Results``.)


.. _YAML/AlertLog/Status:

Status
******

.. grid:: 2

   .. grid-item::
      :columns: 6

      The top level's ``Status`` is the first that applies:

      #. ``STOPLIMIT`` - an alert reached its stop count;
      #. ``TIMEOUT`` - ``EndOfTestReports`` was called with ``TimeOut => TRUE``;
      #. ``FAILED`` - ``TotalErrors`` isn't 0;
      #. ``MANUALCHECKS`` - the test case needs manual checks (``SetManualCheck``);
      #. ``NOCHECKS`` - no check was made (``AffirmCount`` is 0);
      #. ``PASSED``.

      An entry of ``Children`` is ``FAILED`` if its ``TotalErrors`` isn't 0, else ``PASSED``. The names come from
      OsvvmSettingsPkg (``ALERT_LOG_PASS_NAME``, ``ALERT_LOG_FAIL_NAME``, ...).

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version: "0.1"
         Name: "TbReq1"
         Status: "FAILED"
         Results: {TotalErrors: 1, ..., PassedCount: 5, AffirmCount: 5,
           RequirementsPassed: 2, RequirementsGoal: 2,
           DisabledAlertCount: {Failure: 0, Error: 0, Warning: 1}, ...}
         Settings: {ExternalErrors: {Failure: 0, Error: 0, Warning: 0},
           FailOnDisabledErrors: "true",
           FailOnRequirementErrors: "true",
           FailOnWarning: "true"}

      All checks of ``TbReq1`` passed and both requirements reached their goal, but a disabled warning counts as an
      error: ``FailOnDisabledErrors`` and ``FailOnWarning`` are ``true``.


.. _YAML/AlertLog/Hierarchy:

Hierarchy
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``Children`` lists OSVVM's predefined IDs first, then the testbench's IDs in the order they were created, each
      with the IDs below it:

      ``VHDL Asserts``
         VHDL's own ``assert`` and ``report`` statements, if the simulator supports VHDL-2019's assert API and
         AlertLogPkg prints them (``PrintVhdlAssertErrors``). It has no checks and no children.

      ``Default``, ``OSVVM``
         Alerts without an ID, and OSVVM's own alerts.

      ``Requirements``
         Parent of the requirements created with ``GetReqID``. Only written if the test case has requirements.

      Further IDs
         The testbench's IDs (``NewID``, ``GetAlertLogID``), with their own children.

      An ID whose report mode is ``DISABLED`` is left out, with the IDs below it.

   .. grid-item::
      :columns: 6

      .. tree::

         - ``TbReq1`` | top level: the test case
           - ``VHDL Asserts``
           - ``Default``
           - ``OSVVM``
           - ``Requirements``
             - ``UART_REQ_1`` | goal 2, passed 2
             - ``UART_REQ_2`` | goal 1, passed 1
           - ``Uart``
             - ``Tx``
             - ``Rx`` | one disabled warning


.. _YAML/AlertLog/Readers:

Readers
*******

* :ref:`RUFF/osvvm/Simulate2Html` calls :ref:`RUFF/osvvm/Alert2Html`, which writes the alert section of the test case
  report from all keys: the top level's results and settings as a summary table, the hierarchy as a table with one row
  per ID (:ref:`RPT/HTML/TestCase/Alerts`).
* `pyEDAA.OSVVM <https://github.com/edaa-org/pyEDAA.OSVVM>`__ reads the file into a data model
  (``pyEDAA.OSVVM.AlertLog.Document``): ``Version`` and the hierarchy with its ``Results``.
