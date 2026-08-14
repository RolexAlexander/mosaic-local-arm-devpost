# Devpost submission draft

![Mosaic Local Banner](../banner.png)

## Project name

Mosaic Local

## Tagline

Your private AI marketing team, running entirely on the Arm processor in your phone.

## Inspiration

Small businesses across Guyana and the Caribbean need high-quality marketing,
but a cloud AI workflow creates recurring cost, requires reliable connectivity,
and sends sensitive brand plans outside the business. We rebuilt Mosaic's
cloud multi-agent workflow as a local mobile system.

## What it does

Mosaic Local turns a private brand profile into a structured three-post
campaign. An offline strategist chooses the campaign arc, a copywriter creates
the posts, a visual director supplies Caribbean-aware art direction, and a
brand guardian enforces the selected voice. Users can approve posts and retain
versioned campaign records on their phone. After model installation, the full
workflow works in airplane mode.
The Creative Engine then renders the selected campaign direction into a final
512×512 image locally through stable-diffusion.cpp.

## How we built it

The interface and deterministic orchestration are built in Flutter. A Gemma 3
1B instruction model is quantized to INT4 and executed through LiteRT-LM on an
Arm64 Android device. Specialist agents are implemented as structured prompt
roles over one shared model, avoiding duplicate weight memory. JSON contracts
turn model output into native campaign objects. Local preferences provide
private persistence, while an in-app benchmark records first-token and total
generation latency.

## Arm optimization

- Arm64-only release artifact
- 4-bit quantized model weights
- GPU-preferred LiteRT-LM execution with CPU fallback
- One shared model and one active session
- 2,048-token bounded context and capped generation
- Streaming output and on-device metrics
- Zero inference network calls
- Few-step on-device SD-Turbo image generation
- Memory-safe Gemma → diffusion → Gemma lifecycle

Measured results must be inserted from `ARM_OPTIMIZATION.md` before submission.

## Challenges

The cloud version delegated freely to Gemini, Search, and image-generation
services. A phone has finite memory and no live web access. We redesigned the
workflow around a compact model, explicit brand context, structured outputs,
and sequential specialists. We also separated visual direction from image
generation so that the core product remains fast and genuinely offline.

## Accomplishments

- Migrated a real multi-agent product from cloud APIs to local Arm inference.
- Generated complete marketing visuals locally rather than stopping at prompts.
- Preserved the end-to-end marketing workflow without sending brand data away.
- Made performance measurable inside the product.
- Built a reusable pattern for converting cloud agent teams into one efficient
  on-device model with several specialist roles.

## What we learned

Mobile AI optimization is architectural. Quantization matters, but so do
context bounds, session count, shared weights, structured responses, and
avoiding unnecessary inference stages.

## What's next

Next we will add a compact on-device vision model for brand-asset analysis,
LoRA adaptation for Caribbean marketing language, and encrypted SQLite
campaign storage.

## Built with

Flutter, Dart, Kotlin, Gemma 3, LiteRT-LM, flutter_gemma, Llamatik,
stable-diffusion.cpp, Android, Arm64

## Three-minute demo

1. **0:00–0:20** — Problem: cloud cost, privacy, unreliable connectivity.
2. **0:20–0:40** — Show the Arm64/INT4 local-model screen.
3. **0:40–1:10** — Enable airplane mode and show the private brand profile.
4. **1:10–1:50** — Generate a campaign with streaming output.
5. **1:50–2:20** — Generate the final campaign image locally.
6. **2:20–2:38** — Review and approve the posts and visual.
7. **2:38–2:52** — Show Arm performance and zero network calls.
8. **2:52–2:58** — Close with the reusable cloud-to-edge agent pattern.
