import 'package:flutter/widgets.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';

import 'app.dart';
import 'services/mosaic_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine()],
  );
  runApp(MosaicApp(engine: MosaicEngine()));
}

