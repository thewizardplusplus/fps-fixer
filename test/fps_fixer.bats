#!/usr/bin/env bats

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

ffmpeg_processing_calls() {
  grep -F -- "-filter:v fps=" "$FFMPEG_LOG_FILE" || true
}

ffmpeg_processing_call_count() {
  ffmpeg_processing_calls | wc -l | tr -d ' '
}

@test "-v and --version exit 0" {
  run "$SCRIPT" -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]

  run "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]
}

@test "-h and --help exit 0" {
  run "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]

  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "unknown option exits 1" {
  run "$SCRIPT" --unknown
  [ "$status" -eq 1 ]
}

@test "too many positional args exits 1" {
  run "$SCRIPT" foo bar
  [ "$status" -eq 1 ]
}

@test "-f and --fps abc fail because the value is not numeric" {
  run "$SCRIPT" -f abc --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]

  run "$SCRIPT" --fps abc --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]
}

@test "-f and --fps .5 fail because a leading digit is required" {
  run "$SCRIPT" -f .5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]

  run "$SCRIPT" --fps .5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]
}

@test "-f and --fps 0 fail because FPS should be positive" {
  run "$SCRIPT" -f 0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]

  run "$SCRIPT" --fps 0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]
}

@test "-f and --fps successful values pass in no-process mode" {
  run "$SCRIPT" -f 60 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --fps 60 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -f 59.94 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --fps 59.94 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -f 59,94 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --fps 59,94 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "-E and --epsilon abc fail because the value is not numeric" {
  run "$SCRIPT" -E abc --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]

  run "$SCRIPT" --epsilon abc --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]
}

@test "-E and --epsilon .5 fail because a leading digit is required" {
  run "$SCRIPT" -E .5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]

  run "$SCRIPT" --epsilon .5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 1 ]
}

