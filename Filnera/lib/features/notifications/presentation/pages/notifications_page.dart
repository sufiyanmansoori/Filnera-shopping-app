import 'package:flutter/material.dart';

import '../../data/notification_store.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read') NotificationStore.markAllRead();
            if (value == 'clear') NotificationStore.clearAll();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'read', child: Text('Mark all as read')),
            PopupMenuItem(value: 'clear', child: Text('Clear all')),
          ],
        ),
      ],
    ),
    body: ValueListenableBuilder<List<AppNotification>>(
      valueListenable: NotificationStore.items,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('You are all caught up'),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey(item.id),
              onDismissed: (_) => NotificationStore.remove(item.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.shade50,
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              child: Card(
                color: item.read ? Colors.white : const Color(0xFFFFF7E8),
                child: ListTile(
                  leading: Icon(
                    item.read
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: item.read ? Colors.grey : Colors.orange,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.read ? FontWeight.w500 : FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(item.message),
                  trailing: IconButton(
                    tooltip: 'Mark as read',
                    onPressed: item.read
                        ? null
                        : () => NotificationStore.markRead(item.id),
                    icon: const Icon(Icons.done),
                  ),
                  onTap: () => NotificationStore.markRead(item.id),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
