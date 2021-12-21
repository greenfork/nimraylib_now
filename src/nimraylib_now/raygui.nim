import raylib

from os import parentDir, `/`
const rayguiHeader = currentSourcePath().parentDir()/"raygui.h"
{.passC: "-DRAYGUI_IMPLEMENTATION".}
## ******************************************************************************************
##
##    raygui v3.0 - A simple and easy-to-use immediate-mode gui library
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
##
##    GUI STYLE (guiStyle):
##
##    raygui uses a global data array for all gui style properties (allocated on data segment by default),
##    when a new style is loaded, it is loaded over the global style... but a default gui style could always be
##    recovered with GuiLoadStyleDefault() function, that overwrites the current style to the default one
##
##    The global style array size is fixed and depends on the number of controls and properties:
##
##        static unsigned int guiStyle[RAYGUI_MAX_CONTROLS*(RAYGUI_MAX_PROPS_BASE + RAYGUI_MAX_PROPS_EXTENDED)];
##
##    guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
##
##    Note that the first set of BASE properties (by default guiStyle[0..15]) belong to the generic style
##    used for all controls, when any of those base values is set, it is automatically populated to all
##    controls, so, specific control values overwriting generic style should be set after base values.
##
##    After the first BASE set we have the EXTENDED properties (by default guiStyle[16..23]), those
##    properties are actually common to all controls and can not be overwritten individually (like BASE ones)
##    Some of those properties are: TEXT_SIZE, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR
##
##    Custom control properties can be defined using the EXTENDED properties for each independent control.
##
##    TOOL: rGuiStyler is a visual tool to customize raygui style.
##
##
##    GUI ICONS (guiIcons):
##
##    raygui could use a global array containing icons data (allocated on data segment by default),
##    a custom icons set could be loaded over this array using GuiLoadIcons(), but loaded icons set
##    must be same RICON_SIZE and no more than RICON_MAX_ICONS will be loaded
##
##    Every icon is codified in binary form, using 1 bit per pixel, so, every 16x16 icon
##    requires 8 integers (16*16/32) to be stored in memory.
##
##    When the icon is draw, actually one quad per pixel is drawn if the bit for that pixel is set.
##
##    The global icons array size is fixed and depends on the number of icons and size:
##
##        static unsigned int guiIcons[RICON_MAX_ICONS*RICON_DATA_ELEMENTS];
##
##    guiIcons size is by default: 256*(16*16/32) = 2048*4 = 8192 bytes = 8 KB
##
##    TOOL: rGuiIcons is a visual tool to customize raygui icons.
##
##
##    CONFIGURATION:
##
##    #define RAYGUI_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RAYGUI_STANDALONE
##        Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
##        internally in the library and input management and drawing functions must be provided by
##        the user (check library implementation for further details).
##
##    #define RAYGUI_NO_RICONS
##        Avoid including embedded ricons data (256 icons, 16x16 pixels, 1-bit per pixel, 2KB)
##
##    #define RAYGUI_CUSTOM_RICONS
##        Includes custom ricons.h header defining a set of custom icons,
##        this file can be generated using rGuiIcons tool
##
##
##    VERSIONS HISTORY:
##
##        3.0 (xx-Sep-2021) Integrated ricons data to avoid external file
##                          REDESIGNED: GuiTextBoxMulti()
##                          REMOVED: GuiImageButton*()
##                          Multiple minor tweaks and bugs corrected
##        2.9 (17-Mar-2021) REMOVED: Tooltip API
##        2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
##        2.7 (20-Feb-2020) ADDED: Possible tooltips API
##        2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
##                          REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
##                          REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
##                          Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
##                          ADDED: 8 new custom styles ready to use
##                          Multiple minor tweaks and bugs corrected
##        2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
##        2.3 (29-Apr-2019) ADDED: rIcons auxiliar library and support for it, multiple controls reviewed
##                          Refactor all controls drawing mechanism to use control state
##        2.2 (05-Feb-2019) ADDED: GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
##        2.1 (26-Dec-2018) REDESIGNED: GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
##                          REDESIGNED: Style system (breaking change)
##        2.0 (08-Nov-2018) ADDED: Support controls guiLock and custom fonts
##                          REVIEWED: GuiComboBox(), GuiListView()...
##        1.9 (09-Oct-2018) REVIEWED: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
##        1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
##        1.5 (21-Jun-2017) Working in an improved styles system
##        1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
##        1.3 (12-Jun-2017) Complete redesign of style system
##        1.1 (01-Jun-2017) Complete review of the library
##        1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
##        0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
##        0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
##
##
##    CONTRIBUTORS:
##
##        Ramon Santamaria:   Supervision, review, redesign, update and maintenance
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

const
  RAYGUI_VERSION* = "3.0"

