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

@test "-v exits 0" {
  run "$SCRIPT" -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]
}

@test "--version exits 0" {
  run "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]
}

@test "-h exits 0" {
  run "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--help exits 0" {
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

@test "--s abc fails because the value is not numeric" {
  run "$SCRIPT" --s abc
  [ "$status" -eq 1 ]
}

@test "--speed-factor abc fails because the value is not numeric" {
  run "$SCRIPT" --speed-factor abc
  [ "$status" -eq 1 ]
}

@test "--speed-factor 0.49 fails because it is below the allowed range" {
  run "$SCRIPT" --speed-factor 0.49
  [ "$status" -eq 1 ]
}

@test "-s 0.5 succeeds" {
  run "$SCRIPT" -s 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "--speed-factor 0.5 succeeds" {
  run "$SCRIPT" --speed-factor 0.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "--speed-factor 1.5 succeeds" {
  run "$SCRIPT" --speed-factor 1.5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "--speed-factor 2.0 succeeds" {
  run "$SCRIPT" --speed-factor 2.0 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "--speed-factor 2.01 fails because it is above the allowed range" {
  run "$SCRIPT" --speed-factor 2.01
  [ "$status" -eq 1 ]
}

@test "--speed-factor 2 succeeds" {
  run "$SCRIPT" --speed-factor 2 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "--speed-factor .5 fails because a leading digit is required" {
  run "$SCRIPT" --speed-factor .5
  [ "$status" -eq 1 ]
}

@test "--speed-factor 1,5 succeeds" {
  run "$SCRIPT" --speed-factor 1,5 --no-process "$TMPDIR_TEST"
  [ "$status" -eq 0 ]
}

@test "default discovery only mp4 and no nested" {
  mkdir -p "$TMPDIR_TEST/in/sub"
  touch "$TMPDIR_TEST/in/a.mp4" "$TMPDIR_TEST/in/b.mov" "$TMPDIR_TEST/in/sub/c.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/a.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  grep -F -- "-i $TMPDIR_TEST/in/a.mp4" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $TMPDIR_TEST/in/b.mov" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-i $TMPDIR_TEST/in/sub/c.mp4" "$FFMPEG_LOG_FILE"
}

@test "discovery mov with -e" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4" "$TMPDIR_TEST/in/b.mov"
  printf '%s|50\n' "$TMPDIR_TEST/in/b.mov" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" -e "mov" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  ! grep -F -- "-i $TMPDIR_TEST/in/a.mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $TMPDIR_TEST/in/b.mov" "$FFMPEG_LOG_FILE"
}

@test "discovery mov with --extension" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4" "$TMPDIR_TEST/in/b.mov"
  printf '%s|50\n' "$TMPDIR_TEST/in/b.mov" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --extension "mov" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  ! grep -F -- "-i $TMPDIR_TEST/in/a.mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-i $TMPDIR_TEST/in/b.mov" "$FFMPEG_LOG_FILE"
}

@test "no-process does not create output directory" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/v.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/v.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-process "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ ! -d "$TMPDIR_TEST/in/fixed-videos" ]
}

@test "target fps is skipped; non-target is processed" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/ok.mp4" "$TMPDIR_TEST/in/fix.mp4"
  {
    printf '%s|60\n' "$TMPDIR_TEST/in/ok.mp4"
    printf '%s|50\n' "$TMPDIR_TEST/in/fix.mp4"
  } > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/in/fixed-videos/fix.60_fps.mp4" ]
  [ ! -f "$TMPDIR_TEST/in/fixed-videos/ok.60_fps.mp4" ]
}

@test "--force skips probe and processes all" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4"

  run "$SCRIPT" --force "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  ! grep -x -- "-i $TMPDIR_TEST/in/a.mp4" "$FFMPEG_LOG_FILE"
  grep -F -- "-filter:v fps=60" "$FFMPEG_LOG_FILE"
}

@test "--no-audio uses -an and no audio map" {
  mkdir -p "$TMPDIR_TEST/in"
  touch "$TMPDIR_TEST/in/a.mp4"
  printf '%s|50\n' "$TMPDIR_TEST/in/a.mp4" > "$FFMPEG_FPS_MAP_FILE"

  run "$SCRIPT" --no-audio "$TMPDIR_TEST/in"
  [ "$status" -eq 0 ]
  grep -F -- "-an" "$FFMPEG_LOG_FILE"
  ! grep -F -- "-map 0:a?" "$FFMPEG_LOG_FILE"
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
