import httpclient, asyncdispatch
from os import `/`, fileExists, extractFilename
from strutils import split

const
  downloadDirectory = "raylib"
  urlStart = "https://raw.githubusercontent.com/raysan5/"
  filesToDownload = [
    "raylib/master/src/raylib.h",
    "raygui/master/src/raygui.h",
    "raylib/master/src/rlgl.h",
    "raylib/master/src/raymath.h",
  ]


# Download header files

proc downloadSources() {.async.} =
  var futures: seq[Future[void]]
  for file in filesToDownload:
    var client = newAsyncHttpClient()
    let
      url = urlStart & file
      targetPath = downloadDirectory/file.extractFilename
    futures.add client.downloadFile(url, targetPath)
  for future in futures:
    await future

var doDownload = false
for file in filesToDownload:
  if not fileExists(downloadDirectory/file.extractFilename):
    doDownload = true
    break
if doDownload:
  waitFor downloadSources()


# Parse files to (((Nim))) wrappers
