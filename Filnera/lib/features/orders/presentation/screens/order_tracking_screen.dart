import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/order_timeline_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchTracking(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracking = provider.tracking;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TrackingMapWidget(
                location: tracking?.location ?? 'Delivery Partner',
              ),
              const SizedBox(height: 12),
              Text('Status: ${tracking?.status ?? 'Unknown'}'),
              const SizedBox(height: 12),
              const OrderTimelineWidget(
                timeline: ['Order placed', 'Packed', 'On the way'],
              ),
            ],
          );
        },
      ),
    );
  }
}
