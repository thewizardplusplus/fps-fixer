#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] target FPS comparison honors default epsilon boundaries" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r exact_fps_video="$input_dir/exact.mp4"
  declare -r below_within_epsilon_video="$input_dir/below-within.mp4"
  declare -r lower_epsilon_boundary_video="$input_dir/lower-boundary.mp4"
  declare -r above_within_epsilon_video="$input_dir/above-within.mp4"
  declare -r upper_epsilon_boundary_video="$input_dir/upper-boundary.mp4"
  declare -r below_outside_epsilon_video="$input_dir/below-outside.mp4"
  declare -r above_outside_epsilon_video="$input_dir/above-outside.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r exact_fps_fixed_video="$fixed_videos_dir/exact.60_fps.mp4"
  declare -r below_within_epsilon_fixed_video="$fixed_videos_dir/below-within.60_fps.mp4"
  declare -r lower_epsilon_boundary_fixed_video="$fixed_videos_dir/lower-boundary.60_fps.mp4"
  declare -r above_within_epsilon_fixed_video="$fixed_videos_dir/above-within.60_fps.mp4"
  declare -r upper_epsilon_boundary_fixed_video="$fixed_videos_dir/upper-boundary.60_fps.mp4"
  declare -r below_outside_epsilon_fixed_video="$fixed_videos_dir/below-outside.60_fps.mp4"
  declare -r above_outside_epsilon_fixed_video="$fixed_videos_dir/above-outside.60_fps.mp4"

  mkdir -p "$input_dir"
  touch \
    "$exact_fps_video" \
    "$below_within_epsilon_video" \
    "$lower_epsilon_boundary_video" \
    "$above_within_epsilon_video" \
    "$upper_epsilon_boundary_video" \
    "$below_outside_epsilon_video" \
    "$above_outside_epsilon_video"
  {
    printf '%s|60\n' "$exact_fps_video"
    printf '%s|59.5\n' "$below_within_epsilon_video"
    printf '%s|58\n' "$lower_epsilon_boundary_video"
    printf '%s|60.5\n' "$above_within_epsilon_video"
    printf '%s|62\n' "$upper_epsilon_boundary_video"
    printf '%s|57.99\n' "$below_outside_epsilon_video"
    printf '%s|62.01\n' "$above_outside_epsilon_video"
  } > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -f "$exact_fps_fixed_video" ]
  [ ! -f "$below_within_epsilon_fixed_video" ]
  [ ! -f "$lower_epsilon_boundary_fixed_video" ]
  [ ! -f "$above_within_epsilon_fixed_video" ]
  [ ! -f "$upper_epsilon_boundary_fixed_video" ]
  [ -f "$below_outside_epsilon_fixed_video" ]
  [ -f "$above_outside_epsilon_fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 2 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "$below_outside_epsilon_fixed_video" "$FFMPEG_LOG_FILE"
  grep -F -- "$above_outside_epsilon_fixed_video" "$FFMPEG_LOG_FILE"
}

@test "[$(test_file_group)] custom target FPS via -f and --fps is respected" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r target_fps_video="$input_dir/target.mp4"
  declare -r non_target_fps_video="$input_dir/fix.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r target_fps_fixed_video="$fixed_videos_dir/target.48_fps.mp4"
  declare -r non_target_fps_fixed_video="$fixed_videos_dir/fix.48_fps.mp4"

  for fps_option in -f --fps; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$target_fps_video" "$non_target_fps_video"
    {
      printf '%s|48\n' "$target_fps_video"
      printf '%s|45\n' "$non_target_fps_video"
    } > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$fps_option" 48 "$input_dir"
    [ "$status" -eq 0 ]
    [ ! -f "$target_fps_fixed_video" ]
    [ -f "$non_target_fps_fixed_video" ]
    [ "$(ffmpeg_processing_call_count)" -eq 1 ]
    grep -F -- "-filter:v fps=48" "$FFMPEG_LOG_FILE"
    grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
    grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
    grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
    grep -F -- "$non_target_fps_fixed_video" "$FFMPEG_LOG_FILE"
  done
}

