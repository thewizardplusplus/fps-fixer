# FPS Fixer

![](docs/screenshot.png)

The utility for fixing FPS in videos.

## Features

- search of videos:
  - filtering by a video file extension;
  - skipping videos with near target FPS;
- fixing FPS in videos that have FPS less than or greater than the specified FPS;
- automatic directory creation for fixed videos;
- logging:
  - logging of a video name and FPS at the beginning of processing;
  - logging of a fixed video path at the end of processing.

## Requirements

- [FFmpeg](https://ffmpeg.org/) >=4.4.2, <5.0.

## Usage

```
$ fps_fixer.bash -v | --version
$ fps_fixer.bash -h | --help
$ fps_fixer.bash [options]
```

Options:

- `-v`, `--version` &mdash; show the version;
- `-h`, `--help` &mdash; show the help;
- `VIDEO_EXTENSION` &mdash; video file extension (default: `mp4`);
- `FIXED_VIDEO_BASE_PATH` &mdash; base path for fixed videos (default: `./fixed-videos`);
- `TARGET_FPS` &mdash; target FPS (default: `60`);
- `FPS_EPSILON` &mdash; allowable error when comparing FPS (default: `2`).

## License

The MIT License (MIT)

Copyright &copy; 2023 thewizardplusplus
