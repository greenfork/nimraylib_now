# Using Raylib
## How to use Raylib, the original C library?

You have 3 options:

1. Static library linking - this is the default setting, Raylib will be linked
   statically to your executable. This means that its code will be directly
   embedded into your game file.

2. Shared library linking - this is activated with `-d:nimraylib_now_shared`
   flag passed to the Nim compiler and it requires a present `libraylib.so` or
   similar file depending on your OS in your library load path. Shared linking
   means that all Raylib functionality is contained inside a separate file and
   several game files can all use this same shared Raylib file.
   This option is usually preferable for Linux.

3. Manual library linking - this is activated with `-d:nimraylib_now_linkingOverride`
   flag passed to the Nim compiler. This means that you build the Raylib
   library yourself and link it, for example with option `--passL:`. This is a
   preferable option for unsupported targets such as Android or Raspberry Pi.

## Install Raylib as a static library

You don't have to do anything here, this is the default option. Raylib C sources
are included in this library and compiled automatically.

## Install Raylib as a shared library
### Windows

It is recommended to use static linking.

Currently shared library linking is broken because of name conflicts with
`windows.h` file. But if you really want to, you can rename all conflicting
names inside `windows.h` and still use it as a shared library.

Download the latest library from [raylib releases] page for MinGW compiler, for version 3.7.0
the name is `raylib-3.7.0_win64_mingw-w64.zip`. Extract it and **make sure**
that files `libraylibdll.a` and `raylib.dll` are always in the same directory
as your game `.exe` file.

### Linux
Use your package manager, for example for Arch Linux:
```shell
$ sudo pacman -Syu raylib
```

Alternatively download the latest library from [raylib releases] page, for version 3.7.0
the name is `raylib-3.7.0_linux_amd64.tar.gz`. Extract it and put all `.so`
files into `/usr/local/lib`.

### MacOS
With brew package manager:
```shell
$ brew install raylib
```

Alternatively download the latest library from [raylib releases] page, for version 3.7.0
the name is `raylib-3.7.0_macos.tar.gz`. Extract it and put all `.dylib`
files into `/usr/local/lib`.

## Install Raylib manually

Consult [Raylib wiki] on how to build Raylib for different targets.

[Raylib wiki]: https://github.com/raysan5/raylib/wiki

## Exposed compilation flags

NimraylibNow! provides several **optional** flags for compilation:

| Compilation flag                   | Meaning                                                  |
| ---------------------------------  | ------------------------------------------------------   |
| `-d:nimraylib_now_shared`          | link with dynamic Raylib library, search in system paths |
| `-d:nimraylib_now_linkingOverride` | link with your own provided library via `--passL` flag   |
| `-d:nimraylib_now_wayland`         | use Wayland flags during static compilation              |


[raylib releases]: https://github.com/raysan5/raylib/releases
