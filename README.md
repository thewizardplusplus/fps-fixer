# FPS Fixer

## Requirements

- [FFmpeg](https://ffmpeg.org/) >=4.4.2, <5.0.

## Usage

```
$ fps_fixer.bash
```

Environment variables:

- `VIDEO_EXTENSION` &mdash; video file extension (default: `mp4`);
- `FIXED_VIDEO_BASE_PATH` &mdash; base path for fixed videos (default: `./fixed-videos`);
- `TARGET_FPS` &mdash; target FPS (default: `60`);
- `FPS_EPSILON` &mdash; allowable error when comparing FPS (default: `2`).

## License

The MIT License (MIT)

Copyright &copy; 2023 thewizardplusplus
