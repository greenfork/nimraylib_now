## Create tests from examples for each category, max depth is 1 level
## Usage: nim r tools/make_tests_from_examples.nim

import os, strutils

const
  projectDir = currentSourcePath().parentDir().parentDir()
  examplesDir = projectDir/"examples"
  testsDir = projectDir/"tests"/"examples"

# Remove all existing example tests
for dir in walkDirs(testsDir/"*"):
  removeDir(dir)

# Collect all category names and create them in tests directory
var exampleCategories: seq[string]
for dir in walkDirs(examplesDir/"*"):
  let dirName = dir.lastPathPart
  if dirName != "emscripten":
    exampleCategories.add dirName

const
  testTemplate =
    "discard \"\"\"\n" &
    "  action: \"compile\"\n" &
    "  joinable: false\n" &
    "  matrix: \"; -d:release; --gc:orc -d:release; -d:nimraylib_now_shared -d:release; -d:nimraylib_now_shared -d:release --gc:orc\"\n" &
    "  disabled: \"win\"\n" &
    "\"\"\"\n" &
    "import lenientops, math, times, strformat, atomics, system/ansi_c\n" &
    "import ../src/nimraylib_now/[raylib, raygui, raymath, physac]\n" &
    "from ../src/nimraylib_now/rlgl as rl import nil\n" &
    "import ../examples/shaders/rlights\n" &
    "\n"
  # Don't test shared library for windows
  testTemplateWindows =
    "discard \"\"\"\n" &
    "  action: \"compile\"\n" &
    "  joinable: false\n" &
    "  matrix: \"; -d:release; --gc:orc -d:release;\"\n" &
    "  disabled: \"linux\"\n" &
    "  disabled: \"bsd\"\n" &
    "  disabled: \"macosx\"\n" &
    "\"\"\"\n" &
    "import lenientops, math, times, strformat, atomics, system/ansi_c\n" &
    "import ../src/nimraylib_now/[raylib, raygui, raymath, physac]\n" &
    "from ../src/nimraylib_now/rlgl as rl import nil\n" &
    "import ../examples/shaders/rlights\n" &
    "\n"

# Create one big megatest
const testFilename = projectDir/"tests"/"texamples.nim"
const testFilenameWindows = projectDir/"tests"/"texamples_windows.nim"
removeFile(testFilename)
var texamples: string
for category in exampleCategories:
  for example in walkFiles(examplesDir/category/"*.nim"):
    if example.endsWith("rlights.nim"): continue

    texamples.add "block " & example.lastPathPart.replace(".nim", "") & ":\n"
    for line in example.lines:
      if not line.startsWith("import") and not line.startsWith("from"):
        let space = if line == "": "" else: "  "
        texamples.add space & line & "\n"
    texamples.add "\n\n"

writeFile(testFilename, testTemplate & texamples)
writeFile(testFilenameWindows, testTemplateWindows & texamples)
