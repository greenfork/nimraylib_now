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
    raylibDir/"src/physac.h",
  ]
  buildDir = projectDir/"build"
  targetDir = projectDir/"src"/"nimraylib_now"

for file in filesToConvert:
  copyFileToDir(file, buildDir)
  copyFileToDir(file, targetDir)


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
    "FILTER_POINT", # deprecated enum value
    "FILTER_BILINEAR", # deprecated enum value
    "MAP_DIFFUSE", # deprecated enum value
    "UNCOMPRESSED_R8G8B8A8", # deprecated enum value
    "PI", # already in math module
    "DEG2RAD", # already in math module
    "RAD2DEG", # already in math module
    "SpriteFont", # deprecated?
    "LOC_MAP_DIFFUSE", # deprecated?
    "LOC_MAP_SPECULAR", # deprecated?
    "MAP_DIFFUSE", # deprecated?
    "MAP_SPECULAR", # deprecated?
    "PHYSAC_PI", # already in math module
    "PHYSAC_DEG2RAD", # already in math module
    "MATERIAL_MAP_DIFFUSE", # deprecated enum value
    "MATERIAL_MAP_SPECULAR", # deprecated enum value
    "SHADER_LOC_MAP_DIFFUSE", # deprecated enum value
    "SHADER_LOC_MAP_SPECULAR", # deprecated enum value
  ]
  allowIfs = [
    "RAYGUI_SUPPORT_ICONS"
  ]

  # #define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray
  reDefineColor = re"^#define ([[:word:]]+)\s*CLITERAL\(Color\)\{ (\d+), (\d+), (\d+), (\d+) \}.*"
  # typedef struct rAudioBuffer rAudioBuffer;
  reEmptyStructDef = re"^typedef struct ([[:word:]]+) (\*?[[:word:]]+);.*"
  # } PhysicsBodyData;
  reStructDefEnd = re"^\} (\*?[[:word:]]+);.*"
  # typedef enum {
  reTypedefEnumStart = re"^typedef enum \{.*"
  # typedef enum { OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_ES_20 } GlVersion;
  reTypedefEnumOneline = re"^typedef enum \{[^}]*\} ([[:word:]]+);.*"
  # } ConfigFlag;
  reTypedefEnd = re"^\} (\w+);"

  raylibHeader = """
#ifdef C2NIM
#  def RLAPI
#  header raylibHeader
#  cdecl
#  nep1
#  skipinclude
#  prefix FLAG_
#  prefix LOG_
#  prefix KEY_
#  prefix MOUSE_
#  prefix GAMEPAD_
#  prefix FONT_
#  prefix BLEND_
#  prefix GESTURE_
#  prefix CAMERA_
#  prefix MATERIAL_MAP_
#  prefix SHADER_LOC_
#  prefix SHADER_UNIFORM_
#  prefix PIXELFORMAT_
#  prefix TEXTURE_FILTER_
#  prefix TEXTURE_WRAP_
#  prefix NPATCH_
#  prefix CUBEMAP_LAYOUT_
#  mangle va_list va_list
#@
# Functions on C varargs
# Used only for TraceLogCallback type, see core_custom_logging example
type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object
proc vprintf*(format: cstring, args: va_list) {.cdecl, importc: "vprintf", header: "<stdio.h>"}

from os import parentDir, `/`
const raylibHeader = currentSourcePath().parentDir()/"raylib.h"

when defined(emscripten):
  type emCallbackFunc* = proc() {.cdecl.}
  proc emscriptenSetMainLoop*(f: emCallbackFunc, fps: cint, simulateInfiniteLoop: cint) {.
    cdecl, importc: "emscripten_set_main_loop", header: "<emscripten.h>".}
else:
  when defined(windows):
    when defined(vcc):
      # Should it be `link` instead of passL?
      {.passL:"raylibdll.lib".}
    else:
      {.passL:"libraylibdll.a".}
  else:
    {.passL:"-lraylib".}
@#
#endif
"""
  rlglHeader = """
#ifdef C2NIM
#  def RLAPI
#  header rlglHeader
#  cdecl
#  nep1
#  skipinclude
#  prefix rlgl
#  prefix rl
#  prefix RL_
#  prefix PIXELFORMAT_
#  prefix TEXTURE_FILTER_
#  prefix SHADER_LOC_
#  prefix SHADER_UNIFORM_
#@
import raylib

from os import parentDir, `/`
const rlglHeader = currentSourcePath().parentDir()/"rlgl.h"
@#
#endif
"""
  raymathHeader = """
#ifdef C2NIM
#  def RMDEF static inline
#  header raymathHeader
#  cdecl
#  nep1
#  skipinclude
#  mangle float3 Float3
#  mangle float16 Float16
#@
import raylib

from os import parentDir, `/`
const raymathHeader = currentSourcePath().parentDir()/"raymath.h"
@#
#endif
"""
  rayguiHeader = """
#ifdef C2NIM
#  def RAYGUIDEF
#  header rayguiHeader
#  cdecl
#  nep1
#  skipinclude
#  prefix Gui
#  prefix GUI_
#  prefix gui
#@
import raylib

from os import parentDir, `/`
const rayguiHeader = currentSourcePath().parentDir()/"raygui.h"
{.passC: "-DRAYGUI_IMPLEMENTATION".}
@#
#endif
"""
  physacHeader = """
#ifdef C2NIM
#  def PHYSACDEF
#  header physacHeader
#  cdecl
#  nep1
#  skipinclude
#  prefix PHYSICS_
#  prefix PHYSAC_
#@
import raylib

from os import parentDir, `/`
const physacHeader = currentSourcePath().parentDir()/"physac.h"
{.passC: "-DPHYSAC_IMPLEMENTATION".}
{.passC: "-DPHYSAC_NO_THREADS".}
@#
#endif
"""

  raylibFiles = [
    (buildDir/"raylib.h", raylibHeader),
    (buildDir/"rlgl.h", rlglHeader),
    (buildDir/"raymath.h", raymathHeader),
    (buildDir/"raygui.h", rayguiHeader),
    (buildDir/"physac.h", physacHeader),
  ]
  selfModuleDeclarationNames = [
    re"\bRAYLIB_H\b",
    re"\bRLGL_H\b",
    re"\bRAYGUI_H\b",
    re"\bRAYMATH_H\b",
    re"\bPHYSAC_H\b"
  ]
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
      physicsBodyDataMoveDefinition: bool # used only for physac.h
    rs.add c2nimheader
    var i = 0
    while i < raylibhLines.len:
      let
        line = raylibhLines[i]
        words = line.splitWhitespace
      if selfModuleDeclarationNames.any((name) => name in line):
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
        let
          structName = m.groupFirstCapture(0, line)
          typename = m.groupFirstCapture(1, line)
        if typeName == structName:
          rs.add fmt"typedef struct {structName} {{}} {structName};"
        elif structName == "PhysicsBodyData" and typeName == "*PhysicsBody":
          # Due to circular dependency, it is necessary for these 2 types to
          # be defined in the same `type` block
          physicsBodyDataMoveDefinition = true
        else:
          rs.add line & "\n"
      elif physicsBodyDataMoveDefinition and line.match(reStructDefEnd, m) and
         m.groupFirstCapture(0, line) == "PhysicsBodyData":
        # This rewrite allows c2nim to generate correct code
        rs.add "} PhysicsBodyData, *PhysicsBody;\n"
        physicsBodyDataMoveDefinition = false
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
          if enumName == "ConfigFlags": "cuint"
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
      raymathShortcuts = """
template `+`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = addValue(v1, value)
template `+=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = addValue(v1, value)

template `-`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = subtractValue(v1, value)
template `-=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = scale(v1, value)
template `*=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = scale(v1, value)

template `/`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = scale(v1, 1.0/value)
template `/=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = scale(v1, 1.0/value)

template `-`*[T: Vector2 | Vector3](v1: T): T = negate(v1)
"""

      # proc beginTextureMode*(target: RenderTexture2D) {.cdecl,
      #     importc: "BeginTextureMode", header: raylibHeader.}
      # ##  Initializes render texture for drawing
      reBeginProc = re"(?sm)^proc ((begin[^*]*)\*\(.*?\)).*"
      # beginScissorMode*(x: cint; y: cint; width: cint; height: cint)
      reArgumentType = re": [[:word:]]+;"
      reArgumentTypeEnd = re": [[:word:]]+\)"
      # proc vector2Zero*(
      reMathTypeProc = re"^proc ((vector[23]|matrix|quaternion)[^*]+)\*.*"

      # These cannot be determined automatically, only through manual inspection.
      uncheckedArrayReplacements = [
        # In Shader
        ("locs* {.importc: \"locs\".}: ptr cint",
         "locs* {.importc: \"locs\".}: ptr UncheckedArray[cint]"),
        # In Material
        ("maps* {.importc: \"maps\".}: ptr MaterialMap",
         "maps* {.importc: \"maps\".}: ptr UncheckedArray[MaterialMap]"),
        # In Model
        ("meshes* {.importc: \"meshes\".}: ptr Mesh",
         "meshes* {.importc: \"meshes\".}: ptr UncheckedArray[Mesh]"),
        ("materials* {.importc: \"materials\".}: ptr Material",
         "materials* {.importc: \"materials\".}: ptr UncheckedArray[Material]"),
        ("meshMaterial* {.importc: \"meshMaterial\".}: ptr cint",
         "meshMaterial* {.importc: \"meshMaterial\".}: ptr UncheckedArray[cint]"),
        # In ModelAnimation
        ("framePoses* {.importc: \"framePoses\".}: ptr ptr Transform",
         "framePoses* {.importc: \"framePoses\".}: ptr UncheckedArray[ptr Transform]"),
      ]
    let
      raylibnim = readFile(buildDir/fmt"{filename}_modified.nim")
      # Digression from how compiler defines it, used for Color
      raylibnimConvertedTypes = raylibnim.replace("cuchar", "uint8")
      raylibnimLines = raylibnimConvertedTypes.splitLines
    var
      rs: string
      i = 0
      m: RegexMatch
      # For procs such as beginDrawing - endDrawing to turn them into templates
      # such as beginDrawing(body: untyped) = ... and auto-ending
      beginEndPairs: seq[tuple[beginSignature, endProcName: string]]
    while i < raylibnimLines.len:
      var line = raylibnimLines[i]

      line = line.replace("max_Vertices", "MAX_VERTICES")
      line = line.multiReplace(uncheckedArrayReplacements)

      if "{.size: sizeof(cint).} = enum" in line: # add `pure` pragma to enums
        line = line.replace(
          "{.size: sizeof(cint).} = enum",
          "{.size: sizeof(cint), pure.} = enum"
        )
        rs.add line & "\n"
        i.inc
      elif "proc begin" in line:
        # Collect all the proc pairs for future templates
        # Let's hope that 20 lines is enough for begin and end procs
        let
          nextLine = min(i + 20, raylibnim.len - 1)
          nextTwentyLines = raylibnimLines[i..nextLine].join("\n")
        if nextTwentyLines.match(reBeginProc, m):
          let
            signature = m.groupFirstCapture(0, nextTwentyLines)
            beginProcName = m.groupFirstCapture(1, nextTwentyLines)
            endProcName =
              if beginProcName == "begin": "`end`" # `end` is a special word
              else: beginProcName.replace("begin", "end")
          assert endProcName in nextTwentyLines,
                 "no end proc for " & beginProcName
          beginEndPairs.add (signature, endProcName)
        else:
          assert false, "regex for begin proc didn't work:\n" & nextTwentyLines
        rs.add line & "\n"
        i.inc
      elif filename == "raymath" and line.match(reMathTypeProc, m):
        let
          procName = m.groupFirstCapture(0, line)
          mathType = m.groupFirstCapture(1, line)
        if procName in ["vector2Zero", "vector3Zero", "vector2One", "vector3One",
                        "matrixIdentity", "quaternionIdentity"]:
          # Some procs take no arguments and hence can't be overloaded.
          rs.add line & "\n"
        else:
          var newProcName = procName[mathType.len..^1]
          newProcName[0] = newProcName[0].toLowerAscii
          rs.add line.replace(procName, newProcName) & "\n"
        i.inc
      elif filename == "raylib" and line == "  MENU = R":
        # This is a duplicated enum value. Nim forbids duplicated values for
        # enums and `c2nim` converts it to const but doesn't import it.
        rs.add "  MENU* = R" & "\n"
        i.inc
      else:
        rs.add line & "\n"
        i.inc
    if filename == "raylib":
      rs.add "\n"
      rs.add tupleConverters
      rs.add "\n"
      rs.add cTypeConverters
    if filename == "raymath":
      rs.add "\n"
      rs.add raymathShortcuts
    # Add begin-end templates
    for (beginSignature, endProcName) in beginEndPairs:
      let
        signatureWithBody =
          if "()" in beginSignature:
            beginSignature.replace( "()", "(body: untyped)")
          else:
            beginSignature.replace( ")", "; body: untyped)")
        beginWithoutAsterisk = beginSignature.replace("*(", "(")
        beginInvocation =
          if "()" in beginWithoutAsterisk:
            beginWithoutAsterisk
          else:
            beginWithoutAsterisk
              .replace(reArgumentType, ",")
              .replace(reArgumentTypeEnd, ")")
      rs.add fmt"""
template {signatureWithBody} =
  {beginInvocation}
  block:
    body
  {endProcName}()
"""
      rs.add "\n"
    writeFile(targetDir/fmt"{filename}.nim", rs)
