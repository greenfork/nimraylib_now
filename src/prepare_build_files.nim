from os import `/`, parentDir, copyFileToDir, removeDir, createDir, walkDir,
  copyDir
import strutils

import ./filenames

# Copy C headers and sources to build directory
# build directory structure:
# - build/ :: C header files which will be modified and converted to Nim sources
# - build/raylib_src :: raylib sources which will be used for static build

removeDir(buildDir)
createDir(buildDir)
writeFile(buildDir/".gitkeep", "")
createDir(raylibBuildDir)
copyDir(raylibSrcDir, raylibBuildDir)
copyFileToDir(raylibSrcDir/"extras"/"physac.h", raylibBuildDir)
copyFileToDir(raylibSrcDir/"extras"/"raygui.h", raylibBuildDir)

const
  raylibHeaders = [
    raylibBuildFile,
    rlglBuildFile,
    raymathBuildFile,
    physacBuildFile,
    rayguiBuildFile,
  ]

const
  queryPerfFiles = [
    raylibBuildDir/"rgestures.h",
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

const
  raylibSources = [
    raylibBuildDir/"rshapes.c",
    raylibBuildDir/"rtextures.c",
    raylibBuildDir/"rtext.c",
    raylibBuildDir/"utils.c",
    raylibBuildDir/"rmodels.c",
    raylibBuildDir/"raudio.c",
    raylibBuildDir/"rcore.c",
  ]
  headerPreamble = [
    "#undef near", # undefine clashing macros (from windows.h)
    "#undef far", # undefine clashing macros (from windows.h)
  ].join("\n") & "\n"

# Modify raylib files in-place inside build/ directory
for file in raylibHeaders:
  var fileContent: string = headerPreamble
  fileContent.add readFile(file)
  writeFile(file, fileContent)

copyDir(raylibBuildDir, cSourcesDir)

# Copy files to build directory for converting to Nim files
# Copy files to target directory to be used during linking with Nim files
for file in raylibHeaders:
  copyFileToDir(file, buildDir)
  copyFileToDir(file, targetDir)
