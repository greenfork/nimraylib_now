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
# converter uint8ToCuchar*(self: uint8): uint8 = self.uint8
# converter CintToCuchar*(self: int32): uint8 = self.uint8
type va_list* = varargs[cstring, `$`]
## *********************************************************************************************
##
##    raylib - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
##
##    FEATURES:
##        - NO external dependencies, all required libraries included with raylib
##        - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly, MacOS, UWP, Android, Raspberry Pi, HTML5.
##        - Written in plain C code (C99) in PascalCase/camelCase notation
##        - Hardware accelerated with OpenGL (1.1, 2.1, 3.3 or ES2 - choose at compile)
##        - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
##        - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
##        - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
##        - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
##        - Flexible Materials system, supporting classic maps and PBR maps
##        - Skeletal Animation support (CPU bones-based animation)
##        - Shaders support, including Model shaders and Postprocessing shaders
##        - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
##        - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
##        - VR stereo rendering with configurable HMD device parameters
##        - Bindings to multiple programming languages available!
##
##    NOTES:
##        One custom font is loaded by default when InitWindow() [core]
##        If using OpenGL 3.3 or ES2, one default shader is loaded automatically (internally defined) [rlgl]
##        If using OpenGL 3.3 or ES2, several vertex buffers (VAO/VBO) are created to manage lines-triangles-quads
##
##    DEPENDENCIES (included):
##        [core] rglfw (github.com/glfw/glfw) for window/context management and input (only PLATFORM_DESKTOP)
##        [rlgl] glad (github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (only PLATFORM_DESKTOP)
##        [raudio] miniaudio (github.com/dr-soft/miniaudio) for audio device/context management
##
##    OPTIONAL DEPENDENCIES (included):
##        [core] rgif (Charlie Tangora, Ramon Santamaria) for GIF recording
##        [textures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
##        [textures] stb_image_write (Sean Barret) for image writting (BMP, TGA, PNG, JPG)
##        [textures] stb_image_resize (Sean Barret) for image resizing algorithms
##        [textures] stb_perlin (Sean Barret) for Perlin noise image generation
##        [text] stb_truetype (Sean Barret) for ttf fonts loading
##        [text] stb_rect_pack (Sean Barret) for rectangles packing
##        [models] par_shapes (Philip Rideout) for parametric 3d shapes generation
##        [models] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
##        [models] cgltf (Johannes Kuhlmann) for models loading (glTF)
##        [raudio] stb_vorbis (Sean Barret) for OGG audio loading
##        [raudio] dr_flac (David Reid) for FLAC audio file loading
##        [raudio] dr_mp3 (David Reid) for MP3 audio file loading
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
## ----------------------------------------------------------------------------------
##  Some basic Defines
## ----------------------------------------------------------------------------------
##  Allow custom memory allocators
##  NOTE: MSC C++ compiler does not support compound literals (C99 feature)
##  Plain structures in C++ (without constructors) can be initialized from { } initializers.
##  Some Basic Colors
##  NOTE: Custom raylib color palette for amazing visuals on WHITE background
##  Temporal hack to avoid breaking old codebases using
##  deprecated raylib implementation of these functions
## #define Fade(c, a)  ColorAlpha(c, a)
## ----------------------------------------------------------------------------------
##  Structures Definition
## ----------------------------------------------------------------------------------
##  Boolean type
##  Vector2 type

type
  Vector2* {.bycopy.} = object
    x*: float32
    y*: float32


##  Vector3 type

type
  Vector3* {.bycopy.} = object
    x*: float32
    y*: float32
    z*: float32


##  Vector4 type

type
  Vector4* {.bycopy.} = object
    x*: float32
    y*: float32
    z*: float32
    w*: float32


##  Quaternion type, same as Vector4

type
  Quaternion* = Vector4

##  Matrix type (OpenGL style 4x4 - right handed, column major)

type
  Matrix* {.bycopy.} = object
    m0*: float32
    m4*: float32
    m8*: float32
    m12*: float32
    m1*: float32
    m5*: float32
    m9*: float32
    m13*: float32
    m2*: float32
    m6*: float32
    m10*: float32
    m14*: float32
    m3*: float32
    m7*: float32
    m11*: float32
    m15*: float32


##  Color type, RGBA (32bit)

type
  Color* {.bycopy.} = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8


##  Rectangle type

type
  Rectangle* {.bycopy.} = object
    x*: float32
    y*: float32
    width*: float32
    height*: float32


##  Image type, bpp always RGBA (32bit)
##  NOTE: Data stored in CPU memory (RAM)

type
  Image* {.bycopy.} = object
    data*: pointer             ##  Image raw data
    width*: int32               ##  Image base width
    height*: int32              ##  Image base height
    mipmaps*: int32             ##  Mipmap levels, 1 by default
    format*: int32              ##  Data format (PixelFormat type)


##  Texture type
##  NOTE: Data stored in GPU memory

type
  Texture* {.bycopy.} = object
    id*: uint32                 ##  OpenGL texture id
    width*: int32               ##  Texture base width
    height*: int32              ##  Texture base height
    mipmaps*: int32             ##  Mipmap levels, 1 by default
    format*: int32              ##  Data format (PixelFormat type)


##  Texture2D type, same as Texture

type
  Texture2D* = Texture

##  TextureCubemap type, actually, same as Texture

type
  TextureCubemap* = Texture

##  RenderTexture type, for texture rendering

type
  RenderTexture* {.bycopy.} = object
    id*: uint32                 ##  OpenGL Framebuffer Object (FBO) id
    texture*: Texture          ##  Color buffer attachment texture
    depth*: Texture            ##  Depth buffer attachment texture


##  RenderTexture2D type, same as RenderTexture

type
  RenderTexture2D* = RenderTexture

##  N-Patch layout info

type
  NPatchInfo* {.bycopy.} = object
    source*: Rectangle         ##  Region in the texture
    left*: int32                ##  left border offset
    top*: int32                 ##  top border offset
    right*: int32               ##  right border offset
    bottom*: int32              ##  bottom border offset
    `type`*: int32              ##  layout of the n-patch: 3x3, 1x3 or 3x1


##  Font character info

type
  CharInfo* {.bycopy.} = object
    value*: int32               ##  Character value (Unicode)
    offsetX*: int32             ##  Character offset X when drawing
    offsetY*: int32             ##  Character offset Y when drawing
    advanceX*: int32            ##  Character advance position X
    image*: Image              ##  Character image data


##  Font type, includes texture and charSet array data

type
  Font* {.bycopy.} = object
    baseSize*: int32            ##  Base size (default chars height)
    charsCount*: int32          ##  Number of characters
    charsPadding*: int32        ##  Padding around the chars
    texture*: Texture2D        ##  Characters texture atlas
    recs*: ptr Rectangle        ##  Characters rectangles in texture
    chars*: ptr CharInfo        ##  Characters info data


##  Camera type, defines a camera position/orientation in 3d space

type
  Camera3D* {.bycopy.} = object
    position*: Vector3         ##  Camera position
    target*: Vector3           ##  Camera target it looks-at
    up*: Vector3               ##  Camera up vector (rotation over its axis)
    fovy*: float32              ##  Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    `type`*: int32              ##  Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

  Camera* = Camera3D

##  Camera type fallback, defaults to Camera3D
##  Camera2D type, defines a 2d camera

type
  Camera2D* {.bycopy.} = object
    offset*: Vector2           ##  Camera offset (displacement from target)
    target*: Vector2           ##  Camera target (rotation and zoom origin)
    rotation*: float32          ##  Camera rotation in degrees
    zoom*: float32              ##  Camera zoom (scaling), should be 1.0f by default


##  Vertex data definning a mesh
##  NOTE: Data stored in CPU memory (and GPU)

type
  Mesh* {.bycopy.} = object
    vertexCount*: int32         ##  Number of vertices stored in arrays
    triangleCount*: int32       ##  Number of triangles stored (indexed or not)
                       ##  Default vertex data
    vertices*: ptr float32       ##  Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords*: ptr float32      ##  Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2*: ptr float32     ##  Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals*: ptr float32        ##  Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents*: ptr float32       ##  Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors*: ptr uint8         ##  Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices*: ptr cushort ##  Vertex indices (in case vertex data comes indexed)
                       ##  Animation vertex data
    animVertices*: ptr float32   ##  Animated vertex positions (after bones transformations)
    animNormals*: ptr float32    ##  Animated normals (after bones transformations)
    boneIds*: ptr int32          ##  Vertex bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights*: ptr float32 ##  Vertex bone weight, up to 4 bones influence by vertex (skinning)
                          ##  OpenGL identifiers
    vaoId*: uint32              ##  OpenGL Vertex Array Object id
    vboId*: ptr uint32           ##  OpenGL Vertex Buffer Objects id (default vertex data)


##  Shader type (generic)

type
  Shader* {.bycopy.} = object
    id*: uint32                 ##  Shader program id
    locs*: ptr int32             ##  Shader locations array (MAX_SHADER_LOCATIONS)


##  Material texture map

type
  MaterialMap* {.bycopy.} = object
    texture*: Texture2D        ##  Material map texture
    color*: Color              ##  Material map color
    value*: float32             ##  Material map value


##  Material type (generic)

type
  Material* {.bycopy.} = object
    shader*: Shader            ##  Material shader
    maps*: ptr MaterialMap      ##  Material maps array (MAX_MATERIAL_MAPS)
    params*: ptr float32         ##  Material generic parameters (if required)


##  Transformation properties

type
  Transform* {.bycopy.} = object
    translation*: Vector3      ##  Translation
    rotation*: Quaternion      ##  Rotation
    scale*: Vector3            ##  Scale


##  Bone information

type
  BoneInfo* {.bycopy.} = object
    name*: array[32, char]      ##  Bone name
    parent*: int32              ##  Bone parent


##  Model type

type
  Model* {.bycopy.} = object
    transform*: Matrix         ##  Local transform matrix
    meshCount*: int32           ##  Number of meshes
    materialCount*: int32       ##  Number of materials
    meshes*: ptr Mesh           ##  Meshes array
    materials*: ptr Material    ##  Materials array
    meshMaterial*: ptr int32     ##  Mesh material number
                         ##  Animation data
    boneCount*: int32           ##  Number of bones
    bones*: ptr BoneInfo        ##  Bones information (skeleton)
    bindPose*: ptr Transform    ##  Bones base transformation (pose)


##  Model animation

type
  ModelAnimation* {.bycopy.} = object
    boneCount*: int32           ##  Number of bones
    frameCount*: int32          ##  Number of animation frames
    bones*: ptr BoneInfo        ##  Bones information (skeleton)
    framePoses*: ptr ptr Transform ##  Poses array by frame


##  Ray type (useful for raycast)

type
  Ray* {.bycopy.} = object
    position*: Vector3         ##  Ray position (origin)
    direction*: Vector3        ##  Ray direction


##  Raycast hit information

type
  RayHitInfo* {.bycopy.} = object
    hit*: bool                 ##  Did the ray hit something?
    distance*: float32          ##  Distance to nearest hit
    position*: Vector3         ##  Position of nearest hit
    normal*: Vector3           ##  Surface normal of hit


##  Bounding box type

type
  BoundingBox* {.bycopy.} = object
    min*: Vector3              ##  Minimum vertex box-corner
    max*: Vector3              ##  Maximum vertex box-corner


##  Wave type, defines audio wave data

type
  Wave* {.bycopy.} = object
    sampleCount*: uint32        ##  Total number of samples
    sampleRate*: uint32         ##  Frequency (samples per second)
    sampleSize*: uint32         ##  Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32           ##  Number of channels (1-mono, 2-stereo)
    data*: pointer             ##  Buffer data pointer

  rAudioBuffer* {.bycopy.} = object


##  Audio stream type
##  NOTE: Useful to create custom audio streams not bound to a specific file

type
  AudioStream* {.bycopy.} = object
    buffer*: ptr rAudioBuffer   ##  Pointer to internal data used by the audio system
    sampleRate*: uint32         ##  Frequency (samples per second)
    sampleSize*: uint32         ##  Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32           ##  Number of channels (1-mono, 2-stereo)


##  Sound source type

type
  Sound* {.bycopy.} = object
    stream*: AudioStream       ##  Audio stream
    sampleCount*: uint32        ##  Total number of samples


##  Music stream type (audio file streaming from memory)
##  NOTE: Anything longer than ~10 seconds should be streamed

type
  Music* {.bycopy.} = object
    stream*: AudioStream       ##  Audio stream
    sampleCount*: uint32        ##  Total number of samples
    looping*: bool             ##  Music looping enable
    ctxType*: int32             ##  Type of music context (audio filetype)
    ctxData*: pointer          ##  Audio context data, depends on type


##  Head-Mounted-Display device parameters

type
  VrDeviceInfo* {.bycopy.} = object
    hResolution*: int32         ##  HMD horizontal resolution in pixels
    vResolution*: int32         ##  HMD vertical resolution in pixels
    hScreenSize*: float32       ##  HMD horizontal size in meters
    vScreenSize*: float32       ##  HMD vertical size in meters
    vScreenCenter*: float32     ##  HMD screen center in meters
    eyeToScreenDistance*: float32 ##  HMD distance between eye and display in meters
    lensSeparationDistance*: float32 ##  HMD lens separation distance in meters
    interpupillaryDistance*: float32 ##  HMD IPD (distance between pupils) in meters
    lensDistortionValues*: array[4, float32] ##  HMD lens distortion constant parameters
    chromaAbCorrection*: array[4, float32] ##  HMD chromatic aberration correction parameters


## ----------------------------------------------------------------------------------
##  Enumerators Definition
## ----------------------------------------------------------------------------------
##  System/Window config flags
##  NOTE: Every bit registers one state (use it with bit masks)
##  By default all flags are set to 0

type
  ConfigFlag* {.size: sizeof(int32).} = enum
    FLAG_FULLSCREEN_MODE = 0x00000002, ##  Set to run program in fullscreen
    FLAG_WINDOW_RESIZABLE = 0x00000004, ##  Set to allow resizable window
    FLAG_WINDOW_UNDECORATED = 0x00000008, ##  Set to disable window decoration (frame and buttons)
    FLAG_WINDOW_TRANSPARENT = 0x00000010, ##  Set to allow transparent framebuffer
    FLAG_MSAA_4X_HINT = 0x00000020, ##  Set to try enabling MSAA 4X
    FLAG_VSYNC_HINT = 0x00000040, ##  Set to try enabling V-Sync on GPU
    FLAG_WINDOW_HIDDEN = 0x00000080, ##  Set to hide window
    FLAG_WINDOW_ALWAYS_RUN = 0x00000100, ##  Set to allow windows running while minimized
    FLAG_WINDOW_MINIMIZED = 0x00000200, ##  Set to minimize window (iconify)
    FLAG_WINDOW_MAXIMIZED = 0x00000400, ##  Set to maximize window (expanded to monitor)
    FLAG_WINDOW_UNFOCUSED = 0x00000800, ##  Set to window non focused
    FLAG_WINDOW_TOPMOST = 0x00001000, ##  Set to window always on top
    FLAG_WINDOW_HIGHDPI = 0x00002000, ##  Set to support HighDPI
    FLAG_INTERLACED_HINT = 0x00010000


##  Trace log type

type
  TraceLogType* {.size: sizeof(int32).} = enum
    LOG_ALL = 0,                ##  Display all logs
    LOG_TRACE, LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_FATAL, LOG_NONE ##  Disable logging


##  Keyboard keys (US keyboard layout)
##  NOTE: Use GetKeyPressed() to allow redefining
##  required keys for alternative layouts

