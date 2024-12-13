import 'package:flutter/material.dart';
import '../services/scheduler_service.dart';

class SchedulerProvider extends ChangeNotifier {
  SchedulerService? _schedulerService;

  void initialize(BuildContext context) {
    _schedulerService = SchedulerService();
  }

  bool isActiveTime() {
    return _schedulerService?.isActiveTime() ?? false;
  }

  void dispose() {
    _schedulerService?.dispose();
    super.dispose();
  }
} 