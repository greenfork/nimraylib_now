## Static compilation of Raylib
## Conversion of raylib/src/Makefile

from os import parentDir, relativePath, `/`, quoteShell

const
  CurrentDirectory = currentSourcePath().parentDir()
  RaylibSrcPath = CurrentDirectory.parentDir() / "csources" / "raylib_mangled"
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

{.passC: quoteShell("-I" & RaylibSrcPath).}
{.passC: quoteShell("-I" & RaylibSrcPath / "external"/"glfw"/"include").}
{.passC: quoteShell("-I" & RaylibSrcPath / "external"/"glfw"/"deps"/"mingw").}
{.passC: quoteShell("-D" & Platform).}
{.passC: quoteShell("-D" & Graphics).}

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
      {.passL: "-lpthread".}

# *BSD platforms need to be tested.
when defined(bsd) and not defined(emscripten):
  {.passC: "-I"/"usr"/"local"/"include".}
  # {.passL: "-L" & RaylibRootPath.}
  {.passL: quoteShell("-L" & RaylibSrcPath / "src").}
  {.passL: "-L"/"usr"/"local"/"lib".}
  {.passL: "-lX11".}
  {.passL: "-lXrandr".}
  {.passL: "-lXinerama".}
  {.passL: "-lXi".}
  {.passL: "-lXxf86vm".}
  {.passL: "-lXcursor".}
  {.passL: "-lpthread".}

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

when defined(emscripten):
  const NimraylibNowTotalMemory {.intdefine.}: int = 134217728
  {.passL: "-s TOTAL_MEMORY=" & $NimraylibNowTotalMemory}

when defined(emscripten):
  {.passL: "-s USE_GLFW=3".}
elif defined(macosx):
  {.compile(quoteShell(RaylibSrcPathRelative / "rglfw.c"), "-x objective-c").}
else:
  {.compile: quoteShell(RaylibSrcPathRelative / "rglfw.c").}

{.compile: quoteShell(RaylibSrcPathRelative / "rshapes.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "rtextures.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "rtext.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "utils.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "rmodels.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "raudio.c").}
{.compile: quoteShell(RaylibSrcPathRelative / "rcore.c").}
