.. _INSTALL:

Installation/Updates
####################

.. image:: https://img.shields.io/badge/OSVVM-OSVVM--Scripts-EDB74E.svg?longCache=true&logo=GitHub&labelColor=333333
   :alt: Sourcecode on GitHub
   :height: 22
   :target: https://github.com/OSVVM/OSVVM-Scripts
.. image:: https://img.shields.io/github/v/tag/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release

OSVVM is hosted and developed at https://github.com/OSVVM. Its components are split into multiple Git repositories,
which can be used individually or as a group. The all-in-one repository is
`OsvvmLibraries <https://github.com/OSVVM/OsvvmLibraries>`__; it registers the components as Git submodules.
**OSVVM-Scripts** is one of them, in the directory :file:`Scripts`.

Releases are named after year and month, like ``2026.09``. Each release is a Git tag and a GitHub release with
downloadable archives (see :ref:`INSTALL/Download`). The branch ``main`` holds the latest release, ``dev`` the
development.


.. _INSTALL/Clone:

Clone OsvvmLibraries
********************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Clone OsvvmLibraries with the option ``--recursive``, so Git also clones the submodules. Without it, the
      component directories stay empty.

      A clone made without ``--recursive`` gets its submodules afterwards with ``git submodule update --init
      --recursive``.

      .. seealso::

         Git documentation: `git clone <https://git-scm.com/docs/git-clone>`__,
         `git submodule <https://git-scm.com/docs/git-submodule>`__

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         git clone --recursive https://github.com/OSVVM/OsvvmLibraries.git

         # clone made without --recursive
         cd OsvvmLibraries
         git submodule update --init --recursive


.. _INSTALL/Submodule:

Register OsvvmLibraries as Git Submodule
****************************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      Usually, OSVVM is part of a bigger HDL project, also maintained in Git. Then, add OsvvmLibraries as a submodule
      of that project. The commands on the right add it as :file:`lib/OsvvmLibraries` and fetch its own submodules.

      Pin the project to a release by checking out its tag in the submodule; the project's next commit records it.

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         cd <project>
         git submodule add https://github.com/OSVVM/OsvvmLibraries.git lib/OsvvmLibraries
         git submodule update --init --recursive

         # pin to a release
         cd lib/OsvvmLibraries
         git checkout 2026.09
         git submodule update --init --recursive
         cd ../..
         git add lib/OsvvmLibraries
         git commit -m "OSVVM 2026.09"


.. _INSTALL/IndividualSubmodules:

Register Individual Components as Git Submodules
************************************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      A project that needs only some verification components can add the components individually. OSVVM's scripts
      expect the directory layout of OsvvmLibraries: the components next to :file:`Scripts`, under the directory names
      OsvvmLibraries uses. The scripts find the other components relative to :file:`Scripts`.

      Always needed:

      * :file:`osvvm` - repository `OSVVM <https://github.com/OSVVM/OSVVM>`__, the OSVVM utility library;
      * :file:`Common` - repository `OSVVM-Common <https://github.com/OSVVM/OSVVM-Common>`__;
      * :file:`Scripts` - repository `OSVVM-Scripts <https://github.com/OSVVM/OSVVM-Scripts>`__.

      Each verification component has a repository of its directory's name, like ``AXI4``, ``UART`` or ``Ethernet``.
      :file:`OsvvmLibraries.pro` belongs to OsvvmLibraries; a project with individual components writes its own
      build script, which includes :file:`osvvm` and :file:`Common` first.

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         cd <project>/lib/OSVVM
         git submodule add https://github.com/OSVVM/OSVVM.git         osvvm
         git submodule add https://github.com/OSVVM/OSVVM-Common.git  Common
         git submodule add https://github.com/OSVVM/OSVVM-Scripts.git Scripts
         git submodule add https://github.com/OSVVM/AXI4.git          AXI4

      .. code-block:: tcl

         # File: <project>/lib/OSVVM/OsvvmLibraries.pro
         include ./osvvm
         include ./Common
         include ./AXI4


.. _INSTALL/Updating:

Updating OSVVM or OSVVM Components
**********************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      A clone of OsvvmLibraries is updated by pulling the parent repository, then updating the submodules to the
      commits the parent records. To change to another release, check out its tag and update the submodules the same
      way.

      After an update, analyze the OSVVM libraries again, as for the first run: ``build ../OsvvmLibraries`` (see
      :ref:`QSG/Demos`).

   .. grid-item::
      :columns: 6

      .. code-block:: bash

         cd OsvvmLibraries
         git pull
         git submodule update --init --recursive

         # another release
         git fetch --tags
         git checkout 2026.09
         git submodule update --init --recursive


.. _INSTALL/Download:

Download OSVVM Libraries
************************

.. image:: https://img.shields.io/github/v/release/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release

.. grid:: 2

   .. grid-item::
      :columns: 6

      Each release of OsvvmLibraries offers archives with all components at
      https://github.com/OSVVM/OsvvmLibraries/releases/latest, in three formats: ``.tar.gz``, ``.tar.zst`` and
      ``.zip``.

      OSVVM is also available as a zip file from the `osvvm.org downloads page <https://osvvm.org/downloads>`__.

      .. attention::

         GitHub's *Source code* archives of a release don't contain the submodules' code. Use the archives
         :file:`OsvvmLibraries-<version>.*`, which OSVVM's CI packages with all submodules.

   .. grid-item::
      :columns: 6

      .. code-block:: text

         https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.tar.gz
         https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.tar.zst
         https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.zip
