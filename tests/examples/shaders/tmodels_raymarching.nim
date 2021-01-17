discard """
  action: "compile"
  joinable: false
  matrix: "; --gc:orc; -d:release"
  # more
"""
include ../../../examples/shaders/models_raymarching