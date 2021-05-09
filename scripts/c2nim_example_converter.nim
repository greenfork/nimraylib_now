## Usage: ./c2nim_example_converter core_2d_camera.c

import os, osproc
import strutils
import strscans
from sequtils import any
from sugar import `=>`

if paramCount() == 0:
  echo "Provide C file to convert"
  quit(1)

let
  filename = paramStr(1)
  (_, name, ext) = splitFile(filename)
assert ext == ".c", "supplied file must have .c extension"

echo "\n\nRunning ", paramStr(0), " for ", filename

# Preprocessing of C file

let newFilename = name & "_new" & ext
var newFileContent = ""
for line in filename.lines:
  var line = line
  if "(Vector2){" in line or "(Vector3){" in line or "(Vector4){" in line or
     "(Quaternion){" in line or "(Rectangle){" in line or "(Matrix){" in line:
    var
      head, tail, body: string
      n: int
    if scanf(line, "$+(Vector$i){$+}$+$.", head, n, body, tail):
      newFileContent.add head & "Vector" & $n & "(" & body.strip & ")" & tail & "\n"
    elif scanf(line, "$+(Quaternion){$+}$+$.", head, body, tail):
      newFileContent.add head & "Quaternion" & "(" & body.strip & ")" & tail & "\n"
    elif scanf(line, "$+(Rectangle){$+}$+$.", head, body, tail):
      newFileContent.add head & "Rectangle" & "(" & body.strip & ")" & tail & "\n"
    elif scanf(line, "$+(Matrix){$+}$+$.", head, body, tail):
      newFileContent.add head & "Matrix" & "(" & body.strip & ")" & tail & "\n"
  else:
    newFileContent.add line & "\n"
writeFile(newFilename, newFileContent)

let nimFilename = name & ".nim"

proc runc2nim(): TaintedString =
  result = execProcess(
    "c2nim",
    args = ["--ref", "--nep1", "-o:" & nimFilename, newFilename],
    options = {poStdErrToStdOut, poUsePath},
  )
  echo result.strip

const
  errorStrings = [
    # This error usually happens with declarations like
    # Vector2 x = (Vector2){ 100, 100 };
    "Error: expected ';'",
    # Almost same case with this error
    # cubePos = GetWorldToScreen((Vector3){x, y + 2.5f, z}, camera);
    "Error: did not expect {",
  ]
  # /path/core_2d_camera.c(44, 31) Error: expected ';'
  scanfErrors = (
    "$+($i, $i) Error: expected ';'$*",
    "$+($i, $i) Error: did not expect {$*"
  )

# Conversion with c2nim

var c2nimOutput = runc2nim()
while errorStrings.any((error) => error in c2nimOutput):
  let errors = c2nimOutput.splitLines
  block findingError:
    for error in errors:
      for scanfPattern in scanfErrors.fields:
        var
          head: string
          errorLineNo: int
          errorColumnNo: int
          tail: string
        let
          matched = error.scanf(
            scanfPattern,
            head,
            errorLineNo,
            errorColumnNo,
            tail
          )
        if matched:
          var
            buf: string
            cnt = 1
          for line in newFilename.lines:
            if cnt == errorLineNo: buf.add "//"
            buf.add line
            buf.add "\n"
            cnt.inc
          writeFile(newFilename, buf)
          echo "error on line ", errorLineNo, " fixed"
          break findingError
  c2nimOutput = runc2nim()

if fileExists(nimFilename):
  let
    fileContent = readFile(nimFilename)
    contentWithReplacements = fileContent.multiReplace(
      ("proc main*(): cint =", ""),
      (": cint =", " ="),
      (": cfloat =", " ="),
      ("import\n  raylib", "import ../../src/nimraylib_now/raylib"),

      ("vector2(", "("),
      ("vector3(", "("),
      ("vector4(", "("),
      ("quaternion(", "("),
      ("rectangle(", "("),
      ("matrix(", "("),

      ("lightgray", "Lightgray"),
      ("gray", "Gray"),
      ("darkgray", "Darkgray"),
      ("yellow", "Yellow"),
      ("gold", "Gold"),
      ("orange", "Orange"),
      ("pink", "Pink"),
      ("red", "Red"),
      ("maroon", "Maroon"),
      ("green", "Green"),
      ("lime", "Lime"),
      ("darkgreen", "Darkgreen"),
      ("skyblue", "Skyblue"),
      ("blue", "Blue"),
      ("darkblue", "Darkblue"),
      ("purple", "Purple"),
      ("violet", "Violet"),
      ("darkpurple", "Darkpurple"),
      ("beige", "Beige"),
      ("brown", "Brown"),
      ("darkbrown", "Darkbrown"),
      ("white", "White"),
      ("black", "Black"),
      ("blank", "Blank"),
      ("magenta", "Magenta"),
      ("raywhite", "Raywhite"),
    )
  var newFileContent: string = contentWithReplacements
  writeFile(nimFilename, newFileContent)
  discard tryRemoveFile(newFilename)
else:
  echo "Failed to convert " & filename & ", see mid-version in C file " &
    newFilename
