import httpclient, asyncdispatch
import strutils, strformat
from sequtils import any
from os import `/`, fileExists, extractFilename
from osproc import execCmd
from sugar import `=>`
import regex


# Download header files
# Skip downloading if all files are already present

const
  downloadDirectory = "raylib"
  urlStart = "https://raw.githubusercontent.com/raysan5/"
  filesToDownload = [
    "raylib/master/src/raylib.h",
    "raygui/master/src/raygui.h",
    "raylib/master/src/rlgl.h",
    "raylib/master/src/raymath.h",
  ]

proc downloadSources() {.async.} =
  var futures: seq[Future[void]]
  for file in filesToDownload:
    var client = newAsyncHttpClient()
    let
      url = urlStart & file
      targetPath = downloadDirectory/file.extractFilename
    futures.add client.downloadFile(url, targetPath)
  for future in futures:
    await future

var doDownload = false
for file in filesToDownload:
  if not fileExists(downloadDirectory/file.extractFilename):
    doDownload = true
    break
if doDownload:
  waitFor downloadSources()


# Parse files to (((Nim))) wrappers

# Formatting of identifiers
func fmtConst(s: string): string =
  s.toLowerAscii.capitalizeAscii

func peekFirst(ss: seq[string]): string =
  if ss.len > 0: ss[0]
  else: ""

const
  ignoreDefines = [
    "RLAPI", # used before C function definition
    "RL_MALLOC(sz)",
    "RL_CALLOC(n,sz)",
    "RL_REALLOC(ptr,sz)",
    "RL_FREE(ptr)",
    "CLITERAL(type)", # used for colors
    "FormatText", # deprecated function name
    "LoadText", # deprecated function name
    "GetExtension", # deprecated function name
    "GetImageData", # deprecated function name
    "PI", # already in math module
    "DEG2RAD", # already in math module
    "RAD2DEG", # already in math module
    "SpriteFont", # deprecated?
    "LOC_MAP_DIFFUSE", # deprecated?
    "LOC_MAP_SPECULAR", # deprecated?
    "MAP_DIFFUSE", # deprecated?
    "MAP_SPECULAR", # deprecated?
  ]
  allowIfs = [
    "RAYGUI_SUPPORT_ICONS"
  ]

const
  # #define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray
  reDefineColor = re"^#define ([[:word:]]+)\s*CLITERAL\(Color\)\{ (\d+), (\d+), (\d+), (\d+) \}.*"
  # typedef struct rAudioBuffer rAudioBuffer;
  reEmptyStructDef = re"^typedef struct ([[:word:]]+) ([[:word:]]+);.*"
  # typedef enum {
  reTypedefEnumStart = re"^typedef enum \{.*"
  # typedef enum { OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_ES_20 } GlVersion;
  reTypedefEnumOneline = re"^typedef enum \{.*\} ([[:word:]]+);.*"
  # } ConfigFlag;
  reTypedefEnd = re"^\} (\w+);"

const
  raylibHeader = """
#ifdef C2NIM
#  def RLAPI
#  dynlib raylibdll
#  cdecl
#  nep1
#  skipinclude
#  if defined(windows)
#    define raylibdll "libraylib.dll"
#  elif defined(macosx)
#    define raylibdll "libraylib.dylib"
#  else
#    define raylibdll "libraylib.so"
#  endif
#@
type VaList* {.importc, header: "<stdarg.h>".} = object
@#
#endif
"""
  rlglHeader = """
#ifdef C2NIM
#  def RLAPI
#  dynlib raylibdll
#  cdecl
#  nep1
#  skipinclude
#  prefix rlgl
#  prefix rl
#  prefix RL_
#  if defined(windows)
#    define raylibdll "libraylib.dll"
#  elif defined(macosx)
#    define raylibdll "libraylib.dylib"
#  else
#    define raylibdll "libraylib.so"
#  endif
#@
import raylib
@#
#endif
"""
  rayguiHeader = """
#ifdef C2NIM
#  def RAYGUIDEF
#  dynlib rayguidll
#  cdecl
#  nep1
#  skipinclude
#  prefix Gui
#  prefix GUI_
#  prefix gui
#  if defined(windows)
#    define rayguidll "libraygui.dll"
#  elif defined(macosx)
#    define rayguidll "libraygui.dylib"
#  else
#    define rayguidll "libraygui.so"
#  endif
#@
import raylib
@#
#endif
"""
  raymathHeader = """
#ifdef C2NIM
#  def RMDEF static inline
#  dynlib raylibdll
#  cdecl
#  nep1
#  skipinclude
#  if defined(windows)
#    define raylibdll "libraylib.dll"
#  elif defined(macosx)
#    define raylibdll "libraylib.dylib"
#  else
#    define raylibdll "libraylib.so"
#  endif
#@
import raylib
@#
#endif
"""

const
  raylibFiles = [
    ("raylib", raylibHeader),
    ("rlgl", rlglHeader),
    ("raygui", rayguiHeader),
    ("raymath", raymathHeader),
  ]
  selfModuleDeclarationNames = ["RAYLIB_H", "RLGL_H", "RAYGUI_H", "RAYMATH_H"]
  # For converters which are written before c2nim conversion with proper
  # name mangling. Should converters be written in postprocessing after c2nim?
  namePrefixes = ["rlgl", "rl", "RL_", "Gui", "GUI_", "gui"]
  targetDirectory = "src"/"nimraylib_now"


