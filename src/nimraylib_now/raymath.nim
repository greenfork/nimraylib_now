import raylib

from os import parentDir, `/`
const raymathHeader = currentSourcePath().parentDir()/"raymath.h"
## *********************************************************************************************
##
##    raymath v1.2 - Math functions to work with Vector3, Matrix and Quaternions
##
##    CONFIGURATION:
##
##    #define RAYMATH_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RAYMATH_HEADER_ONLY
##        Define static inline functions code, so #include header suffices for use.
##        This may use up lots of memory.
##
##    #define RAYMATH_STANDALONE
##        Avoid raylib.h header inclusion in this file.
##        Vector3 and Matrix data types are defined internally in raymath module.
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2015-2021 Ramon Santamaria (@raysan5)
##
##    This software is provided "as-is", without any express or implied warranty. In no event
##    will the authors be held liable for any damages arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose, including commercial
##    applications, and to alter it and redistribute it freely, subject to the following restrictions:
##
##      1. The origin of this software must not be misrepresented; you must not claim that you
##      wrote the original software. If you use this software in a product, an acknowledgment
##      in the product documentation would be appreciated but is not required.
##
##      2. Altered source versions must be plainly marked as such, and must not be misrepresented
##      as being the original software.
##
##      3. This notice may not be removed or altered from any source distribution.
##
## ********************************************************************************************
## #define RAYMATH_STANDALONE      // NOTE: To use raymath as standalone lib, just uncomment this line
## #define RAYMATH_HEADER_ONLY     // NOTE: To compile functions as static inline, uncomment this line
## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Return float vector for Matrix
##  Return float vector for Vector3
## ----------------------------------------------------------------------------------
##  Types and Structures Definition
## ----------------------------------------------------------------------------------
##  NOTE: Helper types to be used instead of array return types for *ToFloat functions

type
  Float3* {.importc: "float3", header: raymathHeader, bycopy.} = object
    v* {.importc: "v".}: array[3, cfloat]

  Float16* {.importc: "float16", header: raymathHeader, bycopy.} = object
    v* {.importc: "v".}: array[16, cfloat]


## ----------------------------------------------------------------------------------
##  Module Functions Definition - Utils math
## ----------------------------------------------------------------------------------
##  Clamp float value

proc clamp*(value: cfloat; min: cfloat; max: cfloat): cfloat {.inline, cdecl,
    importc: "Clamp", header: raymathHeader.}
##  Calculate linear interpolation between two floats

proc lerp*(start: cfloat; `end`: cfloat; amount: cfloat): cfloat {.inline, cdecl,
    importc: "Lerp", header: raymathHeader.}
##  Normalize input value within input range

proc normalize*(value: cfloat; start: cfloat; `end`: cfloat): cfloat {.inline, cdecl,
    importc: "Normalize", header: raymathHeader.}
##  Remap input value within input range to output range

