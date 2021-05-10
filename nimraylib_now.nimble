# Package

version = "0.11.0"
author = "Dmitry Matveyev"
description = "The Ultimate Raylib gaming library wrapper"
license = "MIT"
srcDir = "src"
skipFiles = @["convert_c_to_nim.nim", "mangle_names.nim", "filenames.nim"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"

from os import `/`

task convert, "run with c2nim":
  let
    convert_c_to_nimFile = "src"/"convert_c_to_nim.nim"
    manglerFile = "src"/"mangle_names.nim"
    raylibFile = "src"/"nimraylib_now"/"raylib.nim"
    rayguiFile = "src"/"nimraylib_now"/"raygui.nim"
    rlglFile = "src"/"nimraylib_now"/"rlgl.nim"
    raymathFile = "src"/"nimraylib_now"/"raymath.nim"
    physacFile = "src"/"nimraylib_now"/"physac.nim"
    convertersFile = "src"/"nimraylib_now"/"converters.nim"
  echo "Running name mangler\n"
  exec "nim r " & manglerFile
  echo "Running converter\n"
  exec "nim r " & convert_c_to_nimFile
  echo "\nExecuting nim check\n"
  exec "nim check " & raylibFile
  exec "nim check " & rlglFile
  exec "nim check " & raymathFile
  exec "nim check " & rayguiFile
  exec "nim check " & physacFile
  exec "nim check " & convertersFile

task testExamples, "checks that all examples are correctly compiled":
  exec "nim r " & "scripts"/"make_tests_from_examples.nim"
  exec "testament run texamples.nim"
  # exec "testament run texamples_shared.nim"
  exec "testament run texamples_windows.nim"

# Can fail on Windows due to globbing rules
task testIndividualExamples, "slower but check that all examples compile individually":
  exec "nim r " & "scripts"/"make_individual_tests_from_examples.nim"
  exec "testament pattern 'tests/examples/t_*.nim'"

task testEmscriptenExample, "run a single test with emsdk installed":
  exec "nim r " & "scripts"/"make_emscripten_tests_from_examples.nim"
  exec "testament pattern 'tests/emscripten/t_*.nim'"
