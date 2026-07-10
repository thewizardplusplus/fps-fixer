#!/usr/bin/env bats

load test_helper

@test "no-process does not create output directory" {
  mkdir -p -- "$TMPDIR_TEST/in"
  touch -- "$TMPDIR_TEST/in/v.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/v.mp4" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ ! -d "$TMPDIR_TEST/in/fixed-videos" ]
}

@test "selected extension and base path are used for output path" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mov"

  declare -r fixed_videos_dir="$input_dir/out"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mov"

  mkdir -p -- "$input_dir"
  touch -- "$video"
  printf '%s|50\n' "$video" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --extension mov --base-path out "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-vsync cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$fixed_video")" "$FFMPEG_LOG_FILE"
}

@test "single-file input with selected extension and base path writes beside the input file" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r selected_video="$input_dir/video.mov"

  declare -r fixed_videos_dir="$input_dir/out"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mov"

  mkdir -p -- "$input_dir"
  touch -- "$selected_video"
  printf '%s|50\n' "$selected_video" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --extension mov --base-path out "$selected_video"
  [ "$status" -eq 0 ]
  [ -f "$fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-vsync cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$fixed_video")" "$FFMPEG_LOG_FILE"
}
