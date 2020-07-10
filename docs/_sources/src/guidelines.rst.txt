Programming Guidelines & Gotchas
===================================

Guidelines
------------------

A few debugging tips:

- First thing to check is that pointers to RAM, caches, etc., are OK
  (``tmj_map.h`` is useful here, for reference)
- Second things to check are points of control synchronization
  (are ``sync_tile()`` or ``sync_all()`` calls in the right locations?)
- Last common thing to check is that memory barriers are inserted in the right locations
  (remember that the caches are incoherent)

Simulation speed

- See the :file:`README.md` in the ``tm_junior`` repo for tips on simulation performance

Gotchas
------------------


- There's no file system, or operating system! Passing command line args or loading files
  isn't possible

- STL containers haven't been tested, so use at your own risk :)
  STL containers aren't necessarily very performant anyway, and the overhead is undesirable for
  constrained programming environments
