import 'package:flutter/material.dart';

class ReturnForm extends StatefulWidget {
  const ReturnForm({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Describe the issue with the product',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              final reason = _controller.text.trim();
              if (reason.isNotEmpty) {
                widget.onSubmit(reason);
              }
            },
            child: const Text('Submit request'),
          ),
        ),
      ],
    );
  }
}
