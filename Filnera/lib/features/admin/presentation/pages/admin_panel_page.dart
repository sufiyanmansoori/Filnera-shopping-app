import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/product_model.dart';
import '../../data/admin_product_store.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _addProduct() {
    final price = double.tryParse(_price.text.trim());
    if (_name.text.trim().isEmpty ||
        _category.text.trim().isEmpty ||
        price == null ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter product name, category and valid price'),
        ),
      );
      return;
    }
    final id = 'admin-${DateTime.now().millisecondsSinceEpoch}';
    AdminProductStore.addProduct(
      ProductModel(
        id: id,
        name: _name.text.trim(),
        category: _category.text.trim(),
        price: price,
        originalPrice: price,
        rating: 0,
        reviewCount: 0,
        imageUrl: 'https://picsum.photos/seed/$id/700/700',
        gallery: ['https://picsum.photos/seed/$id/700/700'],
        description: _description.text.trim().isEmpty
            ? 'New Manara product.'
            : _description.text.trim(),
        features: const ['Quality checked', 'Fast delivery', 'Easy returns'],
        isFeatured: true,
        stock: 20,
      ),
    );
    _name.clear();
    _category.clear();
    _price.clear();
    _description.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product added to catalog')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin product panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ADD NEW PRODUCT',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Product name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Selling price',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('ADD PRODUCT'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/admin/catalog'),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('OPEN CATALOG MANAGER'),
          ),
          const SizedBox(height: 22),
          ValueListenableBuilder<List<ProductModel>>(
            valueListenable: AdminProductStore.products,
            builder: (context, products, child) => Text(
              '${products.length} products in catalog',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
