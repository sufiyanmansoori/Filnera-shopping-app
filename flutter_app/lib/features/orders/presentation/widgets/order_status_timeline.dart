import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.steps,
    this.currentStep = 0,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Colors.green : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                steps[index],
                style: TextStyle(
                  fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                  color: isDone ? Colors.green.shade800 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
