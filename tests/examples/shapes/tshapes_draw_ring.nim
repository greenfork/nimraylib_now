discard """
  action: "compile"
  joinable: false
  matrix: "; --gc:orc; -d:release"
  # more
"""
include ../../../examples/shapes/shapes_draw_ring