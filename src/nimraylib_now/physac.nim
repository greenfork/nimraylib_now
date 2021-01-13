import raylib

from os import parentDir, `/`
const physacHeader = currentSourcePath().parentDir()/"physac.h"
{.passC: "-DPHYSAC_IMPLEMENTATION".}
{.passC: "-DPHYSAC_NO_THREADS".}
## *********************************************************************************************
##
##    Physac v1.0 - 2D Physics library for videogames
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
##    #define PHYSAC_NO_THREADS
##        The generated implementation won't include pthread library and user must create a secondary thread to call PhysicsThread().
##        It is so important that the thread where PhysicsThread() is called must not have v-sync or any other CPU limitation.
##
##    #define PHYSAC_STANDALONE
##        Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
##        internally in the library and input management and drawing functions must be provided by
##        the user (check library implementation for further details).
##
##    #define PHYSAC_DEBUG
##        Traces log messages when creating and destroying physics bodies and detects errors in physics
##        calculations and reference exceptions; it is useful for debug purposes
##
##    #define PHYSAC_MALLOC()
##    #define PHYSAC_FREE()
##        You can define your own malloc/free implementation replacing stdlib.h malloc()/free() functions.
##        Otherwise it will include stdlib.h and use the C standard library malloc()/free() function.
##
##
##    NOTE 1: Physac requires multi-threading, when InitPhysics() a second thread is created to manage physics calculations.
##    NOTE 2: Physac requires static C library linkage to avoid dependency on MinGW DLL (-static -lpthread)
##
##    Use the following code to compile:
##    gcc -o $(NAME_PART).exe $(FILE_NAME) -s -static -lraylib -lpthread -lopengl32 -lgdi32 -lwinmm -std=c99
##
##    VERY THANKS TO:
##        Ramon Santamaria (github: @raysan5)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2016-2018 Victor Fisac (github: @victorfisac)
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
  CIRCLE_VERTICES* = 24
  COLLISION_ITERATIONS* = 100
  PENETRATION_ALLOWANCE* = 0.05
  PENETRATION_CORRECTION* = 0.4

## ----------------------------------------------------------------------------------
##  Types and Structures Definition
##  NOTE: Below types are required for PHYSAC_STANDALONE usage
## ----------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------
##  Data Types Structure Definition
## ----------------------------------------------------------------------------------

type
  PhysicsShapeType* {.size: sizeof(cint), pure.} = enum
    CIRCLE, POLYGON


##  Previously defined to be used in PhysicsShape struct as circular dependencies
##  Matrix2x2 type (used for polygon shape rotation matrix)

