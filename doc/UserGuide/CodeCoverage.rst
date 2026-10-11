.. _UG/CodeCoverage:

Code Coverage
#############

Code coverage tells which parts of a design were exercised by the tests. OSVVM collects it per test case, merges it
per test suite and per build, links the simulator's HTML coverage report from the build report (see :ref:`RPT`), and
can export it into a well-known data format, like Cobertura XML.

Code coverage is supported for the Aldec simulators (Active-HDL, Riviera-PRO, VSimSA), the Siemens simulators
(ModelSim, QuestaSim, Visualizer) and NVC.

.. _UG/CodeCoverage/Enable:

Turning on Code Coverage
************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Coverage is enabled separately for analysis and simulation:

      * :ref:`RUFF/osvvm/SetCoverageAnalyzeEnable` instruments the files analyzed while it's ``true``. Turn it off
        before analyzing the testbench, so the testbench isn't part of the coverage.
      * :ref:`RUFF/osvvm/SetCoverageSimulateEnable` collects coverage in the simulations started while it's ``true``.

      Both are ``false`` by default, so simulations run fast. :ref:`RUFF/osvvm/SetCoverageEnable` (default ``true``)
      switches both off at once without changing them. All three accept any Tcl boolean (``true``, ``yes``, ``on``,
      ``1``, ...).

      NVC instruments a design at elaboration, not at analysis. With NVC, :ref:`RUFF/osvvm/SetCoverageAnalyzeEnable`
      has no effect: the whole design, including the testbench, is covered.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: Dut.pro
         SetCoverageAnalyzeEnable true
         analyze   Dut.vhd
         SetCoverageAnalyzeEnable false

         SetCoverageSimulateEnable true
         analyze   TbDut.vhd
         simulate  TbDut
         SetCoverageSimulateEnable false

.. _UG/CodeCoverage/Kinds:

