setup() {
  export REPO_ROOT="$BATS_TEST_DIRNAME/.."
  export SCRIPT="$REPO_ROOT/fps_fixer.bash"

  export TMPDIR_TEST="$(mktemp -d)"
  export FFMPEG_LOG_FILE="$TMPDIR_TEST/ffmpeg.log"
  export FFMPEG_FPS_MAP_FILE="$TMPDIR_TEST/fps-map.txt"

  export PATH="$BATS_TEST_DIRNAME/bin:$PATH"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

ffmpeg_command_path() {
  printf './%s\n' "$(realpath --relative-to "." "$1")"
}

ffmpeg_processing_call_count() {
  grep -F -- "-filter:v fps=" "$FFMPEG_LOG_FILE" | wc -l | tr -d " "
}

ffmpeg_acceleration_call_count() {
  grep -F -- "-filter_complex" "$FFMPEG_LOG_FILE" | wc -l | tr -d " "
}

test_file_group() {
  basename "$BATS_TEST_FILENAME" .bats
}
