 {.deadCodeElim: on.}
when defined(windows):
  const
    raylibdll* = "libraylib.dll"
elif defined(macosx):
  const
    raylibdll* = "libraylib.dylib"
else:
  const
    raylibdll* = "libraylib.so"
import raylib
## *********************************************************************************************
##
##    rlgl v3.1 - raylib OpenGL abstraction layer
##
##    rlgl is a wrapper for multiple OpenGL versions (1.1, 2.1, 3.3 Core, ES 2.0) to
##    pseudo-OpenGL 1.1 style functions (rlVertex, rlTranslate, rlRotate...).
##
##    When chosing an OpenGL version greater than OpenGL 1.1, rlgl stores vertex data on internal
##    VBO buffers (and VAOs if available). It requires calling 3 functions:
##        rlglInit()  - Initialize internal buffers and auxiliar resources
##        rlglDraw()  - Process internal buffers and send required draw calls
##        rlglClose() - De-initialize internal buffers data and other auxiliar resources
##
##    CONFIGURATION:
##
##    #define GRAPHICS_API_OPENGL_11
##    #define GRAPHICS_API_OPENGL_21
##    #define GRAPHICS_API_OPENGL_33
##    #define GRAPHICS_API_OPENGL_ES2
##        Use selected OpenGL graphics backend, should be supported by platform
##        Those preprocessor defines are only used on rlgl module, if OpenGL version is
##        required by any other module, use rlGetVersion() tocheck it
##
##    #define RLGL_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RLGL_STANDALONE
##        Use rlgl as standalone library (no raylib dependency)
##
##    #define SUPPORT_VR_SIMULATOR
##        Support VR simulation functionality (stereo rendering)
##
##    DEPENDENCIES:
##        raymath     - 3D math functionality (Vector3, Matrix, Quaternion)
##        GLAD        - OpenGL extensions loading (OpenGL 3.3 Core only)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
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

##  Security check in case no GRAPHICS_API_OPENGL_* defined
##  Security check in case multiple GRAPHICS_API_OPENGL_* defined

const
  SUPPORT_RENDER_TEXTURES_HINT* = true

## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Default internal render batch limits
##  Internal Matrix stack
##  Shader and material limits
##  Projection matrix culling
##  Texture parameters (equivalent to OpenGL defines)

const
  TEXTURE_WRAP_S* = 0x00002802
  TEXTURE_WRAP_T* = 0x00002803
  TEXTURE_MAG_FILTER* = 0x00002800
  TEXTURE_MIN_FILTER* = 0x00002801
  TEXTURE_ANISOTROPIC_FILTER* = 0x00003000
  FILTER_NEAREST* = 0x00002600
  FILTER_LINEAR* = 0x00002601
  FILTER_MIP_NEAREST* = 0x00002700
  FILTER_NEAREST_MIP_LINEAR* = 0x00002702
  FILTER_LINEAR_MIP_NEAREST* = 0x00002701
  FILTER_MIP_LINEAR* = 0x00002703
  WRAP_REPEAT* = 0x00002901
  WRAP_CLAMP* = 0x0000812F
  WRAP_MIRROR_REPEAT* = 0x00008370
  WRAP_MIRROR_CLAMP* = 0x00008742

##  Matrix modes (equivalent to OpenGL)

const
  MODELVIEW* = 0x00001700
  PROJECTION* = 0x00001701
  TEXTURE* = 0x00001702

##  Primitive assembly draw modes

const
  LINES* = 0x00000001
  TRIANGLES* = 0x00000004
  QUADS* = 0x00000007

## ----------------------------------------------------------------------------------
##  Types and Structures Definition
## ----------------------------------------------------------------------------------

