#/**********************************************************************************************
#*
#*   raylib - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
#*
#*   FEATURES:
#*       - NO external dependencies, all required libraries included with raylib
#*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly, MacOS, UWP, Android, Raspberry Pi, HTML5.
#*       - Written in plain C code (C99) in PascalCase/camelCase notation
#*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3 or ES2 - choose at compile)
#*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
#*       - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
#*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
#*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
#*       - Flexible Materials system, supporting classic maps and PBR maps
#*       - Skeletal Animation support (CPU bones-based animation)
#*       - Shaders support, including Model shaders and Postprocessing shaders
#*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
#*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
#*       - VR stereo rendering with configurable HMD device parameters
#*       - Bindings to multiple programming languages available!
#*
#*   NOTES:
#*       One custom font is loaded by default when InitWindow() [core]
#*       If using OpenGL 3.3 or ES2, one default shader is loaded automatically (internally defined) [rlgl]
#*       If using OpenGL 3.3 or ES2, several vertex buffers (VAO/VBO) are created to manage lines-triangles-quads
#*
#*   DEPENDENCIES (included):
#*       [core] rglfw (github.com/glfw/glfw) for window/context management and input (only PLATFORM_DESKTOP)
#*       [rlgl] glad (github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (only PLATFORM_DESKTOP)
#*       [raudio] miniaudio (github.com/dr-soft/miniaudio) for audio device/context management
#*
#*   OPTIONAL DEPENDENCIES (included):
#*       [core] rgif (Charlie Tangora, Ramon Santamaria) for GIF recording
#*       [textures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
#*       [textures] stb_image_write (Sean Barret) for image writting (BMP, TGA, PNG, JPG)
#*       [textures] stb_image_resize (Sean Barret) for image resizing algorithms
#*       [textures] stb_perlin (Sean Barret) for Perlin noise image generation
#*       [text] stb_truetype (Sean Barret) for ttf fonts loading
#*       [text] stb_rect_pack (Sean Barret) for rectangles packing
#*       [models] par_shapes (Philip Rideout) for parametric 3d shapes generation
#*       [models] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
#*       [models] cgltf (Johannes Kuhlmann) for models loading (glTF)
#*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
#*       [raudio] dr_flac (David Reid) for FLAC audio file loading
#*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
#*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
#*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
#*
#*
#*   LICENSE: zlib/libpng
#*
#*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#*   BSD-like license that allows static linking with closed source software:
#*
#*   Copyright (c) 2013-2021 Ramon Santamaria (@raysan5)
#*
#*   This software is provided "as-is", without any express or implied warranty. In no event
#*   will the authors be held liable for any damages arising from the use of this software.
#*
#*   Permission is granted to anyone to use this software for any purpose, including commercial
#*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#*
#*     1. The origin of this software must not be misrepresented; you must not claim that you
#*     wrote the original software. If you use this software in a product, an acknowledgment
#*     in the product documentation would be appreciated but is not required.
#*
#*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#*     as being the original software.
#*
#*     3. This notice may not be removed or altered from any source distribution.
#*
#**********************************************************************************************/

##ifndef RAYLIB_H
const LEXT* = when defined(windows):".dll"
elif defined(macosx):               ".dylib"
else:                               ".so"
{.pragma: RLAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}


##include <stdarg.h>     // Required for: va_list - Only used by TraceLogCallback

##if defined(_WIN32)
    # Microsoft attibutes to tell compiler that symbols are imported/exported from a .dll
#    #if defined(BUILD_LIBTYPE_SHARED)
#        #define RLAPI __declspec(dllexport)     // We are building raylib as a Win32 shared library (.dll)
#    #elif defined(USE_LIBTYPE_SHARED)
#        #define RLAPI __declspec(dllimport)     // We are using raylib as a Win32 shared library (.dll)
#    #else
#        #define RLAPI   // We are building or using raylib as a static library
#    #endif
##else
#    #define RLAPI       // We are building or using raylib as a static library (or Linux shared library)
##endif

#----------------------------------------------------------------------------------
# Some basic Defines
#----------------------------------------------------------------------------------
##ifndef PI
#    #define PI 3.14159265358979323846f
##endif

##define DEG2RAD (PI/180.0f)
##define RAD2DEG (180.0f/PI)

