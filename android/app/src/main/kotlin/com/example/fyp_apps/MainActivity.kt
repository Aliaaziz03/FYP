package com.example.fyp_apps

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Build
import android.os.Environment
import android.util.Log
import android.os.Handler
import android.os.Looper
import android.view.PixelCopy
import android.view.SurfaceView
import android.view.View
import android.view.Window
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity(){
    private val CHANNEL = "com.example.ar_screenshot"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "takeScreenshot") {
                takeScreenshot(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun takeScreenshot(result: MethodChannel.Result) {
        try {
            val surfaceView = findViewById<SurfaceView>(android.R.id.content).rootView
            val window: Window = window
            val bitmap = Bitmap.createBitmap(surfaceView.width, surfaceView.height, Bitmap.Config.ARGB_8888)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val handler = Handler(Looper.getMainLooper()) // ✅ Correctly initialized handler

                PixelCopy.request(window, bitmap, { copyResult ->
                    if (copyResult == PixelCopy.SUCCESS) {
                        try {
                            val file = File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "ar_screenshot.png")
                            val outputStream = FileOutputStream(file)
                            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                            outputStream.flush()
                            outputStream.close()
                            result.success(file.absolutePath)
                        } catch (e: Exception) {
                            result.error("WRITE_ERROR", "Failed to save image", e.message)
                        }
                    } else {
                        result.error("PIXELCOPY_FAILED", "PixelCopy failed", null)
                    }
                }, handler)
            } else {
                result.error("UNSUPPORTED", "Requires Android O or higher", null)
            }
        } catch (e: Exception) {
            result.error("EXCEPTION", "Exception during screenshot", e.message)
        }
    }
}

