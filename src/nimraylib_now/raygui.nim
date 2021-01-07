 {.deadCodeElim: on.}
when defined(windows):
  const
    rayguidll* = "libraygui.dll"
elif defined(macosx):
  const
    rayguidll* = "libraygui.dylib"
else:
  const
    rayguidll* = "libraygui.so"
import raylib
## ******************************************************************************************
##
##    raygui v2.8 - A simple and easy-to-use immediate-mode gui library
##
##    DESCRIPTION:
##
##    raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
##    available as a standalone library, as long as input and drawing functions are provided.
##
##    Controls provided:
##
##    # Container/separators Controls
##        - WindowBox
##        - GroupBox
##        - Line
##        - Panel
##
##    # Basic Controls
##        - Label
##        - Button
##        - LabelButton   --> Label
##        - ImageButton   --> Button
##        - ImageButtonEx --> Button
##        - Toggle
##        - ToggleGroup   --> Toggle
##        - CheckBox
##        - ComboBox
##        - DropdownBox
##        - TextBox
##        - TextBoxMulti
##        - ValueBox      --> TextBox
##        - Spinner       --> Button, ValueBox
##        - Slider
##        - SliderBar     --> Slider
##        - ProgressBar
##        - StatusBar
##        - ScrollBar
##        - ScrollPanel
##        - DummyRec
##        - Grid
##
##    # Advance Controls
##        - ListView
##        - ColorPicker   --> ColorPanel, ColorBarHue
##        - MessageBox    --> Window, Label, Button
##        - TextInputBox  --> Window, Label, TextBox, Button
##
##    It also provides a set of functions for styling the controls based on its properties (size, color).
##
##    CONFIGURATION:
##
##    #define RAYGUI_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RAYGUI_STATIC (defined by default)
##        The generated implementation will stay private inside implementation file and all
##        internal symbols and functions will only be visible inside that file.
##
##    #define RAYGUI_STANDALONE
##        Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
##        internally in the library and input management and drawing functions must be provided by
##        the user (check library implementation for further details).
##
##    #define RAYGUI_SUPPORT_ICONS
##        Includes riconsdata.h header defining a set of 128 icons (binary format) to be used on
##        multiple controls and following raygui styles
##
##
##    VERSIONS HISTORY:
##        2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
##        2.7 (20-Feb-2020) Added possible tooltips API
##        2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
##                          REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
##                          REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
##                          Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
##                          Added 8 new custom styles ready to use
##                          Multiple minor tweaks and bugs corrected
##        2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
##        2.3 (29-Apr-2019) Added rIcons auxiliar library and support for it, multiple controls reviewed
##                          Refactor all controls drawing mechanism to use control state
##        2.2 (05-Feb-2019) Added GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
##        2.1 (26-Dec-2018) Redesign of GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
##                          Complete redesign of style system (breaking change)
##        2.0 (08-Nov-2018) Support controls guiLock and custom fonts, reviewed GuiComboBox(), GuiListView()...
##        1.9 (09-Oct-2018) Controls review: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
##        1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
##        1.5 (21-Jun-2017) Working in an improved styles system
##        1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
##        1.3 (12-Jun-2017) Redesigned styles system
##        1.1 (01-Jun-2017) Complete review of the library
##        1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
##        0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
##        0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
##
##    CONTRIBUTORS:
##        Ramon Santamaria:   Supervision, review, redesign, update and maintenance...
##        Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
##        Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
##        Adria Arranz:       Testing and Implementation of additional controls (2018)
##        Jordi Jorba:        Testing and Implementation of additional controls (2018)
##        Albert Martos:      Review and testing of the library (2015)
##        Ian Eito:           Review and testing of the library (2015)
##        Kevin Gato:         Initial implementation of basic components (2014)
##        Daniel Nicolas:     Initial implementation of basic components (2014)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2014-2020 Ramon Santamaria (@raysan5)
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
  RAYGUI_VERSION* = "2.6-dev"

##  Define functions scope to be used internally (static) or externally (extern) to the module including this file
##  Allow custom memory allocators
## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------

const
  NUM_CONTROLS* = 16
  NUM_PROPS_DEFAULT* = 16
  NUM_PROPS_EXTENDED* = 8
  TEXTEDIT_CURSOR_BLINK_FRAMES* = 20

## ----------------------------------------------------------------------------------
##  Types and Structures Definition
##  NOTE: Some types are required for RAYGUI_STANDALONE usage
## ----------------------------------------------------------------------------------
##  Style property

