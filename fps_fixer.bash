#!/usr/bin/env bash

declare -r VIDEO_EXTENSION="${VIDEO_EXTENSION-mp4}"
declare -r FIXED_VIDEO_BASE_PATH="${FIXED_VIDEO_BASE_PATH-./fixed-videos}"

function get_fps() {
  declare -r file_path="$1"

  ffmpeg -i "$file_path" 2>&1 \
    | grep --perl-regexp --only-matching "\d+([.,]\d+)?\s*(?=fps)" \
    | sed --regexp-extended "s/\s*$//"
}

mkdir --parents "$FIXED_VIDEO_BASE_PATH"

find -maxdepth 1 -name "*.$VIDEO_EXTENSION" \
  | while read -r; do
    declare video_path="$REPLY"
    echo "process video $video_path"

    declare video_fps="$(get_fps "$video_path")"
    echo "video $video_path has $video_fps FPS"
  done
