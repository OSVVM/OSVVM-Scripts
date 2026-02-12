.. _SIM:

Simulator Specifics
###################

Quick Overview
**************

.. tab-set::

   .. tab-item:: Aldec Riviera-PRO
      :sync: Riviera

      Initialize the OSVVM Script environment by sourcing :file:`StartUp.tcl` within Riviera-PRO's GUI or Tcl console:

      .. code-block:: tcl

         source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Siemens Visualizer
      :sync: Visualizer

      TODO

      .. code-block:: tcl

         source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Siemens EDA Questa / QuestaSim
      :sync: Questa

      TODO

      .. code-block:: tcl

         source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Siemens EDA ModelSim
      :sync: ModelSim

      TODO

      .. code-block:: tcl

         source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl


Aldec
*****

Active-HDL
==========

Initialize the OSVVM Script environment with the following commands:

.. code-block:: tcl

   scripterconf -tcl
   do -tcl <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

Want to avoid doing this every time? For ActiveHDL, edit :file:`/script/startup.do` and add above to it. Similarly for
**VSimSA**, edit :file:`/BIN/startup.do` and add the above to it.

.. note::

   Note, with 2021.02, you no longer need to set the "Start In" directory to the OSVVM Scripts directory.


Riviera-PRO
===========

AMD (Xilinx)
************

xSim
====


Cadence
*******

Xcelium
=======


GHDL
****

GHDL on Windows in MSYS2/UCRT64
===============================

Initialize the OSVVM Script environment within **tclsh**:

.. code-block:: tcl

   winpty tclsh
   source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

To simplify the startup process, put :file:`source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl` into
:file:`.tclshrc` and add a Windows short cut that calls ``C:\msys64\ucrt64.exe winpty tclsh``. This will open a UCRT64
console window with a Tcl shell and pre-loaded OSVVM Script environment.

.. hint::

   ``tclsh`` and ``tcllib`` might be missing in a fresh MSYS2/UCRT64 environment. |br|
   Use **pacman** to install the necessary Tcl dependencies:

   .. code-block:: Bash

      pacman -S ucrt64/mingw-w64-ucrt-x86_64-winpty
      pacman -S ucrt64/mingw-w64-ucrt-x86_64-tcl ucrt64/mingw-w64-ucrt-x86_64-tcllib

GHDL on Linux/macOS
===================

Initialize the OSVVM Script environment within **tclsh**:

.. code-block:: tcl

   rlwrap tclsh
   source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl

To simplify this, put :file:`source <path-to-OsvvmLibraries>/OsvvmLibraries/Scripts/StartUp.tcl` in the :file:`.tclshrc`
file and in Bash add ``alias gsim='rlwrap tclsh'`` to your :file:`.bashrc`.


NVC
***

NVC on Windows in MSYS2/UCRT64
==============================

NVC on Linux
============

Siemens EDA
***********

ModelSim
========


Questa / QuestaSim
==================


Visualizer
==========


Synopsys
********

VCS
===
