discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

include ../../examples/physics/physics_friction
