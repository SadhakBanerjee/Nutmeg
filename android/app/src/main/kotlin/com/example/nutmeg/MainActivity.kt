package com.example.nutmeg

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Remove native splash screen immediately
        super.onCreate(savedInstanceState)
    }
}