type
  StyleProp* {.bycopy.} = object
    controlId*: uint16
    propertyId*: uint16
    propertyValue*: int32


##  Gui control state

type
  ControlState* {.size: sizeof(int32), pure.} = enum
    STATE_NORMAL = 0, STATE_FOCUSED, STATE_PRESSED, STATE_DISABLED


##  Gui control text alignment

type
  TextAlignment* {.size: sizeof(int32), pure.} = enum
    TEXT_ALIGN_LEFT = 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT


##  Gui controls

type
  Control* {.size: sizeof(int32), pure.} = enum
    DEFAULT = 0, LABEL,          ##  LABELBUTTON
    BUTTON,                   ##  IMAGEBUTTON
    TOGGLE,                   ##  TOGGLEGROUP
    SLIDER,                   ##  SLIDERBAR
    PROGRESSBAR, CHECKBOX, COMBOBOX, DROPDOWNBOX, TEXTBOX, ##  TEXTBOXMULTI
    VALUEBOX, SPINNER, LISTVIEW, COLORPICKER, SCROLLBAR, STATUSBAR


##  Gui base properties for every control

type
  ControlProperty* {.size: sizeof(int32), pure.} = enum
    BORDER_COLOR_NORMAL = 0, BASE_COLOR_NORMAL, TEXT_COLOR_NORMAL,
    BORDER_COLOR_FOCUSED, BASE_COLOR_FOCUSED, TEXT_COLOR_FOCUSED,
    BORDER_COLOR_PRESSED, BASE_COLOR_PRESSED, TEXT_COLOR_PRESSED,
    BORDER_COLOR_DISABLED, BASE_COLOR_DISABLED, TEXT_COLOR_DISABLED, BORDER_WIDTH,
    TEXT_PADDING, TEXT_ALIGNMENT, RESERVED


##  Gui extended properties depend on control
##  NOTE: We reserve a fixed size of additional properties per control
##  DEFAULT properties

type
  DefaultProperty* {.size: sizeof(int32), pure.} = enum
    TEXT_SIZE = 16, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR


##  Label
## typedef enum { } GuiLabelProperty;
##  Button
## typedef enum { } GuiButtonProperty;
##  Toggle / ToggleGroup

type
  ToggleProperty* {.size: sizeof(int32), pure.} = enum
    GROUP_PADDING = 16


##  Slider / SliderBar

type
  SliderProperty* {.size: sizeof(int32), pure.} = enum
    SLIDER_WIDTH = 16, SLIDER_PADDING


##  ProgressBar

type
  ProgressBarProperty* {.size: sizeof(int32), pure.} = enum
    PROGRESS_PADDING = 16


##  CheckBox

type
  CheckBoxProperty* {.size: sizeof(int32), pure.} = enum
    CHECK_PADDING = 16


##  ComboBox

type
  ComboBoxProperty* {.size: sizeof(int32), pure.} = enum
    COMBO_BUTTON_WIDTH = 16, COMBO_BUTTON_PADDING


##  DropdownBox

type
  DropdownBoxProperty* {.size: sizeof(int32), pure.} = enum
    ARROW_PADDING = 16, DROPDOWN_ITEMS_PADDING


##  TextBox / TextBoxMulti / ValueBox / Spinner

type
  TextBoxProperty* {.size: sizeof(int32), pure.} = enum
    TEXT_INNER_PADDING = 16, TEXT_LINES_PADDING, COLOR_SELECTED_FG, COLOR_SELECTED_BG


##  Spinner

type
  SpinnerProperty* {.size: sizeof(int32), pure.} = enum
    SPIN_BUTTON_WIDTH = 16, SPIN_BUTTON_PADDING


##  ScrollBar

type
  ScrollBarProperty* {.size: sizeof(int32), pure.} = enum
    ARROWS_SIZE = 16, ARROWS_VISIBLE, SCROLL_SLIDER_PADDING, SCROLL_SLIDER_SIZE,
    SCROLL_PADDING, SCROLL_SPEED


##  ScrollBar side

type
  ScrollBarSide* {.size: sizeof(int32), pure.} = enum
    SCROLLBAR_LEFT_SIDE = 0, SCROLLBAR_RIGHT_SIDE


##  ListView

type
  ListViewProperty* {.size: sizeof(int32), pure.} = enum
    LIST_ITEMS_HEIGHT = 16, LIST_ITEMS_PADDING, SCROLLBAR_WIDTH, SCROLLBAR_SIDE


