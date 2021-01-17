discard """
  action: "compile"
  joinable: false
  matrix: "; --gc:orc; -d:release"
  # more
"""
include ../../../examples/audio/audio_module_playing