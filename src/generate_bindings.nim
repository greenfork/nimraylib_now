from os import `/`, removeDir, createDir, copyFileToDir, moveFile, parentDir,
  copyDir
import strformat
import strutils
import regex
from sequtils import anyIt
from os import `/`, extractFilename, changeFileExt, findExe
from osproc import execCmd

const
  projectDir                  = currentSourcePath().parentDir().parentDir()
  buildDir                    = projectDir/"build"
  nimraylibNowDir             = projectDir/"src"/"nimraylib_now"
  templatesDir                = projectDir/"src"/"templates"
  raylibSrcDir                = projectDir/"raylib"/"src"
  raylibBuildDir              = buildDir/"raylib_src"
  rayguiBuildDir              = buildDir/"raygui_src"

  # Must assume that there's no `projectDir` as if it is installed as a nimble
  # package.
  srcDir                      = currentSourcePath().parentDir()
  cSourcesDir                 = srcDir/"csources"
  raylibMangledCSourcesDir    = cSourcesDir/"raylib_mangled"

  manglePrefix                = "NmrlbNow_"
  raylibBuildFile             = raylibBuildDir/"raylib.h"
  rlglBuildFile               = raylibBuildDir/"rlgl.h"
  raymathBuildFile            = raylibBuildDir/"raymath.h"
  physacBuildFile             = raylibBuildDir/"physac.h"
  rayguiBuildFile             = raylibBuildDir/"raygui.h"
  raylibHeaderBuildFiles = [
    raylibBuildFile,
    rlglBuildFile,
    raymathBuildFile,
    physacBuildFile,
    rayguiBuildFile,
  ]

proc genDirStructure =
  removeDir(nimraylibNowDir)
  createDir(nimraylibNowDir)
  createDir(nimraylibNowDir/"mangled")
  createDir(nimraylibNowDir/"not_mangled")
  removeDir(cSourcesDir)
  createDir(cSourcesDir)
  createDir(raylibMangledCSourcesDir)
  removeDir(buildDir)
  createDir(buildDir)
  writeFile(buildDir/".gitkeep", "")
  createDir(raylibBuildDir)

proc genSkeleton =
  copyFileToDir(templatesDir/"static_build.nim", nimraylibNowDir)
  const
    alternatingNimFiles = [
      "physac",
      "raygui",
      "raylib",
      "raymath",
      "rlgl",
      "converters",
    ]

  for filename in alternatingNimFiles:
    let content = fmt"""
when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/{filename}
else:
  import mangled/{filename}

export {filename}
"""
    writeFile(nimraylibNowDir/filename & ".nim", content)

