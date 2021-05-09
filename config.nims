when not defined(emscripten) and
     not defined(nimraylib_now_linkingOverride) and
     not defined(nimraylib_now_shared):
  --threads:on
