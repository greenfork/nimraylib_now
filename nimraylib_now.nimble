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

task dorun, "run":
  exec "nim r src/nimraylib_now"

task c2nim, "run with c2nim":
  echo "Executing nim r\n"
  exec "nim r src/nimraylib_now"
  echo "\nExecuting nim check\n"
  exec "nim check raylib/raylib.nim"
