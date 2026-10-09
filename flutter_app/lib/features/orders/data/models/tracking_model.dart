class TrackingModel {
  const TrackingModel({
    required this.orderId,
    required this.status,
    required this.location,
    required this.updatedAt,
    required this.timeline,
  });

  final String orderId;
  final String status;
  final String location;
  final DateTime updatedAt;
  final List<String> timeline;

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'in_transit',
      location: json['location']?.toString() ?? 'Pickup Center',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      timeline: (json['timeline'] as List? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'status': status,
    'location': location,
    'updatedAt': updatedAt.toIso8601String(),
    'timeline': timeline,
  };
}
