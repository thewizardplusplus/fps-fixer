#!/usr/bin/env bash

declare -r VIDEO_EXTENSION="${VIDEO_EXTENSION-mp4}"
declare -r FIXED_VIDEO_BASE_PATH="${FIXED_VIDEO_BASE_PATH-./fixed-videos}"
declare -r TARGET_FPS="${TARGET_FPS-60}"
declare -r FPS_EPSILON="${FPS_EPSILON-2}"

function get_fps() {
  declare -r file_path="$1"

  ffmpeg -i "$file_path" 2>&1 \
    | grep --perl-regexp --only-matching "\d+([.,]\d+)?\s*(?=fps)" \
    | sed --regexp-extended "s/\s*$//"
}

function is_target_fps() {
  declare -r fps="$1"
  declare -r target_fps="$2"
  declare -r epsilon="$3"

  bc <<< "
    define abs(value) { if (value > 0) { return value; } else { return -value; } }

    abs($fps - $target_fps) < $epsilon
  "
}

mkdir --parents "$FIXED_VIDEO_BASE_PATH"

find -maxdepth 1 -name "*.$VIDEO_EXTENSION" \
  | while read -r; do
    declare video_path="$REPLY"
    echo "process video $video_path"

    declare video_fps="$(get_fps "$video_path")"
    echo "video $video_path has $video_fps FPS"

    if (( "$(is_target_fps "$video_fps" "$TARGET_FPS" "$FPS_EPSILON")" )); then
      echo "video $video_path already has the target FPS"
      continue
    fi

    declare video_path_without_extension="${video_path%.$VIDEO_EXTENSION}"
    declare fixed_video_path="./$(realpath --relative-to "." "$(
      printf \
        "%s/%s.%s_fps.%s" \
        "$FIXED_VIDEO_BASE_PATH" \
        "$video_path_without_extension" \
        "$TARGET_FPS" \
        "$VIDEO_EXTENSION"
    )")"
    echo "fixed video path: $fixed_video_path"
  done