type
  GlVersion* {.size: sizeof(int32), pure.} = enum
    OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_ES_20
  FramebufferAttachType* {.size: sizeof(int32), pure.} = enum
    ATTACHMENT_COLOR_CHANNEL0 = 0, ATTACHMENT_COLOR_CHANNEL1,
    ATTACHMENT_COLOR_CHANNEL2, ATTACHMENT_COLOR_CHANNEL3,
    ATTACHMENT_COLOR_CHANNEL4, ATTACHMENT_COLOR_CHANNEL5,
    ATTACHMENT_COLOR_CHANNEL6, ATTACHMENT_COLOR_CHANNEL7, ATTACHMENT_DEPTH = 100,
    ATTACHMENT_STENCIL = 200
  FramebufferTexType* {.size: sizeof(int32), pure.} = enum
    ATTACHMENT_CUBEMAP_POSITIVE_X = 0, ATTACHMENT_CUBEMAP_NEGATIVE_X,
    ATTACHMENT_CUBEMAP_POSITIVE_Y, ATTACHMENT_CUBEMAP_NEGATIVE_Y,
    ATTACHMENT_CUBEMAP_POSITIVE_Z, ATTACHMENT_CUBEMAP_NEGATIVE_Z,
    ATTACHMENT_TEXTURE2D = 100, ATTACHMENT_RENDERBUFFER = 200




## ------------------------------------------------------------------------------------
##  Functions Declaration - Matrix operations
## ------------------------------------------------------------------------------------

proc matrixMode*(mode: int32) {.cdecl, importc: "rlMatrixMode", dynlib: raylibdll.}
##  Choose the current matrix to be transformed

proc pushMatrix*() {.cdecl, importc: "rlPushMatrix", dynlib: raylibdll.}
##  Push the current matrix to stack

proc popMatrix*() {.cdecl, importc: "rlPopMatrix", dynlib: raylibdll.}
##  Pop lattest inserted matrix from stack

proc loadIdentity*() {.cdecl, importc: "rlLoadIdentity", dynlib: raylibdll.}
##  Reset current matrix to identity matrix

proc translatef*(x: float32; y: float32; z: float32) {.cdecl, importc: "rlTranslatef",
    dynlib: raylibdll.}
##  Multiply the current matrix by a translation matrix

proc rotatef*(angleDeg: float32; x: float32; y: float32; z: float32) {.cdecl,
    importc: "rlRotatef", dynlib: raylibdll.}
##  Multiply the current matrix by a rotation matrix

proc scalef*(x: float32; y: float32; z: float32) {.cdecl, importc: "rlScalef",
    dynlib: raylibdll.}
##  Multiply the current matrix by a scaling matrix

proc multMatrixf*(matf: ptr float32) {.cdecl, importc: "rlMultMatrixf",
                                  dynlib: raylibdll.}
##  Multiply the current matrix by another matrix

proc frustum*(left: float64; right: float64; bottom: float64; top: float64;
             znear: float64; zfar: float64) {.cdecl, importc: "rlFrustum",
    dynlib: raylibdll.}
proc ortho*(left: float64; right: float64; bottom: float64; top: float64; znear: float64;
           zfar: float64) {.cdecl, importc: "rlOrtho", dynlib: raylibdll.}
proc viewport*(x: int32; y: int32; width: int32; height: int32) {.cdecl,
    importc: "rlViewport", dynlib: raylibdll.}
##  Set the viewport area
## ------------------------------------------------------------------------------------
##  Functions Declaration - Vertex level operations
## ------------------------------------------------------------------------------------

proc begin*(mode: int32) {.cdecl, importc: "rlBegin", dynlib: raylibdll.}
##  Initialize drawing mode (how to organize vertex)

proc `end`*() {.cdecl, importc: "rlEnd", dynlib: raylibdll.}
##  Finish vertex providing

proc vertex2i*(x: int32; y: int32) {.cdecl, importc: "rlVertex2i", dynlib: raylibdll.}
##  Define one vertex (position) - 2 int

proc vertex2f*(x: float32; y: float32) {.cdecl, importc: "rlVertex2f", dynlib: raylibdll.}
##  Define one vertex (position) - 2 float

