when defined(nimraylib_now_shared) or defined(nimraylib_now_linkingOverride):
  import not_mangled/physac
else:
  import mangled/physac

export physac
