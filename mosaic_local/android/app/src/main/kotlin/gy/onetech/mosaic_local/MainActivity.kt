package gy.onetech.mosaic_local

import android.graphics.Bitmap
import com.llamatik.library.platform.StableDiffusionBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors
import kotlin.math.max

class MainActivity : FlutterActivity() {
    private val channelName = "gy.onetech.mosaic/diffusion"
    private val inferenceExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        val modelPath = call.argument<String>("modelPath")
                        val threads = call.argument<Int>("threads") ?: 4
                        if (modelPath.isNullOrBlank()) {
                            result.error("MODEL_PATH", "A local diffusion model path is required.", null)
                            return@setMethodCallHandler
                        }
                        inferenceExecutor.execute {
                            try {
                                val loaded = StableDiffusionBridge.initModel(modelPath, threads)
                                runOnUiThread { result.success(loaded) }
                            } catch (error: Throwable) {
                                runOnUiThread {
                                    result.error("MODEL_LOAD", error.message ?: "Failed to load model", null)
                                }
                            }
                        }
                    }

                    "generate" -> generateImage(call.arguments as Map<*, *>, result)

                    "release" -> {
                        inferenceExecutor.execute {
                            StableDiffusionBridge.release()
                            runOnUiThread { result.success(null) }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun generateImage(arguments: Map<*, *>, result: MethodChannel.Result) {
        val prompt = arguments["prompt"] as? String
        if (prompt.isNullOrBlank()) {
            result.error("PROMPT", "An image prompt is required.", null)
            return
        }
        val negativePrompt = arguments["negativePrompt"] as? String
        val width = (arguments["width"] as? Int) ?: 512
        val height = (arguments["height"] as? Int) ?: 512
        val steps = (arguments["steps"] as? Int) ?: 8
        val cfgScale = ((arguments["cfgScale"] as? Number)?.toFloat()) ?: 7f
        val requestedSeed = ((arguments["seed"] as? Number)?.toLong()) ?: -1L
        val seed = if (requestedSeed < 0) System.currentTimeMillis() else requestedSeed

        inferenceExecutor.execute {
            val started = System.currentTimeMillis()
            try {
                val rgba = StableDiffusionBridge.txt2img(
                    prompt = prompt,
                    negativePrompt = negativePrompt,
                    width = width,
                    height = height,
                    steps = steps,
                    cfgScale = cfgScale,
                    seed = seed,
                )
                if (rgba.size < width * height * 4) {
                    throw IllegalStateException("Diffusion returned an incomplete RGBA buffer")
                }
                val output = saveRgbaAsPng(rgba, width, height, seed)
                val elapsed = System.currentTimeMillis() - started
                runOnUiThread {
                    result.success(
                        mapOf(
                            "path" to output.absolutePath,
                            "elapsedMs" to elapsed,
                            "seed" to seed,
                        )
                    )
                }
            } catch (error: Throwable) {
                runOnUiThread {
                    result.error("GENERATION", error.message ?: "Image generation failed", null)
                }
            }
        }
    }

    private fun saveRgbaAsPng(bytes: ByteArray, width: Int, height: Int, seed: Long): File {
        val pixels = IntArray(width * height)
        for (index in pixels.indices) {
            val offset = index * 4
            val red = bytes[offset].toInt() and 0xff
            val green = bytes[offset + 1].toInt() and 0xff
            val blue = bytes[offset + 2].toInt() and 0xff
            val alpha = bytes[offset + 3].toInt() and 0xff
            pixels[index] = (alpha shl 24) or (red shl 16) or (green shl 8) or blue
        }
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height)
        val directory = File(filesDir, "generated").apply { mkdirs() }
        val output = File(directory, "mosaic_${System.currentTimeMillis()}_${max(seed, 0)}.png")
        FileOutputStream(output).use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        }
        bitmap.recycle()
        return output
    }

    override fun onDestroy() {
        inferenceExecutor.execute { StableDiffusionBridge.release() }
        inferenceExecutor.shutdown()
        super.onDestroy()
    }
}