proc vertex3f*(x: float32; y: float32; z: float32) {.cdecl, importc: "rlVertex3f",
    dynlib: raylibdll.}
##  Define one vertex (position) - 3 float

proc texCoord2f*(x: float32; y: float32) {.cdecl, importc: "rlTexCoord2f",
                                    dynlib: raylibdll.}
##  Define one vertex (texture coordinate) - 2 float

proc normal3f*(x: float32; y: float32; z: float32) {.cdecl, importc: "rlNormal3f",
    dynlib: raylibdll.}
##  Define one vertex (normal) - 3 float

proc color4ub*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl, importc: "rlColor4ub",
    dynlib: raylibdll.}
##  Define one vertex (color) - 4 byte

proc color3f*(x: float32; y: float32; z: float32) {.cdecl, importc: "rlColor3f",
    dynlib: raylibdll.}
##  Define one vertex (color) - 3 float

proc color4f*(x: float32; y: float32; z: float32; w: float32) {.cdecl, importc: "rlColor4f",
    dynlib: raylibdll.}
##  Define one vertex (color) - 4 float
## ------------------------------------------------------------------------------------
##  Functions Declaration - OpenGL equivalent functions (common to 1.1, 3.3+, ES2)
##  NOTE: This functions are used to completely abstract raylib code from OpenGL layer
## ------------------------------------------------------------------------------------

proc enableTexture*(id: uint32) {.cdecl, importc: "rlEnableTexture", dynlib: raylibdll.}
##  Enable texture usage

proc disableTexture*() {.cdecl, importc: "rlDisableTexture", dynlib: raylibdll.}
##  Disable texture usage

proc textureParameters*(id: uint32; param: int32; value: int32) {.cdecl,
    importc: "rlTextureParameters", dynlib: raylibdll.}
##  Set texture parameters (filter, wrap)

proc enableShader*(id: uint32) {.cdecl, importc: "rlEnableShader", dynlib: raylibdll.}
##  Enable shader program usage

proc disableShader*() {.cdecl, importc: "rlDisableShader", dynlib: raylibdll.}
##  Disable shader program usage

proc enableFramebuffer*(id: uint32) {.cdecl, importc: "rlEnableFramebuffer",
                                  dynlib: raylibdll.}
##  Enable render texture (fbo)

proc disableFramebuffer*() {.cdecl, importc: "rlDisableFramebuffer",
                           dynlib: raylibdll.}
##  Disable render texture (fbo), return to default framebuffer

proc enableDepthTest*() {.cdecl, importc: "rlEnableDepthTest", dynlib: raylibdll.}
##  Enable depth test

proc disableDepthTest*() {.cdecl, importc: "rlDisableDepthTest", dynlib: raylibdll.}
##  Disable depth test

proc enableDepthMask*() {.cdecl, importc: "rlEnableDepthMask", dynlib: raylibdll.}
##  Enable depth write

proc disableDepthMask*() {.cdecl, importc: "rlDisableDepthMask", dynlib: raylibdll.}
##  Disable depth write

proc enableBackfaceCulling*() {.cdecl, importc: "rlEnableBackfaceCulling",
                              dynlib: raylibdll.}
##  Enable backface culling

proc disableBackfaceCulling*() {.cdecl, importc: "rlDisableBackfaceCulling",
                               dynlib: raylibdll.}
##  Disable backface culling

proc enableScissorTest*() {.cdecl, importc: "rlEnableScissorTest", dynlib: raylibdll.}
##  Enable scissor test

proc disableScissorTest*() {.cdecl, importc: "rlDisableScissorTest",
                           dynlib: raylibdll.}
##  Disable scissor test

proc scissor*(x: int32; y: int32; width: int32; height: int32) {.cdecl, importc: "rlScissor",
    dynlib: raylibdll.}
##  Scissor test

proc enableWireMode*() {.cdecl, importc: "rlEnableWireMode", dynlib: raylibdll.}
##  Enable wire mode

