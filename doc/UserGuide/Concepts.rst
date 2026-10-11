.. _UG/Concepts:

Concepts
########

.. _UG/Concepts/Directories:

Directories
***********

.. _UG/Concepts/CurrentSimulationDirectory:

Simulation Directory
====================

.. grid:: 2

   .. grid-item::
      :columns: 6

      The simulation directory is the directory in which the simulator runs. OSVVM keeps its absolute path in the
      variable ``::osvvm::CurrentSimulationDirectory``.

      Simulators write library mappings and other files into this directory, and OSVVM puts its output there: the
      libraries (:file:`VHDL_LIBS`), the build results and reports, and :file:`index.html` with an overview of all
      builds.

      Create a separate directory for simulations, for example :file:`sim` or :file:`temp` next to
      :file:`OsvvmLibraries`. Cleaning up is then just deleting and recreating it.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         > :file:`OsvvmLibraries`
         - :file:`sim` | CurrentSimulationDirectory
           - :file:`VHDL_LIBS`
             > :file:`<ToolName>-<Version>` | compiled libraries
           > :file:`<BuildName>` | results of a build
           - :file:`index.html` | all builds
           - :file:`index.yml`

.. _UG/Concepts/CurrentWorkingDirectory:

Working Directory
=================

.. grid:: 2

   .. grid-item::
      :columns: 6

      The working directory is the directory of the script that is currently running. OSVVM keeps it in the variable
      ``::osvvm::CurrentWorkingDirectory``.

      All OSVVM commands that take a path resolve a relative path against the working directory. So a script names its
      files relative to its own location, no matter from where it is called.

      :ref:`RUFF/osvvm/include` and :ref:`RUFF/osvvm/build` set the working directory to the directory of the script
      they run, and restore it afterwards.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # File: OsvvmLibraries/AXI4/Axi4/src/build.pro
         # The working directory is .../AXI4/Axi4/src
         analyze Axi4Manager.vhd
         analyze Axi4Subordinate.vhd

.. _UG/Concepts/NoCd:

Don't use Tcl's ``cd``
======================

.. grid:: 2

   .. grid-item::
      :columns: 6

      .. caution::

         Don't use Tcl's ``cd``.

      ``cd`` changes the simulation directory and loses the library mappings and other information the simulator keeps
      there. To work relative to another directory inside a script, change the working directory with
      :ref:`RUFF/osvvm/ChangeWorkingDirectory`; like ``cd``, it accepts a relative or an absolute path.

      To get a path relative to the working directory, for a command or for Tcl, use
      :ref:`RUFF/osvvm/JoinWorkingDirectory`.

      If you used ``cd`` anyway, :ref:`RUFF/osvvm/LinkCurrentLibraries` maps all libraries OSVVM knows into the new
      simulation directory.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         ChangeWorkingDirectory src
         analyze Axi4Manager.vhd

      .. code-block:: tcl

         LinkLibraryDirectory [JoinWorkingDirectory RelativePath]

.. _UG/Concepts/NoSource:

Don't use Tcl's ``source`` or a simulator's ``do``
==================================================

.. grid:: 2

   .. grid-item::
      :columns: 6

      .. caution::

         Don't use Tcl's ``source`` or a simulator's ``do`` to run OSVVM scripts.

      :ref:`RUFF/osvvm/include` runs a script with ``source`` (or ``do`` for a :file:`*.do` file), but it also sets the
      working directory to the script's directory and restores it afterwards. With ``source`` or ``do``, the script
      would have to manage its paths itself.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # Instead of:  source ../src/build.pro
         include ../src

.. _UG/Concepts/BuildInclude:

Builds and Includes
*******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/include` runs another script. Scripts are composed hierarchically like the design: a script
      includes the scripts of its sub-directories.

      :ref:`RUFF/osvvm/build` is :ref:`RUFF/osvvm/include` plus a logging point. It's called from the simulator's
      console (or a start-up script) to run a script and:

      * starts a new log file for everything the script and the simulator print,
      * collects the results of all test suites and test cases the script runs,
      * creates the build reports when the script finishes (see :ref:`RPT`).

      A :ref:`RUFF/osvvm/build` inside a running build acts like :ref:`RUFF/osvvm/include`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # In the simulator's console:
         build ../OsvvmLibraries/OsvvmLibraries.pro

      .. code-block:: tcl

         # Inside a script:
         include ./osvvm/osvvm.pro
         include ./Common

.. _UG/Concepts/BuildName:

Build Name and Output
=====================

.. grid:: 2

   .. grid-item::
      :columns: 6

      The build name is derived from the script: ``<directory>_<script>``, where ``<directory>`` is the name of the
      directory containing the script. If both names are equal, the build name is just the script name. A script can
      set another name with :ref:`RUFF/osvvm/BuildName`.

      All results of a build go into a directory of that name in the simulation directory:

      * :file:`<BuildName>.html`, :file:`.xml`, :file:`.yml`: the build summary report (HTML), as JUnit XML and as YAML;
      * :file:`logs/`: the log file of the build, as text and as HTML;
      * :file:`reports/<TestSuite>/`: one report per test case;
      * :file:`results/<TestSuite>/`: files the test cases write.

      :ref:`RUFF/osvvm/OpenBuildHtml` opens the build summary report of the last build.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # in directory "example"
         build ../RunExample.pro

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`example_RunExample`
           - :file:`example_RunExample.html`
           - :file:`example_RunExample.xml`
           - :file:`example_RunExample.yml`
           - :file:`logs`
             - :file:`example_RunExample.log`
             - :file:`example_RunExample_log.html`
           - :file:`reports`
             - :file:`Example`
               - :file:`TbExample.html`
           - :file:`results`
             > :file:`Example`

.. _UG/Concepts/Tests:

Test Suites and Test Cases
**************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      A build runs test cases, grouped into test suites. The reports summarize the build per test suite and per test
      case.

      * :ref:`RUFF/osvvm/TestSuite` starts a test suite. Test cases outside a test suite belong to the test suite
        ``Default``.
      * A test case is one simulation. Its name is the name of the simulated design unit, or the name set with
        :ref:`RUFF/osvvm/TestName` before :ref:`RUFF/osvvm/simulate`.
      * The test case name must match the name the testbench sets with ``SetTestName`` (OSVVM's
        ``SetAlertLogName``). Otherwise, the test case fails, unless the setting ``FailOnVhdlNameNotMatchTestName`` is
        ``false``.
      * :ref:`RUFF/osvvm/RunTest` combines :ref:`RUFF/osvvm/analyze`, :ref:`RUFF/osvvm/TestName` and
        :ref:`RUFF/osvvm/simulate` for a file whose design unit has the same name as the file.
      * :ref:`RUFF/osvvm/SkipTest` lists a test case as skipped, with a reason, in the reports.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         TestSuite Axi4Full
         library   osvvm_TbAxi4

         analyze   TestCtrl_e.vhd
         analyze   TbAxi4.vhd

         RunTest   TbAxi4_BasicReadWrite.vhd
         RunTest   TbAxi4_RandomReadWrite.vhd
         SkipTest  TbAxi4_Interrupt.vhd "Not ready yet"
