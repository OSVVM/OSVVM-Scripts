.. _QSG:

Quick Start Guide
#################

Three steps get OSVVM running in your simulator: get OSVVM, start OSVVM's script environment in the simulator, and run
the demos. Each simulator starts the script environment a little differently - choose yours in the tabs below. The
choice is kept for all tabs on this page.


.. _QSG/Download:

Get OSVVM
*********

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM is distributed as the repository `OsvvmLibraries <https://github.com/OSVVM/OsvvmLibraries>`__. Each
      library - the utility library ``osvvm``, the verification components, the scripts - is a git submodule of it.
      Clone it with ``--recursive``, so all submodules are checked out too.

      A clone without ``--recursive`` has empty submodule directories; ``git submodule update --init --recursive``
      fills them.

      Without git, download the zip file from the `osvvm.org Downloads Page <https://osvvm.org/downloads>`__.

      Updates and other ways to install OSVVM: :ref:`INSTALL`.

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         git clone --recursive https://github.com/OSVVM/OsvvmLibraries

      .. code-block:: bash

         # an existing clone without submodules
         cd OsvvmLibraries
         git submodule update --init --recursive


.. _QSG/SimDir:

Create a Simulation Directory
*****************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Run simulations in a directory of their own. OSVVM and the simulator write everything there: the compiled
      libraries (:file:`VHDL_LIBS`), one directory per build with its reports, and the index of all builds
      (:file:`index.html`). Cleaning up means deleting this directory.

      Create it next to :file:`OsvvmLibraries` and name it :file:`sim` - or :file:`sim_<tool>`, if you use several
      simulators. The commands on this page assume this layout and run in :file:`sim`.

      .. hint::

         A :file:`sim` directory inside :file:`OsvvmLibraries` works as well. Then the scripts are one level up:
         ``build ../RunDemoTests.pro`` instead of ``build ../OsvvmLibraries/RunDemoTests.pro``.

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         mkdir sim
         cd sim

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`<work>`
           - :file:`OsvvmLibraries`
             > :file:`osvvm`
             > :file:`Scripts`
             - …
             - :file:`OsvvmLibraries.pro`
             - :file:`RunDemoTests.pro`
           > :file:`sim`


.. _QSG/Start:

Start the Script Environment
****************************

OSVVM's commands, like :ref:`RUFF/osvvm/build` or :ref:`RUFF/osvvm/simulate`, are Tcl procedures. A start-up script
from :file:`OsvvmLibraries/Scripts` loads them into the Tcl shell of your simulator - once per session, before any other
OSVVM command.

* Simulators with a Tcl console of their own (Riviera-PRO, Active-HDL, Questa, ModelSim, Visualizer, Vivado) use
  :file:`StartUp.tcl`. It detects the simulator it runs in.
* Simulators started from the command line (GHDL, NVC, VCS, Xcelium, DSim) run OSVVM in :program:`tclsh`, with a
  start-up script named after the simulator, like :file:`StartNVC.tcl`. In :program:`tclsh`, :file:`StartUp.tcl` can't
  detect the simulator and selects GHDL.
* The environment variable ``OSVVM_TOOL`` overrides the detection: it names the vendor script to load, like ``NVC``
  for :file:`VendorScripts_NVC.tcl`.

