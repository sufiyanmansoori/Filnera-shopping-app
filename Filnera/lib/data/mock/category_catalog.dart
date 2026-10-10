import '../models/product_model.dart';

const categoryNames = [
  'Mobiles',
  'Electronics',
  'Fashion',
  'Shoes',
  'Home',
  'Furniture',
  'TV & Appliances',
  'Beauty',
  'Toys',
  'Grocery',
  'Wellness',
  'Travel',
  'Gift Cards',
  'Rewards',
  'Minutes',
];

final categoryProducts = [
  for (final category in categoryNames)
    for (var index = 1; index <= 30; index++)
      ProductModel(
        id: '${category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${index.toString().padLeft(2, '0')}',
        name: '$category Essential $index',
        category: category,
        price: 499 + (index * 275),
        originalPrice: 799 + (index * 375),
        rating: 4.1 + ((index % 9) / 10),
        reviewCount: 25 + (index * 17),
        imageUrl: _images[(index - 1) % _images.length],
        gallery: [_images[(index - 1) % _images.length]],
        description:
            'A reliable $category pick for everyday shopping with fast delivery and easy returns.',
        features: const ['Quality assured', 'Fast delivery', 'Easy returns'],
        isFeatured: index <= 4,
        stock: 8 + index,
      ),
];

const _images = [
  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
];
