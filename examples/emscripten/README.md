# Emscripten with NimraylibNow!

This is experimental support for Emscripten. Please report any bugs.

1. Follow an amazing treeform's guide [Nim Emscripten tutorial]. As of 2021-05-08
   only steps 0, 1 and 2 work, it is okay if 3 and 4 do not compile.
2. Compile [Raylib for Web]. You can use this library's C sources as they are
   included together with Nim sources. For example, on my machine they are in
   `/home/grfork/.nimble/pkgs/nimraylib_now-x.x.x/raylib/src`. I used Makefile
   to compile Raylib for Linux.
3. Compile the Nim source file in the example passing the library file
   compiled in step 2 via passL:
```
$ nim c -d:emscripten \
  --passL:"/home/grfork/reps/nimraylib_now/raylib/src/libraylib.a" \
  emscripten_crown.nim
```
4. Install and run `nimhttpd` server:
```
$ nimble install nimhttpd
$ nimhttpd
```
5. Open the output file in a browser http://localhost:1337/public/.

[Raylib for Web]: https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5)
[Nim Emscripten tutorial]: https://github.com/treeform/nim_emscripten_tutorial

## Tips and tricks

- Make sure to include `config.nims` in the same directory as your source file
  and edit it if needed.
- Replace `while not windowShouldClose():` used for native compilation
  with `emscriptenSetMainLoop` and a callback as in the example.
