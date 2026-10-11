.. _YAML/FunctionalCoverage:

Functional Coverage
###################

.. grid:: 2

   .. grid-item::
      :columns: 6

      A test case, which collected functional coverage, writes the coverage models of OSVVM's ``CoveragePkg`` into
      :file:`<TestCaseFileName>_cov.yml`: per model its settings, the structure of its bins and every bin with its
      count and goal.

      * **Written by:** ``CoveragePkg.WriteCovYaml``, called by ``EndOfTestReports`` (VHDL, ``ReportPkg``) at the end
        of a test case, if the test case created coverage models.
      * **Location:** :file:`<BuildName>/reports/<TestSuite>/<TestCaseFileName>_cov.yml`. Its path is recorded in the
        test case's :file:`_run.yml` as ``CovYamlFile``.
      * **Read by:** :ref:`RUFF/osvvm/Cov2Html`, called by :ref:`RUFF/osvvm/Simulate2Html`, for the functional
        coverage section of the test case report (see :ref:`RPT/HTML/TestCase/Coverage`). ``CoveragePkg.ReadCovYaml``
        reads it back into coverage models.
      * **Version:** ``Version`` is ``COVERAGE_YAML_VERSION`` of ``OsvvmScriptSettingsPkg``, ``"0.1"``.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version: "0.1"
         Coverage: 100.00
         Settings:
           WritePassFail: 0
         Models:
           - Name: "Cov1"
             TestCases:
               - "TbStream_SendCheckBurstAsyncPattern2"
             Coverage: 100.00
             Settings:
               CovWeight: 1
               Goal: 100.0
               WeightMode: "REMAIN"
               Seeds: [2132829893, 237973941]
               CountMode: "COUNT_FIRST"
               IllegalMode: "ILLEGAL_ON"
               Threshold: 45.0
               ThresholdEnable: "FALSE"
               IsRequirement: "FALSE"
               TotalCovCount: 32
               TotalCovGoal: 32
             BinInfo:
               Dimensions: 1
               FieldNames:
                 - "Bin1"
               NumBins: 32
             Bins:
               - Name: ""
                 Type: "COUNT"
                 Range:
                   - {Min: 0, Max: 0}
                 Count: 1
                 AtLeast: 1
                 PercentCov: 100.0000
               # ... 31 more bins


.. _YAML/FunctionalCoverage/Writing:

Writing the File
****************

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``EndOfTestReports`` calls ``WriteCovYaml`` if the test case created at least one coverage model
      (``GotCoverage``). ``WriteCovYaml`` writes into OSVVM's temporary directory (``OSVVM_TEMP_OUTPUT_DIRECTORY``,
      like :file:`OsvvmTemp_NVC/`) as :file:`<TestName>_cov.yml`.

      When the simulation is done, the scripts move the file into the test suite's reports directory and name it after
      the test case file name, which includes the generics (see :ref:`UG/Generics`).

      * Models with bins and ``CovWeight`` ≥ 1 come first, models with ``CovWeight`` = 0 last.
      * Models without bins are left out.
      * ``WriteCovYaml(ID, FileName)`` writes a single model; without bins, it raises a ``FAILURE``.

   .. grid-item::
      :columns: 6

      .. code-block:: vhdl

         -- end of the test sequencer: writes <TestName>_cov.yml,
         -- if coverage models exist
         EndOfTestReports ;

      .. code-block:: text

         OsvvmTemp_NVC/TbStream_SendGetDemo1_cov.yml
           -> OsvvmRunDemoTests/reports/AxiStream/TbStream_SendGetDemo1_cov.yml


.. _YAML/FunctionalCoverage/Structure:

Structure
*********

