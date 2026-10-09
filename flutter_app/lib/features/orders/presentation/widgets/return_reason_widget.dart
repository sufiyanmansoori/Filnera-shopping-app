import 'package:flutter/material.dart';

class ReturnReasonWidget extends StatefulWidget {
  const ReturnReasonWidget({super.key});

  @override
  State<ReturnReasonWidget> createState() => _ReturnReasonWidgetState();
}

class _ReturnReasonWidgetState extends State<ReturnReasonWidget> {
  final List<String> _reasons = [
    'Damaged item',
    'Wrong item delivered',
    'Changed my mind',
    'Arrived late',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return Reason',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selected,
              hint: const Text('Select a reason'),
              items: _reasons
                  .map(
                    (reason) => DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selected = value),
            ),
          ],
        ),
      ),
    );
  }
}
