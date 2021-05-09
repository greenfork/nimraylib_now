## Static compilation of Raylib
## Conversion of raylib/src/Makefile
## Right now it supports only Desktop targets, any other targets should be
## compiled and linkedin manually.

# Add the ability to do all the linking manually.
when not defined(linkingOverride):
  import os, strformat

  const
    Platform = "PLATFORM_DESKTOP"
    Graphics = "GRAPHICS_API_OPENGL_33"

    # Paths
    CurrentDirectory = currentSourcePath().parentDir()
    NimraylibNowProjectPath = CurrentDirectory.parentDir().parentDir()
    RaylibSrcPath = NimraylibNowProjectPath / "raylib" / "src"
    # Use relative paths just in case
    # https://github.com/nim-lang/Nim/issues/9370
    RaylibSrcPathRelative = relativePath(RaylibSrcPath, CurrentDirectory)

  var
    cflags {.compileTime.}: string
    ldflags {.compileTime.}: string
    ldlibs {.compileTime.}: string
    includePaths {.compileTime.}: string
    glfwosx {.compileTime.}: string

  when defined(macosx):
    glfwosx &= " -x objective-c"

  cflags &= " -Wall -D_DEFAULT_SOURCE -Wno-missing-braces -Werror=pointer-arith -fno-strict-aliasing"
  cflags &= " -std=c99"

  when defined(linux):
    cflags &= " -fPIC"

  cflags &= " -s -O1"
  cflags &= " -Werror=implicit-function-declaration"

  when defined(linux):
    when defined(wayland):
      cflags &= " -D_GLFW_WAYLAND"
    else:
      ldlibs &= " -lX11"

  includePaths &= fmt" -I{RaylibSrcPathRelative}"
  includePaths &= fmt" -I{RaylibSrcPathRelative}/external/glfw/include"
  includePaths &= fmt" -I{RaylibSrcPathRelative}/external/glfw/deps/mingw"

  when defined(bsd):
    includePaths &= " -I/usr/local/include"
    ldflags &= fmt" -L{RaylibSrcPathRelative}"
    ldflags &= fmt" -L{RaylibSrcPathRelative}/src"
    ldflags &= " -L/usr/local/lib"
    ldflags &= fmt" -L{RaylibReleasePathRelative}"

  {.passC: cflags.}
  {.passC: fmt"-D{Platform}".}
  {.passC: fmt"-D{Graphics}".}
  {.passL: ldlibs.}
  {.passL: ldflags.}
  {.passL: includePaths.}

  {.compile(fmt"{RaylibSrcPathRelative}/rglfw.c", glfwosx).}
  {.compile: fmt"{RaylibSrcPathRelative}/shapes.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/textures.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/text.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/utils.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/models.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/raudio.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/core.c".}
