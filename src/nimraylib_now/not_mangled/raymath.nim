 {.deadCodeElim: on.}
import raylib
const dynlibLibraryName =
  when defined(windows):
    "raylib.dll"
  elif defined(macosx):
    "libraylib.dylib"
  else:
    "libraylib.so"

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
  Float3* {.bycopy.} = object
    v*: array[3, cfloat]

  Float16* {.bycopy.} = object
    v*: array[16, cfloat]


## ----------------------------------------------------------------------------------
##  Module Functions Definition - Utils math
## ----------------------------------------------------------------------------------
##  Clamp float value

proc clamp*(value: cfloat; min: cfloat; max: cfloat): cfloat {.inline, cdecl,
    importc: "Clamp", dynlib: dynlibLibraryName.}
##  Calculate linear interpolation between two floats

proc lerp*(start: cfloat; `end`: cfloat; amount: cfloat): cfloat {.inline, cdecl,
    importc: "Lerp", dynlib: dynlibLibraryName.}
##  Normalize input value within input range

proc normalize*(value: cfloat; start: cfloat; `end`: cfloat): cfloat {.inline, cdecl,
    importc: "Normalize", dynlib: dynlibLibraryName.}
##  Remap input value within input range to output range

proc remap*(value: cfloat; inputStart: cfloat; inputEnd: cfloat; outputStart: cfloat;
           outputEnd: cfloat): cfloat {.inline, cdecl, importc: "Remap",
                                     dynlib: dynlibLibraryName.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Vector2 math
## ----------------------------------------------------------------------------------
##  Vector with components value 0.0f

proc vector2Zero*(): Vector2 {.inline, cdecl, importc: "Vector2Zero",
                            dynlib: dynlibLibraryName.}
##  Vector with components value 1.0f

proc vector2One*(): Vector2 {.inline, cdecl, importc: "Vector2One",
                           dynlib: dynlibLibraryName.}
##  Add two vectors (v1 + v2)

proc add*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Add", dynlib: dynlibLibraryName.}
##  Add vector and float value

proc addValue*(v: Vector2; add: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2AddValue", dynlib: dynlibLibraryName.}
##  Subtract two vectors (v1 - v2)

proc subtract*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Subtract", dynlib: dynlibLibraryName.}
##  Subtract vector by float value

proc subtractValue*(v: Vector2; sub: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2SubtractValue", dynlib: dynlibLibraryName.}
##  Calculate vector length

proc length*(v: Vector2): cfloat {.inline, cdecl, importc: "Vector2Length",
                                      dynlib: dynlibLibraryName.}
##  Calculate vector square length

proc lengthSqr*(v: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2LengthSqr", dynlib: dynlibLibraryName.}
##  Calculate two vectors dot product

proc dotProduct*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2DotProduct", dynlib: dynlibLibraryName.}
##  Calculate distance between two vectors

proc distance*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2Distance", dynlib: dynlibLibraryName.}
##  Calculate angle from two vectors in X-axis

proc angle*(v1: Vector2; v2: Vector2): cfloat {.inline, cdecl,
    importc: "Vector2Angle", dynlib: dynlibLibraryName.}
##  Scale vector (multiply by value)

proc scale*(v: Vector2; scale: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Scale", dynlib: dynlibLibraryName.}
##  Multiply vector by vector

proc multiply*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Multiply", dynlib: dynlibLibraryName.}
##  Negate vector

proc negate*(v: Vector2): Vector2 {.inline, cdecl, importc: "Vector2Negate",
                                       dynlib: dynlibLibraryName.}
##  Divide vector by vector

proc divide*(v1: Vector2; v2: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Divide", dynlib: dynlibLibraryName.}
##  Normalize provided vector

proc normalize*(v: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Normalize", dynlib: dynlibLibraryName.}
##  Calculate linear interpolation between two vectors

proc lerp*(v1: Vector2; v2: Vector2; amount: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Lerp", dynlib: dynlibLibraryName.}
##  Calculate reflected vector to normal

proc reflect*(v: Vector2; normal: Vector2): Vector2 {.inline, cdecl,
    importc: "Vector2Reflect", dynlib: dynlibLibraryName.}
##  Rotate Vector by float in Degrees.

proc rotate*(v: Vector2; degs: cfloat): Vector2 {.inline, cdecl,
    importc: "Vector2Rotate", dynlib: dynlibLibraryName.}
##  Move Vector towards target

proc moveTowards*(v: Vector2; target: Vector2; maxDistance: cfloat): Vector2 {.
    inline, cdecl, importc: "Vector2MoveTowards", dynlib: dynlibLibraryName.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Vector3 math
## ----------------------------------------------------------------------------------
##  Vector with components value 0.0f

proc vector3Zero*(): Vector3 {.inline, cdecl, importc: "Vector3Zero",
                            dynlib: dynlibLibraryName.}
##  Vector with components value 1.0f

proc vector3One*(): Vector3 {.inline, cdecl, importc: "Vector3One",
                           dynlib: dynlibLibraryName.}
##  Add two vectors

proc add*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Add", dynlib: dynlibLibraryName.}
##  Add vector and float value

proc addValue*(v: Vector3; add: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3AddValue", dynlib: dynlibLibraryName.}
##  Subtract two vectors

proc subtract*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Subtract", dynlib: dynlibLibraryName.}
##  Subtract vector by float value

proc subtractValue*(v: Vector3; sub: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3SubtractValue", dynlib: dynlibLibraryName.}
##  Multiply vector by scalar

proc scale*(v: Vector3; scalar: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3Scale", dynlib: dynlibLibraryName.}
##  Multiply vector by vector

proc multiply*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Multiply", dynlib: dynlibLibraryName.}
##  Calculate two vectors cross product

proc crossProduct*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3CrossProduct", dynlib: dynlibLibraryName.}
##  Calculate one vector perpendicular vector

proc perpendicular*(v: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Perpendicular", dynlib: dynlibLibraryName.}
##  Calculate vector length

proc length*(v: Vector3): cfloat {.inline, cdecl, importc: "Vector3Length",
                                      dynlib: dynlibLibraryName.}
##  Calculate vector square length

proc lengthSqr*(v: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3LengthSqr", dynlib: dynlibLibraryName.}
##  Calculate two vectors dot product

proc dotProduct*(v1: Vector3; v2: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3DotProduct", dynlib: dynlibLibraryName.}
##  Calculate distance between two vectors

proc distance*(v1: Vector3; v2: Vector3): cfloat {.inline, cdecl,
    importc: "Vector3Distance", dynlib: dynlibLibraryName.}
##  Negate provided vector (invert direction)

proc negate*(v: Vector3): Vector3 {.inline, cdecl, importc: "Vector3Negate",
                                       dynlib: dynlibLibraryName.}
##  Divide vector by vector

proc divide*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Divide", dynlib: dynlibLibraryName.}
##  Normalize provided vector

proc normalize*(v: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Normalize", dynlib: dynlibLibraryName.}
##  Orthonormalize provided vectors
##  Makes vectors normalized and orthogonal to each other
##  Gram-Schmidt function implementation

proc orthoNormalize*(v1: ptr Vector3; v2: ptr Vector3) {.inline, cdecl,
    importc: "Vector3OrthoNormalize", dynlib: dynlibLibraryName.}
##  Transforms a Vector3 by a given Matrix

proc transform*(v: Vector3; mat: Matrix): Vector3 {.inline, cdecl,
    importc: "Vector3Transform", dynlib: dynlibLibraryName.}
##  Transform a vector by quaternion rotation

proc rotateByQuaternion*(v: Vector3; q: Quaternion): Vector3 {.inline, cdecl,
    importc: "Vector3RotateByQuaternion", dynlib: dynlibLibraryName.}
##  Calculate linear interpolation between two vectors

proc lerp*(v1: Vector3; v2: Vector3; amount: cfloat): Vector3 {.inline, cdecl,
    importc: "Vector3Lerp", dynlib: dynlibLibraryName.}
##  Calculate reflected vector to normal

proc reflect*(v: Vector3; normal: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Reflect", dynlib: dynlibLibraryName.}
##  Return min value for each pair of components

proc min*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Min", dynlib: dynlibLibraryName.}
##  Return max value for each pair of components

proc max*(v1: Vector3; v2: Vector3): Vector3 {.inline, cdecl,
    importc: "Vector3Max", dynlib: dynlibLibraryName.}
##  Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
##  NOTE: Assumes P is on the plane of the triangle

proc barycenter*(p: Vector3; a: Vector3; b: Vector3; c: Vector3): Vector3 {.inline,
    cdecl, importc: "Vector3Barycenter", dynlib: dynlibLibraryName.}
##  Returns Vector3 as float array

proc toFloatV*(v: Vector3): Float3 {.inline, cdecl, importc: "Vector3ToFloatV",
                                        dynlib: dynlibLibraryName.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Matrix math
## ----------------------------------------------------------------------------------
##  Compute matrix determinant

proc determinant*(mat: Matrix): cfloat {.inline, cdecl,
    importc: "MatrixDeterminant", dynlib: dynlibLibraryName.}
##  Returns the trace of the matrix (sum of the values along the diagonal)

proc trace*(mat: Matrix): cfloat {.inline, cdecl, importc: "MatrixTrace",
                                     dynlib: dynlibLibraryName.}
##  Transposes provided matrix

proc transpose*(mat: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixTranspose", dynlib: dynlibLibraryName.}
##  Invert provided matrix

proc invert*(mat: Matrix): Matrix {.inline, cdecl, importc: "MatrixInvert",
                                      dynlib: dynlibLibraryName.}
##  Normalize provided matrix

proc normalize*(mat: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixNormalize", dynlib: dynlibLibraryName.}
##  Returns identity matrix

proc matrixIdentity*(): Matrix {.inline, cdecl, importc: "MatrixIdentity",
                              dynlib: dynlibLibraryName.}
##  Add two matrices

proc add*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixAdd", dynlib: dynlibLibraryName.}
##  Subtract two matrices (left - right)

proc subtract*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixSubtract", dynlib: dynlibLibraryName.}
##  Returns two matrix multiplication
##  NOTE: When multiplying matrices... the order matters!

proc multiply*(left: Matrix; right: Matrix): Matrix {.inline, cdecl,
    importc: "MatrixMultiply", dynlib: dynlibLibraryName.}
##  Returns translation matrix

proc translate*(x: cfloat; y: cfloat; z: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixTranslate", dynlib: dynlibLibraryName.}
##  Create rotation matrix from axis and angle
##  NOTE: Angle should be provided in radians

proc rotate*(axis: Vector3; angle: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixRotate", dynlib: dynlibLibraryName.}
##  Returns x-rotation matrix (angle in radians)

proc rotateX*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateX",
    dynlib: dynlibLibraryName.}
##  Returns y-rotation matrix (angle in radians)

proc rotateY*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateY",
    dynlib: dynlibLibraryName.}
##  Returns z-rotation matrix (angle in radians)

proc rotateZ*(angle: cfloat): Matrix {.inline, cdecl, importc: "MatrixRotateZ",
    dynlib: dynlibLibraryName.}
##  Returns xyz-rotation matrix (angles in radians)

proc rotateXYZ*(ang: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixRotateXYZ", dynlib: dynlibLibraryName.}
##  Returns zyx-rotation matrix (angles in radians)

proc rotateZYX*(ang: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixRotateZYX", dynlib: dynlibLibraryName.}
##  Returns scaling matrix

proc scale*(x: cfloat; y: cfloat; z: cfloat): Matrix {.inline, cdecl,
    importc: "MatrixScale", dynlib: dynlibLibraryName.}
##  Returns perspective projection matrix

proc frustum*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
                   near: cdouble; far: cdouble): Matrix {.inline, cdecl,
    importc: "MatrixFrustum", dynlib: dynlibLibraryName.}
##  Returns perspective projection matrix
##  NOTE: Angle should be provided in radians

proc perspective*(fovy: cdouble; aspect: cdouble; near: cdouble; far: cdouble): Matrix {.
    inline, cdecl, importc: "MatrixPerspective", dynlib: dynlibLibraryName.}
##  Returns orthographic projection matrix

proc ortho*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
                 near: cdouble; far: cdouble): Matrix {.inline, cdecl,
    importc: "MatrixOrtho", dynlib: dynlibLibraryName.}
##  Returns camera look-at matrix (view matrix)

proc lookAt*(eye: Vector3; target: Vector3; up: Vector3): Matrix {.inline, cdecl,
    importc: "MatrixLookAt", dynlib: dynlibLibraryName.}
##  Returns float array of matrix data

proc toFloatV*(mat: Matrix): Float16 {.inline, cdecl, importc: "MatrixToFloatV",
    dynlib: dynlibLibraryName.}
## ----------------------------------------------------------------------------------
##  Module Functions Definition - Quaternion math
## ----------------------------------------------------------------------------------
##  Add two quaternions

proc add*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionAdd", dynlib: dynlibLibraryName.}
##  Add quaternion and float value

proc addValue*(q: Quaternion; add: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionAddValue", dynlib: dynlibLibraryName.}
##  Subtract two quaternions

proc subtract*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionSubtract", dynlib: dynlibLibraryName.}
##  Subtract quaternion and float value

proc subtractValue*(q: Quaternion; sub: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionSubtractValue", dynlib: dynlibLibraryName.}
##  Returns identity quaternion

proc quaternionIdentity*(): Quaternion {.inline, cdecl,
                                      importc: "QuaternionIdentity",
                                      dynlib: dynlibLibraryName.}
##  Computes the length of a quaternion

proc length*(q: Quaternion): cfloat {.inline, cdecl,
    importc: "QuaternionLength", dynlib: dynlibLibraryName.}
##  Normalize provided quaternion

proc normalize*(q: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionNormalize", dynlib: dynlibLibraryName.}
##  Invert provided quaternion

proc invert*(q: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionInvert", dynlib: dynlibLibraryName.}
##  Calculate two quaternion multiplication

proc multiply*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionMultiply", dynlib: dynlibLibraryName.}
##  Scale quaternion by float value

proc scale*(q: Quaternion; mul: cfloat): Quaternion {.inline, cdecl,
    importc: "QuaternionScale", dynlib: dynlibLibraryName.}
##  Divide two quaternions

proc divide*(q1: Quaternion; q2: Quaternion): Quaternion {.inline, cdecl,
    importc: "QuaternionDivide", dynlib: dynlibLibraryName.}
##  Calculate linear interpolation between two quaternions

proc lerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionLerp", dynlib: dynlibLibraryName.}
##  Calculate slerp-optimized interpolation between two quaternions

proc nlerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionNlerp", dynlib: dynlibLibraryName.}
##  Calculates spherical linear interpolation between two quaternions

proc slerp*(q1: Quaternion; q2: Quaternion; amount: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionSlerp", dynlib: dynlibLibraryName.}
##  Calculate quaternion based on the rotation from one vector to another

proc fromVector3ToVector3*(`from`: Vector3; to: Vector3): Quaternion {.
    inline, cdecl, importc: "QuaternionFromVector3ToVector3",
    dynlib: dynlibLibraryName.}
##  Returns a quaternion for a given rotation matrix

proc fromMatrix*(mat: Matrix): Quaternion {.inline, cdecl,
    importc: "QuaternionFromMatrix", dynlib: dynlibLibraryName.}
##  Returns a matrix for a given quaternion

proc toMatrix*(q: Quaternion): Matrix {.inline, cdecl,
    importc: "QuaternionToMatrix", dynlib: dynlibLibraryName.}
##  Returns rotation quaternion for an angle and axis
##  NOTE: angle must be provided in radians

proc fromAxisAngle*(axis: Vector3; angle: cfloat): Quaternion {.inline,
    cdecl, importc: "QuaternionFromAxisAngle", dynlib: dynlibLibraryName.}
##  Returns the rotation angle and axis for a given quaternion

proc toAxisAngle*(q: Quaternion; outAxis: ptr Vector3; outAngle: ptr cfloat) {.
    inline, cdecl, importc: "QuaternionToAxisAngle", dynlib: dynlibLibraryName.}
##  Returns the quaternion equivalent to Euler angles
##  NOTE: Rotation order is ZYX

proc fromEuler*(pitch: cfloat; yaw: cfloat; roll: cfloat): Quaternion {.
    inline, cdecl, importc: "QuaternionFromEuler", dynlib: dynlibLibraryName.}
##  Return the Euler angles equivalent to quaternion (roll, pitch, yaw)
##  NOTE: Angles are returned in a Vector3 struct in degrees

proc toEuler*(q: Quaternion): Vector3 {.inline, cdecl,
    importc: "QuaternionToEuler", dynlib: dynlibLibraryName.}
##  Transform a quaternion given a transformation matrix

proc transform*(q: Quaternion; mat: Matrix): Quaternion {.inline, cdecl,
    importc: "QuaternionTransform", dynlib: dynlibLibraryName.}
##  Projects a Vector3 from screen space into object space

proc unproject*(source: Vector3; projection: Matrix; view: Matrix): Vector3 {.
    inline, cdecl, importc: "Vector3Unproject", dynlib: dynlibLibraryName.}

template `+`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = addValue(v1, value)
template `+=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = addValue(v1, value)

template `-`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = subtractValue(v1, value)
template `-=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = scale(v1, value)
template `*=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = scale(v1, value)

template `/`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: cfloat): T = scale(v1, 1.0/value)
template `/=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: cfloat) = v1 = scale(v1, 1.0/value)

template `-`*[T: Vector2 | Vector3](v1: T): T = negate(v1)
