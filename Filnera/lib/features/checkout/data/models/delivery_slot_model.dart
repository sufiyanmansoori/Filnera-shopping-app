class DeliverySlotModel {
  const DeliverySlotModel({
    required this.id,
    required this.label,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.isExpress = false,
    this.isAvailable = true,
  });

  final String id;
  final String label;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final bool isExpress;
  final bool isAvailable;

  factory DeliverySlotModel.fromJson(Map<String, dynamic> json) {
    final dateValue =
        DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();
    return DeliverySlotModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Standard slot',
      date: dateValue,
      startTime:
          json['start_time']?.toString() ??
          json['startTime']?.toString() ??
          '10:00 AM',
      endTime:
          json['end_time']?.toString() ??
          json['endTime']?.toString() ??
          '01:00 PM',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      isExpress:
          json['is_express'] as bool? ?? json['isExpress'] as bool? ?? false,
      isAvailable:
          json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'date': date.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'price': price,
    'is_express': isExpress,
    'is_available': isAvailable,
  };
}
