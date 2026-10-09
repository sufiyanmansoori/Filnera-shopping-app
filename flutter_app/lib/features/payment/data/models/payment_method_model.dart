import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isRecommended = false,
    this.isEnabled = true,
    this.metadata = const {},
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'card',
      title: json['title'] as String? ?? 'Payment method',
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? 'payment',
      isRecommended: json['isRecommended'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String icon;
  final bool isRecommended;
  final bool isEnabled;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'isRecommended': isRecommended,
      'isEnabled': isEnabled,
      'metadata': metadata,
    };
  }

  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      icon: icon,
      isRecommended: isRecommended,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }
}
