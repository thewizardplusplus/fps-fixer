#!/usr/bin/env bash

declare -r VIDEO_EXTENSION="${VIDEO_EXTENSION-mp4}"
declare -r FIXED_VIDEO_BASE_PATH="${FIXED_VIDEO_BASE_PATH-./fixed-videos}"

mkdir --parents "$FIXED_VIDEO_BASE_PATH"

find -maxdepth 1 -name "*.$VIDEO_EXTENSION" \
  | while read -r; do
    declare video_path="$REPLY"
    echo "process video $video_path"
  done
