import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class ShortsRenderer {
  static String q(String value) => '"${value.replaceAll('"', r'\"')}"';

  static Future<String> render({
    required List<String> mediaPaths,
    required String outputPath,
    required String voicePath,
    required String caption,
  }) async {
    if (mediaPaths.isEmpty) {
      throw Exception('No media selected');
    }

    final hasVideo = _isVideo(mediaPaths.first);

    String command;
    if (hasVideo) {
      command = _videoCommand(
        input: mediaPaths.first,
        voice: voicePath,
        output: outputPath,
        caption: caption,
      );
    } else {
      final listPath = '${outputPath}_images.txt';
      final list = mediaPaths.map((p) {
        final safe = p.replaceAll("'", r"'\''");
        return "file '$safe'\nduration 3";
      }).join('\n');
      await File(listPath).writeAsString('$list\n');

      command = _imageCommand(
        listPath: listPath,
        voice: voicePath,
        output: outputPath,
        caption: caption,
      );
    }

    final session = await FFmpegKit.execute(command);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }

    return outputPath;
  }

  static bool _isVideo(String p) {
    final x = p.toLowerCase();
    return x.endsWith('.mp4') ||
        x.endsWith('.mov') ||
        x.endsWith('.m4v') ||
        x.endsWith('.webm') ||
        x.endsWith('.mkv');
  }

  static String _videoCommand({
    required String input,
    required String voice,
    required String output,
    required String caption,
  }) {
    final text = _escapeDrawText(caption);
    return '-y -i ${q(input)} -i ${q(voice)} '
        '-map 0:v:0 -map 1:a:0 '
        '-vf "scale=1080:1920:force_original_aspect_ratio=increase,'
        'crop=1080:1920,drawtext=fontfile=/system/fonts/NotoSansMyanmar-Regular.ttf:'
        'text=$text:fontcolor=white:fontsize=54:borderw=3:bordercolor=black:'
        'x=(w-text_w)/2:y=h-260" '
        '-t 60 -c:v libx264 -preset veryfast -crf 28 -pix_fmt yuv420p '
        '-c:a aac -b:a 128k -shortest ${q(output)}';
  }

  static String _imageCommand({
    required String listPath,
    required String voice,
    required String output,
    required String caption,
  }) {
    final text = _escapeDrawText(caption);
    return '-y -f concat -safe 0 -i ${q(listPath)} -i ${q(voice)} '
        '-vf "scale=1080:1920:force_original_aspect_ratio=increase,'
        'crop=1080:1920,format=yuv420p,drawtext=fontfile=/system/fonts/NotoSansMyanmar-Regular.ttf:'
        'text=$text:fontcolor=white:fontsize=54:borderw=3:bordercolor=black:'
        'x=(w-text_w)/2:y=h-260" '
        '-c:v libx264 -preset veryfast -crf 28 -pix_fmt yuv420p '
        '-c:a aac -b:a 128k -shortest ${q(output)}';
  }

  static String _escapeDrawText(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(':', r'\:')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');
  }
}
