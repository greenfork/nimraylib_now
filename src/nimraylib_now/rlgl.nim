when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/rlgl
else:
  import mangled/rlgl

export rlgl