type                          ##  Alphanumeric keys
  KeyboardKey* {.size: sizeof(int32).} = enum
    KEY_SPACE = 32, KEY_APOSTROPHE = 39, KEY_COMMA = 44, KEY_MINUS = 45, KEY_PERIOD = 46,
    KEY_SLASH = 47, KEY_ZERO = 48, KEY_ONE = 49, KEY_TWO = 50, KEY_THREE = 51, KEY_FOUR = 52,
    KEY_FIVE = 53, KEY_SIX = 54, KEY_SEVEN = 55, KEY_EIGHT = 56, KEY_NINE = 57,
    KEY_SEMICOLON = 59, KEY_EQUAL = 61, KEY_A = 65, KEY_B = 66, KEY_C = 67, KEY_D = 68,
    KEY_E = 69, KEY_F = 70, KEY_G = 71, KEY_H = 72, KEY_I = 73, KEY_J = 74, KEY_K = 75, KEY_L = 76,
    KEY_M = 77, KEY_N = 78, KEY_O = 79, KEY_P = 80, KEY_Q = 81, KEY_R = 82, KEY_S = 83, KEY_T = 84,
    KEY_U = 85, KEY_V = 86, KEY_W = 87, KEY_X = 88, KEY_Y = 89, KEY_Z = 90, ##  Function keys
    KEY_LEFT_BRACKET = 91, KEY_BACKSLASH = 92, KEY_RIGHT_BRACKET = 93, KEY_GRAVE = 96, ##  Keypad keys
    KEY_ESCAPE = 256, KEY_ENTER = 257, KEY_TAB = 258, KEY_BACKSPACE = 259, KEY_INSERT = 260,
    KEY_DELETE = 261, KEY_RIGHT = 262, KEY_LEFT = 263, KEY_DOWN = 264, KEY_UP = 265,
    KEY_PAGE_UP = 266, KEY_PAGE_DOWN = 267, KEY_HOME = 268, KEY_END = 269,
    KEY_CAPS_LOCK = 280, KEY_SCROLL_LOCK = 281, KEY_NUM_LOCK = 282,
    KEY_PRINT_SCREEN = 283, KEY_PAUSE = 284, KEY_F1 = 290, KEY_F2 = 291, KEY_F3 = 292,
    KEY_F4 = 293, KEY_F5 = 294, KEY_F6 = 295, KEY_F7 = 296, KEY_F8 = 297, KEY_F9 = 298,
    KEY_F10 = 299, KEY_F11 = 300, KEY_F12 = 301, KEY_KP_0 = 320, KEY_KP_1 = 321,
    KEY_KP_2 = 322, KEY_KP_3 = 323, KEY_KP_4 = 324, KEY_KP_5 = 325, KEY_KP_6 = 326,
    KEY_KP_7 = 327, KEY_KP_8 = 328, KEY_KP_9 = 329, KEY_KP_DECIMAL = 330,
    KEY_KP_DIVIDE = 331, KEY_KP_MULTIPLY = 332, KEY_KP_SUBTRACT = 333, KEY_KP_ADD = 334,
    KEY_KP_ENTER = 335, KEY_KP_EQUAL = 336, KEY_LEFT_SHIFT = 340, KEY_LEFT_CONTROL = 341,
    KEY_LEFT_ALT = 342, KEY_LEFT_SUPER = 343, KEY_RIGHT_SHIFT = 344,
    KEY_RIGHT_CONTROL = 345, KEY_RIGHT_ALT = 346, KEY_RIGHT_SUPER = 347,
    KEY_KB_MENU = 348


##  Android buttons

type
  AndroidButton* {.size: sizeof(int32).} = enum
    KEY_BACK = 4, KEY_VOLUME_UP = 24, KEY_VOLUME_DOWN = 25, KEY_MENU = 82


##  Mouse buttons

type
  MouseButton* {.size: sizeof(int32).} = enum
    MOUSE_LEFT_BUTTON = 0, MOUSE_RIGHT_BUTTON = 1, MOUSE_MIDDLE_BUTTON = 2


##  Mouse cursor types

type
  MouseCursor* {.size: sizeof(int32).} = enum
    MOUSE_CURSOR_DEFAULT = 0, MOUSE_CURSOR_ARROW = 1, MOUSE_CURSOR_IBEAM = 2,
    MOUSE_CURSOR_CROSSHAIR = 3, MOUSE_CURSOR_POINTING_HAND = 4, MOUSE_CURSOR_RESIZE_EW = 5, ##  The horizontal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NS = 6, ##  The vertical resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NWSE = 7, ##  The top-left to bottom-right diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NESW = 8, ##  The top-right to bottom-left diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_ALL = 9, ##  The omni-directional resize/move cursor shape
    MOUSE_CURSOR_NOT_ALLOWED = 10


##  Gamepad number

type
  GamepadNumber* {.size: sizeof(int32).} = enum
    GAMEPAD_PLAYER1 = 0, GAMEPAD_PLAYER2 = 1, GAMEPAD_PLAYER3 = 2, GAMEPAD_PLAYER4 = 3


##  Gamepad buttons

type                          ##  This is here just for error checking
  GamepadButton* {.size: sizeof(int32).} = enum
    GAMEPAD_BUTTON_UNKNOWN = 0, ##  This is normally a DPAD
    GAMEPAD_BUTTON_LEFT_FACE_UP, GAMEPAD_BUTTON_LEFT_FACE_RIGHT,
    GAMEPAD_BUTTON_LEFT_FACE_DOWN, GAMEPAD_BUTTON_LEFT_FACE_LEFT, ##  This normally corresponds with PlayStation and Xbox controllers
                                                                ##  XBOX: [Y,X,A,B]
                                                                ##  PS3: [Triangle,Square,Cross,Circle]
                                                                ##  No support for 6 button controllers though..
    GAMEPAD_BUTTON_RIGHT_FACE_UP, GAMEPAD_BUTTON_RIGHT_FACE_RIGHT,
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN, GAMEPAD_BUTTON_RIGHT_FACE_LEFT, ##  Triggers
    GAMEPAD_BUTTON_LEFT_TRIGGER_1, GAMEPAD_BUTTON_LEFT_TRIGGER_2,
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1, GAMEPAD_BUTTON_RIGHT_TRIGGER_2, ##  These are buttons in the center of the gamepad
    GAMEPAD_BUTTON_MIDDLE_LEFT, ## PS3 Select
    GAMEPAD_BUTTON_MIDDLE,    ## PS Button/XBOX Button
    GAMEPAD_BUTTON_MIDDLE_RIGHT, ## PS3 Start
                                ##  These are the joystick press in buttons
    GAMEPAD_BUTTON_LEFT_THUMB, GAMEPAD_BUTTON_RIGHT_THUMB


##  Gamepad axis

type                          ##  Left stick
  GamepadAxis* {.size: sizeof(int32).} = enum
    GAMEPAD_AXIS_LEFT_X = 0, GAMEPAD_AXIS_LEFT_Y = 1, ##  Right stick
    GAMEPAD_AXIS_RIGHT_X = 2, GAMEPAD_AXIS_RIGHT_Y = 3, ##  Pressure levels for the back triggers
    GAMEPAD_AXIS_LEFT_TRIGGER = 4, ##  [1..-1] (pressure-level)
    GAMEPAD_AXIS_RIGHT_TRIGGER = 5


##  Shader location points

type
  ShaderLocationIndex* {.size: sizeof(int32).} = enum
    LOC_VERTEX_POSITION = 0, LOC_VERTEX_TEXCOORD01, LOC_VERTEX_TEXCOORD02,
    LOC_VERTEX_NORMAL, LOC_VERTEX_TANGENT, LOC_VERTEX_COLOR, LOC_MATRIX_MVP,
    LOC_MATRIX_MODEL, LOC_MATRIX_VIEW, LOC_MATRIX_PROJECTION, LOC_VECTOR_VIEW,
    LOC_COLOR_DIFFUSE, LOC_COLOR_SPECULAR, LOC_COLOR_AMBIENT, LOC_MAP_ALBEDO, ##  LOC_MAP_DIFFUSE
    LOC_MAP_METALNESS,        ##  LOC_MAP_SPECULAR
    LOC_MAP_NORMAL, LOC_MAP_ROUGHNESS, LOC_MAP_OCCLUSION, LOC_MAP_EMISSION,
    LOC_MAP_HEIGHT, LOC_MAP_CUBEMAP, LOC_MAP_IRRADIANCE, LOC_MAP_PREFILTER,
    LOC_MAP_BRDF


##  Shader uniform data types

type
  ShaderUniformDataType* {.size: sizeof(int32).} = enum
    UNIFORM_FLOAT = 0, UNIFORM_VEC2, UNIFORM_VEC3, UNIFORM_VEC4, UNIFORM_INT,
    UNIFORM_IVEC2, UNIFORM_IVEC3, UNIFORM_IVEC4, UNIFORM_SAMPLER2D


##  Material maps

type
  MaterialMapType* {.size: sizeof(int32).} = enum
    MAP_ALBEDO = 0,             ##  MAP_DIFFUSE
    MAP_METALNESS = 1,          ##  MAP_SPECULAR
    MAP_NORMAL = 2, MAP_ROUGHNESS = 3, MAP_OCCLUSION, MAP_EMISSION, MAP_HEIGHT, MAP_CUBEMAP, ##  NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_IRRADIANCE,           ##  NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_PREFILTER,            ##  NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_BRDF


##  Pixel formats
##  NOTE: Support depends on OpenGL version and platform

type
  PixelFormat* {.size: sizeof(int32).} = enum
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
    COMPRESSED_ASTC_4x4_RGBA, ##  8 bpp
    COMPRESSED_ASTC_8x8_RGBA  ##  2 bpp


##  Texture parameters: filter mode
##  NOTE 1: Filtering considers mipmaps if available in the texture
##  NOTE 2: Filter is accordingly set for minification and magnification

type
  TextureFilterMode* {.size: sizeof(int32).} = enum
    FILTER_POINT = 0,           ##  No filter, just pixel aproximation
    FILTER_BILINEAR,          ##  Linear filtering
    FILTER_TRILINEAR,         ##  Trilinear filtering (linear with mipmaps)
    FILTER_ANISOTROPIC_4X,    ##  Anisotropic filtering 4x
    FILTER_ANISOTROPIC_8X,    ##  Anisotropic filtering 8x
    FILTER_ANISOTROPIC_16X    ##  Anisotropic filtering 16x


##  Texture parameters: wrap mode

type
  TextureWrapMode* {.size: sizeof(int32).} = enum
    WRAP_REPEAT = 0,            ##  Repeats texture in tiled mode
    WRAP_CLAMP,               ##  Clamps texture to edge pixel in tiled mode
    WRAP_MIRROR_REPEAT,       ##  Mirrors and repeats the texture in tiled mode
    WRAP_MIRROR_CLAMP         ##  Mirrors and clamps to border the texture in tiled mode


##  Cubemap layouts

type
  CubemapLayoutType* {.size: sizeof(int32).} = enum
    CUBEMAP_AUTO_DETECT = 0,    ##  Automatically detect layout type
    CUBEMAP_LINE_VERTICAL,    ##  Layout is defined by a vertical line with faces
    CUBEMAP_LINE_HORIZONTAL,  ##  Layout is defined by an horizontal line with faces
    CUBEMAP_CROSS_THREE_BY_FOUR, ##  Layout is defined by a 3x4 cross with cubemap faces
    CUBEMAP_CROSS_FOUR_BY_THREE, ##  Layout is defined by a 4x3 cross with cubemap faces
    CUBEMAP_PANORAMA          ##  Layout is defined by a panorama image (equirectangular map)


##  Font type, defines generation method

type
  FontType* {.size: sizeof(int32).} = enum
    FONT_DEFAULT = 0,           ##  Default font generation, anti-aliased
    FONT_BITMAP,              ##  Bitmap font generation, no anti-aliasing
    FONT_SDF                  ##  SDF font generation, requires external shader


##  Color blending modes (pre-defined)

type
  BlendMode* {.size: sizeof(int32).} = enum
    BLEND_ALPHA = 0,            ##  Blend textures considering alpha (default)
    BLEND_ADDITIVE,           ##  Blend textures adding colors
    BLEND_MULTIPLIED,         ##  Blend textures multiplying colors
    BLEND_ADD_COLORS,         ##  Blend textures adding colors (alternative)
    BLEND_SUBTRACT_COLORS,    ##  Blend textures subtracting colors (alternative)
    BLEND_CUSTOM              ##  Belnd textures using custom src/dst factors (use SetBlendModeCustom())


##  Gestures type
##  NOTE: It could be used as flags to enable only some gestures

type
  GestureType* {.size: sizeof(int32).} = enum
    GESTURE_NONE = 0, GESTURE_TAP = 1, GESTURE_DOUBLETAP = 2, GESTURE_HOLD = 4,
    GESTURE_DRAG = 8, GESTURE_SWIPE_RIGHT = 16, GESTURE_SWIPE_LEFT = 32,
    GESTURE_SWIPE_UP = 64, GESTURE_SWIPE_DOWN = 128, GESTURE_PINCH_IN = 256,
    GESTURE_PINCH_OUT = 512


##  Camera system modes

type
  CameraMode* {.size: sizeof(int32).} = enum
    CAMERA_CUSTOM = 0, CAMERA_FREE, CAMERA_ORBITAL, CAMERA_FIRST_PERSON,
    CAMERA_THIRD_PERSON


##  Camera projection modes

type
  CameraType* {.size: sizeof(int32).} = enum
    CAMERA_PERSPECTIVE = 0, CAMERA_ORTHOGRAPHIC


##  N-patch types

type
  NPatchType* {.size: sizeof(int32).} = enum
    NPT_9PATCH = 0,             ##  Npatch defined by 3x3 tiles
    NPT_3PATCH_VERTICAL,      ##  Npatch defined by 1x3 tiles
    NPT_3PATCH_HORIZONTAL     ##  Npatch defined by 3x1 tiles


##  Callbacks to be implemented by users

type
  TraceLogCallback* = proc (logType: int32; text: cstring; args: va_list) {.cdecl.}

## ------------------------------------------------------------------------------------
##  Global Variables Definition
## ------------------------------------------------------------------------------------
##  It's lonely here...
## ------------------------------------------------------------------------------------
##  Window and Graphics Device Functions (Module: core)
## ------------------------------------------------------------------------------------
##  Window-related functions

proc InitWindow*(width: int32; height: int32; title: cstring) {.cdecl,
    importc: "InitWindow", dynlib: raylibdll.}
##  Initialize window and OpenGL context

proc WindowShouldClose*(): bool {.cdecl, importc: "WindowShouldClose",
                               dynlib: raylibdll.}
##  Check if KEY_ESCAPE pressed or Close icon pressed

proc CloseWindow*() {.cdecl, importc: "CloseWindow", dynlib: raylibdll.}
##  Close window and unload OpenGL context

proc IsWindowReady*(): bool {.cdecl, importc: "IsWindowReady", dynlib: raylibdll.}
##  Check if window has been initialized successfully

proc IsWindowFullscreen*(): bool {.cdecl, importc: "IsWindowFullscreen",
                                dynlib: raylibdll.}
##  Check if window is currently fullscreen

proc IsWindowHidden*(): bool {.cdecl, importc: "IsWindowHidden", dynlib: raylibdll.}
##  Check if window is currently hidden (only PLATFORM_DESKTOP)

proc IsWindowMinimized*(): bool {.cdecl, importc: "IsWindowMinimized",
                               dynlib: raylibdll.}
##  Check if window is currently minimized (only PLATFORM_DESKTOP)

proc IsWindowMaximized*(): bool {.cdecl, importc: "IsWindowMaximized",
                               dynlib: raylibdll.}
##  Check if window is currently maximized (only PLATFORM_DESKTOP)

proc IsWindowFocused*(): bool {.cdecl, importc: "IsWindowFocused", dynlib: raylibdll.}
##  Check if window is currently focused (only PLATFORM_DESKTOP)

proc IsWindowResized*(): bool {.cdecl, importc: "IsWindowResized", dynlib: raylibdll.}
##  Check if window has been resized last frame

proc IsWindowState*(flag: uint32): bool {.cdecl, importc: "IsWindowState",
                                     dynlib: raylibdll.}
##  Check if one specific window flag is enabled

proc SetWindowState*(flags: uint32) {.cdecl, importc: "SetWindowState",
                                  dynlib: raylibdll.}
##  Set window configuration state using flags

proc ClearWindowState*(flags: uint32) {.cdecl, importc: "ClearWindowState",
                                    dynlib: raylibdll.}
##  Clear window configuration state flags

proc ToggleFullscreen*() {.cdecl, importc: "ToggleFullscreen", dynlib: raylibdll.}
##  Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)

