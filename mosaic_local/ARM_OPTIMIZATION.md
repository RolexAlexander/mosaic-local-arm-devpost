# Arm optimization and validation

Mosaic Local is designed for the Arm Create Mobile AI track. Optimization is
part of the runtime architecture, not a marketing claim.

## Implemented

1. **INT4 weights** — Gemma 3 1B IT uses 4-bit weights, reducing model storage
   and memory bandwidth relative to FP16.
2. **Arm64-only Android artifact** — Gradle restricts the release ABI to
   `arm64-v8a`. Unsupported native packages are not shipped.
3. **LiteRT-LM runtime** — local inference uses LiteRT-LM. On supported Arm
   devices its optimized runtime can use GPU acceleration and optimized CPU
   kernels. The app requests GPU and permits runtime fallback.
4. **One model, multiple specialists** — strategist, copywriter, visual
   director, and brand guardian are prompt roles over one loaded weight set.
   Mosaic does not load four models.
5. **Bounded memory** — one session, a 2,048-token context, and capped output
   prevent unbounded KV-cache growth.
6. **Streaming UI** — tokens are rendered as generated, improving perceived
   latency and exposing time-to-first-token.
7. **Zero inference network traffic** — after the optional one-time model
   installation, prompts and brand data stay on device.
8. **Release shrinking** — R8 and resource shrinking reduce the application
   shell around the model runtime.
9. **Quantized image generation** — the Creative Engine runs a GGUF diffusion
   model through `stable-diffusion.cpp` on the same Arm64 phone.
10. **Mutually exclusive model residency** — Gemma is unloaded before the
    diffusion model loads, then restored after the PNG is saved.
11. **Few-step rendering** — SD-Turbo defaults to 512×512, four denoising steps,
    and CFG 1.0 to keep the mobile workflow practical.

## Device benchmark protocol

Run all measurements on the same physical Arm64 Android phone. Close other
applications, keep the phone unplugged, and record the device and OS version.

1. Install the release APK: `flutter build apk --release --target-platform android-arm64`.
2. Open Model and install a Gemma 3 1B IT INT4 `.litertlm` bundle.
3. Enable airplane mode after installation.
4. Create the included three-post campaign five times.
5. Discard the first warm-up result and average the remaining four.
6. Capture the Arm stats screen after a representative run.
7. Report time to first token, total latency, estimated tokens/second, model
   size, APK size, and peak memory from Android Studio Profiler or Perfetto.
8. Record a second run with `PreferredBackend.cpu` to compare GPU and CPU paths.

Do not publish invented numbers. Paste measured results here:

| Configuration | Model size | Peak memory | TTFT | Tokens/s | Total time |
|---|---:|---:|---:|---:|---:|
| INT4 / Arm GPU | TBD | TBD | TBD | TBD | TBD |
| INT4 / Arm CPU | TBD | TBD | TBD | TBD | TBD |

| Image model | Resolution | Steps | Load time | Render time | Peak memory |
|---|---:|---:|---:|---:|---:|
| SD-Turbo GGUF / Arm | 512×512 | 4 | TBD | TBD | TBD |

## What Arm contributes

The Android phone is an Arm64 system. LiteRT-LM dispatches the quantized model
to supported device backends. Modern LiteRT/XNNPACK integrations can use Arm
optimized kernels such as KleidiAI automatically on compatible devices. We do
not claim SME2 acceleration unless the tested phone exposes an SME2-capable
Armv9 CPU and profiling confirms that path.
