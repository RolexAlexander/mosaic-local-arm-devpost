class BenchmarkResult {
  const BenchmarkResult({
    required this.firstTokenMs,
    required this.totalMs,
    required this.outputCharacters,
    required this.backend,
    required this.model,
  });

  final int firstTokenMs;
  final int totalMs;
  final int outputCharacters;
  final String backend;
  final String model;

  double get estimatedTokensPerSecond {
    final seconds = totalMs / 1000;
    return seconds == 0 ? 0 : (outputCharacters / 4) / seconds;
  }

  Map<String, dynamic> toJson() => {
        'first_token_ms': firstTokenMs,
        'total_ms': totalMs,
        'estimated_tokens_per_second': estimatedTokensPerSecond,
        'output_characters': outputCharacters,
        'backend': backend,
        'model': model,
      };
}

class BenchmarkRecorder {
  final Stopwatch _total = Stopwatch();
  int? _firstTokenMs;
  int _characters = 0;

  void start() => _total.start();

  void token(String value) {
    _firstTokenMs ??= _total.elapsedMilliseconds;
    _characters += value.length;
  }

  BenchmarkResult finish({required String backend, required String model}) {
    _total.stop();
    return BenchmarkResult(
      firstTokenMs: _firstTokenMs ?? _total.elapsedMilliseconds,
      totalMs: _total.elapsedMilliseconds,
      outputCharacters: _characters,
      backend: backend,
      model: model,
    );
  }
}