proc MaximizeWindow*() {.cdecl, importc: "MaximizeWindow", dynlib: raylibdll.}
##  Set window state: maximized, if resizable (only PLATFORM_DESKTOP)

proc MinimizeWindow*() {.cdecl, importc: "MinimizeWindow", dynlib: raylibdll.}
##  Set window state: minimized, if resizable (only PLATFORM_DESKTOP)

proc RestoreWindow*() {.cdecl, importc: "RestoreWindow", dynlib: raylibdll.}
##  Set window state: not minimized/maximized (only PLATFORM_DESKTOP)

proc SetWindowIcon*(image: Image) {.cdecl, importc: "SetWindowIcon", dynlib: raylibdll.}
##  Set icon for window (only PLATFORM_DESKTOP)

proc SetWindowTitle*(title: cstring) {.cdecl, importc: "SetWindowTitle",
                                    dynlib: raylibdll.}
##  Set title for window (only PLATFORM_DESKTOP)

proc SetWindowPosition*(x: int32; y: int32) {.cdecl, importc: "SetWindowPosition",
                                       dynlib: raylibdll.}
##  Set window position on screen (only PLATFORM_DESKTOP)

proc SetWindowMonitor*(monitor: int32) {.cdecl, importc: "SetWindowMonitor",
                                     dynlib: raylibdll.}
##  Set monitor for the current window (fullscreen mode)

proc SetWindowMinSize*(width: int32; height: int32) {.cdecl,
    importc: "SetWindowMinSize", dynlib: raylibdll.}
##  Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)

proc SetWindowSize*(width: int32; height: int32) {.cdecl, importc: "SetWindowSize",
    dynlib: raylibdll.}
##  Set window dimensions

proc GetWindowHandle*(): pointer {.cdecl, importc: "GetWindowHandle",
                                dynlib: raylibdll.}
##  Get native window handle

proc GetScreenWidth*(): int32 {.cdecl, importc: "GetScreenWidth", dynlib: raylibdll.}
##  Get current screen width

proc GetScreenHeight*(): int32 {.cdecl, importc: "GetScreenHeight", dynlib: raylibdll.}
##  Get current screen height

proc GetMonitorCount*(): int32 {.cdecl, importc: "GetMonitorCount", dynlib: raylibdll.}
##  Get number of connected monitors

proc GetCurrentMonitor*(): int32 {.cdecl, importc: "GetCurrentMonitor",
                               dynlib: raylibdll.}
##  Get current connected monitor

proc GetMonitorPosition*(monitor: int32): Vector2 {.cdecl,
    importc: "GetMonitorPosition", dynlib: raylibdll.}
##  Get specified monitor position

proc GetMonitorWidth*(monitor: int32): int32 {.cdecl, importc: "GetMonitorWidth",
    dynlib: raylibdll.}
##  Get specified monitor width

proc GetMonitorHeight*(monitor: int32): int32 {.cdecl, importc: "GetMonitorHeight",
    dynlib: raylibdll.}
##  Get specified monitor height

proc GetMonitorPhysicalWidth*(monitor: int32): int32 {.cdecl,
    importc: "GetMonitorPhysicalWidth", dynlib: raylibdll.}
##  Get specified monitor physical width in millimetres

proc GetMonitorPhysicalHeight*(monitor: int32): int32 {.cdecl,
    importc: "GetMonitorPhysicalHeight", dynlib: raylibdll.}
##  Get specified monitor physical height in millimetres

proc GetMonitorRefreshRate*(monitor: int32): int32 {.cdecl,
    importc: "GetMonitorRefreshRate", dynlib: raylibdll.}
##  Get specified monitor refresh rate

proc GetWindowPosition*(): Vector2 {.cdecl, importc: "GetWindowPosition",
                                  dynlib: raylibdll.}
##  Get window position XY on monitor

proc GetWindowScaleDPI*(): Vector2 {.cdecl, importc: "GetWindowScaleDPI",
                                  dynlib: raylibdll.}
##  Get window scale DPI factor

proc GetMonitorName*(monitor: int32): cstring {.cdecl, importc: "GetMonitorName",
    dynlib: raylibdll.}
##  Get the human-readable, UTF-8 encoded name of the primary monitor

proc SetClipboardText*(text: cstring) {.cdecl, importc: "SetClipboardText",
                                     dynlib: raylibdll.}
##  Set clipboard text content

proc GetClipboardText*(): cstring {.cdecl, importc: "GetClipboardText",
                                 dynlib: raylibdll.}
##  Get clipboard text content
##  Cursor-related functions

proc ShowCursor*() {.cdecl, importc: "ShowCursor", dynlib: raylibdll.}
##  Shows cursor

proc HideCursor*() {.cdecl, importc: "HideCursor", dynlib: raylibdll.}
##  Hides cursor

proc IsCursorHidden*(): bool {.cdecl, importc: "IsCursorHidden", dynlib: raylibdll.}
##  Check if cursor is not visible

proc EnableCursor*() {.cdecl, importc: "EnableCursor", dynlib: raylibdll.}
##  Enables cursor (unlock cursor)

proc DisableCursor*() {.cdecl, importc: "DisableCursor", dynlib: raylibdll.}
##  Disables cursor (lock cursor)

proc IsCursorOnScreen*(): bool {.cdecl, importc: "IsCursorOnScreen", dynlib: raylibdll.}
##  Check if cursor is on the current screen.
##  Drawing-related functions

proc ClearBackground*(color: Color) {.cdecl, importc: "ClearBackground",
                                   dynlib: raylibdll.}
##  Set background color (framebuffer clear color)

proc BeginDrawing*() {.cdecl, importc: "BeginDrawing", dynlib: raylibdll.}
##  Setup canvas (framebuffer) to start drawing

proc EndDrawing*() {.cdecl, importc: "EndDrawing", dynlib: raylibdll.}
##  End canvas drawing and swap buffers (double buffering)

proc BeginMode2D*(camera: Camera2D) {.cdecl, importc: "BeginMode2D", dynlib: raylibdll.}
##  Initialize 2D mode with custom camera (2D)

proc EndMode2D*() {.cdecl, importc: "EndMode2D", dynlib: raylibdll.}
##  Ends 2D mode with custom camera

proc BeginMode3D*(camera: Camera3D) {.cdecl, importc: "BeginMode3D", dynlib: raylibdll.}
##  Initializes 3D mode with custom camera (3D)

proc EndMode3D*() {.cdecl, importc: "EndMode3D", dynlib: raylibdll.}
##  Ends 3D mode and returns to default 2D orthographic mode

proc BeginTextureMode*(target: RenderTexture2D) {.cdecl,
    importc: "BeginTextureMode", dynlib: raylibdll.}
##  Initializes render texture for drawing

proc EndTextureMode*() {.cdecl, importc: "EndTextureMode", dynlib: raylibdll.}
##  Ends drawing to render texture

proc BeginScissorMode*(x: int32; y: int32; width: int32; height: int32) {.cdecl,
    importc: "BeginScissorMode", dynlib: raylibdll.}
##  Begin scissor mode (define screen area for following drawing)

proc EndScissorMode*() {.cdecl, importc: "EndScissorMode", dynlib: raylibdll.}
##  End scissor mode
##  Screen-space-related functions

proc GetMouseRay*(mousePosition: Vector2; camera: Camera): Ray {.cdecl,
    importc: "GetMouseRay", dynlib: raylibdll.}
##  Returns a ray trace from mouse position

proc GetCameraMatrix*(camera: Camera): Matrix {.cdecl, importc: "GetCameraMatrix",
    dynlib: raylibdll.}
##  Returns camera transform matrix (view matrix)

proc GetCameraMatrix2D*(camera: Camera2D): Matrix {.cdecl,
    importc: "GetCameraMatrix2D", dynlib: raylibdll.}
##  Returns camera 2d transform matrix

proc GetWorldToScreen*(position: Vector3; camera: Camera): Vector2 {.cdecl,
    importc: "GetWorldToScreen", dynlib: raylibdll.}
##  Returns the screen space position for a 3d world space position

proc GetWorldToScreenEx*(position: Vector3; camera: Camera; width: int32; height: int32): Vector2 {.
    cdecl, importc: "GetWorldToScreenEx", dynlib: raylibdll.}
##  Returns size position for a 3d world space position

proc GetWorldToScreen2D*(position: Vector2; camera: Camera2D): Vector2 {.cdecl,
    importc: "GetWorldToScreen2D", dynlib: raylibdll.}
##  Returns the screen space position for a 2d camera world space position

proc GetScreenToWorld2D*(position: Vector2; camera: Camera2D): Vector2 {.cdecl,
    importc: "GetScreenToWorld2D", dynlib: raylibdll.}
##  Returns the world space position for a 2d camera screen space position
##  Timing-related functions

proc SetTargetFPS*(fps: int32) {.cdecl, importc: "SetTargetFPS", dynlib: raylibdll.}
##  Set target FPS (maximum)

proc GetFPS*(): int32 {.cdecl, importc: "GetFPS", dynlib: raylibdll.}
##  Returns current FPS

proc GetFrameTime*(): float32 {.cdecl, importc: "GetFrameTime", dynlib: raylibdll.}
##  Returns time in seconds for last frame drawn

proc GetTime*(): cdouble {.cdecl, importc: "GetTime", dynlib: raylibdll.}
##  Returns elapsed time in seconds since InitWindow()
##  Misc. functions

proc SetConfigFlags*(flags: uint32) {.cdecl, importc: "SetConfigFlags",
                                  dynlib: raylibdll.}
##  Setup init configuration flags (view FLAGS)

proc SetTraceLogLevel*(logType: int32) {.cdecl, importc: "SetTraceLogLevel",
                                     dynlib: raylibdll.}
##  Set the current threshold (minimum) log level

proc SetTraceLogExit*(logType: int32) {.cdecl, importc: "SetTraceLogExit",
                                    dynlib: raylibdll.}
##  Set the exit threshold (minimum) log level

proc SetTraceLogCallback*(callback: TraceLogCallback) {.cdecl,
    importc: "SetTraceLogCallback", dynlib: raylibdll.}
##  Set a trace log callback to enable custom logging

proc TraceLog*(logType: int32; text: cstring) {.varargs, cdecl, importc: "TraceLog",
    dynlib: raylibdll.}
##  Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR)

proc MemAlloc*(size: int32): pointer {.cdecl, importc: "MemAlloc", dynlib: raylibdll.}
##  Internal memory allocator

proc MemFree*(`ptr`: pointer) {.cdecl, importc: "MemFree", dynlib: raylibdll.}
##  Internal memory free

proc TakeScreenshot*(fileName: cstring) {.cdecl, importc: "TakeScreenshot",
                                       dynlib: raylibdll.}
##  Takes a screenshot of current screen (saved a .png)

proc GetRandomValue*(min: int32; max: int32): int32 {.cdecl, importc: "GetRandomValue",
    dynlib: raylibdll.}
##  Returns a random value between min and max (both included)
##  Files management functions

proc LoadFileData*(fileName: cstring; bytesRead: ptr uint32): ptr uint8 {.cdecl,
    importc: "LoadFileData", dynlib: raylibdll.}
##  Load file data as byte array (read)

proc UnloadFileData*(data: ptr uint8) {.cdecl, importc: "UnloadFileData",
                                     dynlib: raylibdll.}
##  Unload file data allocated by LoadFileData()

proc SaveFileData*(fileName: cstring; data: pointer; bytesToWrite: uint32): bool {.cdecl,
    importc: "SaveFileData", dynlib: raylibdll.}
##  Save data to file from byte array (write), returns true on success

proc LoadFileText*(fileName: cstring): cstring {.cdecl, importc: "LoadFileText",
    dynlib: raylibdll.}
##  Load text data from file (read), returns a '\0' terminated string

proc UnloadFileText*(text: ptr uint8) {.cdecl, importc: "UnloadFileText",
                                     dynlib: raylibdll.}
##  Unload file text data allocated by LoadFileText()

proc SaveFileText*(fileName: cstring; text: cstring): bool {.cdecl,
    importc: "SaveFileText", dynlib: raylibdll.}
##  Save text data to file (write), string must be '\0' terminated, returns true on success

proc FileExists*(fileName: cstring): bool {.cdecl, importc: "FileExists",
                                        dynlib: raylibdll.}
##  Check if file exists

proc DirectoryExists*(dirPath: cstring): bool {.cdecl, importc: "DirectoryExists",
    dynlib: raylibdll.}
##  Check if a directory path exists

proc IsFileExtension*(fileName: cstring; ext: cstring): bool {.cdecl,
    importc: "IsFileExtension", dynlib: raylibdll.}
##  Check file extension (including point: .png, .wav)

proc GetFileExtension*(fileName: cstring): cstring {.cdecl,
    importc: "GetFileExtension", dynlib: raylibdll.}
##  Get pointer to extension for a filename string (including point: ".png")

proc GetFileName*(filePath: cstring): cstring {.cdecl, importc: "GetFileName",
    dynlib: raylibdll.}
##  Get pointer to filename for a path string

proc GetFileNameWithoutExt*(filePath: cstring): cstring {.cdecl,
    importc: "GetFileNameWithoutExt", dynlib: raylibdll.}
##  Get filename string without extension (uses static string)

proc GetDirectoryPath*(filePath: cstring): cstring {.cdecl,
    importc: "GetDirectoryPath", dynlib: raylibdll.}
##  Get full path for a given fileName with path (uses static string)

proc GetPrevDirectoryPath*(dirPath: cstring): cstring {.cdecl,
    importc: "GetPrevDirectoryPath", dynlib: raylibdll.}
##  Get previous directory path for a given path (uses static string)

proc GetWorkingDirectory*(): cstring {.cdecl, importc: "GetWorkingDirectory",
                                    dynlib: raylibdll.}
##  Get current working directory (uses static string)

proc GetDirectoryFiles*(dirPath: cstring; count: ptr int32): cstringArray {.cdecl,
    importc: "GetDirectoryFiles", dynlib: raylibdll.}
##  Get filenames in a directory path (memory should be freed)

proc ClearDirectoryFiles*() {.cdecl, importc: "ClearDirectoryFiles",
                            dynlib: raylibdll.}
##  Clear directory files paths buffers (free memory)

proc ChangeDirectory*(dir: cstring): bool {.cdecl, importc: "ChangeDirectory",
                                        dynlib: raylibdll.}
##  Change working directory, return true on success

proc IsFileDropped*(): bool {.cdecl, importc: "IsFileDropped", dynlib: raylibdll.}
##  Check if a file has been dropped into window

proc GetDroppedFiles*(count: ptr int32): cstringArray {.cdecl,
    importc: "GetDroppedFiles", dynlib: raylibdll.}
##  Get dropped files names (memory should be freed)

proc ClearDroppedFiles*() {.cdecl, importc: "ClearDroppedFiles", dynlib: raylibdll.}
##  Clear dropped files paths buffer (free memory)

proc GetFileModTime*(fileName: cstring): clong {.cdecl, importc: "GetFileModTime",
    dynlib: raylibdll.}
##  Get file modification time (last write time)

proc CompressData*(data: ptr uint8; dataLength: int32; compDataLength: ptr int32): ptr uint8 {.
    cdecl, importc: "CompressData", dynlib: raylibdll.}
##  Compress data (DEFLATE algorithm)

proc DecompressData*(compData: ptr uint8; compDataLength: int32; dataLength: ptr int32): ptr uint8 {.
    cdecl, importc: "DecompressData", dynlib: raylibdll.}
##  Decompress data (DEFLATE algorithm)
##  Persistent storage management

proc SaveStorageValue*(position: uint32; value: int32): bool {.cdecl,
    importc: "SaveStorageValue", dynlib: raylibdll.}
##  Save integer value to storage file (to defined position), returns true on success

proc LoadStorageValue*(position: uint32): int32 {.cdecl, importc: "LoadStorageValue",
    dynlib: raylibdll.}
##  Load integer value from storage file (from defined position)

proc OpenURL*(url: cstring) {.cdecl, importc: "OpenURL", dynlib: raylibdll.}
##  Open URL with default system browser (if available)
## ------------------------------------------------------------------------------------
##  Input Handling Functions (Module: core)
## ------------------------------------------------------------------------------------
##  Input-related functions: keyboard

