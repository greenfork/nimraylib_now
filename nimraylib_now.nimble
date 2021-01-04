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

task dorun, "run":
  exec "nim r src/nimraylib_now"