proc disableWireMode*() {.cdecl, importc: "rlDisableWireMode", dynlib: raylibdll.}
##  Disable wire mode

proc setLineWidth*(width: float32) {.cdecl, importc: "rlSetLineWidth",
                                 dynlib: raylibdll.}
##  Set the line drawing width

proc getLineWidth*(): float32 {.cdecl, importc: "rlGetLineWidth", dynlib: raylibdll.}
##  Get the line drawing width

proc enableSmoothLines*() {.cdecl, importc: "rlEnableSmoothLines", dynlib: raylibdll.}
##  Enable line aliasing

proc disableSmoothLines*() {.cdecl, importc: "rlDisableSmoothLines",
                           dynlib: raylibdll.}
##  Disable line aliasing

proc clearColor*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl,
    importc: "rlClearColor", dynlib: raylibdll.}
##  Clear color buffer with color

proc clearScreenBuffers*() {.cdecl, importc: "rlClearScreenBuffers",
                           dynlib: raylibdll.}
##  Clear used screen buffers (color and depth)

proc updateBuffer*(bufferId: int32; data: pointer; dataSize: int32) {.cdecl,
    importc: "rlUpdateBuffer", dynlib: raylibdll.}
##  Update GPU buffer with new data

proc loadAttribBuffer*(vaoId: uint32; shaderLoc: int32; buffer: pointer; size: int32;
                      dynamic: bool): uint32 {.cdecl, importc: "rlLoadAttribBuffer",
    dynlib: raylibdll.}
##  Load a new attributes buffer
## ------------------------------------------------------------------------------------
##  Functions Declaration - rlgl functionality
## ------------------------------------------------------------------------------------

proc init*(width: int32; height: int32) {.cdecl, importc: "rlglInit", dynlib: raylibdll.}
##  Initialize rlgl (buffers, shaders, textures, states)

proc close*() {.cdecl, importc: "rlglClose", dynlib: raylibdll.}
##  De-inititialize rlgl (buffers, shaders, textures)

proc draw*() {.cdecl, importc: "rlglDraw", dynlib: raylibdll.}
##  Update and draw default internal buffers

proc checkErrors*() {.cdecl, importc: "rlCheckErrors", dynlib: raylibdll.}
##  Check and log OpenGL error codes

proc getVersion*(): int32 {.cdecl, importc: "rlGetVersion", dynlib: raylibdll.}
##  Returns current OpenGL version

proc checkBufferLimit*(vCount: int32): bool {.cdecl, importc: "rlCheckBufferLimit",
    dynlib: raylibdll.}
##  Check internal buffer overflow for a given number of vertex

proc setDebugMarker*(text: cstring) {.cdecl, importc: "rlSetDebugMarker",
                                   dynlib: raylibdll.}
##  Set debug marker for analysis

proc setBlendMode*(glSrcFactor: int32; glDstFactor: int32; glEquation: int32) {.cdecl,
    importc: "rlSetBlendMode", dynlib: raylibdll.}
##  // Set blending mode factor and equation (using OpenGL factors)

proc loadExtensions*(loader: pointer) {.cdecl, importc: "rlLoadExtensions",
                                     dynlib: raylibdll.}
##  Load OpenGL extensions
##  Textures data management

proc loadTexture*(data: pointer; width: int32; height: int32; format: int32;
                 mipmapCount: int32): uint32 {.cdecl, importc: "rlLoadTexture",
    dynlib: raylibdll.}
##  Load texture in GPU

proc loadTextureDepth*(width: int32; height: int32; useRenderBuffer: bool): uint32 {.cdecl,
    importc: "rlLoadTextureDepth", dynlib: raylibdll.}
##  Load depth texture/renderbuffer (to be attached to fbo)

proc loadTextureCubemap*(data: pointer; size: int32; format: int32): uint32 {.cdecl,
    importc: "rlLoadTextureCubemap", dynlib: raylibdll.}