##  Function specifiers in case library is build/used as a shared library (Windows)
##  NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
##  Function specifiers definition
## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Allow custom memory allocators
##  TODO: Implement custom TraceLog()
## ----------------------------------------------------------------------------------
##  Types and Structures Definition
##  NOTE: Some types are required for RAYGUI_STANDALONE usage
## ----------------------------------------------------------------------------------
##  Style property

type
  StyleProp* {.importc: "GuiStyleProp", header: rayguiHeader, bycopy.} = object
    controlId* {.importc: "controlId".}: cushort
    propertyId* {.importc: "propertyId".}: cushort
    propertyValue* {.importc: "propertyValue".}: cint


##  Gui control state

type
  ControlState* {.size: sizeof(cint), pure.} = enum
    STATE_NORMAL = 0, STATE_FOCUSED, STATE_PRESSED, STATE_DISABLED


##  Gui control text alignment

type
  TextAlignment* {.size: sizeof(cint), pure.} = enum
    TEXT_ALIGN_LEFT = 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT


##  Gui controls

type
  Control* {.size: sizeof(cint), pure.} = enum
    DEFAULT = 0,                ##  Generic control -> populates to all controls when set
    LABEL,                    ##  Used also for: LABELBUTTON
    BUTTON, TOGGLE,            ##  Used also for: TOGGLEGROUP
    SLIDER,                   ##  Used also for: SLIDERBAR
    PROGRESSBAR, CHECKBOX, COMBOBOX, DROPDOWNBOX, TEXTBOX, ##  Used also for: TEXTBOXMULTI
    VALUEBOX, SPINNER, LISTVIEW, COLORPICKER, SCROLLBAR, STATUSBAR


##  Gui base properties for every control
##  NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)

type
  ControlProperty* {.size: sizeof(cint), pure.} = enum
    BORDER_COLOR_NORMAL = 0, BASE_COLOR_NORMAL, TEXT_COLOR_NORMAL,
    BORDER_COLOR_FOCUSED, BASE_COLOR_FOCUSED, TEXT_COLOR_FOCUSED,
    BORDER_COLOR_PRESSED, BASE_COLOR_PRESSED, TEXT_COLOR_PRESSED,
    BORDER_COLOR_DISABLED, BASE_COLOR_DISABLED, TEXT_COLOR_DISABLED, BORDER_WIDTH,
    TEXT_PADDING, TEXT_ALIGNMENT, RESERVED


##  Gui extended properties depend on control
##  NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default 8 properties)
##  DEFAULT extended properties
##  NOTE: Those properties are actually common to all controls

type
  DefaultProperty* {.size: sizeof(cint), pure.} = enum
    TEXT_SIZE = 16, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR


##  Label
## typedef enum { } GuiLabelProperty;
##  Button
## typedef enum { } GuiButtonProperty;
##  Toggle/ToggleGroup

type
  ToggleProperty* {.size: sizeof(cint), pure.} = enum
    GROUP_PADDING = 16


##  Slider/SliderBar

type
  SliderProperty* {.size: sizeof(cint), pure.} = enum
    SLIDER_WIDTH = 16, SLIDER_PADDING


##  ProgressBar

type
  ProgressBarProperty* {.size: sizeof(cint), pure.} = enum
    PROGRESS_PADDING = 16


##  CheckBox

type
  CheckBoxProperty* {.size: sizeof(cint), pure.} = enum
    CHECK_PADDING = 16


##  ComboBox

type
  ComboBoxProperty* {.size: sizeof(cint), pure.} = enum
    COMBO_BUTTON_WIDTH = 16, COMBO_BUTTON_PADDING


##  DropdownBox

type
  DropdownBoxProperty* {.size: sizeof(cint), pure.} = enum
    ARROW_PADDING = 16, DROPDOWN_ITEMS_PADDING


##  TextBox/TextBoxMulti/ValueBox/Spinner

type
  TextBoxProperty* {.size: sizeof(cint), pure.} = enum
    TEXT_INNER_PADDING = 16, TEXT_LINES_PADDING, COLOR_SELECTED_FG, COLOR_SELECTED_BG


##  Spinner

type
  SpinnerProperty* {.size: sizeof(cint), pure.} = enum
    SPIN_BUTTON_WIDTH = 16, SPIN_BUTTON_PADDING


##  ScrollBar

type
  ScrollBarProperty* {.size: sizeof(cint), pure.} = enum
    ARROWS_SIZE = 16, ARROWS_VISIBLE, SCROLL_SLIDER_PADDING, SCROLL_SLIDER_SIZE,
    SCROLL_PADDING, SCROLL_SPEED


##  ScrollBar side

type
  ScrollBarSide* {.size: sizeof(cint), pure.} = enum
    SCROLLBAR_LEFT_SIDE = 0, SCROLLBAR_RIGHT_SIDE


