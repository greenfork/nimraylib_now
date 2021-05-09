# On Windows some Raylib names conflict with names defined in `windows.h`
# so we mangle them in C source and header files and later return them to
# normal names in Nim.
# https://github.com/greenfork/nimraylib_now/issues/5

from os import `/`, parentDir, copyFileToDir, removeDir, createDir, walkDir
from strutils import endsWith
import regex

# Copy C headers and sources to build directory

const
  projectDir = currentSourcePath().parentDir().parentDir()
  raylibDir = projectDir/"raylib"
  rayguiDir = projectDir/"raygui"
  raylibHeaders = [
    raylibDir/"src"/"raylib.h",
    raylibDir/"src"/"rlgl.h",
    raylibDir/"src"/"raymath.h",
    rayguiDir/"src"/"raygui.h",
    raylibDir/"src"/"physac.h",
  ]
  raylibSources = [
    raylibDir/"src"/"shapes.c",
    raylibDir/"src"/"textures.c",
    raylibDir/"src"/"text.c",
    raylibDir/"src"/"utils.c",
    raylibDir/"src"/"models.c",
    raylibDir/"src"/"raudio.c",
    raylibDir/"src"/"core.c",
  ]
  buildDir* = projectDir/"build"
  targetDir* = projectDir/"src"/"nimraylib_now"

removeDir(buildDir)
createDir(buildDir)
writeFile(buildDir/".gitkeep", "")

for file in raylibHeaders:
  copyFileToDir(file, buildDir)

for file in raylibSources:
  copyFileToDir(file, buildDir)

# Do name mangling

const
  mangleNameRegexes = [
    re"\b(Rectangle)\b",
    re"\b(CloseWindow)\b",
    re"\b(ShowCursor)\b",
  ]
  manglePrefix* = "NmrlbNow_"

func mangle(line: string): string =
  result = line
  for reName in mangleNameRegexes:
    result = result.replace(reName, manglePrefix & "$1")

# We re-created directory, so all the files inside are needed.
for _, file in walkDir(buildDir):
  if not file.endsWith(".gitkeep"):
    let fileContent = readFile(file)
    writeFile(file, mangle(fileContent))
    copyFileToDir(file, targetDir)
