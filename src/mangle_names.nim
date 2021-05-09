# On Windows some Raylib names conflict with names defined in `windows.h`
# so we mangle them in C source and header files and later return them to
# normal names in Nim.
# https://github.com/greenfork/nimraylib_now/issues/5

from os import `/`, parentDir, copyFileToDir, removeDir, createDir, walkDir
import strutils
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
  queryPerfFiles = [
    raylibDir/"src"/"gestures.h",
    raylibDir/"src"/"physac.h",
  ]
  buildDir* = projectDir/"build"
  targetDir* = projectDir/"src"/"nimraylib_now"


# Do clean up

for file in queryPerfFiles:
  var content: string
  for line in file.lines:
    if "int __stdcall QueryPerformanceCounter" in line or
       "int __stdcall QueryPerformanceFrequency" in line:
      echo "Ignore: " & line
    else:
      content.add line & "\n"
  writeFile(file, content)


# Do name mangling

const
  mangleNameRegexes = [
    re"\b(Rectangle)\b",
    re"\b(CloseWindow)\b",
    re"\b(ShowCursor)\b",
    re"\b(LoadImage)\b",
    re"\b(DrawText)\b",
    re"\b(DrawTextEx)\b",
    re"\b(GetCurrentTime)\b",
  ]
  manglePrefix* = "NmrlbNow_"

func mangle(line: string): string =
  result = line
  for reName in mangleNameRegexes:
    result = result.replace(reName, manglePrefix & "$1")

# We re-created directory, so all the files inside are needed.
for file in raylibHeaders:
  let fileContent = readFile(file)
  writeFile(file, mangle(fileContent))
for file in raylibSources:
  let fileContent = readFile(file)
  writeFile(file, mangle(fileContent))

# Copy files to build directory

removeDir(buildDir)
createDir(buildDir)
writeFile(buildDir/".gitkeep", "")

for file in raylibHeaders:
  copyFileToDir(file, buildDir)
  copyFileToDir(file, targetDir)
