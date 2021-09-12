import sys
from pathlib import Path
from typing import Dict
from xml.dom.minidom import Document as XMLDocument, Element

from ruamel.yaml import YAML


def main(yamlReportFile: Path, xmlReportFile: Path):
	yamlReader = YAML()
	yamlReport = yamlReader.load(yamlReportFile)
	yamlBuild = yamlReport["Build"]

	xmlReport = XMLDocument()
	xmlReportRoot = xmlReport.createElement("testsuites")
	xmlReportRoot.setAttribute("name", yamlBuild["Name"])
	xmlReport.appendChild(xmlReportRoot)

	counters = {
		"TotalTestcases": 0,
		"TotalFailures": 0,
		"TotalErrors": 0,
		"TotalDisabled": 0,

		"TestsuiteTestcases": 0,
		"TestsuiteFailures": 0,
		"TestsuiteErrors": 0,
		"TestsuiteDisabled": 0,
	}

	translateDocument(yamlReport, xmlReportRoot, counters)

	with xmlReportFile.open("w", encoding="utf-8") as xmlFile:
		xmlReport.writexml(xmlFile, addindent="  ", newl="\n", encoding="utf-8")

def translateDocument(yamlReport, xmlReportRoot: Element, counters: Dict[str, int]):
	for yamlTestsuite in yamlReport['TestSuites']:
		xmlTestsuite = xmlReportRoot.ownerDocument.createElement("testsuite")
		xmlTestsuite.setAttribute("name", yamlTestsuite["Name"])
		xmlReportRoot.appendChild(xmlTestsuite)

		translateTestsuite(yamlTestsuite, xmlTestsuite, counters)

	xmlReportRoot.setAttribute("tests", str(counters["TotalTestcases"]))
	xmlReportRoot.setAttribute("failures", str(counters["TotalFailures"]))
	xmlReportRoot.setAttribute("errors", str(counters["TotalErrors"]))
	xmlReportRoot.setAttribute("disabled", str(counters["TotalDisabled"]))


def translateTestsuite(yamlTestsuite, xmlTestsuite: Element, counters: Dict[str, int]):
	for yamlTestcase in yamlTestsuite['TestCases']:
		xmlTestcase = xmlTestsuite.ownerDocument.createElement("testcase")
		xmlTestcase.setAttribute("name", yamlTestcase["Name"])
		xmlTestsuite.appendChild(xmlTestcase)

		translateTestcase(yamlTestcase, xmlTestcase, counters)

	xmlTestsuite.setAttribute("tests", str(counters["TestsuiteTestcases"]))
	xmlTestsuite.setAttribute("failures", str(counters["TestsuiteFailures"]))
	xmlTestsuite.setAttribute("errors", str(counters["TestsuiteErrors"]))
	xmlTestsuite.setAttribute("disabled", str(counters["TestsuiteDisabled"]))

	counters["TestsuiteTestcases"] = 0
	counters["TestsuiteFailures"] = 0
	counters["TestsuiteErrors"] = 0
	counters["TestsuiteDisabled"] = 0


def translateTestcase(yamlTestcase, xmlTestcase: Element, counters: Dict[str, int]):
	counters["TotalTestcases"] += 1
	counters["TestsuiteTestcases"] += 1

	if yamlTestcase["Status"] == "passed":
		yamlResults = yamlTestcase["Results"]

		if yamlTestcase["Name"] != yamlResults["Name"]:
			print("ERROR: Testcase name does not match.")

		xmlTestcase.setAttribute("status", "passed")
		xmlTestcase.setAttribute("assertions", str(yamlResults["AffirmCount"]))

	elif yamlTestcase["Status"] == "skipped":
		counters["TotalDisabled"] += 1

		xmlTestcase.setAttribute("status", "skipped")

	elif yamlTestcase["Status"] == "failed":
		counters["TotalErrors"] += 1

		xmlFailure = xmlTestcase.ownerDocument.createElement("failure")
		xmlTestcase.appendChild(xmlFailure)
	else:
		print("ERROR: Unknown status")


# TODO: Use ArgParse
if __name__ == '__main__':
	yamlReportFile = Path(sys.argv[1])
	xmlReportFile = Path(sys.argv[2])

	main(yamlReportFile, xmlReportFile)
