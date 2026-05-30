#!/usr/bin/env bats

load test_helper

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