# Allow custom memory allocators
##ifndef RL_MALLOC
#    #define RL_MALLOC(sz)       malloc(sz)
##endif
##ifndef RL_CALLOC
#    #define RL_CALLOC(n,sz)     calloc(n,sz)
##endif
##ifndef RL_REALLOC
#    #define RL_REALLOC(ptr,sz)  realloc(ptr,sz)
##endif
##ifndef RL_FREE
#    #define RL_FREE(ptr)        free(ptr)
##endif

# NOTE: MSC C++ compiler does not support compound literals (C99 feature)
# Plain structures in C++ (without constructors) can be initialized from { } initializers.
##if defined(__cplusplus)
#    #define CLITERAL(type)      type
##else
#    #define CLITERAL(type)      (type)
##endif

# Some Basic Colors
# NOTE: Custom raylib color palette for amazing visuals on WHITE background


# Temporal hack to avoid breaking old codebases using
# deprecated raylib implementation of these functions
##define FormatText      TextFormat
##define LoadText        LoadFileText
##define GetExtension    GetFileExtension
##define GetImageData    LoadImageColors
##define Fade(c, a)  ColorAlpha(c, a)

#----------------------------------------------------------------------------------
# Structures Definition
#----------------------------------------------------------------------------------
# Boolean type
##if defined(__STDC__) && __STDC_VERSION__ >= 199901L
#    #include <stdbool.h>
##elif !defined(__cplusplus) && !defined(bool)
#    typedef enum { false, true } bool;
##endif

# Vector2 type
type Vector2* {.bycopy.} = object
  x*: float32
  y*: float32

# Vector3 type
type Vector3* {.bycopy.} = object
  x*: float32
  y*: float32
  z*: float32

# Vector4 type
type Vector4* {.bycopy.} = object
  x*: float32
  y*: float32
  z*: float32
  w*: float32

# Quaternion type, same as Vector4
type Quaternion* = Vector4

# Matrix type (OpenGL style 4x4 - right handed, column major)
type Matrix* {.bycopy.} = object
  m0*, m4*, m8*, m12*: float32
  m1*, m5*, m9*, m13*: float32
  m2*, m6*, m10*, m14*: float32
  m3*, m7*, m11*, m15*: float32

# Color type, RGBA (32bit)
type Color* {.bycopy.} = object
  r*: uint8
  g*: uint8
  b*: uint8
  a*: uint8

# Rectangle type
type Rectangle* {.bycopy.} = object
  x*: float32
  y*: float32
  width*: float32
  height*: float32

# Image type, bpp always RGBA (32bit)
# NOTE: Data stored in CPU memory (RAM)
type Image* {.bycopy.} = object
  data*: pointer # Image raw data
  width*: int32 # Image base width
  height*: int32 # Image base height
  mipmaps*: int32 # Mipmap levels, 1 by default
  format*: int32 # Data format (PixelFormat type)

# Texture type
# NOTE: Data stored in GPU memory
type Texture* {.bycopy.} = object
  id*: uint32 # OpenGL texture id
  width*: int32 # Texture base width
  height*: int32 # Texture base height
  mipmaps*: int32 # Mipmap levels, 1 by default
  format*: int32 # Data format (PixelFormat type)

# Texture2D type, same as Texture
type Texture2D* = Texture

# TextureCubemap type, actually, same as Texture
type TextureCubemap* = Texture

# RenderTexture type, for texture rendering
type RenderTexture* {.bycopy.} = object
  id*: uint32 # OpenGL Framebuffer Object (FBO) id
  texture*: Texture # Color buffer attachment texture
  depth*: Texture # Depth buffer attachment texture

# RenderTexture2D type, same as RenderTexture
type RenderTexture2D* = RenderTexture

# N-Patch layout info
type NPatchInfo* {.bycopy.} = object
  source*: Rectangle # Region in the texture
  left*: int32 # left border offset
  top*: int32 # top border offset
  right*: int32 # right border offset
  bottom*: int32 # bottom border offset
  typex*: int32 # layout of the n-patch: 3x3, 1x3 or 3x1

# Font character info
type CharInfo* {.bycopy.} = object
  value*: int32 # Character value (Unicode)
  offsetX*: int32 # Character offset X when drawing
  offsetY*: int32 # Character offset Y when drawing
  advanceX*: int32 # Character advance position X
  image*: Image # Character image data

