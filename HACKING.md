# How wrapping works

`nimble convert` runs `src/mangle_names.nim` and `src/convert_c_to_nim.nim`
scripts and checks that the resulting files are valid Nim files.

There are 7 steps during conversion:

1. Get C source and header files
2. Mangle names in C source and header files
3. Copy mangled C files to release C files, next modifications on C files
   are kept just for build purposes
4. Modify C header files (preprocessing)
5. Run [c2nim] on modified C header files (processing)
6. Modify resulting Nim files (postprocessing)
7. Copy modified Nim files to release Nim files

[c2nim]: https://github.com/nim-lang/c2nim

Since every step is done automatically, updating to the next version should
be a comparatively easy task.

# What to run after changing this library

1. `nimble convert` - re-generates Nim files from C files
2. `nimble testExamples` - re-generates big test file and runs it
3. `nimble testIndividualExamples` - re-generates individual test files and runs them

# How to update this library

```shell
$ git clone --recurse-submodules --shallow-submodules https://github.com/greenfork/nimraylib_now
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble install c2nim
$ git checkout master
$ cat .gitmodules  # let's see which submodules might need updating
# For every submodule do the following; here we will only do it for "raylib"
$ cd raylib
$ git pull
$ git fetch --tags
$ git tag --list
# Here you can choose any desired version or just stay at latest master
$ git checkout 3.5.0
$ cd ..
$ nimble convert
$ git diff  # review changes
$ nimble testExamples  # make sure every example still compiles
# Edit nimraylib_now.nimble file and change version according to [semver]
# Assume that the edited version is now 1.2.0
$ git commit --all --verbose
$ git tag -a v1.2.0  # version 1.2.0 is from nimble file earlier
$ git push --all
$ git push --tags
```

[semver]: https://semver.org/

# Notes on updating
## Aliases of deprecated values

Look fore new `const` in generated Nim file, they are translated from C
`#define` and usually are for deprecated names. Some of these deprecated
names include enum values and can't be written in Nim because Nim uses
typed enums. In this case just add them to `ignoreDefines` array in converter
script. If desired, any not enum values can be equivalently translated from
C using `template`.

## Changed const/enum prefixes

When there's a diff related to the name changed across many enum values, it is
likely that their prefix was changed. Look for `#  prefix CAMERA_` declarations
used by `c2nim` in converter script and see if it needs to be changed,
for example to `#  prefix CAMERA_TYPE_`. The diff should help to guess what
was changed `git diff src/nimraylib_now/raylib.nim`.
