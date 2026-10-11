.. _RPT/XML:

JUnit XML Report
################

.. grid:: 2

   .. grid-item::
      :columns: 6

      The JUnit XML build summary report is for continuous integration (CI/CD). CI/CD tools read it to decide whether
      the tests passed, and many of them can display it. The :ref:`HTML build summary report <RPT/HTML/BuildSummary>`
      shows a superset of its information.

      The report is :file:`<BuildName>/<BuildName>.xml`, written next to the HTML build summary report by
      :ref:`RUFF/osvvm/CreateBuildReports` at the end of a :ref:`RUFF/osvvm/build`.
      :ref:`RUFF/osvvm/Report2Junit` creates it alone from the build's YAML file.

      OSVVM runs its own regressions on GitHub and collects these files there.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         build ../OsvvmLibraries/RunDemoTests.pro
         # creates
         #   OsvvmRunDemoTests/OsvvmRunDemoTests.xml

         # again from the build's YAML file
         set Build OsvvmRunDemoTests
         Report2Junit $Build/$Build.yml


.. _RPT/XML/Structure:

Structure
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``<testsuites>``
         The build: its name, start time, duration and the counts of test cases, failures, errors and skipped test
         cases. Its ``<properties>`` name the OSVVM version, the simulator and the simulator's version.

      ``<testsuite>``
         A test suite (:ref:`RUFF/osvvm/TestSuite`), with its counts.

      ``<testcase>``
         A test case: its name, its test suite as ``classname``, the number of checks as ``assertions``, and its
         duration. Generics set with :ref:`RUFF/osvvm/generic` are ``<property name="generic">`` entries.

      ``<failure>``, ``<skipped>``
         A failed test case, with the reason; a test case skipped with :ref:`RUFF/osvvm/SkipTest`.

   .. grid-item::
      :columns: 6

      .. code-block:: xml

         <?xml version="1.0" encoding="utf-8"?>
         <testsuites
            name="OsvvmLibraries_RunAllTests"
            timestamp="2026-10-10T16:50:50+00:00"
            time="99.883"
            tests="314"
            failures="0"
            errors="0"
            skipped="0"
         >
         <properties>
           <property name="OsvvmVersion" value="2026.09" />
           <property name="Simulator" value="NVC" />
           <property name="SimulatorVersion" value="1.23.0" />
         </properties>
         <testsuite
            name="StreamTransactionPkg"
            time="3.923"
            tests="15"
            failures="0"
            errors="0"
            skipped="0"
         >
         <testcase
            name="TbStream_SendGet1"
            classname="StreamTransactionPkg"
            assertions="1296"
            time="0.317"
         >
         </testcase>
         ...
         </testsuite>
         </testsuites>
