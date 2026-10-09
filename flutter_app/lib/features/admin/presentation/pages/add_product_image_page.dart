import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/product_model.dart';
import '../../data/admin_product_store.dart';
import '../../data/product_image_provider.dart';

class AddProductImagePage extends StatefulWidget {
  const AddProductImagePage({super.key});

  @override
  State<AddProductImagePage> createState() => _AddProductImagePageState();
}

class _AddProductImagePageState extends State<AddProductImagePage> {
  final ProductImageProvider _imageProvider = ProductImageProvider.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await _imageProvider.pickImageFromGallery();
    if (!mounted) return;
    if (picked == null) {
      if (_imageProvider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_imageProvider.errorMessage!)));
      }
      return;
    }
    setState(() {});
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name.')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid price.')));
      return;
    }

    if (_imageProvider.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    final product = ProductModel(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      category: 'Fashion',
      price: price,
      originalPrice: price + price * 0.10,
      rating: 4.4,
      reviewCount: 0,
      imageUrl: _imageProvider.selectedImage!.path,
      gallery: [_imageProvider.selectedImage!.path],
      description: 'Freshly added product from the gallery.',
      features: const ['Store uploaded image', 'Global product listing'],
      isFeatured: false,
      stock: 10,
    );

    AdminProductStore.addProduct(product);

    _imageProvider.removeSelectedImage();
    _nameController.clear();
    _priceController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved to the catalog.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a product from your gallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickFromGallery,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.4,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: _imageProvider.selectedImage == null
                      ? Center(
                          child: _imageProvider.isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 56,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Upload Image',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tap to choose from gallery',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_imageProvider.selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FloatingActionButton.small(
                                heroTag: 'remove-image',
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  _imageProvider.removeSelectedImage();
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