.. tab-set::

   .. tab-item:: Riviera-PRO
      :sync: RivieraPRO

      .. grid:: 2

         .. grid-item::
            :columns: 6

            In Riviera-PRO's console, change to the simulation directory and source :file:`StartUp.tcl`.

            To load OSVVM automatically at every start, set the environment variable ``ALDEC_STARTUPTCL`` to the full
            path of :file:`StartUp.tcl`.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               cd <work>/sim
               source ../OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Active-HDL
      :sync: ActiveHDL

      .. grid:: 2

         .. grid-item::
            :columns: 6

            Active-HDL's console runs macros by default: switch it to Tcl with ``scripterconf -tcl``, then run
            :file:`StartUp.tcl` with ``do -tcl``.

            To load OSVVM automatically, add both lines to :file:`<Active-HDL>/script/startup.do`. For VSimSA, the
            command line simulator of Active-HDL, add them to :file:`<Active-HDL>/BIN/startup.do`.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               scripterconf -tcl
               cd <work>/sim
               do -tcl ../OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Questa
      :sync: QuestaSim

      .. grid:: 2

         .. grid-item::
            :columns: 6

            In Questa's console, change to the simulation directory and source :file:`StartUp.tcl`. If the command
            ``qsim`` exists, OSVVM uses :file:`VendorScripts_Questa.tcl`, else :file:`VendorScripts_Siemens.tcl`.

            To load OSVVM automatically, set the environment variable ``MODELSIM_TCL`` to the full path of
            :file:`StartUp.tcl`.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               cd <work>/sim
               source ../OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: ModelSim
      :sync: ModelSim

      .. grid:: 2

         .. grid-item::
            :columns: 6

            In ModelSim's console, change to the simulation directory and source :file:`StartUp.tcl`.

            To load OSVVM automatically, set the environment variable ``MODELSIM_TCL`` to the full path of
            :file:`StartUp.tcl`.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               cd <work>/sim
               source ../OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: Visualizer
      :sync: Visualizer

      .. grid:: 2

         .. grid-item::
            :columns: 6

            In Visualizer's console, change to the simulation directory and source :file:`StartUp.tcl`. OSVVM uses
            :file:`VendorScripts_Questa.tcl` for Visualizer.

            To load OSVVM automatically, set the environment variable ``VISUALIZER_TCL`` to the full path of
            :file:`StartUp.tcl`.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               cd <work>/sim
               source ../OsvvmLibraries/Scripts/StartUp.tcl

   .. tab-item:: GHDL
      :sync: GHDL

      .. grid:: 2

         .. grid-item::
            :columns: 6

            GHDL has no Tcl shell: run OSVVM in :program:`tclsh` and source :file:`StartGHDL.tcl`.

            * Linux: start :program:`tclsh` with :program:`rlwrap` for a command history.
            * Windows: in an MSYS2 shell, start :program:`tclsh` with :program:`winpty`.

            To load OSVVM automatically, put the ``source`` line into :file:`~/.tclshrc` and add an alias like
            ``alias gsim='rlwrap tclsh'`` to :file:`~/.bashrc`. On Windows, a shortcut can run
            ``C:\tools\msys64\mingw64.exe winpty tclsh``.

         .. grid-item::
            :columns: 6

            .. code-block:: bash

               cd <work>/sim
               rlwrap tclsh        # Windows (MSYS2): winpty tclsh

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartGHDL.tcl

   .. tab-item:: NVC
      :sync: NVC

      .. grid:: 2

         .. grid-item::
            :columns: 6

            NVC can run OSVVM in two ways:

            * In NVC's own Tcl shell (``nvc -i``), source :file:`StartUp.tcl`; it detects NVC. A script file runs
              with ``nvc --do <file>``. This needs an NVC built with Tcl support.
            * In :program:`tclsh`, source :file:`StartNVC.tcl`. OSVVM then calls :program:`nvc` for each step.
              Linux: :program:`rlwrap tclsh`; Windows (MSYS2): :program:`winpty tclsh`.

            To load OSVVM automatically in :program:`tclsh`, put the ``source`` line into :file:`~/.tclshrc` and add
            an alias like ``alias nsim='rlwrap tclsh'`` to :file:`~/.bashrc`.

         .. grid-item::
            :columns: 6

            .. code-block:: bash

               cd <work>/sim
               nvc -i              # NVC's Tcl shell

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartUp.tcl

            or

            .. code-block:: bash

               cd <work>/sim
               rlwrap tclsh        # Windows (MSYS2): winpty tclsh

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartNVC.tcl

   .. tab-item:: VCS
      :sync: VCS

      .. grid:: 2

         .. grid-item::
            :columns: 6

            Run OSVVM in :program:`tclsh` and source :file:`StartVCS.tcl`. OSVVM calls VCS' command line tools for
            each step.

            To load OSVVM automatically, put the ``source`` line into :file:`~/.tclshrc` and add an alias like
            ``alias ssim='rlwrap tclsh'`` to :file:`~/.bashrc`.

         .. grid-item::
            :columns: 6

            .. code-block:: bash

               cd <work>/sim
               rlwrap tclsh

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartVCS.tcl

   .. tab-item:: Xcelium
      :sync: Xcelium

      .. grid:: 2

         .. grid-item::
            :columns: 6

            Run OSVVM in :program:`tclsh` and source :file:`StartXcelium.tcl`. OSVVM calls Xcelium's command line
            tools for each step.

            To load OSVVM automatically, put the ``source`` line into :file:`~/.tclshrc`.

         .. grid-item::
            :columns: 6

            .. code-block:: bash

               cd <work>/sim
               rlwrap tclsh

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartXcelium.tcl

   .. tab-item:: XSIM
      :sync: XSIM

      .. grid:: 2

         .. grid-item::
            :columns: 6

            Start Vivado and source :file:`StartXSIM.tcl` in its Tcl console.

            .. note::

               XSIM support is under development: it analyzes the OSVVM utility library, but OSVVM's own test cases
               don't pass yet.

         .. grid-item::
            :columns: 6

            .. code-block:: tcl

               cd <work>/sim
               source ../OsvvmLibraries/Scripts/StartXSIM.tcl

   .. tab-item:: DSim
      :sync: DSim

      .. grid:: 2

         .. grid-item::
            :columns: 6

            Run OSVVM in :program:`tclsh` and source :file:`StartDSim.tcl`. OSVVM calls DSim's command line tools
            for each step.

         .. grid-item::
            :columns: 6

            .. code-block:: bash

               cd <work>/sim
               rlwrap tclsh

            .. code-block:: tcl

               source ../OsvvmLibraries/Scripts/StartDSim.tcl

