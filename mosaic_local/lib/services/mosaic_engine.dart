import 'dart:async';
import 'dart:convert';

import 'package:flutter_gemma/flutter_gemma.dart';

import '../domain/models.dart';
import 'benchmark.dart';

enum EngineState { modelMissing, loading, ready, generating, error }
enum MosaicBackend { gpu, cpu }

class GenerationOutput {
  const GenerationOutput({required this.campaign, required this.benchmark});
  final Campaign campaign;
  final BenchmarkResult benchmark;
}

class MosaicEngine {
  static const modelName = 'Gemma 3 1B IT INT4';
  static const contextTokens = 2048;
  static const outputTokens = 900;

  InferenceModel? _model;
  MosaicBackend backend = MosaicBackend.gpu;
  EngineState state = EngineState.modelMissing;
  String? error;

  Future<void> installFromFile(String path) async {
    state = EngineState.loading;
    try {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromFile(path)
          .install();
      await load();
    } catch (exception) {
      state = EngineState.error;
      error = exception.toString();
      rethrow;
    }
  }

  Future<void> installFromNetwork(String url, {String? token}) async {
    state = EngineState.loading;
    try {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromNetwork(url, token: token)
          .install();
      await load();
    } catch (exception) {
      state = EngineState.error;
      error = exception.toString();
      rethrow;
    }
  }

  Future<void> load({MosaicBackend? useBackend}) async {
    state = EngineState.loading;
    try {
      if (useBackend != null) backend = useBackend;
      await _model?.close();
      _model = await FlutterGemma.getActiveModel(
        maxTokens: contextTokens,
        maxConcurrentSessions: 1,
        preferredBackend: backend == MosaicBackend.gpu
            ? PreferredBackend.gpu
            : PreferredBackend.cpu,
      );
      state = EngineState.ready;
    } catch (exception) {
      state = EngineState.modelMissing;
      error = exception.toString();
    }
  }

  Future<GenerationOutput> createCampaign(
    BrandProfile brand, {
    void Function(String stage)? onStage,
    void Function(String token)? onToken,
  }) async {
    final model = _model;
    if (model == null) throw StateError('Install and load the local model first.');
    state = EngineState.generating;
    onStage?.call('Strategist is designing the campaign');

    final chat = await model.createChat(
      maxOutputTokens: outputTokens,
      systemInstruction: _systemPrompt,
    );
    final prompt = _campaignPrompt(brand);
    await chat.addQueryChunk(Message.text(text: prompt, isUser: true));

    final buffer = StringBuffer();
    final benchmark = BenchmarkRecorder()..start();
    await for (final response in chat.generateChatResponseAsync()) {
      if (response is TextResponse) {
        buffer.write(response.token);
        benchmark.token(response.token);
        onToken?.call(response.token);
      }
    }

    onStage?.call('Brand guardian is validating the output');
    final decoded = decodeObject(buffer.toString());
    final campaign = Campaign(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: decoded['campaign_name'] as String,
      strategy: decoded['strategy'] as String,
      posts: (decoded['posts'] as List)
          .map((post) => CampaignPost.fromJson(post as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.now(),
    );
    state = EngineState.ready;
    return GenerationOutput(
      campaign: campaign,
      benchmark: benchmark.finish(
        backend: backend == MosaicBackend.gpu
            ? 'Arm GPU / LiteRT-LM'
            : 'Arm CPU / LiteRT-LM',
        model: modelName,
      ),
    );
  }

  Future<String> revisePost({
    required BrandProfile brand,
    required CampaignPost post,
    required String instruction,
  }) async {
    final model = _model;
    if (model == null) throw StateError('Install and load the local model first.');
    final chat = await model.createChat(
      maxOutputTokens: 300,
      systemInstruction:
          'You are Mosaic Copywriter. Return only the revised caption, no commentary.',
    );
    await chat.addQueryChunk(Message.text(
      text: 'Brand: ${jsonEncode(brand.toJson())}\n'
          'Original post: ${jsonEncode(post.toJson())}\n'
          'Revision request: $instruction',
      isUser: true,
    ));
    final response = await chat.generateChatResponse();
    return response is TextResponse ? response.token : response.toString();
  }

  Future<void> close() async => _model?.close();

  Future<void> unload() async {
    await _model?.close();
    _model = null;
    state = EngineState.modelMissing;
  }

  static const _systemPrompt = '''
You are Mosaic Local, an expert Caribbean marketing team running privately on a phone.
Act as strategist, copywriter, visual director, and brand guardian.
Use natural regional context without stereotypes, forced dialect, or invented facts.
Never claim live research or current trends because the device is offline.
Return valid JSON only. No markdown fences and no prose outside JSON.
Schema:
{
  "campaign_name": "string",
  "strategy": "2 concise sentences",
  "posts": [
    {
      "day": 1,
      "pillar": "Awareness|Consideration|Conversion",
      "hook": "string",
      "caption": "string",
      "cta": "string",
      "visual": "specific Caribbean-context art direction",
      "hashtags": ["#tag"],
      "approved": false
    }
  ]
}
Create exactly 3 posts, one for each pillar. Keep the entire JSON concise.
''';

  String _campaignPrompt(BrandProfile brand) => '''
Build a three-post campaign from this on-device brand manifest:
${jsonEncode(brand.toJson())}
The writing must sound specific to this brand, preserve its voice, and lead toward its goal.
''';
}
