import 'package:flutter/foundation.dart';

import '../../../data/mock/mock_products.dart';
import '../../../data/mock/pdf_catalog_products.dart';
import '../../../data/models/product_model.dart';

class AdminProductStore {
  AdminProductStore._();

  static final products = ValueNotifier<List<ProductModel>>(
    List<ProductModel>.of([...mockProducts, ...pdfCatalogProducts]),
  );

  static void addProduct(ProductModel product) {
    products.value = [...products.value, product];
  }

  static void removeProduct(String productId) {
    products.value = products.value
        .where((product) => product.id != productId)
        .toList();
  }
}