##  ColorPicker

type
  ColorPickerProperty* {.size: sizeof(int32), pure.} = enum
    COLOR_SELECTOR_SIZE = 16, HUEBAR_WIDTH, ##  Right hue bar width
    HUEBAR_PADDING,           ##  Right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT,   ##  Right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW  ##  Right hue bar selector overflow


## ----------------------------------------------------------------------------------
##  Global Variables Definition
## ----------------------------------------------------------------------------------
##  ...
## ----------------------------------------------------------------------------------
##  Module Functions Declaration
## ----------------------------------------------------------------------------------
##  State modification functions

proc enable*() {.cdecl, importc: "GuiEnable", dynlib: rayguidll.}
##  Enable gui controls (global state)

proc disable*() {.cdecl, importc: "GuiDisable", dynlib: rayguidll.}
##  Disable gui controls (global state)

proc lock*() {.cdecl, importc: "GuiLock", dynlib: rayguidll.}
##  Lock gui controls (global state)

proc unlock*() {.cdecl, importc: "GuiUnlock", dynlib: rayguidll.}
##  Unlock gui controls (global state)

proc fade*(alpha: float32) {.cdecl, importc: "GuiFade", dynlib: rayguidll.}
##  Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f

proc setState*(state: int32) {.cdecl, importc: "GuiSetState", dynlib: rayguidll.}
##  Set gui state (global state)

proc getState*(): int32 {.cdecl, importc: "GuiGetState", dynlib: rayguidll.}
##  Get gui state (global state)
##  Font set/get functions

proc setFont*(font: Font) {.cdecl, importc: "GuiSetFont", dynlib: rayguidll.}
##  Set gui custom font (global state)

proc getFont*(): Font {.cdecl, importc: "GuiGetFont", dynlib: rayguidll.}
##  Get gui custom font (global state)
##  Style set/get functions

proc setStyle*(control: int32; property: int32; value: int32) {.cdecl,
    importc: "GuiSetStyle", dynlib: rayguidll.}
##  Set one style property

proc getStyle*(control: int32; property: int32): int32 {.cdecl, importc: "GuiGetStyle",
    dynlib: rayguidll.}
##  Get one style property
##  Tooltips set functions

proc enableTooltip*() {.cdecl, importc: "GuiEnableTooltip", dynlib: rayguidll.}
##  Enable gui tooltips

proc disableTooltip*() {.cdecl, importc: "GuiDisableTooltip", dynlib: rayguidll.}
##  Disable gui tooltips

proc setTooltip*(tooltip: cstring) {.cdecl, importc: "GuiSetTooltip",
                                  dynlib: rayguidll.}
##  Set current tooltip for display

proc clearTooltip*() {.cdecl, importc: "GuiClearTooltip", dynlib: rayguidll.}
##  Clear any tooltip registered
##  Container/separator controls, useful for controls organization

proc windowBox*(bounds: Rectangle; title: cstring): bool {.cdecl,
    importc: "GuiWindowBox", dynlib: rayguidll.}
##  Window Box control, shows a window that can be closed

proc groupBox*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiGroupBox",
    dynlib: rayguidll.}
##  Group Box control with text name

proc line*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiLine",
    dynlib: rayguidll.}
##  Line separator control, could contain text

proc panel*(bounds: Rectangle) {.cdecl, importc: "GuiPanel", dynlib: rayguidll.}
##  Panel control, useful to group controls

proc scrollPanel*(bounds: Rectangle; content: Rectangle; scroll: ptr Vector2): Rectangle {.
    cdecl, importc: "GuiScrollPanel", dynlib: rayguidll.}
##  Scroll Panel control
##  Basic controls set

proc label*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiLabel",
    dynlib: rayguidll.}
##  Label control, shows text

proc button*(bounds: Rectangle; text: cstring): bool {.cdecl, importc: "GuiButton",
    dynlib: rayguidll.}
##  Button control, returns true when clicked

proc labelButton*(bounds: Rectangle; text: cstring): bool {.cdecl,
    importc: "GuiLabelButton", dynlib: rayguidll.}
##  Label button control, show true when clicked

proc imageButton*(bounds: Rectangle; text: cstring; texture: Texture2D): bool {.cdecl,
    importc: "GuiImageButton", dynlib: rayguidll.}
##  Image button control, returns true when clicked

proc imageButtonEx*(bounds: Rectangle; text: cstring; texture: Texture2D;
                   texSource: Rectangle): bool {.cdecl, importc: "GuiImageButtonEx",
    dynlib: rayguidll.}