# Font type, includes texture and charSet array data
type Font* {.bycopy.} = object
  baseSize*: int32 # Base size (default chars height)
  charsCount*: int32 # Number of characters
  charsPadding*: int32 # Padding around the chars
  texture*: Texture2D # Characters texture atlas
  recs*: ptr Rectangle # Characters rectangles in texture
  chars*: ptr CharInfo # Characters info data

template SpriteFont*(): auto = Font # SpriteFont type fallback, defaults to Font

# Camera type, defines a camera position/orientation in 3d space
type Camera3D* {.bycopy.} = object
  position*: Vector3 # Camera position
  target*: Vector3 # Camera target it looks-at
  up*: Vector3 # Camera up vector (rotation over its axis)
  fovy*: float32 # Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
  typex*: int32 # Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

type Camera* = Camera3D # Camera type fallback, defaults to Camera3D

# Camera2D type, defines a 2d camera
type Camera2D* {.bycopy.} = object
  offset*: Vector2 # Camera offset (displacement from target)
  target*: Vector2 # Camera target (rotation and zoom origin)
  rotation*: float32 # Camera rotation in degrees
  zoom*: float32 # Camera zoom (scaling), should be 1.0f by default

# Vertex data definning a mesh
# NOTE: Data stored in CPU memory (and GPU)
type Mesh* {.bycopy.} = object
  vertexCount*: int32 # Number of vertices stored in arrays
  triangleCount*: int32 # Number of triangles stored (indexed or not)

    # Default vertex data
  vertices*: float32 # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
  texcoords*: float32 # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
  texcoords2*: float32 # Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
  normals*: float32 # Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
  tangents*: float32 # Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
  colors*: uint8 # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
  indices*: uint16 # Vertex indices (in case vertex data comes indexed)

    # Animation vertex data
  animVertices*: float32 # Animated vertex positions (after bones transformations)
  animNormals*: float32 # Animated normals (after bones transformations)
  boneIds*: int32 # Vertex bone ids, up to 4 bones influence by vertex (skinning)
  boneWeights*: float32 # Vertex bone weight, up to 4 bones influence by vertex (skinning)

    # OpenGL identifiers
  vaoId*: uint32 # OpenGL Vertex Array Object id
  vboId*: uint32 # OpenGL Vertex Buffer Objects id (default vertex data)

# Shader type (generic)
type Shader* {.bycopy.} = object
  id*: uint32 # Shader program id
  locs*: int32 # Shader locations array (MAX_SHADER_LOCATIONS)

# Material texture map
type MaterialMap* {.bycopy.} = object
  texture*: Texture2D # Material map texture
  color*: Color # Material map color
  value*: float32 # Material map value

# Material type (generic)
type Material* {.bycopy.} = object
  shader*: Shader # Material shader
  maps*: ptr MaterialMap # Material maps array (MAX_MATERIAL_MAPS)
  params*: float32 # Material generic parameters (if required)

# Transformation properties
type Transform* {.bycopy.} = object
  translation*: Vector3 # Translation
  rotation*: Quaternion # Rotation
  scale*: Vector3 # Scale

# Bone information
type BoneInfo* {.bycopy.} = object
  name*: array[32, char] # Bone name
  parent*: int32 # Bone parent

# Model type
type Model* {.bycopy.} = object
  transform*: Matrix # Local transform matrix

  meshCount*: int32 # Number of meshes
  materialCount*: int32 # Number of materials
  meshes*: ptr Mesh # Meshes array
  materials*: ptr Material # Materials array
  meshMaterial*: int32 # Mesh material number

    # Animation data
  boneCount*: int32 # Number of bones
  bones*: ptr BoneInfo # Bones information (skeleton)
  bindPose*: ptr Transform # Bones base transformation (pose)

# Model animation
type ModelAnimation* {.bycopy.} = object
  boneCount*: int32 # Number of bones
  frameCount*: int32 # Number of animation frames
  bones*: ptr BoneInfo # Bones information (skeleton)
  framePoses*: ptr Transform # Poses array by frame

# Ray type (useful for raycast)
type Ray* {.bycopy.} = object
  position*: Vector3 # Ray position (origin)
  direction*: Vector3 # Ray direction

# Raycast hit information
type RayHitInfo* {.bycopy.} = object
  hit*: bool # Did the ray hit something?
  distance*: float32 # Distance to nearest hit
  position*: Vector3 # Position of nearest hit
  normal*: Vector3 # Surface normal of hit

