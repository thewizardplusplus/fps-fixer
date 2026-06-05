#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] default discovery only mp4 files and no nested" {
  for input_dir in "$TMPDIR_TEST/in" "$TMPDIR_TEST/in with spaces"; do
    declare top_level_mp4="$input_dir/a.mp4"
    declare top_level_mp4_with_spaces="$input_dir/my video.mp4"
    declare top_level_mp4_with_parentheses="$input_dir/video (1).mp4"
    declare top_level_mp4_with_apostrophe="$input_dir/john's video.mp4"
    declare top_level_mp4_cyrillic="$input_dir/видео.mp4"
    declare top_level_mp4_many_dots="$input_dir/my.video.test.mp4"
    declare top_level_non_target_mov="$input_dir/b.mov"
    declare top_level_mp4_uppercase_extension="$input_dir/video.MP4"
    declare top_level_no_extension="$input_dir/video"
    declare top_level_backup_file="$input_dir/video.mp4.backup"

    declare fake_mp4_dir="$input_dir/fake.mp4"

    declare sub_input_dir="$input_dir/sub"
    declare nested_mp4="$sub_input_dir/c.mp4"

    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir" "$fake_mp4_dir" "$sub_input_dir"
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
    ! grep -F -- "-i $top_level_mp4_uppercase_extension" "$FFMPEG_LOG_FILE"
    ! grep -F -- "-i $top_level_no_extension" "$FFMPEG_LOG_FILE"
    ! grep -F -- "-i $top_level_backup_file" "$FFMPEG_LOG_FILE"
    ! grep -F -- "-i $fake_mp4_dir" "$FFMPEG_LOG_FILE"
    ! grep -F -- "-i $nested_mp4" "$FFMPEG_LOG_FILE"
  done
}

@test "[$(test_file_group)] discovery mov files with -e and --extension" {
  declare -r input_dir="$TMPDIR_TEST/in"
  declare -r top_level_non_target_mp4="$input_dir/a.mp4"
  declare -r top_level_target_mov="$input_dir/b.mov"

  for extension_option in -e --extension; do
    rm -rf "$input_dir"
    truncate -s 0 "$FFMPEG_LOG_FILE"

    mkdir -p "$input_dir"
    touch "$top_level_non_target_mp4" "$top_level_target_mov"
    printf '%s|50\n' "$top_level_target_mov" > "$FFMPEG_FPS_MAP_FILE"

    run "$SCRIPT" "$extension_option" "mov" --no-process "$input_dir"
    [ "$status" -eq 0 ]
    ! grep -F -- "-i $top_level_non_target_mp4" "$FFMPEG_LOG_FILE"
    grep -F -- "-i $top_level_target_mov" "$FFMPEG_LOG_FILE"
  done
}
