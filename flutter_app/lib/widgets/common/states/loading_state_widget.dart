import 'package:flutter/material.dart';

import '../loaders/loading_indicator.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: LoadingIndicator(label: message));
  }
}
