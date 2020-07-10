
.. |for_gem5| replace:: `Provided for gem5 compatibility`

TMJ Header-only Libraries
============================================================

TMJ includes a set of headers to abstract away implementation-specific details such as barrier synchronization, and implementation-details related to the ARM M4 cores.

The main library functionality and header organization is partitioned as follows
(from lowest level of abstraction to highest):

+-----------------------+-------------------------------------------------------------------------+
| Header                | Brief                                                                   |
+=======================+=========================================================================+
| :file:`cm4_hal.h`     | Various ASM intrinsics and Cortex M4-specific config                    |
+-----------------------+-------------------------------------------------------------------------+
| :file:`tmj_map.h`     | Memory maps and TMJ microarchitecture-specific typedefs                 |
+-----------------------+-------------------------------------------------------------------------+
| :file:`tmj_thread.h`  | Threading and synchronization primitives                                |
+-----------------------+-------------------------------------------------------------------------+
| :file:`tmj_hal.h`     | Baremetal hardware abstraction layer (HAL) for app development          |
+-----------------------+-------------------------------------------------------------------------+
| :file:`tmj_rt_basic.h`| Abstracted runtime API and misc helpers, built on the HAL               |
+-----------------------+-------------------------------------------------------------------------+

We only document :file:`tmj_rt_basic.h` and :file:`tmj_hal.h` here, since apps will generally not need to
interact with methods from other headers.

Besides :file:`tmj_rt_basic.h` and :file:`tmj_hal.h`,
there's one more header that apps should include: :file:`test_util.h`.
This file implements several methods required for running on physical hardware.

APIs not listed under :ref:`Abstracted Runtime API` are not associated with any
additional software-managed state (beyond what is required for the C/C++ runtime).
APIs that `are` listed under :ref:`Abstracted Runtime API` have special
software-managed data structures, so calling :cpp:func:`RT_INIT` is necessary before use.

Thread identification
-----------------------------------------------------------

Basic thread indices
^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: CORE_ID
.. doxygenfunction:: GPE_ID
.. doxygenfunction:: TILE_ID
.. doxygenfunction:: LCP_TILE_ID
.. doxygenfunction:: IS_MANAGER

Spatial coordinates
^^^^^^^^^^^^^^^^^^^^^^^^

These APIs provide spatial positions of worker cores within a tile.

.. doxygenfunction:: CORE_ROW_ID
.. doxygenfunction:: CORE_COL_ID
.. doxygenfunction:: CORE_ON_LEFT_EDGE
.. doxygenfunction:: CORE_ON_RIGHT_EDGE
.. doxygenfunction:: CORE_ON_TOP_EDGE
.. doxygenfunction:: CORE_ON_BOTTOM_EDGE

Low-level thread communication (QIO)
-----------------------------------------------------------

These exercise the "work queues" between a manager and the worker cores within a tile.
IN/OUT indicates direction from the point of the view of the calling core.

Push/pop operations
^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: QIO_POP
.. doxygenfunction:: QIO_PUSH
.. doxygenfunction:: FREE_GPEQ_PUSH

Status flags
^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: QIO_IN_ISEMPTY
.. doxygenfunction:: QIO_IN_ISFULL
.. doxygenfunction:: QIO_OUT_ISEMPTY
.. doxygenfunction:: QIO_OUT_ISFULL

.. note::
   The QIO methods above implement the same functionality as the gem5 LCPQ/GPEQ APIs, but with simplified semantics.
   For example, in gem5, a core will call a group of methods depending on if the core is a manager or worker:
   :code:`LCPQ_<POP/PUSH>` or :code:`GPEQ_<POP/PUSH>`.
   In TMJ, :code:`QIO_<POP/PUSH>` replaces the LCPQ/GPEQ methods and is callable by both workers and managers.

   It's illustrative to see how TMJ implements the methods provided for gem5 compatibility:

   .. code-block:: cpp

      // gem5 LCP calls
      #define              GPEQ_PUSH(gpe_id, data)        QIO_PUSH(gpe_id, data)
      #define              LCPQ_POP(gpe_id)               QIO_POP(gpe_id)
      __inline static bool GPEQ_ISEMPTY (uint32_t gpe_id) { return QIO_OUT_ISEMPTY(gpe_id); }
      __inline static bool GPEQ_ISFULL  (uint32_t gpe_id) { return QIO_OUT_ISFULL (gpe_id); }
      __inline static bool LCPQ_ISEMPTY (uint32_t gpe_id) { return QIO_IN_ISEMPTY (gpe_id); }
      __inline static bool LCPQ_ISFULL  (uint32_t gpe_id) { return QIO_IN_ISFULL  (gpe_id); }

      // gem5 GPE calls
      #define              LCPQ_PUSH(data)                QIO_PUSH(data)
      #define              GPEQ_POP(_void)                QIO_POP()
      __inline static bool GPEQ_ISEMPTY (void           ) { return QIO_IN_ISEMPTY (      ); }
      __inline static bool GPEQ_ISFULL  (void           ) { return QIO_IN_ISFULL  (      ); }
      __inline static bool LCPQ_ISEMPTY (void           ) { return QIO_OUT_ISEMPTY(      ); }
      __inline static bool LCPQ_ISFULL  (void           ) { return QIO_OUT_ISFULL (      ); }

