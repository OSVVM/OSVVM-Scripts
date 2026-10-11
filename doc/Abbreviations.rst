.. _ABBREVIATIONS:

Abbreviations
#############

.. abbreviations::

   API
      :long: application programming interface

      The commands and variables a software offers to other programs and scripts. OSVVM-Scripts is an API on top of
      :acs:`Tcl`: a :term:`build script` calls its commands instead of a simulator's own ones.

   AXI4
      :long: Advanced eXtensible Interface 4

      Arm's on-chip bus protocol of the AMBA specification, in the variants AXI4 (full), AXI4-Lite and AXI4-Stream.
      OSVVM has a :term:`verification component` for each of them (repository
      `AXI4 <https://github.com/OSVVM/AXI4>`__).

   CD
      :long: continuous delivery

      Releasing every change, which passed :acs:`CI`, automatically. Usually written together, as CI/CD.

   CI
      :long: continuous integration

      Building and testing every change automatically, usually on a server. A CI tool reads the :term:`JUnit XML`
      build summary report of a :term:`build` to show its test cases (see :ref:`RPT/XML`).

   CSV
      :long: comma-separated values

      A text format for tables: one line per row, the fields separated by commas
      (`RFC 4180 <https://www.rfc-editor.org/rfc/rfc4180>`__). OSVVM writes its build :term:`requirements <requirement>`
      report as CSV and reads a requirements specification from CSV (see :ref:`RPT/REQ`).

   FIFO
      :long: first in, first out

      A queue that returns its items in the order they were put in. A :term:`scoreboard` keeps its expected values in
      a FIFO.

   FSM
      :long:        finite-state machine
      :long-plural: finite-state machines

      A circuit in exactly one of a finite number of states at a time. The :term:`coverage kind` ``fsm`` covers the
      states and transitions of a design's FSMs.

   GHDL
      :long: G Hardware Design Language

      An open-source :acs:`VHDL` simulator (`GHDL <https://github.com/ghdl/ghdl>`__); "G" has no meaning.

   HDL
      :long: hardware description language

      A language describing the structure and behaviour of digital circuits, like :acs:`VHDL`, Verilog and
      SystemVerilog.

   HTML
      :long: HyperText Markup Language

      The markup language of web pages (`HTML standard <https://html.spec.whatwg.org/>`__). OSVVM's reports for humans
      are HTML files (see :ref:`RPT/HTML`).

   ID
      :long: identifier

      A name, which identifies one element. In OSVVM, an AlertLog ID identifies an entry of the alert hierarchy, a
      requirement ID a :term:`requirement`.

   ISO 8601
      :long: Date and time - Representations for information interchange

      The ISO standard for writing a date and a time as text, like ``2026-10-11T07:30:15+02:00``. OSVVM's
      :acs:`YAML` files write the start and finish of a :term:`build` in this form.

   JSON
      :long: JavaScript Object Notation

      A text format for structured data (`RFC 8259 <https://www.rfc-editor.org/rfc/rfc8259>`__).
      :ref:`RUFF/osvvm/ProToJson` writes what a :term:`build script` analyzes and simulates as JSON.

   OSVVM
      :long: Open Source VHDL Verification Methodology

      A :acs:`VHDL` verification methodology and its libraries (`osvvm.org <https://osvvm.org/>`__): the
      :term:`utility library`, the :term:`verification components <verification component>`, and OSVVM-Scripts, the
      script library documented here.

   Tcl
      :long: Tool Command Language

      A scripting language (`tcl-lang.org <https://www.tcl-lang.org/>`__), built into most simulators. An OSVVM
      :term:`build script` is a Tcl script.

   UART
      :long:        universal asynchronous receiver-transmitter
      :long-plural: universal asynchronous receiver-transmitters

      A serial interface sending one character at a time, framed by start and stop bits. OSVVM has a
      :term:`verification component` for it (repository `UART <https://github.com/OSVVM/UART>`__).

   UCDB
      :long: Unified Coverage Database

      The coverage database format of the Siemens simulators. The Aldec simulators export their :term:`code coverage`
      as UCDB XML.

   VC
      :long: verification component

      See :term:`verification component`.

   VHDL
      :long: VHSIC Hardware Description Language

      The :acs:`HDL` standardized as `IEEE 1076 <https://standards.ieee.org/standard/1076-2019.html>`__. OSVVM is
      written in VHDL.

   VHSIC
      :long: Very High Speed Integrated Circuit

      The US Department of Defense program, under which :acs:`VHDL` was developed.

   XML
      :long: Extensible Markup Language

      The W3C's markup language for structured text documents (`XML 1.0 <https://www.w3.org/TR/xml/>`__). OSVVM writes
      its build summary report also as :term:`JUnit XML`, and exports :term:`code coverage` as XML.

   YAML
      :long: YAML Ain't Markup Language

      A text format for structured data (`yaml.org <https://yaml.org/>`__). OSVVM writes all results as YAML first
      and creates its reports from these files (see :ref:`YAML`).
