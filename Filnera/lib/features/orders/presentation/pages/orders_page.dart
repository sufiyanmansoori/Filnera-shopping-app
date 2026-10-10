import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.product,
    required this.status,
    required this.date,
    required this.source,
    required this.amount,
    required this.image,
  });

  final String id;
  final String product;
  final String status;
  final String date;
  final String source;
  final double amount;
  final IconData image;
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  int _category = 0;
  String _query = '';
  String? _status;
  double? _maxPrice;
  int _promoPage = 0;
  Timer? _promoTimer;

  final _orders = const [
    OrderModel(
      id: 'MN-1001',
      product: 'S-Softline Premium Back Cover',
      status: 'REFUNDED',
      date: 'Jul 24, 2024',
      source: 'Flipkart',
      amount: 707,
      image: Icons.phone_android,
    ),
    OrderModel(
      id: 'MN-1002',
      product: 'Wireless Bluetooth Headphones',
      status: 'DELIVERED',
      date: 'Aug 03, 2024',
      source: 'Flipkart',
      amount: 1299,
      image: Icons.headphones,
    ),
    OrderModel(
      id: 'MN-1003',
      product: 'Daily Grocery Essentials',
      status: 'DELIVERED',
      date: 'Aug 12, 2024',
      source: 'Grocery',
      amount: 899,
      image: Icons.shopping_basket,
    ),
    OrderModel(
      id: 'MN-1004',
      product: 'Quick Commerce Snack Box',
      status: 'CANCELLED',
      date: 'Aug 19, 2024',
      source: 'Minutes',
      amount: 449,
      image: Icons.fastfood,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _promoPage = (_promoPage + 1) % 3);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    _promoTimer?.cancel();
    super.dispose();
  }

  List<OrderModel> get _filtered {
    final category = ['All', 'Flipkart', 'Grocery', 'Minutes'][_category];
    return _orders.where((order) {
      final matchesQuery =
          _query.isEmpty ||
          order.id.toLowerCase().contains(_query) ||
          order.product.toLowerCase().contains(_query);
      final matchesCategory = category == 'All' || order.source == category;
      final matchesStatus = _status == null || order.status == _status;
      final matchesPrice = _maxPrice == null || order.amount <= _maxPrice!;
      return matchesQuery && matchesCategory && matchesStatus && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _promotions()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchHeaderDelegate(child: _searchBar(), height: 74),
            ),
            SliverToBoxAdapter(child: _categories()),
            if (items.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _emptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _orderCard(items[index]),
                  childCount: items.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _promotions() => Column(
    children: [
      SizedBox(
        height: 126,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_promoPage),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: [Colors.blue, Colors.deepPurple, Colors.teal][_promoPage],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.white, size: 36),
                const SizedBox(width: 12),
                Text(
                  [
                    'Flipkart × Uber',
                    'Travel offers for you',
                    'More rewards with Manara',
                  ][_promoPage],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
            width: index == _promoPage ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index == _promoPage ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _searchBar() => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) {
                    setState(() => _query = value.trim().toLowerCase());
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search your orders',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filter orders',
            onPressed: _showFilters,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    ),
  );

  Widget _categories() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: Row(
      children: ['All', 'Flipkart', 'Grocery', 'Minutes']
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: _category == entry.key,
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: _category == entry.key ? Colors.white : Colors.black,
                ),
                onSelected: (_) => setState(() => _category = entry.key),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _orderCard(OrderModel order) => Card(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: InkWell(
      onTap: () => context.push('/order/${order.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(order.image, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status == 'REFUNDED'
                            ? 'Refund Completed'
                            : '${_prettyStatus(order.status)} on ${order.date}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        order.product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Order ${order.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            if (order.status == 'REFUNDED')
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Refund of ₹${order.amount.toStringAsFixed(0)}'),
                    const Spacer(),
                    const Icon(Icons.account_balance),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          'No ${['', 'Flipkart', 'Grocery', 'Minutes'][_category]} Orders Found',
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Start Shopping'),
        ),
      ],
    ),
  );

  String _prettyStatus(String status) =>
      status[0] + status.substring(1).toLowerCase();

  Future<void> _showFilters() async {
    final result = await showModalBottomSheet<(String?, double?)>(
      context: context,
      builder: (context) =>
          _OrderFilterSheet(status: _status, maxPrice: _maxPrice),
    );
    if (result != null) {
      setState(() {
        _status = result.$1;
        _maxPrice = result.$2;
      });
    }
  }
}

class _OrderFilterSheet extends StatefulWidget {
  const _OrderFilterSheet({required this.status, required this.maxPrice});
  final String? status;
  final double? maxPrice;

  @override
  State<_OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<_OrderFilterSheet> {
  late String? _status = widget.status;
  late double _price = widget.maxPrice ?? 2000;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Filter orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        DropdownButton<String?>(
          value: _status,
          hint: const Text('Any status'),
          items: [null, 'DELIVERED', 'REFUNDED', 'CANCELLED']
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value ?? 'Any status'),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _status = value),
        ),
        Text('Up to ₹${_price.round()}'),
        Slider(
          value: _price,
          min: 100,
          max: 2000,
          onChanged: (value) => setState(() => _price = value),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                context.pop((_status, _price == 2000 ? null : _price)),
            child: const Text('Apply filters'),
          ),
        ),
      ],
    ),
  );
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchHeaderDelegate({required this.child, required this.height});
  final Widget child;
  final double height;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) => false;
}

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Order $orderId')),
    body: const Center(
      child: Text(
        'Order details will be loaded securely from the order service.',
      ),
    ),
  );
}
