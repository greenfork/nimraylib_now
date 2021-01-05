# Package

version = "0.1.0"
author = "Dmitry Matveyev"
description = "The Ultimate Raylib gaming library wrapper"
license = "MIT"
srcDir = "src"
skipFiles = @["converter.nim"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"
requires "c2nim"

task convert, "run with c2nim":
  echo "Running converter\n"
  exec "nim r src/converter.nim"
  echo "\nExecuting nim check\n"
  exec "nim check src/nimraylib_now/raylib.nim"
  exec "nim check src/nimraylib_now/raygui.nim"
  exec "nim check src/nimraylib_now/rlgl.nim"
  exec "nim check src/nimraylib_now/raymath.nim"
