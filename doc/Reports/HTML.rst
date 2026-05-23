.. _RPT/HTML:

HTML Reports
############



Overview
********

OSVVM produces the following reports:

* HTML Build Summary Report for human inspection that provides test completion status.
* HTML Test Case Detailed report for each test case with Alert, Functional Coverage, and Scoreboard reports.
* HTML based simulator transcript/log files (simulator output)
* Text based test case transcript file (from TranscriptOpen)


Build Index
***********

.. todo::

   Experimental Feature - Undocumented


Build Summary Report
********************

The Build Summary Report allows us to quickly confirm if a
build passed or quickly identify which test cases did not PASS.

The Build Summary Report has three distinct pieces:

- Build Status
- Test Suite Summary
- Test Case Summary

For each Test Suite and Test Case, there is additional information,
such as Functional Coverage and Disabled Alert Count.

In the sim directory, the Build Summary Report is
in the file OsvvmLibraries_RunDemoTests.html.
It can be opened by typing OpenBuildHtml at the simulator command line.

.. figure:: images/DemoBuildSummaryReport.png
   :name: BuildSummaryReportFig
   :scale: 25 %
   :align: center

   Build Summary Report

Note that any place in the report there is a triangle preceding text,
pressing on the triangle will rotate it and either hide or reveal
additional information.

Build Status
============

The Build Status, shown below, is in a table at the top of the
Build Summary Report.
If code coverage is run, there will be a link to
the results at the bottom of the Build Summary Report.

.. figure:: images/DemoBuildStatus.png
   :name: BuildStatusFig
   :scale: 50 %
   :align: center

   Build Status

Test Suite Summary
==================

When running tests, test cases are grouped into test suites.
A build can include multiple test suites.
The next table we see in the Build Summary Report is the
Test Suite Summary.
The figure below shows
that this build includes the test suites Axi4Full, AxiStream, and UART.

.. figure:: images/DemoTestSuiteSummary.png
   :name: TestSuiteSummaryFig
   :scale: 50 %
   :align: center

   Test Suite Summary


Test Case Summary
=================

The remainder of the Build Summary Report is Test Case Summary, see below.
There is a seprate Test Case Summary for each test suite in the build.

.. figure:: images/DemoTestCaseSummaries.png
   :name: TestCaseSummaryFig
   :scale: 50 %
   :align: center

   Test Case Summary

Testcase Detailed Report
************************

For each test case that is run (simulated),
a Test Case Detailed Report is produced that
contains consists of the following information:

- Test Information Link Table
- Alert Report
- Functional Coverage Report(s)
- Scoreboard Report(s)
- Link to Test Case Transcript (opened with Transcript Open)
- Link to this test case in HTML based simulator transcript

After running one of the regressions, open one of the HTML files
in the directory ./reports/<test-suite-name>.  An example one is shown below.

.. figure:: images/DemoTestCaseDetailedReport.png
   :name: TestCaseDetailedFig
   :scale: 50 %
   :align: center

   Test Case Detailed Report


Note that any place in the report there is a triangle preceding text,
pressing on the triangle will rotate it and either hide or reveal
additional information.


Test Information Link Table
===========================

The Test Information Link Table is in a table at the top of the
Test Case Detailed Report.
The figure below has links to the Alert Report (in this file),
Functional Coverage Report (in this file),
Scoreboard Reports (in this file),
a link to simulation results (if the simulation report is in HTML),
and a link to any transcript files opened by OSVVM.

.. figure:: images/DemoTestCaseLinks.png
   :name: TestInfoFig
   :scale: 50 %
   :align: center

   Test Information Link Table


Alert Report
============

The Alert Report, shown below, provides detailed information for each AlertLogID
that is used in a test case.  Note that in the case of expected errors, the errors
still show up as FAILED in the Alert Report and are rectified in the total error count.

.. figure:: images/DemoAlertReport.png
   :name: AlertFig
   :scale: 50 %
   :align: center

   Alert Report


Functional Coverage Report
==========================

The Test Case Detailed Report contains a
Functional Coverage Report, shown below, for each
functional coverage model used in the test case.
Note this report is not from the demo.

.. figure:: images/CoverageReport.png
   :name: FunctionalCoverageFig
   :scale: 50 %
   :align: center

   Functional Coverage Report

Scoreboard Report
=================

The Test Case Detailed Report contains a
Scoreboard Report, shown below. There is
a row in the table for each
scoreboard model used in the test case.

.. figure:: images/DemoScoreboardReport.png
   :name: ScoreboardFig
   :scale: 50 %
   :align: center

   Scoreboard Report


Test Case Transcript
====================

OSVVM's transcript utility facilitates collecting all
test output to into a single file, as shown below.

.. figure:: images/DemoVHDLTranscript.png
   :name: TestCaseTranscriptFig
   :scale: 50 %
   :align: center

   Test Case Transcript


Simulator Transcript
********************

Simulator transcript files can be long.
The basic OSVVM regression test (OsvvmLibraries/RunAllTests.pro),
produces a log file that is 84K lines long.
As a plain text file, this is not browsable, however,
when converted to an html file it is.
OSVVM gives you the option to create either html (default), shown below, or plain text.
In the html report, any place there is a triangle preceding text,
pressing on the triangle will rotate it and either hide or reveal
additional information.

.. figure:: images/DemoSimTranscript.png
   :name: SimTranscriptFig
   :scale: 50 %
   :align: center

   HTML Simulator Transcript