.. tree::

   - ``Version`` | format version: string, ``"0.1"``
   - ``Coverage`` | total coverage of the test case in percent (real, 2 digits), weighted by ``CovWeight``
   - ``Settings`` | report settings
     - ``WritePassFail`` | ``1``: the report shows *PASSED*/*FAILED* per bin; ``0``: it doesn't
   - ``Models`` | list of coverage models
     - ``Name`` | the model's name, set with ``SetName``
     - ``TestCases`` | list of test case names; one entry: the test case that wrote the file
     - ``Coverage`` | the model's coverage in percent (real, 2 digits), relative to its ``Goal``
     - ``Settings`` | the model's settings, see :ref:`YAML/FunctionalCoverage/Settings`
     - ``BinInfo`` | the bins' structure, see :ref:`YAML/FunctionalCoverage/Bins`
       - ``Dimensions`` | number of dimensions: ``1`` for a point, ``2`` and more for a cross
       - ``FieldNames`` | list of one name per dimension
       - ``NumBins`` | number of bins
     - ``Bins`` | list of bins, see :ref:`YAML/FunctionalCoverage/Bins`
       - ``Name`` | the bin's name; empty if none was given
       - ``Type`` | ``"COUNT"``, ``"IGNORE"`` or ``"ILLEGAL"``
       - ``Range`` | list of one range per dimension
         - ``Min`` | lowest value of the range (integer)
         - ``Max`` | highest value of the range (integer)
       - ``Count`` | how often the bin was hit (integer)
       - ``AtLeast`` | the bin's goal: hits needed for 100 % (integer)
       - ``PercentCov`` | ``Count`` relative to ``AtLeast`` in percent (real, 4 digits)


.. _YAML/FunctionalCoverage/Total:

Total Coverage and Weights
**************************

.. grid:: 2

   .. grid-item::
      :columns: 6

      The top-level ``Coverage`` is ``GetCov``: the covered counts of all models, each multiplied by its
      ``CovWeight``, relative to their goals, also multiplied by ``CovWeight``. Hits beyond a bin's goal don't count.

      A model with ``CovWeight`` = 0 doesn't count. OSVVM's delay coverage (``DelayCoveragePkg``) creates such
      models, so they show up in many test cases. The report folds them into a section of their own.

      .. attention::

         If all models of a test case have ``CovWeight`` = 0, the top-level ``Coverage`` is ``100.00``, although each
         model shows its own coverage, like ``0.00``.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Version: "0.1"
         Coverage: 100.00
         Settings:
           WritePassFail: 0
         Models:
           - Name: "DelayCov BurstLength"
             TestCases:
               - "TbStream_AxiSetOptionsBurst2"
             Coverage: 0.00
             Settings:
               CovWeight: 0
               # ...


.. _YAML/FunctionalCoverage/Settings:

Model Settings
**************

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``Settings`` of a model are the settings of the coverage model in ``CoveragePkg``. Enumeration values are written
      in upper case, as strings.

      .. tree::

         - ``CovWeight`` | weight of the model in the total ``Coverage`` (integer, ``0``: ignored)
         - ``Goal`` | coverage goal of the model in percent (real), ``SetCovTarget``
         - ``WeightMode`` | randomization weighting: ``"AT_LEAST"`` or ``"REMAIN"`` (others are deprecated)
         - ``Seeds`` | the two seeds of the model's randomization, as a flow sequence
         - ``CountMode`` | ``"COUNT_FIRST"``: a value counts in its first matching bin; ``"COUNT_ALL"``: in all
         - ``IllegalMode`` | ``"ILLEGAL_ON"``, ``"ILLEGAL_FAILURE"`` or ``"ILLEGAL_OFF"``: the alert of an illegal bin
         - ``Threshold`` | coverage threshold of the randomization in percent (real)
         - ``ThresholdEnable`` | ``"TRUE"``/``"FALSE"``: thresholding of the randomization
         - ``IsRequirement`` | ``"TRUE"``/``"FALSE"``: the model is a requirement; the report shows PASSED/FAILED
         - ``TotalCovCount`` | covered count of the ``COUNT`` bins, each limited to its goal (integer)
         - ``TotalCovGoal`` | sum of the ``COUNT`` bins' goals, scaled by ``Goal`` (integer)

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         Settings:
           CovWeight: 1
           Goal: 100.0
           WeightMode: "REMAIN"
           Seeds: [2132829893, 237973941]
           CountMode: "COUNT_FIRST"
           IllegalMode: "ILLEGAL_ON"
           Threshold: 45.0
           ThresholdEnable: "FALSE"
           IsRequirement: "FALSE"
           TotalCovCount: 32
           TotalCovGoal: 32


.. _YAML/FunctionalCoverage/Bins:

Bins
****

.. grid:: 2

   .. grid-item::
      :columns: 6

      ``BinInfo`` describes the shape of the bins: a point has one dimension, a cross two or more.
      ``FieldNames`` names the dimensions; names not set with ``SetFieldName`` are ``"Bin1"``, ``"Bin2"``, ...

      Each entry of ``Bins`` has one ``Range`` per dimension, as a flow mapping ``{Min: ..., Max: ...}``. A single value
      is a range with ``Min`` = ``Max``.

      * ``Type`` comes from the bin's action: ``"COUNT"`` counts towards the coverage, ``"IGNORE"`` and ``"ILLEGAL"``
        don't.
      * ``PercentCov`` is ``100 * Count / AtLeast``; a bin with ``AtLeast`` = 0 has ``100.0``.
      * With ``WritePassFail`` = 1 or ``IsRequirement`` = ``"TRUE"``, the report adds a status column: a ``COUNT``
        bin passes when ``Count`` ≥ ``AtLeast``, an ``ILLEGAL`` bin when it wasn't hit, an ``IGNORE`` bin shows
        *IGNORED*. Models with ``CovWeight`` = 0 show no status.

   .. grid-item::
      :columns: 6

      .. code-block:: yaml

         BinInfo:
           Dimensions: 2
           FieldNames:
             - "Bin1"
             - "Bin2"
           NumBins: 4
         Bins:
           - Name: ""
             Type: "COUNT"
             Range:
               - {Min: 0, Max: 0}
               - {Min: 2, Max: 8}
             Count: 0
             AtLeast: 65
             PercentCov: 0.0000
           - Name: ""
             Type: "COUNT"
             Range:
               - {Min: 0, Max: 0}
               - {Min: 108, Max: 156}
             Count: 0
             AtLeast: 10
             PercentCov: 0.0000
           # ... 2 more bins


.. _YAML/FunctionalCoverage/Readers:

Readers
*******

.. grid:: 2

   .. grid-item::
      :columns: 6

      :ref:`RUFF/osvvm/Cov2Html` reads all keys above: the top-level ``Coverage``, ``Settings``/``WritePassFail`` and
      per model ``Name``, ``Coverage``, ``Settings`` (shown as a table, ``Seeds`` as two values), ``BinInfo``/
      ``FieldNames`` (the table header) and every bin. It is called by :ref:`RUFF/osvvm/Simulate2Html`, which writes
      the test case report after each simulation.

      ``CoveragePkg.ReadCovYaml`` reads the file back into coverage models, to continue or merge coverage across test
      cases (``Merge => TRUE``).

   .. grid-item::
      :columns: 6

      .. code-block:: tcl

         # regenerate the test case report of one test case
         Simulate2Html <BuildName>/reports/AxiStream/TbStream_SendGetDemo1_run.yml <BuildName>
