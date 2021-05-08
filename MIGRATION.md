# Migration guide

This guide documents migration between different versions of NimraylibNow!
and and if necessary simultaneously different versions of Raylib library.

Additionally you can consult [Raylib's changelog](https://github.com/raysan5/raylib/blob/master/CHANGELOG).

## From Raylib v3.5 to v3.7 and from NimraylibNow! v0.10 to v0.12

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
- VR handling was changed significantly, see updated example `core/core_vr_simulator.nim`
- `runPhysicsStep` was renamed to `updatePhysics`
- `getShaderDefault` and freinds were moved from `raylib` module to `rlgl`
