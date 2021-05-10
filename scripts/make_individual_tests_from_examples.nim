import os, strutils

const
  projectDir = currentSourcePath().parentDir().parentDir()
  examplesDir = projectDir/"examples"
  examplesTestDir = projectDir/"tests"/"examples"

# Collect all category names and create them in tests directory
var exampleCategories: seq[string]
for dir in walkDirs(examplesDir/"*"):
  let dirName = dir.lastPathPart
  if dirName != "emscripten":
    exampleCategories.add dirName

removeDir(examplesTestDir)
createDir(examplesTestDir)

const
  testTemplate =
    "discard \"\"\"\n" &
    "  action: \"compile\"\n" &
    "  joinable: false\n" &
    "  matrix: \"; -d:release; --gc:orc -d:release\"\n" &
    "\"\"\"\n\n"

# Create test for each example
for category in exampleCategories:
  for example in walkFiles(examplesDir/category/"*.nim"):
    if example.endsWith("rlights.nim"): continue

    var testContent = testTemplate
    let exampleContent = readFile(example)
    testContent &= exampleContent.replace(
      "import nimraylib_now",
      "import ../../src/nimraylib_now"
    )

    let testName = "t_" & extractFilename(example)
    writeFile(examplesTestDir/testName, testContent)

const
  rlightsnim = projectDir/"examples"/"shaders"/"rlights.nim"
  rlightsh = projectDir/"examples"/"shaders"/"rlights.h"

let
  rlightsnimContent = readFile(rlightsnim)
  rlightsnimNewContent = rlightsnimContent.replace(
    "import nimraylib_now",
    "import ../../src/nimraylib_now"
  )
writeFile(examplesTestDir/"rlights.nim", rlightsnimNewContent)
copyFileToDir(rlightsh, examplesTestDir)
