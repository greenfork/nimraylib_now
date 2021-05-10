# Functions on C varargs
# Used only for TraceLogCallback type, see core_custom_logging example
type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object
proc vprintf*(format: cstring, args: va_list) {.cdecl, importc: "vprintf", header: "<stdio.h>"}

from os import parentDir, `/`
const raylibHeader = currentSourcePath().parentDir()/"raylib.h"

when defined(emscripten):
  type emCallbackFunc* = proc() {.cdecl.}
  proc emscriptenSetMainLoop*(f: emCallbackFunc, fps: cint, simulateInfiniteLoop: cint) {.
    cdecl, importc: "emscripten_set_main_loop", header: "<emscripten.h>".}

when not defined(nimraylib_now_linkingOverride):
  when defined(nimraylib_now_shared):
    when defined(windows):
      when defined(vcc):
        {.passL:"raylibdll.lib".}
      else:
        {.passL:"libraylibdll.a".}
    else:
      {.passL:"-lraylib".}
  else:
    include ../raylib_build_static

## *********************************************************************************************
##
##    raylib - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
##
##    FEATURES:
##        - NO external dependencies, all required libraries included with raylib
##        - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
##                         MacOS, Haiku, UWP, Android, Raspberry Pi, HTML5.
##        - Written in plain C code (C99) in PascalCase/camelCase notation
##        - Hardware accelerated with OpenGL (1.1, 2.1, 3.3 or ES2 - choose at compile)
##        - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
##        - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
##        - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
##        - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
##        - Flexible Materials system, supporting classic maps and PBR maps
##        - Animated 3D models supported (skeletal bones animation) (IQM, glTF)
##        - Shaders support, including Model shaders and Postprocessing shaders
##        - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
##        - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
##        - VR stereo rendering with configurable HMD device parameters
##        - Bindings to multiple programming languages available!
##
##    NOTES:
##        One default Font is loaded on InitWindow()->LoadFontDefault() [core, text]
##        One default Texture2D is loaded on rlglInit() [rlgl] (OpenGL 3.3 or ES2)
##        One default Shader is loaded on rlglInit()->rlLoadShaderDefault() [rlgl] (OpenGL 3.3 or ES2)
##        One default RenderBatch is loaded on rlglInit()->rlLoadRenderBatch() [rlgl] (OpenGL 3.3 or ES2)
##
##    DEPENDENCIES (included):
##        [core] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input (PLATFORM_DESKTOP)
##        [rlgl] glad (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (PLATFORM_DESKTOP)
##        [raudio] miniaudio (David Reid - github.com/dr-soft/miniaudio) for audio device/context management
##
##    OPTIONAL DEPENDENCIES (included):
##        [core] msf_gif (Miles Fogle) for GIF recording
##        [core] sinfl (Micha Mettke) for DEFLATE decompression algorythm
##        [core] sdefl (Micha Mettke) for DEFLATE compression algorythm
##        [textures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
##        [textures] stb_image_write (Sean Barret) for image writting (BMP, TGA, PNG, JPG)
##        [textures] stb_image_resize (Sean Barret) for image resizing algorithms
##        [textures] stb_perlin (Sean Barret) for Perlin noise image generation
##        [text] stb_truetype (Sean Barret) for ttf fonts loading
##        [text] stb_rect_pack (Sean Barret) for rectangles packing
##        [models] par_shapes (Philip Rideout) for parametric 3d shapes generation
##        [models] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
##        [models] cgltf (Johannes Kuhlmann) for models loading (glTF)
##        [raudio] dr_wav (David Reid) for WAV audio file loading
##        [raudio] dr_flac (David Reid) for FLAC audio file loading
##        [raudio] dr_mp3 (David Reid) for MP3 audio file loading
##        [raudio] stb_vorbis (Sean Barret) for OGG audio loading
##        [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
##        [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
##
##
##    LICENSE: zlib/libpng
##
##    raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
##    BSD-like license that allows static linking with closed source software:
##
##    Copyright (c) 2013-2021 Ramon Santamaria (@raysan5)
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

const
  RAYLIB_VERSION* = "3.7.0"

## ----------------------------------------------------------------------------------
##  Some basic Defines
## ----------------------------------------------------------------------------------
##  Allow custom memory allocators
##  NOTE: MSVC C++ compiler does not support compound literals (C99 feature)
##  Plain structures in C++ (without constructors) can be initialized from { } initializers.
##  Some Basic Colors
##  NOTE: Custom raylib color palette for amazing visuals on WHITE background
##  Temporal hacks to avoid breaking old codebases using
##  deprecated raylib implementation or definitions
## ----------------------------------------------------------------------------------
##  Structures Definition
## ----------------------------------------------------------------------------------
##  Boolean type
##  Vector2 type

type
  Vector2* {.importc: "Vector2", header: raylibHeader, bycopy.} = object
    x* {.importc: "x".}: cfloat
    y* {.importc: "y".}: cfloat


##  Vector3 type

type
  Vector3* {.importc: "Vector3", header: raylibHeader, bycopy.} = object
    x* {.importc: "x".}: cfloat
    y* {.importc: "y".}: cfloat
    z* {.importc: "z".}: cfloat


##  Vector4 type

type
  Vector4* {.importc: "Vector4", header: raylibHeader, bycopy.} = object
    x* {.importc: "x".}: cfloat
    y* {.importc: "y".}: cfloat
    z* {.importc: "z".}: cfloat
    w* {.importc: "w".}: cfloat


##  Quaternion type, same as Vector4

type
  Quaternion* = Vector4

##  Matrix type (OpenGL style 4x4 - right handed, column major)

type
  Matrix* {.importc: "Matrix", header: raylibHeader, bycopy.} = object
    m0* {.importc: "m0".}: cfloat
    m4* {.importc: "m4".}: cfloat
    m8* {.importc: "m8".}: cfloat
    m12* {.importc: "m12".}: cfloat
    m1* {.importc: "m1".}: cfloat
    m5* {.importc: "m5".}: cfloat
    m9* {.importc: "m9".}: cfloat
    m13* {.importc: "m13".}: cfloat
    m2* {.importc: "m2".}: cfloat
    m6* {.importc: "m6".}: cfloat
    m10* {.importc: "m10".}: cfloat
    m14* {.importc: "m14".}: cfloat
    m3* {.importc: "m3".}: cfloat
    m7* {.importc: "m7".}: cfloat
    m11* {.importc: "m11".}: cfloat
    m15* {.importc: "m15".}: cfloat


##  Color type, RGBA (32bit)

type
  Color* {.importc: "Color", header: raylibHeader, bycopy.} = object
    r* {.importc: "r".}: uint8
    g* {.importc: "g".}: uint8
    b* {.importc: "b".}: uint8
    a* {.importc: "a".}: uint8


##  NmrlbNow_Rectangle type

type
  Rectangle* {.importc: "NmrlbNow_Rectangle", header: raylibHeader, bycopy.} = object
    x* {.importc: "x".}: cfloat
    y* {.importc: "y".}: cfloat
    width* {.importc: "width".}: cfloat
    height* {.importc: "height".}: cfloat


##  Image type, bpp always RGBA (32bit)
##  NOTE: Data stored in CPU memory (RAM)

type
  Image* {.importc: "Image", header: raylibHeader, bycopy.} = object
    data* {.importc: "data".}: pointer ##  Image raw data
    width* {.importc: "width".}: cint ##  Image base width
    height* {.importc: "height".}: cint ##  Image base height
    mipmaps* {.importc: "mipmaps".}: cint ##  Mipmap levels, 1 by default
    format* {.importc: "format".}: cint ##  Data format (PixelFormat type)


##  Texture type
##  NOTE: Data stored in GPU memory