# Bounding box type
type BoundingBox* {.bycopy.} = object
  min*: Vector3 # Minimum vertex box-corner
  max*: Vector3 # Maximum vertex box-corner

# Wave type, defines audio wave data
type Wave* {.bycopy.} = object
  sampleCount*: uint32 # Total number of samples
  sampleRate*: uint32 # Frequency (samples per second)
  sampleSize*: uint32 # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  channels*: uint32 # Number of channels (1-mono, 2-stereo)
  data*: pointer # Buffer data pointer

type rAudioBuffer* {.bycopy.} = object

# Audio stream type
# NOTE: Useful to create custom audio streams not bound to a specific file
type AudioStream* {.bycopy.} = object
  buffer*: ptr rAudioBuffer # Pointer to internal data used by the audio system

  sampleRate*: uint32 # Frequency (samples per second)
  sampleSize*: uint32 # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  channels*: uint32 # Number of channels (1-mono, 2-stereo)

# Sound source type
type Sound* {.bycopy.} = object
  stream*: AudioStream # Audio stream
  sampleCount*: uint32 # Total number of samples

# Music stream type (audio file streaming from memory)
# NOTE: Anything longer than ~10 seconds should be streamed
type Music* {.bycopy.} = object
  stream*: AudioStream # Audio stream
  sampleCount*: uint32 # Total number of samples
  looping*: bool # Music looping enable

  ctxType*: int32 # Type of music context (audio filetype)
  ctxData*: pointer # Audio context data, depends on type

# Head-Mounted-Display device parameters
type VrDeviceInfo* {.bycopy.} = object
  hResolution*: int32 # HMD horizontal resolution in pixels
  vResolution*: int32 # HMD vertical resolution in pixels
  hScreenSize*: float32 # HMD horizontal size in meters
  vScreenSize*: float32 # HMD vertical size in meters
  vScreenCenter*: float32 # HMD screen center in meters
  eyeToScreenDistance*: float32 # HMD distance between eye and display in meters
  lensSeparationDistance*: float32 # HMD lens separation distance in meters
  interpupillaryDistance*: float32 # HMD IPD (distance between pupils) in meters
  lensDistortionValues*: float32 # HMD lens distortion constant parameters
  chromaAbCorrection*: float32 # HMD chromatic aberration correction parameters

#----------------------------------------------------------------------------------
# Enumerators Definition
#----------------------------------------------------------------------------------
# System/Window config flags
# NOTE: Every bit registers one state (use it with bit masks)
# By default all flags are set to 0
type ConfigFlag* = enum
  flagvsynchint = 0x00000040 # Set to try enabling V-Sync on GPU
  flagfullscreenmode = 0x00000002 # Set to run program in fullscreen
  flagwindowresizable = 0x00000004 # Set to allow resizable window
  flagwindowundecorated = 0x00000008 # Set to disable window decoration (frame and buttons)
  flagwindowhidden = 0x00000080 # Set to hide window
  flagwindowminimized = 0x00000200 # Set to minimize window (iconify)
  flagwindowmaximized = 0x00000400 # Set to maximize window (expanded to monitor)
  flagwindowunfocused = 0x00000800 # Set to window non focused
  flagwindowtopmost = 0x00001000 # Set to window always on top
  flagwindowalwaysrun = 0x00000100 # Set to allow windows running while minimized
  flagwindowtransparent = 0x00000010 # Set to allow transparent framebuffer
  flagwindowhighdpi = 0x00002000 # Set to support HighDPI
  flagmsaa4xhint = 0x00000020 # Set to try enabling MSAA 4X
  flaginterlacedhint = 0x00010000 # Set to try enabling interlaced video format (for V3D)
converter ConfigFlagToint32* (self: ConfigFlag): int32 = self.int32

# Trace log type
type TraceLogType* = enum
  logall = 0 # Display all logs
  logtrace
  logdebug
  loginfo
  logwarning
  logerror
  logfatal
  lognone # Disable logging
converter TraceLogTypeToint32* (self: TraceLogType): int32 = self.int32

