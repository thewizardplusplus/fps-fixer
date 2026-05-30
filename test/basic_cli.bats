#!/usr/bin/env bats

load test_helper

@test "[$(test_file_group)] -v and --version exit 0" {
  run "$SCRIPT" -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]

  run "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"FPS Fixer, v1.1.0"* ]]
}

@test "[$(test_file_group)] -h and --help exit 0" {
  run "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]

  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "[$(test_file_group)] unknown option exits 1" {
  run "$SCRIPT" --unknown
  [ "$status" -eq 1 ]
}

@test "[$(test_file_group)] too many positional args exits 1" {
  run "$SCRIPT" foo bar
  [ "$status" -eq 1 ]
}