The start-up script prints the versions it found, for example:

.. code-block:: text

   OSVVM Script Version:  2026.09
   Simulator Version:     NVC-1.23.0


.. _QSG/Demos:

Run the Demos
*************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Two :ref:`RUFF/osvvm/build` commands run the demos:

      #. :file:`OsvvmLibraries.pro` analyzes the OSVVM utility library and all verification components into
         :file:`VHDL_LIBS/<tool>-<version>`. A directory name - here :file:`../OsvvmLibraries` - runs the script of
         the same name in it.
      #. :file:`RunDemoTests.pro` analyzes and runs 11 demo test cases: AXI4, AXI4 Stream, UART and Ethernet.

      Each :ref:`RUFF/osvvm/build` prints a summary line at its end. With NVC or GHDL, both builds take less than a
      minute.

      Paths in OSVVM commands are relative to the directory of the script that contains them. Typed in the console,
      they are relative to the current directory - here :file:`sim`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         build ../OsvvmLibraries
         build ../OsvvmLibraries/RunDemoTests.pro

      .. code-block:: text

         Build: OsvvmLibraries PASSED,  Passed: 0,  Failed: 0,  Skipped: 0,  Analyze Errors: 0,  Simulate Errors: 0
         Build: OsvvmRunDemoTests PASSED,  Passed: 11,  Failed: 0,  Skipped: 0,  Analyze Errors: 0,  Simulate Errors: 0

.. grid:: 2

   .. grid-item::
      :columns: 6

      The same commands also run from a script file - useful for regressions and continuous integration. The
      start-up script is its first line.

   .. grid-item::
      :columns: 6

      .. tab-set::

         .. tab-item:: NVC
            :sync: NVC

            .. code-block:: tcl
               :caption: sim/regression.tcl

               source ../OsvvmLibraries/Scripts/StartUp.tcl
               build ../OsvvmLibraries
               build ../OsvvmLibraries/RunDemoTests.pro

            .. code-block:: bash

               nvc --do regression.tcl

         .. tab-item:: GHDL
            :sync: GHDL

            .. code-block:: tcl
               :caption: sim/regression.tcl

               source ../OsvvmLibraries/Scripts/StartGHDL.tcl
               build ../OsvvmLibraries
               build ../OsvvmLibraries/RunDemoTests.pro

            .. code-block:: bash

               tclsh regression.tcl


.. _QSG/Reports:

Look at the Reports
*******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Every build creates a directory named after the build, with:

      * the HTML build summary report :file:`<BuildName>.html` - the starting point;
      * the JUnit XML report :file:`<BuildName>.xml`, for continuous integration;
      * the YAML file :file:`<BuildName>.yml`, the data of both reports;
      * :file:`reports/` with a detailed report per test case, :file:`results/` and :file:`logs/`.

      :file:`index.html` in :file:`sim` lists all builds. Open the reports in a web browser;
      :ref:`RUFF/osvvm/OpenBuildHtml` opens the report of the last build (Windows).

      What the reports contain: :ref:`RPT`.

   .. grid-item::
      :columns: 6

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`sim`
           - :file:`index.html`
           - :file:`OsvvmLibraries`
             - :file:`OsvvmLibraries.html`
           - :file:`OsvvmRunDemoTests`
             - :file:`OsvvmRunDemoTests.html`
             - :file:`OsvvmRunDemoTests.xml`
             - :file:`OsvvmRunDemoTests.yml`
             > :file:`logs`
             > :file:`reports`
             > :file:`results`
           - :file:`VHDL_LIBS`
             > :file:`NVC-1.23.0`


.. _QSG/Next:

Next Steps
**********

.. grid:: 2

   .. grid-item::
      :columns: 6

      Scripts of your own use the same few commands:

      * :ref:`RUFF/osvvm/library` selects (and creates) the working library,
      * :ref:`RUFF/osvvm/analyze` compiles a VHDL or Verilog file into it,
      * :ref:`RUFF/osvvm/simulate` runs a test case,
      * :ref:`RUFF/osvvm/RunTest` does all three for a test case named like its file,
      * :ref:`RUFF/osvvm/include` runs another script, :ref:`RUFF/osvvm/build` runs one as a build with reports.

      The :ref:`UG` explains them.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl
         :caption: MyTests.pro

         library  MyLib
         analyze  MyDesign.vhd
         analyze  TestCtrl_e.vhd
         analyze  TbMyDesign.vhd
         RunTest  TbMyDesign_Test1.vhd

      .. code-block:: tcl

         build ../MyProject/MyTests.pro