# Keyboard keys (US keyboard layout)
# NOTE: Use GetKeyPressed() to allow redefining
# required keys for alternative layouts
type KeyboardKey* = enum
    # Alphanumeric keys
  keyapostrophe = 39
  keycomma = 44
  keyminus = 45
  keyperiod = 46
  keyslash = 47
  keyzero = 48
  keyone = 49
  keytwo = 50
  keythree = 51
  keyfour = 52
  keyfive = 53
  keysix = 54
  keyseven = 55
  keyeight = 56
  keynine = 57
  keysemicolon = 59
  keyequal = 61
  keya = 65
  keyb = 66
  keyc = 67
  keyd = 68
  keye = 69
  keyf = 70
  keyg = 71
  keyh = 72
  keyi = 73
  keyj = 74
  keyk = 75
  keyl = 76
  keym = 77
  keyn = 78
  keyo = 79
  keyp = 80
  keyq = 81
  keyr = 82
  keys = 83
  keyt = 84
  keyu = 85
  keyv = 86
  keyw = 87
  keyx = 88
  keyy = 89
  keyz = 90

    # Function keys
  keyspace = 32
  keyescape = 256
  keyenter = 257
  keytab = 258
  keybackspace = 259
  keyinsert = 260
  keydelete = 261
  keyright = 262
  keyleft = 263
  keydown = 264
  keyup = 265
  keypageup = 266
  keypagedown = 267
  keyhome = 268
  keyend = 269
  keycapslock = 280
  keyscrolllock = 281
  keynumlock = 282
  keyprintscreen = 283
  keypause = 284
  keyf1 = 290
  keyf2 = 291
  keyf3 = 292
  keyf4 = 293
  keyf5 = 294
  keyf6 = 295
  keyf7 = 296
  keyf8 = 297
  keyf9 = 298
  keyf10 = 299
  keyf11 = 300
  keyf12 = 301
  keyleftshift = 340
  keyleftcontrol = 341
  keyleftalt = 342
  keyleftsuper = 343
  keyrightshift = 344
  keyrightcontrol = 345
  keyrightalt = 346
  keyrightsuper = 347
  keykbmenu = 348
  keyleftbracket = 91
  keybackslash = 92
  keyrightbracket = 93
  keygrave = 96

    # Keypad keys
  keykp0 = 320
  keykp1 = 321
  keykp2 = 322
  keykp3 = 323
  keykp4 = 324
  keykp5 = 325
  keykp6 = 326
  keykp7 = 327
  keykp8 = 328
  keykp9 = 329
  keykpdecimal = 330
  keykpdivide = 331
  keykpmultiply = 332
  keykpsubtract = 333
  keykpadd = 334
  keykpenter = 335
  keykpequal = 336
converter KeyboardKeyToint32* (self: KeyboardKey): int32 = self.int32

# Android buttons
type AndroidButton* = enum
  keyback = 4
  keymenu = 82
  keyvolumeup = 24
  keyvolumedown = 25
converter AndroidButtonToint32* (self: AndroidButton): int32 = self.int32

# Mouse buttons
type MouseButton* = enum
  mouseleftbutton = 0
  mouserightbutton = 1
  mousemiddlebutton = 2
converter MouseButtonToint32* (self: MouseButton): int32 = self.int32

# Mouse cursor types
type MouseCursor* = enum
  mousecursordefault = 0
  mousecursorarrow = 1
  mousecursoribeam = 2
  mousecursorcrosshair = 3
  mousecursorpointinghand = 4
  mousecursorresizeew = 5 # The horizontal resize/move arrow shape
  mousecursorresizens = 6 # The vertical resize/move arrow shape
  mousecursorresizenwse = 7 # The top-left to bottom-right diagonal resize/move arrow shape
  mousecursorresizenesw = 8 # The top-right to bottom-left diagonal resize/move arrow shape
  mousecursorresizeall = 9 # The omni-directional resize/move cursor shape
  mousecursornotallowed = 10 # The operation-not-allowed shape
converter MouseCursorToint32* (self: MouseCursor): int32 = self.int32

# Gamepad number
type GamepadNumber* = enum
  gamepadplayer1 = 0
  gamepadplayer2 = 1
  gamepadplayer3 = 2
  gamepadplayer4 = 3
converter GamepadNumberToint32* (self: GamepadNumber): int32 = self.int32

