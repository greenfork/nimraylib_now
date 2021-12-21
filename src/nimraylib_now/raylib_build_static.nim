## Static compilation of Raylib
## Conversion of raylib/src/Makefile

# Add the ability to do all the linking manually.
from os import parentDir, relativePath, `/`, quoteShell

import ../filenames

const
  CurrentDirectory = currentSourcePath().parentDir()
  # Use relative paths just in case
  # https://github.com/nim-lang/Nim/issues/9370
  RaylibSrcPathRelative = relativePath(cSourcesDir, CurrentDirectory)

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

{.passC: quoteShell("-I" & cSourcesDir).}
{.passC: quoteShell("-I" & cSourcesDir / "external"/"glfw"/"include").}
{.passC: quoteShell("-I" & cSourcesDir / "external"/"glfw"/"deps"/"mingw").}
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
  {.passL: quoteShell("-L" & cSourcesDir / "src").}
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

  # # Magic defines that will remove colliding names from windows.h,
  # # see https://github.com/raysan5/raylib/issues/1217.
  # {.passC: "-DNOGDICAPMASKS".}     # CC_*, LC_*, PC_*, CP_*, TC_*, RC_
  # {.passC: "-DNOVIRTUALKEYCODES".} # VK_*
  # {.passC: "-DNOWINMESSAGES".}     # WM_*, EM_*, LB_*, CB_*
  # {.passC: "-DNOWINSTYLES".}       # WS_*, CS_*, ES_*, LBS_*, SBS_*, CBS_*
  # {.passC: "-DNOSYSMETRICS".}      # SM_*
  # {.passC: "-DNOMENUS".}           # MF_*
  # {.passC: "-DNOICONS".}           # IDI_*
  # {.passC: "-DNOKEYSTATES".}       # MK_*
  # {.passC: "-DNOSYSCOMMANDS".}     # SC_*
  # {.passC: "-DNORASTEROPS".}       # Binary and Tertiary raster ops
  # {.passC: "-DNOSHOWWINDOW".}      # SW_*
  # {.passC: "-DOEMRESOURCE".}       # OEM Resource values
  # {.passC: "-DNOATOM".}            # Atom Manager routines
  # {.passC: "-DNOCLIPBOARD".}       # Clipboard routines
  # {.passC: "-DNOCOLOR".}           # Screen colors
  # {.passC: "-DNOCTLMGR".}          # Control and Dialog routines
  # {.passC: "-DNODRAWTEXT".}        # DrawText() and DT_*
  # {.passC: "-DNOGDI".}             # All GDI defines and routines
  # {.passC: "-DNOKERNEL".}          # All KERNEL defines and routines
  # {.passC: "-DNOUSER".}            # All USER defines and routines
  # {.passC: "-DNOMB".}              # MB_* and MessageBox()
  # {.passC: "-DNOMEMMGR".}          # GMEM_*, LMEM_*, GHND, LHND, associated routines
  # {.passC: "-DNOMETAFILE".}        # typedef METAFILEPICT
  # {.passC: "-DNOMINMAX".}          # Macros min(a,b) and max(a,b)
  # {.passC: "-DNOMSG".}             # typedef MSG and associated routines
  # {.passC: "-DNOOPENFILE".}        # OpenFile(), OemToAnsi, AnsiToOem, and OF_*
  # {.passC: "-DNOSCROLL".}          # SB_* and scrolling routines
  # {.passC: "-DNOSERVICE".}         # All Service Controller routines, SERVICE_ equates, etc.
  # {.passC: "-DNOSOUND".}           # Sound driver routines
  # {.passC: "-DNOTEXTMETRIC".}      # typedef TEXTMETRIC and associated routines
  # {.passC: "-DNOWH".}              # SetWindowsHook and WH_*
  # {.passC: "-DNOWINOFFSETS".}      # GWL_*, GCL_*, associated routines
  # {.passC: "-DNOCOMM".}            # COMM driver routines
  # {.passC: "-DNOKANJI".}           # Kanji support stuff.
  # {.passC: "-DNOHELP".}            # Help engine interface.
  # {.passC: "-DNOPROFILER".}        # Profiler interface.
  # {.passC: "-DNODEFERWINDOWPOS".}  # DeferWindowPos routines
  # {.passC: "-DNOMCX".}             # Modem Configuration Extensions


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
