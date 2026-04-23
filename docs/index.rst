chpl Vector Library (CVL) documentation
=======================================

Core Library
************

.. toctree::
   :maxdepth: 1

   modules/src/CVL
   modules/src/CVL/Vector
   modules/src/CVL/VectorRef

Intrinsics
**********

CVL implements all of the higher level vector operations using a lower level library of intrinsics. These are platform-independent, with the platform-specific implementations in separate modules

.. toctree::
   :maxdepth: 1

   modules/src/CVL/Intrin

Internal Intrinsics
~~~~~~~~~~~~~~~~~~~

These modules are the internal implementation types used by the intrinsics. They are not intended for direct use by users of CVL, but are included here for developer reference. Do not expect these to be stable or well documented.

.. toctree::
   :maxdepth: 1

   modules/src/CVL/IntrinX86_128
   modules/src/CVL/IntrinX86_256
   modules/src/CVL/IntrinArm64_128
   modules/src/CVL/IntrinArm64_256

SLEEF
~~~~~

SLEEF is a vectorized math library that CVL can use to implement math functions.
See https://sleef.org/ for more information.

.. toctree::
   :maxdepth: 1

   modules/src/CVL/SLEEF


Utilities
~~~~~~~~~

.. toctree::
   :maxdepth: 1

   modules/src/CVL/Arch


Indices and tables
==================

* :ref:`genindex`
* :chpl:chplref:`chplmodindex`
* :ref:`search`
