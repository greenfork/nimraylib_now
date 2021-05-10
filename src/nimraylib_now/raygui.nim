when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/raygui
else:
  import mangled/raygui

export raygui