Load/store intrinsics
-----------------------------------------------------------

.. doxygenfunction:: LOAD_WORD
.. doxygenfunction:: LOAD_WORD_FLOAT
.. doxygenfunction:: STORE_WORD
.. doxygenfunction:: STORE_WORD_FLOAT

Register-to-register intrinsics
-----------------------------------------------------------

Push/pop operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**For fixed point operands:**

.. doxygenfunction:: R2R_POP_WEST
.. doxygenfunction:: R2R_POP_EAST
.. doxygenfunction:: R2R_POP_NORTH
.. doxygenfunction:: R2R_POP_SOUTH

.. doxygenfunction:: R2R_PUSH_WEST
.. doxygenfunction:: R2R_PUSH_EAST
.. doxygenfunction:: R2R_PUSH_NORTH
.. doxygenfunction:: R2R_PUSH_SOUTH

**For floating point operands:**

.. doxygenfunction:: R2R_POP_WEST_FLOAT
.. doxygenfunction:: R2R_POP_EAST_FLOAT
.. doxygenfunction:: R2R_POP_NORTH_FLOAT
.. doxygenfunction:: R2R_POP_SOUTH_FLOAT

.. doxygenfunction:: R2R_PUSH_WEST_FLOAT
.. doxygenfunction:: R2R_PUSH_EAST_FLOAT
.. doxygenfunction:: R2R_PUSH_NORTH_FLOAT
.. doxygenfunction:: R2R_PUSH_SOUTH_FLOAT

.. note::
   The R2R APIs were originally written to be C99 compatible, but enabling basic C++
   constructs ended up not adding much overhead in terms of binary size anyway. The R2R_<PUSH/POP>
   methods might get replaced with templated functions, instead of differentiating types
   with explicitly different function names.

Control
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: R2R_ENABLE
.. doxygenfunction:: R2R_DISABLE

Software prefetching
-----------------------------------------------------------

.. doxygenfunction:: PREFETCH

.. warning::
   The hardware that implements prefetching is tested on only the most basic load/store sequences!
   There is high chance of breakage and/or unintuitive behavior.

L1 cache mode configuration
-----------------------------------------------------------

Configuration control
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These methods return or accept one of the macros defined above.

.. doxygenfunction:: SET_L1_MODE_SEQ
.. doxygenfunction:: GET_L1_MODE_SEQ

Configuration argument macros
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following macros define the available L1 cache reconfigurations.
We define a cache configuration as the combination of a `scope` (address scope) and `control type`.
Someday, we will get around to changing these to enums and updating all the unit tests ...

.. c:macro:: CTRL_SP_SCOPE_PRIV

   <control, scope> = scratchpad, private

.. c:macro:: CTRL_SP_SCOPE_SHRD

   <control, scope> = scratchpad, shared

.. c:macro:: CTRL_CA_SCOPE_PRIV

   <control, scope> = cache, private

.. c:macro:: CTRL_CA_SCOPE_SHRD

   <control, scope> = cache, shared