type
  Texture* {.importc: "Texture", header: raylibHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  OpenGL texture id
    width* {.importc: "width".}: cint ##  Texture base width
    height* {.importc: "height".}: cint ##  Texture base height
    mipmaps* {.importc: "mipmaps".}: cint ##  Mipmap levels, 1 by default
    format* {.importc: "format".}: cint ##  Data format (PixelFormat type)


##  Texture2D type, same as Texture

type
  Texture2D* = Texture

##  TextureCubemap type, actually, same as Texture

type
  TextureCubemap* = Texture

##  RenderTexture type, for texture rendering

type
  RenderTexture* {.importc: "RenderTexture", header: raylibHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  OpenGL framebuffer object id
    texture* {.importc: "texture".}: Texture ##  Color buffer attachment texture
    depth* {.importc: "depth".}: Texture ##  Depth buffer attachment texture


##  RenderTexture2D type, same as RenderTexture

type
  RenderTexture2D* = RenderTexture

##  N-Patch layout info

type
  NPatchInfo* {.importc: "NPatchInfo", header: raylibHeader, bycopy.} = object
    source* {.importc: "source".}: Rectangle ##  Texture source rectangle
    left* {.importc: "left".}: cint ##  Left border offset
    top* {.importc: "top".}: cint ##  Top border offset
    right* {.importc: "right".}: cint ##  Right border offset
    bottom* {.importc: "bottom".}: cint ##  Bottom border offset
    layout* {.importc: "layout".}: cint ##  Layout of the n-patch: 3x3, 1x3 or 3x1


##  Font character info

type
  CharInfo* {.importc: "CharInfo", header: raylibHeader, bycopy.} = object
    value* {.importc: "value".}: cint ##  Character value (Unicode)
    offsetX* {.importc: "offsetX".}: cint ##  Character offset X when drawing
    offsetY* {.importc: "offsetY".}: cint ##  Character offset Y when drawing
    advanceX* {.importc: "advanceX".}: cint ##  Character advance position X
    image* {.importc: "image".}: Image ##  Character image data


##  Font type, includes texture and charSet array data

type
  Font* {.importc: "Font", header: raylibHeader, bycopy.} = object
    baseSize* {.importc: "baseSize".}: cint ##  Base size (default chars height)
    charsCount* {.importc: "charsCount".}: cint ##  Number of characters
    charsPadding* {.importc: "charsPadding".}: cint ##  Padding around the chars
    texture* {.importc: "texture".}: Texture2D ##  Characters texture atlas
    recs* {.importc: "recs".}: ptr Rectangle ##  Characters rectangles in texture
    chars* {.importc: "chars".}: ptr CharInfo ##  Characters info data


##  Camera type, defines a camera position/orientation in 3d space

type
  Camera3D* {.importc: "Camera3D", header: raylibHeader, bycopy.} = object
    position* {.importc: "position".}: Vector3 ##  Camera position
    target* {.importc: "target".}: Vector3 ##  Camera target it looks-at
    up* {.importc: "up".}: Vector3 ##  Camera up vector (rotation over its axis)
    fovy* {.importc: "fovy".}: cfloat ##  Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    projection* {.importc: "projection".}: cint ##  Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

  Camera* = Camera3D

##  Camera type fallback, defaults to Camera3D
##  Camera2D type, defines a 2d camera

type
  Camera2D* {.importc: "Camera2D", header: raylibHeader, bycopy.} = object
    offset* {.importc: "offset".}: Vector2 ##  Camera offset (displacement from target)
    target* {.importc: "target".}: Vector2 ##  Camera target (rotation and zoom origin)
    rotation* {.importc: "rotation".}: cfloat ##  Camera rotation in degrees
    zoom* {.importc: "zoom".}: cfloat ##  Camera zoom (scaling), should be 1.0f by default


##  Vertex data definning a mesh
##  NOTE: Data stored in CPU memory (and GPU)

type
  Mesh* {.importc: "Mesh", header: raylibHeader, bycopy.} = object
    vertexCount* {.importc: "vertexCount".}: cint ##  Number of vertices stored in arrays
    triangleCount* {.importc: "triangleCount".}: cint ##  Number of triangles stored (indexed or not)
                                                  ##  Default vertex data
    vertices* {.importc: "vertices".}: ptr cfloat ##  Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords* {.importc: "texcoords".}: ptr cfloat ##  Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2* {.importc: "texcoords2".}: ptr cfloat ##  Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals* {.importc: "normals".}: ptr cfloat ##  Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents* {.importc: "tangents".}: ptr cfloat ##  Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors* {.importc: "colors".}: ptr uint8 ##  Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices* {.importc: "indices".}: ptr cushort ##  Vertex indices (in case vertex data comes indexed)
                                            ##  Animation vertex data
    animVertices* {.importc: "animVertices".}: ptr cfloat ##  Animated vertex positions (after bones transformations)
    animNormals* {.importc: "animNormals".}: ptr cfloat ##  Animated normals (after bones transformations)
    boneIds* {.importc: "boneIds".}: ptr cint ##  Vertex bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights* {.importc: "boneWeights".}: ptr cfloat ##  Vertex bone weight, up to 4 bones influence by vertex (skinning)
                                                   ##  OpenGL identifiers
    vaoId* {.importc: "vaoId".}: cuint ##  OpenGL Vertex Array Object id
    vboId* {.importc: "vboId".}: ptr cuint ##  OpenGL Vertex Buffer Objects id (default vertex data)


##  Shader type (generic)

type
  Shader* {.importc: "Shader", header: raylibHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  Shader program id
    locs* {.importc: "locs".}: ptr UncheckedArray[cint] ##  Shader locations array (MAX_SHADER_LOCATIONS)


##  Material texture map

type
  MaterialMap* {.importc: "MaterialMap", header: raylibHeader, bycopy.} = object
    texture* {.importc: "texture".}: Texture2D ##  Material map texture
    color* {.importc: "color".}: Color ##  Material map color
    value* {.importc: "value".}: cfloat ##  Material map value


##  Material type (generic)

type
  Material* {.importc: "Material", header: raylibHeader, bycopy.} = object
    shader* {.importc: "shader".}: Shader ##  Material shader
    maps* {.importc: "maps".}: ptr UncheckedArray[MaterialMap] ##  Material maps array (MAX_MATERIAL_MAPS)
    params* {.importc: "params".}: array[4, cfloat] ##  Material generic parameters (if required)


##  Transformation properties

type
  Transform* {.importc: "Transform", header: raylibHeader, bycopy.} = object
    translation* {.importc: "translation".}: Vector3 ##  Translation
    rotation* {.importc: "rotation".}: Quaternion ##  Rotation
    scale* {.importc: "scale".}: Vector3 ##  Scale


##  Bone information

type
  BoneInfo* {.importc: "BoneInfo", header: raylibHeader, bycopy.} = object
    name* {.importc: "name".}: array[32, char] ##  Bone name
    parent* {.importc: "parent".}: cint ##  Bone parent


##  Model type

type
  Model* {.importc: "Model", header: raylibHeader, bycopy.} = object
    transform* {.importc: "transform".}: Matrix ##  Local transform matrix
    meshCount* {.importc: "meshCount".}: cint ##  Number of meshes
    materialCount* {.importc: "materialCount".}: cint ##  Number of materials
    meshes* {.importc: "meshes".}: ptr UncheckedArray[Mesh] ##  Meshes array
    materials* {.importc: "materials".}: ptr UncheckedArray[Material] ##  Materials array
    meshMaterial* {.importc: "meshMaterial".}: ptr UncheckedArray[cint] ##  Mesh material number
                                                   ##  Animation data
    boneCount* {.importc: "boneCount".}: cint ##  Number of bones
    bones* {.importc: "bones".}: ptr BoneInfo ##  Bones information (skeleton)
    bindPose* {.importc: "bindPose".}: ptr Transform ##  Bones base transformation (pose)


##  Model animation

type
  ModelAnimation* {.importc: "ModelAnimation", header: raylibHeader, bycopy.} = object
    boneCount* {.importc: "boneCount".}: cint ##  Number of bones
    frameCount* {.importc: "frameCount".}: cint ##  Number of animation frames
    bones* {.importc: "bones".}: ptr BoneInfo ##  Bones information (skeleton)
    framePoses* {.importc: "framePoses".}: ptr UncheckedArray[ptr Transform] ##  Poses array by frame


##  Ray type (useful for raycast)

type
  Ray* {.importc: "Ray", header: raylibHeader, bycopy.} = object
    position* {.importc: "position".}: Vector3 ##  Ray position (origin)
    direction* {.importc: "direction".}: Vector3 ##  Ray direction


##  Raycast hit information

type
  RayHitInfo* {.importc: "RayHitInfo", header: raylibHeader, bycopy.} = object
    hit* {.importc: "hit".}: bool ##  Did the ray hit something?
    distance* {.importc: "distance".}: cfloat ##  Distance to nearest hit
    position* {.importc: "position".}: Vector3 ##  Position of nearest hit
    normal* {.importc: "normal".}: Vector3 ##  Surface normal of hit


##  Bounding box type

type
  BoundingBox* {.importc: "BoundingBox", header: raylibHeader, bycopy.} = object
    min* {.importc: "min".}: Vector3 ##  Minimum vertex box-corner
    max* {.importc: "max".}: Vector3 ##  Maximum vertex box-corner


##  Wave type, defines audio wave data

type
  Wave* {.importc: "Wave", header: raylibHeader, bycopy.} = object
    sampleCount* {.importc: "sampleCount".}: cuint ##  Total number of samples (considering channels!)
    sampleRate* {.importc: "sampleRate".}: cuint ##  Frequency (samples per second)
    sampleSize* {.importc: "sampleSize".}: cuint ##  Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels* {.importc: "channels".}: cuint ##  Number of channels (1-mono, 2-stereo)
    data* {.importc: "data".}: pointer ##  Buffer data pointer

  RAudioBuffer* {.importc: "rAudioBuffer", header: raylibHeader, bycopy.} = object


##  Audio stream type
##  NOTE: Useful to create custom audio streams not bound to a specific file

type
  AudioStream* {.importc: "AudioStream", header: raylibHeader, bycopy.} = object
    buffer* {.importc: "buffer".}: ptr RAudioBuffer ##  Pointer to internal data used by the audio system
    sampleRate* {.importc: "sampleRate".}: cuint ##  Frequency (samples per second)
    sampleSize* {.importc: "sampleSize".}: cuint ##  Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels* {.importc: "channels".}: cuint ##  Number of channels (1-mono, 2-stereo)


##  Sound source type

type
  Sound* {.importc: "Sound", header: raylibHeader, bycopy.} = object
    stream* {.importc: "stream".}: AudioStream ##  Audio stream
    sampleCount* {.importc: "sampleCount".}: cuint ##  Total number of samples


##  Music stream type (audio file streaming from memory)
##  NOTE: Anything longer than ~10 seconds should be streamed

type
  Music* {.importc: "Music", header: raylibHeader, bycopy.} = object
    stream* {.importc: "stream".}: AudioStream ##  Audio stream
    sampleCount* {.importc: "sampleCount".}: cuint ##  Total number of samples
    looping* {.importc: "looping".}: bool ##  Music looping enable
    ctxType* {.importc: "ctxType".}: cint ##  Type of music context (audio filetype)
    ctxData* {.importc: "ctxData".}: pointer ##  Audio context data, depends on type


##  Head-Mounted-Display device parameters

type
  VrDeviceInfo* {.importc: "VrDeviceInfo", header: raylibHeader, bycopy.} = object
    hResolution* {.importc: "hResolution".}: cint ##  Horizontal resolution in pixels
    vResolution* {.importc: "vResolution".}: cint ##  Vertical resolution in pixels
    hScreenSize* {.importc: "hScreenSize".}: cfloat ##  Horizontal size in meters
    vScreenSize* {.importc: "vScreenSize".}: cfloat ##  Vertical size in meters
    vScreenCenter* {.importc: "vScreenCenter".}: cfloat ##  Screen center in meters
    eyeToScreenDistance* {.importc: "eyeToScreenDistance".}: cfloat ##  Distance between eye and display in meters
    lensSeparationDistance* {.importc: "lensSeparationDistance".}: cfloat ##  Lens separation distance in meters
    interpupillaryDistance* {.importc: "interpupillaryDistance".}: cfloat ##  IPD (distance between pupils) in meters
    lensDistortionValues* {.importc: "lensDistortionValues".}: array[4, cfloat] ##  Lens distortion constant parameters
    chromaAbCorrection* {.importc: "chromaAbCorrection".}: array[4, cfloat] ##  Chromatic aberration correction parameters


##  VR Stereo rendering configuration for simulator

type
  VrStereoConfig* {.importc: "VrStereoConfig", header: raylibHeader, bycopy.} = object
    projection* {.importc: "projection".}: array[2, Matrix] ##  VR projection matrices (per eye)
    viewOffset* {.importc: "viewOffset".}: array[2, Matrix] ##  VR view offset matrices (per eye)
    leftLensCenter* {.importc: "leftLensCenter".}: array[2, cfloat] ##  VR left lens center
    rightLensCenter* {.importc: "rightLensCenter".}: array[2, cfloat] ##  VR right lens center
    leftScreenCenter* {.importc: "leftScreenCenter".}: array[2, cfloat] ##  VR left screen center
    rightScreenCenter* {.importc: "rightScreenCenter".}: array[2, cfloat] ##  VR right screen center
    scale* {.importc: "scale".}: array[2, cfloat] ##  VR distortion scale
    scaleIn* {.importc: "scaleIn".}: array[2, cfloat] ##  VR distortion scale in


## ----------------------------------------------------------------------------------
##  Enumerators Definition
## ----------------------------------------------------------------------------------
##  System/Window config flags
##  NOTE: Every bit registers one state (use it with bit masks)
##  By default all flags are set to 0

type
  ConfigFlags* {.size: sizeof(cint), pure.} = enum
    FULLSCREEN_MODE = 0x00000002, ##  Set to run program in fullscreen
    WINDOW_RESIZABLE = 0x00000004, ##  Set to allow resizable window
    WINDOW_UNDECORATED = 0x00000008, ##  Set to disable window decoration (frame and buttons)
    WINDOW_TRANSPARENT = 0x00000010, ##  Set to allow transparent framebuffer
    MSAA_4X_HINT = 0x00000020,  ##  Set to try enabling MSAA 4X
    VSYNC_HINT = 0x00000040,    ##  Set to try enabling V-Sync on GPU
    WINDOW_HIDDEN = 0x00000080, ##  Set to hide window
    WINDOW_ALWAYS_RUN = 0x00000100, ##  Set to allow windows running while minimized
    WINDOW_MINIMIZED = 0x00000200, ##  Set to minimize window (iconify)
    WINDOW_MAXIMIZED = 0x00000400, ##  Set to maximize window (expanded to monitor)
    WINDOW_UNFOCUSED = 0x00000800, ##  Set to window non focused
    WINDOW_TOPMOST = 0x00001000, ##  Set to window always on top
    WINDOW_HIGHDPI = 0x00002000, ##  Set to support HighDPI
    INTERLACED_HINT = 0x00010000


##  Trace log level

type
  TraceLogLevel* {.size: sizeof(cint), pure.} = enum
    ALL = 0,                    ##  Display all logs
    TRACE, DEBUG, INFO, WARNING, ERROR, FATAL, NONE ##  Disable logging


##  Keyboard keys (US keyboard layout)
##  NOTE: Use GetKeyPressed() to allow redefining
##  required keys for alternative layouts

type
  KeyboardKey* {.size: sizeof(cint), pure.} = enum
    NULL = 0,                   ##  Alphanumeric keys
    BACK = 4, VOLUME_UP = 24, VOLUME_DOWN = 25, SPACE = 32, APOSTROPHE = 39, COMMA = 44,
    MINUS = 45, PERIOD = 46, SLASH = 47, ZERO = 48, ONE = 49, TWO = 50, THREE = 51, FOUR = 52,
    FIVE = 53, SIX = 54, SEVEN = 55, EIGHT = 56, NINE = 57, SEMICOLON = 59, EQUAL = 61, A = 65, B = 66,
    C = 67, D = 68, E = 69, F = 70, G = 71, H = 72, I = 73, J = 74, K = 75, L = 76, M = 77, N = 78, O = 79, P = 80,
    Q = 81, R = 82, S = 83, T = 84, U = 85, V = 86, W = 87, X = 88, Y = 89, Z = 90, ##  Function keys
    LEFT_BRACKET = 91, BACKSLASH = 92, RIGHT_BRACKET = 93, GRAVE = 96, ##  Keypad keys
    ESCAPE = 256, ENTER = 257, TAB = 258, BACKSPACE = 259, INSERT = 260, DELETE = 261,
    RIGHT = 262, LEFT = 263, DOWN = 264, UP = 265, PAGE_UP = 266, PAGE_DOWN = 267, HOME = 268,
    END = 269, CAPS_LOCK = 280, SCROLL_LOCK = 281, NUM_LOCK = 282, PRINT_SCREEN = 283,
    PAUSE = 284, F1 = 290, F2 = 291, F3 = 292, F4 = 293, F5 = 294, F6 = 295, F7 = 296, F8 = 297, F9 = 298,
    F10 = 299, F11 = 300, F12 = 301, KP_0 = 320, KP_1 = 321, KP_2 = 322, KP_3 = 323, KP_4 = 324,
    KP_5 = 325, KP_6 = 326, KP_7 = 327, KP_8 = 328, KP_9 = 329, KP_DECIMAL = 330, KP_DIVIDE = 331,
    KP_MULTIPLY = 332, KP_SUBTRACT = 333, KP_ADD = 334, KP_ENTER = 335, KP_EQUAL = 336, ##  Android key buttons
    LEFT_SHIFT = 340, LEFT_CONTROL = 341, LEFT_ALT = 342, LEFT_SUPER = 343,
    RIGHT_SHIFT = 344, RIGHT_CONTROL = 345, RIGHT_ALT = 346, RIGHT_SUPER = 347,
    KB_MENU = 348

const
  MENU* = KeyboardKey.R

##  Mouse buttons

type
  MouseButton* {.size: sizeof(cint), pure.} = enum
    LEFT_BUTTON = 0, RIGHT_BUTTON = 1, MIDDLE_BUTTON = 2


##  Mouse cursor

type
  MouseCursor* {.size: sizeof(cint), pure.} = enum
    CURSOR_DEFAULT = 0, CURSOR_ARROW = 1, CURSOR_IBEAM = 2, CURSOR_CROSSHAIR = 3,
    CURSOR_POINTING_HAND = 4, CURSOR_RESIZE_EW = 5, ##  The horizontal resize/move arrow shape
    CURSOR_RESIZE_NS = 6,       ##  The vertical resize/move arrow shape
    CURSOR_RESIZE_NWSE = 7,     ##  The top-left to bottom-right diagonal resize/move arrow shape
    CURSOR_RESIZE_NESW = 8,     ##  The top-right to bottom-left diagonal resize/move arrow shape
    CURSOR_RESIZE_ALL = 9,      ##  The omni-directional resize/move cursor shape
    CURSOR_NOT_ALLOWED = 10


##  Gamepad buttons

type                          ##  This is here just for error checking
  GamepadButton* {.size: sizeof(cint), pure.} = enum
    BUTTON_UNKNOWN = 0,         ##  This is normally a DPAD
    BUTTON_LEFT_FACE_UP, BUTTON_LEFT_FACE_RIGHT, BUTTON_LEFT_FACE_DOWN, BUTTON_LEFT_FACE_LEFT, ##  This normally corresponds with PlayStation and Xbox controllers
                                                                                           ##  XBOX: [Y,X,A,B]
                                                                                           ##  PS3: [Triangle,Square,Cross,Circle]
                                                                                           ##  No support for 6 button controllers though..
    BUTTON_RIGHT_FACE_UP, BUTTON_RIGHT_FACE_RIGHT, BUTTON_RIGHT_FACE_DOWN, BUTTON_RIGHT_FACE_LEFT, ##  Triggers
    BUTTON_LEFT_TRIGGER_1, BUTTON_LEFT_TRIGGER_2, BUTTON_RIGHT_TRIGGER_1, BUTTON_RIGHT_TRIGGER_2, ##  These are buttons in the center of the gamepad
    BUTTON_MIDDLE_LEFT,       ##  PS3 Select
    BUTTON_MIDDLE,            ##  PS Button/XBOX Button
    BUTTON_MIDDLE_RIGHT,      ##  PS3 Start
                        ##  These are the joystick press in buttons
    BUTTON_LEFT_THUMB, BUTTON_RIGHT_THUMB


##  Gamepad axis

type                          ##  Left stick
  GamepadAxis* {.size: sizeof(cint), pure.} = enum
    AXIS_LEFT_X = 0, AXIS_LEFT_Y = 1, ##  Right stick
    AXIS_RIGHT_X = 2, AXIS_RIGHT_Y = 3, ##  Pressure levels for the back triggers
    AXIS_LEFT_TRIGGER = 4,      ##  [1..-1] (pressure-level)
    AXIS_RIGHT_TRIGGER = 5


##  Material map index

type
  MaterialMapIndex* {.size: sizeof(cint), pure.} = enum
    ALBEDO = 0,                 ##  MATERIAL_MAP_DIFFUSE
    METALNESS = 1,              ##  MATERIAL_MAP_SPECULAR
    NORMAL = 2, ROUGHNESS = 3, OCCLUSION, EMISSION, HEIGHT, BRDG, CUBEMAP, ##  NOTE: Uses GL_TEXTURE_CUBE_MAP
    IRRADIANCE,               ##  NOTE: Uses GL_TEXTURE_CUBE_MAP
    PREFILTER                 ##  NOTE: Uses GL_TEXTURE_CUBE_MAP


##  Shader location index

type
  ShaderLocationIndex* {.size: sizeof(cint), pure.} = enum
    VERTEX_POSITION = 0, VERTEX_TEXCOORD01, VERTEX_TEXCOORD02, VERTEX_NORMAL,
    VERTEX_TANGENT, VERTEX_COLOR, MATRIX_MVP, MATRIX_VIEW, MATRIX_PROJECTION,
    MATRIX_MODEL, MATRIX_NORMAL, VECTOR_VIEW, COLOR_DIFFUSE, COLOR_SPECULAR,
    COLOR_AMBIENT, MAP_ALBEDO, ##  SHADER_LOC_MAP_DIFFUSE
    MAP_METALNESS,            ##  SHADER_LOC_MAP_SPECULAR
    MAP_NORMAL, MAP_ROUGHNESS, MAP_OCCLUSION, MAP_EMISSION, MAP_HEIGHT, MAP_CUBEMAP,
    MAP_IRRADIANCE, MAP_PREFILTER, MAP_BRDF


##  Shader uniform data type

type
  ShaderUniformDataType* {.size: sizeof(cint), pure.} = enum
    FLOAT = 0, VEC2, VEC3, VEC4, INT, IVEC2, IVEC3, IVEC4, SAMPLER2D


##  Pixel formats
##  NOTE: Support depends on OpenGL version and platform

type
  PixelFormat* {.size: sizeof(cint), pure.} = enum
    UNCOMPRESSED_GRAYSCALE = 1, ##  8 bit per pixel (no alpha)
    UNCOMPRESSED_GRAY_ALPHA,  ##  8*2 bpp (2 channels)
    UNCOMPRESSED_R5G6B5,      ##  16 bpp
    UNCOMPRESSED_R8G8B8,      ##  24 bpp
    UNCOMPRESSED_R5G5B5A1,    ##  16 bpp (1 bit alpha)
    UNCOMPRESSED_R4G4B4A4,    ##  16 bpp (4 bit alpha)
    UNCOMPRESSED_R8G8B8A8,    ##  32 bpp
    UNCOMPRESSED_R32,         ##  32 bpp (1 channel - float)
    UNCOMPRESSED_R32G32B32,   ##  32*3 bpp (3 channels - float)
    UNCOMPRESSED_R32G32B32A32, ##  32*4 bpp (4 channels - float)
    COMPRESSED_DXT1_RGB,      ##  4 bpp (no alpha)
    COMPRESSED_DXT1_RGBA,     ##  4 bpp (1 bit alpha)
    COMPRESSED_DXT3_RGBA,     ##  8 bpp
    COMPRESSED_DXT5_RGBA,     ##  8 bpp
    COMPRESSED_ETC1_RGB,      ##  4 bpp
    COMPRESSED_ETC2_RGB,      ##  4 bpp
    COMPRESSED_ETC2_EAC_RGBA, ##  8 bpp
    COMPRESSED_PVRT_RGB,      ##  4 bpp
    COMPRESSED_PVRT_RGBA,     ##  4 bpp
    COMPRESSED_ASTC_4x4RGBA,  ##  8 bpp
    COMPRESSED_ASTC_8x8RGBA   ##  2 bpp


##  Texture parameters: filter mode
##  NOTE 1: Filtering considers mipmaps if available in the texture
##  NOTE 2: Filter is accordingly set for minification and magnification

type
  TextureFilter* {.size: sizeof(cint), pure.} = enum
    POINT = 0,                  ##  No filter, just pixel aproximation
    BILINEAR,                 ##  Linear filtering
    TRILINEAR,                ##  Trilinear filtering (linear with mipmaps)
    ANISOTROPIC_4X,           ##  Anisotropic filtering 4x
    ANISOTROPIC_8X,           ##  Anisotropic filtering 8x
    ANISOTROPIC_16X           ##  Anisotropic filtering 16x


##  Texture parameters: wrap mode

type
  TextureWrap* {.size: sizeof(cint), pure.} = enum
    REPEAT = 0,                 ##  Repeats texture in tiled mode
    CLAMP,                    ##  Clamps texture to edge pixel in tiled mode
    MIRROR_REPEAT,            ##  Mirrors and repeats the texture in tiled mode
    MIRROR_CLAMP              ##  Mirrors and clamps to border the texture in tiled mode


##  Cubemap layouts

type
  CubemapLayout* {.size: sizeof(cint), pure.} = enum
    AUTO_DETECT = 0,            ##  Automatically detect layout type
    LINE_VERTICAL,            ##  Layout is defined by a vertical line with faces
    LINE_HORIZONTAL,          ##  Layout is defined by an horizontal line with faces
    CROSS_THREE_BY_FOUR,      ##  Layout is defined by a 3x4 cross with cubemap faces
    CROSS_FOUR_BY_THREE,      ##  Layout is defined by a 4x3 cross with cubemap faces
    PANORAMA                  ##  Layout is defined by a panorama image (equirectangular map)


##  Font type, defines generation method

type
  FontType* {.size: sizeof(cint), pure.} = enum
    DEFAULT = 0,                ##  Default font generation, anti-aliased
    BITMAP,                   ##  Bitmap font generation, no anti-aliasing
    SDF                       ##  SDF font generation, requires external shader


##  Color blending modes (pre-defined)

type
  BlendMode* {.size: sizeof(cint), pure.} = enum
    ALPHA = 0,                  ##  Blend textures considering alpha (default)
    ADDITIVE,                 ##  Blend textures adding colors
    MULTIPLIED,               ##  Blend textures multiplying colors
    ADD_COLORS,               ##  Blend textures adding colors (alternative)
    SUBTRACT_COLORS,          ##  Blend textures subtracting colors (alternative)
    CUSTOM                    ##  Belnd textures using custom src/dst factors (use rlSetBlendMode())


##  Gestures
##  NOTE: It could be used as flags to enable only some gestures

type
  Gestures* {.size: sizeof(cint), pure.} = enum
    NONE = 0, TAP = 1, DOUBLETAP = 2, HOLD = 4, DRAG = 8, SWIPE_RIGHT = 16, SWIPE_LEFT = 32,
    SWIPE_UP = 64, SWIPE_DOWN = 128, PINCH_IN = 256, PINCH_OUT = 512


##  Camera system modes

type
  CameraMode* {.size: sizeof(cint), pure.} = enum
    CUSTOM = 0, FREE, ORBITAL, FIRST_PERSON, THIRD_PERSON


##  Camera projection

type
  CameraProjection* {.size: sizeof(cint), pure.} = enum
    PERSPECTIVE = 0, ORTHOGRAPHIC


##  N-patch layout

type
  NPatchLayout* {.size: sizeof(cint), pure.} = enum
    NINE_PATCH = 0,             ##  Npatch layout: 3x3 tiles
    THREE_PATCH_VERTICAL,     ##  Npatch layout: 1x3 tiles
    THREE_PATCH_HORIZONTAL    ##  Npatch layout: 3x1 tiles


##  Callbacks to hook some internal functions
##  WARNING: This callbacks are intended for advance users

type
  TraceLogCallback* = proc (logLevel: cint; text: cstring; args: va_list) {.cdecl.}

##  Logging: Redirect trace log messages

type
  LoadFileDataCallback* = proc (fileName: cstring; bytesRead: ptr cuint): ptr uint8 {.
      cdecl.}

##  FileIO: Load binary data

type
  SaveFileDataCallback* = proc (fileName: cstring; data: pointer; bytesToWrite: cuint): bool {.
      cdecl.}

##  FileIO: Save binary data

type
  LoadFileTextCallback* = proc (fileName: cstring): cstring {.cdecl.}

##  FileIO: Load text data

type
  SaveFileTextCallback* = proc (fileName: cstring; text: cstring): bool {.cdecl.}

##  FileIO: Save text data
## ------------------------------------------------------------------------------------
##  Global Variables Definition
## ------------------------------------------------------------------------------------
##  It's lonely here...
## ------------------------------------------------------------------------------------
##  Window and Graphics Device Functions (Module: core)
## ------------------------------------------------------------------------------------
##  Window-related functions

proc initWindow*(width: cint; height: cint; title: cstring) {.cdecl,
    importc: "InitWindow", header: raylibHeader.}
##  Initialize window and OpenGL context

proc windowShouldClose*(): bool {.cdecl, importc: "WindowShouldClose",
                               header: raylibHeader.}
##  Check if KEY_ESCAPE pressed or Close icon pressed

proc closeWindow*() {.cdecl, importc: "NmrlbNow_CloseWindow", header: raylibHeader.}
##  Close window and unload OpenGL context

proc isWindowReady*(): bool {.cdecl, importc: "IsWindowReady", header: raylibHeader.}
##  Check if window has been initialized successfully

proc isWindowFullscreen*(): bool {.cdecl, importc: "IsWindowFullscreen",
                                header: raylibHeader.}
##  Check if window is currently fullscreen

proc isWindowHidden*(): bool {.cdecl, importc: "IsWindowHidden", header: raylibHeader.}
##  Check if window is currently hidden (only PLATFORM_DESKTOP)

proc isWindowMinimized*(): bool {.cdecl, importc: "IsWindowMinimized",
                               header: raylibHeader.}
##  Check if window is currently minimized (only PLATFORM_DESKTOP)

proc isWindowMaximized*(): bool {.cdecl, importc: "IsWindowMaximized",
                               header: raylibHeader.}
##  Check if window is currently maximized (only PLATFORM_DESKTOP)

proc isWindowFocused*(): bool {.cdecl, importc: "IsWindowFocused",
                             header: raylibHeader.}
##  Check if window is currently focused (only PLATFORM_DESKTOP)

proc isWindowResized*(): bool {.cdecl, importc: "IsWindowResized",
                             header: raylibHeader.}
##  Check if window has been resized last frame

proc isWindowState*(flag: cuint): bool {.cdecl, importc: "IsWindowState",
                                     header: raylibHeader.}
##  Check if one specific window flag is enabled

proc setWindowState*(flags: cuint) {.cdecl, importc: "SetWindowState",
                                  header: raylibHeader.}
##  Set window configuration state using flags

proc clearWindowState*(flags: cuint) {.cdecl, importc: "ClearWindowState",
                                    header: raylibHeader.}
##  Clear window configuration state flags

proc toggleFullscreen*() {.cdecl, importc: "ToggleFullscreen", header: raylibHeader.}
##  Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)

proc maximizeWindow*() {.cdecl, importc: "MaximizeWindow", header: raylibHeader.}
##  Set window state: maximized, if resizable (only PLATFORM_DESKTOP)

proc minimizeWindow*() {.cdecl, importc: "MinimizeWindow", header: raylibHeader.}
##  Set window state: minimized, if resizable (only PLATFORM_DESKTOP)

proc restoreWindow*() {.cdecl, importc: "RestoreWindow", header: raylibHeader.}
##  Set window state: not minimized/maximized (only PLATFORM_DESKTOP)

proc setWindowIcon*(image: Image) {.cdecl, importc: "SetWindowIcon",
                                 header: raylibHeader.}
##  Set icon for window (only PLATFORM_DESKTOP)

proc setWindowTitle*(title: cstring) {.cdecl, importc: "SetWindowTitle",
                                    header: raylibHeader.}
##  Set title for window (only PLATFORM_DESKTOP)

proc setWindowPosition*(x: cint; y: cint) {.cdecl, importc: "SetWindowPosition",
                                       header: raylibHeader.}
##  Set window position on screen (only PLATFORM_DESKTOP)

proc setWindowMonitor*(monitor: cint) {.cdecl, importc: "SetWindowMonitor",
                                     header: raylibHeader.}
##  Set monitor for the current window (fullscreen mode)

proc setWindowMinSize*(width: cint; height: cint) {.cdecl,
    importc: "SetWindowMinSize", header: raylibHeader.}
##  Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)

proc setWindowSize*(width: cint; height: cint) {.cdecl, importc: "SetWindowSize",
    header: raylibHeader.}
##  Set window dimensions

proc getWindowHandle*(): pointer {.cdecl, importc: "GetWindowHandle",
                                header: raylibHeader.}
##  Get native window handle

proc getScreenWidth*(): cint {.cdecl, importc: "GetScreenWidth", header: raylibHeader.}
##  Get current screen width

proc getScreenHeight*(): cint {.cdecl, importc: "GetScreenHeight",
                             header: raylibHeader.}
##  Get current screen height

proc getMonitorCount*(): cint {.cdecl, importc: "GetMonitorCount",
                             header: raylibHeader.}
##  Get number of connected monitors

proc getCurrentMonitor*(): cint {.cdecl, importc: "GetCurrentMonitor",
                               header: raylibHeader.}
##  Get current connected monitor

proc getMonitorPosition*(monitor: cint): Vector2 {.cdecl,
    importc: "GetMonitorPosition", header: raylibHeader.}
##  Get specified monitor position

proc getMonitorWidth*(monitor: cint): cint {.cdecl, importc: "GetMonitorWidth",
    header: raylibHeader.}
##  Get specified monitor width (max available by monitor)

proc getMonitorHeight*(monitor: cint): cint {.cdecl, importc: "GetMonitorHeight",
    header: raylibHeader.}
##  Get specified monitor height (max available by monitor)

proc getMonitorPhysicalWidth*(monitor: cint): cint {.cdecl,
    importc: "GetMonitorPhysicalWidth", header: raylibHeader.}
##  Get specified monitor physical width in millimetres

proc getMonitorPhysicalHeight*(monitor: cint): cint {.cdecl,
    importc: "GetMonitorPhysicalHeight", header: raylibHeader.}
##  Get specified monitor physical height in millimetres

proc getMonitorRefreshRate*(monitor: cint): cint {.cdecl,
    importc: "GetMonitorRefreshRate", header: raylibHeader.}
##  Get specified monitor refresh rate

proc getWindowPosition*(): Vector2 {.cdecl, importc: "GetWindowPosition",
                                  header: raylibHeader.}
##  Get window position XY on monitor

proc getWindowScaleDPI*(): Vector2 {.cdecl, importc: "GetWindowScaleDPI",
                                  header: raylibHeader.}
##  Get window scale DPI factor

proc getMonitorName*(monitor: cint): cstring {.cdecl, importc: "GetMonitorName",
    header: raylibHeader.}
##  Get the human-readable, UTF-8 encoded name of the primary monitor

proc setClipboardText*(text: cstring) {.cdecl, importc: "SetClipboardText",
                                     header: raylibHeader.}
##  Set clipboard text content

proc getClipboardText*(): cstring {.cdecl, importc: "GetClipboardText",
                                 header: raylibHeader.}
##  Get clipboard text content
##  Cursor-related functions

proc showCursor*() {.cdecl, importc: "NmrlbNow_ShowCursor", header: raylibHeader.}
##  Shows cursor

proc hideCursor*() {.cdecl, importc: "HideCursor", header: raylibHeader.}
##  Hides cursor

proc isCursorHidden*(): bool {.cdecl, importc: "IsCursorHidden", header: raylibHeader.}
##  Check if cursor is not visible

proc enableCursor*() {.cdecl, importc: "EnableCursor", header: raylibHeader.}
##  Enables cursor (unlock cursor)

proc disableCursor*() {.cdecl, importc: "DisableCursor", header: raylibHeader.}
##  Disables cursor (lock cursor)

proc isCursorOnScreen*(): bool {.cdecl, importc: "IsCursorOnScreen",
                              header: raylibHeader.}
##  Check if cursor is on the current screen.
##  Drawing-related functions

proc clearBackground*(color: Color) {.cdecl, importc: "ClearBackground",
                                   header: raylibHeader.}
##  Set background color (framebuffer clear color)

proc beginDrawing*() {.cdecl, importc: "BeginDrawing", header: raylibHeader.}
##  Setup canvas (framebuffer) to start drawing

proc endDrawing*() {.cdecl, importc: "EndDrawing", header: raylibHeader.}
##  End canvas drawing and swap buffers (double buffering)

proc beginMode2D*(camera: Camera2D) {.cdecl, importc: "BeginMode2D",
                                   header: raylibHeader.}
##  Initialize 2D mode with custom camera (2D)

proc endMode2D*() {.cdecl, importc: "EndMode2D", header: raylibHeader.}
##  Ends 2D mode with custom camera

proc beginMode3D*(camera: Camera3D) {.cdecl, importc: "BeginMode3D",
                                   header: raylibHeader.}
##  Initializes 3D mode with custom camera (3D)

proc endMode3D*() {.cdecl, importc: "EndMode3D", header: raylibHeader.}
##  Ends 3D mode and returns to default 2D orthographic mode

proc beginTextureMode*(target: RenderTexture2D) {.cdecl,
    importc: "BeginTextureMode", header: raylibHeader.}
##  Initializes render texture for drawing

proc endTextureMode*() {.cdecl, importc: "EndTextureMode", header: raylibHeader.}
##  Ends drawing to render texture

proc beginShaderMode*(shader: Shader) {.cdecl, importc: "BeginShaderMode",
                                     header: raylibHeader.}
##  Begin custom shader drawing

proc endShaderMode*() {.cdecl, importc: "EndShaderMode", header: raylibHeader.}
##  End custom shader drawing (use default shader)

proc beginBlendMode*(mode: cint) {.cdecl, importc: "BeginBlendMode",
                                header: raylibHeader.}
##  Begin blending mode (alpha, additive, multiplied)

proc endBlendMode*() {.cdecl, importc: "EndBlendMode", header: raylibHeader.}
##  End blending mode (reset to default: alpha blending)

proc beginScissorMode*(x: cint; y: cint; width: cint; height: cint) {.cdecl,
    importc: "BeginScissorMode", header: raylibHeader.}
##  Begin scissor mode (define screen area for following drawing)

proc endScissorMode*() {.cdecl, importc: "EndScissorMode", header: raylibHeader.}
##  End scissor mode

proc beginVrStereoMode*(config: VrStereoConfig) {.cdecl,
    importc: "BeginVrStereoMode", header: raylibHeader.}
##  Begin stereo rendering (requires VR simulator)

proc endVrStereoMode*() {.cdecl, importc: "EndVrStereoMode", header: raylibHeader.}
##  End stereo rendering (requires VR simulator)
##  VR stereo config functions for VR simulator

proc loadVrStereoConfig*(device: VrDeviceInfo): VrStereoConfig {.cdecl,
    importc: "LoadVrStereoConfig", header: raylibHeader.}
##  Load VR stereo config for VR simulator device parameters

proc unloadVrStereoConfig*(config: VrStereoConfig) {.cdecl,
    importc: "UnloadVrStereoConfig", header: raylibHeader.}
##  Unload VR stereo config
##  Shader management functions
##  NOTE: Shader functionality is not available on OpenGL 1.1

proc loadShader*(vsFileName: cstring; fsFileName: cstring): Shader {.cdecl,
    importc: "LoadShader", header: raylibHeader.}
##  Load shader from files and bind default locations

proc loadShaderFromMemory*(vsCode: cstring; fsCode: cstring): Shader {.cdecl,
    importc: "LoadShaderFromMemory", header: raylibHeader.}
##  Load shader from code strings and bind default locations

proc getShaderLocation*(shader: Shader; uniformName: cstring): cint {.cdecl,
    importc: "GetShaderLocation", header: raylibHeader.}
##  Get shader uniform location

proc getShaderLocationAttrib*(shader: Shader; attribName: cstring): cint {.cdecl,
    importc: "GetShaderLocationAttrib", header: raylibHeader.}
##  Get shader attribute location

proc setShaderValue*(shader: Shader; locIndex: cint; value: pointer; uniformType: cint) {.
    cdecl, importc: "SetShaderValue", header: raylibHeader.}
##  Set shader uniform value

proc setShaderValueV*(shader: Shader; locIndex: cint; value: pointer;
                     uniformType: cint; count: cint) {.cdecl,
    importc: "SetShaderValueV", header: raylibHeader.}
##  Set shader uniform value vector

proc setShaderValueMatrix*(shader: Shader; locIndex: cint; mat: Matrix) {.cdecl,
    importc: "SetShaderValueMatrix", header: raylibHeader.}
##  Set shader uniform value (matrix 4x4)

proc setShaderValueTexture*(shader: Shader; locIndex: cint; texture: Texture2D) {.
    cdecl, importc: "SetShaderValueTexture", header: raylibHeader.}
##  Set shader uniform value for texture (sampler2d)

proc unloadShader*(shader: Shader) {.cdecl, importc: "UnloadShader",
                                  header: raylibHeader.}
##  Unload shader from GPU memory (VRAM)
##  Screen-space-related functions

proc getMouseRay*(mousePosition: Vector2; camera: Camera): Ray {.cdecl,
    importc: "GetMouseRay", header: raylibHeader.}
##  Returns a ray trace from mouse position

proc getCameraMatrix*(camera: Camera): Matrix {.cdecl, importc: "GetCameraMatrix",
    header: raylibHeader.}
##  Returns camera transform matrix (view matrix)

proc getCameraMatrix2D*(camera: Camera2D): Matrix {.cdecl,
    importc: "GetCameraMatrix2D", header: raylibHeader.}
##  Returns camera 2d transform matrix

proc getWorldToScreen*(position: Vector3; camera: Camera): Vector2 {.cdecl,
    importc: "GetWorldToScreen", header: raylibHeader.}
##  Returns the screen space position for a 3d world space position

proc getWorldToScreenEx*(position: Vector3; camera: Camera; width: cint; height: cint): Vector2 {.
    cdecl, importc: "GetWorldToScreenEx", header: raylibHeader.}
##  Returns size position for a 3d world space position

proc getWorldToScreen2D*(position: Vector2; camera: Camera2D): Vector2 {.cdecl,
    importc: "GetWorldToScreen2D", header: raylibHeader.}
##  Returns the screen space position for a 2d camera world space position

proc getScreenToWorld2D*(position: Vector2; camera: Camera2D): Vector2 {.cdecl,
    importc: "GetScreenToWorld2D", header: raylibHeader.}
##  Returns the world space position for a 2d camera screen space position
##  Timing-related functions

proc setTargetFPS*(fps: cint) {.cdecl, importc: "SetTargetFPS", header: raylibHeader.}
##  Set target FPS (maximum)

proc getFPS*(): cint {.cdecl, importc: "GetFPS", header: raylibHeader.}
##  Returns current FPS

proc getFrameTime*(): cfloat {.cdecl, importc: "GetFrameTime", header: raylibHeader.}
##  Returns time in seconds for last frame drawn (delta time)

proc getTime*(): cdouble {.cdecl, importc: "GetTime", header: raylibHeader.}
##  Returns elapsed time in seconds since InitWindow()
##  Misc. functions

proc getRandomValue*(min: cint; max: cint): cint {.cdecl, importc: "GetRandomValue",
    header: raylibHeader.}
##  Returns a random value between min and max (both included)

proc takeScreenshot*(fileName: cstring) {.cdecl, importc: "TakeScreenshot",
                                       header: raylibHeader.}
##  Takes a screenshot of current screen (filename extension defines format)

proc setConfigFlags*(flags: cuint) {.cdecl, importc: "SetConfigFlags",
                                  header: raylibHeader.}
##  Setup init configuration flags (view FLAGS)

proc traceLog*(logLevel: cint; text: cstring) {.varargs, cdecl, importc: "TraceLog",
    header: raylibHeader.}
##  Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR)

proc setTraceLogLevel*(logLevel: cint) {.cdecl, importc: "SetTraceLogLevel",
                                      header: raylibHeader.}
##  Set the current threshold (minimum) log level

proc memAlloc*(size: cint): pointer {.cdecl, importc: "MemAlloc", header: raylibHeader.}
##  Internal memory allocator

proc memRealloc*(`ptr`: pointer; size: cint): pointer {.cdecl, importc: "MemRealloc",
    header: raylibHeader.}
##  Internal memory reallocator

proc memFree*(`ptr`: pointer) {.cdecl, importc: "MemFree", header: raylibHeader.}
##  Internal memory free
##  Set custom callbacks
##  WARNING: Callbacks setup is intended for advance users

proc setTraceLogCallback*(callback: TraceLogCallback) {.cdecl,
    importc: "SetTraceLogCallback", header: raylibHeader.}
##  Set custom trace log

proc setLoadFileDataCallback*(callback: LoadFileDataCallback) {.cdecl,
    importc: "SetLoadFileDataCallback", header: raylibHeader.}
##  Set custom file binary data loader

proc setSaveFileDataCallback*(callback: SaveFileDataCallback) {.cdecl,
    importc: "SetSaveFileDataCallback", header: raylibHeader.}
##  Set custom file binary data saver

proc setLoadFileTextCallback*(callback: LoadFileTextCallback) {.cdecl,
    importc: "SetLoadFileTextCallback", header: raylibHeader.}
##  Set custom file text data loader

proc setSaveFileTextCallback*(callback: SaveFileTextCallback) {.cdecl,
    importc: "SetSaveFileTextCallback", header: raylibHeader.}
##  Set custom file text data saver
##  Files management functions

proc loadFileData*(fileName: cstring; bytesRead: ptr cuint): ptr uint8 {.cdecl,
    importc: "LoadFileData", header: raylibHeader.}
##  Load file data as byte array (read)

proc unloadFileData*(data: ptr uint8) {.cdecl, importc: "UnloadFileData",
                                     header: raylibHeader.}
##  Unload file data allocated by LoadFileData()

proc saveFileData*(fileName: cstring; data: pointer; bytesToWrite: cuint): bool {.cdecl,
    importc: "SaveFileData", header: raylibHeader.}
##  Save data to file from byte array (write), returns true on success

proc loadFileText*(fileName: cstring): cstring {.cdecl, importc: "LoadFileText",
    header: raylibHeader.}
##  Load text data from file (read), returns a '\0' terminated string

proc unloadFileText*(text: ptr uint8) {.cdecl, importc: "UnloadFileText",
                                     header: raylibHeader.}
##  Unload file text data allocated by LoadFileText()

proc saveFileText*(fileName: cstring; text: cstring): bool {.cdecl,
    importc: "SaveFileText", header: raylibHeader.}
##  Save text data to file (write), string must be '\0' terminated, returns true on success

proc fileExists*(fileName: cstring): bool {.cdecl, importc: "FileExists",
                                        header: raylibHeader.}
##  Check if file exists

proc directoryExists*(dirPath: cstring): bool {.cdecl, importc: "DirectoryExists",
    header: raylibHeader.}
##  Check if a directory path exists

proc isFileExtension*(fileName: cstring; ext: cstring): bool {.cdecl,
    importc: "IsFileExtension", header: raylibHeader.}
##  Check file extension (including point: .png, .wav)

proc getFileExtension*(fileName: cstring): cstring {.cdecl,
    importc: "GetFileExtension", header: raylibHeader.}
##  Get pointer to extension for a filename string (includes dot: ".png")

proc getFileName*(filePath: cstring): cstring {.cdecl, importc: "GetFileName",
    header: raylibHeader.}
##  Get pointer to filename for a path string

proc getFileNameWithoutExt*(filePath: cstring): cstring {.cdecl,
    importc: "GetFileNameWithoutExt", header: raylibHeader.}
##  Get filename string without extension (uses static string)

proc getDirectoryPath*(filePath: cstring): cstring {.cdecl,
    importc: "GetDirectoryPath", header: raylibHeader.}
##  Get full path for a given fileName with path (uses static string)

proc getPrevDirectoryPath*(dirPath: cstring): cstring {.cdecl,
    importc: "GetPrevDirectoryPath", header: raylibHeader.}
##  Get previous directory path for a given path (uses static string)

proc getWorkingDirectory*(): cstring {.cdecl, importc: "GetWorkingDirectory",
                                    header: raylibHeader.}
##  Get current working directory (uses static string)

proc getDirectoryFiles*(dirPath: cstring; count: ptr cint): cstringArray {.cdecl,
    importc: "GetDirectoryFiles", header: raylibHeader.}
##  Get filenames in a directory path (memory should be freed)

proc clearDirectoryFiles*() {.cdecl, importc: "ClearDirectoryFiles",
                            header: raylibHeader.}
##  Clear directory files paths buffers (free memory)

proc changeDirectory*(dir: cstring): bool {.cdecl, importc: "ChangeDirectory",
                                        header: raylibHeader.}
##  Change working directory, return true on success

proc isFileDropped*(): bool {.cdecl, importc: "IsFileDropped", header: raylibHeader.}
##  Check if a file has been dropped into window

proc getDroppedFiles*(count: ptr cint): cstringArray {.cdecl,
    importc: "GetDroppedFiles", header: raylibHeader.}
##  Get dropped files names (memory should be freed)

proc clearDroppedFiles*() {.cdecl, importc: "ClearDroppedFiles", header: raylibHeader.}
##  Clear dropped files paths buffer (free memory)

proc getFileModTime*(fileName: cstring): clong {.cdecl, importc: "GetFileModTime",
    header: raylibHeader.}
##  Get file modification time (last write time)

proc compressData*(data: ptr uint8; dataLength: cint; compDataLength: ptr cint): ptr uint8 {.
    cdecl, importc: "CompressData", header: raylibHeader.}
##  Compress data (DEFLATE algorithm)

proc decompressData*(compData: ptr uint8; compDataLength: cint; dataLength: ptr cint): ptr uint8 {.
    cdecl, importc: "DecompressData", header: raylibHeader.}
##  Decompress data (DEFLATE algorithm)
##  Persistent storage management

proc saveStorageValue*(position: cuint; value: cint): bool {.cdecl,
    importc: "SaveStorageValue", header: raylibHeader.}
##  Save integer value to storage file (to defined position), returns true on success

proc loadStorageValue*(position: cuint): cint {.cdecl, importc: "LoadStorageValue",
    header: raylibHeader.}
##  Load integer value from storage file (from defined position)

proc openURL*(url: cstring) {.cdecl, importc: "OpenURL", header: raylibHeader.}
##  Open URL with default system browser (if available)
## ------------------------------------------------------------------------------------
##  Input Handling Functions (Module: core)
## ------------------------------------------------------------------------------------
##  Input-related functions: keyboard

proc isKeyPressed*(key: cint): bool {.cdecl, importc: "IsKeyPressed",
                                  header: raylibHeader.}
##  Detect if a key has been pressed once

proc isKeyDown*(key: cint): bool {.cdecl, importc: "IsKeyDown", header: raylibHeader.}
##  Detect if a key is being pressed

proc isKeyReleased*(key: cint): bool {.cdecl, importc: "IsKeyReleased",
                                   header: raylibHeader.}
##  Detect if a key has been released once

proc isKeyUp*(key: cint): bool {.cdecl, importc: "IsKeyUp", header: raylibHeader.}
##  Detect if a key is NOT being pressed

proc setExitKey*(key: cint) {.cdecl, importc: "SetExitKey", header: raylibHeader.}
##  Set a custom key to exit program (default is ESC)

proc getKeyPressed*(): cint {.cdecl, importc: "GetKeyPressed", header: raylibHeader.}
##  Get key pressed (keycode), call it multiple times for keys queued

proc getCharPressed*(): cint {.cdecl, importc: "GetCharPressed", header: raylibHeader.}
##  Get char pressed (unicode), call it multiple times for chars queued
##  Input-related functions: gamepads

proc isGamepadAvailable*(gamepad: cint): bool {.cdecl, importc: "IsGamepadAvailable",
    header: raylibHeader.}
##  Detect if a gamepad is available

proc isGamepadName*(gamepad: cint; name: cstring): bool {.cdecl,
    importc: "IsGamepadName", header: raylibHeader.}
##  Check gamepad name (if available)

proc getGamepadName*(gamepad: cint): cstring {.cdecl, importc: "GetGamepadName",
    header: raylibHeader.}
##  Return gamepad internal name id

proc isGamepadButtonPressed*(gamepad: cint; button: cint): bool {.cdecl,
    importc: "IsGamepadButtonPressed", header: raylibHeader.}
##  Detect if a gamepad button has been pressed once

proc isGamepadButtonDown*(gamepad: cint; button: cint): bool {.cdecl,
    importc: "IsGamepadButtonDown", header: raylibHeader.}
##  Detect if a gamepad button is being pressed

proc isGamepadButtonReleased*(gamepad: cint; button: cint): bool {.cdecl,
    importc: "IsGamepadButtonReleased", header: raylibHeader.}
##  Detect if a gamepad button has been released once

proc isGamepadButtonUp*(gamepad: cint; button: cint): bool {.cdecl,
    importc: "IsGamepadButtonUp", header: raylibHeader.}
##  Detect if a gamepad button is NOT being pressed

proc getGamepadButtonPressed*(): cint {.cdecl, importc: "GetGamepadButtonPressed",
                                     header: raylibHeader.}
##  Get the last gamepad button pressed

proc getGamepadAxisCount*(gamepad: cint): cint {.cdecl,
    importc: "GetGamepadAxisCount", header: raylibHeader.}
##  Return gamepad axis count for a gamepad

proc getGamepadAxisMovement*(gamepad: cint; axis: cint): cfloat {.cdecl,
    importc: "GetGamepadAxisMovement", header: raylibHeader.}
##  Return axis movement value for a gamepad axis

proc setGamepadMappings*(mappings: cstring): cint {.cdecl,
    importc: "SetGamepadMappings", header: raylibHeader.}
##  Set internal gamepad mappings (SDL_GameControllerDB)
##  Input-related functions: mouse

proc isMouseButtonPressed*(button: cint): bool {.cdecl,
    importc: "IsMouseButtonPressed", header: raylibHeader.}
##  Detect if a mouse button has been pressed once

proc isMouseButtonDown*(button: cint): bool {.cdecl, importc: "IsMouseButtonDown",
    header: raylibHeader.}
##  Detect if a mouse button is being pressed

proc isMouseButtonReleased*(button: cint): bool {.cdecl,
    importc: "IsMouseButtonReleased", header: raylibHeader.}
##  Detect if a mouse button has been released once

proc isMouseButtonUp*(button: cint): bool {.cdecl, importc: "IsMouseButtonUp",
                                        header: raylibHeader.}
##  Detect if a mouse button is NOT being pressed

proc getMouseX*(): cint {.cdecl, importc: "GetMouseX", header: raylibHeader.}
##  Returns mouse position X

proc getMouseY*(): cint {.cdecl, importc: "GetMouseY", header: raylibHeader.}
##  Returns mouse position Y

proc getMousePosition*(): Vector2 {.cdecl, importc: "GetMousePosition",
                                 header: raylibHeader.}
##  Returns mouse position XY

proc setMousePosition*(x: cint; y: cint) {.cdecl, importc: "SetMousePosition",
                                      header: raylibHeader.}
##  Set mouse position XY

proc setMouseOffset*(offsetX: cint; offsetY: cint) {.cdecl, importc: "SetMouseOffset",
    header: raylibHeader.}
##  Set mouse offset

proc setMouseScale*(scaleX: cfloat; scaleY: cfloat) {.cdecl, importc: "SetMouseScale",
    header: raylibHeader.}
##  Set mouse scaling

proc getMouseWheelMove*(): cfloat {.cdecl, importc: "GetMouseWheelMove",
                                 header: raylibHeader.}
##  Returns mouse wheel movement Y

proc setMouseCursor*(cursor: cint) {.cdecl, importc: "SetMouseCursor",
                                  header: raylibHeader.}
##  Set mouse cursor
##  Input-related functions: touch

proc getTouchX*(): cint {.cdecl, importc: "GetTouchX", header: raylibHeader.}
##  Returns touch position X for touch point 0 (relative to screen size)

proc getTouchY*(): cint {.cdecl, importc: "GetTouchY", header: raylibHeader.}
##  Returns touch position Y for touch point 0 (relative to screen size)

proc getTouchPosition*(index: cint): Vector2 {.cdecl, importc: "GetTouchPosition",
    header: raylibHeader.}
##  Returns touch position XY for a touch point index (relative to screen size)
## ------------------------------------------------------------------------------------
##  Gestures and Touch Handling Functions (Module: gestures)
## ------------------------------------------------------------------------------------

proc setGesturesEnabled*(flags: cuint) {.cdecl, importc: "SetGesturesEnabled",
                                      header: raylibHeader.}
##  Enable a set of gestures using flags

proc isGestureDetected*(gesture: cint): bool {.cdecl, importc: "IsGestureDetected",
    header: raylibHeader.}
##  Check if a gesture have been detected

proc getGestureDetected*(): cint {.cdecl, importc: "GetGestureDetected",
                                header: raylibHeader.}
##  Get latest detected gesture

proc getTouchPointsCount*(): cint {.cdecl, importc: "GetTouchPointsCount",
                                 header: raylibHeader.}
##  Get touch points count

proc getGestureHoldDuration*(): cfloat {.cdecl, importc: "GetGestureHoldDuration",
                                      header: raylibHeader.}
##  Get gesture hold time in milliseconds

proc getGestureDragVector*(): Vector2 {.cdecl, importc: "GetGestureDragVector",
                                     header: raylibHeader.}
##  Get gesture drag vector

proc getGestureDragAngle*(): cfloat {.cdecl, importc: "GetGestureDragAngle",
                                   header: raylibHeader.}
##  Get gesture drag angle

proc getGesturePinchVector*(): Vector2 {.cdecl, importc: "GetGesturePinchVector",
                                      header: raylibHeader.}
##  Get gesture pinch delta

proc getGesturePinchAngle*(): cfloat {.cdecl, importc: "GetGesturePinchAngle",
                                    header: raylibHeader.}
##  Get gesture pinch angle
## ------------------------------------------------------------------------------------
##  Camera System Functions (Module: camera)
## ------------------------------------------------------------------------------------

proc setCameraMode*(camera: Camera; mode: cint) {.cdecl, importc: "SetCameraMode",
    header: raylibHeader.}
##  Set camera mode (multiple camera modes available)

proc updateCamera*(camera: ptr Camera) {.cdecl, importc: "UpdateCamera",
                                     header: raylibHeader.}
##  Update camera position for selected mode

proc setCameraPanControl*(keyPan: cint) {.cdecl, importc: "SetCameraPanControl",
                                       header: raylibHeader.}
##  Set camera pan key to combine with mouse movement (free camera)

proc setCameraAltControl*(keyAlt: cint) {.cdecl, importc: "SetCameraAltControl",
                                       header: raylibHeader.}
##  Set camera alt key to combine with mouse movement (free camera)

proc setCameraSmoothZoomControl*(keySmoothZoom: cint) {.cdecl,
    importc: "SetCameraSmoothZoomControl", header: raylibHeader.}
##  Set camera smooth zoom key to combine with mouse (free camera)

proc setCameraMoveControls*(keyFront: cint; keyBack: cint; keyRight: cint;
                           keyLeft: cint; keyUp: cint; keyDown: cint) {.cdecl,
    importc: "SetCameraMoveControls", header: raylibHeader.}
##  Set camera move controls (1st person and 3rd person cameras)
## ------------------------------------------------------------------------------------
##  Basic Shapes Drawing Functions (Module: shapes)
## ------------------------------------------------------------------------------------
##  Set texture and rectangle to be used on shapes drawing
##  NOTE: It can be useful when using basic shapes and one single font,
##  defining a font char white rectangle would allow drawing everything in a single draw call

proc setShapesTexture*(texture: Texture2D; source: Rectangle) {.cdecl,
    importc: "SetShapesTexture", header: raylibHeader.}
##  Basic shapes drawing functions

proc drawPixel*(posX: cint; posY: cint; color: Color) {.cdecl, importc: "DrawPixel",
    header: raylibHeader.}
##  Draw a pixel

proc drawPixelV*(position: Vector2; color: Color) {.cdecl, importc: "DrawPixelV",
    header: raylibHeader.}
##  Draw a pixel (Vector version)

proc drawLine*(startPosX: cint; startPosY: cint; endPosX: cint; endPosY: cint;
              color: Color) {.cdecl, importc: "DrawLine", header: raylibHeader.}
##  Draw a line

proc drawLineV*(startPos: Vector2; endPos: Vector2; color: Color) {.cdecl,
    importc: "DrawLineV", header: raylibHeader.}
##  Draw a line (Vector version)

proc drawLineEx*(startPos: Vector2; endPos: Vector2; thick: cfloat; color: Color) {.
    cdecl, importc: "DrawLineEx", header: raylibHeader.}
##  Draw a line defining thickness

proc drawLineBezier*(startPos: Vector2; endPos: Vector2; thick: cfloat; color: Color) {.
    cdecl, importc: "DrawLineBezier", header: raylibHeader.}
##  Draw a line using cubic-bezier curves in-out

proc drawLineBezierQuad*(startPos: Vector2; endPos: Vector2; controlPos: Vector2;
                        thick: cfloat; color: Color) {.cdecl,
    importc: "DrawLineBezierQuad", header: raylibHeader.}
## Draw line using quadratic bezier curves with a control point

proc drawLineStrip*(points: ptr Vector2; pointsCount: cint; color: Color) {.cdecl,
    importc: "DrawLineStrip", header: raylibHeader.}
##  Draw lines sequence

proc drawCircle*(centerX: cint; centerY: cint; radius: cfloat; color: Color) {.cdecl,
    importc: "DrawCircle", header: raylibHeader.}
##  Draw a color-filled circle

proc drawCircleSector*(center: Vector2; radius: cfloat; startAngle: cfloat;
                      endAngle: cfloat; segments: cint; color: Color) {.cdecl,
    importc: "DrawCircleSector", header: raylibHeader.}
##  Draw a piece of a circle

proc drawCircleSectorLines*(center: Vector2; radius: cfloat; startAngle: cfloat;
                           endAngle: cfloat; segments: cint; color: Color) {.cdecl,
    importc: "DrawCircleSectorLines", header: raylibHeader.}
##  Draw circle sector outline

proc drawCircleGradient*(centerX: cint; centerY: cint; radius: cfloat; color1: Color;
                        color2: Color) {.cdecl, importc: "DrawCircleGradient",
                                       header: raylibHeader.}
##  Draw a gradient-filled circle

proc drawCircleV*(center: Vector2; radius: cfloat; color: Color) {.cdecl,
    importc: "DrawCircleV", header: raylibHeader.}
##  Draw a color-filled circle (Vector version)

proc drawCircleLines*(centerX: cint; centerY: cint; radius: cfloat; color: Color) {.
    cdecl, importc: "DrawCircleLines", header: raylibHeader.}
##  Draw circle outline

proc drawEllipse*(centerX: cint; centerY: cint; radiusH: cfloat; radiusV: cfloat;
                 color: Color) {.cdecl, importc: "DrawEllipse", header: raylibHeader.}
##  Draw ellipse

proc drawEllipseLines*(centerX: cint; centerY: cint; radiusH: cfloat; radiusV: cfloat;
                      color: Color) {.cdecl, importc: "DrawEllipseLines",
                                    header: raylibHeader.}
##  Draw ellipse outline

proc drawRing*(center: Vector2; innerRadius: cfloat; outerRadius: cfloat;
              startAngle: cfloat; endAngle: cfloat; segments: cint; color: Color) {.
    cdecl, importc: "DrawRing", header: raylibHeader.}
##  Draw ring

proc drawRingLines*(center: Vector2; innerRadius: cfloat; outerRadius: cfloat;
                   startAngle: cfloat; endAngle: cfloat; segments: cint; color: Color) {.
    cdecl, importc: "DrawRingLines", header: raylibHeader.}
##  Draw ring outline

proc drawRectangle*(posX: cint; posY: cint; width: cint; height: cint; color: Color) {.
    cdecl, importc: "DrawRectangle", header: raylibHeader.}
##  Draw a color-filled rectangle

proc drawRectangleV*(position: Vector2; size: Vector2; color: Color) {.cdecl,
    importc: "DrawRectangleV", header: raylibHeader.}
##  Draw a color-filled rectangle (Vector version)

proc drawRectangleRec*(rec: Rectangle; color: Color) {.cdecl,
    importc: "DrawRectangleRec", header: raylibHeader.}
##  Draw a color-filled rectangle

proc drawRectanglePro*(rec: Rectangle; origin: Vector2; rotation: cfloat; color: Color) {.
    cdecl, importc: "DrawRectanglePro", header: raylibHeader.}
##  Draw a color-filled rectangle with pro parameters

proc drawRectangleGradientV*(posX: cint; posY: cint; width: cint; height: cint;
                            color1: Color; color2: Color) {.cdecl,
    importc: "DrawRectangleGradientV", header: raylibHeader.}
##  Draw a vertical-gradient-filled rectangle

proc drawRectangleGradientH*(posX: cint; posY: cint; width: cint; height: cint;
                            color1: Color; color2: Color) {.cdecl,
    importc: "DrawRectangleGradientH", header: raylibHeader.}
##  Draw a horizontal-gradient-filled rectangle

proc drawRectangleGradientEx*(rec: Rectangle; col1: Color; col2: Color; col3: Color;
                             col4: Color) {.cdecl,
    importc: "DrawRectangleGradientEx", header: raylibHeader.}
##  Draw a gradient-filled rectangle with custom vertex colors

proc drawRectangleLines*(posX: cint; posY: cint; width: cint; height: cint; color: Color) {.
    cdecl, importc: "DrawRectangleLines", header: raylibHeader.}
##  Draw rectangle outline

proc drawRectangleLinesEx*(rec: Rectangle; lineThick: cint; color: Color) {.cdecl,
    importc: "DrawRectangleLinesEx", header: raylibHeader.}
##  Draw rectangle outline with extended parameters

proc drawRectangleRounded*(rec: Rectangle; roundness: cfloat; segments: cint;
                          color: Color) {.cdecl, importc: "DrawRectangleRounded",
                                        header: raylibHeader.}
##  Draw rectangle with rounded edges

proc drawRectangleRoundedLines*(rec: Rectangle; roundness: cfloat; segments: cint;
                               lineThick: cint; color: Color) {.cdecl,
    importc: "DrawRectangleRoundedLines", header: raylibHeader.}
##  Draw rectangle with rounded edges outline

proc drawTriangle*(v1: Vector2; v2: Vector2; v3: Vector2; color: Color) {.cdecl,
    importc: "DrawTriangle", header: raylibHeader.}
##  Draw a color-filled triangle (vertex in counter-clockwise order!)

proc drawTriangleLines*(v1: Vector2; v2: Vector2; v3: Vector2; color: Color) {.cdecl,
    importc: "DrawTriangleLines", header: raylibHeader.}
##  Draw triangle outline (vertex in counter-clockwise order!)

proc drawTriangleFan*(points: ptr Vector2; pointsCount: cint; color: Color) {.cdecl,
    importc: "DrawTriangleFan", header: raylibHeader.}
##  Draw a triangle fan defined by points (first vertex is the center)

proc drawTriangleStrip*(points: ptr Vector2; pointsCount: cint; color: Color) {.cdecl,
    importc: "DrawTriangleStrip", header: raylibHeader.}
##  Draw a triangle strip defined by points

proc drawPoly*(center: Vector2; sides: cint; radius: cfloat; rotation: cfloat;
              color: Color) {.cdecl, importc: "DrawPoly", header: raylibHeader.}
##  Draw a regular polygon (Vector version)

proc drawPolyLines*(center: Vector2; sides: cint; radius: cfloat; rotation: cfloat;
                   color: Color) {.cdecl, importc: "DrawPolyLines",
                                 header: raylibHeader.}
##  Draw a polygon outline of n sides
##  Basic shapes collision detection functions

proc checkCollisionRecs*(rec1: Rectangle; rec2: Rectangle): bool {.cdecl,
    importc: "CheckCollisionRecs", header: raylibHeader.}
##  Check collision between two rectangles

proc checkCollisionCircles*(center1: Vector2; radius1: cfloat; center2: Vector2;
                           radius2: cfloat): bool {.cdecl,
    importc: "CheckCollisionCircles", header: raylibHeader.}
##  Check collision between two circles

proc checkCollisionCircleRec*(center: Vector2; radius: cfloat; rec: Rectangle): bool {.
    cdecl, importc: "CheckCollisionCircleRec", header: raylibHeader.}
##  Check collision between circle and rectangle

proc checkCollisionPointRec*(point: Vector2; rec: Rectangle): bool {.cdecl,
    importc: "CheckCollisionPointRec", header: raylibHeader.}
##  Check if point is inside rectangle

proc checkCollisionPointCircle*(point: Vector2; center: Vector2; radius: cfloat): bool {.
    cdecl, importc: "CheckCollisionPointCircle", header: raylibHeader.}
##  Check if point is inside circle

proc checkCollisionPointTriangle*(point: Vector2; p1: Vector2; p2: Vector2; p3: Vector2): bool {.
    cdecl, importc: "CheckCollisionPointTriangle", header: raylibHeader.}
##  Check if point is inside a triangle

proc checkCollisionLines*(startPos1: Vector2; endPos1: Vector2; startPos2: Vector2;
                         endPos2: Vector2; collisionPoint: ptr Vector2): bool {.cdecl,
    importc: "CheckCollisionLines", header: raylibHeader.}
##  Check the collision between two lines defined by two points each, returns collision point by reference

proc getCollisionRec*(rec1: Rectangle; rec2: Rectangle): Rectangle {.cdecl,
    importc: "GetCollisionRec", header: raylibHeader.}
##  Get collision rectangle for two rectangles collision
## ------------------------------------------------------------------------------------
##  Texture Loading and Drawing Functions (Module: textures)
## ------------------------------------------------------------------------------------
##  Image loading functions
##  NOTE: This functions do not require GPU access

proc loadImage*(fileName: cstring): Image {.cdecl, importc: "NmrlbNow_LoadImage",
                                        header: raylibHeader.}
##  Load image from file into CPU memory (RAM)

proc loadImageRaw*(fileName: cstring; width: cint; height: cint; format: cint;
                  headerSize: cint): Image {.cdecl, importc: "LoadImageRaw",
    header: raylibHeader.}
##  Load image from RAW file data

proc loadImageAnim*(fileName: cstring; frames: ptr cint): Image {.cdecl,
    importc: "LoadImageAnim", header: raylibHeader.}
##  Load image sequence from file (frames appended to image.data)

proc loadImageFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: cint): Image {.
    cdecl, importc: "LoadImageFromMemory", header: raylibHeader.}
##  Load image from memory buffer, fileType refers to extension: i.e. ".png"

proc unloadImage*(image: Image) {.cdecl, importc: "UnloadImage", header: raylibHeader.}
##  Unload image from CPU memory (RAM)

proc exportImage*(image: Image; fileName: cstring): bool {.cdecl,
    importc: "ExportImage", header: raylibHeader.}
##  Export image data to file, returns true on success

proc exportImageAsCode*(image: Image; fileName: cstring): bool {.cdecl,
    importc: "ExportImageAsCode", header: raylibHeader.}
##  Export image as code file defining an array of bytes, returns true on success
##  Image generation functions

proc genImageColor*(width: cint; height: cint; color: Color): Image {.cdecl,
    importc: "GenImageColor", header: raylibHeader.}
##  Generate image: plain color

proc genImageGradientV*(width: cint; height: cint; top: Color; bottom: Color): Image {.
    cdecl, importc: "GenImageGradientV", header: raylibHeader.}
##  Generate image: vertical gradient

proc genImageGradientH*(width: cint; height: cint; left: Color; right: Color): Image {.
    cdecl, importc: "GenImageGradientH", header: raylibHeader.}
##  Generate image: horizontal gradient

proc genImageGradientRadial*(width: cint; height: cint; density: cfloat; inner: Color;
                            outer: Color): Image {.cdecl,
    importc: "GenImageGradientRadial", header: raylibHeader.}
##  Generate image: radial gradient

proc genImageChecked*(width: cint; height: cint; checksX: cint; checksY: cint;
                     col1: Color; col2: Color): Image {.cdecl,
    importc: "GenImageChecked", header: raylibHeader.}
##  Generate image: checked

proc genImageWhiteNoise*(width: cint; height: cint; factor: cfloat): Image {.cdecl,
    importc: "GenImageWhiteNoise", header: raylibHeader.}
##  Generate image: white noise

proc genImagePerlinNoise*(width: cint; height: cint; offsetX: cint; offsetY: cint;
                         scale: cfloat): Image {.cdecl,
    importc: "GenImagePerlinNoise", header: raylibHeader.}
##  Generate image: perlin noise

proc genImageCellular*(width: cint; height: cint; tileSize: cint): Image {.cdecl,
    importc: "GenImageCellular", header: raylibHeader.}
##  Generate image: cellular algorithm. Bigger tileSize means bigger cells
##  Image manipulation functions

proc imageCopy*(image: Image): Image {.cdecl, importc: "ImageCopy",
                                   header: raylibHeader.}
##  Create an image duplicate (useful for transformations)

proc imageFromImage*(image: Image; rec: Rectangle): Image {.cdecl,
    importc: "ImageFromImage", header: raylibHeader.}
##  Create an image from another image piece

proc imageText*(text: cstring; fontSize: cint; color: Color): Image {.cdecl,
    importc: "ImageText", header: raylibHeader.}
##  Create an image from text (default font)

proc imageTextEx*(font: Font; text: cstring; fontSize: cfloat; spacing: cfloat;
                 tint: Color): Image {.cdecl, importc: "ImageTextEx",
                                    header: raylibHeader.}
##  Create an image from text (custom sprite font)

proc imageFormat*(image: ptr Image; newFormat: cint) {.cdecl, importc: "ImageFormat",
    header: raylibHeader.}
##  Convert image data to desired format

proc imageToPOT*(image: ptr Image; fill: Color) {.cdecl, importc: "ImageToPOT",
    header: raylibHeader.}
##  Convert image to POT (power-of-two)

proc imageCrop*(image: ptr Image; crop: Rectangle) {.cdecl, importc: "ImageCrop",
    header: raylibHeader.}
##  Crop an image to a defined rectangle

proc imageAlphaCrop*(image: ptr Image; threshold: cfloat) {.cdecl,
    importc: "ImageAlphaCrop", header: raylibHeader.}
##  Crop image depending on alpha value

proc imageAlphaClear*(image: ptr Image; color: Color; threshold: cfloat) {.cdecl,
    importc: "ImageAlphaClear", header: raylibHeader.}
##  Clear alpha channel to desired color

proc imageAlphaMask*(image: ptr Image; alphaMask: Image) {.cdecl,
    importc: "ImageAlphaMask", header: raylibHeader.}
##  Apply alpha mask to image

proc imageAlphaPremultiply*(image: ptr Image) {.cdecl,
    importc: "ImageAlphaPremultiply", header: raylibHeader.}
##  Premultiply alpha channel

proc imageResize*(image: ptr Image; newWidth: cint; newHeight: cint) {.cdecl,
    importc: "ImageResize", header: raylibHeader.}
##  Resize image (Bicubic scaling algorithm)

proc imageResizeNN*(image: ptr Image; newWidth: cint; newHeight: cint) {.cdecl,
    importc: "ImageResizeNN", header: raylibHeader.}
##  Resize image (Nearest-Neighbor scaling algorithm)

proc imageResizeCanvas*(image: ptr Image; newWidth: cint; newHeight: cint;
                       offsetX: cint; offsetY: cint; fill: Color) {.cdecl,
    importc: "ImageResizeCanvas", header: raylibHeader.}
##  Resize canvas and fill with color

proc imageMipmaps*(image: ptr Image) {.cdecl, importc: "ImageMipmaps",
                                   header: raylibHeader.}
##  Generate all mipmap levels for a provided image

proc imageDither*(image: ptr Image; rBpp: cint; gBpp: cint; bBpp: cint; aBpp: cint) {.cdecl,
    importc: "ImageDither", header: raylibHeader.}
##  Dither image data to 16bpp or lower (Floyd-Steinberg dithering)

proc imageFlipVertical*(image: ptr Image) {.cdecl, importc: "ImageFlipVertical",
                                        header: raylibHeader.}
##  Flip image vertically

proc imageFlipHorizontal*(image: ptr Image) {.cdecl, importc: "ImageFlipHorizontal",
    header: raylibHeader.}
##  Flip image horizontally

proc imageRotateCW*(image: ptr Image) {.cdecl, importc: "ImageRotateCW",
                                    header: raylibHeader.}
##  Rotate image clockwise 90deg

proc imageRotateCCW*(image: ptr Image) {.cdecl, importc: "ImageRotateCCW",
                                     header: raylibHeader.}
##  Rotate image counter-clockwise 90deg

proc imageColorTint*(image: ptr Image; color: Color) {.cdecl,
    importc: "ImageColorTint", header: raylibHeader.}
##  Modify image color: tint

proc imageColorInvert*(image: ptr Image) {.cdecl, importc: "ImageColorInvert",
                                       header: raylibHeader.}
##  Modify image color: invert

proc imageColorGrayscale*(image: ptr Image) {.cdecl, importc: "ImageColorGrayscale",
    header: raylibHeader.}
##  Modify image color: grayscale

proc imageColorContrast*(image: ptr Image; contrast: cfloat) {.cdecl,
    importc: "ImageColorContrast", header: raylibHeader.}
##  Modify image color: contrast (-100 to 100)

proc imageColorBrightness*(image: ptr Image; brightness: cint) {.cdecl,
    importc: "ImageColorBrightness", header: raylibHeader.}
##  Modify image color: brightness (-255 to 255)

proc imageColorReplace*(image: ptr Image; color: Color; replace: Color) {.cdecl,
    importc: "ImageColorReplace", header: raylibHeader.}
##  Modify image color: replace color

proc loadImageColors*(image: Image): ptr Color {.cdecl, importc: "LoadImageColors",
    header: raylibHeader.}
##  Load color data from image as a Color array (RGBA - 32bit)

proc loadImagePalette*(image: Image; maxPaletteSize: cint; colorsCount: ptr cint): ptr Color {.
    cdecl, importc: "LoadImagePalette", header: raylibHeader.}
##  Load colors palette from image as a Color array (RGBA - 32bit)

proc unloadImageColors*(colors: ptr Color) {.cdecl, importc: "UnloadImageColors",
    header: raylibHeader.}
##  Unload color data loaded with LoadImageColors()

proc unloadImagePalette*(colors: ptr Color) {.cdecl, importc: "UnloadImagePalette",
    header: raylibHeader.}
##  Unload colors palette loaded with LoadImagePalette()

proc getImageAlphaBorder*(image: Image; threshold: cfloat): Rectangle {.cdecl,
    importc: "GetImageAlphaBorder", header: raylibHeader.}
##  Get image alpha border rectangle
##  Image drawing functions
##  NOTE: Image software-rendering functions (CPU)

proc imageClearBackground*(dst: ptr Image; color: Color) {.cdecl,
    importc: "ImageClearBackground", header: raylibHeader.}
##  Clear image background with given color

proc imageDrawPixel*(dst: ptr Image; posX: cint; posY: cint; color: Color) {.cdecl,
    importc: "ImageDrawPixel", header: raylibHeader.}
##  Draw pixel within an image

proc imageDrawPixelV*(dst: ptr Image; position: Vector2; color: Color) {.cdecl,
    importc: "ImageDrawPixelV", header: raylibHeader.}
##  Draw pixel within an image (Vector version)

proc imageDrawLine*(dst: ptr Image; startPosX: cint; startPosY: cint; endPosX: cint;
                   endPosY: cint; color: Color) {.cdecl, importc: "ImageDrawLine",
    header: raylibHeader.}
##  Draw line within an image

proc imageDrawLineV*(dst: ptr Image; start: Vector2; `end`: Vector2; color: Color) {.
    cdecl, importc: "ImageDrawLineV", header: raylibHeader.}
##  Draw line within an image (Vector version)

proc imageDrawCircle*(dst: ptr Image; centerX: cint; centerY: cint; radius: cint;
                     color: Color) {.cdecl, importc: "ImageDrawCircle",
                                   header: raylibHeader.}
##  Draw circle within an image

proc imageDrawCircleV*(dst: ptr Image; center: Vector2; radius: cint; color: Color) {.
    cdecl, importc: "ImageDrawCircleV", header: raylibHeader.}
##  Draw circle within an image (Vector version)

proc imageDrawRectangle*(dst: ptr Image; posX: cint; posY: cint; width: cint;
                        height: cint; color: Color) {.cdecl,
    importc: "ImageDrawRectangle", header: raylibHeader.}
##  Draw rectangle within an image

proc imageDrawRectangleV*(dst: ptr Image; position: Vector2; size: Vector2; color: Color) {.
    cdecl, importc: "ImageDrawRectangleV", header: raylibHeader.}
##  Draw rectangle within an image (Vector version)

proc imageDrawRectangleRec*(dst: ptr Image; rec: Rectangle; color: Color) {.cdecl,
    importc: "ImageDrawRectangleRec", header: raylibHeader.}
##  Draw rectangle within an image

proc imageDrawRectangleLines*(dst: ptr Image; rec: Rectangle; thick: cint; color: Color) {.
    cdecl, importc: "ImageDrawRectangleLines", header: raylibHeader.}
##  Draw rectangle lines within an image

proc imageDraw*(dst: ptr Image; src: Image; srcRec: Rectangle; dstRec: Rectangle;
               tint: Color) {.cdecl, importc: "ImageDraw", header: raylibHeader.}
##  Draw a source image within a destination image (tint applied to source)

proc imageDrawText*(dst: ptr Image; text: cstring; posX: cint; posY: cint; fontSize: cint;
                   color: Color) {.cdecl, importc: "ImageDrawText",
                                 header: raylibHeader.}
##  Draw text (using default font) within an image (destination)

proc imageDrawTextEx*(dst: ptr Image; font: Font; text: cstring; position: Vector2;
                     fontSize: cfloat; spacing: cfloat; tint: Color) {.cdecl,
    importc: "ImageDrawTextEx", header: raylibHeader.}
##  Draw text (custom sprite font) within an image (destination)
##  Texture loading functions
##  NOTE: These functions require GPU access

proc loadTexture*(fileName: cstring): Texture2D {.cdecl, importc: "LoadTexture",
    header: raylibHeader.}
##  Load texture from file into GPU memory (VRAM)

proc loadTextureFromImage*(image: Image): Texture2D {.cdecl,
    importc: "LoadTextureFromImage", header: raylibHeader.}
##  Load texture from image data

proc loadTextureCubemap*(image: Image; layout: cint): TextureCubemap {.cdecl,
    importc: "LoadTextureCubemap", header: raylibHeader.}
##  Load cubemap from image, multiple image cubemap layouts supported

proc loadRenderTexture*(width: cint; height: cint): RenderTexture2D {.cdecl,
    importc: "LoadRenderTexture", header: raylibHeader.}
##  Load texture for rendering (framebuffer)

proc unloadTexture*(texture: Texture2D) {.cdecl, importc: "UnloadTexture",
                                       header: raylibHeader.}
##  Unload texture from GPU memory (VRAM)

proc unloadRenderTexture*(target: RenderTexture2D) {.cdecl,
    importc: "UnloadRenderTexture", header: raylibHeader.}
##  Unload render texture from GPU memory (VRAM)

proc updateTexture*(texture: Texture2D; pixels: pointer) {.cdecl,
    importc: "UpdateTexture", header: raylibHeader.}
##  Update GPU texture with new data

proc updateTextureRec*(texture: Texture2D; rec: Rectangle; pixels: pointer) {.cdecl,
    importc: "UpdateTextureRec", header: raylibHeader.}
##  Update GPU texture rectangle with new data

proc getTextureData*(texture: Texture2D): Image {.cdecl, importc: "GetTextureData",
    header: raylibHeader.}
##  Get pixel data from GPU texture and return an Image

proc getScreenData*(): Image {.cdecl, importc: "GetScreenData", header: raylibHeader.}
##  Get pixel data from screen buffer and return an Image (screenshot)
##  Texture configuration functions

proc genTextureMipmaps*(texture: ptr Texture2D) {.cdecl,
    importc: "GenTextureMipmaps", header: raylibHeader.}
##  Generate GPU mipmaps for a texture

proc setTextureFilter*(texture: Texture2D; filter: cint) {.cdecl,
    importc: "SetTextureFilter", header: raylibHeader.}
##  Set texture scaling filter mode

proc setTextureWrap*(texture: Texture2D; wrap: cint) {.cdecl,
    importc: "SetTextureWrap", header: raylibHeader.}
##  Set texture wrapping mode
##  Texture drawing functions

proc drawTexture*(texture: Texture2D; posX: cint; posY: cint; tint: Color) {.cdecl,
    importc: "DrawTexture", header: raylibHeader.}
##  Draw a Texture2D

proc drawTextureV*(texture: Texture2D; position: Vector2; tint: Color) {.cdecl,
    importc: "DrawTextureV", header: raylibHeader.}
##  Draw a Texture2D with position defined as Vector2

proc drawTextureEx*(texture: Texture2D; position: Vector2; rotation: cfloat;
                   scale: cfloat; tint: Color) {.cdecl, importc: "DrawTextureEx",
    header: raylibHeader.}
##  Draw a Texture2D with extended parameters

proc drawTextureRec*(texture: Texture2D; source: Rectangle; position: Vector2;
                    tint: Color) {.cdecl, importc: "DrawTextureRec",
                                 header: raylibHeader.}
##  Draw a part of a texture defined by a rectangle

proc drawTextureQuad*(texture: Texture2D; tiling: Vector2; offset: Vector2;
                     quad: Rectangle; tint: Color) {.cdecl,
    importc: "DrawTextureQuad", header: raylibHeader.}
##  Draw texture quad with tiling and offset parameters

proc drawTextureTiled*(texture: Texture2D; source: Rectangle; dest: Rectangle;
                      origin: Vector2; rotation: cfloat; scale: cfloat; tint: Color) {.
    cdecl, importc: "DrawTextureTiled", header: raylibHeader.}
##  Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.

proc drawTexturePro*(texture: Texture2D; source: Rectangle; dest: Rectangle;
                    origin: Vector2; rotation: cfloat; tint: Color) {.cdecl,
    importc: "DrawTexturePro", header: raylibHeader.}
##  Draw a part of a texture defined by a rectangle with 'pro' parameters

proc drawTextureNPatch*(texture: Texture2D; nPatchInfo: NPatchInfo; dest: Rectangle;
                       origin: Vector2; rotation: cfloat; tint: Color) {.cdecl,
    importc: "DrawTextureNPatch", header: raylibHeader.}
##  Draws a texture (or part of it) that stretches or shrinks nicely

proc drawTexturePoly*(texture: Texture2D; center: Vector2; points: ptr Vector2;
                     texcoords: ptr Vector2; pointsCount: cint; tint: Color) {.cdecl,
    importc: "DrawTexturePoly", header: raylibHeader.}
##  Draw a textured polygon
##  Color/pixel related functions

proc fade*(color: Color; alpha: cfloat): Color {.cdecl, importc: "Fade",
    header: raylibHeader.}
##  Returns color with alpha applied, alpha goes from 0.0f to 1.0f

proc colorToInt*(color: Color): cint {.cdecl, importc: "ColorToInt",
                                   header: raylibHeader.}
##  Returns hexadecimal value for a Color

proc colorNormalize*(color: Color): Vector4 {.cdecl, importc: "ColorNormalize",
    header: raylibHeader.}
##  Returns Color normalized as float [0..1]

proc colorFromNormalized*(normalized: Vector4): Color {.cdecl,
    importc: "ColorFromNormalized", header: raylibHeader.}
##  Returns Color from normalized values [0..1]

proc colorToHSV*(color: Color): Vector3 {.cdecl, importc: "ColorToHSV",
                                      header: raylibHeader.}
##  Returns HSV values for a Color, hue [0..360], saturation/value [0..1]

proc colorFromHSV*(hue: cfloat; saturation: cfloat; value: cfloat): Color {.cdecl,
    importc: "ColorFromHSV", header: raylibHeader.}
##  Returns a Color from HSV values, hue [0..360], saturation/value [0..1]

proc colorAlpha*(color: Color; alpha: cfloat): Color {.cdecl, importc: "ColorAlpha",
    header: raylibHeader.}
##  Returns color with alpha applied, alpha goes from 0.0f to 1.0f

proc colorAlphaBlend*(dst: Color; src: Color; tint: Color): Color {.cdecl,
    importc: "ColorAlphaBlend", header: raylibHeader.}
##  Returns src alpha-blended into dst color with tint

proc getColor*(hexValue: cint): Color {.cdecl, importc: "GetColor",
                                    header: raylibHeader.}
##  Get Color structure from hexadecimal value

proc getPixelColor*(srcPtr: pointer; format: cint): Color {.cdecl,
    importc: "GetPixelColor", header: raylibHeader.}
##  Get Color from a source pixel pointer of certain format

proc setPixelColor*(dstPtr: pointer; color: Color; format: cint) {.cdecl,
    importc: "SetPixelColor", header: raylibHeader.}
##  Set color formatted into destination pixel pointer

proc getPixelDataSize*(width: cint; height: cint; format: cint): cint {.cdecl,
    importc: "GetPixelDataSize", header: raylibHeader.}
##  Get pixel data size in bytes for certain format
## ------------------------------------------------------------------------------------
##  Font Loading and Text Drawing Functions (Module: text)
## ------------------------------------------------------------------------------------
##  Font loading/unloading functions

proc getFontDefault*(): Font {.cdecl, importc: "GetFontDefault", header: raylibHeader.}
##  Get the default Font

proc loadFont*(fileName: cstring): Font {.cdecl, importc: "LoadFont",
                                      header: raylibHeader.}
##  Load font from file into GPU memory (VRAM)

proc loadFontEx*(fileName: cstring; fontSize: cint; fontChars: ptr cint;
                charsCount: cint): Font {.cdecl, importc: "LoadFontEx",
                                       header: raylibHeader.}
##  Load font from file with extended parameters

proc loadFontFromImage*(image: Image; key: Color; firstChar: cint): Font {.cdecl,
    importc: "LoadFontFromImage", header: raylibHeader.}
##  Load font from Image (XNA style)

proc loadFontFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: cint;
                        fontSize: cint; fontChars: ptr cint; charsCount: cint): Font {.
    cdecl, importc: "LoadFontFromMemory", header: raylibHeader.}
##  Load font from memory buffer, fileType refers to extension: i.e. ".ttf"

proc loadFontData*(fileData: ptr uint8; dataSize: cint; fontSize: cint;
                  fontChars: ptr cint; charsCount: cint; `type`: cint): ptr CharInfo {.
    cdecl, importc: "LoadFontData", header: raylibHeader.}
##  Load font data for further use

proc genImageFontAtlas*(chars: ptr CharInfo; recs: ptr ptr Rectangle; charsCount: cint;
                       fontSize: cint; padding: cint; packMethod: cint): Image {.cdecl,
    importc: "GenImageFontAtlas", header: raylibHeader.}
##  Generate image font atlas using chars info

proc unloadFontData*(chars: ptr CharInfo; charsCount: cint) {.cdecl,
    importc: "UnloadFontData", header: raylibHeader.}
##  Unload font chars info data (RAM)

proc unloadFont*(font: Font) {.cdecl, importc: "UnloadFont", header: raylibHeader.}
##  Unload Font from GPU memory (VRAM)
##  Text drawing functions

proc drawFPS*(posX: cint; posY: cint) {.cdecl, importc: "DrawFPS", header: raylibHeader.}
##  Draw current FPS

proc drawText*(text: cstring; posX: cint; posY: cint; fontSize: cint; color: Color) {.
    cdecl, importc: "NmrlbNow_DrawText", header: raylibHeader.}
##  Draw text (using default font)

proc drawTextEx*(font: Font; text: cstring; position: Vector2; fontSize: cfloat;
                spacing: cfloat; tint: Color) {.cdecl,
    importc: "NmrlbNow_DrawTextEx", header: raylibHeader.}
##  Draw text using font and additional parameters

proc drawTextRec*(font: Font; text: cstring; rec: Rectangle; fontSize: cfloat;
                 spacing: cfloat; wordWrap: bool; tint: Color) {.cdecl,
    importc: "DrawTextRec", header: raylibHeader.}
##  Draw text using font inside rectangle limits

proc drawTextRecEx*(font: Font; text: cstring; rec: Rectangle; fontSize: cfloat;
                   spacing: cfloat; wordWrap: bool; tint: Color; selectStart: cint;
                   selectLength: cint; selectTint: Color; selectBackTint: Color) {.
    cdecl, importc: "DrawTextRecEx", header: raylibHeader.}
##  Draw text using font inside rectangle limits with support for text selection

proc drawTextCodepoint*(font: Font; codepoint: cint; position: Vector2;
                       fontSize: cfloat; tint: Color) {.cdecl,
    importc: "DrawTextCodepoint", header: raylibHeader.}
##  Draw one character (codepoint)
##  Text misc. functions

proc measureText*(text: cstring; fontSize: cint): cint {.cdecl, importc: "MeasureText",
    header: raylibHeader.}
##  Measure string width for default font

proc measureTextEx*(font: Font; text: cstring; fontSize: cfloat; spacing: cfloat): Vector2 {.
    cdecl, importc: "MeasureTextEx", header: raylibHeader.}
##  Measure string size for Font

proc getGlyphIndex*(font: Font; codepoint: cint): cint {.cdecl,
    importc: "GetGlyphIndex", header: raylibHeader.}
##  Get index position for a unicode character on font
##  Text strings management functions (no utf8 strings, only byte chars)
##  NOTE: Some strings allocate memory internally for returned strings, just be careful!

proc textCopy*(dst: cstring; src: cstring): cint {.cdecl, importc: "TextCopy",
    header: raylibHeader.}
##  Copy one string to another, returns bytes copied

proc textIsEqual*(text1: cstring; text2: cstring): bool {.cdecl,
    importc: "TextIsEqual", header: raylibHeader.}
##  Check if two text string are equal

proc textLength*(text: cstring): cuint {.cdecl, importc: "TextLength",
                                     header: raylibHeader.}
##  Get text length, checks for '\0' ending

proc textFormat*(text: cstring): cstring {.varargs, cdecl, importc: "TextFormat",
                                       header: raylibHeader.}
##  Text formatting with variables (sprintf style)

proc textSubtext*(text: cstring; position: cint; length: cint): cstring {.cdecl,
    importc: "TextSubtext", header: raylibHeader.}
##  Get a piece of a text string

proc textReplace*(text: cstring; replace: cstring; by: cstring): cstring {.cdecl,
    importc: "TextReplace", header: raylibHeader.}
##  Replace text string (memory must be freed!)

proc textInsert*(text: cstring; insert: cstring; position: cint): cstring {.cdecl,
    importc: "TextInsert", header: raylibHeader.}
##  Insert text in a position (memory must be freed!)

proc textJoin*(textList: cstringArray; count: cint; delimiter: cstring): cstring {.
    cdecl, importc: "TextJoin", header: raylibHeader.}
##  Join text strings with delimiter

proc textSplit*(text: cstring; delimiter: char; count: ptr cint): cstringArray {.cdecl,
    importc: "TextSplit", header: raylibHeader.}
##  Split text into multiple strings

proc textAppend*(text: cstring; append: cstring; position: ptr cint) {.cdecl,
    importc: "TextAppend", header: raylibHeader.}
##  Append text at specific position and move cursor!

proc textFindIndex*(text: cstring; find: cstring): cint {.cdecl,
    importc: "TextFindIndex", header: raylibHeader.}
##  Find first text occurrence within a string

proc textToUpper*(text: cstring): cstring {.cdecl, importc: "TextToUpper",
                                        header: raylibHeader.}
##  Get upper case version of provided string

proc textToLower*(text: cstring): cstring {.cdecl, importc: "TextToLower",
                                        header: raylibHeader.}
##  Get lower case version of provided string

proc textToPascal*(text: cstring): cstring {.cdecl, importc: "TextToPascal",
    header: raylibHeader.}
##  Get Pascal case notation version of provided string

proc textToInteger*(text: cstring): cint {.cdecl, importc: "TextToInteger",
                                       header: raylibHeader.}
##  Get integer value from text (negative values not supported)

proc textToUtf8*(codepoints: ptr cint; length: cint): cstring {.cdecl,
    importc: "TextToUtf8", header: raylibHeader.}
##  Encode text codepoint into utf8 text (memory must be freed!)
##  UTF8 text strings management functions

proc getCodepoints*(text: cstring; count: ptr cint): ptr cint {.cdecl,
    importc: "GetCodepoints", header: raylibHeader.}
##  Get all codepoints in a string, codepoints count returned by parameters

proc getCodepointsCount*(text: cstring): cint {.cdecl, importc: "GetCodepointsCount",
    header: raylibHeader.}
##  Get total number of characters (codepoints) in a UTF8 encoded string

proc getNextCodepoint*(text: cstring; bytesProcessed: ptr cint): cint {.cdecl,
    importc: "GetNextCodepoint", header: raylibHeader.}
##  Returns next codepoint in a UTF8 encoded string; 0x3f('?') is returned on failure

proc codepointToUtf8*(codepoint: cint; byteLength: ptr cint): cstring {.cdecl,
    importc: "CodepointToUtf8", header: raylibHeader.}
##  Encode codepoint into utf8 text (char array length returned as parameter)
## ------------------------------------------------------------------------------------
##  Basic 3d Shapes Drawing Functions (Module: models)
## ------------------------------------------------------------------------------------
##  Basic geometric 3D shapes drawing functions

proc drawLine3D*(startPos: Vector3; endPos: Vector3; color: Color) {.cdecl,
    importc: "DrawLine3D", header: raylibHeader.}
##  Draw a line in 3D world space

proc drawPoint3D*(position: Vector3; color: Color) {.cdecl, importc: "DrawPoint3D",
    header: raylibHeader.}
##  Draw a point in 3D space, actually a small line

proc drawCircle3D*(center: Vector3; radius: cfloat; rotationAxis: Vector3;
                  rotationAngle: cfloat; color: Color) {.cdecl,
    importc: "DrawCircle3D", header: raylibHeader.}
##  Draw a circle in 3D world space

proc drawTriangle3D*(v1: Vector3; v2: Vector3; v3: Vector3; color: Color) {.cdecl,
    importc: "DrawTriangle3D", header: raylibHeader.}
##  Draw a color-filled triangle (vertex in counter-clockwise order!)

proc drawTriangleStrip3D*(points: ptr Vector3; pointsCount: cint; color: Color) {.cdecl,
    importc: "DrawTriangleStrip3D", header: raylibHeader.}
##  Draw a triangle strip defined by points

proc drawCube*(position: Vector3; width: cfloat; height: cfloat; length: cfloat;
              color: Color) {.cdecl, importc: "DrawCube", header: raylibHeader.}
##  Draw cube

proc drawCubeV*(position: Vector3; size: Vector3; color: Color) {.cdecl,
    importc: "DrawCubeV", header: raylibHeader.}
##  Draw cube (Vector version)

proc drawCubeWires*(position: Vector3; width: cfloat; height: cfloat; length: cfloat;
                   color: Color) {.cdecl, importc: "DrawCubeWires",
                                 header: raylibHeader.}
##  Draw cube wires

proc drawCubeWiresV*(position: Vector3; size: Vector3; color: Color) {.cdecl,
    importc: "DrawCubeWiresV", header: raylibHeader.}
##  Draw cube wires (Vector version)

proc drawCubeTexture*(texture: Texture2D; position: Vector3; width: cfloat;
                     height: cfloat; length: cfloat; color: Color) {.cdecl,
    importc: "DrawCubeTexture", header: raylibHeader.}
##  Draw cube textured

proc drawSphere*(centerPos: Vector3; radius: cfloat; color: Color) {.cdecl,
    importc: "DrawSphere", header: raylibHeader.}
##  Draw sphere

proc drawSphereEx*(centerPos: Vector3; radius: cfloat; rings: cint; slices: cint;
                  color: Color) {.cdecl, importc: "DrawSphereEx",
                                header: raylibHeader.}
##  Draw sphere with extended parameters

proc drawSphereWires*(centerPos: Vector3; radius: cfloat; rings: cint; slices: cint;
                     color: Color) {.cdecl, importc: "DrawSphereWires",
                                   header: raylibHeader.}
##  Draw sphere wires

proc drawCylinder*(position: Vector3; radiusTop: cfloat; radiusBottom: cfloat;
                  height: cfloat; slices: cint; color: Color) {.cdecl,
    importc: "DrawCylinder", header: raylibHeader.}
##  Draw a cylinder/cone

proc drawCylinderWires*(position: Vector3; radiusTop: cfloat; radiusBottom: cfloat;
                       height: cfloat; slices: cint; color: Color) {.cdecl,
    importc: "DrawCylinderWires", header: raylibHeader.}
##  Draw a cylinder/cone wires

proc drawPlane*(centerPos: Vector3; size: Vector2; color: Color) {.cdecl,
    importc: "DrawPlane", header: raylibHeader.}
##  Draw a plane XZ

proc drawRay*(ray: Ray; color: Color) {.cdecl, importc: "DrawRay", header: raylibHeader.}
##  Draw a ray line

proc drawGrid*(slices: cint; spacing: cfloat) {.cdecl, importc: "DrawGrid",
    header: raylibHeader.}
##  Draw a grid (centered at (0, 0, 0))
## ------------------------------------------------------------------------------------
##  Model 3d Loading and Drawing Functions (Module: models)
## ------------------------------------------------------------------------------------
##  Model loading/unloading functions

proc loadModel*(fileName: cstring): Model {.cdecl, importc: "LoadModel",
                                        header: raylibHeader.}
##  Load model from files (meshes and materials)

proc loadModelFromMesh*(mesh: Mesh): Model {.cdecl, importc: "LoadModelFromMesh",
    header: raylibHeader.}
##  Load model from generated mesh (default material)

proc unloadModel*(model: Model) {.cdecl, importc: "UnloadModel", header: raylibHeader.}
##  Unload model (including meshes) from memory (RAM and/or VRAM)

proc unloadModelKeepMeshes*(model: Model) {.cdecl, importc: "UnloadModelKeepMeshes",
    header: raylibHeader.}
##  Unload model (but not meshes) from memory (RAM and/or VRAM)
##  Mesh loading/unloading functions

proc uploadMesh*(mesh: ptr Mesh; dynamic: bool) {.cdecl, importc: "UploadMesh",
    header: raylibHeader.}
##  Upload mesh vertex data in GPU and provide VAO/VBO ids

proc updateMeshBuffer*(mesh: Mesh; index: cint; data: pointer; dataSize: cint;
                      offset: cint) {.cdecl, importc: "UpdateMeshBuffer",
                                    header: raylibHeader.}
##  Update mesh vertex data in GPU for a specific buffer index

proc drawMesh*(mesh: Mesh; material: Material; transform: Matrix) {.cdecl,
    importc: "DrawMesh", header: raylibHeader.}
##  Draw a 3d mesh with material and transform

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: ptr Matrix;
                       instances: cint) {.cdecl, importc: "DrawMeshInstanced",
                                        header: raylibHeader.}
