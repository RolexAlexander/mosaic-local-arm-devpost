# Mosaic Local

**A complete, private AI marketing team running on an Arm64 Android phone.**

Mosaic Local is the on-device rebuild of Mosaic Marketing. It transforms a brand profile into campaign strategy, finished copy, calls to action, hashtags, and Caribbean-aware visual direction without cloud inference, running entirely on the Arm processor in your phone.

---

## Architecture & Features

```text
Flutter UI
  ├─ Brand manifest + local campaign store
  ├─ Deterministic Mosaic orchestrator
  │    ├─ Strategist prompt
  │    ├─ Copywriter prompt
  │    ├─ Visual director prompt
  │    └─ Brand guardian contract
  └─ LiteRT-LM
       └─ Gemma 3 1B IT INT4
            └─ Arm64 GPU / optimized CPU fallback

Creative Engine
  └─ Llamatik Android bridge
       └─ stable-diffusion.cpp
            └─ SD-Turbo GGUF → local PNG
```

### Key Features
- **Private Brand Onboarding:** Complete offline profiling of Guyana and Caribbean brands.
- **Multi-Agent Orchestration:** Strategist, copywriter, visual director, and brand guardian roles over one loaded model weight set to conserve memory.
- **On-device Image Generation:** Uses `stable-diffusion.cpp` for native 512×512 image creation.
- **Airplane Mode Operation:** Once models are installed, the app works entirely offline with zero network calls.
- **Arm-Optimized:** GPU-preferred LiteRT-LM execution, memory-safe Gemma → diffusion → Gemma lifecycle.

---

## Project Structure

- [mosaic_local/](file:///c:/Users/rolex/Downloads/mosaic-local-arm-devpost/mosaic_local) - The main Flutter application codebase.
- [DEVPOST.md](file:///c:/Users/rolex/Downloads/mosaic-local-arm-devpost/DEVPOST.md) - Devpost hackathon submission details.
- [ARM_OPTIMIZATION.md](file:///c:/Users/rolex/Downloads/mosaic-local-arm-devpost/ARM_OPTIMIZATION.md) - Benchmark details, optimization methodologies, and hardware-specific configurations.

---

## Getting Started

### Requirements
- Flutter stable compatible with Dart 3.3+
- Android SDK and a physical 64-bit Arm Android device
- A Gemma 3 1B IT INT4 `.litertlm` model URL
- An SD-Turbo or compatible self-contained diffusion GGUF (about 2 GB)

### Running Locally

To build and run the application:

```bash
cd mosaic_local
flutter create --platforms android --org gy.onetech .
flutter pub get
flutter run --release
```

To build a release Android APK targetting Arm64:
```bash
flutter build apk --release --target-platform android-arm64
```

For detailed setup, verification, and testing procedures, check out [mosaic_local/README.md](file:///c:/Users/rolex/Downloads/mosaic-local-arm-devpost/mosaic_local/README.md).

## License

This project is licensed under the MIT License - see [LICENSE](file:///c:/Users/rolex/Downloads/mosaic-local-arm-devpost/mosaic_local/LICENSE) for details.
