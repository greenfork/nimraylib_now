discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

include ../../examples/shaders/shaders_basic_lighting
