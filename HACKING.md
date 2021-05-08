# How wrapping works

`nimble convert` runs `src/converter.nim` script and checks that the resulting
files are valid Nim files.

There are 4 steps during conversion:

1. Get C header files
2. Modify C header files (preprocessing)
3. Run [c2nim] on modified C header files (processing)
4. Modify resulting Nim files (postprocessing)

[c2nim]: https://github.com/nim-lang/c2nim

Since every step is done automatically, updating to the next version should
be a comparatively easy task.

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
```

[semver]: https://semver.org/
