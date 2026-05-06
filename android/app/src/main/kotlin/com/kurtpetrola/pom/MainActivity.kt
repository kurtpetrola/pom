package com.kurtpetrola.pom

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Start a lightweight service so Android calls onTaskRemoved()
        // when the user swipes the app from recents.
        startService(Intent(this, TaskRemovedService::class.java))
    }
}