##  Draw multiple mesh instances with material and different transforms

proc unloadMesh*(mesh: Mesh) {.cdecl, importc: "UnloadMesh", header: raylibHeader.}
##  Unload mesh data from CPU and GPU

proc exportMesh*(mesh: Mesh; fileName: cstring): bool {.cdecl, importc: "ExportMesh",
    header: raylibHeader.}
##  Export mesh data to file, returns true on success
##  Material loading/unloading functions

proc loadMaterials*(fileName: cstring; materialCount: ptr cint): ptr Material {.cdecl,
    importc: "LoadMaterials", header: raylibHeader.}
##  Load materials from model file

proc loadMaterialDefault*(): Material {.cdecl, importc: "LoadMaterialDefault",
                                     header: raylibHeader.}
##  Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)

proc unloadMaterial*(material: Material) {.cdecl, importc: "UnloadMaterial",
                                        header: raylibHeader.}
##  Unload material from GPU memory (VRAM)

proc setMaterialTexture*(material: ptr Material; mapType: cint; texture: Texture2D) {.
    cdecl, importc: "SetMaterialTexture", header: raylibHeader.}
##  Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)

proc setModelMeshMaterial*(model: ptr Model; meshId: cint; materialId: cint) {.cdecl,
    importc: "SetModelMeshMaterial", header: raylibHeader.}
