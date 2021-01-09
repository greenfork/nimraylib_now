## Create tests from examples for each category, max depth is 1 level
## Usage: nim r tools/make_tests_from_examples.nim

import os, strutils

const
  projectDir = currentSourcePath().parentDir().parentDir()
  examplesDir = projectDir/"examples"
  testsDir = projectDir/"tests"/"examples"

var exampleCategories: seq[string]
for dir in walkDirs(examplesDir/"*"):
  let dirName = dir.lastPathPart
  exampleCategories.add dirName
  createDir(testsDir/dirName)

const testTemplate =
  "discard \"\"\"\n" &
  "  action: \"compile\"\n" &
  "  # more\n" &
  "\"\"\"\n"

for category in exampleCategories:
  for example in walkFiles(examplesDir/category/"*"):
    let
      testName = "t" & example.lastPathPart
      includePath = example.replace(projectDir, "../../..").replace(".nim", "")
      includeStmt = "include " & includePath
      content = testTemplate & includeStmt
    writeFile(testsDir/category/testName, content)