.. c:macro:: CTRL_RW_Q1_SCOPE_OTHER

   <control, scope> = queue, other [#]_

.. [#] Although "RW_Q1" is already obvious enough, the "other" scope was added to
   make sure this configuration was totally unambiguous.

L1 queue mode
-----------------------------------------------------------

Available with :c:macro:`CTRL_RW_Q1_SCOPE_OTHER`.

Push/pop operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

**For fixed point operands:**

.. doxygenfunction:: Q_PUSH_EAST
.. doxygenfunction:: Q_POP_WEST

**For floating point operands:**

.. doxygenfunction:: Q_PUSH_EAST_FLOAT
.. doxygenfunction:: Q_POP_WEST_FLOAT

Spatial coordinates
^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: Q_LEFT_EDGE
.. doxygenfunction:: Q_RIGHT_EDGE

Low-level cache invalidation
-----------------------------------------------------------

.. doxygenfunction:: MEM_WAIT_L1_ALL
.. doxygenfunction:: MEM_WAIT_L2_ALL
.. doxygenfunction:: INV_L1_ALL
.. doxygenfunction:: INV_L2_ALL
.. doxygenfunction:: INV_L2_BANK
.. doxygenfunction:: INV_TILE

.. note:: Recall that the L1 and L2 caches in TMJ are incoherent, with a read-allocate/write-through policy.
   This means that writes don't have to be explicitly flushed across the cache hierarchy, since writes
   will propagate through the caches anyway. However, cores that will load from addresses that were
   updated by other cores `should` perform an invalidation prior to the load(s), so that stale cache lines
   are replaced.

Low-level threading primitives
-----------------------------------------------------------

Mutexes
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cpp:type:: lock_t

   A lock variable. This is a uint32_t of 4 bytes.

.. doxygenfunction:: mutex_init
.. doxygenfunction:: mutex_lock
.. doxygenfunction:: mutex_unlock

Synchronization barriers
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cpp:type:: barrier_t

   A barrier variable. This is a packed struct of 16 bytes.

.. doxygenfunction:: barrier_init
.. doxygenfunction:: barrier_wait
.. doxygenfunction:: pthread_barrier_wait
.. doxygenfunction:: global_barrier_wait

Abstracted Runtime API
-----------------------------------------------------------

Setup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: RT_INIT

Thread synchronization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: sync_managers
.. doxygenfunction:: sync_workers
.. doxygenfunction:: sync_tile
.. doxygenfunction:: sync_all

Memory address getters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: GET_RAM_BASE
.. doxygenfunction:: GET_L1_SP_BASE
.. doxygenfunction:: GET_TSP_BASE
.. doxygenfunction:: GET_GSP_BASE

Memory allocation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: MALLOC_POLY
.. doxygenfunction:: FREE_POLY
.. doxygenfunction:: MALLOC_L0
.. doxygenfunction:: FREE_L0
.. doxygenfunction:: MEMSET

Memory barriers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: mem_barrier_tile
.. doxygenfunction:: mem_barrier_all
.. doxygenfunction:: mem_inv_all

Thread communication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: broadcast_send
.. doxygenfunction:: broadcast_recv

Test utilities
-----------------------------------------------------------

The methods handle synchronization and signaling with the host, using various hardware mechanisms on the chip.
Using these methods is required for testing on real hardware.
There are additional methods available when using the RTL simulator (e.g., to poke various registers), but
they are out-of-scope and not documented here.

.. doxygenfunction:: main_sync
.. doxygenfunction:: test_bar
.. doxygenfunction:: test_setup
.. doxygenfunction:: test_cleanup

Debug aids
-----------------------------------------------------------

Line breaking prints
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: PRINT
.. doxygenfunction:: PRINT_INT
.. doxygenfunction:: PRINT_HEX

Non-line breaking prints
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Prints are line-breaking by default, but breaks can be disabled by passing :code:`false` for the
optional argument :code:`flush`.
There are also the following convenience macros (suffixed with "_NF"):

.. code-block:: cpp

   // Non-linebreaking prints
   #define PRINT_NF(s)       PRINT(s, false)
   #define PRINT_INT_NF(v)   PRINT_INT(v, false)
   #define PRINT_HEX_NF(v)   PRINT_HEX(v, false)

Debug macros
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. c:macro:: DBG

   Enables "D" prefixed print methods, if added before the :code:`#include` for :file:`tmj_hal.h`.

.. code-block:: cpp
   :caption: DBG-enabled macros from :file:`tmj_hal.h`

   // Debug aliases and helper macros
   #ifdef DBG
      // flush prints (newline)
      #define DPRINT(s)          PRINT(s)
      #define DPRINT_INT(v)      PRINT_INT(v)
      #define DPRINT_HEX(v)      PRINT_HEX(v)
      // no flush variants
      #define DPRINT_NF(s)       PRINT_NF(s)
      #define DPRINT_INT_NF(v)   PRINT_INT_NF(v)
      #define DPRINT_HEX_NF(v)   PRINT_HEX_NF(v)
      // inject a line of code
      #define DBG_LINE(line)     line
   // Empty calls if DBG isn't defined
   #else
      // ...
      #define DPRINT(s)          {}
      #define DPRINT_INT(v)      {}
      #define DPRINT_HEX(v)      {}
      // ...
      #define DPRINT_NF(s)       {}
      #define DPRINT_INT_NF(v)   {}
      #define DPRINT_HEX_NF(v)   {}
      // ...
      #define DBG_LINE(line)     {}
   #endif

.. todo:: setup doxygen+breathe. writing these docs by hand was more tedious than I thought
