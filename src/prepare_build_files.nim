from os import `/`, parentDir, copyFileToDir, removeDir, createDir, walkDir,
  copyDir

import ./filenames

# Copy C headers and sources to build directory
# build directory structure:
# - build/ :: C header files which will be modified and converted to Nim sources
# - build/raylib_src :: raylib sources which will be used for static build
# - build/raygui_src :: raygui sources which will be used for static build

removeDir(buildDir)
createDir(buildDir)
writeFile(buildDir/".gitkeep", "")
createDir(raylibBuildDir)
createDir(rayguiBuildDir)
copyDir(raylibSrcDir, raylibBuildDir)
copyDir(rayguiSrcDir, rayguiBuildDir)

const
  raylibHeaders = [
    raylibBuildFile,
    rlglBuildFile,
    raymathBuildFile,
    physacBuildFile,
    rayguiBuildFile,
  ]


when defined(nimraylib_now_mangle):
  import strutils
  import regex

  # Some strange names that also collide with `windows.h`
  const
    queryPerfFiles = [
      raylibBuildDir/"gestures.h",
      raylibBuildDir/"physac.h",
    ]

  for file in queryPerfFiles:
    var content: string
    for line in file.lines:
      if "int __stdcall QueryPerformanceCounter" in line or
         "int __stdcall QueryPerformanceFrequency" in line:
        echo "Ignore: " & line & "\n"
      else:
        content.add line & "\n"
    writeFile(file, content)

  # Name mangling
  # On Windows some Raylib names conflict with names defined in `windows.h`
  # so we mangle them in C source and header files and later return them to
  # normal names in Nim.
  # https://github.com/greenfork/nimraylib_now/issues/5
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
    raylibSources = [
      raylibBuildDir/"shapes.c",
      raylibBuildDir/"textures.c",
      raylibBuildDir/"text.c",
      raylibBuildDir/"utils.c",
      raylibBuildDir/"models.c",
      raylibBuildDir/"raudio.c",
      raylibBuildDir/"core.c",
    ]

  func mangle(line: string): string =
    result = line
    for reName in mangleNameRegexes:
      result = result.replace(reName, manglePrefix & "$1")

  for file in raylibHeaders:
    let fileContent = readFile(file)
    writeFile(file, mangle(fileContent))
  for file in raylibSources:
    let fileContent = readFile(file)
    writeFile(file, mangle(fileContent))

  # Copy mangled C sources to src/csources
  # for file in raylibSources:
  #   copyFileToDir(file, raylibMangledCSourcesDir)
  # for file in raylibHeaders:
  #   copyFileToDir(file, raylibMangledCSourcesDir)
  copyDir(raylibBuildDir, raylibMangledCSourcesDir)


# Copy files to build directory for converting to Nim files
# Copy files to target directory to be used during linking with Nim files
for file in raylibHeaders:
  copyFileToDir(file, buildDir)
  copyFileToDir(file, targetDir)
