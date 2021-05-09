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

    CurrentDirectory = currentSourcePath().parentDir()
    NimraylibNowProjectPath = CurrentDirectory.parentDir().parentDir()
    RaylibSrcPath = NimraylibNowProjectPath / "raylib" / "src"
    # Use relative paths just in case
    # https://github.com/nim-lang/Nim/issues/9370
    RaylibSrcPathRelative = relativePath(RaylibSrcPath, CurrentDirectory)

  {.passC: "-Wall -D_DEFAULT_SOURCE -Wno-missing-braces -Werror=pointer-arith -fno-strict-aliasing".}
  {.passC: "-std=c99".}

  when defined(linux):
    {.passC: "-fPIC".}

  {.passC: "-s -O1".}
  {.passC: "-Werror=implicit-function-declaration".}

  when defined(linux):
    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND".}
    else:
      {.passL: "-lX11".}

  {.passC: "-I" & RaylibSrcPath.}
  {.passC: "-I" & RaylibSrcPath & "/external/glfw/include".}
  {.passC: "-I" & RaylibSrcPath & "/external/glfw/deps/mingw".}

  when defined(bsd):
    {.passC: "-I/usr/local/include".}
    {.passL: "-L" & RaylibSrcPath.}
    {.passL: "-L" & RaylibSrcPath & "/src".}
    {.passL: "-L/usr/local/lib".}
    {.passL: "-L" & RaylibReleasePath.}

  {.passC: "-D" & Platform.}
  {.passC: "-D" & Graphics.}

  when defined(macosx):
    {.compile(fmt"{RaylibSrcPathRelative}/rglfw.c", "-x objective-c").}
  else:
    {.compile: fmt"{RaylibSrcPathRelative}/rglfw.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/shapes.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/textures.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/text.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/utils.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/models.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/raudio.c".}
  {.compile: fmt"{RaylibSrcPathRelative}/core.c".}
