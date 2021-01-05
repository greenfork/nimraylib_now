# Package

version = "0.1.0"
author = "Dmitry Matveyev"
description = "Raylib wrapper for head version"
license = "MIT"
srcDir = "src"
bin = @["nimraylib_now"]
backend = "c"

# Dependencies

requires "nim >= 1.4.2"
requires "regex"
requires "c2nim"

task convert, "run with c2nim":
  echo "Running converter\n"
  exec "nim r src/converter.nim"
  echo "\nExecuting nim check\n"
  exec "nim check raylib/raylib.nim"
  exec "nim check raylib/raygui.nim"
  exec "nim check raylib/rlgl.nim"
  exec "nim check raylib/raymath.nim"