@test "-E and --epsilon successful values pass in no-process mode" {
  run "$SCRIPT" -E 0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --epsilon 0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -E 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --epsilon 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -E 0,5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --epsilon 0,5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "-s and --speed-factor abc fail because the value is not numeric" {
  run "$SCRIPT" -s abc
  [ "$status" -eq 1 ]

  run "$SCRIPT" --speed-factor abc
  [ "$status" -eq 1 ]
}

@test "-s and --speed-factor 0.49 fail because it is below the allowed range" {
  run "$SCRIPT" -s 0.49
  [ "$status" -eq 1 ]

  run "$SCRIPT" --speed-factor 0.49
  [ "$status" -eq 1 ]
}

@test "-s and --speed-factor 2.01 fail because it is above the allowed range" {
  run "$SCRIPT" -s 2.01
  [ "$status" -eq 1 ]

  run "$SCRIPT" --speed-factor 2.01
  [ "$status" -eq 1 ]
}

@test "-s and --speed-factor .5 fail because a leading digit is required" {
  run "$SCRIPT" -s .5
  [ "$status" -eq 1 ]

  run "$SCRIPT" --speed-factor .5
  [ "$status" -eq 1 ]
}

@test "-s and --speed-factor successful values pass in no-process mode" {
  run "$SCRIPT" -s 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --speed-factor 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -s 1.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --speed-factor 1.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -s 2.0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --speed-factor 2.0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -s 2 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --speed-factor 2 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" -s 1,5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]

  run "$SCRIPT" --speed-factor 1,5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "default discovery only mp4 files and no nested" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r top_level_mp4="$input_dir/a.mp4"
  declare -r top_level_mp4_with_spaces="$input_dir/my video.mp4"
  declare -r top_level_mp4_with_parentheses="$input_dir/video (1).mp4"
  declare -r top_level_mp4_with_apostrophe="$input_dir/john's video.mp4"
  declare -r top_level_mp4_cyrillic="$input_dir/видео.mp4"
  declare -r top_level_mp4_many_dots="$input_dir/my.video.test.mp4"
  declare -r top_level_non_target_mov="$input_dir/b.mov"
  declare -r fake_mp4_directory="$input_dir/fake.mp4"
  declare -r top_level_mp4_uppercase_extension="$input_dir/video.MP4"
  declare -r top_level_no_extension="$input_dir/video"
  declare -r top_level_backup_file="$input_dir/video.mp4.backup"
  declare -r nested_mp4="$input_dir/sub/c.mp4"

  mkdir -p "$fake_mp4_directory" "$input_dir/sub"
  touch \
    "$top_level_mp4" \
    "$top_level_mp4_with_spaces" \
    "$top_level_mp4_with_parentheses" \
    "$top_level_mp4_with_apostrophe" \
    "$top_level_mp4_cyrillic" \
    "$top_level_mp4_many_dots" \
    "$top_level_non_target_mov" \
    "$top_level_mp4_uppercase_extension" \
    "$top_level_no_extension" \
    "$top_level_backup_file" \
    "$nested_mp4"
  {
    printf '%s|50\n' "$top_level_mp4"
    printf '%s|50\n' "$top_level_mp4_with_spaces"
    printf '%s|50\n' "$top_level_mp4_with_parentheses"
    printf '%s|50\n' "$top_level_mp4_with_apostrophe"
    printf '%s|50\n' "$top_level_mp4_cyrillic"
    printf '%s|50\n' "$top_level_mp4_many_dots"
  } > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$input_dir"
  [ "$status" -eq 0 ]
  grep -F -- "-i $top_level_mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_mp4_with_spaces" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_mp4_with_parentheses" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_mp4_with_apostrophe" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_mp4_cyrillic" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_mp4_many_dots" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $top_level_non_target_mov" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $fake_mp4_directory" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $top_level_mp4_uppercase_extension" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $top_level_no_extension" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $top_level_backup_file" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $nested_mp4" "$FFMPEG_LOG_FILE"
}

@test "discovery mov with -e" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r top_level_non_target_mp4="$input_dir/a.mp4"
  declare -r top_level_target_mov="$input_dir/b.mov"

  mkdir -p "$input_dir"
  touch "$top_level_non_target_mp4" "$top_level_target_mov"
  printf '%s|50\n' "$top_level_target_mov" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" -e "mov" --no-process "$input_dir"
  [ "$status" -eq 0 ]
  ! grep -F -- "-i $top_level_non_target_mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_target_mov" "$FFMPEG_LOG_FILE"
}

@test "discovery mov with --extension" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r top_level_non_target_mp4="$input_dir/a.mp4"
  declare -r top_level_target_mov="$input_dir/b.mov"

  mkdir -p "$input_dir"
  touch "$top_level_non_target_mp4" "$top_level_target_mov"
  printf '%s|50\n' "$top_level_target_mov" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --extension "mov" --no-process "$input_dir"
  [ "$status" -eq 0 ]
  ! grep -F -- "-i $top_level_non_target_mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $top_level_target_mov" "$FFMPEG_LOG_FILE"
}

@test "no-process does not create output directory" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/v.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/v.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ ! -d "$TMPDIR_TEST/in/fixed-videos" ]
}

@test "target FPS comparison honors default epsilon boundaries" {
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

@test "custom target FPS via -f and --fps is respected" {
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

@test "custom epsilon via -E and --epsilon is respected" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r within_epsilon_video="$input_dir/within.mp4"
  declare -r outside_epsilon_video="$input_dir/outside.mp4"

  declare -r fixed_videos_dir="$input_dir/fixed-videos"
  declare -r within_epsilon_fixed_video="$fixed_videos_dir/within.60_fps.mp4"
  declare -r outside_epsilon_fixed_video="$fixed_videos_dir/outside.60_fps.mp4"

  for epsilon_option in -E --epsilon; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$within_epsilon_video" "$outside_epsilon_video"
    {
      printf '%s|59.5\n' "$within_epsilon_video"
      printf '%s|59.49\n' "$outside_epsilon_video"
    } > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$epsilon_option" 0,5 "$input_dir"
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
}

@test "fractional FPS with dot and comma notation is handled" {
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

@test "only the first FPS match from ffmpeg output is used" {
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
