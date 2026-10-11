.. _UG/Libraries:

VHDL Libraries
##############

.. _UG/Libraries/Directory:

Library Directory
*****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      OSVVM creates libraries in a library directory: :file:`<LibraryDirectory>/VHDL_LIBS/<ToolName>-<Version>/`. The
      tool and version part keeps the libraries of different simulators and versions apart.

      By default, ``<LibraryDirectory>`` is the simulation directory. :ref:`RUFF/osvvm/SetLibraryDirectory` selects
      another one; a relative path is resolved against the simulation directory. :ref:`RUFF/osvvm/GetLibraryDirectory`
      returns it.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         SetLibraryDirectory ../libs
         puts [GetLibraryDirectory]

      .. tree::
         :root-icon: 📁
         :node-icon: 📁
         :leaf-icon: 📄
         :icons:     > 📁

         - :file:`libs`
           - :file:`VHDL_LIBS`
             - :file:`NVC-1.23.0`
               - *one entry per library*
             - :file:`QuestaSim-2024.3`
               - *one entry per library*

.. _UG/Libraries/Active:

Active Library
**************

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/library` makes a library the active library, the one :ref:`RUFF/osvvm/analyze` and
      :ref:`RUFF/osvvm/simulate` use. If it doesn't exist, it's created in the library directory. An optional second
      argument names another directory for it.

      Library names are case insensitive, as in VHDL. :ref:`RUFF/osvvm/ListLibraries` prints the libraries OSVVM
      knows.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         library osvvm_TbAxi4
         analyze TbAxi4.vhd

         ListLibraries

.. _UG/Libraries/Link:

Using Existing Libraries
************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Libraries analyzed before, by another build or in another directory, can be used without analyzing them again:

      * :ref:`RUFF/osvvm/LinkLibrary` maps one library.
      * :ref:`RUFF/osvvm/LinkLibraryDirectory` maps every library of a library directory. The path may name the
        directory containing :file:`VHDL_LIBS`, or the library directory itself.
      * :ref:`RUFF/osvvm/LinkCurrentLibraries` maps all libraries OSVVM knows again, after the simulation directory
        changed (:ref:`UG/Concepts/NoCd`).

      Without a path, they use the library directory of :ref:`RUFF/osvvm/SetLibraryDirectory`.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # Use the OSVVM libraries built in another simulation directory
         LinkLibraryDirectory ../sim_shared

         library  ExampleLib
         RunTest  TbExample.vhd

.. _UG/Libraries/Remove:

Removing Libraries
******************

.. grid:: 2

   .. grid-item::
      :columns: 6

      * :ref:`RUFF/osvvm/RemoveLibrary` removes one library. The path is only needed for a library OSVVM hasn't
        mapped.
      * :ref:`RUFF/osvvm/RemoveLibraryDirectory` removes a library directory and its libraries; without a path, the one
        of :ref:`RUFF/osvvm/SetLibraryDirectory`.
      * :ref:`RUFF/osvvm/RemoveAllLibraries` removes every library directory OSVVM knows.

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         RemoveLibrary osvvm_TbAxi4
         RemoveLibraryDirectory
         RemoveAllLibraries
