.. _INSTALL:

Installation/Updates
####################

.. image:: https://img.shields.io/badge/OSVVM-OsvvmLibraries-EDB74E.svg?longCache=true&logo=GitHub&labelColor=333333
   :alt: Sourcecode on GitHub
   :height: 22
   :target: https://github.com/OSVVM/OsvvmLibraries
.. image:: https://img.shields.io/github/v/tag/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release

OSVVM is hosted and developed on https://github.com/OSVVM. It's components are split into multiple Git repositories,
which be used individually or as a group. The all-in-one repository is called
`OsvvmLibraries <https://github.com/OSVVM/OsvvmLibraries>`__.


OSVVM is available as either a git repository OSVVM Libraries or a zip file from osvvm.org Downloads Page.

Clone OsvvmLibraries
********************

OsvvmLibraries summarizes all OSVVM repositories into a single parent repository, which has OSVVM's components
registered as Git submodules. |br|
When cloning ensure to append the ``–recursive`` flag.

.. code-block:: bash

   git clone --recursive https://github.com/OSVVM/OsvvmLibraries.git

.. seealso::

   Git Documentation: `git clone <https://git-scm.com/docs/git-clone>`__


Register OsvvmLibraries as Git Submodule
****************************************

Usually, OSVVM will be part of a bigger HDL project structure also maintained in Git. Therefore, it's best to integrate
OSVVM as a submodule into that project. The following commands assume, OSVVM gets added into ``./lib/OsvvmLibraries``.

.. code-block:: bash

   cd <project>/lib
   git submodule add https://github.com/OSVVM/OsvvmLibraries.git
   git submodule update --init --recursive

.. seealso::

   Git Documentation: `git submodule add <https://git-scm.com/docs/git-submodule>`__


Register Individual VCs as Git Submodule
****************************************

.. todo::

   describe individual submodule workflow

Updating OSVVM or OSVVM Components
**********************************

.. todo::

   describe update process using Git


Download OSVVM Libraries
************************

.. image:: https://img.shields.io/github/v/release/OSVVM/OsvvmLibraries
   :target: https://github.com/OSVVM/OsvvmLibraries/releases/latest
   :alt: GitHub Release

OsvvmLibraries is also offered as an archive at https://github.com/OSVVM/OsvvmLibraries/releases/latest

* ``https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.tar.gz``
* ``https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.tar.zstd``
* ``https://github.com/OSVVM/OsvvmLibraries/releases/download/<version>/OsvvmLibraries-<version>.zip``

.. attention::

   Downloading the archive provided by GitHub's source code download doesn't include the submodule's code. Therefore
   OSVVM added a CI job for packaging all sources (incl. submodules) into a single archive.


Business Continuity Planning
****************************

.. todo:

   describe fork structure

   1. fork on GitHub
   2. mirror to local Git server (e.g. GitLab)
   3. clone to local machine

