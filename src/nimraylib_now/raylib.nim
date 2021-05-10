when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/raylib
else:
  import mangled/raylib

export raylib
