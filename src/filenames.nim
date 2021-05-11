from os import `/`, parentDir

const
  projectDir*                  = currentSourcePath().parentDir().parentDir()
  buildDir*                    = projectDir/"build"
  nimraylibNowDir*             = projectDir/"src"/"nimraylib_now"
  raylibSrcDir*                = projectDir/"raylib"/"src"
  rayguiSrcDir*                = projectDir/"raygui"/"src"
  raylibBuildDir*              = buildDir/"raylib_src"
  rayguiBuildDir*              = buildDir/"raygui_src"

  cSourcesDir*                 = projectDir/"src"/"csources"
  raylibMangledCSourcesDir*    = cSourcesDir/"raylib_mangled"

  raylibBuildFile*             = raylibBuildDir/"raylib.h"
  rlglBuildFile*               = raylibBuildDir/"rlgl.h"
  raymathBuildFile*            = raylibBuildDir/"raymath.h"
  physacBuildFile*             = raylibBuildDir/"physac.h"
  rayguiBuildFile*             = rayguiBuildDir/"raygui.h"

  manglePrefix*                = "NmrlbNow_"

when defined(nimraylib_now_mangle):
  const targetDir* = nimraylibNowDir/"mangled"
else:
  const targetDir* = nimraylibNowDir/"not_mangled"
