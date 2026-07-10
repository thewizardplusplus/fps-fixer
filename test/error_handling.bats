#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] FPS processing failure warns and continues" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r failed_video="$input_dir/failed.mp4"
  declare -r another_failed_video="$input_dir/another-failed.mp4"
  declare -r processed_video="$input_dir/processed.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r failed_fixed_video="$fixed_videos_dir/failed.60_fps.mp4"
  declare -r another_failed_fixed_video="$fixed_videos_dir/another-failed.60_fps.mp4"
  declare -r processed_fixed_video="$fixed_videos_dir/processed.60_fps.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$failed_video" "$another_failed_video" "$processed_video"
  {
    printf '%s|50\n' "$failed_video"
    printf '%s|50\n' "$another_failed_video"
    printf '%s|50\n' "$processed_video"
  } > "$FFPROBE_FPS_MAP_FILE"
  # two failing files prove that the loop reached another failure after the first one,
  # regardless of the order returned by `find`
  {
    printf '%s\n' "$failed_video"
    printf '%s\n' "$another_failed_video"
  } > "$FFMPEG_FAIL_MATCH_FILE"

  run "$SCRIPT" "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -f "$failed_fixed_video" ]
  [ ! -f "$another_failed_fixed_video" ]
  [ -f "$processed_fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 3 ]
  ! grep -F -- "$(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  ! grep -F -- "$(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  [ "$(output_line_count "mock processing failure")" -eq 2 ]
  [ "$(output_line_count "unable to process video")" -eq 2 ]
}

@test "[$(test_file_group)] video acceleration failure warns and continues" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r failed_video="$input_dir/failed.mp4"
  declare -r another_failed_video="$input_dir/another-failed.mp4"
  declare -r processed_video="$input_dir/processed.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r failed_fixed_video="$fixed_videos_dir/failed.60_fps.mp4"
  declare -r another_failed_fixed_video="$fixed_videos_dir/another-failed.60_fps.mp4"
  declare -r processed_fixed_video="$fixed_videos_dir/processed.60_fps.mp4"
  declare -r failed_accelerated_video="$fixed_videos_dir/failed.60_fps.1.5x.mp4"
  declare -r another_failed_accelerated_video="$fixed_videos_dir/another-failed.60_fps.1.5x.mp4"
  declare -r processed_accelerated_video="$fixed_videos_dir/processed.60_fps.1.5x.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$failed_video" "$another_failed_video" "$processed_video"
  {
    printf '%s|50\n' "$failed_video"
    printf '%s|50\n' "$another_failed_video"
    printf '%s|50\n' "$processed_video"
  } > "$FFPROBE_FPS_MAP_FILE"
  # two failing files prove that the loop reached another failure after the first one,
  # regardless of the order returned by `find`
  {
    printf '%s\n' "$(relative_path "$failed_accelerated_video")"
    printf '%s\n' "$(relative_path "$another_failed_accelerated_video")"
  } > "$FFMPEG_FAIL_MATCH_FILE"

  run "$SCRIPT" --speed-factor 1.5 "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$failed_fixed_video" ]
  [ -f "$another_failed_fixed_video" ]
  [ -f "$processed_fixed_video" ]
  [ ! -f "$failed_accelerated_video" ]
  [ ! -f "$another_failed_accelerated_video" ]
  [ -f "$processed_accelerated_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 3 ]
  [ "$(ffmpeg_acceleration_call_count)" -eq 3 ]
  grep -F -- "$(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  ! grep -F -- "$(relative_path "$failed_accelerated_video")" "$FFMPEG_LOG_FILE"
  ! grep -F -- "$(relative_path "$another_failed_accelerated_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_accelerated_video")" "$FFMPEG_LOG_FILE"
  [ "$(output_line_count "mock processing failure")" -eq 2 ]
  [ "$(output_line_count "unable to process video")" -eq 2 ]
}

