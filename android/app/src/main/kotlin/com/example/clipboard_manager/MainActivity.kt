package com.example.clipboard_manager

import android.content.ClipboardManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "clipboard_manager/clipboard"
    private var clipboardManager: ClipboardManager? = null
    private var clipboardListener: ClipboardManager.OnPrimaryClipChangedListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager?
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBackgroundMonitoring" -> startBackgroundMonitoring()
                "stopBackgroundMonitoring" -> stopBackgroundMonitoring()
                else -> result.notImplemented()
            }
        }
    }

    private fun startBackgroundMonitoring() {
        clipboardListener = ClipboardManager.OnPrimaryClipChangedListener {
            val clipData = clipboardManager?.primaryClip
            if (clipData != null && clipData.itemCount > 0) {
                val text = clipData.getItemAt(0).text.toString()
                sendClipboardTextToFlutter(text)
            }
        }
        clipboardManager?.addPrimaryClipChangedListener(clipboardListener)
    }

    private fun stopBackgroundMonitoring() {
        clipboardListener?.let {
            clipboardManager?.removePrimaryClipChangedListener(it)
        }
    }

    private fun sendClipboardTextToFlutter(text: String) {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod(
                "addHistoryItemFromNative", text)
        }
    }
}
