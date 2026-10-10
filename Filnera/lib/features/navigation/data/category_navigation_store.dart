import 'package:flutter/material.dart';

class CategoryNavigationStore {
  CategoryNavigationStore._();

  static final selectedCategory = ValueNotifier<String>('All');

  static const categories = [
    ('All', '🛍️'),
    ('Mobiles', '📱'),
    ('Electronics', '💻'),
    ('Fashion', '👕'),
    ('Shoes', '👟'),
    ('Home', '🏠'),
    ('Furniture', '🛋️'),
    ('TV & Appliances', '📺'),
    ('Beauty', '💄'),
    ('Toys', '🧸'),
    ('Grocery', '🛒'),
    ('Wellness', '💊'),
    ('Travel', '✈️'),
    ('Gift Cards', '🎁'),
    ('Rewards', '🪙'),
    ('Minutes', '⚡'),
  ];

  static void select(String category) {
    selectedCategory.value = category;
  }
}
