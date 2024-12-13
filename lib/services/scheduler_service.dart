import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SchedulerService {
  static const String _lastCheckKey = 'last_scheduler_check';
  static const platform = MethodChannel('gb_channel');
  Timer? _schedulerTimer;
  bool _isInitialized = false;
  late final VoidCallback? onWakeUp;  // Callback for wake up events

  // Default schedule times
  static const int startHour = 8;  // 9 AM
  static const int endHour = 22;   // 10 PM

  static final SchedulerService _instance = SchedulerService._internal();
  
  factory SchedulerService({VoidCallback? onWakeUp}) {
    _instance.onWakeUp = onWakeUp;
    return _instance;
  }
  
  SchedulerService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('Initializing SchedulerService at ${DateTime.now()}');
    debugPrint('Schedule: Active from $startHour:00 to $endHour:00');
    
    await _checkSchedule(); // Immediate check on startup
    _initializeScheduler();
    _isInitialized = true;
  }

  void _initializeScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer =
        Timer.periodic(const Duration(minutes: 120), (_) => _checkSchedule());
    debugPrint('Scheduler timer initialized');
  }

  Future<void> _checkSchedule() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    debugPrint('''
Schedule Check at $currentHour:$currentMinute
--------------------
Current time: $now
Active hours: $startHour:00 to $endHour:00
Should be active: ${_shouldBeActive(now)}
''');

    // Get last check time
    final lastCheckStr = prefs.getString(_lastCheckKey);
    final lastCheck = lastCheckStr != null ? DateTime.parse(lastCheckStr) : null;
    
    if (lastCheck != null) {
      debugPrint('Last check: $lastCheck');
    }

    // Save current check time
    await prefs.setString(_lastCheckKey, now.toIso8601String());

    // Check if we need to change state
    if (_shouldBeActive(now)) {
      debugPrint('Current time is within active hours');
      if (lastCheck != null && !_shouldBeActive(lastCheck)) {
        debugPrint('Transitioning to active state');
        await _wakeDevice();
      }
    } else {
      debugPrint('Current time is outside active hours');
      // Always try to put device to sleep when outside active hours
      // This ensures the device stays in sleep mode
      await _putDeviceToSleep();
      debugPrint('Sleep command sent');
    }
  }

  bool _shouldBeActive(DateTime time) {
    final hour = time.hour;
    debugPrint('Checking hour $hour: ${hour >= startHour && hour < endHour}');
    return hour >= startHour && hour < endHour;
  }

  Future<void> _wakeDevice() async {
    debugPrint('Attempting to wake device at ${DateTime.now()}');
    try {
      await platform.invokeMethod('wakeDevice');
      debugPrint('Wake device command sent successfully');
      
      // Give the device a moment to wake up
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if we're in the correct time window
      if (_shouldBeActive(DateTime.now())) {
        // Call the wake up callback if provided
        onWakeUp?.call();
      }
    } catch (e) {
      debugPrint('Error waking device: $e');
    }
  }

  Future<void> _putDeviceToSleep() async {
    debugPrint('Starting sleep sequence at ${DateTime.now()}');
    try {
      // 1. Notify app to cleanup resources
      debugPrint('Triggering app cleanup');
      SystemChannels.lifecycle.send(AppLifecycleState.paused.toString());
      
      // 2. Small delay to ensure cleanup
      await Future.delayed(const Duration(seconds: 1));
      
      // 3. Send sleep command to platform
      debugPrint('Sending sleep command to platform');
      await platform.invokeMethod('putToSleep');
      
      // 4. Force exit the app
      debugPrint('Forcing app exit');
      await Future.delayed(const Duration(milliseconds: 500));
      SystemNavigator.pop(animated: false);
    } catch (e) {
      debugPrint('Error during sleep sequence: $e');
      // Try force exit anyway
      SystemNavigator.pop(animated: false);
    }
  }

  void dispose() {
    _schedulerTimer?.cancel();
    _isInitialized = false;
    debugPrint('SchedulerService disposed');
  }

  bool isActiveTime() {
    final now = DateTime.now();
    final isActive = _shouldBeActive(now);
    debugPrint(
        'Checking if current time (${now.hour}:${now.minute}) is active: $isActive');
    return isActive;
  }
}