proc remap*(value: cfloat; inputStart: cfloat; inputEnd: cfloat; outputStart: cfloat;
           outputEnd: cfloat): cfloat {.inline, cdecl, importc: "Remap",
                                     header: raymathHeader.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Vector2 math
## ----------------------------------------------------------------------------------
##  Vector with components value 0.0f

proc vector2Zero*(): Vector2 {.inline, cdecl, importc: "Vector2Zero",
                            header: raymathHeader.}
##  Vector with components value 1.0f

proc vector2One*(): Vector2 {.inline, cdecl, importc: "Vector2One",
                           header: raymathHeader.}
##  Add two vectors (v1 + v2)

proc vector2Add*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Add", header: raymathHeader.}
##  Add vector and float value

proc vector2AddValue*(v: Vector2; add: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2AddValue", header: raymathHeader.}
##  Subtract two vectors (v1 - v2)

proc vector2Subtract*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Subtract", header: raymathHeader.}
##  Subtract vector by float value

proc vector2SubtractValue*(v: Vector2; sub: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2SubtractValue", header: raymathHeader.}
##  Calculate vector length

proc vector2Length*(v: Vector2): cfloat {.inline, cdecl, importc: "Vector2Length",
                                      header: raymathHeader.}
##  Calculate vector square length

proc vector2LengthSqr*(v: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2LengthSqr", header: raymathHeader.}
##  Calculate two vectors dot product

proc vector2DotProduct*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2DotProduct", header: raymathHeader.}
##  Calculate distance between two vectors

proc vector2Distance*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2Distance", header: raymathHeader.}
##  Calculate angle from two vectors in X-axis

proc vector2Angle*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2Angle", header: raymathHeader.}
##  Scale vector (multiply by value)

proc vector2Scale*(v: Vector2; scale: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Scale", header: raymathHeader.}
##  Multiply vector by vector

proc vector2Multiply*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Multiply", header: raymathHeader.}
##  Negate vector

proc vector2Negate*(v: Vector2): Vector2 {.inline, cdecl, importc: "Vector2Negate",
                                       header: raymathHeader.}
##  Divide vector by vector

proc vector2Divide*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Divide", header: raymathHeader.}
##  Normalize provided vector

proc vector2Normalize*(v: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Normalize", header: raymathHeader.}
##  Calculate linear interpolation between two vectors

proc vector2Lerp*(v1: Vector2; v2: Vector2; amount: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Lerp", header: raymathHeader.}
##  Calculate reflected vector to normal

proc vector2Reflect*(v: Vector2; normal: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Reflect", header: raymathHeader.}
##  Rotate Vector by float in Degrees.

proc vector2Rotate*(v: Vector2; degs: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Rotate", header: raymathHeader.}
##  Move Vector towards target

proc vector2MoveTowards*(v: Vector2; target: Vector2; maxDistance: cfloat): Vector2 {.
    inline, cdecl, importc: "Vector2MoveTowards", header: raymathHeader.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Vector3 math
## ----------------------------------------------------------------------------------
##  Vector with components value 0.0f

proc vector3Zero*(): Vector3 {.inline, cdecl, importc: "Vector3Zero",
                            header: raymathHeader.}
##  Vector with components value 1.0f

proc vector3One*(): Vector3 {.inline, cdecl, importc: "Vector3One",
                           header: raymathHeader.}
##  Add two vectors

proc vector3Add*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Add", header: raymathHeader.}
##  Add vector and float value

proc vector3AddValue*(v: Vector3; add: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3AddValue", header: raymathHeader.}
##  Subtract two vectors

proc vector3Subtract*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Subtract", header: raymathHeader.}
##  Subtract vector by float value

proc vector3SubtractValue*(v: Vector3; sub: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3SubtractValue", header: raymathHeader.}
##  Multiply vector by scalar

proc vector3Scale*(v: Vector3; scalar: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3Scale", header: raymathHeader.}
##  Multiply vector by vector

proc vector3Multiply*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Multiply", header: raymathHeader.}
##  Calculate two vectors cross product

proc vector3CrossProduct*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3CrossProduct", header: raymathHeader.}
##  Calculate one vector perpendicular vector

proc vector3Perpendicular*(v: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Perpendicular", header: raymathHeader.}
##  Calculate vector length

proc vector3Length*(v: Vector3): cfloat {.inline, cdecl, importc: "Vector3Length",
                                      header: raymathHeader.}
##  Calculate vector square length

proc vector3LengthSqr*(v: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3LengthSqr", header: raymathHeader.}
##  Calculate two vectors dot product

proc vector3DotProduct*(v1: Vector3; v2: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3DotProduct", header: raymathHeader.}
##  Calculate distance between two vectors

proc vector3Distance*(v1: Vector3; v2: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3Distance", header: raymathHeader.}
##  Negate provided vector (invert direction)

proc vector3Negate*(v: Vector3): Vector3 {.inline, cdecl, importc: "Vector3Negate",
                                       header: raymathHeader.}
##  Divide vector by vector

proc vector3Divide*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Divide", header: raymathHeader.}
##  Normalize provided vector

proc vector3Normalize*(v: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Normalize", header: raymathHeader.}
##  Orthonormalize provided vectors
##  Makes vectors normalized and orthogonal to each other
##  Gram-Schmidt function implementation

proc vector3OrthoNormalize*(v1: ptr Vector3; v2: ptr Vector3) {.inline, cdecl,
    importc: "Vector3OrthoNormalize", header: raymathHeader.}
##  Transforms a Vector3 by a given Matrix

proc vector3Transform*(v: Vector3; mat: Matrix): Vector3 {.inline, cdecl,
    importc: "Vector3Transform", header: raymathHeader.}
##  Transform a vector by quaternion rotation

proc vector3RotateByQuaternion*(v: Vector3; q: Quaternion): Vector3 {.inline, cdecl,
    importc: "Vector3RotateByQuaternion", header: raymathHeader.}
##  Calculate linear interpolation between two vectors

proc vector3Lerp*(v1: Vector3; v2: Vector3; amount: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3Lerp", header: raymathHeader.}
##  Calculate reflected vector to normal

proc vector3Reflect*(v: Vector3; normal: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Reflect", header: raymathHeader.}
##  Return min value for each pair of components

proc vector3Min*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Min", header: raymathHeader.}
##  Return max value for each pair of components

proc vector3Max*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Max", header: raymathHeader.}
##  Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
##  NOTE: Assumes P is on the plane of the triangle

proc vector3Barycenter*(p: Vector3; a: Vector3; b: Vector3; c: Vector3): Vector3 {.inline,
    cdecl, importc: "Vector3Barycenter", header: raymathHeader.}
##  Returns Vector3 as float array

proc vector3ToFloatV*(v: Vector3): Float3 {.inline, cdecl, importc: "Vector3ToFloatV",
                                        header: raymathHeader.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Matrix math
## ----------------------------------------------------------------------------------
##  Compute matrix determinant

proc matrixDeterminant*(mat: Matrix): cfloat {.inline, cdecl,
    importc: "MatrixDeterminant", header: raymathHeader.}
##  Returns the trace of the matrix (sum of the values along the diagonal)

proc matrixTrace*(mat: Matrix): cfloat {.inline, cdecl, importc: "MatrixTrace",
                                     header: raymathHeader.}
##  Transposes provided matrix

proc matrixTranspose*(mat: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixTranspose", header: raymathHeader.}
##  Invert provided matrix

proc matrixInvert*(mat: Matrix): Matrix {.inline, cdecl, importc: "MatrixInvert",
                                      header: raymathHeader.}
##  Normalize provided matrix

proc matrixNormalize*(mat: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixNormalize", header: raymathHeader.}
##  Returns identity matrix

proc matrixIdentity*(): Matrix {.inline, cdecl, importc: "MatrixIdentity",
                              header: raymathHeader.}
##  Add two matrices

proc matrixAdd*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixAdd", header: raymathHeader.}
##  Subtract two matrices (left - right)

proc matrixSubtract*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixSubtract", header: raymathHeader.}
##  Returns two matrix multiplication
##  NOTE: When multiplying matrices... the order matters!

proc matrixMultiply*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixMultiply", header: raymathHeader.}
##  Returns translation matrix

proc matrixTranslate*(x: cfloat; y: cfloat; z: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixTranslate", header: raymathHeader.}
##  Create rotation matrix from axis and angle
##  NOTE: Angle should be provided in radians

proc matrixRotate*(axis: Vector3; angle: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixRotate", header: raymathHeader.}
##  Returns x-rotation matrix (angle in radians)

proc matrixRotateX*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateX",
    header: raymathHeader.}
##  Returns y-rotation matrix (angle in radians)

proc matrixRotateY*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateY",
    header: raymathHeader.}
##  Returns z-rotation matrix (angle in radians)

proc matrixRotateZ*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateZ",
    header: raymathHeader.}
##  Returns xyz-rotation matrix (angles in radians)

proc matrixRotateXYZ*(ang: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixRotateXYZ", header: raymathHeader.}
##  Returns zyx-rotation matrix (angles in radians)
##  TODO: This solution is suboptimal, it should be possible to create this matrix in one go
##  instead of using a 3 matrix multiplication

proc matrixRotateZYX*(ang: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixRotateZYX", header: raymathHeader.}
##  Returns scaling matrix

proc matrixScale*(x: cfloat; y: cfloat; z: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixScale", header: raymathHeader.}
##  Returns perspective projection matrix

proc matrixFrustum*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
                   near: cdouble; far: cdouble): Matrix {.inline, cdecl,
    importc: "MatrixFrustum", header: raymathHeader.}
##  Returns perspective projection matrix
##  NOTE: Angle should be provided in radians

proc matrixPerspective*(fovy: cdouble; aspect: cdouble; near: cdouble; far: cdouble): Matrix {.
    inline, cdecl, importc: "MatrixPerspective", header: raymathHeader.}
##  Returns orthographic projection matrix

proc matrixOrtho*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
                 near: cdouble; far: cdouble): Matrix {.inline, cdecl,
    importc: "MatrixOrtho", header: raymathHeader.}
##  Returns camera look-at matrix (view matrix)

proc matrixLookAt*(eye: Vector3; target: Vector3; up: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixLookAt", header: raymathHeader.}
##  Returns float array of matrix data

proc matrixToFloatV*(mat: Matrix): Float16 {.inline, cdecl, importc: "MatrixToFloatV",
    header: raymathHeader.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Quaternion math
## ----------------------------------------------------------------------------------
##  Add two quaternions

proc quaternionAdd*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionAdd", header: raymathHeader.}
##  Add quaternion and float value

proc quaternionAddValue*(q: Quaternion; add: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionAddValue", header: raymathHeader.}
##  Subtract two quaternions

proc quaternionSubtract*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionSubtract", header: raymathHeader.}
##  Subtract quaternion and float value

proc quaternionSubtractValue*(q: Quaternion; sub: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionSubtractValue", header: raymathHeader.}
##  Returns identity quaternion

proc quaternionIdentity*(): Quaternion {.inline, cdecl,
                                      importc: "QuaternionIdentity",
                                      header: raymathHeader.}
##  Computes the length of a quaternion

proc quaternionLength*(q: Quaternion): cfloat {.inline, cdecl,
    importc: "QuaternionLength", header: raymathHeader.}
##  Normalize provided quaternion

proc quaternionNormalize*(q: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionNormalize", header: raymathHeader.}
##  Invert provided quaternion

proc quaternionInvert*(q: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionInvert", header: raymathHeader.}
##  Calculate two quaternion multiplication

proc quaternionMultiply*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionMultiply", header: raymathHeader.}
##  Scale quaternion by float value

proc quaternionScale*(q: Quaternion; mul: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionScale", header: raymathHeader.}
##  Divide two quaternions

proc quaternionDivide*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionDivide", header: raymathHeader.}
##  Calculate linear interpolation between two quaternions

proc quaternionLerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionLerp", header: raymathHeader.}
##  Calculate slerp-optimized interpolation between two quaternions

proc quaternionNlerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionNlerp", header: raymathHeader.}
##  Calculates spherical linear interpolation between two quaternions

proc quaternionSlerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionSlerp", header: raymathHeader.}
##  Calculate quaternion based on the rotation from one vector to another

proc quaternionFromVector3ToVector3*(`from`: Vector3; to: Vector3): Quaternion {.
    inline, cdecl, importc: "QuaternionFromVector3ToVector3", header: raymathHeader.}
##  Returns a quaternion for a given rotation matrix

proc quaternionFromMatrix*(mat: Matrix): Quaternion {.inline, cdecl,
    importc: "QuaternionFromMatrix", header: raymathHeader.}
##  Returns a matrix for a given quaternion

proc quaternionToMatrix*(q: Quaternion): Matrix {.inline, cdecl,
    importc: "QuaternionToMatrix", header: raymathHeader.}
##  Returns rotation quaternion for an angle and axis
##  NOTE: angle must be provided in radians

proc quaternionFromAxisAngle*(axis: Vector3; angle: cfloat): Quaternion {.inline,
    cdecl, importc: "QuaternionFromAxisAngle", header: raymathHeader.}
##  Returns the rotation angle and axis for a given quaternion

proc quaternionToAxisAngle*(q: Quaternion; outAxis: ptr Vector3; outAngle: ptr cfloat) {.
    inline, cdecl, importc: "QuaternionToAxisAngle", header: raymathHeader.}
##  Returns he quaternion equivalent to Euler angles

proc quaternionFromEuler*(roll: cfloat; pitch: cfloat; yaw: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionFromEuler", header: raymathHeader.}
##  Return the Euler angles equivalent to quaternion (roll, pitch, yaw)
##  NOTE: Angles are returned in a Vector3 struct in degrees

proc quaternionToEuler*(q: Quaternion): Vector3 {.inline, cdecl,
    importc: "QuaternionToEuler", header: raymathHeader.}
##  Transform a quaternion given a transformation matrix

proc quaternionTransform*(q: Quaternion; mat: Matrix): Quaternion {.inline, cdecl,
    importc: "QuaternionTransform", header: raymathHeader.}
##  Projects a Vector3 from screen space into object space

proc vector3Unproject*(source: Vector3; projection: Matrix; view: Matrix): Vector3 {.
    inline, cdecl, importc: "Vector3Unproject", header: raymathHeader.}
