package com.example.focus_launcher

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.provider.Settings // Import Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.focuslauncher/app_ops"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        launchApp(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                    }
                }
                "openDefaultLauncherSettings" -> {
                    openDefaultLauncherSettings(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(0)
        val appList = mutableListOf<Map<String, String>>()
        for (appInfo in apps) {
            // Filter out system apps if desired, or apps without launch intents
            if (pm.getLaunchIntentForPackage(appInfo.packageName) != null) {
                 val appName = appInfo.loadLabel(pm).toString()
                 val packageName = appInfo.packageName
                 appList.add(mapOf("name" to appName, "packageName" to packageName))
            }
        }
        return appList
    }

    private fun launchApp(packageName: String) {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                // Add FLAG_ACTIVITY_NEW_TASK to launch the app in a new task
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } else {
                // Optionally, inform Flutter that the app could not be launched
                // This could be done via another MethodChannel call or by returning an error
                println("Could not get launch intent for package: $packageName")
            }
        } catch (e: Exception) {
            // Handle exceptions, e.g., ActivityNotFoundException
             println("Error launching app $packageName: ${e.message}")
        }
    }

    private fun openDefaultLauncherSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            println("Error opening default launcher settings: ${e.message}")
            result.error("ERROR_OPENING_SETTINGS", "Could not open default home settings.", e.message)
        }
    }
}