proc IsKeyPressed*(key: int32): bool {.cdecl, importc: "IsKeyPressed", dynlib: raylibdll.}
##  Detect if a key has been pressed once

proc IsKeyDown*(key: int32): bool {.cdecl, importc: "IsKeyDown", dynlib: raylibdll.}
##  Detect if a key is being pressed

proc IsKeyReleased*(key: int32): bool {.cdecl, importc: "IsKeyReleased",
                                   dynlib: raylibdll.}
##  Detect if a key has been released once

proc IsKeyUp*(key: int32): bool {.cdecl, importc: "IsKeyUp", dynlib: raylibdll.}
##  Detect if a key is NOT being pressed

proc SetExitKey*(key: int32) {.cdecl, importc: "SetExitKey", dynlib: raylibdll.}
##  Set a custom key to exit program (default is ESC)

proc GetKeyPressed*(): int32 {.cdecl, importc: "GetKeyPressed", dynlib: raylibdll.}
##  Get key pressed (keycode), call it multiple times for keys queued

proc GetCharPressed*(): int32 {.cdecl, importc: "GetCharPressed", dynlib: raylibdll.}
##  Get char pressed (unicode), call it multiple times for chars queued
##  Input-related functions: gamepads

proc IsGamepadAvailable*(gamepad: int32): bool {.cdecl, importc: "IsGamepadAvailable",
    dynlib: raylibdll.}
##  Detect if a gamepad is available

proc IsGamepadName*(gamepad: int32; name: cstring): bool {.cdecl,
    importc: "IsGamepadName", dynlib: raylibdll.}
##  Check gamepad name (if available)

proc GetGamepadName*(gamepad: int32): cstring {.cdecl, importc: "GetGamepadName",
    dynlib: raylibdll.}
##  Return gamepad internal name id

proc IsGamepadButtonPressed*(gamepad: int32; button: int32): bool {.cdecl,
    importc: "IsGamepadButtonPressed", dynlib: raylibdll.}
##  Detect if a gamepad button has been pressed once

proc IsGamepadButtonDown*(gamepad: int32; button: int32): bool {.cdecl,
    importc: "IsGamepadButtonDown", dynlib: raylibdll.}
##  Detect if a gamepad button is being pressed

proc IsGamepadButtonReleased*(gamepad: int32; button: int32): bool {.cdecl,
    importc: "IsGamepadButtonReleased", dynlib: raylibdll.}
##  Detect if a gamepad button has been released once

proc IsGamepadButtonUp*(gamepad: int32; button: int32): bool {.cdecl,
    importc: "IsGamepadButtonUp", dynlib: raylibdll.}
##  Detect if a gamepad button is NOT being pressed

proc GetGamepadButtonPressed*(): int32 {.cdecl, importc: "GetGamepadButtonPressed",
                                     dynlib: raylibdll.}
##  Get the last gamepad button pressed

proc GetGamepadAxisCount*(gamepad: int32): int32 {.cdecl,
    importc: "GetGamepadAxisCount", dynlib: raylibdll.}
##  Return gamepad axis count for a gamepad

proc GetGamepadAxisMovement*(gamepad: int32; axis: int32): float32 {.cdecl,
    importc: "GetGamepadAxisMovement", dynlib: raylibdll.}
##  Return axis movement value for a gamepad axis
##  Input-related functions: mouse

proc IsMouseButtonPressed*(button: int32): bool {.cdecl,
    importc: "IsMouseButtonPressed", dynlib: raylibdll.}
##  Detect if a mouse button has been pressed once

proc IsMouseButtonDown*(button: int32): bool {.cdecl, importc: "IsMouseButtonDown",
    dynlib: raylibdll.}
##  Detect if a mouse button is being pressed

proc IsMouseButtonReleased*(button: int32): bool {.cdecl,
    importc: "IsMouseButtonReleased", dynlib: raylibdll.}
##  Detect if a mouse button has been released once

proc IsMouseButtonUp*(button: int32): bool {.cdecl, importc: "IsMouseButtonUp",
                                        dynlib: raylibdll.}
##  Detect if a mouse button is NOT being pressed

proc GetMouseX*(): int32 {.cdecl, importc: "GetMouseX", dynlib: raylibdll.}
##  Returns mouse position X

proc GetMouseY*(): int32 {.cdecl, importc: "GetMouseY", dynlib: raylibdll.}
##  Returns mouse position Y

proc GetMousePosition*(): Vector2 {.cdecl, importc: "GetMousePosition",
                                 dynlib: raylibdll.}
##  Returns mouse position XY

proc SetMousePosition*(x: int32; y: int32) {.cdecl, importc: "SetMousePosition",
                                      dynlib: raylibdll.}
##  Set mouse position XY

proc SetMouseOffset*(offsetX: int32; offsetY: int32) {.cdecl, importc: "SetMouseOffset",
    dynlib: raylibdll.}
##  Set mouse offset

proc SetMouseScale*(scaleX: float32; scaleY: float32) {.cdecl, importc: "SetMouseScale",
    dynlib: raylibdll.}
##  Set mouse scaling

proc GetMouseWheelMove*(): float32 {.cdecl, importc: "GetMouseWheelMove",
                                 dynlib: raylibdll.}
##  Returns mouse wheel movement Y

proc GetMouseCursor*(): int32 {.cdecl, importc: "GetMouseCursor", dynlib: raylibdll.}
##  Returns mouse cursor if (MouseCursor enum)

proc SetMouseCursor*(cursor: int32) {.cdecl, importc: "SetMouseCursor",
                                  dynlib: raylibdll.}
##  Set mouse cursor
##  Input-related functions: touch

proc GetTouchX*(): int32 {.cdecl, importc: "GetTouchX", dynlib: raylibdll.}
##  Returns touch position X for touch point 0 (relative to screen size)

proc GetTouchY*(): int32 {.cdecl, importc: "GetTouchY", dynlib: raylibdll.}
##  Returns touch position Y for touch point 0 (relative to screen size)

proc GetTouchPosition*(index: int32): Vector2 {.cdecl, importc: "GetTouchPosition",
    dynlib: raylibdll.}
##  Returns touch position XY for a touch point index (relative to screen size)
## ------------------------------------------------------------------------------------
##  Gestures and Touch Handling Functions (Module: gestures)
## ------------------------------------------------------------------------------------

proc SetGesturesEnabled*(gestureFlags: uint32) {.cdecl,
    importc: "SetGesturesEnabled", dynlib: raylibdll.}
##  Enable a set of gestures using flags

proc IsGestureDetected*(gesture: int32): bool {.cdecl, importc: "IsGestureDetected",
    dynlib: raylibdll.}
##  Check if a gesture have been detected

proc GetGestureDetected*(): int32 {.cdecl, importc: "GetGestureDetected",
                                dynlib: raylibdll.}
##  Get latest detected gesture

proc GetTouchPointsCount*(): int32 {.cdecl, importc: "GetTouchPointsCount",
                                 dynlib: raylibdll.}
##  Get touch points count

proc GetGestureHoldDuration*(): float32 {.cdecl, importc: "GetGestureHoldDuration",
                                      dynlib: raylibdll.}
##  Get gesture hold time in milliseconds

proc GetGestureDragVector*(): Vector2 {.cdecl, importc: "GetGestureDragVector",
                                     dynlib: raylibdll.}
##  Get gesture drag vector

proc GetGestureDragAngle*(): float32 {.cdecl, importc: "GetGestureDragAngle",
                                   dynlib: raylibdll.}
##  Get gesture drag angle

proc GetGesturePinchVector*(): Vector2 {.cdecl, importc: "GetGesturePinchVector",
                                      dynlib: raylibdll.}
##  Get gesture pinch delta

proc GetGesturePinchAngle*(): float32 {.cdecl, importc: "GetGesturePinchAngle",
                                    dynlib: raylibdll.}
##  Get gesture pinch angle
## ------------------------------------------------------------------------------------
##  Camera System Functions (Module: camera)
## ------------------------------------------------------------------------------------

proc SetCameraMode*(camera: Camera; mode: int32) {.cdecl, importc: "SetCameraMode",
    dynlib: raylibdll.}
##  Set camera mode (multiple camera modes available)

proc UpdateCamera*(camera: ptr Camera) {.cdecl, importc: "UpdateCamera",
                                     dynlib: raylibdll.}
##  Update camera position for selected mode

proc SetCameraPanControl*(keyPan: int32) {.cdecl, importc: "SetCameraPanControl",
                                       dynlib: raylibdll.}
##  Set camera pan key to combine with mouse movement (free camera)

proc SetCameraAltControl*(keyAlt: int32) {.cdecl, importc: "SetCameraAltControl",
                                       dynlib: raylibdll.}
##  Set camera alt key to combine with mouse movement (free camera)

proc SetCameraSmoothZoomControl*(keySmoothZoom: int32) {.cdecl,
    importc: "SetCameraSmoothZoomControl", dynlib: raylibdll.}
##  Set camera smooth zoom key to combine with mouse (free camera)

proc SetCameraMoveControls*(keyFront: int32; keyBack: int32; keyRight: int32;
                           keyLeft: int32; keyUp: int32; keyDown: int32) {.cdecl,
    importc: "SetCameraMoveControls", dynlib: raylibdll.}
##  Set camera move controls (1st person and 3rd person cameras)
## ------------------------------------------------------------------------------------
##  Basic Shapes Drawing Functions (Module: shapes)
## ------------------------------------------------------------------------------------
##  Basic shapes drawing functions

proc DrawPixel*(posX: int32; posY: int32; color: Color) {.cdecl, importc: "DrawPixel",
    dynlib: raylibdll.}
##  Draw a pixel

proc DrawPixelV*(position: Vector2; color: Color) {.cdecl, importc: "DrawPixelV",
    dynlib: raylibdll.}
##  Draw a pixel (Vector version)

proc DrawLine*(startPosX: int32; startPosY: int32; endPosX: int32; endPosY: int32;
              color: Color) {.cdecl, importc: "DrawLine", dynlib: raylibdll.}
##  Draw a line

proc DrawLineV*(startPos: Vector2; endPos: Vector2; color: Color) {.cdecl,
    importc: "DrawLineV", dynlib: raylibdll.}
##  Draw a line (Vector version)

proc DrawLineEx*(startPos: Vector2; endPos: Vector2; thick: float32; color: Color) {.
    cdecl, importc: "DrawLineEx", dynlib: raylibdll.}
##  Draw a line defining thickness

proc DrawLineBezier*(startPos: Vector2; endPos: Vector2; thick: float32; color: Color) {.
    cdecl, importc: "DrawLineBezier", dynlib: raylibdll.}
##  Draw a line using cubic-bezier curves in-out

proc DrawLineBezierQuad*(startPos: Vector2; endPos: Vector2; controlPos: Vector2;
                        thick: float32; color: Color) {.cdecl,
    importc: "DrawLineBezierQuad", dynlib: raylibdll.}
## Draw line using quadratic bezier curves with a control point

proc DrawLineStrip*(points: ptr Vector2; pointsCount: int32; color: Color) {.cdecl,
    importc: "DrawLineStrip", dynlib: raylibdll.}
##  Draw lines sequence

proc DrawCircle*(centerX: int32; centerY: int32; radius: float32; color: Color) {.cdecl,
    importc: "DrawCircle", dynlib: raylibdll.}
##  Draw a color-filled circle

proc DrawCircleSector*(center: Vector2; radius: float32; startAngle: int32;
                      endAngle: int32; segments: int32; color: Color) {.cdecl,
    importc: "DrawCircleSector", dynlib: raylibdll.}
##  Draw a piece of a circle

proc DrawCircleSectorLines*(center: Vector2; radius: float32; startAngle: int32;
                           endAngle: int32; segments: int32; color: Color) {.cdecl,
    importc: "DrawCircleSectorLines", dynlib: raylibdll.}
##  Draw circle sector outline

proc DrawCircleGradient*(centerX: int32; centerY: int32; radius: float32; color1: Color;
                        color2: Color) {.cdecl, importc: "DrawCircleGradient",
                                       dynlib: raylibdll.}
##  Draw a gradient-filled circle

proc DrawCircleV*(center: Vector2; radius: float32; color: Color) {.cdecl,
    importc: "DrawCircleV", dynlib: raylibdll.}
##  Draw a color-filled circle (Vector version)

proc DrawCircleLines*(centerX: int32; centerY: int32; radius: float32; color: Color) {.
    cdecl, importc: "DrawCircleLines", dynlib: raylibdll.}
##  Draw circle outline

proc DrawEllipse*(centerX: int32; centerY: int32; radiusH: float32; radiusV: float32;
                 color: Color) {.cdecl, importc: "DrawEllipse", dynlib: raylibdll.}
##  Draw ellipse

proc DrawEllipseLines*(centerX: int32; centerY: int32; radiusH: float32; radiusV: float32;
                      color: Color) {.cdecl, importc: "DrawEllipseLines",
                                    dynlib: raylibdll.}
##  Draw ellipse outline

proc DrawRing*(center: Vector2; innerRadius: float32; outerRadius: float32;
              startAngle: int32; endAngle: int32; segments: int32; color: Color) {.cdecl,
    importc: "DrawRing", dynlib: raylibdll.}
##  Draw ring

proc DrawRingLines*(center: Vector2; innerRadius: float32; outerRadius: float32;
                   startAngle: int32; endAngle: int32; segments: int32; color: Color) {.
    cdecl, importc: "DrawRingLines", dynlib: raylibdll.}
##  Draw ring outline

proc DrawRectangle*(posX: int32; posY: int32; width: int32; height: int32; color: Color) {.
    cdecl, importc: "DrawRectangle", dynlib: raylibdll.}
##  Draw a color-filled rectangle

proc DrawRectangleV*(position: Vector2; size: Vector2; color: Color) {.cdecl,
    importc: "DrawRectangleV", dynlib: raylibdll.}
##  Draw a color-filled rectangle (Vector version)

proc DrawRectangleRec*(rec: Rectangle; color: Color) {.cdecl,
    importc: "DrawRectangleRec", dynlib: raylibdll.}
##  Draw a color-filled rectangle

proc DrawRectanglePro*(rec: Rectangle; origin: Vector2; rotation: float32; color: Color) {.
    cdecl, importc: "DrawRectanglePro", dynlib: raylibdll.}
##  Draw a color-filled rectangle with pro parameters

proc DrawRectangleGradientV*(posX: int32; posY: int32; width: int32; height: int32;
                            color1: Color; color2: Color) {.cdecl,
    importc: "DrawRectangleGradientV", dynlib: raylibdll.}
##  Draw a vertical-gradient-filled rectangle

proc DrawRectangleGradientH*(posX: int32; posY: int32; width: int32; height: int32;
                            color1: Color; color2: Color) {.cdecl,
    importc: "DrawRectangleGradientH", dynlib: raylibdll.}
##  Draw a horizontal-gradient-filled rectangle

proc DrawRectangleGradientEx*(rec: Rectangle; col1: Color; col2: Color; col3: Color;
                             col4: Color) {.cdecl,
    importc: "DrawRectangleGradientEx", dynlib: raylibdll.}
##  Draw a gradient-filled rectangle with custom vertex colors

proc DrawRectangleLines*(posX: int32; posY: int32; width: int32; height: int32; color: Color) {.
    cdecl, importc: "DrawRectangleLines", dynlib: raylibdll.}
##  Draw rectangle outline

proc DrawRectangleLinesEx*(rec: Rectangle; lineThick: int32; color: Color) {.cdecl,
    importc: "DrawRectangleLinesEx", dynlib: raylibdll.}
##  Draw rectangle outline with extended parameters

proc DrawRectangleRounded*(rec: Rectangle; roundness: float32; segments: int32;
                          color: Color) {.cdecl, importc: "DrawRectangleRounded",
                                        dynlib: raylibdll.}
##  Draw rectangle with rounded edges

proc DrawRectangleRoundedLines*(rec: Rectangle; roundness: float32; segments: int32;
                               lineThick: int32; color: Color) {.cdecl,
    importc: "DrawRectangleRoundedLines", dynlib: raylibdll.}
##  Draw rectangle with rounded edges outline