##  Load texture cubemap

proc updateTexture*(id: uint32; offsetX: int32; offsetY: int32; width: int32; height: int32;
                   format: int32; data: pointer) {.cdecl, importc: "rlUpdateTexture",
    dynlib: raylibdll.}
##  Update GPU texture with new data

proc getGlTextureFormats*(format: int32; glInternalFormat: ptr uint32;
                         glFormat: ptr uint32; glType: ptr uint32) {.cdecl,
    importc: "rlGetGlTextureFormats", dynlib: raylibdll.}
##  Get OpenGL internal formats

proc unloadTexture*(id: uint32) {.cdecl, importc: "rlUnloadTexture", dynlib: raylibdll.}
##  Unload texture from GPU memory

proc generateMipmaps*(texture: ptr Texture2D) {.cdecl, importc: "rlGenerateMipmaps",
    dynlib: raylibdll.}
##  Generate mipmap data for selected texture

proc readTexturePixels*(texture: Texture2D): pointer {.cdecl,
    importc: "rlReadTexturePixels", dynlib: raylibdll.}
##  Read texture pixel data

proc readScreenPixels*(width: int32; height: int32): ptr uint8 {.cdecl,
    importc: "rlReadScreenPixels", dynlib: raylibdll.}
##  Read screen pixel data (color buffer)
##  Framebuffer management (fbo)

proc loadFramebuffer*(width: int32; height: int32): uint32 {.cdecl,
    importc: "rlLoadFramebuffer", dynlib: raylibdll.}
##  Load an empty framebuffer

proc framebufferAttach*(fboId: uint32; texId: uint32; attachType: int32; texType: int32) {.
    cdecl, importc: "rlFramebufferAttach", dynlib: raylibdll.}
##  Attach texture/renderbuffer to a framebuffer

proc framebufferComplete*(id: uint32): bool {.cdecl, importc: "rlFramebufferComplete",
    dynlib: raylibdll.}
##  Verify framebuffer is complete

proc unloadFramebuffer*(id: uint32) {.cdecl, importc: "rlUnloadFramebuffer",
                                  dynlib: raylibdll.}
##  Delete framebuffer from GPU
##  Vertex data management

proc loadMesh*(mesh: ptr Mesh; dynamic: bool) {.cdecl, importc: "rlLoadMesh",
    dynlib: raylibdll.}
##  Upload vertex data into GPU and provided VAO/VBO ids

proc updateMesh*(mesh: Mesh; buffer: int32; count: int32) {.cdecl,
    importc: "rlUpdateMesh", dynlib: raylibdll.}
##  Update vertex or index data on GPU (upload new data to one buffer)

proc updateMeshAt*(mesh: Mesh; buffer: int32; count: int32; index: int32) {.cdecl,
    importc: "rlUpdateMeshAt", dynlib: raylibdll.}
##  Update vertex or index data on GPU, at index

proc drawMesh*(mesh: Mesh; material: Material; transform: Matrix) {.cdecl,
    importc: "rlDrawMesh", dynlib: raylibdll.}
##  Draw a 3d mesh with material and transform

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: ptr Matrix;
                       count: int32) {.cdecl, importc: "rlDrawMeshInstanced",
                                    dynlib: raylibdll.}
##  Draw a 3d mesh with material and transform

proc unloadMesh*(mesh: Mesh) {.cdecl, importc: "rlUnloadMesh", dynlib: raylibdll.}
##  Unload mesh data from CPU and GPU
##  NOTE: There is a set of shader related functions that are available to end user,
##  to avoid creating function wrappers through core module, they have been directly declared in raylib.h

converter GlVersionToInt32*(self: GlVersion): int32 = self.int32
converter FramebufferAttachTypeToInt32*(self: FramebufferAttachType): int32 = self.int32
converter FramebufferTexTypeToInt32*(self: FramebufferTexType): int32 = self.int32

