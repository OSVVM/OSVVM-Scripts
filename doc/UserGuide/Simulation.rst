.. _UG/Simulation:

Simulation
##########

.. _UG/Generics:

Simulating with Generics
************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/generic` sets a top-level generic for the next :ref:`RUFF/osvvm/simulate` or
      :ref:`RUFF/osvvm/RunTest`. It takes the generic's name and value. OSVVM passes the generics the way each simulator
      needs them.

      The square brackets are required: Tcl calls :ref:`RUFF/osvvm/generic` and passes its result as argument.

      The generics become part of the test case's file names, so runs with different values keep separate reports:
      :file:`<TestCaseName>_<Generic>_<Value>.html`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         library  default
         RunTest  Tb_xMii1.vhd [generic MII_INTERFACE RGMII] [generic MII_BPS BPS_1G]
         simulate Tb_xMii1     [generic MII_INTERFACE MII]   [generic MII_BPS BPS_10M]

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`reports/<TestSuite>`
           - :file:`Tb_xMii1_MII_INTERFACE_RGMII_MII_BPS_BPS_1G.html`
           - :file:`Tb_xMii1_MII_INTERFACE_MII_MII_BPS_BPS_10M.html`

.. _UG/Simulation/SecondTopLevel:

Second Top Level
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Some testbenches need a second design unit at the top level of the simulation, for example a configuration of
      timing checks or a Verilog ``glbl`` module. :ref:`RUFF/osvvm/SetSecondSimulationTopLevel` names it as
      ``<Library>.<DesignUnit>`` before :ref:`RUFF/osvvm/simulate`; an empty value removes it.

      Supported by the Aldec and Siemens simulators, DSim and XSIM.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetSecondSimulationTopLevel work.glbl
         simulate TbSystem
         SetSecondSimulationTopLevel ""

.. _UG/Waveform:

Waveforms
*********

.. _UG/Waveform/DoWaves:

Wave Files
==========

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/DoWaves` adds wave files to a simulation; like :ref:`RUFF/osvvm/generic`, it's called in square
      brackets in the call of :ref:`RUFF/osvvm/simulate`. A wave file not in the simulation directory needs its path.

      The Aldec and Siemens simulators run them when the simulation starts. A file named :file:`wave.do` doesn't need
      :ref:`RUFF/osvvm/DoWaves`: it runs automatically (see :ref:`UG/Config/HookFiles`).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         library  default
         simulate Tb [DoWaves wave1.do]
         simulate Tb [DoWaves wave1.do wave2.do]

.. _UG/Waveform/SaveWaves:

Saving Waveforms with GHDL and NVC
==================================

.. grid:: 2

   .. grid-item::
      :columns: 6

      GHDL and NVC run in batch mode, but can save waveforms for a separate viewer like GTKWave or Surfer.
      :ref:`RUFF/osvvm/SetSaveWaves` turns it on; without an argument, it means ``true``. The default is ``false``.

      The waveform file is written next to the test case's report: :file:`<BuildName>/reports/<TestSuite>/`.

      The Siemens scripts use the setting too, to keep the simulator's waveform database.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetSaveWaves
         build ../RunExample.pro

      .. tab-set::

         .. tab-item:: GHDL
            :sync: GHDL

            .. code-block:: text

               <BuildName>/reports/<TestSuite>/<DesignUnit>.ghw

            Signals can be selected with a file :file:`<DesignUnit>.ghdl` (GHDL's ``--read-wave-opt``).

         .. tab-item:: NVC
            :sync: NVC

            .. code-block:: text

               <BuildName>/reports/<TestSuite>/<DesignUnit>.fst
