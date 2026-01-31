/// Scan log model – QR or NFC scan record.
class ScanLog {
  const ScanLog({
    required this.id,
    required this.type,
    required this.value,
    this.userId,
    this.deviceId,
    required this.createdAt,
  });

  final String id;
  final String type; // 'QR' or 'NFC'
  final String value;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      userId: json['user_id'] as String?,
      deviceId: json['device_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'user_id': userId,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
