# Package

version = "0.14.2"
author = "Dmitry Matveyev"
description = "The Ultimate Raylib gaming library wrapper"
license = "MIT"
srcDir = "src"
skipFiles = @["generate_bindings"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"

from os import `/`, parentDir

task genbindings, "generate bindings":
  exec "nim r src"/"generate_bindings.nim"

task checkbindings, "nim check all generated bindings":
  const nimraylibNowDir = currentSourcePath().parentDir()/"src"/"nimraylib_now"
  exec "nim check " & nimraylibNowDir/"mangled"/"raylib.nim"
  exec "nim check " & nimraylibNowDir/"mangled"/"raygui.nim"
  exec "nim check " & nimraylibNowDir/"mangled"/"rlgl.nim"
  exec "nim check " & nimraylibNowDir/"mangled"/"raymath.nim"
  exec "nim check " & nimraylibNowDir/"mangled"/"physac.nim"
  exec "nim check " & nimraylibNowDir/"mangled"/"converters.nim"

  exec "nim check " & nimraylibNowDir/"not_mangled"/"raylib.nim"
  exec "nim check " & nimraylibNowDir/"not_mangled"/"raygui.nim"
  exec "nim check " & nimraylibNowDir/"not_mangled"/"rlgl.nim"
  exec "nim check " & nimraylibNowDir/"not_mangled"/"raymath.nim"
  exec "nim check " & nimraylibNowDir/"not_mangled"/"physac.nim"
  exec "nim check " & nimraylibNowDir/"not_mangled"/"converters.nim"

task prepareTests, "generate tests from examples":
  exec "nim r " & "scripts"/"make_tests_from_examples.nim"
  exec "nim r " & "scripts"/"make_individual_tests_from_examples.nim"
  exec "nim r " & "scripts"/"make_emscripten_tests_from_examples.nim"

task testExamples, "checks that all examples are correctly compiled":
  exec "testament pattern tests/texamples.nim"
  exec "testament pattern tests/texamples_shared.nim"
  exec "testament pattern tests/texamples_windows.nim"

# Can fail on Windows due to globbing rules
task testIndividualExamples, "slower but check that all examples compile individually":
  exec "testament pattern 'tests/examples/t_*.nim'"

task testEmscriptenExample, "run a single test with emsdk installed":
  exec "testament pattern 'tests/emscripten/t_*.nim'"