# Gamepad buttons
type GamepadButton* = enum
    # This is here just for error checking
  gamepadbuttonunknown = 0

    # This is normally a DPAD
  gamepadbuttonleftfaceup
  gamepadbuttonleftfaceright
  gamepadbuttonleftfacedown
  gamepadbuttonleftfaceleft

    # This normally corresponds with PlayStation and Xbox controllers
    # XBOX: [Y,X,A,B]
    # PS3: [Triangle,Square,Cross,Circle]
    # No support for 6 button controllers though..
  gamepadbuttonrightfaceup
  gamepadbuttonrightfaceright
  gamepadbuttonrightfacedown
  gamepadbuttonrightfaceleft

    # Triggers
  gamepadbuttonlefttrigger1
  gamepadbuttonlefttrigger2
  gamepadbuttonrighttrigger1
  gamepadbuttonrighttrigger2

    # These are buttons in the center of the gamepad
  gamepadbuttonmiddleleft #PS3 Select
  gamepadbuttonmiddle #PS Button/XBOX Button
  gamepadbuttonmiddleright #PS3 Start

    # These are the joystick press in buttons
  gamepadbuttonleftthumb
  gamepadbuttonrightthumb
converter GamepadButtonToint32* (self: GamepadButton): int32 = self.int32

# Gamepad axis
type GamepadAxis* = enum
    # Left stick
  gamepadaxisleftx = 0
  gamepadaxislefty = 1

    # Right stick
  gamepadaxisrightx = 2
  gamepadaxisrighty = 3

    # Pressure levels for the back triggers
  gamepadaxislefttrigger = 4 # [1..-1] (pressure-level)
  gamepadaxisrighttrigger = 5 # [1..-1] (pressure-level)
converter GamepadAxisToint32* (self: GamepadAxis): int32 = self.int32

# Shader location points
type ShaderLocationIndex* = enum
  locvertexposition = 0
  locvertextexcoord01
  locvertextexcoord02
  locvertexnormal
  locvertextangent
  locvertexcolor
  locmatrixmvp
  locmatrixmodel
  locmatrixview
  locmatrixprojection
  locvectorview
  loccolordiffuse
  loccolorspecular
  loccolorambient
  locmapalbedo # LOC_MAP_DIFFUSE
  locmapmetalness # LOC_MAP_SPECULAR
  locmapnormal
  locmaproughness
  locmapocclusion
  locmapemission
  locmapheight
  locmapcubemap
  locmapirradiance
  locmapprefilter
  locmapbrdf
converter ShaderLocationIndexToint32* (self: ShaderLocationIndex): int32 = self.int32

template LOC_MAP_DIFFUSE*(): auto = LOC_MAP_ALBEDO
template LOC_MAP_SPECULAR*(): auto = LOC_MAP_METALNESS

# Shader uniform data types
type ShaderUniformDataType* = enum
  uniformfloat = 0
  uniformvec2
  uniformvec3
  uniformvec4
  uniformint
  uniformivec2
  uniformivec3
  uniformivec4
  uniformsampler2d
converter ShaderUniformDataTypeToint32* (self: ShaderUniformDataType): int32 = self.int32

# Material maps
type MaterialMapType* = enum
  mapalbedo = 0 # MAP_DIFFUSE
  mapmetalness = 1 # MAP_SPECULAR
  mapnormal = 2
  maproughness = 3
  mapocclusion
  mapemission
  mapheight
  mapcubemap # NOTE: Uses GL_TEXTURE_CUBE_MAP
  mapirradiance # NOTE: Uses GL_TEXTURE_CUBE_MAP
  mapprefilter # NOTE: Uses GL_TEXTURE_CUBE_MAP
  mapbrdf
converter MaterialMapTypeToint32* (self: MaterialMapType): int32 = self.int32

template MAP_DIFFUSE*(): auto = MAP_ALBEDO
template MAP_SPECULAR*(): auto = MAP_METALNESS

# Pixel formats
# NOTE: Support depends on OpenGL version and platform
type PixelFormat* = enum
  uncompressedgrayscale = 1 # 8 bit per pixel (no alpha)
  uncompressedgrayalpha # 8*2 bpp (2 channels)
  uncompressedr5g6b5 # 16 bpp
  uncompressedr8g8b8 # 24 bpp
  uncompressedr5g5b5a1 # 16 bpp (1 bit alpha)
  uncompressedr4g4b4a4 # 16 bpp (4 bit alpha)
  uncompressedr8g8b8a8 # 32 bpp
  uncompressedr32 # 32 bpp (1 channel - float)
  uncompressedr32g32b32 # 32*3 bpp (3 channels - float)
  uncompressedr32g32b32a32 # 32*4 bpp (4 channels - float)
  compresseddxt1rgb # 4 bpp (no alpha)
  compresseddxt1rgba # 4 bpp (1 bit alpha)
  compresseddxt3rgba # 8 bpp
  compresseddxt5rgba # 8 bpp
  compressedetc1rgb # 4 bpp
  compressedetc2rgb # 4 bpp
  compressedetc2eacrgba # 8 bpp
  compressedpvrtrgb # 4 bpp
  compressedpvrtrgba # 4 bpp
  compressedastc4x4rgba # 8 bpp
  compressedastc8x8rgba # 2 bpp