##  Set material for a mesh
##  Model animations loading/unloading functions

proc loadModelAnimations*(fileName: cstring; animsCount: ptr cint): ptr ModelAnimation {.
    cdecl, importc: "LoadModelAnimations", header: raylibHeader.}
##  Load model animations from file

proc updateModelAnimation*(model: Model; anim: ModelAnimation; frame: cint) {.cdecl,
    importc: "UpdateModelAnimation", header: raylibHeader.}
##  Update model animation pose

proc unloadModelAnimation*(anim: ModelAnimation) {.cdecl,
    importc: "UnloadModelAnimation", header: raylibHeader.}
##  Unload animation data

proc unloadModelAnimations*(animations: ptr ModelAnimation; count: cuint) {.cdecl,
    importc: "UnloadModelAnimations", header: raylibHeader.}
##  Unload animation array data

proc isModelAnimationValid*(model: Model; anim: ModelAnimation): bool {.cdecl,
    importc: "IsModelAnimationValid", header: raylibHeader.}
##  Check model animation skeleton match
##  Mesh generation functions

proc genMeshPoly*(sides: cint; radius: cfloat): Mesh {.cdecl, importc: "GenMeshPoly",
    header: raylibHeader.}
##  Generate polygonal mesh

proc genMeshPlane*(width: cfloat; length: cfloat; resX: cint; resZ: cint): Mesh {.cdecl,
    importc: "GenMeshPlane", header: raylibHeader.}
