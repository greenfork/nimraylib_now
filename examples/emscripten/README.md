# Emscripten with NimraylibNow!

This is experimental support for Emscripten. Please report any bugs.

1. Follow an amazing treeform's guide [Nim Emscripten tutorial]. As of 2021-05-08
   only steps 0, 1 and 2 work, it is okay if 3 and 4 do not compile.
2. Compile the Nim source file (`-d:release` for extra speed):
```
$ nim c -d:release -o:public/index.html emscripten_crown.nim
```
3. Install and run `nimhttpd` server:
```
$ nimble install nimhttpd
$ nimhttpd
```
4. Open the output file in a browser http://localhost:1337/public/.

[Nim Emscripten tutorial]: https://github.com/treeform/nim_emscripten_tutorial

## Tips and tricks

- Make sure to include `config.nims` in the same directory as your source file
  and edit it if needed.
- Replace `while not windowShouldClose():` used for native compilation
  with `emscriptenSetMainLoop` and a callback as in the example.
- Music may not play if the window is not in focus, click on the game window to
  make it focused.

## Compile options

### NimraylibNowTotalMemory

Use `NimraylibNowTotalMemory` define to override the memory size, the default is
134217728:
```
-d:NimraylibNowTotalMemory=64000
```

### nimraylib_now_web_resources and NimraylibNowWebResourcesPath

`config.nims` contains a `nimraylib_now_web_resources` define which includes
files under "resources" directory into the virtual file system so that
these files can be used inside your game, see [packaging](https://emscripten.org/docs/porting/files/packaging_files.html).

In order to disable it, remove `--define:nimraylib_now_web_resources` from your
config file.

In order to change the path to "assets", add `--define:NimraylibNowWebResourcesPath=assets`
to your config file.
