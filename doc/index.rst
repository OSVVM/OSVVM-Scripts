The OSVVM Simulator Script Library
##################################

.. image:: https://img.shields.io/badge/OSVVM-OSVVM--Scripts-EDB74E.svg?longCache=true&logo=GitHub&labelColor=333333
   :alt: Sourcecode on GitHub
   :height: 22
   :target: https://github.com/OSVVM/OSVVM-Scripts
.. image:: https://img.shields.io/badge/code-Apache%20License,%202.0-97ca00.svg?longCache=true&logo=Apache&labelColor=555555
   :alt: Code license
   :height: 22
   :target: License.html
.. image:: https://img.shields.io/github/v/tag/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release
.. image:: https://img.shields.io/github/v/release/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release

The *OSVVM Simulator Script Library* provides a simple way to compile designs, run simulations, and use libraries.

This scripting approach provides:

* Scripts as simple as a list of files
* Scripts that run on any simulator
* Simple path management – everything is relative to the script location
* Simple usage of libraries

This is an evolving approach. Input is welcome.

.. _NEWS:

News
****

Latest blog posts and news are available at the `OSVVM Blog <https://osvvm.org/blog>`__.

v2026.01 (upcoming)
===================

* tbd

v2025.06a
=========

* tbd

v2025.06
========

* tbd

v2025.04
========

* tbd

v2025.02
========

* tbd


.. _CONTRIBUTORS:

Contributors
************

* `Jim Lewis <https://GitHub.com/JimLewis>`__ (Maintainer)
* `Patrick Lehmann <https://GitHub.com/Paebbels>`__
* `and more... <https://GitHub.com/OSVVM/OSVVM-Scripts/graphs/contributors>`__


.. _LICENSE:

License
*******

.. only:: html

   The ``::osvvm`` Tcl namespace (source code) is licensed under `Apache License 2.0 <Code-License.html>`__. |br|
   The accompanying documentation is licensed under `Creative Commons - Attribution 4.0 (CC-BY 4.0) <Doc-License.html>`__.

.. only:: latex

   This ``::osvvm`` Tcl namespace (source code) is licensed under **Apache License 2.0**. |br|
   The accompanying documentation is licensed under **Creative Commons - Attribution 4.0 (CC-BY 4.0)**.


.. toctree::
   :caption: Overview
   :hidden:

   Installation
   QuickStartGuide
   ToolSpecific
   Support

.. raw:: latex

   \part{Main Documentation}

.. toctree::
   :caption: OSVVM Utility Library
   :hidden:

   UtilityLibrary/AlertLog
   UtilityLibrary/Coverage
   UtilityLibrary/Random

.. toctree::
   :caption: Verification Components
   :hidden:

   VC/AXI4/index
   VC/DpRAM
   VC/Ethernet
   VC/SPI
   VC/UART
   VC/VideoBus
   VC/WishBone

.. toctree::
   :caption: Co-Simulation
   :hidden:

   CoSim/index
   CoSim/PCIe

.. toctree::
   :caption: Scripting Guide
   :hidden:

   UserGuide
   Reports/index
   RequirementsTracking

.. raw:: latex

   \part{References and Reports}

.. toctree::
   :caption: References and Reports
   :hidden:

   VC/ModelIndependentTransactions
   Tcl Command Reference <osvvm-scripts/osvvm>
   YAML/index

.. raw:: latex

   \part{Appendix}

.. toctree::
   :caption: Appendix
   :hidden:

   License
   Doc-License
   Glossary
   genindex
   TODO
