## Static compilation of Raylib
## Conversion of raylib/src/Makefile

# Add the ability to do all the linking manually.
from os import parentDir, relativePath, `/`

import ../filenames

const
  CurrentDirectory = currentSourcePath().parentDir()
  RaylibRootPath {.used.} = raylibSrcDir.parentDir()
  RaylibSrcPath = raylibBuildDir
  # Use relative paths just in case
  # https://github.com/nim-lang/Nim/issues/9370
  RaylibSrcPathRelative = relativePath(RaylibSrcPath, CurrentDirectory)

when defined(emscripten):
  const Platform = "PLATFORM_WEB"
  const Graphics = "GRAPHICS_API_OPENGL_ES2"
else:
  const Platform = "PLATFORM_DESKTOP"
  const Graphics = "GRAPHICS_API_OPENGL_33"

{.passC: "-Wall -D_DEFAULT_SOURCE -Wno-missing-braces -Werror=pointer-arith -fno-strict-aliasing".}

when defined(emscripten):
  {.passC: "-std=gnu99".}
  {.passC: "-Os".}
else:
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

  when not defined(emscripten):
    when defined(nimraylib_now_wayland):
      {.passC: "-D_GLFW_WAYLAND".}
      {.passL: "-lwayland-client".}
      {.passL: "-lwayland-cursor".}
      {.passL: "-lwayland-egl".}
      {.passL: "-lxkbcommon".}
    else:
      {.passL: "-lX11".}

# *BSD platforms need to be tested.
when defined(bsd) and not defined(emscripten):
  {.passC: "-I/usr/local/include".}
  {.passL: "-L" & RaylibRootPath.}
  {.passL: "-L" & RaylibSrcPath & "/src".}
  {.passL: "-L/usr/local/lib".}
  {.passL: "-lX11".}
  {.passL: "-lXrandr".}
  {.passL: "-lXinerama".}
  {.passL: "-lXi".}
  {.passL: "-lXxf86vm".}
  {.passL: "-lXcursor".}

when defined(macosx) and not defined(emscripten):
  {.passL: "-framework CoreVideo".}
  {.passL: "-framework IOKit".}
  {.passL: "-framework Cocoa".}
  {.passL: "-framework GLUT".}
  {.passL: "-framework OpenGL".}

when defined(windows) and not defined(emscripten):
  {.passL: "-lgdi32".}
  {.passL: "-lopengl32".}
  {.passL: "-lwinmm".}
  {.passL: "-Wl,--subsystem,windows".}

when defined(emscripten):
  {.passL: "-s USE_GLFW=3".}
elif defined(macosx):
  {.compile(RaylibSrcPathRelative & "/rglfw.c", "-x objective-c").}
else:
  {.compile: RaylibSrcPathRelative & "/rglfw.c".}

{.compile: RaylibSrcPathRelative & "/shapes.c".}
{.compile: RaylibSrcPathRelative & "/textures.c".}
{.compile: RaylibSrcPathRelative & "/text.c".}
{.compile: RaylibSrcPathRelative & "/utils.c".}
{.compile: RaylibSrcPathRelative & "/models.c".}
{.compile: RaylibSrcPathRelative & "/raudio.c".}
{.compile: RaylibSrcPathRelative & "/core.c".}
