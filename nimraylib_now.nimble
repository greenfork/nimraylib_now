# Package

version = "0.12.2"
author = "Dmitry Matveyev"
description = "The Ultimate Raylib gaming library wrapper"
license = "MIT"
srcDir = "src"
skipFiles = @["convert_c_to_nim.nim", "prepare_build_files.nim", "filenames.nim",
  "common_files_setup.nim"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"

from os import `/`

task convert, "run with c2nim":
  let
    common_files_setupFile = "src"/"common_files_setup.nim"
    convert_c_to_nimFile = "src"/"convert_c_to_nim.nim"
    prepare_build_filesFile = "src"/"prepare_build_files.nim"

    nimraylibNowDir = "src"/"nimraylib_now"

    raylibFile = "src"/"nimraylib_now"/"raylib.nim"
    rayguiFile = "src"/"nimraylib_now"/"raygui.nim"
    rlglFile = "src"/"nimraylib_now"/"rlgl.nim"
    raymathFile = "src"/"nimraylib_now"/"raymath.nim"
    physacFile = "src"/"nimraylib_now"/"physac.nim"
    convertersFile = "src"/"nimraylib_now"/"converters.nim"

  echo "Running clear target directories\n"
  exec "nim r " & common_files_setupFile

  echo "Running prepare build files\n"
  exec "nim r " & prepare_build_filesFile
  echo "Running converter\n"
  exec "nim r " & convert_c_to_nimFile

  echo "Running prepare build files -d:nimraylib_now_mangle\n"
  exec "nim r -d:nimraylib_now_mangle " & prepare_build_filesFile
  echo "Running converter -d:nimraylib_now_mangle\n"
  exec "nim r -d:nimraylib_now_mangle " & convert_c_to_nimFile

  echo "\nExecuting nim check\n"
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

task testExamples, "checks that all examples are correctly compiled":
  exec "nim r " & "scripts"/"make_tests_from_examples.nim"
  exec "testament pattern tests/texamples.nim"
  exec "testament pattern tests/texamples_shared.nim"
  exec "testament pattern tests/texamples_windows.nim"

# Can fail on Windows due to globbing rules
task testIndividualExamples, "slower but check that all examples compile individually":
  exec "nim r " & "scripts"/"make_individual_tests_from_examples.nim"
  exec "testament pattern 'tests/examples/t_*.nim'"

task testEmscriptenExample, "run a single test with emsdk installed":
  exec "nim r " & "scripts"/"make_emscripten_tests_from_examples.nim"
  exec "testament pattern 'tests/emscripten/t_*.nim'"
