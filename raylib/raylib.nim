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
#    // Microsoft attibutes to tell compiler that symbols are imported/exported from a .dll
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

#//----------------------------------------------------------------------------------
#// Some basic Defines
#//----------------------------------------------------------------------------------
##ifndef PI
#    #define PI 3.14159265358979323846f
##endif

##define DEG2RAD (PI/180.0f)
##define RAD2DEG (180.0f/PI)

#// Allow custom memory allocators
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

#// NOTE: MSC C++ compiler does not support compound literals (C99 feature)
#// Plain structures in C++ (without constructors) can be initialized from { } initializers.
##if defined(__cplusplus)
#    #define CLITERAL(type)      type
##else
#    #define CLITERAL(type)      (type)
##endif

#// Some Basic Colors
#// NOTE: Custom raylib color palette for amazing visuals on WHITE background


#// Temporal hack to avoid breaking old codebases using
#// deprecated raylib implementation of these functions
##define FormatText      TextFormat
##define LoadText        LoadFileText
##define GetExtension    GetFileExtension
##define GetImageData    LoadImageColors
#//#define Fade(c, a)  ColorAlpha(c, a)

#//----------------------------------------------------------------------------------
#// Structures Definition
#//----------------------------------------------------------------------------------
#// Boolean type
##if defined(__STDC__) && __STDC_VERSION__ >= 199901L
#    #include <stdbool.h>
##elif !defined(__cplusplus) && !defined(bool)
#    typedef enum { false, true } bool;
##endif

#// Vector2 type
type Vector2* {.bycopy.} = object
  x*: float32
  y*: float32

#// Vector3 type
type Vector3* {.bycopy.} = object
  x*: float32
  y*: float32
  z*: float32

#// Vector4 type
type Vector4* {.bycopy.} = object
  x*: float32
  y*: float32
  z*: float32
  w*: float32

#// Quaternion type, same as Vector4
type Quaternion* = Vector4

#// Matrix type (OpenGL style 4x4 - right handed, column major)
type Matrix* {.bycopy.} = object
  m0*, m4*, m8*, m12*: float32
  m1*, m5*, m9*, m13*: float32
  m2*, m6*, m10*, m14*: float32
  m3*, m7*, m11*, m15*: float32

#// Color type, RGBA (32bit)
type Color* {.bycopy.} = object
  r*: uint8
  g*: uint8
  b*: uint8
  a*: uint8

#// Rectangle type
type Rectangle* {.bycopy.} = object
  x*: float32
  y*: float32
  width*: float32
  height*: float32

#// Image type, bpp always RGBA (32bit)
#// NOTE: Data stored in CPU memory (RAM)
type Image* {.bycopy.} = object
  data*: pointer # Image raw data
  width*: int32 # Image base width
  height*: int32 # Image base height
  mipmaps*: int32 # Mipmap levels, 1 by default
  format*: int32 # Data format (PixelFormat type)

#// Texture type
#// NOTE: Data stored in GPU memory
type Texture* {.bycopy.} = object
  id*: uint32 # OpenGL texture id
  width*: int32 # Texture base width
  height*: int32 # Texture base height
  mipmaps*: int32 # Mipmap levels, 1 by default
  format*: int32 # Data format (PixelFormat type)

#// Texture2D type, same as Texture
type Texture2D* = Texture

#// TextureCubemap type, actually, same as Texture
type TextureCubemap* = Texture

#// RenderTexture type, for texture rendering
type RenderTexture* {.bycopy.} = object
  id*: uint32 # OpenGL Framebuffer Object (FBO) id
  texture*: Texture # Color buffer attachment texture
  depth*: Texture # Depth buffer attachment texture

#// RenderTexture2D type, same as RenderTexture
type RenderTexture2D* = RenderTexture

#// N-Patch layout info
type NPatchInfo* {.bycopy.} = object
  source*: Rectangle # Region in the texture
  left*: int32 # left border offset
  top*: int32 # top border offset
  right*: int32 # right border offset
  bottom*: int32 # bottom border offset
  typex*: int32 # layout of the n-patch: 3x3, 1x3 or 3x1

#// Font character info
type CharInfo* {.bycopy.} = object
  value*: int32 # Character value (Unicode)
  offsetX*: int32 # Character offset X when drawing
  offsetY*: int32 # Character offset Y when drawing
  advanceX*: int32 # Character advance position X
  image*: Image # Character image data

