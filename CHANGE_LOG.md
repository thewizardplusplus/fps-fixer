# Change Log

## [v1.2.0](https://github.com/thewizardplusplus/fps-fixer/tree/v1.2.0) (2026-07-11)

Add video speed adjustment and audio removal, improve FPS detection and processing controls, support a single video file as input, and introduce an automated test suite.

- search of videos:
  - support a single video file as input;
  - skipping videos with near target FPS:
    - use `ffprobe` to detect video FPS, including fractional frame rates;
    - treat FPS values at the epsilon boundary as matching the target;
    - validate and normalize the FPS and epsilon options, including comma decimal notation;
- video correction:
  - add optional acceleration or deceleration of output videos;
  - add the option to remove audio from output videos;
  - map video and optional audio streams explicitly;
  - produce constant-frame-rate output;
- the additional modes:
  - add the force mode to process videos regardless of their current FPS;
  - avoid creating the output directory in the mode without real video processing;
- add a [Bats](https://bats-core.readthedocs.io/) test suite, with coverage of:
  - basic CLI behavior;
  - numeric option validation and normalization;
  - file discovery for directory and single-file inputs;
  - FPS detection, comparison, and processing;
  - video acceleration and audio handling;
  - processing, probing, and metadata error handling;
  - additional modes and output path construction.

## [v1.1.0](https://github.com/thewizardplusplus/fps-fixer/tree/v1.1.0) (2023-09-05)

Improve logging, parse the options via CLI, handle processing errors, add support for specifying a base path to original videos, and add the mode without real processing of videos.

- parse the options via CLI;
- handle processing errors;
- add support for specifying a base path to original videos;
- add the mode without real processing of videos, only with search of them and check of their FPS;
- improve logging:
  - colorize log messages;
  - add to log messages:
    - add timestamps to log messages;
    - add log levels to log messages.

## [v1.0.0](https://github.com/thewizardplusplus/fps-fixer/tree/v1.0.0) (2023-09-05)

The major version.
