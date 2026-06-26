setup() {
  export REPO_ROOT="$BATS_TEST_DIRNAME/.."
  export SCRIPT="$REPO_ROOT/fps_fixer.bash"

  export TMPDIR_TEST="$(mktemp -d)"
  export FFMPEG_LOG_FILE="$TMPDIR_TEST/ffmpeg.log"
  export FFPROBE_LOG_FILE="$TMPDIR_TEST/ffprobe.log"
  export FFMPEG_FPS_MAP_FILE="$TMPDIR_TEST/fps-map.txt"
  export FFPROBE_AUDIO_MAP_FILE="$TMPDIR_TEST/audio-map.txt"

  export PATH="$BATS_TEST_DIRNAME/bin:$PATH"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

test_file_group() {
  basename "$BATS_TEST_FILENAME" .bats
}

ffmpeg_log_path() {
  printf './%s\n' "$(realpath --relative-to "." "$1")"
}

ffmpeg_log_line_number() {
  grep -nF -- "$1" "$FFMPEG_LOG_FILE" | cut -d: -f1 | head -n1
}

ffmpeg_processing_call_count() {
  grep -F -- "-filter:v fps=" "$FFMPEG_LOG_FILE" | wc -l | tr -d " "
}

ffmpeg_acceleration_call_count() {
  grep -F -- "-filter_complex" "$FFMPEG_LOG_FILE" | wc -l | tr -d " "
}


ffprobe_fps_probe_log_path() {
  printf '%s %s\n' \
    '-v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1' \
    "$1"
}