##  Image button extended control, returns true when clicked

proc toggle*(bounds: Rectangle; text: cstring; active: bool): bool {.cdecl,
    importc: "GuiToggle", dynlib: rayguidll.}
##  Toggle Button control, returns true when active

proc toggleGroup*(bounds: Rectangle; text: cstring; active: int32): int32 {.cdecl,
    importc: "GuiToggleGroup", dynlib: rayguidll.}
##  Toggle Group control, returns active toggle index

proc checkBox*(bounds: Rectangle; text: cstring; checked: bool): bool {.cdecl,
    importc: "GuiCheckBox", dynlib: rayguidll.}
##  Check Box control, returns true when active

proc comboBox*(bounds: Rectangle; text: cstring; active: int32): int32 {.cdecl,
    importc: "GuiComboBox", dynlib: rayguidll.}
##  Combo Box control, returns selected item index

proc dropdownBox*(bounds: Rectangle; text: cstring; active: ptr int32; editMode: bool): bool {.
    cdecl, importc: "GuiDropdownBox", dynlib: rayguidll.}
##  Dropdown Box control, returns selected item

proc spinner*(bounds: Rectangle; text: cstring; value: ptr int32; minValue: int32;
             maxValue: int32; editMode: bool): bool {.cdecl, importc: "GuiSpinner",
    dynlib: rayguidll.}
##  Spinner control, returns selected value

proc valueBox*(bounds: Rectangle; text: cstring; value: ptr int32; minValue: int32;
              maxValue: int32; editMode: bool): bool {.cdecl, importc: "GuiValueBox",
    dynlib: rayguidll.}
##  Value Box control, updates input text with numbers

proc textBox*(bounds: Rectangle; text: cstring; textSize: int32; editMode: bool): bool {.
    cdecl, importc: "GuiTextBox", dynlib: rayguidll.}
##  Text Box control, updates input text

proc textBoxMulti*(bounds: Rectangle; text: cstring; textSize: int32; editMode: bool): bool {.
    cdecl, importc: "GuiTextBoxMulti", dynlib: rayguidll.}
##  Text Box control with multiple lines

proc slider*(bounds: Rectangle; textLeft: cstring; textRight: cstring; value: float32;
            minValue: float32; maxValue: float32): float32 {.cdecl, importc: "GuiSlider",
    dynlib: rayguidll.}
##  Slider control, returns selected value

proc sliderBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
               value: float32; minValue: float32; maxValue: float32): float32 {.cdecl,
    importc: "GuiSliderBar", dynlib: rayguidll.}
##  Slider Bar control, returns selected value

proc progressBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
                 value: float32; minValue: float32; maxValue: float32): float32 {.cdecl,
    importc: "GuiProgressBar", dynlib: rayguidll.}
##  Progress Bar control, shows current progress value

proc statusBar*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiStatusBar",
    dynlib: rayguidll.}
##  Status Bar control, shows info text

proc dummyRec*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiDummyRec",
    dynlib: rayguidll.}
##  Dummy control for placeholders

proc scrollBar*(bounds: Rectangle; value: int32; minValue: int32; maxValue: int32): int32 {.
    cdecl, importc: "GuiScrollBar", dynlib: rayguidll.}
##  Scroll Bar control

proc grid*(bounds: Rectangle; spacing: float32; subdivs: int32): Vector2 {.cdecl,
    importc: "GuiGrid", dynlib: rayguidll.}
##  Grid control
##  Advance controls set

proc listView*(bounds: Rectangle; text: cstring; scrollIndex: ptr int32; active: int32): int32 {.
    cdecl, importc: "GuiListView", dynlib: rayguidll.}
##  List View control, returns selected list item index

proc listViewEx*(bounds: Rectangle; text: cstringArray; count: int32; focus: ptr int32;
                scrollIndex: ptr int32; active: int32): int32 {.cdecl,
    importc: "GuiListViewEx", dynlib: rayguidll.}
##  List View with extended parameters

proc messageBox*(bounds: Rectangle; title: cstring; message: cstring; buttons: cstring): int32 {.
    cdecl, importc: "GuiMessageBox", dynlib: rayguidll.}
##  Message Box control, displays a message

proc textInputBox*(bounds: Rectangle; title: cstring; message: cstring;
                  buttons: cstring; text: cstring): int32 {.cdecl,
    importc: "GuiTextInputBox", dynlib: rayguidll.}
##  Text Input Box control, ask for text

