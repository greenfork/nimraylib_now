## Static compilation of Raylib
## Conversion of raylib/src/Makefile
## Right now it supports only Desktop targets, any other targets should be
## compiled and linkedin manually.

# Add the ability to do all the linking manually.
when not defined(nimraylib_now_linkingOverride):
  from os import parentDir, relativePath, `/`

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
  {.passC: "-s -O1".}
  {.passC: "-Werror=implicit-function-declaration".}
  {.passC: "-I" & RaylibSrcPath.}
  {.passC: "-I" & RaylibSrcPath & "/external/glfw/include".}
  {.passC: "-I" & RaylibSrcPath & "/external/glfw/deps/mingw".}
  {.passC: "-D" & Platform.}
  {.passC: "-D" & Graphics.}

  when defined(linux):
    {.passC: "-fPIC".}
    when defined(nimraylib_now_wayland):
      {.passC: "-D_GLFW_WAYLAND".}
    else:
      {.passL: "-lX11".}

  # *BSD platforms need to be tested.
  when defined(bsd):
    {.passC: "-I/usr/local/include".}
    {.passL: "-L" & RaylibSrcPath.}
    # {.passL: "-L" & RaylibSrcPath & "/src".}
    {.passL: "-L/usr/local/lib".}
    {.passL: "-L" & RaylibSrcPath.}

  when defined(macosx):
    {.passL: "-framework CoreVideo".}
    {.passL: "-framework IOKit".}
    {.passL: "-framework Cocoa".}
    {.passL: "-framework GLUT".}
    {.passL: "-framework OpenGL".}

  when defined(windows):
    {.passL: "-lgdi32".}

  when defined(macosx):
    {.compile(RaylibSrcPathRelative & "/rglfw.c", "-x objective-c").}
  # elif defined(windows):
  #   {.compile(RaylibSrcPathRelative & "/rglfw.c", "-lgdi32").}
  else:
    {.compile: RaylibSrcPathRelative & "/rglfw.c".}

  {.compile: RaylibSrcPathRelative & "/shapes.c".}
  {.compile: RaylibSrcPathRelative & "/textures.c".}
  {.compile: RaylibSrcPathRelative & "/text.c".}
  {.compile: RaylibSrcPathRelative & "/utils.c".}
  {.compile: RaylibSrcPathRelative & "/models.c".}
  {.compile: RaylibSrcPathRelative & "/raudio.c".}
  {.compile: RaylibSrcPathRelative & "/core.c".}
