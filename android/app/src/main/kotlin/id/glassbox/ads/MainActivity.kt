package id.glassbox.ads

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.app.ActivityManager
import android.os.Process
import android.os.Bundle
import java.util.Calendar
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "gb_channel"
    private val PERMISSION_REQUEST_CODE = 1001
    private val KILL_PERMISSION_CODE = 1002
    private lateinit var powerManager: PowerManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToWifi" -> {
                    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CHANGE_WIFI_STATE) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.CHANGE_WIFI_STATE), PERMISSION_REQUEST_CODE)
                    } else {
                        connectToWifiManager(call, result)
                    }
                }
                "getAndroidId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId)
                }
                "openDeveloperOptions" -> {
                    openDeveloperOptions()
                    result.success("Developer options opened")
                }
                "openWifiSettings" -> {
                    openWifiSettings()
                    result.success("Opened Wi-Fi Settings")
                }
                "putToSleep" -> {
                    try {
                        Log.i("DeviceControl", "Starting sleep sequence")
                        
                        // 1. First kill the app completely
                        Log.i("DeviceControl", "Stopping app")
                        finishAffinity() // Close all activities
                        finishAndRemoveTask() // Remove from recent tasks
                        
                        // 2. Force stop our own process
                        Log.i("DeviceControl", "Killing process")
                        Handler(Looper.getMainLooper()).postDelayed({
                            try {
                                // Send power key event before killing process
                                Runtime.getRuntime().exec("input keyevent 26")
                                Log.i("DeviceControl", "Sleep command sent")
                                
                                // Kill the process
                                Process.killProcess(Process.myPid())
                            } catch (e: Exception) {
                                Log.e("DeviceControl", "Error in delayed execution", e)
                            }
                        }, 1000) // 1 second delay
                        
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e("DeviceControl", "Failed to execute sleep sequence", e)
                        result.error("SLEEP_ERROR", "Failed to put device to sleep", e.toString())
                    }
                }
                "wakeDevice" -> {
                    try {
                        Log.i("DeviceControl", "Attempting to wake device")
                        
                        val wakeLock = powerManager.newWakeLock(
                            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                            "id.glassbox.ads:WakeLock"
                        )
                        wakeLock.acquire(1000)
                        
                        // Also try power key event if screen is off
                        if (!powerManager.isInteractive) {
                            Runtime.getRuntime().exec("input keyevent 26")
                        }
                        
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e("DeviceControl", "Failed to wake device", e)
                        result.error("WAKE_ERROR", "Failed to wake device", e.toString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Handle permission request result
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.i("Permission", "Wi-Fi permission granted.")
            } else {
                Log.e("Permission", "Wi-Fi permission denied.")
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun connectToWifiManager(call: MethodCall, result: MethodChannel.Result) {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        if (!wifiManager.isWifiEnabled) {
            wifiManager.isWifiEnabled = true
        }

        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")

        if (ssid != null && password != null) {
            connectToWifi(ssid, password, result)
        } else {
            result.error("INVALID_ARGUMENTS", "SSID or password is missing", null)
        }
    }

    private fun connectToWifi(ssid: String?, password: String?, result: MethodChannel.Result) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            // Android 10+ logic: Users need to manually connect via Wi-Fi settings
            openWifiSettings(result)
        } else {
            // Android < 10 logic
            connectToWifiForOlderVersions(ssid, password, result)
        }
    }

    private fun openWifiSettings(result: MethodChannel.Result) {
        Log.i("WifiConnection", "Android 10 and above: Opening Wi-Fi settings for manual connection.")
        val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
        startActivity(intent)
        result.success("Opened Wi-Fi settings")
    }

    private fun connectToWifiForOlderVersions(ssid: String?, password: String?, result: MethodChannel.Result) {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiConfig = WifiConfiguration().apply {
            SSID = "\"$ssid\""
            preSharedKey = "\"$password\""
        }

        val netId = wifiManager.addNetwork(wifiConfig)
        if (netId != -1) {
            wifiManager.disconnect()
            wifiManager.enableNetwork(netId, true)
            wifiManager.reconnect()
            Log.i("WifiConnection", "Connected to $ssid")
            result.success("Connected to $ssid")
        } else {
            Log.e("WifiConnection", "Unable to connect to $ssid")
            result.error("CONNECTION_FAILED", "Unable to connect to $ssid", null)
        }
    }

    private fun openDeveloperOptions() {
        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        startActivity(intent)
    }

    private fun openWifiSettings() {
        val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
        startActivity(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Request boot permission if needed
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECEIVE_BOOT_COMPLETED)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.RECEIVE_BOOT_COMPLETED),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    // Add method to check if we should start based on time
    private fun shouldStartApp(): Boolean {
        val calendar = Calendar.getInstance()
        val hour = calendar.get(Calendar.HOUR_OF_DAY)
        return hour >= 9 && hour < 22  // Match your scheduler service times
    }
}