proc prepareCSources =
  copyDir(raylibSrcDir, raylibMangledCSourcesDir)
  copyFileToDir(raylibSrcDir/"extras"/"physac.h", raylibMangledCSourcesDir)
  copyFileToDir(raylibSrcDir/"extras"/"raygui.h", raylibMangledCSourcesDir)

  # Some strange names that also collide with `windows.h`
  const queryPerfFiles = [
    raylibMangledCSourcesDir/"rgestures.h",
    raylibMangledCSourcesDir/"physac.h",
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

  # Name mangling
  # On Windows some Raylib names conflict with names defined in `windows.h`
  # so we mangle them in C source and header files and later return them to
  # normal names in Nim.
  # https://github.com/greenfork/nimraylib_now/issues/5
  const
    mangleNameRegexes = [
      re"\b(Rectangle)\b",
      re"\b(CloseWindow)\b",
      re"\b(ShowCursor)\b",
      re"\b(LoadImage)\b",
      re"\b(DrawText)\b",
      re"\b(DrawTextEx)\b",
      re"\b(GetCurrentTime)\b",
    ]
    raylibSources = [
      raylibMangledCSourcesDir/"rshapes.c",
      raylibMangledCSourcesDir/"rtextures.c",
      raylibMangledCSourcesDir/"rtext.c",
      raylibMangledCSourcesDir/"utils.c",
      raylibMangledCSourcesDir/"rmodels.c",
      raylibMangledCSourcesDir/"raudio.c",
      raylibMangledCSourcesDir/"rcore.c",
    ]
    raylibHeaders = [
      raylibMangledCSourcesDir/"raylib.h",
      raylibMangledCSourcesDir/"rlgl.h",
      raylibMangledCSourcesDir/"raymath.h",
      raylibMangledCSourcesDir/"physac.h",
      raylibMangledCSourcesDir/"raygui.h"
    ]
    headerPreamble = [
      "#undef near", # undefine clashing macros (from windows.h)
      "#undef far", # undefine clashing macros (from windows.h)
    ].join("\n") & "\n"

  func mangle(line: string): string =
    result = line
    for reName in mangleNameRegexes:
      result = result.replace(reName, manglePrefix & "$1")

  for file in raylibHeaders:
    var fileContent: string = headerPreamble
    fileContent.add readFile(file)
    writeFile(file, mangle(fileContent))
  for file in raylibSources:
    let fileContent = readFile(file)
    writeFile(file, mangle(fileContent))

  # Copy mangled C sources from build/ to src/csources
  copyDir(raylibBuildDir, raylibMangledCSourcesDir)

proc prepareBuildFiles(targetDir: string, mangled: bool) =
  # Prepare build files
  if mangled:
    copyDir(raylibMangledCSourcesDir, raylibBuildDir)
  else:
    copyDir(raylibSrcDir, raylibBuildDir)
    copyFileToDir(raylibSrcDir/"extras"/"physac.h", raylibBuildDir)
    copyFileToDir(raylibSrcDir/"extras"/"raygui.h", raylibBuildDir)
  # Copy files to target directory to be used during linking with Nim files
  for file in raylibHeaderBuildFiles:
    copyFileToDir(file, targetDir)

proc convertToNim(targetDir: string, mangled: bool) =
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
      "LOC_MAP_DIFFUSE", # deprecated
      "LOC_MAP_SPECULAR", # deprecated
      "RL_SHADER_LOC_MAP_DIFFUSE", # deprecated
      "RL_SHADER_LOC_MAP_SPECULAR", # deprecated
      "MAP_DIFFUSE", # deprecated?
      "MAP_SPECULAR", # deprecated?
      "PHYSAC_PI", # already in math module
      "PHYSAC_DEG2RAD", # already in math module
      "MATERIAL_MAP_DIFFUSE", # deprecated enum value
      "MATERIAL_MAP_SPECULAR", # deprecated enum value
      "SHADER_LOC_MAP_DIFFUSE", # deprecated enum value
      "SHADER_LOC_MAP_SPECULAR", # deprecated enum value
      "TRACELOG(level,", # we don't need that
      "MOUSE_LEFT_BUTTON", # deprecated
      "MOUSE_RIGHT_BUTTON", # deprecated
      "MOUSE_MIDDLE_BUTTON", # deprecated
    ]
    allowIfs = [
      "RAYGUI_SUPPORT_ICONS"
    ]
    ignoreLines = [
      "#if defined(RAYGUI_SUPPORT_ICONS)"
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

    c2nimHeaderPreamble = fmt"""
#ifdef C2NIM
#  prefix {manglePrefix}
#  cdecl
#  nep1
#  skipinclude
"""

    raylibHeader = c2nimHeaderPreamble & """
#  def RLAPI
#  header raylibHeader
#  prefix FLAG_
#  prefix LOG_
#  prefix KEY_
#  prefix MOUSE_CURSOR_
#  prefix MOUSE_BUTTON_
#  prefix GAMEPAD_BUTTON_
#  prefix GAMEPAD_AXIS_
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

when not defined(nimraylib_now_linkingOverride):
  when defined(nimraylib_now_shared) and not defined(emscripten):
    when defined(windows):
      when defined(vcc):
        {.passL: "raylibdll.lib".}
      else:
        {.passL: "libraylibdll.a".}
    elif defined(macosx):
      {.passL: "-lraylib".}
    else:
      {.passL: "-lraylib".}
  else:
    include ../static_build

@#
#endif
"""
    rlglHeader = c2nimHeaderPreamble & """
#  def RLAPI
#  header rlglHeader
#  prefix rlgl
#  prefix rl
#  prefix RL_PIXELFORMAT_
#  prefix RL_TEXTURE_FILTER_
#  prefix RL_SHADER_LOC_
#  prefix RL_SHADER_UNIFORM_
#  prefix RL_BLEND_
#  prefix RL_LOG_
#  prefix RL_SHADER_ATTRIB_
#  prefix RL_
#@
import raylib

from os import parentDir, `/`
const rlglHeader = currentSourcePath().parentDir()/"rlgl.h"
@#
#endif
"""
    raymathHeader = c2nimHeaderPreamble & """
#  def RMAPI static inline
#  header raymathHeader
#  mangle float3 Float3
#  mangle float16 Float16
#@
import raylib

from os import parentDir, `/`
const raymathHeader = currentSourcePath().parentDir()/"raymath.h"
@#
#endif
"""
    rayguiHeader = c2nimHeaderPreamble & """
#  def RAYGUIAPI
#  header rayguiHeader
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
    physacHeader = c2nimHeaderPreamble & """
#  def PHYSACDEF
#  header physacHeader
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

    raylibHeaders = [
      (raylibBuildFile, raylibHeader),
      (rlglBuildFile, rlglHeader),
      (raymathBuildFile, raymathHeader),
      (physacBuildFile, physacHeader),
      (rayguiBuildFile, rayguiHeader),
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

  # Converters will be kept in a separate file
  var nimEnumConverters: string

  # Start processing all files
  for (filepath, c2nimheader) in raylibHeaders:
    let filename = filepath.extractFilename.changeFileExt("")

    # Preprocessing of C header file before feeding it to c2nim

    block preprocessing:
      let
        raylibh = readFile(filepath)
        raylibhLines = raylibh.splitLines
      var
        rs: string
        nimColorNames: string
        m: RegexMatch
        physicsBodyDataMoveDefinition: bool # used only for physac.h
      rs.add c2nimheader
      var i = 0
      while i < raylibhLines.len:
        let
          line = raylibhLines[i]
          words = line.splitWhitespace
        if selfModuleDeclarationNames.anyIt(it in line):
          # Remove module declaration start and end, we don't need it
          if "#endif" in line: # this is the end of h file and start of implementation
            echo "Reached end of header part: " & line
            break
          echo "Ignore: " & line # skip all self-header module definitions
        elif ignoreLines.anyIt(it in line) and filename == "raygui":
          echo "Ignore: " & line
        elif line.match(reDefineColor, m) and filename == "raylib":
          # Colors are defined with #define, we want to turn them into consts
          # and remove from original C file
          let
            colorName = m.groupFirstCapture(0, line)
            red = m.groupFirstCapture(1, line)
            green = m.groupFirstCapture(2, line)
            blue = m.groupFirstCapture(3, line)
            alpha = m.groupFirstCapture(4, line)
          nimColorNames.add fmt"const {colorName.fmtConst}* = " &
            fmt("Color(r: {red}, g: {green}, b: {blue}, a: {alpha})\n")
        elif line.match(reEmptyStructDef, m) and filename in ["physac", "raylib"]:
          # c2nim can't parse it without {} in the middle
          # this seems as a forward declaration of a struct but no further
          # declaration actually happens
          let
            structName = m.groupFirstCapture(0, line)
            typeName = m.groupFirstCapture(1, line)
          if typeName == structName:
            rs.add fmt"typedef struct {structName} {{}} {structName};"
          elif structName == "PhysicsBodyData" and typeName == "*PhysicsBody":
            # Due to circular dependency, it is necessary for these 2 types to
            # be defined in the same `type` block
            physicsBodyDataMoveDefinition = true
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
          nimEnumConverters.add(
            fmt("converter {enumName}ToInt*(self: {filename}.{enumName}): {convertType} = self.{convertType}\n")
          )
          # Remember to still add this line
          rs.add line & "\n"
        elif words.len > 0 and (words[0] == "#if" or words[0] == "#ifndef") and
             allowIfs.anyIt(it notin line):
          echo "Ignore branch: " & line
          var nestLevels = 1
          while nestLevels > 0:
            i.inc
            let firstWord = raylibhLines[i].splitWhitespace.peekFirst
            if firstWord == "#endif":
              nestLevels.dec
            elif firstWord == "#if" or firstWord == "#ifndef":
              nestLevels.inc
        elif line.startsWith("RMAPI") and filename == "raymath":
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

      if nimColorNames.len > 0 and filename == "raylib":
        rs.add fmt"""
#ifdef C2NIM
#@
{nimColorNames}
@#
#endif
"""
      writeFile(buildDir/fmt"{filename}_modified.h", rs)


    # Processing with c2nim

    echo "\nExecuting c2nim"
    let c2nimcmd = findExe("c2nim") & " " & buildDir/fmt"{filename}_modified.h"
    echo c2nimcmd & "\n"
    assert execCmd(c2nimcmd) == 0


    # Postprocessing of generated nim file by c2nim

    block postprocessing:
      const
        raymathShortcuts = slurp(templatesDir/"raymath_shortcuts.nim")
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
          # In Font
          ("recs* {.importc: \"recs\".}: ptr Rectangle",
           "recs* {.importc: \"recs\".}: ptr UncheckedArray[Rectangle]"),
          ("glyphs* {.importc: \"glyphs\".}: ptr GlyphInfo",
           "glyphs* {.importc: \"glyphs\".}: ptr UncheckedArray[GlyphInfo]"),
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
          # In Mesh
          ("vertices* {.importc: \"vertices\".}: ptr cfloat",
           "vertices* {.importc: \"vertices\".}: ptr UncheckedArray[cfloat]"),
          ("texcoords* {.importc: \"texcoords\".}: ptr cfloat",
           "texcoords* {.importc: \"texcoords\".}: ptr UncheckedArray[cfloat]"),
          ("texcoords2* {.importc: \"texcoords2\".}: ptr cfloat",
           "texcoords2* {.importc: \"texcoords2\".}: ptr UncheckedArray[cfloat]"),
          ("normals* {.importc: \"normals\".}: ptr cfloat",
           "normals* {.importc: \"normals\".}: ptr UncheckedArray[cfloat]"),
          ("tangents* {.importc: \"tangents\".}: ptr cfloat",
           "tangents* {.importc: \"tangents\".}: ptr UncheckedArray[cfloat]"),
          ("colors* {.importc: \"colors\".}: ptr uint8",
           "colors* {.importc: \"colors\".}: ptr UncheckedArray[uint8]"),
          ("indices* {.importc: \"indices\".}: ptr cushort",
           "indices* {.importc: \"indices\".}: ptr UncheckedArray[cushort]"),
          ("animVertices* {.importc: \"animVertices\".}: ptr cfloat",
           "animVertices* {.importc: \"animVertices\".}: ptr UncheckedArray[cfloat]"),
          ("animNormals* {.importc: \"animNormals\".}: ptr cfloat",
           "animNormals* {.importc: \"animNormals\".}: ptr UncheckedArray[cfloat]"),
          ("boneIds* {.importc: \"boneIds\".}: ptr cint",
           "boneIds* {.importc: \"boneIds\".}: ptr UncheckedArray[cint]"),
          ("boneWeights* {.importc: \"boneWeights\".}: ptr cfloat",
           "boneWeights* {.importc: \"boneWeights\".}: ptr UncheckedArray[cfloat]"),
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
        elif "proc begin" in line and filename in ["raylib", "rlgl"]:
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
          rs.add "  MENU* = KeyboardKey.R" & "\n"
          i.inc
        else:
          rs.add line & "\n"
          i.inc
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


  # Write converters

  const baseConverters = slurp(templatesDir/"base_converters.nim")
  writeFile(targetDir/"converters.nim", baseConverters & nimEnumConverters)

proc main =
  genDirStructure()
  genSkeleton()
  prepareCSources()
  prepareBuildFiles(targetDir = nimraylibNowDir/"not_mangled", mangled = false)
  convertToNim(targetDir = nimraylibNowDir/"not_mangled", mangled = false)
  prepareBuildFiles(targetDir = nimraylibNowDir/"mangled", mangled = true)
  convertToNim(targetDir = nimraylibNowDir/"mangled", mangled = true)

when isMainModule:
  main()
