# The aim of the build system is to be simple and thereby only support unix

set dotenv-load
set shell := ["bash", "-uc"]

_check_err := if os_family() == "windows" {error("Windows not supported")} else {""}

# Output/Build directory
build_dir := "build"

# Source code and output file
src := prepend("src/", "main.c")
output := build_dir / "main"

std := "c17"

# Flags that is included at different compilation commands
cxx := "ccache clang"
libs := ""
common_flags := f"-std={{std}} -Wall -Wextra -pedantic"
debug_flags := f"-g"
release_flags := f"-Werror=unused -O3"

# This is for tests, super simple tests
test_dir := "test"
test_src := shell(f"ls {{test_dir}}/*.c 2>/dev/null || echo -n")

alias default := release

# Build for release
[group("release")]
release: prepare
  {{cxx}} {{common_flags}} {{release_flags}} -o {{output}} {{src}} {{libs}}

# Build the program for debug
[group("debug")]
debug: prepare
  {{cxx}} {{common_flags}} {{debug_flags}} -o {{output}} {{src}} {{libs}}

# Build for debug if the binary does not exist, then run it
[group("debug")]
run:
  {{output}}

# Generate compile_commands.json
[group("tooling"), unix]
database: prepare
  bear -- {{cxx}} {{common_flags}} {{debug_flags}} -o {{output}} {{src}} {{libs}}

# Build/Prepare the dependencies
[private, parallel]
prepare: # mylib

# [private, working-directory: "lib/mylib"]
# mylib:
#   make static -j{{num_cpus()}}

# Run all tests
test: prepare
  {{if test_src == "" {error("No tests found.")} else {""}}}
  -rm -r {{build_dir / "testing"}}
  mkdir -p {{build_dir / "testing"}}
  echo "{{test_src}}" | xargs -n 1 just compile_test

# Test a single file: Compile, link, and then run
[private]
compile_test input output=(build_dir / "testing" / encode_uri_component(without_extension(input))):
  {{cxx}} {{common_flags}} -o {{output}} {{input}} {{libs}}
  @just run_test {{output}} {{file_stem(input)}}

# This is for pretty-formatting the test-run
[private, unix]
run_test test_file test_name:
  #!/usr/bin/env -S bash
  echo -n "Running test '{{test_name}}' ... "
  output=$({{test_file}} 2>&1)
  if [ $? -eq 0 ]; then
    echo {{GREEN}}ok{{NORMAL}}
  else
    echo {{RED}}failed{{NORMAL}}
    echo "--- output"
    echo $output
    echo "--- end of output"
  fi

