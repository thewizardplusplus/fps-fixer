#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] --no-process does not create output directory" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"

  mkdir -p -- "$input_dir"
  touch -- "$video"
  printf '%s|50\n' "$video" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -d "$fixed_videos_dir" ]
  [ "$(ffmpeg_processing_call_count)" -eq 0 ]
  grep -F -- "$video" "$FFPROBE_LOG_FILE"
}

@test "[$(test_file_group)] --no-process reports target and non-target FPS without processing" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r target_fps_video="$input_dir/target.mp4"
  declare -r non_target_fps_video="$input_dir/non-target.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$target_fps_video" "$non_target_fps_video"
  {
    printf '%s|60\n' "$target_fps_video"
    printf '%s|50\n' "$non_target_fps_video"
  } > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$input_dir"
  [ "$status" -eq 0 ]
  [ "$(ffmpeg_processing_call_count)" -eq 0 ]
  grep -F -- "$target_fps_video" "$FFPROBE_LOG_FILE"
  grep -F -- "$non_target_fps_video" "$FFPROBE_LOG_FILE"
  [ "$(output_line_count "already has the target FPS")" -eq 1 ]
  [ "$(output_line_count "doesn't have the target FPS")" -eq 1 ]
}

@test "[$(test_file_group)] --force with --no-process skips FPS probing and processing" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$video"
  printf '%s|60\n' "$video" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --force --no-process "$input_dir"
  [ "$status" -eq 0 ]
  [ "$(ffmpeg_processing_call_count)" -eq 0 ]
  ! grep -F -- "$video" "$FFPROBE_LOG_FILE"
}

@test "[$(test_file_group)] selected extension and base path are used for output path" {
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

@test "[$(test_file_group)] single-file input with selected extension and base path writes output beside the input file" {
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
