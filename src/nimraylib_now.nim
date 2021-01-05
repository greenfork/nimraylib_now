import httpclient, asyncdispatch
import strutils, strformat, sequtils
from os import `/`, fileExists, extractFilename
from osproc import execCmd
from parseutils import skipWhitespace
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

const arrayFieldName = re"([[:word:]]+)\[(\d+)\]"

func convertType(t: string, varname: string): string =
  var m: RegexMatch
  result =
    case t
    of "const void", "void":
      if varname[0] == '*': "pointer"
      else: ""
    of "long", "int": "int32"
    of "float": "float32"
    of "double": "float64"
    of "const char": "cstring"
    of "unsigned int": "uint32"
    of "unsigned char": "uint8"
    of "unsigned short": "uint16"
    of "TraceLogCallback": "int"
    of "const unsigned char": "UncheckedArray[byte]"
    else:
      if varname[0] == '*' and t == "char":
        "cstringArray"
      elif varname[0] == '*':
        "ptr " & t.replace("const ", "ptr ")
      elif varname.match(arrayFieldName, m):
        fmt"array[{m.groupFirstCapture(1, varname)}, {t}]"
      else:
        t.replace("const ", "ptr ")
  result = ": " & result

# Formatting of identifiers
func fmtConst(s: string): string =
  s.toLowerAscii.capitalizeAscii

func peekFirst(ss: seq[string]): string =
  if ss.len > 0: ss[0]
  else: ""

func maybeChangeName(s: string): string =
  result = s
  if result in ["ptr", "type"]: result.add 'x'
func maybeArrayField(s: string): string =
  var m: RegexMatch
  if s.match(arrayFieldName, m):
    result = m.groupFirstCapture(0, s)
  else:
    result = s

const
  ignoreDefines = [
    "RLAPI",
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
  ]
  raylibHeader = """
const LEXT* = when defined(windows):".dll"
elif defined(macosx):               ".dylib"
else:                               ".so"
{.pragma: RLAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}
"""

block attempt3:
  const
    # #define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray
    reDefineColor = re"^#define ([[:word:]]+)\s*CLITERAL\(Color\)\{ (\d+), (\d+), (\d+), (\d+) \}.*"
    # typedef struct rAudioBuffer rAudioBuffer;
    reEmptyStructDef = re"^typedef struct ([[:word:]]+) ([[:word:]]+);"
    # typedef enum {
    typedefEnumStart = re"^typedef enum \{.*"
    # } ConfigFlag;
    typedefEnd = re"^\} (\w+);"
  const raylibHeader = """
#ifdef C2NIM
#  def RLAPI
#  dynlib raylibdll
#  cdecl
#  if defined(windows)
#    define raylibdll "libraylib.dll"
#  elif defined(macosx)
#    define raylibdll "libraylib.dylib"
#  else
#    define raylibdll "libraylib.so"
#  endif
#@
# converter uint8ToCuchar*(self: uint8): cuchar = self.cuchar
# converter CintToCuchar*(self: cint): cuchar = self.cuchar
type va_list* = varargs[cstring, `$`]
@#
#endif
"""
  const ignoreDirectives = ["#define", "#include"]


  # Preprocessing

  block preprocessing:
    let
      raylibh = readFile("raylib"/"raylib.h")
      raylibhLines = raylibh.splitLines
    var
      rs: string
      appendToVeryEnd: string # e.g. for #define->const conversion
      m: RegexMatch
    rs.add raylibHeader
    var i = 0
    while i < raylibhLines.len:
      # if i > 91: break
      let
        line = raylibhLines[i]
        words = line.splitWhitespace
      if "RAYLIB_H" in words: discard # skip all self-header module definitions
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
      elif line.match(typedefEnumStart):
        # C uses enums in place of int32 numbers, so every enum takes an
        # appropriate converter to translate types in Nim implicitly
        var
          enumEnd = i + 1
          enumEndLine = raylibhLines[enumEnd]
        while not enumEndLine.match(typedefEnd, m):
          enumEnd.inc
          enumEndLine = raylibhLines[enumEnd]
        let enumName = m.groupFirstCapture(0, enumEndLine)
        appendToVeryEnd.add(
          fmt("converter {enumName}ToInt32*(self: {enumName}): int32 = self.int32\n")
        )
        # Remember to still add this line
        rs.add line & "\n"
      elif words.len > 0 and (words[0] == "#if" or words[0] == "#ifndef"):
        echo "Ignore branch: " & line
        var nestLevels = 1
        while nestLevels > 0:
          i.inc
          let firstWord = raylibhLines[i].splitWhitespace.peekFirst
          if firstWord == "#endif":
            nestLevels.dec
          elif firstWord == "#if" or firstWord == "#ifndef":
            nestLevels.inc
      elif words.len > 0 and words[0] in ignoreDirectives:
        echo "Ignore: " & line
      else:
        rs.add line & "\n"
      i.inc

    rs.add fmt"""
#ifdef C2NIM
#@
{appendToVeryEnd}
@#
#endif
"""
    writeFile("raylib"/"raylib_modified.h", rs)


  # Processing with c2nim

  echo "\nExecuting c2nim\n"
  assert execCmd("c2nim raylib/raylib_modified.h") == 0


  # Postprocessing

  block postprocessing:
    let
      raylibnim = readFile("raylib"/"raylib_modified.nim")
      raylibnimLines = raylibnim.splitLines
    var
      rs: string
      appendToVeryEnd: string # e.g. for #define->const conversion
      m: RegexMatch
    var i = 0
    while i < raylibnimLines.len:
      var line = raylibnimLines[i].multiReplace(
        ("cint", "int32"),
        ("cfloat", "float32"),
        ("cuchar", "uint8"),
        ("cuint", "uint32"),
      )
      rs.add line & "\n"
      i.inc

    writeFile("raylib"/"raylib.nim", rs)

