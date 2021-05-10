from os import `/`, removeDir, createDir, copyFileToDir

import ./filenames

const buildScript = projectDir/"src"/"raylib_build_static.nim"

removeDir(nimraylibNowDir)
createDir(nimraylibNowDir)
createDir(nimraylibNowDir/"mangled")
createDir(nimraylibNowDir/"not_mangled")
copyFileToDir(buildScript, nimraylibNowDir)
