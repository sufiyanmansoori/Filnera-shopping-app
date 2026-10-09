import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isRecommended = false,
    this.isEnabled = true,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String icon;
  final bool isRecommended;
  final bool isEnabled;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    subtitle,
    icon,
    isRecommended,
    isEnabled,
    metadata,
  ];
}
