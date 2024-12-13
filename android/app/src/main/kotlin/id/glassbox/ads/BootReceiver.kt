package id.glassbox.ads

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            Log.i("BootReceiver", "Device boot completed, starting app")
            
            // Create intent to launch the app
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            
            // Add a small delay to ensure system is fully booted
            android.os.Handler().postDelayed({
                try {
                    context.startActivity(launchIntent)
                    Log.i("BootReceiver", "App started successfully")
                } catch (e: Exception) {
                    Log.e("BootReceiver", "Failed to start app", e)
                }
            }, 10000) // 10 second delay
        }
    }
} 