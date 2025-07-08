chpl Vector Library (CVL) documentation
=======================================

Core Library
************

.. toctree::
   :maxdepth: 1

   CVL

Intrinsics
**********

CVL implements all of the higher level vector operations using a lower level library of intrinsics. These are platform-independent, with the platform-specific implementations in separate modules

.. toctree::
   :maxdepth: 1

   Intrin

Internal Intrinsics
~~~~~~~~~~~~~~~~~~~

These modules are the internal implementation types used by the intrinsics. They are not intended for direct use by users of CVL, but are included here for developer reference. Do not expect these to be stable or well documented.

.. toctree::
   :maxdepth: 1

   IntrinX86_128
   IntrinX86_256
   IntrinArm64_128
   IntrinArm64_256


Indices and tables
==================

* :ref:`genindex`
* :chpl:chplref:`chplmodindex`
* :ref:`search`
