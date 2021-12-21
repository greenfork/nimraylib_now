from os import `/`, parentDir

const
  projectDir*                  = currentSourcePath().parentDir().parentDir()
  buildDir*                    = projectDir/"build"
  nimraylibNowDir*             = projectDir/"src"/"nimraylib_now"
  raylibSrcDir*                = projectDir/"raylib"/"src"
  raylibBuildDir*              = buildDir/"raylib_src"
  rayguiBuildDir*              = buildDir/"raygui_src"
  targetDir*                   = nimraylibNowDir

  # Must assume that there's no `projectDir` as if it is installed as a nimble
  # package.
  srcDir*                      = currentSourcePath().parentDir()
  cSourcesDir*                 = srcDir/"csources"

  raylibBuildFile*             = raylibBuildDir/"raylib.h"
  rlglBuildFile*               = raylibBuildDir/"rlgl.h"
  raymathBuildFile*            = raylibBuildDir/"raymath.h"
  physacBuildFile*             = raylibBuildDir/"physac.h"
  rayguiBuildFile*             = raylibBuildDir/"raygui.h"
