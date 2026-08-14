import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_local/domain/models.dart';
import 'package:mosaic_local/services/image_generation_engine.dart';

void main() {
  test('parses JSON surrounded by model noise', () {
    final result = decodeObject('prefix {"campaign_name":"Launch"} suffix');
    expect(result['campaign_name'], 'Launch');
  });

  test('brand manifest round trips without losing regional context', () {
    const profile = BrandProfile(
      name: 'Demo',
      product: 'Service',
      audience: 'Small businesses',
      voice: 'Confident',
      goal: 'Book demos',
    );
    final restored = BrandProfile.fromJson(profile.toJson());
    expect(restored.region, 'Guyana and the Caribbean');
  });

  test('image benchmark records offline native generation', () {
    const result = ImageGenerationResult(
      path: '/local/image.png',
      elapsedMs: 1200,
      width: 512,
      height: 512,
      steps: 4,
      seed: 42,
    );
    expect(result.toJson()['network_calls'], 0);
    expect(result.toJson()['runtime'], 'stable-diffusion.cpp');
  });
}
