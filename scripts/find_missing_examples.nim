import os

const
  projectDir = currentSourcePath().parentDir().parentDir()
  #originalRaylibExamplesDir = projectDir/"raylib"/"examples"
  originalRaylibExamplesDir = "/home/jseb/sources/raylib_jseb/examples"
  nimraylibNowExamplesDir = projectDir/"examples"

for dir in walkDirs(originalRaylibExamplesDir/"*"):
  for originalExample in walkFiles(dir/"*"):
    let (_, name, ext) = splitFile(originalExample)
    if ext == ".c":
      let
        category = originalExample.parentDir.lastPathPart
        nimExampleName = name & ".nim"
      if not fileExists(nimraylibNowExamplesDir/category/nimExampleName):
        echo "Missing: ", category/nimExampleName
