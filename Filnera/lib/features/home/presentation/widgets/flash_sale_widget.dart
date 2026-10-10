import 'package:flutter/material.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({
    super.key,
    required this.title,
    this.items = const <Widget>[],
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}