##  ListView

type
  ListViewProperty* {.size: sizeof(cint), pure.} = enum
    LIST_ITEMS_HEIGHT = 16, LIST_ITEMS_PADDING, SCROLLBAR_WIDTH, SCROLLBAR_SIDE


##  ColorPicker

type
  ColorPickerProperty* {.size: sizeof(cint), pure.} = enum
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
##  Global gui state control functions

proc enable*() {.cdecl, importc: "GuiEnable", header: rayguiHeader.}
##  Enable gui controls (global state)

proc disable*() {.cdecl, importc: "GuiDisable", header: rayguiHeader.}
##  Disable gui controls (global state)

proc lock*() {.cdecl, importc: "GuiLock", header: rayguiHeader.}
##  Lock gui controls (global state)

proc unlock*() {.cdecl, importc: "GuiUnlock", header: rayguiHeader.}
##  Unlock gui controls (global state)

proc isLocked*(): bool {.cdecl, importc: "GuiIsLocked", header: rayguiHeader.}
##  Check if gui is locked (global state)

proc fade*(alpha: cfloat) {.cdecl, importc: "GuiFade", header: rayguiHeader.}
##  Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f

proc setState*(state: cint) {.cdecl, importc: "GuiSetState", header: rayguiHeader.}
##  Set gui state (global state)

proc getState*(): cint {.cdecl, importc: "GuiGetState", header: rayguiHeader.}
##  Get gui state (global state)
##  Font set/get functions

proc setFont*(font: Font) {.cdecl, importc: "GuiSetFont", header: rayguiHeader.}
##  Set gui custom font (global state)

proc getFont*(): Font {.cdecl, importc: "GuiGetFont", header: rayguiHeader.}
##  Get gui custom font (global state)
##  Style set/get functions

proc setStyle*(control: cint; property: cint; value: cint) {.cdecl,
    importc: "GuiSetStyle", header: rayguiHeader.}
##  Set one style property

proc getStyle*(control: cint; property: cint): cint {.cdecl, importc: "GuiGetStyle",
    header: rayguiHeader.}
##  Get one style property
##  Container/separator controls, useful for controls organization

proc windowBox*(bounds: Rectangle; title: cstring): bool {.cdecl,
    importc: "GuiWindowBox", header: rayguiHeader.}
##  Window Box control, shows a window that can be closed

proc groupBox*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiGroupBox",
    header: rayguiHeader.}
##  Group Box control with text name

proc line*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiLine",
    header: rayguiHeader.}
##  Line separator control, could contain text

proc panel*(bounds: Rectangle) {.cdecl, importc: "GuiPanel", header: rayguiHeader.}
##  Panel control, useful to group controls

proc scrollPanel*(bounds: Rectangle; content: Rectangle; scroll: ptr Vector2): Rectangle {.
    cdecl, importc: "GuiScrollPanel", header: rayguiHeader.}
##  Scroll Panel control
##  Basic controls set

proc label*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiLabel",
    header: rayguiHeader.}
##  Label control, shows text

proc button*(bounds: Rectangle; text: cstring): bool {.cdecl, importc: "GuiButton",
    header: rayguiHeader.}
##  Button control, returns true when clicked

proc labelButton*(bounds: Rectangle; text: cstring): bool {.cdecl,
    importc: "GuiLabelButton", header: rayguiHeader.}
##  Label button control, show true when clicked

proc toggle*(bounds: Rectangle; text: cstring; active: bool): bool {.cdecl,
    importc: "GuiToggle", header: rayguiHeader.}
##  Toggle Button control, returns true when active

proc toggleGroup*(bounds: Rectangle; text: cstring; active: cint): cint {.cdecl,
    importc: "GuiToggleGroup", header: rayguiHeader.}
##  Toggle Group control, returns active toggle index

proc checkBox*(bounds: Rectangle; text: cstring; checked: bool): bool {.cdecl,
    importc: "GuiCheckBox", header: rayguiHeader.}
##  Check Box control, returns true when active

proc comboBox*(bounds: Rectangle; text: cstring; active: cint): cint {.cdecl,
    importc: "GuiComboBox", header: rayguiHeader.}
##  Combo Box control, returns selected item index

proc dropdownBox*(bounds: Rectangle; text: cstring; active: ptr cint; editMode: bool): bool {.
    cdecl, importc: "GuiDropdownBox", header: rayguiHeader.}
##  Dropdown Box control, returns selected item

proc spinner*(bounds: Rectangle; text: cstring; value: ptr cint; minValue: cint;
             maxValue: cint; editMode: bool): bool {.cdecl, importc: "GuiSpinner",
    header: rayguiHeader.}
##  Spinner control, returns selected value

