#!/usr/bin/env bats

load test_helper

@test "no-process does not create output directory" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/v.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/v.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ ! -d "$TMPDIR_TEST/in/fixed-videos" ]
}

@test "selected extension and base path are used for output path" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mov"

  declare -r fixed_videos_dir="$input_dir/out"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mov"

  mkdir -p "$input_dir"
  touch "$video"
  printf '%s|50\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --extension mov --base-path out "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "$fixed_video" "$FFMPEG_LOG_FILE"
}

@test "--force skips probe and processes all" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4"

  run "$SCRIPT" --force "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  ! grep -x -- "-i $TMPDIR_TEST/in/a.mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
}

@test "--no-audio uses -an and skips optional audio map in processing command" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mp4"

  mkdir -p "$input_dir"
  touch "$video"
  printf '%s|50\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-audio "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "-an" "$FFMPEG_LOG_FILE"
  grep -F -- "$fixed_video" "$FFMPEG_LOG_FILE"
}

@test "--speed-factor generates acceleration output" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/a.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --speed-factor 1.5 "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/in/fixed-videos/a.60_fps.1.5x.mp4" ]
  grep -F -- "atempo=1.5" "$FFMPEG_LOG_FILE"
}

@test "probe failure warns and continues" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/bad.mp4" "$TMPDIR_TEST/in/good.mp4"
  export FFMPEG_PROBE_FAIL_FOR="$TMPDIR_TEST/in/bad.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/good.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unable to extract FPS"* ]]
  [ -f "$TMPDIR_TEST/in/fixed-videos/good.60_fps.mp4" ]
}