type
  Matrix2x2* {.importc: "Matrix2x2", header: physacHeader, bycopy.} = object
    m00* {.importc: "m00".}: cfloat
    m01* {.importc: "m01".}: cfloat
    m10* {.importc: "m10".}: cfloat
    m11* {.importc: "m11".}: cfloat

  PolygonData* {.importc: "PolygonData", header: physacHeader, bycopy.} = object
    vertexCount* {.importc: "vertexCount".}: cuint ##  Current used vertex and normals count
    positions* {.importc: "positions".}: array[MAX_VERTICES, Vector2] ##  Polygon vertex positions vectors
    normals* {.importc: "normals".}: array[MAX_VERTICES, Vector2] ##  Polygon vertex normals vectors

  PhysicsShape* {.importc: "PhysicsShape", header: physacHeader, bycopy.} = object
    `type`* {.importc: "type".}: PhysicsShapeType ##  Physics shape type (circle or polygon)
    body* {.importc: "body".}: PhysicsBody ##  Shape physics body reference
    radius* {.importc: "radius".}: cfloat ##  Circle shape radius (used for circle shapes)
    transform* {.importc: "transform".}: Matrix2x2 ##  Vertices transform matrix 2x2
    vertexData* {.importc: "vertexData".}: PolygonData ##  Polygon shape vertices position and normals data (just used for polygon shapes)

  PhysicsBodyData* {.importc: "PhysicsBodyData", header: physacHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  Reference unique identifier
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
    shape* {.importc: "shape".}: PhysicsShape ##  Physics body shape information (type, radius, vertices, normals)

  PhysicsBody* = ptr PhysicsBodyData
  PhysicsManifoldData* {.importc: "PhysicsManifoldData", header: physacHeader, bycopy.} = object
    id* {.importc: "id".}: cuint ##  Reference unique identifier
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

proc initPhysics*() {.cdecl, importc: "InitPhysics", header: physacHeader.}
##  Initializes physics values, pointers and creates physics loop thread

proc runPhysicsStep*() {.cdecl, importc: "RunPhysicsStep", header: physacHeader.}
##  Run physics step, to be used if PHYSICS_NO_THREADS is set in your main loop

proc setPhysicsTimeStep*(delta: cdouble) {.cdecl, importc: "SetPhysicsTimeStep",
                                        header: physacHeader.}
##  Sets physics fixed time step in milliseconds. 1.666666 by default

proc isPhysicsEnabled*(): bool {.cdecl, importc: "IsPhysicsEnabled",
                              header: physacHeader.}
##  Returns true if physics thread is currently enabled

proc setPhysicsGravity*(x: cfloat; y: cfloat) {.cdecl, importc: "SetPhysicsGravity",
    header: physacHeader.}
##  Sets physics global gravity force

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

proc physicsAddForce*(body: PhysicsBody; force: Vector2) {.cdecl,
    importc: "PhysicsAddForce", header: physacHeader.}
##  Adds a force to a physics body

proc physicsAddTorque*(body: PhysicsBody; amount: cfloat) {.cdecl,
    importc: "PhysicsAddTorque", header: physacHeader.}
##  Adds an angular force to a physics body

proc physicsShatter*(body: PhysicsBody; position: Vector2; force: cfloat) {.cdecl,
    importc: "PhysicsShatter", header: physacHeader.}
##  Shatters a polygon shape physics body to little physics bodies with explosion force

proc getPhysicsBodiesCount*(): cint {.cdecl, importc: "GetPhysicsBodiesCount",
                                   header: physacHeader.}
##  Returns the current amount of created physics bodies

proc getPhysicsBody*(index: cint): PhysicsBody {.cdecl, importc: "GetPhysicsBody",
    header: physacHeader.}
##  Returns a physics body of the bodies pool at a specific index

proc getPhysicsShapeType*(index: cint): cint {.cdecl, importc: "GetPhysicsShapeType",
    header: physacHeader.}
##  Returns the physics body shape type (PHYSICS_CIRCLE or PHYSICS_POLYGON)

proc getPhysicsShapeVerticesCount*(index: cint): cint {.cdecl,
    importc: "GetPhysicsShapeVerticesCount", header: physacHeader.}
##  Returns the amount of vertices of a physics body shape

proc getPhysicsShapeVertex*(body: PhysicsBody; vertex: cint): Vector2 {.cdecl,
    importc: "GetPhysicsShapeVertex", header: physacHeader.}
##  Returns transformed position of a body shape (body position + vertex transformed position)

proc setPhysicsBodyRotation*(body: PhysicsBody; radians: cfloat) {.cdecl,
    importc: "SetPhysicsBodyRotation", header: physacHeader.}
##  Sets physics body shape transform based on radians parameter

proc destroyPhysicsBody*(body: PhysicsBody) {.cdecl, importc: "DestroyPhysicsBody",
    header: physacHeader.}
##  Unitializes and destroy a physics body

proc resetPhysics*() {.cdecl, importc: "ResetPhysics", header: physacHeader.}
##  Destroys created physics bodies and manifolds and resets global values

proc closePhysics*() {.cdecl, importc: "ClosePhysics", header: physacHeader.}
##  Unitializes physics pointers and closes physics loop thread