# block attempt2:
#   const
#     multilineCommentStart = re"^/\*"
#     multilineCommentEnd = re"\*/$"
#     onelineComment = re"^\s*(//).+"
#     defineExpr = re"^\s*#define(?:\s+(\S+))+"
#     typedefStructStart = re"^typedef struct ([[:word:]]+) \{.*"
#     typedefEmptyStruct = re"^typedef struct ([[:word:]]+) ([[:word:]]+);"
#     typedefAlias = re"^typedef ([[:word:]]+) ([[:word:]]+);.*"
#     typedefEnumStart = re"^typedef enum \{.*"
#     typedefEnd = re"^\} (\w+);"
#     typedefFieldList = re"^\s*((?:[[:word:]]+)\s)+(?:([[:word:]*\[\]]+)(?:, )?)+;.*"
#     typedefEnumEntry = re"^\s*([[:word:]]+)\s*(?:=\s((?:0x)?[[:xdigit:]]+),?)?.*"

#   type
#     RaylibParser = object
#       filepath: string
#       line: int
#       buf: seq[string]

#   proc parseFile(filepath: string, writeToFile = false) =
#     let targetFile = filepath.replace(".h", ".nim")
#     var
#       parser = RaylibParser(
#         filepath: filepath,
#         buf: readFile(filepath).split("\n")
#       )
#       output: File
#       m: RegexMatch # for future parsing
#       trailingComment: string # auto-inserted in `o` proc
#       appendToVeryEnd: string # e.g. for #define->const conversion there
#                               # should be types above in the code
#     if writeToFile: output = open(targetFile, fmWrite)

#     # Output to file or stdout
#     proc o(s: string) =
#       var rs: string
#       rs.add s
#       if trailingComment.len > 0:
#         if s.len > 0: rs.add ' '
#         rs.add "#" & trailingComment
#       if writeToFile:
#         rs.add "\n"
#         output.write rs
#       else:
#         echo rs

#     func parseTrailingComment(line: string): string =
#       var parsed = line.split("//")
#       if parsed.len > 1:
#         parsed[1..^1].join
#       else:
#         ""

#     while parser.line < parser.buf.len:
#       if parser.line < 0:
#         parser.line.inc
#         continue
#       if parser.line > 874:
#         break

#       let line = parser.buf[parser.line]
#       trailingComment = parseTrailingComment(line)

