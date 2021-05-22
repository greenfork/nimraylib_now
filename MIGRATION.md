# Migration guide

This guide documents migration between different versions of NimraylibNow!
and and if necessary simultaneously different versions of Raylib library.

There are not a lot of possibilities to use proper deprecation warnings
since it is not always possible to translate `#define` declarations from C.
Sadly upgrades of user code is a necessary part of migration. On the bright
side it should mainly consist of renaming, please try the wonderful tool
`nimgrep`, it is shipped with Nim and has a useful "replace" functionality.

Additionally you can consult [Raylib's changelog](https://github.com/raysan5/raylib/blob/master/CHANGELOG).

## From NimraylibNow! v0.12 to v0.13

- `Mesh` has most of its fields changed from `ptr cfloat` to `ptr UncheckedArray[cfloat]`

## From Raylib v3.5 to v3.7 and from NimraylibNow! v0.10 to v0.12

Recommended:

- Change all imports except for `rlgl` to just `import nimraylib_now`

Renamed:

- `Camera.type` was renamed to `Camera.projection`
- `CameraType` was renamed to `CameraProjection`
- `GestureType` was renamed to `Gestures`
- `Material.params` type was changed from `ptr cfloat` to `array[4, cfloat]`
- `ConfigFlag` was renamed to `ConfigFlags`
- `TraceLogType` was renamed to `TraceLogLevel`
- `TextureFilterMod` was renamed to `TextureFilter`
- `TextureWrapMode` was renamed to `TextureWrap`
- `CubemapLayoutType` was renamed to `CubemapLayout`
- `NPatchInfo.type` was renamed to `NPatchInfo.layout`
- `NPatchType` was renamed to `NPatchLayout`
- `NPatchLayout` enum values were renamed to use English words instead of numbers
- `beginVrDrawing` was renamed to `beginVrStereoMode`
- `runPhysicsStep` was renamed to `updatePhysics`
- `getShaderDefault` and freinds were moved from `raylib` module to `rlgl`

Misc changes:

- VR handling was changed significantly, see updated example `core/core_vr_simulator.nim`
- Importing just `nimraylib_now` is now possible and it imports all libraries
  but `rlgl`
- "Tuple to object converters for geometry" feature requires importing
  `nimraylib_now/converters` or just `nimraylib_now`