proc DrawTriangle*(v1: Vector2; v2: Vector2; v3: Vector2; color: Color) {.cdecl,
    importc: "DrawTriangle", dynlib: raylibdll.}
##  Draw a color-filled triangle (vertex in counter-clockwise order!)

proc DrawTriangleLines*(v1: Vector2; v2: Vector2; v3: Vector2; color: Color) {.cdecl,
    importc: "DrawTriangleLines", dynlib: raylibdll.}
##  Draw triangle outline (vertex in counter-clockwise order!)

proc DrawTriangleFan*(points: ptr Vector2; pointsCount: int32; color: Color) {.cdecl,
    importc: "DrawTriangleFan", dynlib: raylibdll.}
##  Draw a triangle fan defined by points (first vertex is the center)

proc DrawTriangleStrip*(points: ptr Vector2; pointsCount: int32; color: Color) {.cdecl,
    importc: "DrawTriangleStrip", dynlib: raylibdll.}
##  Draw a triangle strip defined by points

proc DrawPoly*(center: Vector2; sides: int32; radius: float32; rotation: float32;
              color: Color) {.cdecl, importc: "DrawPoly", dynlib: raylibdll.}
##  Draw a regular polygon (Vector version)

proc DrawPolyLines*(center: Vector2; sides: int32; radius: float32; rotation: float32;
                   color: Color) {.cdecl, importc: "DrawPolyLines", dynlib: raylibdll.}
##  Draw a polygon outline of n sides
##  Basic shapes collision detection functions

proc CheckCollisionRecs*(rec1: Rectangle; rec2: Rectangle): bool {.cdecl,
    importc: "CheckCollisionRecs", dynlib: raylibdll.}
##  Check collision between two rectangles

proc CheckCollisionCircles*(center1: Vector2; radius1: float32; center2: Vector2;
                           radius2: float32): bool {.cdecl,
    importc: "CheckCollisionCircles", dynlib: raylibdll.}
##  Check collision between two circles

proc CheckCollisionCircleRec*(center: Vector2; radius: float32; rec: Rectangle): bool {.
    cdecl, importc: "CheckCollisionCircleRec", dynlib: raylibdll.}
##  Check collision between circle and rectangle

proc CheckCollisionPointRec*(point: Vector2; rec: Rectangle): bool {.cdecl,
    importc: "CheckCollisionPointRec", dynlib: raylibdll.}
##  Check if point is inside rectangle

proc CheckCollisionPointCircle*(point: Vector2; center: Vector2; radius: float32): bool {.
    cdecl, importc: "CheckCollisionPointCircle", dynlib: raylibdll.}
##  Check if point is inside circle

proc CheckCollisionPointTriangle*(point: Vector2; p1: Vector2; p2: Vector2; p3: Vector2): bool {.
    cdecl, importc: "CheckCollisionPointTriangle", dynlib: raylibdll.}
##  Check if point is inside a triangle

proc CheckCollisionLines*(startPos1: Vector2; endPos1: Vector2; startPos2: Vector2;
                         endPos2: Vector2; collisionPoint: ptr Vector2): bool {.cdecl,
    importc: "CheckCollisionLines", dynlib: raylibdll.}
##  Check the collision between two lines defined by two points each, returns collision point by reference

proc GetCollisionRec*(rec1: Rectangle; rec2: Rectangle): Rectangle {.cdecl,
    importc: "GetCollisionRec", dynlib: raylibdll.}
##  Get collision rectangle for two rectangles collision
## ------------------------------------------------------------------------------------
##  Texture Loading and Drawing Functions (Module: textures)
## ------------------------------------------------------------------------------------
##  Image loading functions
##  NOTE: This functions do not require GPU access

proc LoadImage*(fileName: cstring): Image {.cdecl, importc: "LoadImage",
                                        dynlib: raylibdll.}
##  Load image from file into CPU memory (RAM)

proc LoadImageRaw*(fileName: cstring; width: int32; height: int32; format: int32;
                  headerSize: int32): Image {.cdecl, importc: "LoadImageRaw",
    dynlib: raylibdll.}
##  Load image from RAW file data

proc LoadImageAnim*(fileName: cstring; frames: ptr int32): Image {.cdecl,
    importc: "LoadImageAnim", dynlib: raylibdll.}
##  Load image sequence from file (frames appended to image.data)

proc LoadImageFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: int32): Image {.
    cdecl, importc: "LoadImageFromMemory", dynlib: raylibdll.}
##  Load image from memory buffer, fileType refers to extension: i.e. "png"

proc UnloadImage*(image: Image) {.cdecl, importc: "UnloadImage", dynlib: raylibdll.}
##  Unload image from CPU memory (RAM)

proc ExportImage*(image: Image; fileName: cstring): bool {.cdecl,
    importc: "ExportImage", dynlib: raylibdll.}
##  Export image data to file, returns true on success

proc ExportImageAsCode*(image: Image; fileName: cstring): bool {.cdecl,
    importc: "ExportImageAsCode", dynlib: raylibdll.}
##  Export image as code file defining an array of bytes, returns true on success
##  Image generation functions

proc GenImageColor*(width: int32; height: int32; color: Color): Image {.cdecl,
    importc: "GenImageColor", dynlib: raylibdll.}
##  Generate image: plain color

proc GenImageGradientV*(width: int32; height: int32; top: Color; bottom: Color): Image {.
    cdecl, importc: "GenImageGradientV", dynlib: raylibdll.}
##  Generate image: vertical gradient

proc GenImageGradientH*(width: int32; height: int32; left: Color; right: Color): Image {.
    cdecl, importc: "GenImageGradientH", dynlib: raylibdll.}
##  Generate image: horizontal gradient

proc GenImageGradientRadial*(width: int32; height: int32; density: float32; inner: Color;
                            outer: Color): Image {.cdecl,
    importc: "GenImageGradientRadial", dynlib: raylibdll.}
##  Generate image: radial gradient

proc GenImageChecked*(width: int32; height: int32; checksX: int32; checksY: int32;
                     col1: Color; col2: Color): Image {.cdecl,
    importc: "GenImageChecked", dynlib: raylibdll.}
##  Generate image: checked

proc GenImageWhiteNoise*(width: int32; height: int32; factor: float32): Image {.cdecl,
    importc: "GenImageWhiteNoise", dynlib: raylibdll.}
##  Generate image: white noise

proc GenImagePerlinNoise*(width: int32; height: int32; offsetX: int32; offsetY: int32;
                         scale: float32): Image {.cdecl,
    importc: "GenImagePerlinNoise", dynlib: raylibdll.}
##  Generate image: perlin noise

proc GenImageCellular*(width: int32; height: int32; tileSize: int32): Image {.cdecl,
    importc: "GenImageCellular", dynlib: raylibdll.}
##  Generate image: cellular algorithm. Bigger tileSize means bigger cells
##  Image manipulation functions

proc ImageCopy*(image: Image): Image {.cdecl, importc: "ImageCopy", dynlib: raylibdll.}
##  Create an image duplicate (useful for transformations)

proc ImageFromImage*(image: Image; rec: Rectangle): Image {.cdecl,
    importc: "ImageFromImage", dynlib: raylibdll.}
##  Create an image from another image piece

proc ImageText*(text: cstring; fontSize: int32; color: Color): Image {.cdecl,
    importc: "ImageText", dynlib: raylibdll.}
##  Create an image from text (default font)

proc ImageTextEx*(font: Font; text: cstring; fontSize: float32; spacing: float32;
                 tint: Color): Image {.cdecl, importc: "ImageTextEx",
                                    dynlib: raylibdll.}
##  Create an image from text (custom sprite font)

proc ImageFormat*(image: ptr Image; newFormat: int32) {.cdecl, importc: "ImageFormat",
    dynlib: raylibdll.}
##  Convert image data to desired format

proc ImageToPOT*(image: ptr Image; fill: Color) {.cdecl, importc: "ImageToPOT",
    dynlib: raylibdll.}
##  Convert image to POT (power-of-two)

proc ImageCrop*(image: ptr Image; crop: Rectangle) {.cdecl, importc: "ImageCrop",
    dynlib: raylibdll.}
##  Crop an image to a defined rectangle

proc ImageAlphaCrop*(image: ptr Image; threshold: float32) {.cdecl,
    importc: "ImageAlphaCrop", dynlib: raylibdll.}
##  Crop image depending on alpha value

proc ImageAlphaClear*(image: ptr Image; color: Color; threshold: float32) {.cdecl,
    importc: "ImageAlphaClear", dynlib: raylibdll.}
##  Clear alpha channel to desired color

proc ImageAlphaMask*(image: ptr Image; alphaMask: Image) {.cdecl,
    importc: "ImageAlphaMask", dynlib: raylibdll.}
##  Apply alpha mask to image

proc ImageAlphaPremultiply*(image: ptr Image) {.cdecl,
    importc: "ImageAlphaPremultiply", dynlib: raylibdll.}
##  Premultiply alpha channel

proc ImageResize*(image: ptr Image; newWidth: int32; newHeight: int32) {.cdecl,
    importc: "ImageResize", dynlib: raylibdll.}
##  Resize image (Bicubic scaling algorithm)

proc ImageResizeNN*(image: ptr Image; newWidth: int32; newHeight: int32) {.cdecl,
    importc: "ImageResizeNN", dynlib: raylibdll.}
##  Resize image (Nearest-Neighbor scaling algorithm)

proc ImageResizeCanvas*(image: ptr Image; newWidth: int32; newHeight: int32;
                       offsetX: int32; offsetY: int32; fill: Color) {.cdecl,
    importc: "ImageResizeCanvas", dynlib: raylibdll.}
##  Resize canvas and fill with color

proc ImageMipmaps*(image: ptr Image) {.cdecl, importc: "ImageMipmaps",
                                   dynlib: raylibdll.}
##  Generate all mipmap levels for a provided image

proc ImageDither*(image: ptr Image; rBpp: int32; gBpp: int32; bBpp: int32; aBpp: int32) {.cdecl,
    importc: "ImageDither", dynlib: raylibdll.}
##  Dither image data to 16bpp or lower (Floyd-Steinberg dithering)

proc ImageFlipVertical*(image: ptr Image) {.cdecl, importc: "ImageFlipVertical",
                                        dynlib: raylibdll.}
##  Flip image vertically

proc ImageFlipHorizontal*(image: ptr Image) {.cdecl, importc: "ImageFlipHorizontal",
    dynlib: raylibdll.}
##  Flip image horizontally

proc ImageRotateCW*(image: ptr Image) {.cdecl, importc: "ImageRotateCW",
                                    dynlib: raylibdll.}
##  Rotate image clockwise 90deg

proc ImageRotateCCW*(image: ptr Image) {.cdecl, importc: "ImageRotateCCW",
                                     dynlib: raylibdll.}
##  Rotate image counter-clockwise 90deg

proc ImageColorTint*(image: ptr Image; color: Color) {.cdecl,
    importc: "ImageColorTint", dynlib: raylibdll.}
##  Modify image color: tint

proc ImageColorInvert*(image: ptr Image) {.cdecl, importc: "ImageColorInvert",
                                       dynlib: raylibdll.}
##  Modify image color: invert

proc ImageColorGrayscale*(image: ptr Image) {.cdecl, importc: "ImageColorGrayscale",
    dynlib: raylibdll.}
##  Modify image color: grayscale

proc ImageColorContrast*(image: ptr Image; contrast: float32) {.cdecl,
    importc: "ImageColorContrast", dynlib: raylibdll.}
##  Modify image color: contrast (-100 to 100)

proc ImageColorBrightness*(image: ptr Image; brightness: int32) {.cdecl,
    importc: "ImageColorBrightness", dynlib: raylibdll.}
##  Modify image color: brightness (-255 to 255)

proc ImageColorReplace*(image: ptr Image; color: Color; replace: Color) {.cdecl,
    importc: "ImageColorReplace", dynlib: raylibdll.}
##  Modify image color: replace color

proc LoadImageColors*(image: Image): ptr Color {.cdecl, importc: "LoadImageColors",
    dynlib: raylibdll.}
##  Load color data from image as a Color array (RGBA - 32bit)

proc LoadImagePalette*(image: Image; maxPaletteSize: int32; colorsCount: ptr int32): ptr Color {.
    cdecl, importc: "LoadImagePalette", dynlib: raylibdll.}
##  Load colors palette from image as a Color array (RGBA - 32bit)

proc UnloadImageColors*(colors: ptr Color) {.cdecl, importc: "UnloadImageColors",
    dynlib: raylibdll.}
##  Unload color data loaded with LoadImageColors()

proc UnloadImagePalette*(colors: ptr Color) {.cdecl, importc: "UnloadImagePalette",
    dynlib: raylibdll.}
##  Unload colors palette loaded with LoadImagePalette()

proc GetImageAlphaBorder*(image: Image; threshold: float32): Rectangle {.cdecl,
    importc: "GetImageAlphaBorder", dynlib: raylibdll.}
##  Get image alpha border rectangle
##  Image drawing functions
##  NOTE: Image software-rendering functions (CPU)

proc ImageClearBackground*(dst: ptr Image; color: Color) {.cdecl,
    importc: "ImageClearBackground", dynlib: raylibdll.}
##  Clear image background with given color

proc ImageDrawPixel*(dst: ptr Image; posX: int32; posY: int32; color: Color) {.cdecl,
    importc: "ImageDrawPixel", dynlib: raylibdll.}
##  Draw pixel within an image

proc ImageDrawPixelV*(dst: ptr Image; position: Vector2; color: Color) {.cdecl,
    importc: "ImageDrawPixelV", dynlib: raylibdll.}
##  Draw pixel within an image (Vector version)

proc ImageDrawLine*(dst: ptr Image; startPosX: int32; startPosY: int32; endPosX: int32;
                   endPosY: int32; color: Color) {.cdecl, importc: "ImageDrawLine",
    dynlib: raylibdll.}
##  Draw line within an image

proc ImageDrawLineV*(dst: ptr Image; start: Vector2; `end`: Vector2; color: Color) {.
    cdecl, importc: "ImageDrawLineV", dynlib: raylibdll.}
##  Draw line within an image (Vector version)

proc ImageDrawCircle*(dst: ptr Image; centerX: int32; centerY: int32; radius: int32;
                     color: Color) {.cdecl, importc: "ImageDrawCircle",
                                   dynlib: raylibdll.}
##  Draw circle within an image

proc ImageDrawCircleV*(dst: ptr Image; center: Vector2; radius: int32; color: Color) {.
    cdecl, importc: "ImageDrawCircleV", dynlib: raylibdll.}
##  Draw circle within an image (Vector version)

proc ImageDrawRectangle*(dst: ptr Image; posX: int32; posY: int32; width: int32;
                        height: int32; color: Color) {.cdecl,
    importc: "ImageDrawRectangle", dynlib: raylibdll.}
##  Draw rectangle within an image

proc ImageDrawRectangleV*(dst: ptr Image; position: Vector2; size: Vector2; color: Color) {.
    cdecl, importc: "ImageDrawRectangleV", dynlib: raylibdll.}
##  Draw rectangle within an image (Vector version)

proc ImageDrawRectangleRec*(dst: ptr Image; rec: Rectangle; color: Color) {.cdecl,
    importc: "ImageDrawRectangleRec", dynlib: raylibdll.}
##  Draw rectangle within an image

proc ImageDrawRectangleLines*(dst: ptr Image; rec: Rectangle; thick: int32; color: Color) {.
    cdecl, importc: "ImageDrawRectangleLines", dynlib: raylibdll.}
##  Draw rectangle lines within an image

proc ImageDraw*(dst: ptr Image; src: Image; srcRec: Rectangle; dstRec: Rectangle;
               tint: Color) {.cdecl, importc: "ImageDraw", dynlib: raylibdll.}
##  Draw a source image within a destination image (tint applied to source)

proc ImageDrawText*(dst: ptr Image; text: cstring; posX: int32; posY: int32; fontSize: int32;
                   color: Color) {.cdecl, importc: "ImageDrawText", dynlib: raylibdll.}
##  Draw text (using default font) within an image (destination)

