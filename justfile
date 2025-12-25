set export

# Entry point and executable
entry := "./src/main.c"
output := "./out/main"

# Flags that is included at different compilation commands
common_flags := "-Wall -Wextra -pedantic"
debug_flags := "-g"
release_flags := "-Werror=unused"
libs := ""


# Alias for 'debug'
default: debug

# Build the program for debug
debug:
  ccache clang $common_flags $debug_flags $libs -o $output $entry

# Build for debug and then run it
run: debug
  $output

# Build for release
release:
  ccache clang $common_flags $release_flags $libs -o $output $entry

# Generate compile_commands.json
database:
  bear -- clang $common_flags $debug_flags $libs -o $output $entry
