import raylib

from os import parentDir, `/`
const physacHeader = currentSourcePath().parentDir()/"physac.h"
{.passC: "-DPHYSAC_IMPLEMENTATION".}
{.passC: "-DPHYSAC_NO_THREADS".}
## *********************************************************************************************
##
##    Physac v1.1 - 2D Physics library for videogames
##
##    DESCRIPTION:
##
##    Physac is a small 2D physics engine written in pure C. The engine uses a fixed time-step thread loop
##    to simluate physics. A physics step contains the following phases: get collision information,
##    apply dynamics, collision solving and position correction. It uses a very simple struct for physic
##    bodies with a position vector to be used in any 3D rendering API.
##
##    CONFIGURATION:
##
##    #define PHYSAC_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define PHYSAC_STATIC (defined by default)
##        The generated implementation will stay private inside implementation file and all
##        internal symbols and functions will only be visible inside that file.
##
##    #define PHYSAC_DEBUG
##        Show debug traces log messages about physic bodies creation/destruction, physic system errors,
##        some calculations results and NULL reference exceptions
##
##    #define PHYSAC_DEFINE_VECTOR2_TYPE
##        Forces library to define struct Vector2 data type (float x; float y)
##
##    #define PHYSAC_AVOID_TIMMING_SYSTEM
##        Disables internal timming system, used by UpdatePhysics() to launch timmed physic steps,
##        it allows just running UpdatePhysics() automatically on a separate thread at a desired time step.
##        In case physics steps update needs to be controlled by user with a custom timming mechanism,
##        just define this flag and the internal timming mechanism will be avoided, in that case,
##        timming libraries are neither required by the module.
##
##    #define PHYSAC_MALLOC()
##    #define PHYSAC_CALLOC()
##    #define PHYSAC_FREE()
##        You can define your own malloc/free implementation replacing stdlib.h malloc()/free() functions.
##        Otherwise it will include stdlib.h and use the C standard library malloc()/free() function.
##
##    COMPILATION:
##
##    Use the following code to compile with GCC:
##        gcc -o $(NAME_PART).exe $(FILE_NAME) -s -static -lraylib -lopengl32 -lgdi32 -lwinmm -std=c99
##
##    VERSIONS HISTORY:
##        1.1 (20-Jan-2021) @raysan5: Library general revision
##                Removed threading system (up to the user)
##                Support MSVC C++ compilation using CLITERAL()
##                Review DEBUG mechanism for TRACELOG() and all TRACELOG() messages
##                Review internal variables/functions naming for consistency
##                Allow option to avoid internal timming system, to allow app manage the steps
##        1.0 (12-Jun-2017) First release of the library
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2016-2021 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
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
##  Allow custom memory allocators
## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------

const
  MAX_BODIES* = 64
  MAX_MANIFOLDS* = 4096
  MAX_VERTICES* = 24
  DEFAULT_CIRCLE_VERTICES* = 24
  COLLISION_ITERATIONS* = 100
  PENETRATION_ALLOWANCE* = 0.05
  PENETRATION_CORRECTION* = 0.4

## ----------------------------------------------------------------------------------
##  Data Types Structure Definition
## ----------------------------------------------------------------------------------

type
  PhysicsShapeType* {.size: sizeof(cint), pure.} = enum
    CIRCLE = 0, POLYGON


##  Previously defined to be used in PhysicsShape struct as circular dependencies
##  Matrix2x2 type (used for polygon shape rotation matrix)