@test "[$(test_file_group)] FPS probe failure warns and continues" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r failed_video="$input_dir/failed.mp4"
  declare -r another_failed_video="$input_dir/another-failed.mp4"
  declare -r processed_video="$input_dir/processed.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r failed_fixed_video="$fixed_videos_dir/failed.60_fps.mp4"
  declare -r another_failed_fixed_video="$fixed_videos_dir/another-failed.60_fps.mp4"
  declare -r processed_fixed_video="$fixed_videos_dir/processed.60_fps.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$failed_video" "$another_failed_video" "$processed_video"
  # two failing files prove that the loop reached another failure after the first one,
  # regardless of the order returned by `find`
  {
    printf '%s\n' "$failed_video"
    printf '%s\n' "$another_failed_video"
  } > "$FFPROBE_FAIL_MATCH_FILE"
  printf '%s|50\n' "$processed_video" > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -f "$failed_fixed_video" ]
  [ ! -f "$another_failed_fixed_video" ]
  [ -f "$processed_fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  ! grep -F -- "$(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  ! grep -F -- "$(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  [ "$(output_line_count "mock probe failure")" -eq 2 ]
  [ "$(output_line_count "unable to extract FPS")" -eq 2 ]
}

@test "[$(test_file_group)] missing video FPS metadata warns and continues" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r no_fps_video="$input_dir/no-fps.mp4"
  declare -r another_no_fps_video="$input_dir/another-no-fps.mp4"
  declare -r processed_video="$input_dir/processed.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r no_fps_fixed_video="$fixed_videos_dir/no-fps.60_fps.mp4"
  declare -r another_no_fps_fixed_video="$fixed_videos_dir/another-no-fps.60_fps.mp4"
  declare -r processed_fixed_video="$fixed_videos_dir/processed.60_fps.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$no_fps_video" "$another_no_fps_video" "$processed_video"
  {
    printf '%s|0/0\n' "$no_fps_video"
    printf '%s|0/0\n' "$another_no_fps_video"
    printf '%s|50\n' "$processed_video"
  } > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -f "$no_fps_fixed_video" ]
  [ ! -f "$another_no_fps_fixed_video" ]
  [ -f "$processed_fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  ! grep -F -- "$(relative_path "$no_fps_fixed_video")" "$FFMPEG_LOG_FILE"
  ! grep -F -- "$(relative_path "$another_no_fps_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  [ "$(output_line_count "unable to extract FPS")" -eq 2 ]
}

@test "[$(test_file_group)] audio probe failure skips audio acceleration and continues" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r failed_video="$input_dir/failed.mp4"
  declare -r another_failed_video="$input_dir/another-failed.mp4"
  declare -r processed_video="$input_dir/processed.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r failed_fixed_video="$fixed_videos_dir/failed.60_fps.mp4"
  declare -r another_failed_fixed_video="$fixed_videos_dir/another-failed.60_fps.mp4"
  declare -r processed_fixed_video="$fixed_videos_dir/processed.60_fps.mp4"
  declare -r failed_accelerated_video="$fixed_videos_dir/failed.60_fps.1.5x.mp4"
  declare -r another_failed_accelerated_video="$fixed_videos_dir/another-failed.60_fps.1.5x.mp4"
  declare -r processed_accelerated_video="$fixed_videos_dir/processed.60_fps.1.5x.mp4"

  mkdir -p -- "$input_dir"
  touch -- "$failed_video" "$another_failed_video" "$processed_video"
  # two failing files prove that the loop reached another failure after the first one,
  # regardless of the order returned by `find`
  {
    printf '%s\n' "$(relative_path "$failed_fixed_video")"
    printf '%s\n' "$(relative_path "$another_failed_fixed_video")"
  } > "$FFPROBE_FAIL_MATCH_FILE"
  {
    printf '%s|50\n' "$failed_video"
    printf '%s|50\n' "$another_failed_video"
    printf '%s|50\n' "$processed_video"
  } > "$FFPROBE_FPS_MAP_FILE"

  run "$SCRIPT" --speed-factor 1.5 "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$failed_fixed_video" ]
  [ -f "$another_failed_fixed_video" ]
  [ -f "$processed_fixed_video" ]
  [ -f "$failed_accelerated_video" ]
  [ -f "$another_failed_accelerated_video" ]
  [ -f "$processed_accelerated_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 3 ]
  [ "$(ffmpeg_acceleration_call_count)" -eq 3 ]
  grep -F -- "$(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$another_failed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $(relative_path "$processed_fixed_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$failed_accelerated_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$another_failed_accelerated_video")" "$FFMPEG_LOG_FILE"
  grep -F -- "$(relative_path "$processed_accelerated_video")" "$FFMPEG_LOG_FILE"
  [ "$(file_line_count "$FFMPEG_LOG_FILE" "-map [v] -an")" -eq 2 ]
  [ "$(file_line_count "$FFMPEG_LOG_FILE" "-map [v] -map [a]")" -eq 1 ]
  [ "$(output_line_count "mock probe failure")" -eq 2 ]
}
