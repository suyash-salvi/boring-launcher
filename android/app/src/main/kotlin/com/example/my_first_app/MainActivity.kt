package com.example.my_first_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.boring.launcher/unlock"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_USER_PRESENT)
        registerReceiver(unlockReceiver, filter)
    }

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_USER_PRESENT) {
                methodChannel?.invokeMethod("onUnlock", null)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(unlockReceiver)
    }
}
