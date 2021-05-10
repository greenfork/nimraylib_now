# Contributing

Any ideas are welcome. Open an issue to ask a question or suggest an idea.

## Documentation
Any ideas on how to improve documentation are welcome!

## Convert examples
You can help by converting missing examples from original C library doing
the following:

1. Find a missing example in C, you can use helper script for that:
   `nim r scripts/find_missing_examples.nim`.
2. Compile and run `scripts/c2nim_example_converter.nim` on this C file, it helps
   with conversion.
3. Edit resulting Nim file, make sure it runs.
4. Put this file into a correct category in `examples` (`original` is for
   self-developed examples).
5. Run `nimble testExamples` and make sure that your example passes the test.
   If it doesn't pass the test, create an issue or ask me any other way, I will
   help.

I cannot port a number of examples:
* `core_drop_files.c` - I can't test it on my machine (Wayland on Linux)
* `core_input_gamepad.c` - I don't have a gamepad
* `core_input_multitouch.c` - probably requires a phone to test it?
* `core_storage_values.c` - I can't compile the original C example, values
  are reset to 0,0 when I press Space
* `core_basic_window_web.c` - need emscripten dev tools

## Work on converter script
If something is broken or you see an opportunity to improve the wrapper, you
can help with converter script.

Clone and run tests:

```shell
$ git clone --recurse-submodules --shallow-submodules https://github.com/greenfork/nimraylib_now
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble install c2nim
$ nimble convert
$ nimble testExamples
```

Then workflow is as follows:
1. Change `src/converter.nim` file
2. Run `nimble convert` and see if you achieved desired changes
3. Run `nimble testExamples` to see that all examples are still compiled