Kinds of Code Coverage
**********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/SetCoverageKinds` selects the kinds of code coverage independent of the simulator; the vendor
      script translates them into the simulator's options. ``all`` stands for all kinds, ``default`` for the kinds in
      the setting ``DefaultCoverageKinds``: statement, branch and state machine coverage. A kind the simulator doesn't
      support is left out; an unknown kind is an error. :ref:`RUFF/osvvm/GetCoverageKinds` returns the current kinds.

      .. list-table::
         :header-rows: 1

         * - Kind
           - NVC (elaborate)
           - Siemens (analyze)
           - Aldec (analyze, simulate)
         * - ``statement``
           - ``statement``
           - ``s``
           - ``s``
         * - ``branch``
           - ``branch``
           - ``b``
           - ``b``
         * - ``condition``
           - ``expression``
           - ``c``
           - ``c``
         * - ``expression``
           - ``expression``
           - ``e``
           - ``e``
         * - ``toggle``
           - ``toggle``
           - ``t``
           - -
         * - ``fsm``
           - ``fsm-state``
           - ``f``
           - ``m``
         * - ``functional``
           - ``functional``
           - -
           - -

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetCoverageKinds all                  ;# all kinds
         SetCoverageKinds {default toggle}     ;# statement branch fsm toggle
         SetCoverageKinds                      ;# back to the default kinds

         puts [GetCoverageKinds]
         # statement branch fsm

.. _UG/CodeCoverage/Options:

Coverage Options
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The options passed to the simulator are kept per step:

      * :ref:`RUFF/osvvm/SetCoverageAnalyzeOptions` - used by :ref:`RUFF/osvvm/analyze`;
      * :ref:`RUFF/osvvm/SetCoverageElaborateOptions` - used by the elaboration in :ref:`RUFF/osvvm/simulate`;
      * :ref:`RUFF/osvvm/SetCoverageSimulateOptions` - used by :ref:`RUFF/osvvm/simulate`.

      Their defaults come from the vendor script, built from the kinds. :ref:`RUFF/osvvm/SetCoverageKinds` sets all
      three to the vendor's defaults for the new kinds, replacing options set before. Options set afterwards are passed
      to the simulator as given, so a simulator option without a kind is still possible. The ``Get`` commands
      (:ref:`RUFF/osvvm/GetCoverageAnalyzeOptions`, :ref:`RUFF/osvvm/GetCoverageElaborateOptions`,
      :ref:`RUFF/osvvm/GetCoverageSimulateOptions`) return the current options.

   .. grid-item::
      :columns: 6

      .. tab-set::

         .. tab-item:: Riviera-PRO
            :sync: RivieraPRO

            .. code-block:: tcl

               # Defaults (default kinds)
               SetCoverageAnalyzeOptions  "-coverage sbm"
               SetCoverageSimulateOptions "-acdb_cov sbm -cc_all"

         .. tab-item:: Active-HDL
            :sync: ActiveHDL

            .. code-block:: tcl

               # Defaults (default kinds)
               SetCoverageAnalyzeOptions  "-coverage sbm"
               SetCoverageSimulateOptions "-acdb -acdb_cov sbm -cc_all"

         .. tab-item:: QuestaSim
            :sync: QuestaSim

            .. code-block:: tcl

               # Defaults (default kinds)
               SetCoverageAnalyzeOptions  "+cover=sbf"
               SetCoverageSimulateOptions "-coverage"

               # Own options instead of the kinds
               SetCoverageAnalyzeOptions  "+cover=bcst"

         .. tab-item:: NVC
            :sync: NVC

            .. code-block:: tcl

               # Defaults (default kinds)
               SetCoverageElaborateOptions "--cover=statement,branch,fsm-state"

               # Own options instead of the kinds
               SetCoverageElaborateOptions "--cover=statement"

.. _UG/CodeCoverage/NVC:

NVC's Further Coverage Options
******************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      NVC has further code coverage options, which aren't kinds, like ``fsm-no-default-enums`` or
      ``count-from-undefined``. The variable ``NvcExtendedCoverageOptions`` holds them as a space separated list; they
      are appended to NVC's ``--cover=`` option when the elaborate options are built from the kinds.

      Set the variable in :file:`OsvvmSettingsLocal_NVC.tcl` (see :ref:`UG/Configuration`), then build the elaborate
      options again: with ``vendor_SetCoverageElaborateDefaults`` or with :ref:`RUFF/osvvm/SetCoverageKinds`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: OsvvmSettingsLocal_NVC.tcl
         namespace eval ::osvvm {
           variable NvcExtendedCoverageOptions "fsm-no-default-enums count-from-undefined"
           variable CoverageElaborateOptions   [vendor_SetCoverageElaborateDefaults]
         }

         # --cover=statement,branch,fsm-state,fsm-no-default-enums,count-from-undefined

.. _UG/CodeCoverage/Merge:

Merging and Reports
*******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      With coverage on, each test case writes its coverage database. When a test suite completes, the databases of
      its test cases are merged; when the build completes, the databases of all test suites are merged and the
      simulator writes its HTML coverage report, which the build report links.

      All of it is in :file:`<BuildName>/CodeCoverage/` of the simulation directory.

   .. grid-item::
      :columns: 6

      .. tab-set::

         .. tab-item:: QuestaSim
            :sync: QuestaSim

            .. tree::
               :root-icon: 📁
               :node-icon: 📁
               :leaf-icon: 📄
               :icons:     > 📁

               - :file:`<BuildName>`
                 - :file:`CodeCoverage`
                   - :file:`<TestSuite>`
                     - :file:`<TestCaseFileName>.ucdb` | per test case
                   - :file:`<BuildName>`
                     - :file:`<TestSuite>.ucdb` | merged per test suite
                   - :file:`<BuildName>.ucdb` | merged for the build
                   > :file:`<BuildName>_code_cov` | HTML report

         .. tab-item:: NVC
            :sync: NVC

            .. tree::
               :root-icon: 📁
               :node-icon: 📁
               :leaf-icon: 📄
               :icons:     > 📁

               - :file:`<BuildName>`
                 - :file:`CodeCoverage`
                   - :file:`<TestSuite>`
                     - :file:`<TestCaseFileName>.ncdb` | per test case
                   - :file:`<BuildName>`
                     - :file:`<TestSuite>.ncdb` | merged per test suite
                   - :file:`<BuildName>.ncdb` | merged for the build
                   - :file:`<BuildName>_code_cov`
                     - :file:`index.html` | HTML report

.. _UG/CodeCoverage/Export:

Exporting Code Coverage
***********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/ExportCodeCoverage` exports the code coverage of the last build that collected code coverage
      into a well-known data format, for CI tools and coverage services. The file name is optional; options for this
      export are added with :ref:`RUFF/osvvm/ExportOptions`, written as an argument like :ref:`RUFF/osvvm/generic`.

      :ref:`RUFF/osvvm/SetCoverageExportEnable` exports at the end of every build that collected code coverage (off
      by default). :ref:`RUFF/osvvm/SetCoverageExportOptions` sets the options of every export.

      .. list-table::
         :header-rows: 1

         * - Simulator
           - Format
           - Default file in :file:`CodeCoverage/`
         * - NVC
           - Cobertura XML
           - :file:`<BuildName>_code_cov.cobertura.xml`
         * - Siemens
           - coverage report XML
           - :file:`<BuildName>_code_cov.questa.xml`
         * - Aldec
           - UCDB XML
           - :file:`<BuildName>_code_cov.ucdb.xml`

      Other simulators print that the export isn't supported yet.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # at the end of every build
         SetCoverageExportEnable  true
         SetCoverageExportOptions "--relative=.."

         build ../OsvvmLibraries/RunDemoTestsWithCoverage.pro

         # once more, into another file, with one more option
         ExportCodeCoverage coverage.xml [ExportOptions "--relative=."]
