from os import `/`, removeDir, createDir, copyFileToDir, moveFile
import strformat

import ./filenames

removeDir(nimraylibNowDir)
createDir(nimraylibNowDir)
copyFileToDir(
  projectDir/"src"/"raylib_build_static_template.nim",
  nimraylibNowDir
)
moveFile(
  nimraylibNowDir/"raylib_build_static_template.nim",
  nimraylibNowDir/"raylib_build_static.nim"
)
removeDir(cSourcesDir)
createDir(cSourcesDir)
