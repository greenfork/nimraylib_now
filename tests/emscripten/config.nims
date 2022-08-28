--define:emscripten # Specify target

--os:linux # Emscripten pretends to be linux.
--cpu:wasm32 # Emscripten is 32bits.
--cc:clang # Emscripten is very close to clang, so we will replace it.
when defined(windows):
  --clang.exe:emcc.bat  # Replace C
  --clang.linkerexe:emcc.bat # Replace C linker
  --clang.cpp.exe:emcc.bat # Replace C++
  --clang.cpp.linkerexe:emcc.bat # Replace C++ linker.
else:
  --clang.exe:emcc  # Replace C
  --clang.linkerexe:emcc # Replace C linker
  --clang.cpp.exe:emcc # Replace C++
  --clang.cpp.linkerexe:emcc # Replace C++ linker.

--gc:orc # GC:orc is friendlier with crazy platforms.
--exceptions:goto # Goto exceptions are friendlier with crazy platforms.
--define:noSignalHandler # Emscripten doesn't support signal handlers.


