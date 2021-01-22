import ../../src/nimraylib_now/raylib

from os import parentDir, `/`
const rlightsHeader = currentSourcePath().parentDir()/"rlights.h"
{.passC: "-DRLIGHTS_IMPLEMENTATION".}

const MAX_LIGHTS* = 4

type
  Light* {.importc: "Light", header: rlightsHeader, bycopy.} = object
    `type`* {.importc: "type".}: cint
    position* {.importc: "position".}: Vector3
    target* {.importc: "target".}: Vector3
    color* {.importc: "color".}: Color
    enabled* {.importc: "enabled".}: bool ##  Shader locations
    enabledLoc* {.importc: "enabledLoc".}: cint
    typeLoc* {.importc: "typeLoc".}: cint
    posLoc* {.importc: "posLoc".}: cint
    targetLoc* {.importc: "targetLoc".}: cint
    colorLoc* {.importc: "colorLoc".}: cint

type
  LightType* {.size: sizeof(cint), pure.} = enum
    DIRECTIONAL, POINT
converter LightTypeToInt*(self: LightType): cint = self.cint

proc createLight*(`type`: cint; position: Vector3; target: Vector3; color: Color;
                 shader: Shader): Light {.importc: "CreateLight", header: rlightsHeader.}

proc updateLightValues*(shader: Shader; light: Light) {.importc: "UpdateLightValues",
    header: rlightsHeader.}