proc ImageDrawTextEx*(dst: ptr Image; font: Font; text: cstring; position: Vector2;
                     fontSize: float32; spacing: float32; tint: Color) {.cdecl,
    importc: "ImageDrawTextEx", dynlib: raylibdll.}
##  Draw text (custom sprite font) within an image (destination)
##  Texture loading functions
##  NOTE: These functions require GPU access

proc LoadTexture*(fileName: cstring): Texture2D {.cdecl, importc: "LoadTexture",
    dynlib: raylibdll.}
##  Load texture from file into GPU memory (VRAM)

proc LoadTextureFromImage*(image: Image): Texture2D {.cdecl,
    importc: "LoadTextureFromImage", dynlib: raylibdll.}
##  Load texture from image data

proc LoadTextureCubemap*(image: Image; layoutType: int32): TextureCubemap {.cdecl,
    importc: "LoadTextureCubemap", dynlib: raylibdll.}
##  Load cubemap from image, multiple image cubemap layouts supported

proc LoadRenderTexture*(width: int32; height: int32): RenderTexture2D {.cdecl,
    importc: "LoadRenderTexture", dynlib: raylibdll.}
##  Load texture for rendering (framebuffer)

proc UnloadTexture*(texture: Texture2D) {.cdecl, importc: "UnloadTexture",
                                       dynlib: raylibdll.}
##  Unload texture from GPU memory (VRAM)

proc UnloadRenderTexture*(target: RenderTexture2D) {.cdecl,
    importc: "UnloadRenderTexture", dynlib: raylibdll.}
##  Unload render texture from GPU memory (VRAM)

proc UpdateTexture*(texture: Texture2D; pixels: pointer) {.cdecl,
    importc: "UpdateTexture", dynlib: raylibdll.}
##  Update GPU texture with new data

proc UpdateTextureRec*(texture: Texture2D; rec: Rectangle; pixels: pointer) {.cdecl,
    importc: "UpdateTextureRec", dynlib: raylibdll.}
##  Update GPU texture rectangle with new data

proc GetTextureData*(texture: Texture2D): Image {.cdecl, importc: "GetTextureData",
    dynlib: raylibdll.}
##  Get pixel data from GPU texture and return an Image

proc GetScreenData*(): Image {.cdecl, importc: "GetScreenData", dynlib: raylibdll.}
##  Get pixel data from screen buffer and return an Image (screenshot)
##  Texture configuration functions

proc GenTextureMipmaps*(texture: ptr Texture2D) {.cdecl,
    importc: "GenTextureMipmaps", dynlib: raylibdll.}
##  Generate GPU mipmaps for a texture

proc SetTextureFilter*(texture: Texture2D; filterMode: int32) {.cdecl,
    importc: "SetTextureFilter", dynlib: raylibdll.}
##  Set texture scaling filter mode

proc SetTextureWrap*(texture: Texture2D; wrapMode: int32) {.cdecl,
    importc: "SetTextureWrap", dynlib: raylibdll.}
##  Set texture wrapping mode
##  Texture drawing functions

proc DrawTexture*(texture: Texture2D; posX: int32; posY: int32; tint: Color) {.cdecl,
    importc: "DrawTexture", dynlib: raylibdll.}
##  Draw a Texture2D

proc DrawTextureV*(texture: Texture2D; position: Vector2; tint: Color) {.cdecl,
    importc: "DrawTextureV", dynlib: raylibdll.}
##  Draw a Texture2D with position defined as Vector2

proc DrawTextureEx*(texture: Texture2D; position: Vector2; rotation: float32;
                   scale: float32; tint: Color) {.cdecl, importc: "DrawTextureEx",
    dynlib: raylibdll.}
##  Draw a Texture2D with extended parameters

proc DrawTextureRec*(texture: Texture2D; source: Rectangle; position: Vector2;
                    tint: Color) {.cdecl, importc: "DrawTextureRec",
                                 dynlib: raylibdll.}
##  Draw a part of a texture defined by a rectangle

proc DrawTextureQuad*(texture: Texture2D; tiling: Vector2; offset: Vector2;
                     quad: Rectangle; tint: Color) {.cdecl,
    importc: "DrawTextureQuad", dynlib: raylibdll.}
##  Draw texture quad with tiling and offset parameters

proc DrawTextureTiled*(texture: Texture2D; source: Rectangle; dest: Rectangle;
                      origin: Vector2; rotation: float32; scale: float32; tint: Color) {.
    cdecl, importc: "DrawTextureTiled", dynlib: raylibdll.}
##  Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.

proc DrawTexturePro*(texture: Texture2D; source: Rectangle; dest: Rectangle;
                    origin: Vector2; rotation: float32; tint: Color) {.cdecl,
    importc: "DrawTexturePro", dynlib: raylibdll.}
##  Draw a part of a texture defined by a rectangle with 'pro' parameters

proc DrawTextureNPatch*(texture: Texture2D; nPatchInfo: NPatchInfo; dest: Rectangle;
                       origin: Vector2; rotation: float32; tint: Color) {.cdecl,
    importc: "DrawTextureNPatch", dynlib: raylibdll.}
##  Draws a texture (or part of it) that stretches or shrinks nicely
##  Color/pixel related functions

proc Fade*(color: Color; alpha: float32): Color {.cdecl, importc: "Fade",
    dynlib: raylibdll.}
##  Returns color with alpha applied, alpha goes from 0.0f to 1.0f

proc ColorToInt*(color: Color): int32 {.cdecl, importc: "ColorToInt", dynlib: raylibdll.}
##  Returns hexadecimal value for a Color

proc ColorNormalize*(color: Color): Vector4 {.cdecl, importc: "ColorNormalize",
    dynlib: raylibdll.}
##  Returns Color normalized as float [0..1]

proc ColorFromNormalized*(normalized: Vector4): Color {.cdecl,
    importc: "ColorFromNormalized", dynlib: raylibdll.}
##  Returns Color from normalized values [0..1]

proc ColorToHSV*(color: Color): Vector3 {.cdecl, importc: "ColorToHSV",
                                      dynlib: raylibdll.}
##  Returns HSV values for a Color

proc ColorFromHSV*(hue: float32; saturation: float32; value: float32): Color {.cdecl,
    importc: "ColorFromHSV", dynlib: raylibdll.}
##  Returns a Color from HSV values

proc ColorAlpha*(color: Color; alpha: float32): Color {.cdecl, importc: "ColorAlpha",
    dynlib: raylibdll.}
##  Returns color with alpha applied, alpha goes from 0.0f to 1.0f

proc ColorAlphaBlend*(dst: Color; src: Color; tint: Color): Color {.cdecl,
    importc: "ColorAlphaBlend", dynlib: raylibdll.}
##  Returns src alpha-blended into dst color with tint

proc GetColor*(hexValue: int32): Color {.cdecl, importc: "GetColor", dynlib: raylibdll.}
##  Get Color structure from hexadecimal value

proc GetPixelColor*(srcPtr: pointer; format: int32): Color {.cdecl,
    importc: "GetPixelColor", dynlib: raylibdll.}
##  Get Color from a source pixel pointer of certain format

proc SetPixelColor*(dstPtr: pointer; color: Color; format: int32) {.cdecl,
    importc: "SetPixelColor", dynlib: raylibdll.}
##  Set color formatted into destination pixel pointer

proc GetPixelDataSize*(width: int32; height: int32; format: int32): int32 {.cdecl,
    importc: "GetPixelDataSize", dynlib: raylibdll.}
##  Get pixel data size in bytes for certain format
## ------------------------------------------------------------------------------------
##  Font Loading and Text Drawing Functions (Module: text)
## ------------------------------------------------------------------------------------
##  Font loading/unloading functions

proc GetFontDefault*(): Font {.cdecl, importc: "GetFontDefault", dynlib: raylibdll.}
##  Get the default Font

proc LoadFont*(fileName: cstring): Font {.cdecl, importc: "LoadFont", dynlib: raylibdll.}
##  Load font from file into GPU memory (VRAM)

proc LoadFontEx*(fileName: cstring; fontSize: int32; fontChars: ptr int32;
                charsCount: int32): Font {.cdecl, importc: "LoadFontEx",
                                       dynlib: raylibdll.}
##  Load font from file with extended parameters

proc LoadFontFromImage*(image: Image; key: Color; firstChar: int32): Font {.cdecl,
    importc: "LoadFontFromImage", dynlib: raylibdll.}
##  Load font from Image (XNA style)

proc LoadFontFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: int32;
                        fontSize: int32; fontChars: ptr int32; charsCount: int32): Font {.
    cdecl, importc: "LoadFontFromMemory", dynlib: raylibdll.}
##  Load font from memory buffer, fileType refers to extension: i.e. "ttf"

proc LoadFontData*(fileData: ptr uint8; dataSize: int32; fontSize: int32;
                  fontChars: ptr int32; charsCount: int32; `type`: int32): ptr CharInfo {.
    cdecl, importc: "LoadFontData", dynlib: raylibdll.}
##  Load font data for further use

proc GenImageFontAtlas*(chars: ptr CharInfo; recs: ptr ptr Rectangle; charsCount: int32;
                       fontSize: int32; padding: int32; packMethod: int32): Image {.cdecl,
    importc: "GenImageFontAtlas", dynlib: raylibdll.}
##  Generate image font atlas using chars info

proc UnloadFontData*(chars: ptr CharInfo; charsCount: int32) {.cdecl,
    importc: "UnloadFontData", dynlib: raylibdll.}
##  Unload font chars info data (RAM)

proc UnloadFont*(font: Font) {.cdecl, importc: "UnloadFont", dynlib: raylibdll.}
##  Unload Font from GPU memory (VRAM)
##  Text drawing functions

proc DrawFPS*(posX: int32; posY: int32) {.cdecl, importc: "DrawFPS", dynlib: raylibdll.}
##  Shows current FPS

proc DrawText*(text: cstring; posX: int32; posY: int32; fontSize: int32; color: Color) {.
    cdecl, importc: "DrawText", dynlib: raylibdll.}
##  Draw text (using default font)

proc DrawTextEx*(font: Font; text: cstring; position: Vector2; fontSize: float32;
                spacing: float32; tint: Color) {.cdecl, importc: "DrawTextEx",
    dynlib: raylibdll.}
##  Draw text using font and additional parameters

proc DrawTextRec*(font: Font; text: cstring; rec: Rectangle; fontSize: float32;
                 spacing: float32; wordWrap: bool; tint: Color) {.cdecl,
    importc: "DrawTextRec", dynlib: raylibdll.}
##  Draw text using font inside rectangle limits

proc DrawTextRecEx*(font: Font; text: cstring; rec: Rectangle; fontSize: float32;
                   spacing: float32; wordWrap: bool; tint: Color; selectStart: int32;
                   selectLength: int32; selectTint: Color; selectBackTint: Color) {.
    cdecl, importc: "DrawTextRecEx", dynlib: raylibdll.}
##  Draw text using font inside rectangle limits with support for text selection

proc DrawTextCodepoint*(font: Font; codepoint: int32; position: Vector2;
                       fontSize: float32; tint: Color) {.cdecl,
    importc: "DrawTextCodepoint", dynlib: raylibdll.}
##  Draw one character (codepoint)
##  Text misc. functions

proc MeasureText*(text: cstring; fontSize: int32): int32 {.cdecl, importc: "MeasureText",
    dynlib: raylibdll.}
##  Measure string width for default font

proc MeasureTextEx*(font: Font; text: cstring; fontSize: float32; spacing: float32): Vector2 {.
    cdecl, importc: "MeasureTextEx", dynlib: raylibdll.}
##  Measure string size for Font

proc GetGlyphIndex*(font: Font; codepoint: int32): int32 {.cdecl,
    importc: "GetGlyphIndex", dynlib: raylibdll.}
##  Get index position for a unicode character on font
##  Text strings management functions (no utf8 strings, only byte chars)
##  NOTE: Some strings allocate memory internally for returned strings, just be careful!

proc TextCopy*(dst: cstring; src: cstring): int32 {.cdecl, importc: "TextCopy",
    dynlib: raylibdll.}
##  Copy one string to another, returns bytes copied

proc TextIsEqual*(text1: cstring; text2: cstring): bool {.cdecl,
    importc: "TextIsEqual", dynlib: raylibdll.}
##  Check if two text string are equal

proc TextLength*(text: cstring): uint32 {.cdecl, importc: "TextLength",
                                     dynlib: raylibdll.}
##  Get text length, checks for '\0' ending

proc TextFormat*(text: cstring): cstring {.varargs, cdecl, importc: "TextFormat",
                                       dynlib: raylibdll.}
##  Text formatting with variables (sprintf style)

proc TextSubtext*(text: cstring; position: int32; length: int32): cstring {.cdecl,
    importc: "TextSubtext", dynlib: raylibdll.}
##  Get a piece of a text string

proc TextReplace*(text: cstring; replace: cstring; by: cstring): cstring {.cdecl,
    importc: "TextReplace", dynlib: raylibdll.}
##  Replace text string (memory must be freed!)

proc TextInsert*(text: cstring; insert: cstring; position: int32): cstring {.cdecl,
    importc: "TextInsert", dynlib: raylibdll.}
##  Insert text in a position (memory must be freed!)

proc TextJoin*(textList: cstringArray; count: int32; delimiter: cstring): cstring {.
    cdecl, importc: "TextJoin", dynlib: raylibdll.}
##  Join text strings with delimiter

proc TextSplit*(text: cstring; delimiter: char; count: ptr int32): cstringArray {.cdecl,
    importc: "TextSplit", dynlib: raylibdll.}
##  Split text into multiple strings

proc TextAppend*(text: cstring; append: cstring; position: ptr int32) {.cdecl,
    importc: "TextAppend", dynlib: raylibdll.}
##  Append text at specific position and move cursor!

proc TextFindIndex*(text: cstring; find: cstring): int32 {.cdecl,
    importc: "TextFindIndex", dynlib: raylibdll.}
##  Find first text occurrence within a string

proc TextToUpper*(text: cstring): cstring {.cdecl, importc: "TextToUpper",
                                        dynlib: raylibdll.}
##  Get upper case version of provided string

proc TextToLower*(text: cstring): cstring {.cdecl, importc: "TextToLower",
                                        dynlib: raylibdll.}
##  Get lower case version of provided string

proc TextToPascal*(text: cstring): cstring {.cdecl, importc: "TextToPascal",
    dynlib: raylibdll.}
##  Get Pascal case notation version of provided string

proc TextToInteger*(text: cstring): int32 {.cdecl, importc: "TextToInteger",
                                       dynlib: raylibdll.}
##  Get integer value from text (negative values not supported)

proc TextToUtf8*(codepoints: ptr int32; length: int32): cstring {.cdecl,
    importc: "TextToUtf8", dynlib: raylibdll.}
##  Encode text codepoint into utf8 text (memory must be freed!)
##  UTF8 text strings management functions

proc GetCodepoints*(text: cstring; count: ptr int32): ptr int32 {.cdecl,
    importc: "GetCodepoints", dynlib: raylibdll.}
##  Get all codepoints in a string, codepoints count returned by parameters

proc GetCodepointsCount*(text: cstring): int32 {.cdecl, importc: "GetCodepointsCount",
    dynlib: raylibdll.}
##  Get total number of characters (codepoints) in a UTF8 encoded string

proc GetNextCodepoint*(text: cstring; bytesProcessed: ptr int32): int32 {.cdecl,
    importc: "GetNextCodepoint", dynlib: raylibdll.}
##  Returns next codepoint in a UTF8 encoded string; 0x3f('?') is returned on failure

proc CodepointToUtf8*(codepoint: int32; byteLength: ptr int32): cstring {.cdecl,
    importc: "CodepointToUtf8", dynlib: raylibdll.}
##  Encode codepoint into utf8 text (char array length returned as parameter)
## ------------------------------------------------------------------------------------
##  Basic 3d Shapes Drawing Functions (Module: models)
## ------------------------------------------------------------------------------------
##  Basic geometric 3D shapes drawing functions

proc DrawLine3D*(startPos: Vector3; endPos: Vector3; color: Color) {.cdecl,
    importc: "DrawLine3D", dynlib: raylibdll.}
##  Draw a line in 3D world space

proc DrawPoint3D*(position: Vector3; color: Color) {.cdecl, importc: "DrawPoint3D",
    dynlib: raylibdll.}