type
  Matrix2x2* {.importc: "Matrix2x2", header: physacHeader, bycopy.} = object
    m00* {.importc: "m00".}: cfloat
    m01* {.importc: "m01".}: cfloat
    m10* {.importc: "m10".}: cfloat
    m11* {.importc: "m11".}: cfloat

  PhysicsVertexData* {.importc: "PhysicsVertexData", header: physacHeader, bycopy.} = object
    vertexCount* {.importc: "vertexCount".}: cuint ##  Vertex count (positions and normals)
    positions* {.importc: "positions".}: array[MAX_VERTICES, Vector2] ##  Vertex positions vectors
    normals* {.importc: "normals".}: array[MAX_VERTICES, Vector2] ##  Vertex normals vectors

  PhysicsShape* {.importc: "PhysicsShape", header: physacHeader, bycopy.} = object
    `type`* {.importc: "type".}: PhysicsShapeType ##  Shape type (circle or polygon)
    body* {.importc: "body".}: PhysicsBody ##  Shape physics body data pointer
    vertexData* {.importc: "vertexData".}: PhysicsVertexData ##  Shape vertices data (used for polygon shapes)
    radius* {.importc: "radius".}: cfloat ##  Shape radius (used for circle shapes)
    transform* {.importc: "transform".}: Matrix2x2 ##  Vertices transform matrix 2x2

  PhysicsBodyData* {.importc: "PhysicsBodyData", header: physacHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  Unique identifier
    enabled* {.importc: "enabled".}: bool ##  Enabled dynamics state (collisions are calculated anyway)
    position* {.importc: "position".}: Vector2 ##  Physics body shape pivot
    velocity* {.importc: "velocity".}: Vector2 ##  Current linear velocity applied to position
    force* {.importc: "force".}: Vector2 ##  Current linear force (reset to 0 every step)
    angularVelocity* {.importc: "angularVelocity".}: cfloat ##  Current angular velocity applied to orient
    torque* {.importc: "torque".}: cfloat ##  Current angular force (reset to 0 every step)
    orient* {.importc: "orient".}: cfloat ##  Rotation in radians
    inertia* {.importc: "inertia".}: cfloat ##  Moment of inertia
    inverseInertia* {.importc: "inverseInertia".}: cfloat ##  Inverse value of inertia
    mass* {.importc: "mass".}: cfloat ##  Physics body mass
    inverseMass* {.importc: "inverseMass".}: cfloat ##  Inverse value of mass
    staticFriction* {.importc: "staticFriction".}: cfloat ##  Friction when the body has not movement (0 to 1)
    dynamicFriction* {.importc: "dynamicFriction".}: cfloat ##  Friction when the body has movement (0 to 1)
    restitution* {.importc: "restitution".}: cfloat ##  Restitution coefficient of the body (0 to 1)
    useGravity* {.importc: "useGravity".}: bool ##  Apply gravity force to dynamics
    isGrounded* {.importc: "isGrounded".}: bool ##  Physics grounded on other body state
    freezeOrient* {.importc: "freezeOrient".}: bool ##  Physics rotation constraint
    shape* {.importc: "shape".}: PhysicsShape ##  Physics body shape information (type, radius, vertices, transform)

  PhysicsBody* = ptr PhysicsBodyData
  PhysicsManifoldData* {.importc: "PhysicsManifoldData", header: physacHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  Unique identifier
    bodyA* {.importc: "bodyA".}: PhysicsBody ##  Manifold first physics body reference
    bodyB* {.importc: "bodyB".}: PhysicsBody ##  Manifold second physics body reference
    penetration* {.importc: "penetration".}: cfloat ##  Depth of penetration from collision
    normal* {.importc: "normal".}: Vector2 ##  Normal direction vector from 'a' to 'b'
    contacts* {.importc: "contacts".}: array[2, Vector2] ##  Points of contact during collision
    contactsCount* {.importc: "contactsCount".}: cuint ##  Current collision number of contacts
    restitution* {.importc: "restitution".}: cfloat ##  Mixed restitution during collision
    dynamicFriction* {.importc: "dynamicFriction".}: cfloat ##  Mixed dynamic friction during collision
    staticFriction* {.importc: "staticFriction".}: cfloat ##  Mixed static friction during collision

  PhysicsManifold* = ptr PhysicsManifoldData

## ----------------------------------------------------------------------------------
##  Module Functions Declaration
## ----------------------------------------------------------------------------------
##  Physics system management

proc initPhysics*() {.cdecl, importc: "InitPhysics", header: physacHeader.}
##  Initializes physics system

proc updatePhysics*() {.cdecl, importc: "UpdatePhysics", header: physacHeader.}
##  Update physics system

proc resetPhysics*() {.cdecl, importc: "ResetPhysics", header: physacHeader.}
##  Reset physics system (global variables)

proc closePhysics*() {.cdecl, importc: "ClosePhysics", header: physacHeader.}
##  Close physics system and unload used memory

proc setPhysicsTimeStep*(delta: cdouble) {.cdecl, importc: "SetPhysicsTimeStep",
                                        header: physacHeader.}
##  Sets physics fixed time step in milliseconds. 1.666666 by default

proc setPhysicsGravity*(x: cfloat; y: cfloat) {.cdecl, importc: "SetPhysicsGravity",
    header: physacHeader.}
##  Sets physics global gravity force
##  Physic body creation/destroy

proc createPhysicsBodyCircle*(pos: Vector2; radius: cfloat; density: cfloat): PhysicsBody {.
    cdecl, importc: "CreatePhysicsBodyCircle", header: physacHeader.}
##  Creates a new circle physics body with generic parameters

proc createPhysicsBodyRectangle*(pos: Vector2; width: cfloat; height: cfloat;
                                density: cfloat): PhysicsBody {.cdecl,
    importc: "CreatePhysicsBodyRectangle", header: physacHeader.}
##  Creates a new rectangle physics body with generic parameters

proc createPhysicsBodyPolygon*(pos: Vector2; radius: cfloat; sides: cint;
                              density: cfloat): PhysicsBody {.cdecl,
    importc: "CreatePhysicsBodyPolygon", header: physacHeader.}
##  Creates a new polygon physics body with generic parameters

proc destroyPhysicsBody*(body: PhysicsBody) {.cdecl, importc: "DestroyPhysicsBody",
    header: physacHeader.}
##  Destroy a physics body
##  Physic body forces

proc physicsAddForce*(body: PhysicsBody; force: Vector2) {.cdecl,
    importc: "PhysicsAddForce", header: physacHeader.}
##  Adds a force to a physics body

proc physicsAddTorque*(body: PhysicsBody; amount: cfloat) {.cdecl,
    importc: "PhysicsAddTorque", header: physacHeader.}
##  Adds an angular force to a physics body

proc physicsShatter*(body: PhysicsBody; position: Vector2; force: cfloat) {.cdecl,
    importc: "PhysicsShatter", header: physacHeader.}
##  Shatters a polygon shape physics body to little physics bodies with explosion force

proc setPhysicsBodyRotation*(body: PhysicsBody; radians: cfloat) {.cdecl,
    importc: "SetPhysicsBodyRotation", header: physacHeader.}
##  Sets physics body shape transform based on radians parameter
##  Query physics info

proc getPhysicsBody*(index: cint): PhysicsBody {.cdecl, importc: "GetPhysicsBody",
    header: physacHeader.}
##  Returns a physics body of the bodies pool at a specific index

proc getPhysicsBodiesCount*(): cint {.cdecl, importc: "GetPhysicsBodiesCount",
                                   header: physacHeader.}
##  Returns the current amount of created physics bodies

proc getPhysicsShapeType*(index: cint): cint {.cdecl, importc: "GetPhysicsShapeType",
    header: physacHeader.}
##  Returns the physics body shape type (PHYSICS_CIRCLE or PHYSICS_POLYGON)

proc getPhysicsShapeVerticesCount*(index: cint): cint {.cdecl,
    importc: "GetPhysicsShapeVerticesCount", header: physacHeader.}
##  Returns the amount of vertices of a physics body shape

proc getPhysicsShapeVertex*(body: PhysicsBody; vertex: cint): Vector2 {.cdecl,
    importc: "GetPhysicsShapeVertex", header: physacHeader.}
##  Returns transformed position of a body shape (body position + vertex transformed position)

