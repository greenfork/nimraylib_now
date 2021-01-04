import httpclient, asyncdispatch
import strutils, strformat
from os import `/`, fileExists, extractFilename
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

func convertType(t: string, varname: string): string =
  result =
    case t
    of "const void", "void": ""
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
      if varname[0] == '*' and t == "char": "cstringArray"
      elif varname[0] == '*': "ptr " & t.replace("const ", "ptr ")
      else: t.replace("const ", "ptr ")
  result = ": " & result

block attempt1:
  type
    RaylibParser = object
      lineNumber: int
      multilineComment: bool
      filepath: string

  iterator lines(p: var RaylibParser): string =
    for line in lines(p.filepath):
      p.lineNumber.inc
      yield line

  const
    ignoreDefines = [
      "RLAPI",
      "RL_MALLOC(sz)",
      "RL_CALLOC(n,sz)",
      "RL_REALLOC(ptr,sz)",
      "RL_FREE(ptr)",
      "CLITERAL(type)",
      "FormatText",
      "LoadText",
      "GetExtension",
      "GetImageData",
    ]
    raylibHeader = """
  const LEXT* = when defined(windows):".dll"
  elif defined(macosx):               ".dylib"
  else:                               ".so"
  {.pragma: RLAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}
    """

  proc parseFile(filepath: string, writeToFile = false) =
    let targetFile = filepath.replace(".h", ".nim")
    var
      parser = RaylibParser(filepath: filepath)
      output: File
      multilineStatement: bool
    if writeToFile: output = open(targetFile, fmWrite)
    for line in lines(parser):
      if parser.lineNumber < 172: continue
      if parser.lineNumber > 219: break
      var
        line = line
        rs: string # resulting line
        copyVerbatim: bool # just prepend '#' and copy the line
      line = line[skipWhitespace(line)..^1]
      let
        words = line.splitWhitespace
        trailingComment = block:
          var parsed = line.split("//")
          if parsed.len > 1:
            parsed[1..^1].join
          else:
            ""
      # echo words

      if line == "":
        rs.add "\n"
      elif parser.multilineComment:
        rs.add '#'
        rs.add line
      elif line.startsWith("/*"):
        parser.multilineComment = true
        rs.add '#'
        rs.add line
      elif words[0] == "#define" and words[1] notin ignoreDefines:
        if words[1] == "RAYLIB_H":
          rs.add raylibHeader
        elif words.len > 2 and words[2] == "CLITERAL(Color){":
          rs.add fmt"template {words[1]}*(): auto = "
          rs.add fmt"Color(r: {words[3]} g: {words[4]} b: {words[5]} a: {words[6]})"
        else:
          rs.add fmt"template {words[1]}*(): auto = {words[2]}"
      elif words[0] == "typedef":
        case words[1]
        of "struct":
          assert words[3] == "{"
          rs.add fmt"type {words[2]}* {{.bycopy.}} = object"
          multilineStatement = true
        else:
          discard
      elif words[0] == "}":
        multilineStatement = false
      else:
        copyVerbatim = true
        rs.add '#'
        rs.add line

      if parser.multilineComment and line.endsWith("*/"):
        parser.multilineComment = false
      if not copyVerbatim and trailingComment.len > 0:
        if rs.len > 0:
          rs.add ' '
        rs.add '#'
        rs.add trailingComment

      if rs.len > 0:
        if writeToFile:
          output.write(rs)
          output.write "\n"
        else:
          echo rs

  # parseFile("raylib"/"raylib.h")


block attempt2:
  const
    multilineCommentStart = re"^/\*"
    multilineCommentEnd = re"\*/$"
