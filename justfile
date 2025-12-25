# This build functionality does not strictly support windows. To support full functionality please use wsl.

set dotenv-load
set export

set shell := ["bash", "-c"]

# Source code and output file
src := "./src/main.c"
output := "./out/main"

# Flags that is included at different compilation commands
libs := ""
common_flags := "-Wall -Wextra -pedantic"
debug_flags := f"-g"
release_flags := f"-Werror=unused"


# Alias for 'debug'
[group("debug")]
default: debug

# Build the program for debug
[group("debug")]
debug:
  ccache clang  $common_flags $debug_flags -o $output $src $libs

# Build for debug and then run it
[group("debug")]
run: debug
  $output

# Build for release
[group("release")]
release:
  ccache clang  $common_flags $release_flags -o $output $src $libs

# Generate compile_commands.json
[group("tooling"), linux]
database:
  bear -- just debug
