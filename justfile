# The aim of the build system is to be simple and thereby only support unix

set dotenv-load
set shell := ["bash", "-c"]

# Source code and output file
src := "./src/main.c"
output := "./out/main"

# Flags that is included at different compilation commands
cxx := "ccache clang"
libs := ""
common_flags := "-Wall -Wextra -pedantic"
debug_flags := f"-g"
release_flags := f"-Werror=unused -O3"


alias default := run

# Build for debug if the binary does not exist, then run it
[group("debug")]
run:
  @if [[ ! -x {{output}} ]]; then just debug; fi
  {{output}}

# Build the program for debug
[group("debug")]
debug: prepare
  {{cxx}} {{common_flags}} {{debug_flags}} -o {{output}} {{src}} {{libs}}

# Build for release
[group("release")]
release: prepare
  {{cxx}} {{common_flags}} {{release_flags}} -o {{output}} {{src}} {{libs}}

# Generate compile_commands.json
[group("tooling"), unix]
database: prepare
  bear -- {{cxx}} {{common_flags}} {{debug_flags}} -o {{output}} {{src}} {{libs}}

[private, parallel]
prepare: # mylib

# [private, working-directory: "lib/mylib"]
# mylib:
#   make static -j{{num_cpus()}}