proc valueBox*(bounds: Rectangle; text: cstring; value: ptr cint; minValue: cint;
              maxValue: cint; editMode: bool): bool {.cdecl, importc: "GuiValueBox",
    header: rayguiHeader.}
##  Value Box control, updates input text with numbers

proc textBox*(bounds: Rectangle; text: cstring; textSize: cint; editMode: bool): bool {.
    cdecl, importc: "GuiTextBox", header: rayguiHeader.}
##  Text Box control, updates input text

proc textBoxMulti*(bounds: Rectangle; text: cstring; textSize: cint; editMode: bool): bool {.
    cdecl, importc: "GuiTextBoxMulti", header: rayguiHeader.}
##  Text Box control with multiple lines

proc slider*(bounds: Rectangle; textLeft: cstring; textRight: cstring; value: cfloat;
            minValue: cfloat; maxValue: cfloat): cfloat {.cdecl, importc: "GuiSlider",
    header: rayguiHeader.}
##  Slider control, returns selected value

proc sliderBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
               value: cfloat; minValue: cfloat; maxValue: cfloat): cfloat {.cdecl,
    importc: "GuiSliderBar", header: rayguiHeader.}
##  Slider Bar control, returns selected value

proc progressBar*(bounds: Rectangle; textLeft: cstring; textRight: cstring;
                 value: cfloat; minValue: cfloat; maxValue: cfloat): cfloat {.cdecl,
    importc: "GuiProgressBar", header: rayguiHeader.}
##  Progress Bar control, shows current progress value

proc statusBar*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiStatusBar",
    header: rayguiHeader.}
##  Status Bar control, shows info text

proc dummyRec*(bounds: Rectangle; text: cstring) {.cdecl, importc: "GuiDummyRec",
    header: rayguiHeader.}
##  Dummy control for placeholders

proc scrollBar*(bounds: Rectangle; value: cint; minValue: cint; maxValue: cint): cint {.
    cdecl, importc: "GuiScrollBar", header: rayguiHeader.}
##  Scroll Bar control

proc grid*(bounds: Rectangle; spacing: cfloat; subdivs: cint): Vector2 {.cdecl,
    importc: "GuiGrid", header: rayguiHeader.}
##  Grid control
##  Advance controls set

proc listView*(bounds: Rectangle; text: cstring; scrollIndex: ptr cint; active: cint): cint {.
    cdecl, importc: "GuiListView", header: rayguiHeader.}
##  List View control, returns selected list item index

proc listViewEx*(bounds: Rectangle; text: cstringArray; count: cint; focus: ptr cint;
                scrollIndex: ptr cint; active: cint): cint {.cdecl,
    importc: "GuiListViewEx", header: rayguiHeader.}
##  List View with extended parameters

proc messageBox*(bounds: Rectangle; title: cstring; message: cstring; buttons: cstring): cint {.
    cdecl, importc: "GuiMessageBox", header: rayguiHeader.}
##  Message Box control, displays a message

proc textInputBox*(bounds: Rectangle; title: cstring; message: cstring;
                  buttons: cstring; text: cstring): cint {.cdecl,
    importc: "GuiTextInputBox", header: rayguiHeader.}
##  Text Input Box control, ask for text

proc colorPicker*(bounds: Rectangle; color: Color): Color {.cdecl,
    importc: "GuiColorPicker", header: rayguiHeader.}
##  Color Picker control (multiple color controls)

proc colorPanel*(bounds: Rectangle; color: Color): Color {.cdecl,
    importc: "GuiColorPanel", header: rayguiHeader.}
##  Color Panel control

proc colorBarAlpha*(bounds: Rectangle; alpha: cfloat): cfloat {.cdecl,
    importc: "GuiColorBarAlpha", header: rayguiHeader.}
##  Color Bar Alpha control

proc colorBarHue*(bounds: Rectangle; value: cfloat): cfloat {.cdecl,
    importc: "GuiColorBarHue", header: rayguiHeader.}
##  Color Bar Hue control
##  Styles loading functions

proc loadStyle*(fileName: cstring) {.cdecl, importc: "GuiLoadStyle",
                                  header: rayguiHeader.}
##  Load style file over global style variable (.rgs)

proc loadStyleDefault*() {.cdecl, importc: "GuiLoadStyleDefault",
                         header: rayguiHeader.}
##  Load style default over global style
##
## typedef GuiStyle (unsigned int *)
## RAYGUIAPI GuiStyle LoadGuiStyle(const char *fileName);          // Load style from file (.rgs)
## RAYGUIAPI void UnloadGuiStyle(GuiStyle style);                  // Unload style
##

proc iconText*(iconId: cint; text: cstring): cstring {.cdecl, importc: "GuiIconText",
    header: rayguiHeader.}
##  Get text with icon id prepended (if supported)

