.. _GLOSSARY:

Glossary
########

.. glossary::

   Affirmation
     An *affirmation* is a self-check of a testbench: ``AffirmIf``, ``AffirmIfEqual`` and their siblings of OSVVM's
     ``AlertLogPkg`` count a passed check, or raise an :term:`alert` of level ``ERROR`` for a failed one. With an
     :acs:`ID` of a :term:`requirement`, an affirmation counts for that requirement. The counts are in the AlertLog
     report (see :ref:`YAML/AlertLog`).

     See also: :osvvmdoc:`AlertLogPkg user guide <AlertLogPkg_user_guide>`

   Alert
     An *alert* is a message of a testbench, which counts as a problem: ``Alert`` of OSVVM's ``AlertLogPkg`` raises
     one of level ``FAILURE``, ``ERROR`` or ``WARNING``, counted per AlertLog :acs:`ID`. A :term:`test case` with an
     error count other than 0 fails. The alert counts are in the AlertLog report (see :ref:`YAML/AlertLog` and
     :ref:`RPT/HTML/TestCase/Alerts`).

     See also: :osvvmdoc:`AlertLogPkg user guide <AlertLogPkg_user_guide>`

   Analyze
   Analysis
     *Analysis* is the compilation of a :acs:`VHDL` (or Verilog) file into a :term:`library`: the simulator checks the
     file and stores its design units. :ref:`RUFF/osvvm/analyze` analyzes a file into the active library (see
     :ref:`UG/Scripts/SimpleTest` and :ref:`UG/Options/Analyze`).

   Build
     A *build* is a run of a :term:`build script` with :ref:`RUFF/osvvm/build`. It writes a log file, collects the
     results of its :term:`test suites <test suite>` and :term:`test cases <test case>`, and creates the build reports
     in a directory named after its :term:`build name` (see :ref:`UG/Concepts/BuildInclude` and :ref:`RPT`).

   Build Name
     The *build name* names a :term:`build`, its directory in the :term:`simulation directory` and its reports. It is
     derived from the :term:`build script`'s directory and file name, or set with :ref:`RUFF/osvvm/BuildName` (see
     :ref:`UG/Concepts/BuildName`).

   Build Script
   Project Script
     A *build script* is a :acs:`Tcl` file named :file:`*.pro`, which uses OSVVM's commands to activate libraries,
     analyze files and run test cases. Build scripts include each other hierarchically, like the design (see
     :ref:`UG/Scripts`).

   Cobertura XML
     *Cobertura XML* is the :acs:`XML` report format of the Java code coverage tool
     `Cobertura <https://cobertura.github.io/cobertura/>`__, which many :acs:`CI` tools and coverage services read.
     :ref:`RUFF/osvvm/ExportCodeCoverage` writes the :term:`code coverage` of an NVC build in this format (see
     :ref:`UG/CodeCoverage/Export`).

   Code Coverage
     *Code coverage* tells which parts of a design's code the simulation exercised. The simulator collects it per
     :term:`coverage kind`; OSVVM merges it per :term:`test suite` and :term:`build`, links the simulator's report and
     exports it as :term:`Cobertura XML` or another :acs:`XML` format (see :ref:`UG/CodeCoverage`). Unlike
     :term:`functional coverage`, it is collected without a model in the testbench.

   Coverage Kind
     A *coverage kind* is one metric of :term:`code coverage`: ``statement``, ``branch``, ``condition``,
     ``expression``, ``toggle``, ``fsm`` (:acs:`FSM` states) or ``functional``. :ref:`RUFF/osvvm/SetCoverageKinds`
     selects the kinds; the :term:`vendor script` translates them into the simulator's options (see
     :ref:`UG/CodeCoverage/Kinds`).

   Design Unit
     A *design unit* is a :acs:`VHDL` construct analyzed into a :term:`library` on its own, like an entity, an
     architecture, a package or a configuration. A :term:`test case` simulates the design unit of its top level.

   Elaborate
   Elaboration
     *Elaboration* builds the design hierarchy of a top-level :term:`design unit`, before the simulation runs.
     :ref:`RUFF/osvvm/simulate` elaborates and simulates; some simulators, like NVC, instrument the design for
     :term:`code coverage` at elaboration (see :ref:`UG/CodeCoverage/Options`).

   Functional Coverage
     *Functional coverage* measures which values and conditions of the verification plan a testbench has exercised.
     The testbench describes them as coverage models with bins and goals, using OSVVM's ``CoveragePkg``. The models are
     written into a :acs:`YAML` file per :term:`test case` (see :ref:`YAML/FunctionalCoverage` and
     :ref:`RPT/HTML/TestCase/Coverage`).

     See also: :osvvmdoc:`CoveragePkg user guide <CoveragePkg_user_guide>`

   Generic
     A *generic* is a parameter of a :acs:`VHDL` design unit. :ref:`RUFF/osvvm/generic` sets a top-level generic for
     the next simulation; the generics become part of the :term:`test case file name` (see :ref:`UG/Generics`).

   GTKWave
     *GTKWave* is an open-source waveform viewer (`GTKWave <https://gtkwave.github.io/gtkwave/>`__). It displays the
     waveform files :acs:`GHDL` and NVC write with :ref:`RUFF/osvvm/SetSaveWaves` (see :ref:`UG/Waveform/SaveWaves`).

   JUnit XML
     *JUnit XML* is the :acs:`XML` test report format of the Java test framework
     `JUnit <https://junit.org/>`__, which most :acs:`CI` tools read. OSVVM writes the build summary report of a
     :term:`build` also in this format (see :ref:`RPT/XML`).

   Library
     A *library* is a :acs:`VHDL` design library: a named collection of analyzed :term:`design units <design unit>`.
     :ref:`RUFF/osvvm/library` activates a library for the following :ref:`RUFF/osvvm/analyze` and
     :ref:`RUFF/osvvm/simulate`; the libraries are stored in the :term:`library directory` (see
     :ref:`UG/Libraries`).

   Library Directory
     The *library directory* is the directory, under which OSVVM creates the simulator's :term:`libraries <library>`,
     in :file:`VHDL_LIBS/<ToolName>-<Version>`. By default, it is the :term:`simulation directory`;
     :ref:`RUFF/osvvm/SetLibraryDirectory` selects another one (see :ref:`UG/Libraries/Directory`).

   Requirement
     A *requirement* is a feature of a specification, which a testbench checks: in VHDL, a requirement :acs:`ID`
     created with ``NewReqID`` and used in :term:`affirmations <affirmation>`. OSVVM writes the requirements of each
     :term:`test case` into a :acs:`YAML` file, merges them per :term:`test suite` and :term:`build`, and reports them
     as :acs:`HTML` and :acs:`CSV` (see :ref:`UG/Requirements` and :ref:`RPT/REQ`).

   Scoreboard
     A *scoreboard* is a data structure, which compares the values a design produces with the expected ones. OSVVM's
     ``ScoreboardGenericPkg`` keeps the expected values in a :acs:`FIFO` and counts the checked, dropped and failed
     items; a :term:`test case` writes these counts into a :acs:`YAML` file per scoreboard package (see
     :ref:`YAML/ScoreBoard` and :ref:`RPT/HTML/TestCase/Scoreboards`).

     See also: :osvvmdoc:`ScoreboardPkg user guide <ScoreboardPkg_user_guide>`

   Settings File
     A *settings file* is a :acs:`Tcl` file, which sets OSVVM's variables. OSVVM loads its defaults
     (:file:`OsvvmSettingsDefault.tcl`), then the local settings files :file:`OsvvmSettingsLocal.tcl` and
     :file:`OsvvmSettingsLocal_<ScriptBaseName>.tcl` of the :term:`vendor script` (see :ref:`UG/Configuration`).

   Simulation Directory
     The *simulation directory* is the directory, in which the simulator runs. OSVVM puts its libraries, the results
     of each :term:`build` and the build index there (see :ref:`UG/Concepts/CurrentSimulationDirectory`).

   Surfer
     *Surfer* is an open-source waveform viewer (`Surfer <https://surfer-project.org/>`__), also running in a web
     browser. Like :term:`GTKWave`, it displays the waveform files :acs:`GHDL` and NVC write with
     :ref:`RUFF/osvvm/SetSaveWaves` (see :ref:`UG/Waveform/SaveWaves`).

   Test Case
     A *test case* is one simulation of a testbench. It is named after the simulated :term:`design unit`, or with
     :ref:`RUFF/osvvm/TestName`; the name must match the name the testbench sets. Each test case gets its own reports
     (see :ref:`UG/Concepts/Tests` and :ref:`RPT/HTML/TestCase`).

   Test Case File Name
     The *test case file name* names a :term:`test case`'s files: its name, followed by the names and values of its
     :term:`generics <generic>`, so runs with different generics keep separate reports (see :ref:`UG/Generics`).

   Test Suite
     A *test suite* is a group of :term:`test cases <test case>`, started with :ref:`RUFF/osvvm/TestSuite`. The
     reports summarize a :term:`build` per test suite (see :ref:`UG/Concepts/Tests`).

   Testbench
     A *testbench* is the :acs:`VHDL` design, which stimulates and checks a design under test. With OSVVM, it uses the
     :term:`utility library` and :term:`verification components <verification component>`; a
     :term:`test case` simulates it.

     See also: :osvvmdoc:`OSVVM test writer's user guide <OSVVM_test_writers_user_guide>`

   Transcript
     A *transcript* is the text output of a simulation. OSVVM writes the output of a whole :term:`build` into its log
     file, and a :term:`test case` can write its own transcript with ``TranscriptOpen``; both are linked from the
     reports (see :ref:`RPT/HTML/SimTranscript` and :ref:`RPT/HTML/TestCaseTranscript`).

   Utility Library
     The *OSVVM utility library* is the :acs:`VHDL` library ``osvvm`` with OSVVM's packages: ``AlertLogPkg``,
     ``CoveragePkg``, ``ScoreboardGenericPkg``, ``RandomPkg`` and more (repository
     `OSVVM <https://github.com/OSVVM/OSVVM>`__). Its packages write the :acs:`YAML` files of each
     :term:`test case` (see :ref:`YAML`).

   Vendor Script
     A *vendor script* (:file:`VendorScripts_<ScriptBaseName>.tcl`) translates OSVVM's commands into one simulator's
     commands and options. The start-up script loads the vendor script of the running simulator (see
     :ref:`QSG/Start`).

   Verification Component
     A *verification component* (:acs:`VC`) is a :acs:`VHDL` model of an interface, like :acs:`AXI4` or :acs:`UART`,
     which a :term:`testbench` controls with transactions. Each OSVVM verification component comes with its regression
     tests (see :ref:`UG/Scripts`).

     See also: :osvvmdoc:`OSVVM verification component developer's guide
     <OSVVM_verification_component_developers_guide>`

   Working Directory
     The *working directory* is the directory of the running :term:`build script`. OSVVM's commands resolve relative
     paths against it (see :ref:`UG/Concepts/CurrentWorkingDirectory`).
