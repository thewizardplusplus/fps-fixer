#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] -s and --speed-factor accelerate non-target FPS videos after FPS fixing" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mp4"
  declare -r accelerated_video="$fixed_videos_dir/video.60_fps.1.5x.mp4"

  for speed_option in -s --speed-factor; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$video"
    printf '%s|50\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$speed_option" 1.5 "$input_dir"
    [ "$status" -eq 0 ]
    [ -f "$fixed_video" ]
    [ -f "$accelerated_video" ]
    [ "$(ffmpeg_processing_call_count)" -eq 1 ]
    [ "$(ffmpeg_acceleration_call_count)" -eq 1 ]
    grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
    grep -F -- "-filter_complex [0:v]setpts=PTS/1.5[v];[0:a]atempo=1.5[a]" "$FFMPEG_LOG_FILE"
    grep -F -- "-i $(ffmpeg_command_path "$fixed_video")" "$FFMPEG_LOG_FILE"
    grep -F -- "$(ffmpeg_command_path "$accelerated_video")" "$FFMPEG_LOG_FILE"

    declare fps_fix_line
    declare acceleration_line
    fps_fix_line="$(grep -nF -- "-filter:v fps=60" "$FFMPEG_LOG_FILE" | cut -d: -f1 | head -n1)"
    acceleration_line="$(grep -nF -- "-filter_complex" "$FFMPEG_LOG_FILE" | cut -d: -f1 | head -n1)"
    [ "$fps_fix_line" -lt "$acceleration_line" ]
  done
}

@test "[$(test_file_group)] -s and --speed-factor skip already target FPS videos without --force and do not accelerate" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mp4"
  declare -r accelerated_video="$fixed_videos_dir/video.60_fps.1.5x.mp4"

  for speed_option in -s --speed-factor; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$video"
    printf '%s|60\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$speed_option" 1.5 "$input_dir"
    [ "$status" -eq 0 ]
    [ ! -f "$fixed_video" ]
    [ ! -f "$accelerated_video" ]
    [ "$(ffmpeg_processing_call_count)" -eq 0 ]
    [ "$(ffmpeg_acceleration_call_count)" -eq 0 ]
    ! grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
    ! grep -F -- "-filter_complex" "$FFMPEG_LOG_FILE"
  done
}

@test "[$(test_file_group)] -s and --speed-factor with --force do not skip already target FPS videos and accelerate" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r fixed_video="$fixed_videos_dir/video.60_fps.mp4"
  declare -r accelerated_video="$fixed_videos_dir/video.60_fps.1.5x.mp4"

  for speed_option in -s --speed-factor; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$video"
    printf '%s|60\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$speed_option" 1.5 --force "$input_dir"
    [ "$status" -eq 0 ]
    [ -f "$fixed_video" ]
    [ -f "$accelerated_video" ]
    [ "$(ffmpeg_processing_call_count)" -eq 1 ]
    [ "$(ffmpeg_acceleration_call_count)" -eq 1 ]
    grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
    grep -F -- "-filter_complex [0:v]setpts=PTS/1.5[v];[0:a]atempo=1.5[a]" "$FFMPEG_LOG_FILE"
    grep -F -- "$(ffmpeg_command_path "$accelerated_video")" "$FFMPEG_LOG_FILE"
  done
}

@test "[$(test_file_group)] acceleration with audio uses video and audio filters and maps both outputs" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  mkdir -p "$input_dir"
  touch "$video"
  printf '%s|50\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --speed-factor 1.5 "$input_dir"
  [ "$status" -eq 0 ]
  [ "$(ffmpeg_acceleration_call_count)" -eq 1 ]
  grep -F -- "setpts=PTS/1.5[v]" "$FFMPEG_LOG_FILE"
  grep -F -- "atempo=1.5[a]" "$FFMPEG_LOG_FILE"
  grep -F -- "-map [v] -map [a]" "$FFMPEG_LOG_FILE"
}

@test "[$(test_file_group)] acceleration with --no-audio maps only video and disables audio" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r video="$input_dir/video.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r accelerated_video="$fixed_videos_dir/video.60_fps.1.5x.mp4"

  mkdir -p "$input_dir"
  touch "$video"
  printf '%s|50\n' "$video" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" -s 1.5 --no-audio "$input_dir"
  [ "$status" -eq 0 ]
  [ -f "$accelerated_video" ]
  [ "$(ffmpeg_acceleration_call_count)" -eq 1 ]
  grep -F -- "-filter_complex [0:v]setpts=PTS/1.5[v]" "$FFMPEG_LOG_FILE"
  ! grep -F -- "atempo" "$FFMPEG_LOG_FILE"
  grep -F -- "-map [v] -an" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-map [a]" "$FFMPEG_LOG_FILE"
  grep -F -- "-an" "$FFMPEG_LOG_FILE"
}