converter PixelFormatToint32* (self: PixelFormat): int32 = self.int32

# Texture parameters: filter mode
# NOTE 1: Filtering considers mipmaps if available in the texture
# NOTE 2: Filter is accordingly set for minification and magnification
type TextureFilterMode* = enum
  filterpoint = 0 # No filter, just pixel aproximation
  filterbilinear # Linear filtering
  filtertrilinear # Trilinear filtering (linear with mipmaps)
  filteranisotropic4x # Anisotropic filtering 4x
  filteranisotropic8x # Anisotropic filtering 8x
  filteranisotropic16x # Anisotropic filtering 16x
converter TextureFilterModeToint32* (self: TextureFilterMode): int32 = self.int32

# Texture parameters: wrap mode
type TextureWrapMode* = enum
  wraprepeat = 0 # Repeats texture in tiled mode
  wrapclamp # Clamps texture to edge pixel in tiled mode
  wrapmirrorrepeat # Mirrors and repeats the texture in tiled mode
  wrapmirrorclamp # Mirrors and clamps to border the texture in tiled mode
converter TextureWrapModeToint32* (self: TextureWrapMode): int32 = self.int32

# Cubemap layouts
type CubemapLayoutType* = enum
  cubemapautodetect = 0 # Automatically detect layout type
  cubemaplinevertical # Layout is defined by a vertical line with faces
  cubemaplinehorizontal # Layout is defined by an horizontal line with faces
  cubemapcrossthreebyfour # Layout is defined by a 3x4 cross with cubemap faces
  cubemapcrossfourbythree # Layout is defined by a 4x3 cross with cubemap faces
  cubemappanorama # Layout is defined by a panorama image (equirectangular map)
converter CubemapLayoutTypeToint32* (self: CubemapLayoutType): int32 = self.int32

# Font type, defines generation method
type FontType* = enum
  fontdefault = 0 # Default font generation, anti-aliased
  fontbitmap # Bitmap font generation, no anti-aliasing
  fontsdf # SDF font generation, requires external shader
converter FontTypeToint32* (self: FontType): int32 = self.int32

# Color blending modes (pre-defined)
type BlendMode* = enum
  blendalpha = 0 # Blend textures considering alpha (default)
  blendadditive # Blend textures adding colors
  blendmultiplied # Blend textures multiplying colors
  blendaddcolors # Blend textures adding colors (alternative)
  blendsubtractcolors # Blend textures subtracting colors (alternative)
  blendcustom # Belnd textures using custom src/dst factors (use SetBlendModeCustom())
converter BlendModeToint32* (self: BlendMode): int32 = self.int32

# Gestures type
# NOTE: It could be used as flags to enable only some gestures
type GestureType* = enum
  gesturenone = 0
  gesturetap = 1
  gesturedoubletap = 2
  gesturehold = 4
  gesturedrag = 8
  gestureswiperight = 16
  gestureswipeleft = 32
  gestureswipeup = 64
  gestureswipedown = 128
  gesturepinchin = 256
  gesturepinchout = 512
converter GestureTypeToint32* (self: GestureType): int32 = self.int32

# Camera system modes
type CameraMode* = enum
  cameracustom = 0
  camerafree
  cameraorbital
  camerafirstperson
  camerathirdperson
converter CameraModeToint32* (self: CameraMode): int32 = self.int32

# Camera projection modes
type CameraType* = enum
  cameraperspective = 0
  cameraorthographic
converter CameraTypeToint32* (self: CameraType): int32 = self.int32

# N-patch types
type NPatchType* = enum
  npt9patch = 0 # Npatch defined by 3x3 tiles
  npt3patchvertical # Npatch defined by 1x3 tiles
  npt3patchhorizontal # Npatch defined by 3x1 tiles
converter NPatchTypeToint32* (self: NPatchType): int32 = self.int32

# Callbacks to be implemented by users
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

