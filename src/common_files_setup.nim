from os import `/`, removeDir, createDir, copyFileToDir
import strformat

import ./filenames

const buildScript = projectDir/"src"/"raylib_build_static.nim"

removeDir(nimraylibNowDir)
createDir(nimraylibNowDir)
createDir(nimraylibNowDir/"mangled")
createDir(nimraylibNowDir/"not_mangled")
copyFileToDir(buildScript, nimraylibNowDir)

const
  alternatingNimFiles* = [
    "physac",
    "raygui",
    "raylib",
    "raymath",
    "rlgl",
    "converters",
  ]

for filename in alternatingNimFiles:
  let content = fmt"""
when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/{filename}
else:
  import mangled/{filename}

export {filename}
"""
  writeFile(nimraylibNowDir/filename & ".nim", content)
