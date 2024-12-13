class LoginRequest {
  final String deviceId;
  final String deviceName;
  final String operatingSystem;
  final String deviceDetail;

  LoginRequest({
    required this.deviceId,
    required this.deviceName,
    required this.operatingSystem,
    this.deviceDetail = "{}",
  });

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'device_name': deviceName,
    'operating_system': operatingSystem,
    'device_detail': deviceDetail,
  };
} 