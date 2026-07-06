setup() {
  export REPO_ROOT="$BATS_TEST_DIRNAME/.."
  export SCRIPT="$REPO_ROOT/fps_fixer.bash"

  export TMPDIR_TEST="$(mktemp -d)"
  export FFMPEG_LOG_FILE="$TMPDIR_TEST/ffmpeg.log"
  export FFMPEG_FAIL_MATCH_FILE="$TMPDIR_TEST/ffmpeg-fail-matches.txt"
  export FFPROBE_LOG_FILE="$TMPDIR_TEST/ffprobe.log"
  export FFPROBE_FAIL_MATCH_FILE="$TMPDIR_TEST/ffprobe-fail-matches.txt"
  export FFPROBE_FPS_MAP_FILE="$TMPDIR_TEST/fps-map.txt"
  export FFPROBE_AUDIO_MAP_FILE="$TMPDIR_TEST/audio-map.txt"

  export PATH="$BATS_TEST_DIRNAME/bin:$PATH"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

test_file_group() {
  basename "$BATS_TEST_FILENAME" .bats
}

relative_path() {
  printf './%s\n' "$(realpath --canonicalize-missing --relative-to "." "$1")"
}

ffmpeg_log_line_number() {
  grep -nF -- "$1" "$FFMPEG_LOG_FILE" | cut -d: -f1 | head -n1
}

file_line_count() {
  declare -r file="$1"
  declare -r pattern="$2"

  grep -F -- "$pattern" "$file" | wc -l | tr -d " "
}

ffmpeg_processing_call_count() {
  file_line_count "$FFMPEG_LOG_FILE" "-filter:v fps="
}

ffmpeg_acceleration_call_count() {
  file_line_count "$FFMPEG_LOG_FILE" "-filter_complex"
}

output_line_count() {
  declare -r pattern="$1"

  file_line_count <(printf '%s\n' "$output") "$pattern"
}
