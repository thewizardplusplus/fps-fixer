#!/usr/bin/env bash

declare -r BLACK="$(tput setaf 237)"
declare -r RED="$(tput setaf 1)"
declare -r GREEN="$(tput setaf 2)"
declare -r YELLOW="$(tput setaf 3)"
declare -r MAGENTA="$(tput setaf 4)"
declare -r RESET="$(tput sgr0)"

declare -r VIDEO_EXTENSION="${VIDEO_EXTENSION-mp4}"
declare -r FIXED_VIDEO_BASE_PATH="${FIXED_VIDEO_BASE_PATH-./fixed-videos}"
declare -r TARGET_FPS="${TARGET_FPS-60}"
declare -r FPS_EPSILON="${FPS_EPSILON-2}"

function ansi() {
  declare -r code="$1"
  declare -r text="$2"

  echo -n "$code$text$RESET"
}

function log() {
  declare -r level="$1"

  shift # a shift for the first parameter
  declare -r message="$*"

  declare level_color=""
  if [[ $level == INFO ]]; then
    level_color="$GREEN"
  elif [[ $level == WARNING ]]; then
    level_color="$YELLOW"
  elif [[ $level == ERROR ]]; then
    level_color="$RED"
  fi

  echo "$(ansi "$BLACK" "$(date --rfc-3339=ns)")" \
    "$(ansi "$level_color" "[$level]")" \
    "$message" \
    1>&2
}

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

set -o errtrace
trap 'log WARNING "unable to process video $(ansi "$YELLOW" "$video_path")"' ERR

mkdir --parents "$FIXED_VIDEO_BASE_PATH"

find -maxdepth 1 -name "*.$VIDEO_EXTENSION" \
  | while read -r; do
    declare video_path="$REPLY"
    log INFO "process video $(ansi "$YELLOW" "$video_path")"

    declare video_fps="$(get_fps "$video_path")"
    log INFO "video $(ansi "$YELLOW" "$video_path") has $(ansi "$MAGENTA" "$video_fps") FPS"

    if (( "$(is_target_fps "$video_fps" "$TARGET_FPS" "$FPS_EPSILON")" )); then
      log INFO "video $(ansi "$YELLOW" "$video_path") already has the target FPS"
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
    ffmpeg \
      -nostdin \
      -loglevel warning \
      -stats \
      -y \
      -i "$video_path" \
      -filter:v fps="$TARGET_FPS" \
      "$fixed_video_path"
    log INFO "fixed video path: $(ansi "$YELLOW" "$fixed_video_path")"
  done
