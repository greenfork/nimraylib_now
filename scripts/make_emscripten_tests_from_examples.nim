import os, strutils

const
  projectDir = currentSourcePath().parentDir().parentDir()
  emscriptenExampleDir = projectDir/"examples"/"emscripten"
  emscriptenTestDir = projectDir/"tests"/"emscripten"
  exampleFile = emscriptenExampleDir/"emscripten_crown.nim"

removeDir(emscriptenTestDir)
createDir(emscriptenTestDir)
copyFileToDir(emscriptenExampleDir/"config.nims", emscriptenTestDir)

const
  testTemplate =
    "discard \"\"\"\n" &
    "  cmd: \"nim c -d:emscripten --listCmd $options $file\"\n" &
    "  action: \"compile\"\n" &
    "  joinable: false\n" &
    "  matrix: \";-d:release\"\n" &
    "\"\"\"\n\n"

var testContent = testTemplate
let exampleContent = readFile(exampleFile)
testContent &= exampleContent.replace(
  "import nimraylib_now",
  "import ../../src/nimraylib_now"
)

let testName = "t_" & extractFilename(exampleFile)
writeFile(emscriptenTestDir/testName, testContent)
