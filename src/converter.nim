import strutils, strformat
from sequtils import any
from os import `/`, fileExists, extractFilename, changeFileExt, parentDir,
  copyFileToDir
from osproc import execCmd
from sugar import `=>`
import regex


# Copy header files from C sources to build directory

const
  projectDir = currentSourcePath().parentDir().parentDir()
  raylibDir = projectDir/"raylib"
  rayguiDir = projectDir/"raygui"
  filesToConvert = [
    raylibDir/"src/raylib.h",
    raylibDir/"src/rlgl.h",
    raylibDir/"src/raymath.h",
    rayguiDir/"src/raygui.h",
  ]
  buildDir = projectDir/"build"
  targetDirectory = projectDir/"src"/"nimraylib_now"

for file in filesToConvert:
  copyFileToDir(file, buildDir)


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

  # #define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray
  reDefineColor = re"^#define ([[:word:]]+)\s*CLITERAL\(Color\)\{ (\d+), (\d+), (\d+), (\d+) \}.*"
  # typedef struct rAudioBuffer rAudioBuffer;
  reEmptyStructDef = re"^typedef struct ([[:word:]]+) ([[:word:]]+);.*"
  # typedef enum {
  reTypedefEnumStart = re"^typedef enum \{.*"
  # typedef enum { OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_ES_20 } GlVersion;
  reTypedefEnumOneline = re"^typedef enum \{[^}]*\} ([[:word:]]+);.*"
  # } ConfigFlag;
  reTypedefEnd = re"^\} (\w+);"

  raylibHeader = """
#ifdef C2NIM
#  def RLAPI
#  dynlib raylibdll
#  cdecl
#  nep1
#  skipinclude
#  prefix FLAG_
#  prefix LOG_
#  prefix KEY_
#  prefix MOUSE_
#  prefix GAMEPAD_
#  prefix LOC_
#  prefix UNIFORM_
#  prefix MAP_
#  prefix FILTER_
#  prefix WRAP_
#  prefix CUBEMAP_
#  prefix FONT_
#  prefix BLEND_
#  prefix GESTURE_
#  prefix CAMERA_
#  mangle va_list va_list
#  private raylibdll
#  if defined(windows)
#    define raylibdll "libraylib.dll"
#  elif defined(macosx)
#    define raylibdll "libraylib.dylib"
#  else
#    define raylibdll "libraylib.so"
#  endif
#@
# Functions on C varargs
# Used only for TraceLogCallback type, see core_custom_logging example
type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object
proc vprintf*(format: cstring, args: va_list) {.cdecl, importc: "vprintf", header: "<stdio.h>"}
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
#  private raylibdll
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
  raymathHeader = """
#ifdef C2NIM
#  def RMDEF static inline
#  dynlib raylibdll
#  cdecl
#  nep1
#  skipinclude
#  private raylibdll
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
#  private rayguidll
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

  raylibFiles = [
    (buildDir/"raylib.h", raylibHeader),
    (buildDir/"rlgl.h", rlglHeader),
    (buildDir/"raymath.h", raymathHeader),
    (buildDir/"raygui.h", rayguiHeader),
  ]
  selfModuleDeclarationNames = ["RAYLIB_H", "RLGL_H", "RAYGUI_H", "RAYMATH_H"]
  # For converters which are written before c2nim conversion with proper
  # name mangling. Should converters be written in postprocessing after c2nim?
  namePrefixes = ["rlgl", "rl", "RL_", "Gui", "GUI_", "gui"]


# Start processing all files
for (filepath, c2nimheader) in raylibFiles:
  let filename = filepath.extractFilename.changeFileExt("")

  # Preprocessing of C header file before feeding it to c2nim

  block preprocessing:
    let
      raylibh = readFile(filepath)
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
        # C uses enums in place of int numbers, so every enum takes an
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
        let convertType =
          if enumName == "ConfigFlag": "cuint"
          else: "cint"
        appendToVeryEnd.add(
          fmt("converter {enumName}ToInt*(self: {enumName}): {convertType} = self.{convertType}\n")
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
    writeFile(buildDir/fmt"{filename}_modified.h", rs)


  # Processing with c2nim

  echo "\nExecuting c2nim\n"
  assert execCmd("c2nim " & (buildDir/fmt"{filename}_modified.h")) == 0


  # Postprocessing of generated nim file by c2nim

  block postprocessing:
    const
      # Conversions from tuple to object for Vector2, Vector3, Vector4,
      # Matrix and Rectangle. Quaternion is same as Vector4, so works too.
      tupleConverters = """
converter tupleToColor*(self: tuple[r,g,b,a: int]): Color =
  Color(r: self.r.uint8, g: self.g.uint8, b: self.b.uint8, a: self.a.uint8)

converter tupleToColor*(self: tuple[r,g,b: int]): Color =
  Color(r: self.r.uint8, g: self.g.uint8, b: self.b.uint8, a: 255)

converter tupleToVector2*(self: tuple[x,y: float]): Vector2 =
  Vector2(x: self.x.cfloat, y: self.y.cfloat)

converter tupleToVector3*(self: tuple[x,y,z: float]): Vector3 =
  Vector3(x: self.x.cfloat, y: self.y.cfloat, z: self.z.cfloat)

converter tupleToVector4*(self: tuple[x,y,z,w: float]): Vector4 =
  Vector4(x: self.x.cfloat, y: self.y.cfloat, z: self.z.cfloat, w: self.w.cfloat)

converter tupleToMatrix*(self:
  tuple[m0,m4,m8, m12,
        m1,m5,m9, m13,
        m2,m6,m10,m14,
        m3,m7,m11,m15: float]
): Matrix =
  Matrix(
    m0: self.m0.cfloat, m4: self.m4.cfloat, m8:  self.m8.cfloat,  m12: self.m12.cfloat,
    m1: self.m1.cfloat, m5: self.m5.cfloat, m9:  self.m9.cfloat,  m13: self.m13.cfloat,
    m2: self.m2.cfloat, m6: self.m6.cfloat, m10: self.m10.cfloat, m14: self.m14.cfloat,
    m3: self.m3.cfloat, m7: self.m7.cfloat, m11: self.m11.cfloat, m15: self.m15.cfloat,
  )

converter tupleToRectangle*(self: tuple[x,y,width,height: float]): Rectangle =
  Rectangle(x: self.x.cfloat, y: self.y.cfloat, width: self.width.cfloat, height: self.height.cfloat)
"""
      cTypeConverters = """
converter toCint*(self: int): cint = self.cint
converter toInt*(self: cint): int = self.int
"""
    let
      raylibnim = readFile(buildDir/fmt"{filename}_modified.nim")
      # Digression from how compiler defines it, used for Color
      raylibnimConvertedTypes = raylibnim.replace("cuchar", "uint8")
      raylibnimLines = raylibnimConvertedTypes.splitLines
    var rs: string
    var i = 0
    while i < raylibnimLines.len:
      var line = raylibnimLines[i]
      if "{.size: sizeof(cint).} = enum" in line: # add `pure` pragma to enums
        line = line.replace(
          "{.size: sizeof(cint).} = enum",
          "{.size: sizeof(cint), pure.} = enum"
        )
        rs.add line & "\n"
        i.inc
      else:
        rs.add line & "\n"
        i.inc
    if filename == "raylib":
      rs.add tupleConverters
      rs.add "\n"
      rs.add cTypeConverters
    writeFile(targetDirectory/fmt"{filename}.nim", rs)
