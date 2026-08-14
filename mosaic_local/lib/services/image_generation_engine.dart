import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum CreativeEngineState { missing, downloading, loading, ready, generating, error }

class ImageGenerationResult {
  const ImageGenerationResult({
    required this.path,
    required this.elapsedMs,
    required this.width,
    required this.height,
    required this.steps,
    required this.seed,
  });

  final String path;
  final int elapsedMs;
  final int width;
  final int height;
  final int steps;
  final int seed;

  Map<String, dynamic> toJson() => {
        'path': path,
        'elapsed_ms': elapsedMs,
        'width': width,
        'height': height,
        'steps': steps,
        'seed': seed,
        'network_calls': 0,
        'runtime': 'stable-diffusion.cpp',
      };
}

class ImageGenerationEngine {
  static const _channel = MethodChannel('gy.onetech.mosaic/diffusion');
  CreativeEngineState state = CreativeEngineState.missing;
  String? modelPath;
  String? error;

  Future<String?> restoreModel() async {
    final directory = await getApplicationSupportDirectory();
    final modelDirectory = Directory('${directory.path}/models');
    if (!await modelDirectory.exists()) return null;
    final candidates = await modelDirectory
        .list()
        .where((entry) => entry is File && !entry.path.endsWith('.partial'))
        .cast<File>()
        .toList();
    if (candidates.isEmpty) return null;
    modelPath = candidates.first.path;
    return modelPath;
  }

  Future<String> downloadModel(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    state = CreativeEngineState.downloading;
    final directory = await getApplicationSupportDirectory();
    final modelDirectory = Directory('${directory.path}/models');
    await modelDirectory.create(recursive: true);
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.isEmpty ? 'mosaic-image-model.gguf' : uri.pathSegments.last;
    final target = File('${modelDirectory.path}/$fileName');
    final partial = File('${target.path}.partial');
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Model download failed: HTTP ${response.statusCode}');
      }
      final total = response.contentLength;
      var received = 0;
      final sink = partial.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.close();
      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
      modelPath = target.path;
      state = CreativeEngineState.missing;
      return target.path;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> initialize(String path, {int threads = 4}) async {
    state = CreativeEngineState.loading;
    try {
      final initialized = await _channel.invokeMethod<bool>('initialize', {
            'modelPath': path,
            'threads': threads,
          }) ??
          false;
      if (!initialized) throw StateError('The diffusion model could not be loaded.');
      modelPath = path;
      state = CreativeEngineState.ready;
    } catch (exception) {
      state = CreativeEngineState.error;
      error = exception.toString();
      rethrow;
    }
  }

  Future<ImageGenerationResult> generate({
    required String prompt,
    String negativePrompt = 'blurry, distorted, low quality, watermark, text artifacts',
    int width = 512,
    int height = 512,
    int steps = 8,
    double cfgScale = 7,
    int seed = -1,
  }) async {
    state = CreativeEngineState.generating;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('generate', {
        'prompt': prompt,
        'negativePrompt': negativePrompt,
        'width': width,
        'height': height,
        'steps': steps,
        'cfgScale': cfgScale,
        'seed': seed,
      });
      if (result == null || result['path'] == null) {
        throw StateError('The native image engine returned no image.');
      }
      state = CreativeEngineState.ready;
      return ImageGenerationResult(
        path: result['path']! as String,
        elapsedMs: result['elapsedMs']! as int,
        width: width,
        height: height,
        steps: steps,
        seed: result['seed']! as int,
      );
    } catch (exception) {
      state = CreativeEngineState.error;
      error = exception.toString();
      rethrow;
    }
  }

  Future<void> release() async {
    await _channel.invokeMethod<void>('release');
    state = CreativeEngineState.missing;
  }
}
