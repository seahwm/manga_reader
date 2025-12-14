package com.example.manga_reader

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream

class MainActivity : FlutterActivity() {
    // 定义 MethodChannel，名称必须与 Flutter 端的一致
    private val CHANNEL = "com.example.manga_reader/image_loader"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "loadImage") {
                // 获取从 Flutter 传递过来的 'uri' 参数
                val uriString = call.argument<String>("uri")
                if (uriString != null) {
                    try {
                        // 在原生端处理 URI
                        val uri = android.net.Uri.parse(uriString)
                        val inputStream: InputStream? = contentResolver.openInputStream(uri)

                        // 将 InputStream 的数据读取到 ByteArray
                        val byteArray = inputStream?.readBytes()
                        inputStream?.close()

                        // 将 ByteArray 返回给 Flutter
                        result.success(byteArray)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot load image from URI: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_URI", "URI string is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
