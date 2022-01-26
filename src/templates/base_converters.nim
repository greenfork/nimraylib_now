import ./raylib
import ./rlgl
import ./raygui

converter toCint*(self: int): cint = self.cint
converter toInt*(self: cint): int = self.int

# Conversions from tuple to object for Vector2, Vector3, Vector4,
# Matrix and Rectangle. Quaternion is same as Vector4, so works too.
converter tupleToColor*(self: tuple[r,g,b,a: int]): Color =
  Color(r: self.r.uint8, g: self.g.uint8, b: self.b.uint8, a: self.a.uint8)

converter tupleToColor*(self: tuple[r,g,b: int]): Color =
  Color(r: self.r.uint8, g: self.g.uint8, b: self.b.uint8, a: 255)

converter tupleToVector2*(self: tuple[x,y: float]): Vector2 =
  Vector2(x: self.x.cfloat, y: self.y.cfloat)

converter tupleToVector3*(self: tuple[x,y,z: float]): Vector3 =
  Vector3(x: self.x.cfloat, y: self.y.cfloat, z: self.z.cfloat)

converter tupleToVector4*(self: tuple[x,y,z,w: float]): Vector4 =
  Vector4(x: self.x.cfloat, y: self.y.cfloat, z: self.z.cfloat, w: self.w.cfloat)

converter tupleToMatrix*(self:
  tuple[m0,m4,m8, m12,
        m1,m5,m9, m13,
        m2,m6,m10,m14,
        m3,m7,m11,m15: float]
): Matrix =
  Matrix(
    m0: self.m0.cfloat, m4: self.m4.cfloat, m8:  self.m8.cfloat,  m12: self.m12.cfloat,
    m1: self.m1.cfloat, m5: self.m5.cfloat, m9:  self.m9.cfloat,  m13: self.m13.cfloat,
    m2: self.m2.cfloat, m6: self.m6.cfloat, m10: self.m10.cfloat, m14: self.m14.cfloat,
    m3: self.m3.cfloat, m7: self.m7.cfloat, m11: self.m11.cfloat, m15: self.m15.cfloat,
  )

converter tupleToRectangle*(self: tuple[x,y,width,height: float]): Rectangle =
  Rectangle(x: self.x.cfloat, y: self.y.cfloat, width: self.width.cfloat, height: self.height.cfloat)
