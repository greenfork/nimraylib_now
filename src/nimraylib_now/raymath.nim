when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/raymath
else:
  import mangled/raymath

export raymath
