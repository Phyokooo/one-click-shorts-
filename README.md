# One Click Shorts — FFmpeg + TTS edition

This version adds real on-device rendering:

1. Select photos or a video.
2. Enter Burmese text.
3. Generate speech with the Android TTS engine.
4. FFmpeg renders a 1080x1920 (9:16) MP4.
5. H.264 video + AAC audio.
6. Text is burned onto the video using Noto Sans Myanmar when available.
7. Share the resulting MP4 from the app.

## Dependencies

- `flutter_tts: ^4.2.5`
- `ffmpeg_kit_flutter_new: ^4.6.2`
- `share_plus: ^10.1.4`
- `image_picker`
- `path_provider`
- `video_player`

## Run

```bash
flutter pub get
flutter run
```

## Release APK

```bash
flutter build apk --release
```

The APK will be under:

`build/app/outputs/flutter-apk/release/app-release.apk`

## Notes

- Burmese TTS depends on the Android device's installed TTS engine and available voice. The app requests `my-MM` first and falls back if unavailable.
- FFmpegKit's maintained fork is used rather than the old discontinued package.
- Image projects use 3 seconds per image and stop when the generated voice ends.
- Video projects use the first selected video and stop at 60 seconds or when the voice ends.
- Music, automatic scene timing, cloud AI voice, and AI-generated images are not included in this local/offline build.