#// Font type, includes texture and charSet array data
type Font* {.bycopy.} = object
  baseSize*: int32 # Base size (default chars height)
  charsCount*: int32 # Number of characters
  charsPadding*: int32 # Padding around the chars
  texture*: Texture2D # Characters texture atlas
  recs*: ptr Rectangle # Characters rectangles in texture
  chars*: ptr CharInfo # Characters info data

template SpriteFont*(): auto = Font # SpriteFont type fallback, defaults to Font

#// Camera type, defines a camera position/orientation in 3d space
type Camera3D* {.bycopy.} = object
  position*: Vector3 # Camera position
  target*: Vector3 # Camera target it looks-at
  up*: Vector3 # Camera up vector (rotation over its axis)
  fovy*: float32 # Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
  typex*: int32 # Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

type Camera* = Camera3D # Camera type fallback, defaults to Camera3D

#// Camera2D type, defines a 2d camera
type Camera2D* {.bycopy.} = object
  offset*: Vector2 # Camera offset (displacement from target)
  target*: Vector2 # Camera target (rotation and zoom origin)
  rotation*: float32 # Camera rotation in degrees
  zoom*: float32 # Camera zoom (scaling), should be 1.0f by default

#// Vertex data definning a mesh
#// NOTE: Data stored in CPU memory (and GPU)
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

#// Shader type (generic)
type Shader* {.bycopy.} = object
  id*: uint32 # Shader program id
  locs*: int32 # Shader locations array (MAX_SHADER_LOCATIONS)

#// Material texture map
type MaterialMap* {.bycopy.} = object
  texture*: Texture2D # Material map texture
  color*: Color # Material map color
  value*: float32 # Material map value

#// Material type (generic)
type Material* {.bycopy.} = object
  shader*: Shader # Material shader
  maps*: ptr MaterialMap # Material maps array (MAX_MATERIAL_MAPS)
  params*: float32 # Material generic parameters (if required)

#// Transformation properties
type Transform* {.bycopy.} = object
  translation*: Vector3 # Translation
  rotation*: Quaternion # Rotation
  scale*: Vector3 # Scale

#// Bone information
type BoneInfo* {.bycopy.} = object
  name*: array[32, char] # Bone name
  parent*: int32 # Bone parent

#// Model type
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

#// Model animation
type ModelAnimation* {.bycopy.} = object
  boneCount*: int32 # Number of bones
  frameCount*: int32 # Number of animation frames
  bones*: ptr BoneInfo # Bones information (skeleton)
  framePoses*: ptr Transform # Poses array by frame

#// Ray type (useful for raycast)
type Ray* {.bycopy.} = object
  position*: Vector3 # Ray position (origin)
  direction*: Vector3 # Ray direction

#// Raycast hit information
type RayHitInfo* {.bycopy.} = object
  hit*: bool # Did the ray hit something?
  distance*: float32 # Distance to nearest hit
  position*: Vector3 # Position of nearest hit
  normal*: Vector3 # Surface normal of hit

#// Bounding box type
type BoundingBox* {.bycopy.} = object
  min*: Vector3 # Minimum vertex box-corner
  max*: Vector3 # Maximum vertex box-corner

#// Wave type, defines audio wave data
type Wave* {.bycopy.} = object
  sampleCount*: uint32 # Total number of samples
  sampleRate*: uint32 # Frequency (samples per second)
  sampleSize*: uint32 # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  channels*: uint32 # Number of channels (1-mono, 2-stereo)
  data*: pointer # Buffer data pointer

type rAudioBuffer* {.bycopy.} = object

#// Audio stream type
#// NOTE: Useful to create custom audio streams not bound to a specific file
type AudioStream* {.bycopy.} = object
  buffer*: ptr rAudioBuffer # Pointer to internal data used by the audio system

  sampleRate*: uint32 # Frequency (samples per second)
  sampleSize*: uint32 # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  channels*: uint32 # Number of channels (1-mono, 2-stereo)

#// Sound source type
type Sound* {.bycopy.} = object
  stream*: AudioStream # Audio stream
  sampleCount*: uint32 # Total number of samples

#// Music stream type (audio file streaming from memory)
#// NOTE: Anything longer than ~10 seconds should be streamed
type Music* {.bycopy.} = object
  stream*: AudioStream # Audio stream
  sampleCount*: uint32 # Total number of samples
  looping*: bool # Music looping enable

  ctxType*: int32 # Type of music context (audio filetype)
  ctxData*: pointer # Audio context data, depends on type

#// Head-Mounted-Display device parameters
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

#//----------------------------------------------------------------------------------
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

