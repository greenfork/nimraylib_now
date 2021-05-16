# Contributing

Any ideas are welcome. Open an issue to ask a question or suggest an idea.

## Documentation

Any ideas on how to improve documentation are welcome!

## Convert examples

Code in examples strives to be as close to [NEP1] style guide as possible.

[NEP1]: https://nim-lang.org/docs/nep1.html

You can help by converting missing examples from original C library doing
the following:

1. Find a missing example in C, you can use a helper script for that:
   `nim r scripts/find_missing_examples.nim`.
2. Compile and run `nim r scripts/c2nim_example_converter.nim examplefile.c`
   on this C file, check out generated `examplefile.nim`, it should be very
   close to the desired file.
3. Edit resulting Nim file, make sure it runs `nim r examplefile.nim`.
4. Put this file into a correct category in the `examples` directory
   (`original` is for self-developed examples).
5. Run `nimble testExamples` and make sure that your example passes the test.
   If it doesn't pass the test, create an issue or ask me any other way, I will
   help.
6. Run `nim r make_individual_tests_from_examples.nim` to include this example
   in the test suite.

I cannot port a number of examples:
* `core_drop_files.c` - I can't test it on my machine (Wayland on Linux)
* `core_input_multitouch.c` - probably requires a phone to test it?
* `core_storage_values.c` - I can't compile the original C example, values
  are reset to 0,0 when I press Space
* `core_basic_window_web.c` - we have emscripten example with more information

## Work on converter script

If something is broken or you see an opportunity to improve the wrapper, you
can help with converter script. See [HACKING](HACKING.md).