@test "[$(test_file_group)] custom FPS epsilon via -E and --epsilon is respected" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r within_epsilon_video="$input_dir/within.mp4"
  declare -r outside_epsilon_video="$input_dir/outside.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r within_epsilon_fixed_video="$fixed_videos_dir/within.60_fps.mp4"
  declare -r outside_epsilon_fixed_video="$fixed_videos_dir/outside.60_fps.mp4"

  for epsilon_option in -E --epsilon; do
    for fps_epsilon in 0.5 0,5; do
      rm -rf "$input_dir"
      truncate -s 0 "$FFMPEG_LOG_FILE"

      mkdir -p "$input_dir"
      touch "$within_epsilon_video" "$outside_epsilon_video"
      {
        printf '%s|59.5\n' "$within_epsilon_video"
        printf '%s|59.49\n' "$outside_epsilon_video"
      } > "$FFMPEG_FPS_MAP_FILE"

      run "$SCRIPT" "$epsilon_option" "$fps_epsilon" "$input_dir"
      [ "$status" -eq 0 ]
      [ ! -f "$within_epsilon_fixed_video" ]
      [ -f "$outside_epsilon_fixed_video" ]
      [ "$(ffmpeg_processing_call_count)" -eq 1 ]
      grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
      grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
      grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
      grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
      grep -F -- "$outside_epsilon_fixed_video" "$FFMPEG_LOG_FILE"
    done
  done
}

@test "[$(test_file_group)] fractional FPS with dot and comma notation is handled" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r dot_fps_video="$input_dir/dot.mp4"
  declare -r comma_fps_video="$input_dir/comma.mp4"
  declare -r non_target_fps_video="$input_dir/fix.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r dot_fps_fixed_video="$fixed_videos_dir/dot.59.94_fps.mp4"
  declare -r comma_fps_fixed_video="$fixed_videos_dir/comma.59.94_fps.mp4"
  declare -r non_target_fps_fixed_video="$fixed_videos_dir/fix.59.94_fps.mp4"

  for target_fps in 59.94 59,94; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$dot_fps_video" "$comma_fps_video" "$non_target_fps_video"
    {
      printf '%s|59.94\n' "$dot_fps_video"
      printf '%s|59,94\n' "$comma_fps_video"
      printf '%s|58\n' "$non_target_fps_video"
    } > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" --fps "$target_fps" --epsilon 0 "$input_dir"
    [ "$status" -eq 0 ]
    [ ! -f "$dot_fps_fixed_video" ]
    [ ! -f "$comma_fps_fixed_video" ]
    [ -f "$non_target_fps_fixed_video" ]
    [ "$(ffmpeg_processing_call_count)" -eq 1 ]
    grep -F -- "-filter:v fps=59.94" "$FFMPEG_LOG_FILE"
    grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
    grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
    grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
    grep -F -- "$non_target_fps_fixed_video" "$FFMPEG_LOG_FILE"
  done
}

@test "[$(test_file_group)] only the first FPS match from ffmpeg output is used" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r first_target_fps_video="$input_dir/first-target.mp4"
  declare -r first_non_target_fps_video="$input_dir/first-non-target.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r first_target_fps_fixed_video="$fixed_videos_dir/first-target.60_fps.mp4"
  declare -r first_non_target_fps_fixed_video="$fixed_videos_dir/first-non-target.60_fps.mp4"

  mkdir -p "$input_dir"
  touch "$first_target_fps_video" "$first_non_target_fps_video"
  {
    printf '%s|60 fps, 50\n' "$first_target_fps_video"
    printf '%s|50 fps, 60\n' "$first_non_target_fps_video"
  } > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" "$input_dir"
  [ "$status" -eq 0 ]
  [ ! -f "$first_target_fps_fixed_video" ]
  [ -f "$first_non_target_fps_fixed_video" ]
  [ "$(ffmpeg_processing_call_count)" -eq 1 ]
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
  grep -F -- "-fps_mode:v cfr" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:v" "$FFMPEG_LOG_FILE"
  grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
  grep -F -- "$first_non_target_fps_fixed_video" "$FFMPEG_LOG_FILE"
}
