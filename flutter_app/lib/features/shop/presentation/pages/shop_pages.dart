import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/mock/mock_products.dart';
import '../../../../core/utils/formatters.dart';
import '../../shop_store.dart';
import '../../../../data/mock/ad_content.dart';
import '../../../media/widgets/autoplay_video_reel.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _searchController = TextEditingController();
  final _places = const [
    'Mumbai, Maharashtra',
    'New Delhi, Delhi',
    'Bengaluru, Karnataka',
    'Hyderabad, Telangana',
  ];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    // A real GPS lookup is intentionally avoided: this remains safe and works offline.
    ShopStore.location.value = 'Current location';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Using your current location')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final results = _places
        .where((place) => place.toLowerCase().contains(_query))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose delivery location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search for area, street or pincode',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.clear),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primary),
              title: const Text('Use my current location'),
              subtitle: const Text(
                'Use an approximate location on this device',
              ),
              onTap: _useCurrentLocation,
            ),
          ),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No matching locations found')),
            ),
          ...results.map(
            (place) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
                title: Text(place),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ShopStore.location.value = place;
                  context.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});
  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  String sort = 'Relevance';
  double min = 0, max = 20000;
  final brands = <String>{};
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Filters'),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            sort = 'Relevance';
            brands.clear();
            min = 0;
            max = 20000;
          }),
          child: const Text('CLEAR'),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('PRICE', style: TextStyle(fontWeight: FontWeight.bold)),
        RangeSlider(
          values: RangeValues(min, max),
          min: 0,
          max: 20000,
          divisions: 20,
          labels: RangeLabels('₹${min.round()}', '₹${max.round()}'),
          onChanged: (v) => setState(() {
            min = v.start;
            max = v.end;
          }),
        ),
        // ignore: deprecated_member_use
        const Divider(),
        const Text('SORT BY', style: TextStyle(fontWeight: FontWeight.bold)),
        ...[
          'Relevance',
          'Price -- Low to High',
          'Price -- High to Low',
          'Customer Ratings',
        ].map(
          (v) => RadioListTile<String>(
            value: v,
            // ignore: deprecated_member_use
            groupValue: sort,
            title: Text(v),
            // ignore: deprecated_member_use
            onChanged: (x) => setState(() => sort = x!),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Divider(),
        const Text('BRAND', style: TextStyle(fontWeight: FontWeight.bold)),
        ...['Manara', 'AeroSmart', 'Nova', 'Premium brands'].map(
          (v) => CheckboxListTile(
            value: brands.contains(v),
            title: Text(v),
            onChanged: (x) =>
                setState(() => x! ? brands.add(v) : brands.remove(v)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Divider(),
        const Text(
          'CUSTOMER RATINGS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...['4★ & above', '3★ & above'].map(
          (v) => ListTile(
            title: Text(v),
            leading: const Icon(Icons.star, color: Colors.amber),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('APPLY FILTERS'),
        ),
      ],
    ),
  );
}

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});
  @override
  Widget build(BuildContext context) => const ReelsPage();
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manara Play'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.shopping_bag_outlined),
                text: 'Product Reels',
              ),
              Tab(icon: Icon(Icons.movie_outlined), text: 'Drama'),
              Tab(icon: Icon(Icons.live_tv_outlined), text: 'Live Ads'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReelGrid(images: productReelImages, label: 'Shop this product'),
            _ReelGrid(images: dramaReelImages, label: 'Watch drama reel'),
            const _LiveAdPanel(),
          ],
        ),
      ),
    );
  }
}

class _ReelGrid extends StatelessWidget {
  const _ReelGrid({required this.images, required this.label});
  final List<String> images;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: images.length,
      itemBuilder: (_, index) => AutoplayVideoReel(
        videoUrl: _videoUrls[index % _videoUrls.length],
        title: '$label • ${index + 1}',
        subtitle: 'Swipe up for the next ad',
      ),
    );
  }
}

const _videoUrls = [
  'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
];

class _LiveAdPanel extends StatelessWidget {
  const _LiveAdPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 230,
                    child: AutoplayVideoReel(
                      videoUrl: _videoUrls.first,
                      title: 'Live shopping showcase',
                      subtitle: 'Live product demo and limited-time offer',
                    ),
                  ),
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(
                      avatar: Icon(Icons.circle, color: Colors.red, size: 10),
                      label: Text('LIVE NOW'),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: IconButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(content: Text('Live ad started')),
                            ),
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live shopping showcase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Watch product demos, ask questions and shop live offers.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live reminders enabled')),
          ),
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('REMIND ME'),
        ),
      ],
    );
  }
}

class DealsPage extends StatelessWidget {
  const DealsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Top Deals')),
    body: GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mockProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _DealTile(product: mockProducts[i]),
    ),
  );
}

class _DealTile extends StatelessWidget {
  const _DealTile({required this.product});
  final dynamic product;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(product.name, maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              AppFormatters.currency(product.price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}