##  Generate plane mesh (with subdivisions)

proc genMeshCube*(width: cfloat; height: cfloat; length: cfloat): Mesh {.cdecl,
    importc: "GenMeshCube", header: raylibHeader.}
##  Generate cuboid mesh

proc genMeshSphere*(radius: cfloat; rings: cint; slices: cint): Mesh {.cdecl,
    importc: "GenMeshSphere", header: raylibHeader.}
##  Generate sphere mesh (standard sphere)

proc genMeshHemiSphere*(radius: cfloat; rings: cint; slices: cint): Mesh {.cdecl,
    importc: "GenMeshHemiSphere", header: raylibHeader.}
##  Generate half-sphere mesh (no bottom cap)

proc genMeshCylinder*(radius: cfloat; height: cfloat; slices: cint): Mesh {.cdecl,
    importc: "GenMeshCylinder", header: raylibHeader.}
##  Generate cylinder mesh

proc genMeshTorus*(radius: cfloat; size: cfloat; radSeg: cint; sides: cint): Mesh {.cdecl,
    importc: "GenMeshTorus", header: raylibHeader.}
##  Generate torus mesh

proc genMeshKnot*(radius: cfloat; size: cfloat; radSeg: cint; sides: cint): Mesh {.cdecl,
    importc: "GenMeshKnot", header: raylibHeader.}
