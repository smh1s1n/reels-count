class ReelEvent {
  final String id;
  final String appName;
  final DateTime timestamp;
  final double dwellSeconds;

  const ReelEvent({
    required this.id,
    required this.appName,
    required this.timestamp,
    required this.dwellSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appName': appName,
      'timestamp': timestamp.toIso8601String(),
      'dwellSeconds': dwellSeconds,
    };
  }

  factory ReelEvent.fromMap(Map<String, dynamic> map) {
    return ReelEvent(
      id: map['id'] as String? ?? '',
      appName: map['appName'] as String? ?? 'unknown',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      dwellSeconds: (map['dwellSeconds'] as num?)?.toDouble() ?? 1.5,
    );
  }
}
