discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

include ../../examples/audio/audio_module_playing
