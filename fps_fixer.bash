#!/usr/bin/env bash

declare -r BLACK="$(tput setaf 237)"
declare -r RED="$(tput setaf 1)"
declare -r GREEN="$(tput setaf 2)"
declare -r YELLOW="$(tput setaf 3)"
declare -r MAGENTA="$(tput setaf 4)"
declare -r RESET="$(tput sgr0)"

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

declare -r script_name="$(basename "$0")"
# it's necessary to separate the declaration and definition of the variable
# so that the `declare` command doesn't hide an exit code of the defining expression
declare options
options="$(
  getopt \
    --name "$script_name" \
    --options "vhe:b:f:E:" \
    --longoptions "version,help,extension:,base-path:,fps:,epsilon:,no-process" \
    -- "$@"
)"
if [[ $? != 0 ]]; then
  log ERROR "incorrect option"
  exit 1
fi

declare video_extension="mp4"
declare fixed_video_base_path="./fixed-videos"
declare target_fps="60"
declare fps_epsilon="2"
declare process=TRUE
eval set -- "$options"
while [[ "$1" != "--" ]]; do
  case "$1" in
    "-v" | "--version")
      echo "FPS Fixer, v1.1.0"
      echo "Copyright (C) 2023 thewizardplusplus"

      exit 0
      ;;
    "-h" | "--help")
      echo "Usage:"
      echo "  $script_name -v | --version"
      echo "  $script_name -h | --help"
      echo "  $script_name [options] [<path>]"
      echo
      echo "Options:"
      echo "  -v, --version                        - show the version;"
      echo "  -h, --help                           - show the help;"
      echo "  -e EXTENSION, --extension EXTENSION  - video file extension (default: \"mp4\");"
      echo "  -b PATH, --base-path PATH            - base path for fixed videos" \
        "(should be relative to argument \"<path>\"; default: \"./fixed-videos\");"
      echo "  -f FPS, --fps FPS                    - target FPS (default: \"60\");"
      echo "  -E EPSILON, --epsilon EPSILON        - allowable error when comparing FPS" \
        "(default: \"2\");"
      echo "  --no-process                         - don't process videos," \
        "only search for them and check their FPS."
      echo
      echo "Arguments:"
      echo "  <path>                               - base path to original videos" \
        "(default: \".\")."

      exit 0
      ;;
    "-e" | "--extension")
      video_extension="$2"
      shift # an additional shift for the option parameter
      ;;
    "-b" | "--base-path")
      fixed_video_base_path="$2"
      shift # an additional shift for the option parameter
      ;;
    "-f" | "--fps")
      target_fps="$2"
      shift # an additional shift for the option parameter
      ;;
    "-E" | "--epsilon")
      fps_epsilon="$2"
      shift # an additional shift for the option parameter
      ;;
    "--no-process")
      process=FALSE
      ;;
  esac

  shift
done

declare original_video_base_path="."
shift # an additional shift for the "--" option
if [[ $# == 1 ]]; then
  original_video_base_path="$1"
  fixed_video_base_path="$original_video_base_path/$fixed_video_base_path"
elif [[ $# > 1 ]]; then
  log ERROR "too many positional arguments"
  exit 1
fi

set -o errtrace
trap 'log WARNING "unable to process video $(ansi "$YELLOW" "$video_path")"' ERR

mkdir --parents "$fixed_video_base_path"

find "$original_video_base_path" -maxdepth 1 -type f -name "*.$video_extension" \
  | while read -r; do
    declare video_path="$REPLY"
    log INFO "process video $(ansi "$YELLOW" "$video_path")"

    declare video_fps="$(get_fps "$video_path")"
    log INFO "video $(ansi "$YELLOW" "$video_path") has $(ansi "$MAGENTA" "$video_fps") FPS"

    if (( "$(is_target_fps "$video_fps" "$target_fps" "$fps_epsilon")" )); then
      log INFO "video $(ansi "$YELLOW" "$video_path") already has the target FPS"
      continue
    fi

    if [[ $process == FALSE ]]; then
      log WARNING "video $(ansi "$YELLOW" "$video_path") doesn't have the target FPS"
      continue
    fi

    declare video_name="$(basename "$video_path")"
    declare video_name_without_extension="${video_name%.$video_extension}"
    declare fixed_video_path="./$(realpath --relative-to "." "$(
      printf \
        "%s/%s.%s_fps.%s" \
        "$fixed_video_base_path" \
        "$video_name_without_extension" \
        "$target_fps" \
        "$video_extension"
    )")"
    ffmpeg \
      -nostdin \
      -loglevel warning \
      -stats \
      -y \
      -i "$video_path" \
      -filter:v fps="$target_fps" \
      "$fixed_video_path"
    log INFO "fixed video path: $(ansi "$YELLOW" "$fixed_video_path")"
  done
