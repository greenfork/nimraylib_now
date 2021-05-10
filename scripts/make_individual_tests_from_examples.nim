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

    # testContent &= readFile(example)
    let (exdir, exname, _) = splitFile(example)
    let examplePath = relativePath(exdir, examplesTestDir)
    testContent &= "include " & examplePath / exname & "\n"

    let testName = "t_" & extractFilename(example)
    writeFile(examplesTestDir/testName, testContent)

const
  rlightsnim = projectDir/"examples"/"shaders"/"rlights.nim"
  rlightsh = projectDir/"examples"/"shaders"/"rlights.h"

copyFileToDir(rlightsnim, examplesTestDir)
copyFileToDir(rlightsh, examplesTestDir)
