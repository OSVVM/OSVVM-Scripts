.. _YAML/ScoreBoard:

ScoreBoard
##########

.. grid:: 2

   .. grid-item::
      :columns: 6

      A test case writes the statistics of its scoreboards into one file per scoreboard package:
      :file:`<TestCaseFileName>_sb_<Name>.yml`. ``<Name>`` names the package instance of ``ScoreboardGenericPkg``,
      like ``slv`` for ``ScoreboardPkg_slv`` or ``Uart`` for the UART's ``ScoreboardPkg_Uart``.

      * **Written by:** ``WriteScoreboardYaml`` of each scoreboard package, called by ``EndOfTestReports`` (VHDL,
        ``ReportPkg``) for OSVVM's packages, or by the testbench for other packages.
      * **Location:** :file:`<BuildName>/reports/<TestSuite>/<TestCaseFileName>_sb_<Name>.yml`. The paths are
        recorded in the test case's :file:`_run.yml` as ``ScoreboardDict``, keyed by ``<Name>``.
      * **Read by:** :ref:`RUFF/osvvm/Scoreboard2Html`, called by :ref:`RUFF/osvvm/Simulate2Html`, for the scoreboard
        sections of the test case report (see :ref:`RPT/HTML/TestCase/Scoreboards`).
      * **Version:** ``Version`` is ``SCOREBOARD_YAML_VERSION`` of ``OsvvmScriptSettingsPkg``, ``"0.1"``.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # TbUart_Scoreboard1_sb_Uart.yml
         Version: "0.1"
         TestCase: "TbUart_Scoreboard1"
         Scoreboards:
           - Name:         "UART_SB1"
             ParentName:   "OSVVM"
             ItemCount:    137
             ErrorCount:   92
             ItemsChecked: 137
             ItemsPopped:  137
             ItemsDropped: 0
             FifoCount:    0


.. _YAML/ScoreBoard/Writing:

Writing the Files
*****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``EndOfTestReports`` writes a file for each of OSVVM's scoreboard packages, which has scoreboards
      (``GotScoreboards``): ``slv``, ``unsigned``, ``signed``, ``int`` and ``IntV``.

      A scoreboard package of a verification component or a testbench, created from ``ScoreboardGenericPkg``, writes
      its file only when the testbench calls its ``WriteScoreboardYaml``, before ``EndOfTestReports``.

      ``FileName`` is a base name: the file is :file:`<TestName>_sb_<FileName>.yml` in OSVVM's temporary directory
      (``OSVVM_TEMP_OUTPUT_DIRECTORY``). This holds while the setting ``SCOREBOARD_YAML_IS_BASE_FILE_NAME`` is ``TRUE``,
      the default since settings revision 2024; with ``FALSE``, ``FileName`` is used as given. Without ``FileName``,
      the file is :file:`<TestName>_sb.yml`.

      When the simulation is done, the scripts move every :file:`<TestName>_sb_*.yml` into the test suite's reports
      directory, named after the test case file name, which includes the generics (see :ref:`UG/Generics`).

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         -- testbench with its own scoreboard package
         osvvm_uart.ScoreboardPkg_Uart.WriteScoreboardYaml(FileName => "Uart") ;
         EndOfTestReports ;  -- writes _sb_slv.yml, ... for OSVVM's packages

      .. code-block:: text

         OsvvmTemp_NVC/TbUart_Scoreboard1_sb_Uart.yml
           -> <BuildName>/reports/UART/TbUart_Scoreboard1_sb_Uart.yml


.. _YAML/ScoreBoard/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``Scoreboards`` lists every scoreboard of the package, in the order they were created. The counters are those
      of the scoreboard's ``Get*Count`` functions.

      .. tree::

         - ``Version`` | format version: string, ``"0.1"``
         - ``TestCase`` | name of the test case that wrote the file
         - ``Scoreboards`` | list of the package's scoreboards
           - ``Name`` | the scoreboard's name (its AlertLog name)
           - ``ParentName`` | name of the scoreboard's AlertLog parent, like the verification component
           - ``ItemCount`` | number of items pushed (``GetItemCount``, ``GetPushCount``)
           - ``ErrorCount`` | number of errors: mismatches of checked items, checks or pops of an empty scoreboard
           - ``ItemsChecked`` | number of items checked (``GetCheckCount``)
           - ``ItemsPopped`` | number of items popped (``GetPopCount``)
           - ``ItemsDropped`` | number of items dropped by ``Find``/``Flush`` (``GetDropCount``)
           - ``FifoCount`` | number of items still in the scoreboard (``GetFifoCount``)

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # TbAxi_SetBurstMode1_sb_slv.yml
         Version: "0.1"
         TestCase: "TbAxi_SetBurstMode1"
         Scoreboards:
           - Name:         "TransmitFifo"
             ParentName:   "transmitter_1"
             ItemCount:    0
             ErrorCount:   0
             ItemsChecked: 0
             ItemsPopped:  0
             ItemsDropped: 0
             FifoCount:    0
           - Name:         "ReceiveFifo"
             ParentName:   "receiver_1"
             ItemCount:    0
             ErrorCount:   0
             ItemsChecked: 0
             ItemsPopped:  0
             ItemsDropped: 0
             FifoCount:    0
           # ... TxBurstFifo, RxBurstFifo


.. _YAML/ScoreBoard/Readers:

Readers
*******

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/Simulate2Html` calls :ref:`RUFF/osvvm/Scoreboard2Html` once per entry of the test case's
      ``ScoreboardDict``. :ref:`RUFF/osvvm/Scoreboard2Html` writes one table per file: the header from the keys of the
      first scoreboard, one row per scoreboard, the values in the order of the keys. It reads ``Version`` and
      ``Scoreboards``; ``TestCase`` isn't read.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         # TbStream_SendGetDemo1_run.yml (excerpt)
         CovYamlFile:  "reports/AxiStream_VTI/TbStream_SendGetDemo1_cov.yml"
         ScoreboardDict:
           slv: "reports/AxiStream_VTI/TbStream_SendGetDemo1_sb_slv.yml"