##  Generate trefoil knot mesh

proc genMeshHeightmap*(heightmap: Image; size: Vector3): Mesh {.cdecl,
    importc: "GenMeshHeightmap", header: raylibHeader.}
##  Generate heightmap mesh from image data

proc genMeshCubicmap*(cubicmap: Image; cubeSize: Vector3): Mesh {.cdecl,
    importc: "GenMeshCubicmap", header: raylibHeader.}
##  Generate cubes-based map mesh from image data
##  Mesh manipulation functions

proc meshBoundingBox*(mesh: Mesh): BoundingBox {.cdecl, importc: "MeshBoundingBox",
    header: raylibHeader.}
##  Compute mesh bounding box limits

proc meshTangents*(mesh: ptr Mesh) {.cdecl, importc: "MeshTangents",
                                 header: raylibHeader.}
##  Compute mesh tangents

proc meshBinormals*(mesh: ptr Mesh) {.cdecl, importc: "MeshBinormals",
                                  header: raylibHeader.}
##  Compute mesh binormals
##  Model drawing functions

proc drawModel*(model: Model; position: Vector3; scale: cfloat; tint: Color) {.cdecl,
    importc: "DrawModel", header: raylibHeader.}
##  Draw a model (with texture if set)

proc drawModelEx*(model: Model; position: Vector3; rotationAxis: Vector3;
                 rotationAngle: cfloat; scale: Vector3; tint: Color) {.cdecl,
    importc: "DrawModelEx", header: raylibHeader.}