#       if multilineCommentStart in line:
#         while parser.line < parser.buf.len:
#           let commentLine = parser.buf[parser.line]
#           if multilineCommentEnd in commentLine:
#             o '#' & commentLine
#             break
#           else:
#             parser.line.inc
#             o '#' & commentLine
#       elif onelineComment in line:
#         trailingComment = ""
#         o line.replace("//", "#")
#       elif line.match(defineExpr, m) and
#            m.groupFirstCapture(0, line) notin ignoreDefines:
#         let matches = m.group(0, line)
#         if matches[0] == "RAYLIB_H":
#           o raylibHeader
#         elif matches.len > 1 and matches[1] == "CLITERAL(Color){":
#           appendToVeryEnd.add fmt"const {matches[0].fmtConst}* = " &
#             fmt("Color(r: {matches[2]} g: {matches[3]} b: {matches[4]} a: {matches[5]})\n")
#         else:
#           o fmt"template {matches[0]}*(): auto = {matches[1]}"
#       elif line.match(typedefAlias, m):
#         o fmt"type {m.groupFirstCapture(1, line)}* = {m.groupFirstCapture(0, line)}"
#       elif line.match(typedefStructStart, m) or line.match(typedefEmptyStruct, m):
#         let typename = m.groupFirstCapture(0, line)
#         o fmt"type {typename}* {{.bycopy.}} = object"
#         # If this is not empty struct definition
#         if typedefEmptyStruct notin line:
#           # Find where type definition ends
#           var typedefEndLine = parser.line
#           while not parser.buf[typedefEndLine].match(typedefEnd, m):
#             typedefEndLine.inc
#           assert typename == m.groupFirstCapture(0, parser.buf[typedefEndLine]),
#                  "wrong typedef ending"
#           # Convert fields
#           for i in (parser.line+1)..<typedefEndLine:
#             trailingComment = ""
#             let typedefFieldsLine = parser.buf[i]
#             if typedefFieldsLine.match(typedefFieldList, m):
#               trailingComment = parseTrailingComment(typedefFieldsLine)
#               let
#                 fieldType = m.group(0, typedefFieldsLine).join.strip
#                 firstFieldName = m.groupFirstCapture(1, typedefFieldsLine).strip
#               var fields = "  "
#               fields.add m.group(1, typedefFieldsLine)
#                           .mapIt(it.strip(chars = {'*'})
#                                    .maybeArrayField
#                                    .maybeChangeName & '*')
#                           .join(", ")
#               fields.add convertType(fieldType, firstFieldName)
#               o fields
#             elif onelineComment in typedefFieldsLine:
#               o typedefFieldsLine.replace("//", "#")
#             elif typedefFieldsLine.len > 0:
#               o '#' & typedefFieldsLine
#             else:
#               o ""
#           parser.line = typedefEndLine
#       elif line.match(typedefEnumStart, m):
#         # Find where type definition ends
#         var typedefEndLine = parser.line
#         while not parser.buf[typedefEndLine].match(typedefEnd, m):
#           typedefEndLine.inc
#         let typename = m.groupFirstCapture(0, parser.buf[typedefEndLine])
#         o fmt"type {typename}* = enum"
#         # Convert fields
#         for i in (parser.line+1)..<typedefEndLine:
#           trailingComment = ""
#           let typedefEnumLine = parser.buf[i]
#           if typedefEnumLine.match(typedefEnumEntry, m):
#             trailingComment = parseTrailingComment(typedefEnumLine)
#             var entry = "  "
#             var ident = m.groupFirstCapture(0, typedefEnumLine)
#             ident[0] = ident[0].toLowerAscii
#             ident = ident.nimIdentNormalize
#             entry.add ident
#             let value = m.groupFirstCapture(1, typedefEnumLine)
#             if value.len > 0:
#               entry.add fmt" = {value}"
#             o entry
#           elif onelineComment in typedefEnumLine:
#             o typedefEnumLine.replace("//", "#")
#           elif typedefEnumLine.len > 0:
#             o '#' & typedefEnumLine
#           else:
#             o ""
#         parser.line = typedefEndLine
#         trailingComment = ""
#         o fmt"converter {typename}Toint32* (self: {typename}): int32 = self.int32"
#       elif line.len > 0:
#         trailingComment = ""
#         o "#" & line
#       else:
#         o ""

#       parser.line.inc
#     o appendToVeryEnd

#   parseFile("raylib"/"raylib.h", true)


# block attempt1:
#   type
#     RaylibParser = object
#       lineNumber: int
#       multilineComment: bool
#       filepath: string

#   iterator lines(p: var RaylibParser): string =
#     for line in lines(p.filepath):
#       p.lineNumber.inc
#       yield line

#   proc parseFile(filepath: string, writeToFile = false) =
#     let targetFile = filepath.replace(".h", ".nim")
#     var
#       parser = RaylibParser(filepath: filepath)
#       output: File
#       multilineStatement: bool
#     if writeToFile: output = open(targetFile, fmWrite)
#     for line in lines(parser):
#       if parser.lineNumber < 172: continue
#       if parser.lineNumber > 219: break
#       var
#         line = line
#         rs: string # resulting line
#         copyVerbatim: bool # just prepend '#' and copy the line
#       line = line[skipWhitespace(line)..^1]
#       let
#         words = line.splitWhitespace
#         trailingComment = block:
#           var parsed = line.split("//")
#           if parsed.len > 1:
#             parsed[1..^1].join
#           else:
#             ""
#       # echo words

#       if line == "":
#         rs.add "\n"
#       elif parser.multilineComment:
#         rs.add '#'
#         rs.add line
#       elif line.startsWith("/*"):
#         parser.multilineComment = true
#         rs.add '#'
#         rs.add line
#       elif words[0] == "#define" and words[1] notin ignoreDefines:
#         if words[1] == "RAYLIB_H":
#           rs.add raylibHeader
#         elif words.len > 2 and words[2] == "CLITERAL(Color){":
#           rs.add fmt"template {words[1]}*(): auto = "
#           rs.add fmt"Color(r: {words[3]} g: {words[4]} b: {words[5]} a: {words[6]})"
#         else:
#           rs.add fmt"template {words[1]}*(): auto = {words[2]}"
#       elif words[0] == "typedef":
#         case words[1]
#         of "struct":
#           assert words[3] == "{"
#           rs.add fmt"type {words[2]}* {{.bycopy.}} = object"
#           multilineStatement = true
#         else:
#           discard
#       elif words[0] == "}":
#         multilineStatement = false
#       else:
#         copyVerbatim = true
#         rs.add '#'
#         rs.add line

#       if parser.multilineComment and line.endsWith("*/"):
#         parser.multilineComment = false
#       if not copyVerbatim and trailingComment.len > 0:
#         if rs.len > 0:
#           rs.add ' '
#         rs.add '#'
#         rs.add trailingComment

#       if rs.len > 0:
#         if writeToFile:
#           output.write(rs)
#           output.write "\n"
#         else:
#           echo rs

#   # parseFile("raylib"/"raylib.h")


