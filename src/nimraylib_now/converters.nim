when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/converters
else:
  import mangled/converters

export converters