# Start processing all files
for (filename, c2nimheader) in raylibFiles:

  # Preprocessing of C header file before feeding it to c2nim

  block preprocessing:
    let
      raylibh = readFile("raylib"/filename & ".h")
      raylibhLines = raylibh.splitLines
    var
      rs: string
      appendToVeryEnd: string # as Nim code
      m: RegexMatch
    rs.add c2nimheader
    var i = 0
    while i < raylibhLines.len:
      let
        line = raylibhLines[i]
        words = line.splitWhitespace
      if selfModuleDeclarationNames.any((name) => name in words):
        if "#endif" in line: # this is the end of h file and start of implementation
          echo "Reached end of header part: " & line
          break
        echo "Ignore: " & line # skip all self-header module definitions
      elif line.match(reDefineColor, m):
        let
          colorName = m.groupFirstCapture(0, line)
          red = m.groupFirstCapture(1, line)
          green = m.groupFirstCapture(2, line)
          blue = m.groupFirstCapture(3, line)
          alpha = m.groupFirstCapture(4, line)
        appendToVeryEnd.add fmt"const {colorName.fmtConst}* = " &
          fmt("Color(r: {red}, g: {green}, b: {blue}, a: {alpha})\n")
      elif line.match(reEmptyStructDef, m):
        # c2nim can't parse it without {} in the middle
        # this seems as a forward declaration of a struct but no further
        # declaration actually happens
        let typename = m.groupFirstCapture(0, line)
        assert m.groupFirstCapture(1, line) == typename, "wrong typename: " & $i
        rs.add fmt"typedef struct {typename} {{}} {typename};"
      elif line.match(reTypedefEnumStart):
        # C uses enums in place of int32 numbers, so every enum takes an
        # appropriate converter to translate types in Nim implicitly
        var enumName =
          if line.match(reTypedefEnumOneline, m):
            m.groupFirstCapture(0, line)
          else:
            var
              enumEnd = i + 1
              enumEndLine = raylibhLines[enumEnd]
            while not enumEndLine.match(reTypedefEnd, m):
              enumEnd.inc
              enumEndLine = raylibhLines[enumEnd]
            m.groupFirstCapture(0, enumEndLine)
        for prefix in namePrefixes:
          if enumName.startsWith(prefix):
            enumName.removePrefix(prefix)
            break
        appendToVeryEnd.add(
          fmt("converter {enumName}ToInt32*(self: {enumName}): int32 = self.int32\n")
        )
        # Remember to still add this line
        rs.add line & "\n"
      elif words.len > 0 and (words[0] == "#if" or words[0] == "#ifndef") and
           allowIfs.any((ident) => ident notin line):
        echo "Ignore branch: " & line
        var nestLevels = 1
        while nestLevels > 0:
          i.inc
          let firstWord = raylibhLines[i].splitWhitespace.peekFirst
          if firstWord == "#endif":
            nestLevels.dec
          elif firstWord == "#if" or firstWord == "#ifndef":
            nestLevels.inc
      elif line.startsWith("RMDEF"):
        # raymath header file contains implementation and c2nim crashes
        # trying to parse it. Here implementation is stripped away and only
        # definition is left.
        rs.add line & ";\n"
        if i+1 < raylibhLines.len and raylibhLines[i+1] == "{":
          while raylibhLines[i] != "}": i.inc
      elif words.len > 1 and words[0] == "#define" and words[1] in ignoreDefines:
        echo "Ignore: " & line
      else:
        rs.add line & "\n"
      i.inc

    if appendToVeryEnd.len > 0:
      rs.add fmt"""
#ifdef C2NIM
#@
{appendToVeryEnd}
@#
#endif
"""
    writeFile("raylib"/fmt"{filename}_modified.h", rs)


  # Processing with c2nim

  echo "\nExecuting c2nim\n"
  assert execCmd("c2nim raylib"/fmt"{filename}_modified.h") == 0


  # Postprocessing of generated nim file by c2nim

  block postprocessing:
    let
      raylibnim = readFile("raylib"/fmt"{filename}_modified.nim")
      raylibnimLines = raylibnim.splitLines
    var rs: string
    var i = 0
    while i < raylibnimLines.len:
      # Replace all C-style types to native Nim ones
      # Until we use 9-qbit words for bytes, Nim definition should be
      # same as C definition and it allows one to write code without
      # constant conversions such as `let width = 640.cint`
      var line = raylibnimLines[i].multiReplace(
        # According to definitions in compiler Nim/lib/system.nim
        ("cint", "int32"),
        ("cschar", "int8"),
        ("cshort", "int16"),
        ("cint", "int32"),
        ("csize_t", "uint"),
        ("csize", "int"),
        ("clonglong", "int64"),
        ("cfloat", "float32"),
        ("cdouble", "float64"),
        ("clongdouble", "BiggestFloat"),
        ("cuchar", "uint8"), # digression from how compiler defines it
        ("cushort", "uint16"),
        ("cuint", "uint32"),
        ("culonglong", "uint64"),
      )
      if "{.size: sizeof(int32).} = enum" in line: # add `pure` pragma to enums
        line = line.replace(
          "{.size: sizeof(int32).} = enum",
          "{.size: sizeof(int32), pure.} = enum"
        )
      rs.add line & "\n"
      i.inc

    writeFile(targetDirectory/fmt"{filename}.nim", rs)
