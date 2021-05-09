# Package

version = "0.10.0"
author = "Dmitry Matveyev"
description = "The Ultimate Raylib gaming library wrapper"
license = "MIT"
srcDir = "src"
skipFiles = @["converter.nim", "mangle_names.nim"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"

from os import `/`

task convert, "run with c2nim":
  let
    converterFile = "src"/"converter.nim"
    manglerFile = "src"/"mangle_names.nim"
    raylibFile = "src"/"nimraylib_now"/"raylib.nim"
    rayguiFile = "src"/"nimraylib_now"/"raygui.nim"
    rlglFile = "src"/"nimraylib_now"/"rlgl.nim"
    raymathFile = "src"/"nimraylib_now"/"raymath.nim"
    physacFile = "src"/"nimraylib_now"/"physac.nim"
  echo "Running name mangler\n"
  exec "nim r " & manglerFile
  echo "Running converter\n"
  exec "nim r " & converterFile
  echo "\nExecuting nim check\n"
  exec "nim check " & raylibFile
  exec "nim check " & rlglFile
  exec "nim check " & raymathFile
  exec "nim check " & rayguiFile
  exec "nim check " & physacFile

task testExamples, "checks that all examples are correctly compiled":
  exec "testament run texamples.nim"
  exec "testament run texamples_windows.nim"