##  Draw a model with extended parameters

proc drawModelWires*(model: Model; position: Vector3; scale: cfloat; tint: Color) {.
    cdecl, importc: "DrawModelWires", header: raylibHeader.}
##  Draw a model wires (with texture if set)

proc drawModelWiresEx*(model: Model; position: Vector3; rotationAxis: Vector3;
                      rotationAngle: cfloat; scale: Vector3; tint: Color) {.cdecl,
    importc: "DrawModelWiresEx", header: raylibHeader.}
##  Draw a model wires (with texture if set) with extended parameters

proc drawBoundingBox*(box: BoundingBox; color: Color) {.cdecl,
    importc: "DrawBoundingBox", header: raylibHeader.}
##  Draw bounding box (wires)

proc drawBillboard*(camera: Camera; texture: Texture2D; center: Vector3; size: cfloat;
                   tint: Color) {.cdecl, importc: "DrawBillboard",
                                header: raylibHeader.}
##  Draw a billboard texture

proc drawBillboardRec*(camera: Camera; texture: Texture2D; source: Rectangle;
                      center: Vector3; size: cfloat; tint: Color) {.cdecl,
    importc: "DrawBillboardRec", header: raylibHeader.}
##  Draw a billboard texture defined by source
##  Collision detection functions

proc checkCollisionSpheres*(center1: Vector3; radius1: cfloat; center2: Vector3;
                           radius2: cfloat): bool {.cdecl,
    importc: "CheckCollisionSpheres", header: raylibHeader.}