##  Draw a point in 3D space, actually a small line

proc DrawCircle3D*(center: Vector3; radius: float32; rotationAxis: Vector3;
                  rotationAngle: float32; color: Color) {.cdecl,
    importc: "DrawCircle3D", dynlib: raylibdll.}
##  Draw a circle in 3D world space

proc DrawTriangle3D*(v1: Vector3; v2: Vector3; v3: Vector3; color: Color) {.cdecl,
    importc: "DrawTriangle3D", dynlib: raylibdll.}
##  Draw a color-filled triangle (vertex in counter-clockwise order!)

proc DrawTriangleStrip3D*(points: ptr Vector3; pointsCount: int32; color: Color) {.cdecl,
    importc: "DrawTriangleStrip3D", dynlib: raylibdll.}
##  Draw a triangle strip defined by points

proc DrawCube*(position: Vector3; width: float32; height: float32; length: float32;
              color: Color) {.cdecl, importc: "DrawCube", dynlib: raylibdll.}
##  Draw cube

proc DrawCubeV*(position: Vector3; size: Vector3; color: Color) {.cdecl,
    importc: "DrawCubeV", dynlib: raylibdll.}
##  Draw cube (Vector version)

proc DrawCubeWires*(position: Vector3; width: float32; height: float32; length: float32;
                   color: Color) {.cdecl, importc: "DrawCubeWires", dynlib: raylibdll.}
##  Draw cube wires

proc DrawCubeWiresV*(position: Vector3; size: Vector3; color: Color) {.cdecl,
    importc: "DrawCubeWiresV", dynlib: raylibdll.}
##  Draw cube wires (Vector version)

proc DrawCubeTexture*(texture: Texture2D; position: Vector3; width: float32;
                     height: float32; length: float32; color: Color) {.cdecl,
    importc: "DrawCubeTexture", dynlib: raylibdll.}
##  Draw cube textured

proc DrawSphere*(centerPos: Vector3; radius: float32; color: Color) {.cdecl,
    importc: "DrawSphere", dynlib: raylibdll.}
##  Draw sphere

proc DrawSphereEx*(centerPos: Vector3; radius: float32; rings: int32; slices: int32;
                  color: Color) {.cdecl, importc: "DrawSphereEx", dynlib: raylibdll.}
##  Draw sphere with extended parameters

proc DrawSphereWires*(centerPos: Vector3; radius: float32; rings: int32; slices: int32;
                     color: Color) {.cdecl, importc: "DrawSphereWires",
                                   dynlib: raylibdll.}
##  Draw sphere wires

proc DrawCylinder*(position: Vector3; radiusTop: float32; radiusBottom: float32;
                  height: float32; slices: int32; color: Color) {.cdecl,
    importc: "DrawCylinder", dynlib: raylibdll.}
##  Draw a cylinder/cone

proc DrawCylinderWires*(position: Vector3; radiusTop: float32; radiusBottom: float32;
                       height: float32; slices: int32; color: Color) {.cdecl,
    importc: "DrawCylinderWires", dynlib: raylibdll.}
##  Draw a cylinder/cone wires

proc DrawPlane*(centerPos: Vector3; size: Vector2; color: Color) {.cdecl,
    importc: "DrawPlane", dynlib: raylibdll.}
##  Draw a plane XZ

proc DrawRay*(ray: Ray; color: Color) {.cdecl, importc: "DrawRay", dynlib: raylibdll.}
##  Draw a ray line

proc DrawGrid*(slices: int32; spacing: float32) {.cdecl, importc: "DrawGrid",
    dynlib: raylibdll.}
##  Draw a grid (centered at (0, 0, 0))

proc DrawGizmo*(position: Vector3) {.cdecl, importc: "DrawGizmo", dynlib: raylibdll.}
##  Draw simple gizmo
## ------------------------------------------------------------------------------------
##  Model 3d Loading and Drawing Functions (Module: models)
## ------------------------------------------------------------------------------------
##  Model loading/unloading functions

proc LoadModel*(fileName: cstring): Model {.cdecl, importc: "LoadModel",
                                        dynlib: raylibdll.}
##  Load model from files (meshes and materials)

proc LoadModelFromMesh*(mesh: Mesh): Model {.cdecl, importc: "LoadModelFromMesh",
    dynlib: raylibdll.}
##  Load model from generated mesh (default material)

proc UnloadModel*(model: Model) {.cdecl, importc: "UnloadModel", dynlib: raylibdll.}
##  Unload model (including meshes) from memory (RAM and/or VRAM)

proc UnloadModelKeepMeshes*(model: Model) {.cdecl, importc: "UnloadModelKeepMeshes",
    dynlib: raylibdll.}
##  Unload model (but not meshes) from memory (RAM and/or VRAM)
##  Mesh loading/unloading functions

proc LoadMeshes*(fileName: cstring; meshCount: ptr int32): ptr Mesh {.cdecl,
    importc: "LoadMeshes", dynlib: raylibdll.}
##  Load meshes from model file

proc UnloadMesh*(mesh: Mesh) {.cdecl, importc: "UnloadMesh", dynlib: raylibdll.}
##  Unload mesh from memory (RAM and/or VRAM)

proc ExportMesh*(mesh: Mesh; fileName: cstring): bool {.cdecl, importc: "ExportMesh",
    dynlib: raylibdll.}
##  Export mesh data to file, returns true on success
##  Material loading/unloading functions

proc LoadMaterials*(fileName: cstring; materialCount: ptr int32): ptr Material {.cdecl,
    importc: "LoadMaterials", dynlib: raylibdll.}
##  Load materials from model file

proc LoadMaterialDefault*(): Material {.cdecl, importc: "LoadMaterialDefault",
                                     dynlib: raylibdll.}
##  Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)

proc UnloadMaterial*(material: Material) {.cdecl, importc: "UnloadMaterial",
                                        dynlib: raylibdll.}
##  Unload material from GPU memory (VRAM)

proc SetMaterialTexture*(material: ptr Material; mapType: int32; texture: Texture2D) {.
    cdecl, importc: "SetMaterialTexture", dynlib: raylibdll.}
##  Set texture for a material map type (MAP_DIFFUSE, MAP_SPECULAR...)

proc SetModelMeshMaterial*(model: ptr Model; meshId: int32; materialId: int32) {.cdecl,
    importc: "SetModelMeshMaterial", dynlib: raylibdll.}
##  Set material for a mesh
##  Model animations loading/unloading functions

proc LoadModelAnimations*(fileName: cstring; animsCount: ptr int32): ptr ModelAnimation {.
    cdecl, importc: "LoadModelAnimations", dynlib: raylibdll.}
##  Load model animations from file

proc UpdateModelAnimation*(model: Model; anim: ModelAnimation; frame: int32) {.cdecl,
    importc: "UpdateModelAnimation", dynlib: raylibdll.}
##  Update model animation pose

proc UnloadModelAnimation*(anim: ModelAnimation) {.cdecl,
    importc: "UnloadModelAnimation", dynlib: raylibdll.}
##  Unload animation data

proc IsModelAnimationValid*(model: Model; anim: ModelAnimation): bool {.cdecl,
    importc: "IsModelAnimationValid", dynlib: raylibdll.}
##  Check model animation skeleton match
##  Mesh generation functions

proc GenMeshPoly*(sides: int32; radius: float32): Mesh {.cdecl, importc: "GenMeshPoly",
    dynlib: raylibdll.}
##  Generate polygonal mesh

proc GenMeshPlane*(width: float32; length: float32; resX: int32; resZ: int32): Mesh {.cdecl,
    importc: "GenMeshPlane", dynlib: raylibdll.}
##  Generate plane mesh (with subdivisions)

proc GenMeshCube*(width: float32; height: float32; length: float32): Mesh {.cdecl,
    importc: "GenMeshCube", dynlib: raylibdll.}
##  Generate cuboid mesh

proc GenMeshSphere*(radius: float32; rings: int32; slices: int32): Mesh {.cdecl,
    importc: "GenMeshSphere", dynlib: raylibdll.}
##  Generate sphere mesh (standard sphere)

proc GenMeshHemiSphere*(radius: float32; rings: int32; slices: int32): Mesh {.cdecl,
    importc: "GenMeshHemiSphere", dynlib: raylibdll.}
##  Generate half-sphere mesh (no bottom cap)

proc GenMeshCylinder*(radius: float32; height: float32; slices: int32): Mesh {.cdecl,
    importc: "GenMeshCylinder", dynlib: raylibdll.}
##  Generate cylinder mesh

proc GenMeshTorus*(radius: float32; size: float32; radSeg: int32; sides: int32): Mesh {.cdecl,
    importc: "GenMeshTorus", dynlib: raylibdll.}
##  Generate torus mesh

proc GenMeshKnot*(radius: float32; size: float32; radSeg: int32; sides: int32): Mesh {.cdecl,
    importc: "GenMeshKnot", dynlib: raylibdll.}
##  Generate trefoil knot mesh

proc GenMeshHeightmap*(heightmap: Image; size: Vector3): Mesh {.cdecl,
    importc: "GenMeshHeightmap", dynlib: raylibdll.}
##  Generate heightmap mesh from image data

proc GenMeshCubicmap*(cubicmap: Image; cubeSize: Vector3): Mesh {.cdecl,
    importc: "GenMeshCubicmap", dynlib: raylibdll.}
##  Generate cubes-based map mesh from image data
##  Mesh manipulation functions

proc MeshBoundingBox*(mesh: Mesh): BoundingBox {.cdecl, importc: "MeshBoundingBox",
    dynlib: raylibdll.}
##  Compute mesh bounding box limits

proc MeshTangents*(mesh: ptr Mesh) {.cdecl, importc: "MeshTangents", dynlib: raylibdll.}
##  Compute mesh tangents

proc MeshBinormals*(mesh: ptr Mesh) {.cdecl, importc: "MeshBinormals",
                                  dynlib: raylibdll.}
##  Compute mesh binormals

proc MeshNormalsSmooth*(mesh: ptr Mesh) {.cdecl, importc: "MeshNormalsSmooth",
                                      dynlib: raylibdll.}
##  Smooth (average) vertex normals
##  Model drawing functions

proc DrawModel*(model: Model; position: Vector3; scale: float32; tint: Color) {.cdecl,
    importc: "DrawModel", dynlib: raylibdll.}
##  Draw a model (with texture if set)

proc DrawModelEx*(model: Model; position: Vector3; rotationAxis: Vector3;
                 rotationAngle: float32; scale: Vector3; tint: Color) {.cdecl,
    importc: "DrawModelEx", dynlib: raylibdll.}
##  Draw a model with extended parameters

proc DrawModelWires*(model: Model; position: Vector3; scale: float32; tint: Color) {.
    cdecl, importc: "DrawModelWires", dynlib: raylibdll.}
##  Draw a model wires (with texture if set)

proc DrawModelWiresEx*(model: Model; position: Vector3; rotationAxis: Vector3;
                      rotationAngle: float32; scale: Vector3; tint: Color) {.cdecl,
    importc: "DrawModelWiresEx", dynlib: raylibdll.}
##  Draw a model wires (with texture if set) with extended parameters

proc DrawBoundingBox*(box: BoundingBox; color: Color) {.cdecl,
    importc: "DrawBoundingBox", dynlib: raylibdll.}
##  Draw bounding box (wires)

proc DrawBillboard*(camera: Camera; texture: Texture2D; center: Vector3; size: float32;
                   tint: Color) {.cdecl, importc: "DrawBillboard", dynlib: raylibdll.}
##  Draw a billboard texture

proc DrawBillboardRec*(camera: Camera; texture: Texture2D; source: Rectangle;
                      center: Vector3; size: float32; tint: Color) {.cdecl,
    importc: "DrawBillboardRec", dynlib: raylibdll.}
##  Draw a billboard texture defined by source
##  Collision detection functions

proc CheckCollisionSpheres*(center1: Vector3; radius1: float32; center2: Vector3;
                           radius2: float32): bool {.cdecl,
    importc: "CheckCollisionSpheres", dynlib: raylibdll.}
##  Detect collision between two spheres

proc CheckCollisionBoxes*(box1: BoundingBox; box2: BoundingBox): bool {.cdecl,
    importc: "CheckCollisionBoxes", dynlib: raylibdll.}
##  Detect collision between two bounding boxes

proc CheckCollisionBoxSphere*(box: BoundingBox; center: Vector3; radius: float32): bool {.
    cdecl, importc: "CheckCollisionBoxSphere", dynlib: raylibdll.}
##  Detect collision between box and sphere

proc CheckCollisionRaySphere*(ray: Ray; center: Vector3; radius: float32): bool {.cdecl,
    importc: "CheckCollisionRaySphere", dynlib: raylibdll.}
##  Detect collision between ray and sphere

proc CheckCollisionRaySphereEx*(ray: Ray; center: Vector3; radius: float32;
                               collisionPoint: ptr Vector3): bool {.cdecl,
    importc: "CheckCollisionRaySphereEx", dynlib: raylibdll.}
##  Detect collision between ray and sphere, returns collision point

proc CheckCollisionRayBox*(ray: Ray; box: BoundingBox): bool {.cdecl,
    importc: "CheckCollisionRayBox", dynlib: raylibdll.}
##  Detect collision between ray and box

proc GetCollisionRayMesh*(ray: Ray; mesh: Mesh; transform: Matrix): RayHitInfo {.cdecl,
    importc: "GetCollisionRayMesh", dynlib: raylibdll.}
##  Get collision info between ray and mesh

proc GetCollisionRayModel*(ray: Ray; model: Model): RayHitInfo {.cdecl,
    importc: "GetCollisionRayModel", dynlib: raylibdll.}
##  Get collision info between ray and model

proc GetCollisionRayTriangle*(ray: Ray; p1: Vector3; p2: Vector3; p3: Vector3): RayHitInfo {.
    cdecl, importc: "GetCollisionRayTriangle", dynlib: raylibdll.}
##  Get collision info between ray and triangle

proc GetCollisionRayGround*(ray: Ray; groundHeight: float32): RayHitInfo {.cdecl,
    importc: "GetCollisionRayGround", dynlib: raylibdll.}
##  Get collision info between ray and ground plane (Y-normal plane)
## ------------------------------------------------------------------------------------
##  Shaders System Functions (Module: rlgl)
##  NOTE: This functions are useless when using OpenGL 1.1
## ------------------------------------------------------------------------------------
##  Shader loading/unloading functions

proc LoadShader*(vsFileName: cstring; fsFileName: cstring): Shader {.cdecl,
    importc: "LoadShader", dynlib: raylibdll.}
##  Load shader from files and bind default locations

proc LoadShaderCode*(vsCode: cstring; fsCode: cstring): Shader {.cdecl,
    importc: "LoadShaderCode", dynlib: raylibdll.}
##  Load shader from code strings and bind default locations

proc UnloadShader*(shader: Shader) {.cdecl, importc: "UnloadShader", dynlib: raylibdll.}
##  Unload shader from GPU memory (VRAM)

proc GetShaderDefault*(): Shader {.cdecl, importc: "GetShaderDefault",
                                dynlib: raylibdll.}
##  Get default shader

proc GetTextureDefault*(): Texture2D {.cdecl, importc: "GetTextureDefault",
                                    dynlib: raylibdll.}
##  Get default texture

proc GetShapesTexture*(): Texture2D {.cdecl, importc: "GetShapesTexture",
                                   dynlib: raylibdll.}
##  Get texture to draw shapes

proc GetShapesTextureRec*(): Rectangle {.cdecl, importc: "GetShapesTextureRec",
                                      dynlib: raylibdll.}
##  Get texture rectangle to draw shapes

proc SetShapesTexture*(texture: Texture2D; source: Rectangle) {.cdecl,
    importc: "SetShapesTexture", dynlib: raylibdll.}
##  Define default texture used to draw shapes
##  Shader configuration functions

proc GetShaderLocation*(shader: Shader; uniformName: cstring): int32 {.cdecl,
    importc: "GetShaderLocation", dynlib: raylibdll.}
##  Get shader uniform location

proc GetShaderLocationAttrib*(shader: Shader; attribName: cstring): int32 {.cdecl,
    importc: "GetShaderLocationAttrib", dynlib: raylibdll.}