proc colorPicker*(bounds: Rectangle; color: Color): Color {.cdecl,
    importc: "GuiColorPicker", dynlib: rayguidll.}
##  Color Picker control (multiple color controls)

proc colorPanel*(bounds: Rectangle; color: Color): Color {.cdecl,
    importc: "GuiColorPanel", dynlib: rayguidll.}
##  Color Panel control

proc colorBarAlpha*(bounds: Rectangle; alpha: float32): float32 {.cdecl,
    importc: "GuiColorBarAlpha", dynlib: rayguidll.}
##  Color Bar Alpha control

proc colorBarHue*(bounds: Rectangle; value: float32): float32 {.cdecl,
    importc: "GuiColorBarHue", dynlib: rayguidll.}
##  Color Bar Hue control
##  Styles loading functions

proc loadStyle*(fileName: cstring) {.cdecl, importc: "GuiLoadStyle", dynlib: rayguidll.}
##  Load style file (.rgs)

proc loadStyleDefault*() {.cdecl, importc: "GuiLoadStyleDefault", dynlib: rayguidll.}
##  Load style default over global style
##
## typedef GuiStyle (unsigned int *)
## RAYGUIDEF GuiStyle LoadGuiStyle(const char *fileName);          // Load style from file (.rgs)
## RAYGUIDEF void UnloadGuiStyle(GuiStyle style);                  // Unload style
##

proc iconText*(iconId: int32; text: cstring): cstring {.cdecl, importc: "GuiIconText",
    dynlib: rayguidll.}
##  Get text with icon id prepended (if supported)

when defined(raygui_Support_Icons):
  ##  Gui icons functionality
  proc drawIcon*(iconId: int32; position: Vector2; pixelSize: int32; color: Color) {.cdecl,
      importc: "GuiDrawIcon", dynlib: rayguidll.}
  proc getIcons*(): ptr uint32 {.cdecl, importc: "GuiGetIcons", dynlib: rayguidll.}
  ##  Get full icons data pointer
  proc getIconData*(iconId: int32): ptr uint32 {.cdecl, importc: "GuiGetIconData",
      dynlib: rayguidll.}
  ##  Get icon bit data
  proc setIconData*(iconId: int32; data: ptr uint32) {.cdecl, importc: "GuiSetIconData",
      dynlib: rayguidll.}
  ##  Set icon bit data
  proc setIconPixel*(iconId: int32; x: int32; y: int32) {.cdecl,
      importc: "GuiSetIconPixel", dynlib: rayguidll.}
  ##  Set icon pixel value
  proc clearIconPixel*(iconId: int32; x: int32; y: int32) {.cdecl,
      importc: "GuiClearIconPixel", dynlib: rayguidll.}
  ##  Clear icon pixel value
  proc checkIconPixel*(iconId: int32; x: int32; y: int32): bool {.cdecl,
      importc: "GuiCheckIconPixel", dynlib: rayguidll.}
  ##  Check icon pixel value
converter ControlStateToInt32*(self: ControlState): int32 = self.int32
converter TextAlignmentToInt32*(self: TextAlignment): int32 = self.int32
converter ControlToInt32*(self: Control): int32 = self.int32
converter ControlPropertyToInt32*(self: ControlProperty): int32 = self.int32
converter DefaultPropertyToInt32*(self: DefaultProperty): int32 = self.int32
converter TogglePropertyToInt32*(self: ToggleProperty): int32 = self.int32
converter SliderPropertyToInt32*(self: SliderProperty): int32 = self.int32
converter ProgressBarPropertyToInt32*(self: ProgressBarProperty): int32 = self.int32
converter CheckBoxPropertyToInt32*(self: CheckBoxProperty): int32 = self.int32
converter ComboBoxPropertyToInt32*(self: ComboBoxProperty): int32 = self.int32
converter DropdownBoxPropertyToInt32*(self: DropdownBoxProperty): int32 = self.int32
converter TextBoxPropertyToInt32*(self: TextBoxProperty): int32 = self.int32
converter SpinnerPropertyToInt32*(self: SpinnerProperty): int32 = self.int32
converter ScrollBarPropertyToInt32*(self: ScrollBarProperty): int32 = self.int32
converter ScrollBarSideToInt32*(self: ScrollBarSide): int32 = self.int32
converter ListViewPropertyToInt32*(self: ListViewProperty): int32 = self.int32
converter ColorPickerPropertyToInt32*(self: ColorPickerProperty): int32 = self.int32