##  Detect collision between two spheres

proc checkCollisionBoxes*(box1: BoundingBox; box2: BoundingBox): bool {.cdecl,
    importc: "CheckCollisionBoxes", header: raylibHeader.}
##  Detect collision between two bounding boxes

proc checkCollisionBoxSphere*(box: BoundingBox; center: Vector3; radius: cfloat): bool {.
    cdecl, importc: "CheckCollisionBoxSphere", header: raylibHeader.}
##  Detect collision between box and sphere

proc checkCollisionRaySphere*(ray: Ray; center: Vector3; radius: cfloat): bool {.cdecl,
    importc: "CheckCollisionRaySphere", header: raylibHeader.}
##  Detect collision between ray and sphere

proc checkCollisionRaySphereEx*(ray: Ray; center: Vector3; radius: cfloat;
                               collisionPoint: ptr Vector3): bool {.cdecl,
    importc: "CheckCollisionRaySphereEx", header: raylibHeader.}
##  Detect collision between ray and sphere, returns collision point

proc checkCollisionRayBox*(ray: Ray; box: BoundingBox): bool {.cdecl,
    importc: "CheckCollisionRayBox", header: raylibHeader.}
##  Detect collision between ray and box

proc getCollisionRayMesh*(ray: Ray; mesh: Mesh; transform: Matrix): RayHitInfo {.cdecl,
    importc: "GetCollisionRayMesh", header: raylibHeader.}
##  Get collision info between ray and mesh

proc getCollisionRayModel*(ray: Ray; model: Model): RayHitInfo {.cdecl,
    importc: "GetCollisionRayModel", header: raylibHeader.}
##  Get collision info between ray and model

proc getCollisionRayTriangle*(ray: Ray; p1: Vector3; p2: Vector3; p3: Vector3): RayHitInfo {.
    cdecl, importc: "GetCollisionRayTriangle", header: raylibHeader.}
##  Get collision info between ray and triangle

proc getCollisionRayGround*(ray: Ray; groundHeight: cfloat): RayHitInfo {.cdecl,
    importc: "GetCollisionRayGround", header: raylibHeader.}
##  Get collision info between ray and ground plane (Y-normal plane)
## ------------------------------------------------------------------------------------
##  Audio Loading and Playing Functions (Module: audio)
## ------------------------------------------------------------------------------------
##  Audio device management functions

proc initAudioDevice*() {.cdecl, importc: "InitAudioDevice", header: raylibHeader.}
##  Initialize audio device and context

proc closeAudioDevice*() {.cdecl, importc: "CloseAudioDevice", header: raylibHeader.}
##  Close the audio device and context

proc isAudioDeviceReady*(): bool {.cdecl, importc: "IsAudioDeviceReady",
                                header: raylibHeader.}
##  Check if audio device has been initialized successfully

proc setMasterVolume*(volume: cfloat) {.cdecl, importc: "SetMasterVolume",
                                     header: raylibHeader.}
##  Set master volume (listener)
##  Wave/Sound loading/unloading functions

proc loadWave*(fileName: cstring): Wave {.cdecl, importc: "LoadWave",
                                      header: raylibHeader.}
##  Load wave data from file

proc loadWaveFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: cint): Wave {.
    cdecl, importc: "LoadWaveFromMemory", header: raylibHeader.}
##  Load wave from memory buffer, fileType refers to extension: i.e. ".wav"

proc loadSound*(fileName: cstring): Sound {.cdecl, importc: "LoadSound",
                                        header: raylibHeader.}
##  Load sound from file

proc loadSoundFromWave*(wave: Wave): Sound {.cdecl, importc: "LoadSoundFromWave",
    header: raylibHeader.}
##  Load sound from wave data

proc updateSound*(sound: Sound; data: pointer; samplesCount: cint) {.cdecl,
    importc: "UpdateSound", header: raylibHeader.}
##  Update sound buffer with new data

proc unloadWave*(wave: Wave) {.cdecl, importc: "UnloadWave", header: raylibHeader.}
##  Unload wave data

proc unloadSound*(sound: Sound) {.cdecl, importc: "UnloadSound", header: raylibHeader.}
##  Unload sound

proc exportWave*(wave: Wave; fileName: cstring): bool {.cdecl, importc: "ExportWave",
    header: raylibHeader.}
##  Export wave data to file, returns true on success

proc exportWaveAsCode*(wave: Wave; fileName: cstring): bool {.cdecl,
    importc: "ExportWaveAsCode", header: raylibHeader.}
##  Export wave sample data to code (.h), returns true on success
##  Wave/Sound management functions

proc playSound*(sound: Sound) {.cdecl, importc: "PlaySound", header: raylibHeader.}
##  Play a sound

proc stopSound*(sound: Sound) {.cdecl, importc: "StopSound", header: raylibHeader.}
##  Stop playing a sound

proc pauseSound*(sound: Sound) {.cdecl, importc: "PauseSound", header: raylibHeader.}
##  Pause a sound

proc resumeSound*(sound: Sound) {.cdecl, importc: "ResumeSound", header: raylibHeader.}
##  Resume a paused sound

proc playSoundMulti*(sound: Sound) {.cdecl, importc: "PlaySoundMulti",
                                  header: raylibHeader.}
##  Play a sound (using multichannel buffer pool)

proc stopSoundMulti*() {.cdecl, importc: "StopSoundMulti", header: raylibHeader.}
##  Stop any sound playing (using multichannel buffer pool)

proc getSoundsPlaying*(): cint {.cdecl, importc: "GetSoundsPlaying",
                              header: raylibHeader.}
##  Get number of sounds playing in the multichannel

proc isSoundPlaying*(sound: Sound): bool {.cdecl, importc: "IsSoundPlaying",
                                       header: raylibHeader.}
##  Check if a sound is currently playing

proc setSoundVolume*(sound: Sound; volume: cfloat) {.cdecl, importc: "SetSoundVolume",
    header: raylibHeader.}
##  Set volume for a sound (1.0 is max level)

proc setSoundPitch*(sound: Sound; pitch: cfloat) {.cdecl, importc: "SetSoundPitch",
    header: raylibHeader.}
##  Set pitch for a sound (1.0 is base level)

proc waveFormat*(wave: ptr Wave; sampleRate: cint; sampleSize: cint; channels: cint) {.
    cdecl, importc: "WaveFormat", header: raylibHeader.}
##  Convert wave data to desired format

proc waveCopy*(wave: Wave): Wave {.cdecl, importc: "WaveCopy", header: raylibHeader.}
##  Copy a wave to a new wave

proc waveCrop*(wave: ptr Wave; initSample: cint; finalSample: cint) {.cdecl,
    importc: "WaveCrop", header: raylibHeader.}
##  Crop a wave to defined samples range

proc loadWaveSamples*(wave: Wave): ptr cfloat {.cdecl, importc: "LoadWaveSamples",
    header: raylibHeader.}
##  Load samples data from wave as a floats array

proc unloadWaveSamples*(samples: ptr cfloat) {.cdecl, importc: "UnloadWaveSamples",
    header: raylibHeader.}
##  Unload samples data loaded with LoadWaveSamples()
##  Music management functions

proc loadMusicStream*(fileName: cstring): Music {.cdecl, importc: "LoadMusicStream",
    header: raylibHeader.}
##  Load music stream from file

proc loadMusicStreamFromMemory*(fileType: cstring; data: ptr uint8; dataSize: cint): Music {.
    cdecl, importc: "LoadMusicStreamFromMemory", header: raylibHeader.}
##  Load music stream from data

proc unloadMusicStream*(music: Music) {.cdecl, importc: "UnloadMusicStream",
                                     header: raylibHeader.}
##  Unload music stream

proc playMusicStream*(music: Music) {.cdecl, importc: "PlayMusicStream",
                                   header: raylibHeader.}
##  Start music playing

proc isMusicPlaying*(music: Music): bool {.cdecl, importc: "IsMusicPlaying",
                                       header: raylibHeader.}
##  Check if music is playing

proc updateMusicStream*(music: Music) {.cdecl, importc: "UpdateMusicStream",
                                     header: raylibHeader.}
##  Updates buffers for music streaming

proc stopMusicStream*(music: Music) {.cdecl, importc: "StopMusicStream",
                                   header: raylibHeader.}
##  Stop music playing

proc pauseMusicStream*(music: Music) {.cdecl, importc: "PauseMusicStream",
                                    header: raylibHeader.}
##  Pause music playing

proc resumeMusicStream*(music: Music) {.cdecl, importc: "ResumeMusicStream",
                                     header: raylibHeader.}
##  Resume playing paused music

proc setMusicVolume*(music: Music; volume: cfloat) {.cdecl, importc: "SetMusicVolume",
    header: raylibHeader.}
##  Set volume for music (1.0 is max level)

proc setMusicPitch*(music: Music; pitch: cfloat) {.cdecl, importc: "SetMusicPitch",
    header: raylibHeader.}
##  Set pitch for a music (1.0 is base level)

proc getMusicTimeLength*(music: Music): cfloat {.cdecl,
    importc: "GetMusicTimeLength", header: raylibHeader.}
##  Get music time length (in seconds)

proc getMusicTimePlayed*(music: Music): cfloat {.cdecl,
    importc: "GetMusicTimePlayed", header: raylibHeader.}
##  Get current music time played (in seconds)
##  AudioStream management functions

proc initAudioStream*(sampleRate: cuint; sampleSize: cuint; channels: cuint): AudioStream {.
    cdecl, importc: "InitAudioStream", header: raylibHeader.}
##  Init audio stream (to stream raw audio pcm data)

proc updateAudioStream*(stream: AudioStream; data: pointer; samplesCount: cint) {.
    cdecl, importc: "UpdateAudioStream", header: raylibHeader.}
##  Update audio stream buffers with data

proc closeAudioStream*(stream: AudioStream) {.cdecl, importc: "CloseAudioStream",
    header: raylibHeader.}
##  Close audio stream and free memory

proc isAudioStreamProcessed*(stream: AudioStream): bool {.cdecl,
    importc: "IsAudioStreamProcessed", header: raylibHeader.}
##  Check if any audio stream buffers requires refill

proc playAudioStream*(stream: AudioStream) {.cdecl, importc: "PlayAudioStream",
    header: raylibHeader.}
##  Play audio stream

proc pauseAudioStream*(stream: AudioStream) {.cdecl, importc: "PauseAudioStream",
    header: raylibHeader.}
##  Pause audio stream

proc resumeAudioStream*(stream: AudioStream) {.cdecl, importc: "ResumeAudioStream",
    header: raylibHeader.}
##  Resume audio stream

proc isAudioStreamPlaying*(stream: AudioStream): bool {.cdecl,
    importc: "IsAudioStreamPlaying", header: raylibHeader.}
##  Check if audio stream is playing

proc stopAudioStream*(stream: AudioStream) {.cdecl, importc: "StopAudioStream",
    header: raylibHeader.}
##  Stop audio stream

proc setAudioStreamVolume*(stream: AudioStream; volume: cfloat) {.cdecl,
    importc: "SetAudioStreamVolume", header: raylibHeader.}
##  Set volume for audio stream (1.0 is max level)

proc setAudioStreamPitch*(stream: AudioStream; pitch: cfloat) {.cdecl,
    importc: "SetAudioStreamPitch", header: raylibHeader.}
##  Set pitch for audio stream (1.0 is base level)

proc setAudioStreamBufferSizeDefault*(size: cint) {.cdecl,
    importc: "SetAudioStreamBufferSizeDefault", header: raylibHeader.}
##  Default size for new audio streams

const Lightgray* = Color(r: 200, g: 200, b: 200, a: 255)
const Gray* = Color(r: 130, g: 130, b: 130, a: 255)
const Darkgray* = Color(r: 80, g: 80, b: 80, a: 255)
const Yellow* = Color(r: 253, g: 249, b: 0, a: 255)
const Gold* = Color(r: 255, g: 203, b: 0, a: 255)
const Orange* = Color(r: 255, g: 161, b: 0, a: 255)
const Pink* = Color(r: 255, g: 109, b: 194, a: 255)
const Red* = Color(r: 230, g: 41, b: 55, a: 255)
const Maroon* = Color(r: 190, g: 33, b: 55, a: 255)
const Green* = Color(r: 0, g: 228, b: 48, a: 255)
const Lime* = Color(r: 0, g: 158, b: 47, a: 255)
const Darkgreen* = Color(r: 0, g: 117, b: 44, a: 255)
const Skyblue* = Color(r: 102, g: 191, b: 255, a: 255)
const Blue* = Color(r: 0, g: 121, b: 241, a: 255)
const Darkblue* = Color(r: 0, g: 82, b: 172, a: 255)
const Purple* = Color(r: 200, g: 122, b: 255, a: 255)
const Violet* = Color(r: 135, g: 60, b: 190, a: 255)
const Darkpurple* = Color(r: 112, g: 31, b: 126, a: 255)
const Beige* = Color(r: 211, g: 176, b: 131, a: 255)
const Brown* = Color(r: 127, g: 106, b: 79, a: 255)
const Darkbrown* = Color(r: 76, g: 63, b: 47, a: 255)
const White* = Color(r: 255, g: 255, b: 255, a: 255)
const Black* = Color(r: 0, g: 0, b: 0, a: 255)
const Blank* = Color(r: 0, g: 0, b: 0, a: 0)
const Magenta* = Color(r: 255, g: 0, b: 255, a: 255)
const Raywhite* = Color(r: 245, g: 245, b: 245, a: 255)

template beginDrawing*(body: untyped) =
  beginDrawing()
  block:
    body
  endDrawing()

template beginMode2D*(camera: Camera2D; body: untyped) =
  beginMode2D(camera)
  block:
    body
  endMode2D()

template beginMode3D*(camera: Camera3D; body: untyped) =
  beginMode3D(camera)
  block:
    body
  endMode3D()

template beginTextureMode*(target: RenderTexture2D; body: untyped) =
  beginTextureMode(target)
  block:
    body
  endTextureMode()

template beginShaderMode*(shader: Shader; body: untyped) =
  beginShaderMode(shader)
  block:
    body
  endShaderMode()

template beginBlendMode*(mode: cint; body: untyped) =
  beginBlendMode(mode)
  block:
    body
  endBlendMode()

template beginScissorMode*(x: cint; y: cint; width: cint; height: cint; body: untyped) =
  beginScissorMode(x, y, width, height)
  block:
    body
  endScissorMode()

template beginVrStereoMode*(config: VrStereoConfig; body: untyped) =
  beginVrStereoMode(config)
  block:
    body
  endVrStereoMode()