##  Get shader attribute location

proc SetShaderValue*(shader: Shader; uniformLoc: int32; value: pointer;
                    uniformType: int32) {.cdecl, importc: "SetShaderValue",
                                       dynlib: raylibdll.}
##  Set shader uniform value

proc SetShaderValueV*(shader: Shader; uniformLoc: int32; value: pointer;
                     uniformType: int32; count: int32) {.cdecl,
    importc: "SetShaderValueV", dynlib: raylibdll.}
##  Set shader uniform value vector

proc SetShaderValueMatrix*(shader: Shader; uniformLoc: int32; mat: Matrix) {.cdecl,
    importc: "SetShaderValueMatrix", dynlib: raylibdll.}
##  Set shader uniform value (matrix 4x4)

proc SetShaderValueTexture*(shader: Shader; uniformLoc: int32; texture: Texture2D) {.
    cdecl, importc: "SetShaderValueTexture", dynlib: raylibdll.}
##  Set shader uniform value for texture

proc SetMatrixProjection*(proj: Matrix) {.cdecl, importc: "SetMatrixProjection",
                                       dynlib: raylibdll.}
##  Set a custom projection matrix (replaces internal projection matrix)

proc SetMatrixModelview*(view: Matrix) {.cdecl, importc: "SetMatrixModelview",
                                      dynlib: raylibdll.}
##  Set a custom modelview matrix (replaces internal modelview matrix)

proc GetMatrixModelview*(): Matrix {.cdecl, importc: "GetMatrixModelview",
                                  dynlib: raylibdll.}
##  Get internal modelview matrix

proc GetMatrixProjection*(): Matrix {.cdecl, importc: "GetMatrixProjection",
                                   dynlib: raylibdll.}
##  Get internal projection matrix
##  Texture maps generation (PBR)
##  NOTE: Required shaders should be provided

proc GenTextureCubemap*(shader: Shader; panorama: Texture2D; size: int32; format: int32): TextureCubemap {.
    cdecl, importc: "GenTextureCubemap", dynlib: raylibdll.}
##  Generate cubemap texture from 2D panorama texture

proc GenTextureIrradiance*(shader: Shader; cubemap: TextureCubemap; size: int32): TextureCubemap {.
    cdecl, importc: "GenTextureIrradiance", dynlib: raylibdll.}
##  Generate irradiance texture using cubemap data

proc GenTexturePrefilter*(shader: Shader; cubemap: TextureCubemap; size: int32): TextureCubemap {.
    cdecl, importc: "GenTexturePrefilter", dynlib: raylibdll.}
##  Generate prefilter texture using cubemap data

proc GenTextureBRDF*(shader: Shader; size: int32): Texture2D {.cdecl,
    importc: "GenTextureBRDF", dynlib: raylibdll.}
##  Generate BRDF texture
##  Shading begin/end functions

proc BeginShaderMode*(shader: Shader) {.cdecl, importc: "BeginShaderMode",
                                     dynlib: raylibdll.}
##  Begin custom shader drawing

proc EndShaderMode*() {.cdecl, importc: "EndShaderMode", dynlib: raylibdll.}
##  End custom shader drawing (use default shader)

proc BeginBlendMode*(mode: int32) {.cdecl, importc: "BeginBlendMode", dynlib: raylibdll.}
##  Begin blending mode (alpha, additive, multiplied)

proc EndBlendMode*() {.cdecl, importc: "EndBlendMode", dynlib: raylibdll.}
##  End blending mode (reset to default: alpha blending)
##  VR control functions

proc InitVrSimulator*() {.cdecl, importc: "InitVrSimulator", dynlib: raylibdll.}
##  Init VR simulator for selected device parameters

proc CloseVrSimulator*() {.cdecl, importc: "CloseVrSimulator", dynlib: raylibdll.}
##  Close VR simulator for current device

proc UpdateVrTracking*(camera: ptr Camera) {.cdecl, importc: "UpdateVrTracking",
    dynlib: raylibdll.}
##  Update VR tracking (position and orientation) and camera

proc SetVrConfiguration*(info: VrDeviceInfo; distortion: Shader) {.cdecl,
    importc: "SetVrConfiguration", dynlib: raylibdll.}
##  Set stereo rendering configuration parameters

proc IsVrSimulatorReady*(): bool {.cdecl, importc: "IsVrSimulatorReady",
                                dynlib: raylibdll.}
##  Detect if VR simulator is ready

proc ToggleVrMode*() {.cdecl, importc: "ToggleVrMode", dynlib: raylibdll.}
##  Enable/Disable VR experience

proc BeginVrDrawing*() {.cdecl, importc: "BeginVrDrawing", dynlib: raylibdll.}
##  Begin VR simulator stereo rendering

proc EndVrDrawing*() {.cdecl, importc: "EndVrDrawing", dynlib: raylibdll.}
##  End VR simulator stereo rendering
## ------------------------------------------------------------------------------------
##  Audio Loading and Playing Functions (Module: audio)
## ------------------------------------------------------------------------------------
##  Audio device management functions

proc InitAudioDevice*() {.cdecl, importc: "InitAudioDevice", dynlib: raylibdll.}
##  Initialize audio device and context

proc CloseAudioDevice*() {.cdecl, importc: "CloseAudioDevice", dynlib: raylibdll.}
##  Close the audio device and context

proc IsAudioDeviceReady*(): bool {.cdecl, importc: "IsAudioDeviceReady",
                                dynlib: raylibdll.}
##  Check if audio device has been initialized successfully

proc SetMasterVolume*(volume: float32) {.cdecl, importc: "SetMasterVolume",
                                     dynlib: raylibdll.}
##  Set master volume (listener)
##  Wave/Sound loading/unloading functions

proc LoadWave*(fileName: cstring): Wave {.cdecl, importc: "LoadWave", dynlib: raylibdll.}
##  Load wave data from file

proc LoadWaveFromMemory*(fileType: cstring; fileData: ptr uint8; dataSize: int32): Wave {.
    cdecl, importc: "LoadWaveFromMemory", dynlib: raylibdll.}
##  Load wave from memory buffer, fileType refers to extension: i.e. "wav"

proc LoadSound*(fileName: cstring): Sound {.cdecl, importc: "LoadSound",
                                        dynlib: raylibdll.}
##  Load sound from file

proc LoadSoundFromWave*(wave: Wave): Sound {.cdecl, importc: "LoadSoundFromWave",
    dynlib: raylibdll.}
##  Load sound from wave data

proc UpdateSound*(sound: Sound; data: pointer; samplesCount: int32) {.cdecl,
    importc: "UpdateSound", dynlib: raylibdll.}
##  Update sound buffer with new data

proc UnloadWave*(wave: Wave) {.cdecl, importc: "UnloadWave", dynlib: raylibdll.}
##  Unload wave data

proc UnloadSound*(sound: Sound) {.cdecl, importc: "UnloadSound", dynlib: raylibdll.}
##  Unload sound

proc ExportWave*(wave: Wave; fileName: cstring): bool {.cdecl, importc: "ExportWave",
    dynlib: raylibdll.}
##  Export wave data to file, returns true on success

proc ExportWaveAsCode*(wave: Wave; fileName: cstring): bool {.cdecl,
    importc: "ExportWaveAsCode", dynlib: raylibdll.}
##  Export wave sample data to code (.h), returns true on success
##  Wave/Sound management functions

proc PlaySound*(sound: Sound) {.cdecl, importc: "PlaySound", dynlib: raylibdll.}
##  Play a sound

proc StopSound*(sound: Sound) {.cdecl, importc: "StopSound", dynlib: raylibdll.}
##  Stop playing a sound

proc PauseSound*(sound: Sound) {.cdecl, importc: "PauseSound", dynlib: raylibdll.}
##  Pause a sound

proc ResumeSound*(sound: Sound) {.cdecl, importc: "ResumeSound", dynlib: raylibdll.}
##  Resume a paused sound

proc PlaySoundMulti*(sound: Sound) {.cdecl, importc: "PlaySoundMulti",
                                  dynlib: raylibdll.}
##  Play a sound (using multichannel buffer pool)

proc StopSoundMulti*() {.cdecl, importc: "StopSoundMulti", dynlib: raylibdll.}
##  Stop any sound playing (using multichannel buffer pool)

proc GetSoundsPlaying*(): int32 {.cdecl, importc: "GetSoundsPlaying", dynlib: raylibdll.}
##  Get number of sounds playing in the multichannel

proc IsSoundPlaying*(sound: Sound): bool {.cdecl, importc: "IsSoundPlaying",
                                       dynlib: raylibdll.}
##  Check if a sound is currently playing

proc SetSoundVolume*(sound: Sound; volume: float32) {.cdecl, importc: "SetSoundVolume",
    dynlib: raylibdll.}
##  Set volume for a sound (1.0 is max level)

proc SetSoundPitch*(sound: Sound; pitch: float32) {.cdecl, importc: "SetSoundPitch",
    dynlib: raylibdll.}
##  Set pitch for a sound (1.0 is base level)

proc WaveFormat*(wave: ptr Wave; sampleRate: int32; sampleSize: int32; channels: int32) {.
    cdecl, importc: "WaveFormat", dynlib: raylibdll.}
##  Convert wave data to desired format

proc WaveCopy*(wave: Wave): Wave {.cdecl, importc: "WaveCopy", dynlib: raylibdll.}
##  Copy a wave to a new wave

proc WaveCrop*(wave: ptr Wave; initSample: int32; finalSample: int32) {.cdecl,
    importc: "WaveCrop", dynlib: raylibdll.}
##  Crop a wave to defined samples range

proc LoadWaveSamples*(wave: Wave): ptr float32 {.cdecl, importc: "LoadWaveSamples",
    dynlib: raylibdll.}
##  Load samples data from wave as a floats array

proc UnloadWaveSamples*(samples: ptr float32) {.cdecl, importc: "UnloadWaveSamples",
    dynlib: raylibdll.}
##  Unload samples data loaded with LoadWaveSamples()
##  Music management functions

proc LoadMusicStream*(fileName: cstring): Music {.cdecl, importc: "LoadMusicStream",
    dynlib: raylibdll.}
##  Load music stream from file

proc UnloadMusicStream*(music: Music) {.cdecl, importc: "UnloadMusicStream",
                                     dynlib: raylibdll.}
##  Unload music stream

proc PlayMusicStream*(music: Music) {.cdecl, importc: "PlayMusicStream",
                                   dynlib: raylibdll.}
##  Start music playing

proc UpdateMusicStream*(music: Music) {.cdecl, importc: "UpdateMusicStream",
                                     dynlib: raylibdll.}
##  Updates buffers for music streaming

proc StopMusicStream*(music: Music) {.cdecl, importc: "StopMusicStream",
                                   dynlib: raylibdll.}
##  Stop music playing

proc PauseMusicStream*(music: Music) {.cdecl, importc: "PauseMusicStream",
                                    dynlib: raylibdll.}
##  Pause music playing

proc ResumeMusicStream*(music: Music) {.cdecl, importc: "ResumeMusicStream",
                                     dynlib: raylibdll.}
##  Resume playing paused music

proc IsMusicPlaying*(music: Music): bool {.cdecl, importc: "IsMusicPlaying",
                                       dynlib: raylibdll.}
##  Check if music is playing

proc SetMusicVolume*(music: Music; volume: float32) {.cdecl, importc: "SetMusicVolume",
    dynlib: raylibdll.}
##  Set volume for music (1.0 is max level)

proc SetMusicPitch*(music: Music; pitch: float32) {.cdecl, importc: "SetMusicPitch",
    dynlib: raylibdll.}
##  Set pitch for a music (1.0 is base level)

proc GetMusicTimeLength*(music: Music): float32 {.cdecl,
    importc: "GetMusicTimeLength", dynlib: raylibdll.}
##  Get music time length (in seconds)

proc GetMusicTimePlayed*(music: Music): float32 {.cdecl,
    importc: "GetMusicTimePlayed", dynlib: raylibdll.}
##  Get current music time played (in seconds)
##  AudioStream management functions

proc InitAudioStream*(sampleRate: uint32; sampleSize: uint32; channels: uint32): AudioStream {.
    cdecl, importc: "InitAudioStream", dynlib: raylibdll.}
##  Init audio stream (to stream raw audio pcm data)

proc UpdateAudioStream*(stream: AudioStream; data: pointer; samplesCount: int32) {.
    cdecl, importc: "UpdateAudioStream", dynlib: raylibdll.}
##  Update audio stream buffers with data

proc CloseAudioStream*(stream: AudioStream) {.cdecl, importc: "CloseAudioStream",
    dynlib: raylibdll.}
##  Close audio stream and free memory

proc IsAudioStreamProcessed*(stream: AudioStream): bool {.cdecl,
    importc: "IsAudioStreamProcessed", dynlib: raylibdll.}
##  Check if any audio stream buffers requires refill

proc PlayAudioStream*(stream: AudioStream) {.cdecl, importc: "PlayAudioStream",
    dynlib: raylibdll.}
##  Play audio stream

proc PauseAudioStream*(stream: AudioStream) {.cdecl, importc: "PauseAudioStream",
    dynlib: raylibdll.}
##  Pause audio stream

proc ResumeAudioStream*(stream: AudioStream) {.cdecl, importc: "ResumeAudioStream",
    dynlib: raylibdll.}
##  Resume audio stream

proc IsAudioStreamPlaying*(stream: AudioStream): bool {.cdecl,
    importc: "IsAudioStreamPlaying", dynlib: raylibdll.}
##  Check if audio stream is playing

proc StopAudioStream*(stream: AudioStream) {.cdecl, importc: "StopAudioStream",
    dynlib: raylibdll.}
##  Stop audio stream

proc SetAudioStreamVolume*(stream: AudioStream; volume: float32) {.cdecl,
    importc: "SetAudioStreamVolume", dynlib: raylibdll.}
##  Set volume for audio stream (1.0 is max level)

proc SetAudioStreamPitch*(stream: AudioStream; pitch: float32) {.cdecl,
    importc: "SetAudioStreamPitch", dynlib: raylibdll.}
##  Set pitch for audio stream (1.0 is base level)

proc SetAudioStreamBufferSizeDefault*(size: int32) {.cdecl,
    importc: "SetAudioStreamBufferSizeDefault", dynlib: raylibdll.}
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
converter ConfigFlagToInt32*(self: ConfigFlag): int32 = self.int32
converter TraceLogTypeToInt32*(self: TraceLogType): int32 = self.int32
converter KeyboardKeyToInt32*(self: KeyboardKey): int32 = self.int32
converter AndroidButtonToInt32*(self: AndroidButton): int32 = self.int32
converter MouseButtonToInt32*(self: MouseButton): int32 = self.int32
converter MouseCursorToInt32*(self: MouseCursor): int32 = self.int32
converter GamepadNumberToInt32*(self: GamepadNumber): int32 = self.int32
converter GamepadButtonToInt32*(self: GamepadButton): int32 = self.int32
converter GamepadAxisToInt32*(self: GamepadAxis): int32 = self.int32
converter ShaderLocationIndexToInt32*(self: ShaderLocationIndex): int32 = self.int32
converter ShaderUniformDataTypeToInt32*(self: ShaderUniformDataType): int32 = self.int32
converter MaterialMapTypeToInt32*(self: MaterialMapType): int32 = self.int32
converter PixelFormatToInt32*(self: PixelFormat): int32 = self.int32
converter TextureFilterModeToInt32*(self: TextureFilterMode): int32 = self.int32
converter TextureWrapModeToInt32*(self: TextureWrapMode): int32 = self.int32
converter CubemapLayoutTypeToInt32*(self: CubemapLayoutType): int32 = self.int32
converter FontTypeToInt32*(self: FontType): int32 = self.int32
converter BlendModeToInt32*(self: BlendMode): int32 = self.int32
converter GestureTypeToInt32*(self: GestureType): int32 = self.int32
converter CameraModeToInt32*(self: CameraMode): int32 = self.int32
converter CameraTypeToInt32*(self: CameraType): int32 = self.int32
converter NPatchTypeToInt32*(self: NPatchType): int32 = self.int32

