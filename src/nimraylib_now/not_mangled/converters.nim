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
converter ConfigFlagsToInt*(self: raylib.ConfigFlags): cuint = self.cuint
converter TraceLogLevelToInt*(self: raylib.TraceLogLevel): cint = self.cint
converter KeyboardKeyToInt*(self: raylib.KeyboardKey): cint = self.cint
converter MouseButtonToInt*(self: raylib.MouseButton): cint = self.cint
converter MouseCursorToInt*(self: raylib.MouseCursor): cint = self.cint
converter GamepadButtonToInt*(self: raylib.GamepadButton): cint = self.cint
converter GamepadAxisToInt*(self: raylib.GamepadAxis): cint = self.cint
converter MaterialMapIndexToInt*(self: raylib.MaterialMapIndex): cint = self.cint
converter ShaderLocationIndexToInt*(self: raylib.ShaderLocationIndex): cint = self.cint
converter ShaderUniformDataTypeToInt*(self: raylib.ShaderUniformDataType): cint = self.cint
converter ShaderAttributeDataTypeToInt*(self: raylib.ShaderAttributeDataType): cint = self.cint
converter PixelFormatToInt*(self: raylib.PixelFormat): cint = self.cint
converter TextureFilterToInt*(self: raylib.TextureFilter): cint = self.cint
converter TextureWrapToInt*(self: raylib.TextureWrap): cint = self.cint
converter CubemapLayoutToInt*(self: raylib.CubemapLayout): cint = self.cint
converter FontTypeToInt*(self: raylib.FontType): cint = self.cint
converter BlendModeToInt*(self: raylib.BlendMode): cint = self.cint
converter GestureToInt*(self: raylib.Gesture): cint = self.cint
converter CameraModeToInt*(self: raylib.CameraMode): cint = self.cint
converter CameraProjectionToInt*(self: raylib.CameraProjection): cint = self.cint
converter NPatchLayoutToInt*(self: raylib.NPatchLayout): cint = self.cint
converter GlVersionToInt*(self: rlgl.GlVersion): cint = self.cint
converter FramebufferAttachTypeToInt*(self: rlgl.FramebufferAttachType): cint = self.cint
converter FramebufferAttachTextureTypeToInt*(self: rlgl.FramebufferAttachTextureType): cint = self.cint
converter TraceLogLevelToInt*(self: rlgl.TraceLogLevel): cint = self.cint
converter PixelFormatToInt*(self: rlgl.PixelFormat): cint = self.cint
converter TextureFilterToInt*(self: rlgl.TextureFilter): cint = self.cint
converter BlendModeToInt*(self: rlgl.BlendMode): cint = self.cint
converter ShaderLocationIndexToInt*(self: rlgl.ShaderLocationIndex): cint = self.cint
converter ShaderUniformDataTypeToInt*(self: rlgl.ShaderUniformDataType): cint = self.cint
converter ShaderAttributeDataTypeToInt*(self: rlgl.ShaderAttributeDataType): cint = self.cint
converter ControlStateToInt*(self: raygui.ControlState): cint = self.cint
converter TextAlignmentToInt*(self: raygui.TextAlignment): cint = self.cint
converter ControlToInt*(self: raygui.Control): cint = self.cint
converter ControlPropertyToInt*(self: raygui.ControlProperty): cint = self.cint
converter DefaultPropertyToInt*(self: raygui.DefaultProperty): cint = self.cint
converter TogglePropertyToInt*(self: raygui.ToggleProperty): cint = self.cint
converter SliderPropertyToInt*(self: raygui.SliderProperty): cint = self.cint
converter ProgressBarPropertyToInt*(self: raygui.ProgressBarProperty): cint = self.cint
converter CheckBoxPropertyToInt*(self: raygui.CheckBoxProperty): cint = self.cint
converter ComboBoxPropertyToInt*(self: raygui.ComboBoxProperty): cint = self.cint
converter DropdownBoxPropertyToInt*(self: raygui.DropdownBoxProperty): cint = self.cint
converter TextBoxPropertyToInt*(self: raygui.TextBoxProperty): cint = self.cint
converter SpinnerPropertyToInt*(self: raygui.SpinnerProperty): cint = self.cint
converter ScrollBarPropertyToInt*(self: raygui.ScrollBarProperty): cint = self.cint
converter ScrollBarSideToInt*(self: raygui.ScrollBarSide): cint = self.cint
converter ListViewPropertyToInt*(self: raygui.ListViewProperty): cint = self.cint
converter ColorPickerPropertyToInt*(self: raygui.ColorPickerProperty): cint = self.cint
