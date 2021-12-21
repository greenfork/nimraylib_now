from os import `/`, parentDir, copyFileToDir, removeDir, createDir, walkDir,
  copyDir
import strutils

import ./filenames

# Copy C headers and sources to build directory
# build directory structure:
# - build/ :: C header files which will be modified and converted to Nim sources
# - build/raylib_src :: raylib sources which will be used for static build

removeDir(buildDir)
createDir(buildDir)
writeFile(buildDir/".gitkeep", "")
createDir(raylibBuildDir)
copyDir(raylibSrcDir, raylibBuildDir)
copyFileToDir(raylibSrcDir/"extras"/"physac.h", raylibBuildDir)
copyFileToDir(raylibSrcDir/"extras"/"raygui.h", raylibBuildDir)

const
  raylibHeaders = [
    raylibBuildFile,
    rlglBuildFile,
    raymathBuildFile,
    physacBuildFile,
    rayguiBuildFile,
  ]

const
  queryPerfFiles = [
    raylibBuildDir/"rgestures.h",
    raylibBuildDir/"physac.h",
  ]

for file in queryPerfFiles:
  var content: string
  for line in file.lines:
    if "int __stdcall QueryPerformanceCounter" in line or
       "int __stdcall QueryPerformanceFrequency" in line:
      echo "Ignore: " & line & "\n"
    else:
      content.add line & "\n"
  writeFile(file, content)

const
  raylibSources = [
    raylibBuildDir/"rshapes.c",
    raylibBuildDir/"rtextures.c",
    raylibBuildDir/"rtext.c",
    raylibBuildDir/"utils.c",
    raylibBuildDir/"rmodels.c",
    raylibBuildDir/"raudio.c",
    raylibBuildDir/"rcore.c",
  ]
  raymathPreamble = """
#undef near // undefine clashing macros (from windows.h)
#undef far  // undefine clashing macros (from windows.h)
"""
  # https://github.com/raysan5/raylib/issues/1217
  windowsHPreamble = """
#if defined(_WIN32)
// To avoid conflicting windows.h symbols with raylib, some flags are defined
// WARNING: Those flags avoid inclusion of some Win32 headers that could be required
// by user at some point and won't be included...
//-------------------------------------------------------------------------------------

// If defined, the following flags inhibit definition of the indicated items.
#define NOGDICAPMASKS     // CC_*, LC_*, PC_*, CP_*, TC_*, RC_
#define NOVIRTUALKEYCODES // VK_*
#define NOWINMESSAGES     // WM_*, EM_*, LB_*, CB_*
#define NOWINSTYLES       // WS_*, CS_*, ES_*, LBS_*, SBS_*, CBS_*
#define NOSYSMETRICS      // SM_*
#define NOMENUS           // MF_*
#define NOICONS           // IDI_*
#define NOKEYSTATES       // MK_*
#define NOSYSCOMMANDS     // SC_*
#define NORASTEROPS       // Binary and Tertiary raster ops
#define NOSHOWWINDOW      // SW_*
#define OEMRESOURCE       // OEM Resource values
#define NOATOM            // Atom Manager routines
#define NOCLIPBOARD       // Clipboard routines
#define NOCOLOR           // Screen colors
#define NOCTLMGR          // Control and Dialog routines
#define NODRAWTEXT        // DrawText() and DT_*
#define NOGDI             // All GDI defines and routines
#define NOKERNEL          // All KERNEL defines and routines
#define NOUSER            // All USER defines and routines
//#define NONLS             // All NLS defines and routines
#define NOMB              // MB_* and MessageBox()
#define NOMEMMGR          // GMEM_*, LMEM_*, GHND, LHND, associated routines
#define NOMETAFILE        // typedef METAFILEPICT
#define NOMINMAX          // Macros min(a,b) and max(a,b)
#define NOMSG             // typedef MSG and associated routines
#define NOOPENFILE        // OpenFile(), OemToAnsi, AnsiToOem, and OF_*
#define NOSCROLL          // SB_* and scrolling routines
#define NOSERVICE         // All Service Controller routines, SERVICE_ equates, etc.
#define NOSOUND           // Sound driver routines
#define NOTEXTMETRIC      // typedef TEXTMETRIC and associated routines
#define NOWH              // SetWindowsHook and WH_*
#define NOWINOFFSETS      // GWL_*, GCL_*, associated routines
#define NOCOMM            // COMM driver routines
#define NOKANJI           // Kanji support stuff.
#define NOHELP            // Help engine interface.
#define NOPROFILER        // Profiler interface.
#define NODEFERWINDOWPOS  // DeferWindowPos routines
#define NOMCX             // Modem Configuration Extensions

// Type required before windows.h inclusion
typedef struct tagMSG *LPMSG;

#include <windows.h>

// Type required by some unused function...
typedef struct tagBITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;

#include <objbase.h>
#include <mmreg.h>
#include <mmsystem.h>

// Some required types defined for MSVC/TinyC compiler
#if defined(_MSC_VER) || defined(__TINYC__)
    #include "propidl.h"
#else
    #include <oleidl.h>
#endif
#endif
"""

# Modify raylib files in-place inside build/ directory
for file in raylibHeaders:
  if file.endsWith("raymath.h"):
    var fileContent: string = raymathPreamble & readFile(file)
    writeFile(file, fileContent)
  elif file.endsWith("raylib.h"):
    var fileContent: string = windowsHPreamble & readFile(file)
    writeFile(file, fileContent)

copyDir(raylibBuildDir, cSourcesDir)

# Copy files to build directory for converting to Nim files
# Copy files to target directory to be used during linking with Nim files
for file in raylibHeaders:
  copyFileToDir(file, buildDir)
  copyFileToDir(file, targetDir)
