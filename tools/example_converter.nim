## Usage: ./example_converter core_2d_camera.c

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

let newFilename = name & "_new" & ext
copyFile(filename, newFilename)

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
    newFileContent = fileContent.multiReplace(
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
  writeFile(nimFilename, newFileContent)
