discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

include ../../examples/core/core_random_values
